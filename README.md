# tpil_native_freq_analysis
This repository is a collection of scripts and files to do frequency analysis of fmri in native space.

How to use this  repository :

What you need:
    1- The only MRI data you need to begin with is an fmri run for every subject.
    2- You need to have a compute Canada account to be able to run most of the scripts on their clusters.
    3- A text file with the complete subject labels with their group labels. See Group_subjects.txt for an example.


Getting started:
1- Start by cloning this repository on your scratch on a compute canada server. 
2- In an other folder, place your data with the following structure:
    Root directory  -> session ->  subject label -> func  ->  filename 
    # For now the filename need to be “sub-{numerical subject label}__task-rest_bold.nii.gz” other wise the code have to be modified
3- Build the freesurfer.sif image in the repository directory by running the build_freesurfer_container.sh script.
    bash build_freesurfer_container.sh
4- I recommend using the create_venv.sh script to build the virtual environment needed for the python scripts before running the main. You should create it in your scratch in dedicated to virtual environment
    bash create_venv.sh  “/scratch/ENV/frequency_analysis”
5- I also recommend creating the subjectIDs.txt file for every visit before running the main. You can do that with the create_subject_txt_file.sh script.


Outputs

The main will generate subject specific outputs in a directory called frequency_analysis_outputs directly in the subject’s folder. This is where the power spectrum file is saved. Other files created during processing will be stored in
    <Root directory>/<session>/<subject label>/frequency_analysis_outputs
Other subject specific files created during processing will be stored in subfolders within this directory
Session specific files will be stored in <Root directory>/<session>/Stats
Output file	description	location
		



The main scripts that you are going to use are explained in the following table. Any script can be called with the --help option to get their usage information.
Scripts	description	Example usage
		




Those scripts were developed and tested with only one dataset, so even if I did my best to make it compatible with new data, you might have to tweak them a little.
