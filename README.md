# tpil_native_freq_analysis
This repository is a collection of scripts and files to do frequency analysis of fmri in native space.

How to use this  repository :

    What you need:
1- The only MRI data you need to begin with is an fmri run for every subject.
2- You need to have a compute Canada account to be able to run most of the scripts on their clusters.
3- A text file with the complete subject labels with their group labels. See Group_subjects.txt for an example.
4 - A text file containing a list of the brain regions you want to process with their label index. The index are the value of the region in the segmented fMRI image. See pain_ROI_list.txt for an example. 



    Getting started:
1- Start by cloning this repository on your scratch on a compute canada server. 
2- In an other folder, place your data with the following structure:
{Root_dir}/{sessions}/{subject-label}/func/{filename}
For now the filename need to be “sub-<numerical subject label>__task-rest_bold.nii.gz” other wise the code has to be modified
3- Build the freesurfer.sif image in the repository directory by running the build_freesurfer_container.sh script.
bash build_freesurfer_container.sh
4- I recommend using the create_venv.sh script to build the virtual environment needed for the python scripts before running the analysis. You should create it in your scratch in dedicated to virtual environment
bash create_venv.sh  “/scratch/ENV/frequency_analysis”
5- I also recommend creating the subjectIDs.txt file for every visit before running the main analysis. You can do that with the create_subject_txt_file.sh script.
6- If you want other brain regions of interests than what is in pain_ROI_list.txt, you have to  generate your own label file and put it in the repository directory.
Now everything should be ready to go.

Frequency analysis :
The first script you want to run on your data is subject_spectrums.sh. It wil compute the power spectrum of every brain region in your label file for all subjects and save them in one csv file per subject. Inputs and outputs are specified in the following table. 
Then, you can use compute_group_average_spectrums.py to get the group-level average spectrum for every region, but before you do, make sure you examine the data for any outliers. If there is any subject you don’t want to include in the group average, add their label to an sub_ignore_list.txt file and pass this list to the script. If you want to ignore any region do the same with a region_ignore_list.txt.
For the next steps, like running statistics on the data or looking at the relationship between head movement components and the power spectrums, there are some scripts that I started to develop, but might need more tweaking that I made available in the beta folder. Those also don’t need to be executed on compute Canada. 

Outputs
The main will generate subject specific outputs in a directory called frequency_analysis_outputs directly in the subject’s folder. This is where the power spectrum file is saved. Other files created during processing will be stored in
<Root directory>/<session>/<subject label>/frequency_analysis_outputs
Other subject specific files created during processing will be stored in subfolders within this directory
Session specific files will be stored in <Root directory>/<session>/Stats
Output file	description	location
XX_HMC.nii.gz	The head motion corrected fMRI run.	{Root_dir}/{sessions}/{subject-label}/frequency_analysis_outputs/BOLD/
XX_HMC.nii.gz.par	Motion parameters file. 	{Root_dir}/{sessions}/{subject-label}/frequency_analysis_outputs/BOLD/
XX_boldref.nii.gz	One brain extracted volume of the HMC file. Used for segmentation	{Root_dir}/{sessions}/{subject-label}/frequency_analysis_outputs/BOLD/
XX _bold_seg.nii.gz	Segmentation file. It’s a 3D in which every label is associated to a brain region. See SynthSeg_label_file.txt for all the labels present in a SynthSeg output.	{Root_dir}/{sessions}/{subject-label}/frequency_analysis_outputs/Segmentation/
XX_ power_spectras.csv	The first column contains the frequencies in Hz of the spectrums. The other columns are named after the brain regions and contain their respective power spectrum.	{Root_dir}/{sessions}/{subject-label}/frequency_analysis_outputs/
{group}_Averaged_spectrum_{region}.csv	This is only present if you run the Group average. The first column contains the frequencies in Hz of the spectrums. The other columns are the mean, standard error and 95% confidence interval of the region’s spectrum.	{Root_dir}/{sessions}/Stats/{group}



The main scripts that you are going to use are explained in the following table. Any script can be called with the --help option to get their usage information....
Script name	description	Inputs 	outputs	Example usage
				
...



Those scripts were developed and tested with only one dataset, so even if I did my best to make it compatible with new data, you might have to tweak them a little.
