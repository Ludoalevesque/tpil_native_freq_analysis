#!/bin/bash

# This script applies head motion correction to an fMRI 4D image using FSL's mcflirt tool.

# Function to display script usage information
display_help() {
    echo "This script applies head motion correction to an fMRI 4D image using FSL's mcflirt tool."
    echo "Usage: $(basename "$0") [options] <input_fmri_file> <output_fmri_file>"
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

# Check if the correct number of arguments is provided
if [ $# -ne 2 ]; then
    echo "Error: Invalid number of arguments."
    display_help
    exit 1
fi

input_fmri_file="$1"
output_fmri_file="$2"

output_dir=$(dirname "${output_fmri_file}")

# Create the output directory if it doesn't exist
if [ ! -d "${output_dir}" ]; then
  mkdir -p "${output_dir}"
fi

# Load necessary modules
module load StdEnv/2020 gcc/9.3.0 cuda/11.0 fsl/6.0.4

# Apply head motion correction to the fMRI 4D image using mcflirt
mcflirt -in "$input_fmri_file" -out "${output_fmri_file}"