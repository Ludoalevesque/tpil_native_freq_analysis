#!/bin/bash

# test compute_group_average

env_path="/home/ludoal/scratch/ENV/frequency_analysis" 
label_file="pain_ROI_list.txt"
data_dir="/home/ludoal/scratch/freq_analysis_data/V1"
out_path="${data_dir}/Stats"
figure_path="${out_path}/figures"
sub_gr_file="Group_subjects.txt"


  # Activate the virtual environment containing the required packages
if [ ! -d "${env_path}" ]; then
    echo "The virtual environment was not found. A new one will be created and the packages will be installed. \
    This can take time, so make sure this messages doesn't pop up every time."
    bash create_env.sh "${env_path}" --leave-activated
fi
source "${env_path}/bin/activate"

cmd="python compute_group_average_spectrums.py \
    --data_dir "${data_dir}" \
    --output_path "${out_path}" \
    --figure_path "${figure_path}" \
    --sub_txt_file "${sub_gr_file}" \
    --label_file "${label_file}" "

echo "${cmd}"
eval "${cmd}"
