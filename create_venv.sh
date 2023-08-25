#!/bin/bash

# Name of the virtual environment
venv_name="$1"

# List of packages to install
packages=("numpy" "nibabel" "nilearn" "matplotlib" "scipy")

# Create the virtual environment
module load python
python3 -m venv $venv_name

# Activate the virtual environment
source $venv_name/bin/activate

# Update pip and install packages
pip install --upgrade pip
pip install "${packages[@]}"

# Check if the "leave activated" argument is provided
if [ "$1" == "--leave-activated" ]; then
    echo "Virtual environment created and packages installed. Environment is still activated."
else
    # Deactivate the virtual environment
    deactivate
    echo "Virtual environment created and packages installed. Environment deactivated."
fi

echo "Virtual environment created and packages installed."
