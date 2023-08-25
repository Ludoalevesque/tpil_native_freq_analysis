#!/bin/bash

data_dir="/home/ludoal/scratch/freq_analysis_data"
session="V1"

while IFS= read -r sub
do
    sub_dir="${data_dir}/${session}/sub-${sub}"
    rm -r "${sub_dir}/frequency_analysis_outputs"

done < "${data_dir}/${session}/subjectIDs.txt"

