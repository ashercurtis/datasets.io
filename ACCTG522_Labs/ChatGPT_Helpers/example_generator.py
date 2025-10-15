import csv
import random
from itertools import product

def csv_generator(num_obs=10, ranges_and_lists=[]):
    """
    Generates a CSV file with randomly selected data from lists and numeric ranges.

    Parameters:
        num_obs (int): Number of observations (rows) to generate.
        ranges_and_lists (list): List of tuples specifying field name and source.
            Each element should be in one of the following forms:
                ('field_name', [list_of_strings])
                ('field_name', range(start, end))
                ('field_name', ('concat', ['field1', 'field2']))  # combines existing fields

    Example:
        csv_generator(5, [
            ('name', ['Alice', 'Bob', 'Charlie']),
            ('city', ['Seattle', 'Portland', 'Austin']),
            ('age', range(20, 41)),
            ('id', ('concat', ['name', 'age']))
        ])
    """

    # Initialize output data
    data = []

    for _ in range(num_obs):
        record = {}

        # Generate basic fields
        for field, source in ranges_and_lists:
            if isinstance(source, range):  # numeric range
                record[field] = random.choice(list(source))
            elif isinstance(source, list):  # list of strings
                record[field] = random.choice(source)
            elif isinstance(source, tuple) and source[0] == 'concat':  
                # concatenation field (will process later)
                record[field] = source
            else:
                raise ValueError(f"Unsupported data type for field: {field}")
        
        # Handle concatenation fields after all base fields exist
        for field, source in ranges_and_lists:
            if isinstance(source, tuple) and source[0] == 'concat':
                concat_fields = source[1]
                record[field] = ''.join(str(record[f]) for f in concat_fields)
        
        data.append(record)

    # Write to CSV file
    filename = "generated_data.csv"
    with open(filename, "w", newline='', encoding='utf-8') as f:
        writer = csv.DictWriter(f, fieldnames=[f[0] for f in ranges_and_lists])
        writer.writeheader()
        writer.writerows(data)

    print(f"{num_obs} records written to {filename}")

csv_generator(5, [
            ('name', ['Alice', 'Bob', 'Charlie']),
            ('city', ['Seattle', 'Portland', 'Austin']),
            ('age', range(20, 41)),
            ('id', ('concat', ['name', 'age']))
        ])