#!/ddnstor/imau_sunzhihong/mnt1/conda/bin/python
import argparse
import os
import shutil

def split_file(input_file, line_count, output_folder, force):
    """
    Split a file into multiple smaller files.

    :param input_file: Path to the input file.
    :param line_count: Number of lines in each split file.
    :param output_folder: Folder where the split files will be saved.
    :param force: Overwrite the output folder if it already exists.
    """
    # Check if output folder exists
    if os.path.exists(output_folder):
        if force:
            shutil.rmtree(output_folder)
            os.makedirs(output_folder)
        else:
            print(f"Output folder '{output_folder}' already exists. Use -f to overwrite.")
            return
    else:
        os.makedirs(output_folder)

    try:
        with open(input_file, 'r') as file:
            lines = file.readlines()

        # Split lines into chunks
        for i in range(0, len(lines), line_count):
            with open(os.path.join(output_folder, f'output_{i//line_count + 1}.txt'), 'w') as output_file:
                output_file.writelines(lines[i:i + line_count])

        print("File splitting completed.")
    except Exception as e:
        print(f"An error occurred: {e}")

def main():
    parser = argparse.ArgumentParser(description='Split a file into multiple smaller files.')
    parser.add_argument('-i', '--input', required=True, help='Input file path')
    parser.add_argument('-l', '--lines', type=int, required=True, help='Number of lines in each split file')
    parser.add_argument('-o', '--output', required=True, help='Output folder path')
    parser.add_argument('-f', '--force', action='store_true', help='Overwrite output folder if exists')

    args = parser.parse_args()

    split_file(args.input, args.lines, args.output, args.force)

if __name__ == "__main__":
    main()
