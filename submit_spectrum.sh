#!/bin/bash
#SBATCH --time=01:00:00
#SBATCH --job-name=spectrums
#SBATCH --cpus-per-task=2
#SBATCH --mem-per-cpu=4G
#SBATCH --mail-user=ludo.a.levesque@gmail.com
#SBATCH --mail-type=FAIL,END
#SBATCH --ntasks=47
#SBATCH --array=1-47
#SBATCH --output="outputs/slurm-%A_%a.out"

# Define main variables
root_dir="/home/ludoal/scratch/freq_analysis_data"
sessions="V1"
subjectIDs_file="${root_dir}/${sessions}/subjectIDs.txt"
sub=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "${subjectIDs_file}")
output_dir="${root_dir}/${sessions}/sub-${sub}/frequency_analysis_outputs"
segmentation_dir="${output_dir}/Segmentation/SynthSeg"
segmentation_file="${segmentation_dir}/sub-${sub}_bold_seg.nii.gz"
label_file="pain_ROI_list.txt"
bold_file="${output_dir}/BOLD/sub-${sub}_task-rest_bold_HMC.nii.gz"


# Activate the virtual environment containing the required packages
env_path="/home/ludoal/scratch/ENV/frequency_analysis"
source "${env_path}/bin/activate"

# Run the python script

cmd="python compute_specrum_by_region_SynthSeg.py \
--seg_file "${segmentation_file}" \
--label_file "${label_file}" \
--bold_file "${bold_file}" \
--output_prefix "${output_dir}/sub-${sub}" "

echo "$cmd"
eval "$cmd"