import os
import sqlite3
import time
from func_timeout import func_timeout, FunctionTimedOut
import argparse


def read_queries_from_file(filename):
    query_question_pair = []
    with open(filename, 'r') as file:
        content = file.read()
        sections = content.split('\n\n')
        for section in sections:
                lines = section.strip().split('\n')
                if len(lines) >= 2:
                    question_time = lines[0].strip()
                    sql_query = ' '.join(lines[1:]).strip()
                    query_question_pair.append(sql_query)
    return query_question_pair


def process_files_in_folder(folder_path):
    result_dict = {}
    file_names = os.listdir(folder_path)
    sorted_file_names = sorted(file_names, key=lambda x: int(x.split('_')[0][1:]) if x.split('_')[0][1:].isdigit() else float('inf'))
    for filename in sorted_file_names:
        if filename.endswith('.txt'):
            file_path = os.path.join(folder_path, filename)
            queries_list = read_queries_from_file(file_path)
            result_dict[os.path.splitext(filename)[0]] = queries_list
    return result_dict


def execute_query(query, db_path):
    try:
        connection = sqlite3.connect(db_path)
        cursor = connection.cursor()

        start_time = time.time()
        cursor.execute(query)
        result = cursor.fetchone()
        end_time = time.time()
        execution_time = end_time - start_time

        return result  # Return the query result

    except sqlite3.Error as sql_error:
        return f"Error executing query: {sql_error}"  # Return the error message

    except Exception as error:
        return f"Error executing query: {error}"  # Return the error message

def check_identical(lst):
    return all(item == lst[0] for item in lst)

    
    


# EXECUTE THE PIPELINE OF ACCESSING ALL FILES, READ THEM AND SUBMIT QUERIES TO DB, THEN STORE RESULTS
folder_path = './T07_sqlite/' 
database_path = './Microbiome_gpt_Db_3.db'
# Initialize an empty list to store all the results
all_results = []

# Loop over the dictionaries in the process_files_in_folder result
for key, value in process_files_in_folder(folder_path).items():
    question_id = key
    list_of_queries = value
    results = []  # Initialize an empty list for each dictionary
    
    # if queries are all identical, just execute the first one to save time
    if check_identical(list_of_queries) == True:
        query = list_of_queries[0]
        try:
                # Execute the query and get the result or error
                doitReturnValue = func_timeout(4000, execute_query, args=(query, database_path))
                # Append the result or error to the results list
                for i in range(len(list_of_queries)):
                    results.append(doitReturnValue)

        except FunctionTimedOut:
            # Handle timeout error
            for i in range(len(list_of_queries)):
                results.append(f"Error: Search could not complete within 4000 seconds and was terminated.")

        except Exception as e:
            # Handle other exceptions
            for i in range(len(list_of_queries)):
                results.append(f"Error: {e}")
    else:
        # Process each query in the list
        for query in list_of_queries:
            try:
                # Execute the query and get the result or error
                doitReturnValue = func_timeout(4000, execute_query, args=(query, database_path))
                # Append the result or error to the results list
                results.append(doitReturnValue)

            except FunctionTimedOut:
                # Handle timeout error
                results.append(f"Error: Search could not complete within 4000 seconds and was terminated.")

            except Exception as e:
                # Handle other exceptions
                results.append(f"Error: {e}")
    with open('answers_T07.txt', 'a') as output_file:
        results = '\t'.join(map(str, results))
        output_file.write(f'{question_id}\t{results}\n')
            