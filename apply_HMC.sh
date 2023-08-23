#!/bin/bash

# input_fmri_file="/home/ludoal/scratch/freq_analysis_data/V1/sub-23/func/sub-23_task-rest_bold.nii.gz"
# output_fmri_file="/home/ludoal/scratch/freq_analysis_data/V1/sub-23/frequency_analysis_outputs/BOLD/sub-23_task-rest_bold_HMC.nii.gz"

if [ $# -ne 2 ]; then
  echo "Usage: $0 <input_fmri_file> <output_fmri_file>"
  exit 1
fi

input_fmri_file="$1"
output_fmri_file="$2"

output_dir=$(dirname "${output_fmri_file}")

if [ ! -d "${output_dir}" ]; then
  mkdir -p "${output_dir}"
fi

module load StdEnv/2020  gcc/9.3.0  cuda/11.0 fsl/6.0.4

# Apply head motion correction to fMRI 4D image
mcflirt -in "$input_fmri_file" -out "${output_fmri_file}"


