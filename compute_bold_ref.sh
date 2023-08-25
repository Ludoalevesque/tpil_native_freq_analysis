#!/bin/bash

if [ $# -ne 2 ]; then
  echo "Usage: $0 <input_4D_file> <output_3D_file>"
  exit 1
fi

HMC_fmri_file="$1"
output_bold_ref_file="$2"

output_dir=$(dirname "${output_bold_ref_file}")

if [ ! -d "${output_dir}" ]; then
  mkdir -p "${output_dir}"
fi
half_vol_file="${output_dir}/half_vol_file.nii.gz"

module load StdEnv/2020  gcc/9.3.0  cuda/11.0 fsl/6.0.4

# Task 1: Get the volume at 0.5
num_volumes=$(fslinfo "$HMC_fmri_file" | grep '^dim4' | awk '{print $2}')
half_index=$((num_volumes / 2))
fslroi "$HMC_fmri_file" "$half_vol_file" "$half_index" 1

# Task 2: Apply brain extraction on the ref volume image
bet "$half_vol_file" "$output_bold_ref_file"

# Removing temporary files
rm "$half_vol_file"


# HMC_fmri_file="/home/ludoal/scratch/freq_analysis_data/V1/sub-56/frequency_analysis_outputs/BOLD/sub-56_task-rest_bold_HMC.nii.gz"
# output_bold_ref_file="/home/ludoal/scratch/freq_analysis_data/V1/sub-56/frequency_analysis_outputs/BOLD/sub-56_task-rest_boldref.nii.gz"
# bash compute_bold_ref.sh "/home/ludoal/scratch/freq_analysis_data/V1/sub-56/frequency_analysis_outputs/BOLD/sub-56_task-rest_bold_HMC.nii.gz" "/home/ludoal/scratch/freq_analysis_data/V1/sub-56/frequency_analysis_outputs/BOLD/sub-56_task-rest_boldref.nii.gz"
