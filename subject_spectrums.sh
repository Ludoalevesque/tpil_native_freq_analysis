#!/bin/bash
#SBATCH --time=02:00:00
#SBATCH --job-name=Freq_analysis
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=10G
#SBATCH --mail-user=ludo.a.levesque@gmail.com
#SBATCH --mail-type=FAIL,END
#SBATCH --output="outputs/slurm-%A_%a.out"

# Warning this script needs to be run on compute canada from a directory on the scratch.

# example of usage : sbatch subject_spectrums.sh "/home/ludoal/scratch/freq_analysis_data" "V3"


export root_dir="$1"
export sessions="$2"
export subjectIDs_file="${root_dir}/${sessions}/subjectIDs.txt" 

# this part allows all subjects to run in parallel
 
if [ ! -f "${subjectIDs_file}" ]; then
  bash create_subject_txt_file.sh "${subjectIDs_file}"
fi

num_subjects=$(wc -l < "${subjectIDs_file}")
#SBATCH --array=1-${num_subjects}
export sub=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "${subjectIDs_file}")
echo "Processing sub-${sub} "


export output_dir="${root_dir}/${sessions}/sub-${sub}/frequency_analysis_outputs"
export FS_LICENSE="licenses/license.txt"
env_path="${HOME}/scratch/ENV/frequency_analysis" 

if [ ! -d "${output_dir}" ]; then
  mkdir -p "${output_dir}"
fi


## Apply head motion correction to fMRI 4D image
raw_bold="${root_dir}/${sessions}/sub-${sub}/func/sub-${sub}_task-rest_bold.nii.gz"
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

bash SynthSeg_on_bold.sh "${BOLD_ref}" "${ROI_file}" "${qc_path}"

if [ ! -f "${ROI_file}" ]; then
  echo " The segmentation did not work "
  exit 1
fi
echo " Segmentation finished "


## Compute spectrums for specified regions
label_file="pain_ROI_list.txt"

  # Activate the virtual environment containing the required packages
if [ ! -d "${env_path}" ]; then
    echo "!!! Warning : The virtual environment was not found. A new one will be created and the packages will be installed. \
    This can take time, so make sure this messages doesn't pop up every time."
    bash create_env.sh "${env_path}" --leave-activated
fi
source "${env_path}/bin/activate"

  # Run the python script
cmd="python compute_specrum_by_region.py \
--seg_file '${ROI_file}' \
--label_file '${label_file}' \
--bold_file '${bold_file}' \
--output_prefix '${output_dir}/sub-${sub}' "

echo "$cmd"
eval "$cmd"

