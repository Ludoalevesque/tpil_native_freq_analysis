#!/bin/bash


# Create the destination directory if it doesn't exist
mkdir -p copied_power_spectra_SynthSeg

# Loop through each subject ID in the file
while IFS= read -r ID; do
    source_file="/home/ludoal/scratch/freq_analysis_data/V1/sub-${ID}/frequency_analysis_outputs/sub-${ID}_power_spectras.csv"
    destination_file="copied_power_spectra_SynthSeg/sub-${ID}_power_spectras.csv"

    # Copy the power spectra file from source to destination
    cp "${source_file}" "${destination_file}"
    
    echo "Copied power spectra for subject ${ID}"
done < "/home/ludoal/scratch/freq_analysis_data/V1/subjectIDs.txt"



# # Create the destination directory if it doesn't exist
# mkdir -p copied_seg

# # Loop through each subject ID in the file
# while IFS= read -r ID; do
#     source_file="/home/ludoal/scratch/freq_analysis_data/V1/sub-${ID}/frequency_analysis_outputs/Segmentation/SynthSeg/sub-${ID}_bold_seg.nii.gz"
#     destination_file="copied_seg/sub-${ID}_bold_seg.nii.gz"

#     # Copy the power spectra file from source to destination
#     cp "${source_file}" "${destination_file}"
    
#     echo "Copied segmentation for subject ${ID}"
# done < "/home/ludoal/scratch/freq_analysis_data/V1/subjectIDs.txt"
