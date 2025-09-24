import re
import csv

# Regular expression pattern to match different country and employee code formats
pattern = r'([A-Za-z]+)(\d+)-(\d+)([A-Za-z]+)'

# Standardize country names (abbreviation or full)
def standardize_country(country_code):
    country_map = {
        "Japan": "JPN", "Canada": "CAN", "AUS": "AUS", "ARG": "ARG", "GER": "GER", "US": "USA", "ENG": "ENG"
    }
    return country_map.get(country_code, country_code)

# Standardize the period (month/week)
def standardize_period(period_code):
    if period_code in ['Mo', 'M']:
        return 'Month'
    elif period_code == 'W':
        return 'Week'
    else:
        return period_code  # Return as is if it's unusual

# Function to process each employee code and extract parts
def extract_and_standardize(input_string):
    match = re.match(pattern, input_string)
    if match:
        country = standardize_country(match.group(1))  # Standardize country
        numeric_code = match.group(2)  # Extract numeric code
        week_month_num = match.group(3)  # Extract number part of period
        period = standardize_period(match.group(4))  # Standardize period (Month or Week)
        return [country, numeric_code, week_month_num, period]
    else:
        return None  # Return None if pattern doesn't match

# Read from CSV and process each row
def process_messy_csv(input_file, output_file):
    with open(input_file, mode='r', newline='') as infile, open(output_file, mode='w', newline='') as outfile:
        reader = csv.reader(infile)
        writer = csv.writer(outfile)
        
        # Write header row to the output file
        writer.writerow(["EmployeeCode", "Country", "NumericCode", "Week/MonthNumber", "Period", "FirstName", "LastName"])

        for row in reader:
            employee_code = row[0]
            first_name = row[1]
            last_name = row[2]

            result = extract_and_standardize(employee_code)
            if result:
                writer.writerow([employee_code] + result + [first_name, last_name])

# Example usage
input_file = 'ACCTG522_Labs/Class03/ETL_input2.csv'
output_file = 'ACCTG522_Labs/Class03/cleaned_output.csv'
process_messy_csv(input_file, output_file)
