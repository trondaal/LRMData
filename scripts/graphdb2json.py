import os
import json
from SPARQLWrapper import SPARQLWrapper, JSON


def query_graphdb(sparql_endpoint, query):
    sparql = SPARQLWrapper(sparql_endpoint)
    sparql.setQuery(query)
    sparql.setReturnFormat(JSON)
    results = sparql.query().convert()
    return results

def save_to_file(data, filename):
    with open(filename, 'w') as f:
        json.dump(data, f, indent=4)


def process_query_files(fromdir, todir, sparql_endpoint):
    for filename in os.listdir(fromdir):
        if filename.endswith(".sparql"):
            with open(os.path.join(fromdir, filename), 'r') as file:
                query = file.read()
                response = query_graphdb(sparql_endpoint, query)

                # derive json filename from sparql filename
                json_filename = os.path.splitext(filename)[0] + ".json"
                json_filepath = os.path.join(todir, json_filename)

                save_to_file(response, json_filepath)
                print(f"Processed {fromdir + '/' + filename} and saved results to {todir + '/' + json_filename}")


if __name__ == "__main__":
    endpoint_url = "http://localhost:7200/repositories/LRMSearch-data"
    query_directory = "../queries"  # directory containing your .sparql files
    json_directory = "../graphdb-dump"
    process_query_files(query_directory, json_directory, endpoint_url)