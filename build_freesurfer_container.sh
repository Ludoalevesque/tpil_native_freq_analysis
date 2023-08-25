#!/bin/bash

# This script checks for the existence of a file named "freesurfer.sif" in a given directory and its subdirectories.
# If the file doesn't exist, it builds the Docker container using apptainer and adds the filename to .gitignore.

# Function to display script usage information
display_help() {
    echo "This script checks for the existence of a file named "freesurfer.sif" in a given directory and its subdirectories.
    If the file doesn't exist, it builds the Docker container using apptainer and adds the filename to .gitignore."
    echo "Usage: $(basename "$0") [options]"
    echo "Options:"
    echo "  --help    Display the help message"
}

# Default values
filename="freesurfer.sif"
directory="${HOME}"

# Check for command-line options
while [[ $# -gt 0 ]]; do
    case "$1" in
        --help)
            display_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            display_help
            exit 1
            ;;
    esac
    shift
done

# Find the file and save the result in a variable
file_path=$(find "$directory" -type f -name "$filename" -print -quit)

# Load the required module
module load apptainer/1.1.8

if [ -n "$file_path" ]; then
    echo "File $filename exists at: $file_path"
else
    echo "File $filename does not exist in $directory or its subdirectories."
    echo "Building $filename..."
    apptainer build "$filename" docker://freesurfer/freesurfer:7.3.2
fi

# Add the file to .gitignore to prevent it from getting pushed in commits
if ! grep -qF "$filename" .gitignore; then
    echo "$filename" >> .gitignore
    echo "Added $filename to .gitignore"
else
    echo "$filename is already in .gitignore"
fi
