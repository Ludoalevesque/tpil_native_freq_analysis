#!/bin/bash
#SBATCH --time=02:00:00
#SBATCH --job-name=freq_analysis
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=10G
#SBATCH --mail-user=ludo.a.levesque@gmail.com
#SBATCH --mail-type=FAIL,END
#SBATCH --array=1-53
#SBATCH --output="outputs/slurm-%A_%a.out"


export root_dir="/home/ludoal/scratch/freq_analysis_data"
export sessions="V1"
export subjectIDs_file="/home/ludoal/scratch/freq_analysis_data/V1/subjectIDs.txt"  
export sub=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "${subjectIDs_file}")
export output_dir="/home/ludoal/scratch/freq_analysis_data/${sessions}/sub-${sub}/frequency_analysis_outputs"
export ROI_file="${output_dir}/Segmentation/SynthSeg/sub-${sub}_bold_seg.nii.gz"
export qc_path="${output_dir}/Segmentation/SynthSeg/sub-${sub}_qc.csv"
export FS_LICENSE="${output_dir}/license.txt"

if [ ! -d "${output_dir}" ]; then
  mkdir -p "${output_dir}"
fi


# Apply head motion correction to fMRI 4D image
raw_bold="${root_dir}/V1/sub-${sub}/func/sub-${sub}_task-rest_bold.nii.gz"
bold_file="${output_dir}/BOLD/sub-${sub}_task-rest_bold_HMC.nii.gz"

bash apply_HMC.sh "${raw_bold}" "${bold_file}"

if [ ! -f "${bold_file}" ]; then
  echo " HMC did not work "
  exit 1
fi
echo "Head motion correction applied and saved."

# Compute bold ref
export BOLD_ref="${output_dir}/BOLD/sub-${sub}_task-rest_boldref.nii.gz"

bash compute_bold_ref.sh "${bold_file}" "${BOLD_ref}"

if [ ! -f "${bold_file}" ]; then
  echo " The bold ref was not computed "
  exit 1
fi
echo " Bold ref file created "


## Segment Bold ref file

if [ ! -d "${output_dir}/Segmentation/SynthSeg" ]; then
  mkdir -p "${output_dir}/Segmentation/SynthSeg"
fi

module load apptainer/1.1.8
apptainer run -B /scratch freesurfer.sif mri_synthseg --i "${BOLD_ref}" --o "${ROI_file}" --robust --parc --qc "${qc_path}"


## Compute spectrums for specified regions
label_file="pain_ROI_list.txt"

# Activate the virtual environment containing the required packages
env_path="/home/ludoal/scratch/ENV/frequency_analysis"
source "${env_path}/bin/activate"

# Run the python script
cmd="python compute_specrum_by_region_SynthSeg.py \
--seg_file '${ROI_file}' \
--label_file '${label_file}' \
--bold_file '${bold_file}' \
--output_prefix '${output_dir}/sub-${sub}' "

echo "$cmd"
eval "$cmd"