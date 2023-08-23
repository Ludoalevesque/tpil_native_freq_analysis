#!/bin/bash
#SBATCH --time=01:00:00
#SBATCH --job-name=SynthSeg
#SBATCH --cpus-per-task=2
#SBATCH --mem-per-cpu=10G
#SBATCH --mail-user=ludo.a.levesque@gmail.com
#SBATCH --mail-type=FAIL,END
#SBATCH --array=1-47
#SBATCH --output="outputs/slurm-%A_%a.out"

export root_dir="/home/ludoal/scratch/freq_analysis_data"
export sessions="V1"
export subjectIDs_file="${root_dir}/${sessions}/subjectIDs.txt"
export sub=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "${subjectIDs_file}")
export output_dir="/home/ludoal/scratch/freq_analysis_data/${sessions}/sub-${sub}/frequency_analysis_outputs"
export BOLD_ref="${output_dir}/BOLD/sub-${sub}_task-rest_boldref.nii.gz"
export ROI_file="${output_dir}/Segmentation/SynthSeg/sub-${sub}_bold_seg.nii.gz"
export qc_path="${output_dir}/Segmentation/SynthSeg/sub-${sub}_qc.csv"
export FS_LICENSE="${output_dir}/license.txt"

#Starting docker :
# sudo service docker start
module load apptainer/1.1.8

## segment Bold ref file

# fs_cmd="mri_synthseg --i "${BOLD_ref}" --o "${ROI_file}" "


apptainer run -B /scratch freesurfer.sif mri_synthseg --i "${BOLD_ref}" --o "${ROI_file}" --robust --parc --qc "${qc_path}"


# docker run -v "/mnt/d/NeuroImaging/compute_canada_test/V1/sub-08/frequency_analysis_outputs":"/mnt/d/NeuroImaging/compute_canada_test/V1/sub-08/frequency_analysis_outputs" -e FS_LICENSE="${root_dir}/license.txt" -it freesurfer/freesurfer:7.4.1
# mri_synthseg --i "/mnt/d/NeuroImaging/compute_canada_test/V1/sub-08/frequency_analysis_outputs/BOLD/sub-08_task-rest_boldref.nii.gz" --o "/mnt/d/NeuroImaging/compute_canada_test/V1/sub-08/frequency_analysis_outputs//Segmentation/SynthSeg/sub-08_bold_seg.nii.gz"