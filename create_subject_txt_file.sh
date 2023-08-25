#!/bin/bash

# This script lists folder names from a given directory and writes them to an output file specified by the user.

# Function to display script usage information
display_help() {
    echo "This script lists folder names from a given directory and writes them to an output file specified by the user."
    echo "Usage: $(basename "$0") [options] <output_file>"
    echo "Options:"
    echo "  --help    Display this help message"
}

# Check for command-line options
while [[ $# -gt 0 ]]; do
    case "$1" in
        --help)
            display_help
            exit 0
            ;;
        *)
            break
            ;;
    esac
    shift
done

# Check if the output file argument is provided
if [[ $# -lt 1 ]]; then
    echo "Error: Output file not provided."
    display_help
    exit 1
fi

output_file="$1"
subjects_dir=$(dirname "${output_file}")

# List all folder names and write to the output file
cd "$subjects_dir" || exit 1
find . -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | grep -Eo '[0-9]+$' > "$output_file"

echo "Folder names listed in ${output_file}."
