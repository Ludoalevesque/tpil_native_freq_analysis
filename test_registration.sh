#!/bin/bash
#SBATCH --time=00:40:00
#SBATCH --job-name=regTest
#SBATCH --cpus-per-task=2
#SBATCH --mem-per-cpu=10G
#SBATCH --mail-user=ludo.a.levesque@gmail.com
#SBATCH --mail-type=FAIL,END
#SBATCH --ntasks=1
#SBATCH --output="outputs/slurm-%A_%a.out"


## TEST script for registration 


root_dir="/home/ludoal/scratch/freq_analysis_data"
sessions="V1"
sub="08"

# Assigning main variables
output_dir="${root_dir}/${session}/sub-${sub}/frequency_analysis_outputs"
func_dir="${root_dir}/${session}/sub-${sub}/func"
segmentation_dir="${output_dir}/Segmentation/first_all"
segmentation_file="${segmentation_dir}/sub-${sub}_all_fast_firstseg.nii.gz"
bold_ref_file="${bold_out_dir}/sub-${sub}_task-rest_boldref.nii.gz"
seg_in_bold_space="${segmentation_dir}/sub-${sub}_ROIs_space-BOLD.nii.gz"
T1_brain="${output_dir}/BrainExtraction/sub-${sub}_T1_BrainExtractionBrain.nii.gz"
registration_dir="${output_dir}/Registration"

# 5- Register T1 to Bold

if [ ! -d "${registration_dir}" ]; then
    mkdir -p "${registration_dir}"
fi

module load StdEnv/2020  gcc/9.3.0 ants/2.4.4

antsRegistrationSyNQuick.sh -d 3 -f "${T1_brain}" -m "${bold_ref_file}" -o "${registration_dir}/sub-${sub}_boldToT1_"

echo "Registration of T1 to Bold complete."


# 6- Register the segmentation to BOLD space

antsApplyTransforms -d 3 \
-i "${segmentation_file}" \
-r "${bold_ref_file}" \
-o "${seg_in_bold_space}" \
-t ["${registration_dir}/sub-${sub}_boldToT1_0GenericAffine.mat", 1] \
-t "${registration_dir}/sub-${sub}_boldToT1_1InverseWarp.nii.gz" \
-n GenericLabel

echo " ants  fixed : T1, moving: bold, apply inverse"
