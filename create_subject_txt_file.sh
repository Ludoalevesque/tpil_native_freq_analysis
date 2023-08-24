#!/bin/bash

# change subjects_dir to a path where the subject's folders are but nothing else. 
# subjects_dir="/home/ludoal/scratch/freq_analysis_data/V1"

subjects_dir="$1"
subject_ID_file="subjectIDs.txt"

# List all folder names and write to the output file
cd "$subjects_dir"
find . -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | grep -Eo '[0-9]+$' > "$subject_ID_file"

echo "Folder names listed in ${subjects_dir}/${subject_ID_file}." 