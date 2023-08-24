#!/bin/bash
#SBATCH --time=02:00:00
#SBATCH --job-name=freq_analysis
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=10G
#SBATCH --mail-user=ludo.a.levesque@gmail.com
#SBATCH --mail-type=FAIL,END
#SBATCH --array=1
#SBATCH --output="outputs/slurm-%A_%a.out"

# Warning this script needs to be run on compute canada from a directory on the scratch.

# this part allows all subjects to run in parallel
export subjectIDs_file="/home/ludoal/scratch/freq_analysis_data/V1/subjectIDs.txt"  
export sub=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "${subjectIDs_file}")

export root_dir="/home/ludoal/scratch/freq_analysis_data"
export sessions="V1"
export output_dir="${root_dir}/${sessions}/sub-${sub}/frequency_analysis_outputs"
export FS_LICENSE="licenses/license.txt"
env_path="/home/ludoal/scratch/ENV/frequency_analysis" 

if [ ! -d "${output_dir}" ]; then
  mkdir -p "${output_dir}"
fi


## Apply head motion correction to fMRI 4D image
raw_bold="${root_dir}/V1/sub-${sub}/func/sub-${sub}_task-rest_bold.nii.gz"
bold_file="${output_dir}/BOLD/sub-${sub}_task-rest_bold_HMC.nii.gz"

bash apply_HMC.sh "${raw_bold}" "${bold_file}"

if [ ! -f "${bold_file}" ]; then
  echo " HMC did not work "
  exit 1
fi
echo "Head motion correction applied and saved."

## Compute bold ref
export BOLD_ref="${output_dir}/BOLD/sub-${sub}_task-rest_boldref.nii.gz"

bash compute_bold_ref.sh "${bold_file}" "${BOLD_ref}"

if [ ! -f "${bold_file}" ]; then
  echo " The bold ref was not computed "
  exit 1
fi
echo " Bold ref file created "


## Segment Bold ref file
export ROI_file="${output_dir}/Segmentation/sub-${sub}_bold_seg.nii.gz"
export qc_path="${output_dir}/Segmentation/sub-${sub}_qc.csv"

bash SyntSeg_on_bold.sh "${BOLD_ref}" "${ROI_file}" "${qc_path}"

if [ ! -f "${ROI_file}" ]; then
  echo " The segmentation did not work "
  exit 1
fi
echo " Segmentation finished "


## Compute spectrums for specified regions
label_file="pain_ROI_list.txt"

  # Activate the virtual environment containing the required packages
source "${env_path}/bin/activate"

  # Run the python script
cmd="python compute_specrum_by_region.py.py \
--seg_file '${ROI_file}' \
--label_file '${label_file}' \
--bold_file '${bold_file}' \
--output_prefix '${output_dir}/sub-${sub}' "

echo "$cmd"
eval "$cmd"


# ## Compute the groups average

#   # Run the python script

# cmd="python compute_group_average_spectrums.py --groups CLBP HC --data-dir /path/to/data --output-path /output/path --figure-path /figure/path --sub-txt-file /path/to/sub_txt_file.txt --label-file /path/to/label_file.txt

# cmd="python compute_specrum_by_region_SynthSeg.py \
# --seg_file '${ROI_file}' \
# --label_file '${label_file}' \
# --bold_file '${bold_file}' \
# --output_prefix '${output_dir}/sub-${sub}' "

# echo "$cmd"
# eval "$cmd"