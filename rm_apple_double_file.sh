#!/bin/bash

directory_path="/home/ludoal/scratch/freq_analysis_data/V1"

# Function to remove files starting with "._"
remove_apple_double_files() {
    find "$1" -type f -name "._*" -exec rm -f {} +
}

remove_apple_double_files "$directory_path"

echo "Apple double files removed."


