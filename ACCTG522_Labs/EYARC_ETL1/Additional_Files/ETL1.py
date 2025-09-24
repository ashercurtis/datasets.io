import re
import csv

# Regular expression pattern to match the new format: country code, numeric, period number, and time period
pattern = r'([A-Z]+)(\d+)-(\d+)([A-Z]+)'

# Function to process a string and extract parts
def extract_parts(input_string):
    match = re.match(pattern, input_string)
    if match:
        # Return the matched groups: Country, NumericCode, Week/MonthNumber, Period
        return [match.group(1), match.group(2), match.group(3), match.group(4)]
    else:
        return None

# Read from CSV and process each row
def process_csv(input_file, output_file):
    with open(input_file, mode='r', newline='') as infile, open(output_file, mode='w', newline='') as outfile:
        reader = csv.reader(infile)
        writer = csv.writer(outfile)
        
        # Write header to output file
        writer.writerow(["Country", "NumericCode", "Week/MonthNumber", "Period", "FirstName", "LastName"])
        
        for row in reader:
            employee_code = row[0]  # First element is the employee code
            first_name = row[1]     # Second element is the first name
            last_name = row[2]      # Third element is the last name
            
            result = extract_parts(employee_code)
            if result:
                # Write the separated parts along with the first and last name to the output CSV
                writer.writerow(result + [first_name, last_name])

# Example usage
input_file = 'ACCTG522_Labs/Class03/ETL_input1.csv'
output_file = 'ACCTG522_Labs/Class03/separated_employee_codes.csv'
process_csv(input_file, output_file)
