# -*- coding: utf-8 -*-
"""
Created on Thu Aug 24 12:53:59 2023

This script processes power spectrum data for different groups and regions,
generates averaged spectra plots, and saves output data.

Usage example:
python compute_group_average_spectrums.py --data_dir /path/to/data --output_path /output/path --figure_path /figure/path --sub_txt_file /path/to/sub_txt_file.txt --label_file /path/to/label_file.txt
"""

import os
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from sys import exit
import argparse

positive_frequencies = []

def mean_stderr_CI(region_spectrums):
    """
    Compute the mean, standard error, and confidence interval of region spectrums.

    Parameters:
        region_spectrums (numpy.ndarray): Array of region spectrums for multiple subjects.

    Returns:
        numpy.ndarray: Mean of region spectrums.
        numpy.ndarray: Standard error of region spectrums.
        numpy.ndarray: Confidence interval of region spectrums.
        int: Number of samples.
    """
    n = region_spectrums.shape[1]
    mean_region_spectrum = np.mean(region_spectrums, axis=1)
    std_error = np.std(region_spectrums, axis=1) / np.sqrt(region_spectrums.shape[1])
    confidence_interval = 1.96 * std_error #Corresponding to 95% confidence interval
    return mean_region_spectrum, std_error, confidence_interval, n

def plot_region_averaged_spectrum(region_spectrums, positive_frequencies, region, group_name, save_path):
    """
    Plot the averaged power spectra for a region within a group and save the plot.

    This function creates a plot of the averaged power spectra for a specific region within a group.
    It includes individual spectra as well as the mean spectrum with confidence intervals.
    The plot is saved as a JPEG image if a valid save_path is provided.

    Parameters:
        region_spectrums (numpy.ndarray): Array of region spectrums for multiple subjects.
        positive_frequencies (numpy.ndarray): Array of positive frequencies used for spectrums.
        region (str): Name of the brain region.
        group_name (str): Name of the group.
        save_path (str): Path to save the generated plot as a JPEG image.

    Returns:
        None
    """
    
    plt.figure(figsize=(10, 6))  # Create a single figure for all plots
    for i in range(region_spectrums.shape[1]):
        plt.semilogy(positive_frequencies, region_spectrums[:,i], linewidth=0.5, alpha=0.5)
        
    mean_region_spectrum, std_error, confidence_interval, n = mean_stderr_CI(region_spectrums)

    plt.semilogy(positive_frequencies, mean_region_spectrum, color='red', linewidth=2, label='Mean Spectrum')
    plt.fill_between(positive_frequencies, mean_region_spectrum - confidence_interval,
                     mean_region_spectrum + confidence_interval, color='red', alpha=0.3, label='95% CI')
    plt.text(0.05, 0.9, f'N = {n}', transform=plt.gca().transAxes)
    plt.xlabel("Frequency (Hz)")
    plt.ylabel("Power")
    plt.title(f"Power Spectra of {region} {group_name}")
    plt.grid(True)
    plt.legend()
    
    # Save the plot as a JPEG image if save_path is provided
    plt.savefig(save_path, format='jpeg')
    
    plt.close()
           
def save_averaged_spectrum(region_spectrums, positive_frequencies, csv_filename):
    """
    Save the averaged power spectrum data to a CSV file.

    This function computes the mean power spectrum, standard error, and confidence interval from
    the given region spectrums and saves the computed statistics along with the positive frequencies
    to a CSV file.

    Parameters:
        region_spectrums (numpy.ndarray): Array of region spectrums for multiple subjects.
        positive_frequencies (numpy.ndarray): Array of positive frequencies used for spectrums.
        csv_filename (str): Path to the CSV file where the data will be saved.

    Returns:
        None
    """
    mean_region_spectrum, std_error, confidence_interval, n = mean_stderr_CI(region_spectrums) 

    # Create a dataframe for the file to be saved
    data = {
        'Frequencies (Hz)': positive_frequencies,
        'Power': mean_region_spectrum,
        'Standard error': std_error,
        '95% confidence interval': confidence_interval,
        'Number of samples (n)': n
    }
        
    df = pd.DataFrame(data) 
    
    # Create the output directory if it doesn't exist and save 
    out_path = os.path.dirname(csv_filename)
    if not os.path.exists(out_path):
        os.makedirs(out_path)
    
    df.to_csv(csv_filename, index=False)

def read_labels_file(file_path):
    """
    Read and process a labels file.

    This function reads a labels file, extracts label values and corresponding labels,
    and returns them as lists.

    Parameters:
        file_path (str): Path to the labels file.

    Returns:
        list: List of labels.
        list: List of corresponding label values.
    """
    labels = []
    labels_values = []

    # Check if file exists
    if not os.path.exists(file_path):
        print("label file path provided doesn't exist")
        exit(1)
    
    with open(file_path, 'r') as file:
        for line in file:
            parts = line.split()
            if len(parts) == 2:
                value, label = parts
                labels_values.append(int(value))
                labels.append(label)
    
    return labels, labels_values

def analyze_group_spectrums(file_list, region, group_name, output_path, figure_path):
    """
    Analyze power spectra for a specific region within a group.

    This function reads power spectrum data files from the provided file list,
    processes them, generates averaged spectra plots, and saves output data.

    Parameters:
        file_list (list): List of paths to power spectrum data files.
        region (str): Name of the brain region.
        group_name (str): Name of the group.
        output_path (str): Directory to save output data.
        figure_path (str): Directory to save figures.

    Returns:
        tuple: Tuple containing mean, standard error, confidence interval, and number of samples.
    """
    region_spectrums = []
    valid_subject_count = 0
    
    for file in file_list:
        
        # Get rid of the frequencies too close to the edges
        full_df = pd.read_csv(file)
        all_freqs =  full_df['Frequencies (Hz)']
        selected_frequencies = all_freqs[(all_freqs >= 0.01)&(all_freqs <= 0.4)]
        df = full_df.loc[full_df['Frequencies (Hz)'].isin(selected_frequencies)]
        
        # Get the positive frequencies used for spectrums
        global positive_frequencies
        if type(positive_frequencies) == list:
            positive_frequencies= df['Frequencies (Hz)']
            
        region_spectrum = df[region].to_numpy()
        del df
    
        if np.isnan(region_spectrum).any():  # Check for NaN values in the spectrum
            print(f"NaN values found in {file} for region {region}")
            continue  # Skip this subject if NaN values are present
    
        region_spectrums.append(region_spectrum)
        valid_subject_count += 1  # Increment the valid subject count
    
    if valid_subject_count > 0:
        region_spectrums = np.column_stack(region_spectrums)
        
        plot_save_path = f'{figure_path}/{region}_{group_name}_group_mean_spectra'
        if not os.path.exists(os.path.dirname(plot_save_path)):
            os.makedirs(os.path.dirname(plot_save_path))
                
        plot_region_averaged_spectrum(region_spectrums, positive_frequencies, region, group_name, plot_save_path)
        
        csv_filename = f"{output_path}/{group_name}/{group_name}_Averaged_spectrum_{region}.csv"
        save_averaged_spectrum(region_spectrums, positive_frequencies, csv_filename)
    
    else:
        print('There were no valid subjects for', group_name, 'and', region)
        print("Check for issues with the data or remove the region from analysis if necessary")
        exit(1)
        
    return mean_stderr_CI(region_spectrums)

def main(group_names, data_dir, output_path, figure_path, sub_txt_file, label_file):
    """
    Main function to analyze power spectrum data for different groups and regions.

    Parameters:
        group_names (list): List of group names.
        data_dir (str): Directory containing power spectrum data.
        output_path (str): Directory to save output data.
        figure_path (str): Directory to save figures.
        sub_txt_file (str): Path to the subject text file.
        label_file (str): Path to the label file.
    """

    labels, _ = read_labels_file(label_file)
    
    group_files = {group: [] for group in group_names}
    
    with open(sub_txt_file, 'r') as file:
        for line in file:
            words = line.split()
            sub = words[0]
            group = words[1]
            spectra_file = f'{sub}_power_spectras.csv'
            complete_path = f'{data_dir}/{sub}/frequency_analysis_outputs/{spectra_file}'
            
            if os.path.exists(complete_path) and group in group_names:
                group_files[group].append(complete_path)
    
    for region in labels:
        for group_name in group_names:
            mean_spectrum, stde, confidence_interval, n = analyze_group_spectrums(
                file_list=group_files[group_name],
                region=region,
                group_name=group_name,
                output_path=output_path,
                figure_path=figure_path
            )
            
            
if __name__ == "__main__":
    
    parser = argparse.ArgumentParser(description="Process power spectrum data for different groups and regions.")
    parser.add_argument("--data_dir", required=True, help="Directory containing power spectrum data")
    parser.add_argument("--output_path", required=True, help="Directory to save output data")
    parser.add_argument("--figure_path", required=True, help="Directory to save figures")
    parser.add_argument("--sub_txt_file", required=True, help="Path to the subject text file")
    parser.add_argument("--label_file", required=True, help="Path to the label text file containing the brain regions to process")
    
    args = parser.parse_args()
    
        # Read unique group names from the subject text file
    with open(args.sub_txt_file, 'r') as file:
        group_names = list(set(line.split()[1] for line in file))
    
    main(group_names, args.data_dir, args.output_path, args.figure_path, args.sub_txt_file, args.label_file)
        
    # label_file = r"D:\NeuroImaging\frequency_analysis\Label_files\pain_ROI_list.txt"
    # data_dir = r'D:\NeuroImaging\compute_canada_test\V1\copied_power_spectra_SynthSeg'
    # output_path = r'D:\NeuroImaging\frequency_analysis\V1\Stats\with_SynthSeg'
    # figure_path = r"D:\NeuroImaging\frequency_analysis\V1\Stats\figures"
    # sub_txt_file = r"D:\NeuroImaging\subject_IDs_and_group.txt"
    # group_names = ['CLBP', 'HC']  # Add more group names if needed
    
    # main(group_names, data_dir, output_path, figure_path, sub_txt_file,label_file)
