import requests
import xml.etree.ElementTree as ET
import time


def fetch_and_merge_xml(identifiers_file, output_file):
    # Namespace for parsing XML, adjust if necessary
    namespaces = {'': 'http://www.loc.gov/MARC21/slim'}

    # Initialize the root for the final merged XML document
    merged_root = ET.Element('root')

    with open(identifiers_file, 'r') as file:
        identifiers = [line.strip() for line in file if line.strip()]  # List of non-empty identifiers

    # Counter to track the number of requests
    request_count = 0

    for identifier in identifiers:
        url = f"https://authority.bibsys.no/authority/rest/authorities/v2/{identifier}?format=xml"
        response = requests.get(url)

        if response.status_code == 200:
            # Parse the XML from response
            root = ET.fromstring(response.content)
            merged_root.append(root)
            # Merge the XML elements
            #for child in root:
            #    merged_root.append(child)
        else:
            print(f"Failed to fetch data for identifier {identifier}. Status code: {response.status_code}")

        request_count += 1

        # Pause after every 100 requests
        if request_count % 50 == 0:
            print("Pausing for 5 seconds to avoid rate limits...")
            time.sleep(5)

    # Convert the merged XML to a tree and write to a file
    tree = ET.ElementTree(merged_root)
    tree.write(output_file, encoding='utf-8', xml_declaration=True)


if __name__ == '__main__':
    identifiers_file = '/Users/trondaal/GitHub/LRMData/mrc/bringsværd.bare.txt'  # Path to your file with identifiers
    output_file = '/Users/trondaal/GitHub/LRMData/mrc/bringsværd.bare.xml'  # Path for the resulting merged XML file
    fetch_and_merge_xml(identifiers_file, output_file)