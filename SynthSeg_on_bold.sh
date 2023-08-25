#!/bin/bash

# This script performs MRI image segmentation using FreeSurfer's mri_synthseg tool.

# Function to display script usage information
display_help() {
    echo "This script performs MRI image segmentation using FreeSurfer's mri_synthseg tool."
    echo "Usage: $(basename "$0") [options] <input_fmri_file> <output_segmentation_file> <qc_file_path>"
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
if [ $# -ne 3 ]; then
    echo "Error: Invalid number of arguments."
    display_help
    exit 1
fi

BOLD_ref="$1"
ROI_file="$2"
qc_path="$3"

# Create the output directory if it doesn't exist
output_dir=$(dirname "${ROI_file}")
if [ ! -d "${output_dir}" ]; then
  mkdir -p "${output_dir}"
fi

# Load necessary modules
module load apptainer/1.1.8

# Run FreeSurfer's mri_synthseg tool for image segmentation
# Note: The script is set to run on the /scratch directory on Compute Canada.
# Please modify the -B argument and the path accordingly if you're running it from a different directory,
# but this might require more modifications in other scripts
apptainer run -B /scratch freesurfer.sif mri_synthseg --i "${BOLD_ref}" --o "${ROI_file}" --robust --parc --qc "${qc_path}"
