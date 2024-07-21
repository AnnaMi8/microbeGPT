# Submit queries to database (open one connection per query), use timeout to close queries that are too long/wrong.
import sqlite3
import time
from func_timeout import func_timeout, FunctionTimedOut

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



def execute_query_and_measure_time(query_and_question_pair, db_path, output_file_path):
    """
    Reads list of questions and queries and submits the SQL query to database, then write results in output text file.
    Args:
        query_and_question_pair (list) : List containing (query, question) pairs.
        db_path (str): Path to the SQL database.
        output_file(str): path to output text file.

    Returns:
        output text file is filled in with results.
    """
    try:
        question, query = query_and_question_pair
        connection = sqlite3.connect(db_path)
        cursor = connection.cursor()

        start_time = time.time()
        cursor.execute(query)
        result = cursor.fetchone()
        end_time = time.time()
        execution_time = end_time - start_time

        with open(output_file_path, 'a') as output_file:
            output_file.write(f"{question}\t{query}\t{result}\t{execution_time:.4f}\n")

    except sqlite3.Error as sql_error:
        with open(output_file_path, 'a') as output_file:
            output_file.write(f"{question}\t{query}\tError executing query: {str(sql_error)}\t{execution_time}\n")

    except Exception as error:
        with open(output_file_path, 'a') as output_file:
            output_file.write(f"{question}\t{query}\tError executing query: {error}\t{execution_time}\n")

    finally:
        connection.close()


#timeout and submit questions in loop
# replace with pathway file names of interest to run a pipeline performance evaluation
SQL_queries_AI_generated_path = './benchmarking_sqlite_queries.sql'
SQLite_database_path = './microbiome_gpt_Db_3.db'
results_output_path = './benchmarking_sqlite_results.txt'
queries_to_execute = read_sql_commands_from_file(SQL_queries_AI_generated_path)
counter = 0
for query_and_question_pair in queries_to_execute:
    question, query = query_and_question_pair
    counter +=1
    try:
        doitReturnValue = func_timeout(4500, execute_query_and_measure_time, args=(query_and_question_pair, SQLite_database_path , results_output_path ))
        print(f"{counter}-Search completed successfully")
    except FunctionTimedOut:
        timeout = True
        print("Search could not complete within 500 seconds and was terminated.\t")
    except Exception as e:
        # Handle any exceptions that function might raise here
        print(f"An error occurred: {e}")
    if timeout:
        with open('./pan4_1_results.txt', 'a') as output_file:
            output_file.write(f"{question}\t{query}\tError executing query: Search could not complete within 3500 seconds and was terminated.\ More than 4000 s.\n")