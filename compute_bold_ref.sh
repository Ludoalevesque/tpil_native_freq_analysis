#!/bin/bash


HMC_fmri_file="$1"
output_bold_ref_file="$2"
half_vol_file="half_vol_file.nii.gz"

# HMC_fmri_file="/mnt/d/NeuroImaging/frequency_analysis/sub-02/sub-02_task-rest_bold_HMC.nii.gz"
# output_bold_ref_file="/mnt/d/NeuroImaging/frequency_analysis/sub-02/sub-02_task-rest_boldref.nii.gz"

output_dir=$(dirname "${output_bold_ref_file}")

if [ ! -d "${output_dir}" ]; then
  mkdir -p "${output_dir}"
fi

module load StdEnv/2020  gcc/9.3.0  cuda/11.0 fsl/6.0.4

# Task 1: Get the volume at 0.5
num_volumes=$(fslinfo "$HMC_fmri_file" | grep '^dim4' | awk '{print $2}')
half_index=$((num_volumes / 2))
fslroi "$HMC_fmri_file" "$half_vol_file" "$half_index" 1

# Task 2: Apply brain extraction on the ref volume image
bet "$half_vol_file" "$output_bold_ref_file"

# Removing temporary files
rm "$half_vol_file"
