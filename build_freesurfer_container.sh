#!/bin/bash


filename="freesurfer.sif"
directory="${HOME}"

# Find the file and save the result in a variable
file_path=$(find "$directory" -type f -name "$filename" -print -quit)

if [ -n "$file_path" ]; then
    echo "File $filename exists at: $file_path"
else
    echo "File $filename does not exist in $directory or its subdirectories."
    echo " building $filename "
    module load apptainer/1.1.8
    apptainer build $filename docker://freesurfer/freesurfer:7.2.0
fi