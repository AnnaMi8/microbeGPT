# ssingle connection, loop over questions and timeout
import time
from func_timeout import func_timeout, FunctionTimedOut
import glob
import psycopg2
import os
import subprocess

def krbauth(username: str, password: str) -> bool:
    """Perform Kerberos authentication.

    Args:
    username: username for the account having access to auth
    password: password for user
    Returns:
    success: the exit code of subprocess.run() flipped, (because a successful run exits with 0)
    and produces a non-zero output if something is wrong.
    """
    cmd = ["kinit", username]
    try:
        command = subprocess.run(
            cmd, input=password.encode(), check=True, capture_output=True
        )
        success = command.returncode
    except subprocess.CalledProcessError as e:
        print(f"The error output for krbauth: {e.output}")
        print(f"The error code: {e.returncode}")
        print(f"The stderr: {e.stderr}")
        print(f"The stdout: {e.stdout}")
        raise (subprocess.CalledProcessError(success, command))
    # we flip the bool value of success, because we are returning the exit code of subprocess.run()
    # if it is 0, then it was a successful run, meaning we need to flip it, to make it truthy
    return not bool(success)


def read_sql_commands_from_file(file_path):
    """
    Reads SQL commands from a file and returns them as a list of lists (query, question).
    Args:
        file_path (str): Path to the SQL file.

    Returns:
        list: List of lists containing (query, question) pairs.
    """
    query_question_pairs = []
    try:
        with open(file_path, 'r') as sql_file:
            content = sql_file.read()  # Read the entire file content
            # Split the content by double newline (question separator)
            sections = content.split('\n\n')
            for section in sections:
                lines = section.strip().split('\n')
                if len(lines) >= 2:
                    question = lines[0].strip('--').strip()
                    query = ' '.join(lines[1:]).strip()
                    query_question_pairs.append([question, query])
    except FileNotFoundError:
        print(f"File '{file_path}' not found.")
    return query_question_pairs



def execute_query_and_measure_time(query_and_question_pair, output_file_path):
    hostname = '' # replace with hostname
    database = 'datalake' # replace with database name
    username = '' # replace with username
    port_id = 5434
    conn = None
    cur = None
    execution_time = 0.0  # Initialize execution_time outside the try block

    try:
        conn = psycopg2.connect(host=hostname, dbname=database, user=username, port=port_id)
        cur = conn.cursor()
        question, query = query_and_question_pair
        start_time = time.time()
        cur.execute(query)
        result = cur.fetchone()
        end_time = time.time()
        execution_time = end_time - start_time

        with open(output_file_path, 'a') as output_file:
            output_file.write(f"{question}\t{query}\t{result}\t{execution_time:.4f}\n")

    except psycopg2.Error as e:
        with open(output_file_path, 'a') as output_file:
            error_message = str(e).split("\n")[0]
            output_file.write(f"{question}\t{query}\tError executing query: {str(error_message)}\t{execution_time}\n")

    except Exception as error:
        with open(output_file_path, 'a') as output_file:
            output_file.write(f"{question}\t{query}\tError executing query: {error}\t{execution_time}\n")

    finally:
        if cur is not None:
            cur.close()
        if conn is not None:
            conn.close()


# define input and output files paths
AIgenerated_SQL_queries_path = "../GPT_pipeline/postgreSQL_database_assessment/benchmarking_postgres_queries.sql"
output_results_path = "../GPT_pipeline/postgreSQL_database_assessment/benchmarking_postgres_answers.txt"

#timeout and submit questions in loop
answer = krbauth(username = "", password = "***") # replace with password and username
print(answer)

queries_to_execute = read_sql_commands_from_file(AIgenerated_SQL_queries_path)
counter = 0
for query_and_question_pair in queries_to_execute:
    question, query = query_and_question_pair
    counter +=1
    try:
        doitReturnValue = func_timeout(4000, execute_query_and_measure_time, args=(query_and_question_pair, output_results_path))
        print(f"{counter}-Search completed successfully")
    except FunctionTimedOut:
        with open(output_results_path, 'a') as output_file:
            output_file.write(f"{question}\tError executing query: Search could not complete within 4000 seconds and was terminated.\n")
    except Exception as e:
        # Handle any exceptions that function might raise here
        print(f"An error occurred: {e}")