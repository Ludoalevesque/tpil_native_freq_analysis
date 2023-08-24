#!/bin/bash

# Warning this script needs to be run on compute canada from a directory on the scratch. Other wise the last line has to be modified

if [ $# -ne 3 ]; then
  echo "Usage: $0 <input_fmri_file> <output_segmentation_file> <qc_file_path>"
  exit 1
fi

BOLD_ref="$1"
ROI_file="$2"
qc_path="$3"

output_dir=$(dirname "${output_fmri_file}")

if [ ! -d "${output_dir}" ]; then
  mkdir -p "${output_dir}"
fi

module load apptainer/1.1.8
apptainer run -B /scratch freesurfer.sif mri_synthseg --i "${BOLD_ref}" --o "${ROI_file}" --robust --parc --qc "${qc_path}"
