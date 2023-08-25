# -*- coding: utf-8 -*-
"""
Created on Fri Aug 4 12:11:36 2023

This script computes the power spectrum of time series data extracted from specific brain regions
segmented using FreeSurfer's SynthSeg. It utilizes the Welch method to calculate the power spectrum and 
can optionally plot the results.

Requirements:
- Python 3.x
- Required Python packages: numpy, nibabel, nilearn, matplotlib, scipy, pandas

Usage:
python compute_specrumt_by_region_first_all.py [options]

Options:
    --seg_file <path>: Path to the segmentation file (e.g., sub-02_bold_seg.nii.gz).
    --bold_file <path>: Path to the bold file (e.g., sub-02_task-rest_bold_HMC.nii.gz).
    --label_file <path>: Path to the label file (e.g., SynthSeg_label_file.txt).
    --output_prefix <path>: Prefix for the output file names (default: "./").
    --plot: Include this flag to enable plotting of power spectra (default: disabled).
    --help: Display this help message and exit.

Example:
python compute_specrum_by_region_SynthSeg.py --seg_file path/to/seg_file.nii.gz --bold_file path/to/bold_file.nii.gz --plot
"""
import os
import sys
import argparse
import numpy as np
import nibabel as nib
from nilearn.maskers import NiftiMasker
import pandas as pd
import matplotlib.pyplot as plt
from scipy.signal import welch
import pandas as pd
from scipy.ndimage import binary_erosion
from nilearn.image import resample_img

def read_labels_file(file_path):
    labels = []
    labels_values = []

    # Check if file exists
    if not os.path.exists(file_path):
        print("label file path provided doesn't exist")
        sys.exit(1)
    
    with open(file_path, 'r') as file:
        for line in file:
            parts = line.split()
            if len(parts) == 2:
                value, label = parts
                labels_values.append(int(value))
                labels.append(label)
    
    return labels, labels_values


def compute_power_spectrum(signal_array, fs, nperseg=None,window='hann', noverlap=None, **kwargs):
    """
    Compute the power spectrum of a signal using the Welch method.

    Parameters:
        signal_array (numpy.ndarray): The input signal array.
        fs (float, optional): The sampling frequency of the signal (inverse of the time interval). Default is 1.0.
        nperseg (int, optional): The length of each segment. Default is None (auto-detected).
        noverlap (int, optional): The number of points to overlap between segments. Default is None (auto-detected).
        nfft (int, optional): The number of points to compute the Fast Fourier Transform (FFT). Default is None (auto-detected).
        **kwargs: Additional arguments to be passed to `scipy.signal.welch`.

    Returns:
        frequencies (numpy.ndarray): The frequencies corresponding to the power spectrum.
        power_spectrum (numpy.ndarray): The power spectrum of the input signal array.
    """

    # Compute the power spectrum using the Welch method
    frequencies, power_spectrum = welch(signal_array, fs=fs, nperseg=nperseg, noverlap=noverlap, **kwargs)

    return frequencies, power_spectrum

def main(args):
    
    seg_file = args.seg_file
    bold_file = args.bold_file
    output_prefix = args.output_prefix
    plot = args.plot
    
    print('Starting processing of :', os.path.basename(seg_file))

    labels, labels_values = read_labels_file(args.label_file)
    
    TR = nib.load(bold_file).header['pixdim'][4]
    sampling_rate = 1 / TR
    
    power_spectra_data = {"Frequencies (Hz)": []}
    bold_affine = nib.load(bold_file).affine
    
    # print ('In debug mode')
    # for region_index in [12]:
    for region_index in range(len(labels)):

        
        # Dont process the backgound
        if labels[region_index]=='Background':
            continue

        label_val = labels_values[region_index]

        # Load parcellation image (output of run_first)
        parcellation_img = nib.load(seg_file)
        
        # Create a binary mask of the region
        mask_data = (parcellation_img.get_fdata() == label_val).astype('uint8')
        num_vox = np.count_nonzero(mask_data)


        if num_vox == 0 :
            print(labels[region_index], 'has no voxel')
            power_spectra_data[labels[region_index]] = []
            continue
        else:
            print(labels[region_index],' originally has : ', num_vox , ' 1x1x1 voxels')
        
        mask_img = nib.Nifti1Image(mask_data, affine=parcellation_img.affine, dtype='float')

        # Erode the region mask
        erosion_iterations = 1  # Adjust this value as needed
        eroded_mask_data = (binary_erosion(mask_data, iterations=erosion_iterations)).astype('float')
        eroded_mask_img = nib.Nifti1Image(eroded_mask_data, mask_img.affine,  dtype='float')  

        # Downsample the eroded mask 
        resampled_mask_img = resample_img(eroded_mask_img, target_affine=bold_affine, interpolation='nearest')
        
        # Check if the erosion left some voxels
        num_vox = np.count_nonzero(resampled_mask_img.get_fdata())
        if num_vox == 0 :
            print(labels[region_index], 'has no voxel left after erosion')
            power_spectra_data[labels[region_index]] = []
            continue
        else:
            print(labels[region_index], ' has ', num_vox, ' remaining 3x3x3 voxels after erosion')


        # Extract the signals for voxels within the region
        masker = NiftiMasker(mask_img=resampled_mask_img, target_affine=bold_affine)
        time_series = masker.fit_transform(bold_file)

        # compute the spectrum for each voxels then average them together
        positive_frequencies, power_mtx = compute_power_spectrum(time_series.T, sampling_rate)
        mean_spectrum = np.mean(power_mtx, axis=0)
        
        # Store the mean_spectrum in the dictionary
        power_spectra_data[labels[region_index]] = mean_spectrum
        
            
        if plot:
            import matplotlib.pyplot as plt
            # Plot the power spectrum with log scale y-axis
            plt.figure(figsize=(10, 6))
            plt.semilogy(positive_frequencies, mean_spectrum, linewidth=2)
            plt.xlabel("Frequency (Hz)")
            plt.ylabel("Power")
            plt.title(f"Power Spectrum of {labels[region_index]}")
            plt.grid(True)
            plt.show()
    
            
            
    ## Save the spectrums averaged across subjects
    
    # Check if spectrum have been computed for at least one region
    if  'time_series' not in locals():
        print('There was no voxels in any of the specified brain regions! Check the segmentation or consider removing erosions steps')
        sys.exit(1)

    # create frequencies colum and fill empty regions with NaN
    power_spectra_data['Frequencies (Hz)'] = positive_frequencies
    
    for key, value in power_spectra_data.items():
        if type(value) == list:
            power_spectra_data[key] = np.full(len(positive_frequencies),np.nan)
        
    
    # Create a DataFrame from the power_spectra_data dictionary
    power_spectra_df = pd.DataFrame(power_spectra_data)
    
    # Save the DataFrame to a CSV file
    csv_filename = f"{output_prefix}_power_spectras.csv"
    power_spectra_df.to_csv(csv_filename, index=False)
    print(f"Power spectra data saved to '{csv_filename}'")

    

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Compute power spectra from brain regions.")
    
    parser.add_argument('--seg_file', type=str, required=True, help="Path to the segmentation file.")
    parser.add_argument('--bold_file', type=str, required=True, help="Path to the bold file.")
    parser.add_argument('--label_file', type=str, required=True, help="Path to the labels text file. The file can contain a subset of the regions present in the segmentation file.")
    parser.add_argument('--output_prefix', type=str, default="./", help="Output file prefix.")
    parser.add_argument('--plot', action='store_true', help="Enable plotting of power spectra.")
    
    args = parser.parse_args()
    main(args)