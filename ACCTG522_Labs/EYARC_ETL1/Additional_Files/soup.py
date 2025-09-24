from bs4 import BeautifulSoup
import csv

# Load an iXBRL (HTML embedded XBRL) file
with open('ACCTG522_Labs/Class03/aapl-20230930.html', 'r') as f:
    soup = BeautifulSoup(f, 'html.parser')

# Extract iXBRL-specific tags (for example: ix:nonfraction tags)
ixbrl_data = soup.find_all('ix:nonfraction')

# Open a CSV file to write the extracted data
with open('ixbrl_data.csv', mode='w', newline='', encoding='utf-8') as csv_file:
    writer = csv.writer(csv_file)
    
    # Write the header for the CSV
    writer.writerow(['ElementName', 'Value'])
    
    # Iterate over the extracted iXBRL data and write each row to the CSV
    for tag in ixbrl_data:
        element_name = tag['name']  # Extract element name
        value = tag.get_text()  # Extract value (text content)
        writer.writerow([element_name, value])

print("iXBRL data has been saved to ixbrl_data.csv")
