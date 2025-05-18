import json

def transform_json_outputs_to_string(input_filepath, output_filepath="dumps.json"):
    """
    Reads a JSON file containing a list of objects, converts the 'output'
    field of each object from a JSON object/array to a JSON string representation,
    and writes the transformed list to a new JSON file.

    Args:
        input_filepath (str): The path to the input JSON file.
        output_filepath (str): The path to the output JSON file.
    """
    try:
        # Open and read the input JSON file
        with open(input_filepath, 'r', encoding='utf-8') as infile:
            original_data = json.load(infile)
        print(f"Successfully loaded data from '{input_filepath}'.")
    except FileNotFoundError:
        print(f"Error: Input file '{input_filepath}' not found.")
        return
    except json.JSONDecodeError as e:
        print(f"Error decoding JSON from '{input_filepath}': {e}")
        return
    except Exception as e:
        print(f"An unexpected error occurred while reading '{input_filepath}': {e}")
        return

    # Ensure the loaded data is a list
    if not isinstance(original_data, list):
        print("Error: Input JSON file does not contain a list at the root level.")
        return

    transformed_data = []
    # Iterate through each item in the original data list
    for index, item in enumerate(original_data):
        if not isinstance(item, dict):
            print(f"Warning: Item at index {index} is not an object/dictionary. Skipping transformation for this item.")
            transformed_data.append(item) # Add as is or handle as needed
            continue

        new_item = item.copy() # Create a shallow copy to modify

        # Check if the 'output' key exists in the current item
        if 'output' in new_item:
            # Check if the 'output' field is already a string.
            # This is a basic check to prevent re-processing if the script is run multiple times
            # on an already processed file, or if some entries are already strings.
            if isinstance(new_item['output'], str):
                try:
                    # Attempt to parse the string to see if it's already valid JSON.
                    # If it is, we assume it's already in the desired stringified format.
                    json.loads(new_item['output'])
                    print(f"Info: 'output' field in item at index {index} is already a string that is valid JSON. Keeping as is.")
                except json.JSONDecodeError:
                    # If it's a string but not valid JSON, it's an unexpected format.
                    # We'll keep it as is to avoid data loss, but log a warning.
                    print(f"Warning: 'output' field in item at index {index} is a string but not valid JSON. Keeping as is: {new_item['output'][:50]}...")
            elif isinstance(new_item['output'], (dict, list)):
                # If 'output' is a dictionary or list, convert it to a JSON string
                try:
                    new_item['output'] = json.dumps(new_item['output'])
                except TypeError as e:
                    print(f"Error stringifying 'output' for item at index {index}: {e}. Keeping original object/list.")
                    # If dumping fails (e.g., non-serializable objects), keep the original to avoid data loss.
                    # This shouldn't happen with standard JSON-compatible data.
                    new_item['output'] = item['output'] # Revert to original
            else:
                # If 'output' is neither a string, dict, nor list, log it and keep as is.
                print(f"Warning: 'output' field in item at index {index} is of an unexpected type ({type(new_item['output'])}). Keeping as is.")
        else:
            # If 'output' key is not found, log a warning
            print(f"Warning: 'output' field not found in item at index {index}.")

        transformed_data.append(new_item)

    try:
        # Write the transformed data to the output JSON file
        with open(output_filepath, 'w', encoding='utf-8') as outfile:
            # Use indent=2 for pretty-printing the output JSON file
            json.dump(transformed_data, outfile, indent=2)
        print(f"Successfully transformed data and saved to '{output_filepath}'.")
    except IOError:
        print(f"Error: Could not write to output file '{output_filepath}'.")
    except Exception as e:
        print(f"An unexpected error occurred while writing '{output_filepath}': {e}")

if __name__ == '__main__':
    input_file = input("Enter the path to your input JSON file (e.g., train.json): ")
    if not input_file.strip(): # Check if input is empty or just whitespace
        print("No input file provided. Exiting.")
    else:
        output_file = "dumps.json" # Define the output file name
        transform_json_outputs_to_string(input_file, output_file)
