# 2020 Slow Oscillations Review

This document outlines the steps necessary to generate Kevin L. Turner's data and code contributions to the Review manuscript **Ultra-slow oscillations in fMRI and resting-state connectivity: Neuronal and vascular contributions and technical confounds** by P. J. Drew*, C. Mateo*, K.L. Turner, X. Yu and D. Kleinfeld.

---
## Generating the figures
---
This data and code generates Figure 7d and 7e of the manuscript.

Begin by downloading the entire code repository and (if desired) the data from the following locations:
* Code repository location: https://github.com/DrewLab/Drew_Mateo_Turner_Yu_Kleinfeld_Neuron2020
* Data repository location: https://psu.box.com/s/asrvku6m6kpojn9hzz2ndr6azcjjkimh

The github repository contains a pre-analyzed **ComparisonData.mat** structure that can be used to immediately generate the figures without re-analyzing any data. If you would like to view the figure in its final form, simply CD to the code repository's directory (folder) in Matlab and open the file **MainScript_Neuron2020.m**. This file will add all the requisite sub-functions and generate the figure. If you would like to re-analyze the data from the beginning, download each animal's folder (9 total) from the box link. Unzip all 9 folders and put them into the same folder that contains the code repository (Drew_Mateo_Turner_Yu_Kleinfeld_Neuron2020). Remove or delete the **ComparisonData.mat** structure from this folder, as the code will only run from the beginning if this file is not present. If done correctly, two loading bars should pop up upon execution of **MainScript_Neuron2020.m**. This will take several minutes to run, depending on computer speed and data location.

---
## Original data and pre-processing
---
The data provided has gone through several pre-processing steps. Original data (.TIFF stacks, analog .txt files, camera .bin files, and LabVIEW TDMS files) are available upon request. The code used to initially process all initial files is provided in the code repository's **Pre-processing-scripts** folder. The analysis follows past techniques from Winder et al, 2017. Paper available at: https://www.nature.com/articles/s41593-017-0007-y and code available at https://github.com/DrewLab/Winder_Echagarruga_Zhang_Drew_2017_Code 

The baseline diameter of each vessel was determined by taking all periods of 5 seconds or greater with no whisker stimulation, volitional whisking, or body movement. These periods were averaged to establish a "resting baseline" diameter unique to each day of imaging. Any differences in sampling rate, trial duration, or lost data were corrected in these stages.

LabVIEW code used to acquire the data can be found at: https://github.com/DrewLab/LabVIEW-DAQ 

---
## Core data analysis
---

### Single trial example

The single trial example shown in figure 7d is from animal T72, file ID **T72_A1_190317_19_21_24_022_MergedData.mat.** A function to conveniently view other individual vessels from any animal is provided: **ViewIndividualVessels_Neuron2020.m.** Simply navigate through the different animal's folders and run this function, which will prompt you to manually select a file. The function will then generate a figure analyzed identically to the representative example in Fig 7d.

### Cross-correlation analysis

Behavioral data (whisker acceleration, piezo sensor) was processed to match the sampling rate and filter characteristics (2 Hz low-pass) of the vessel diameter. The Matlab function *xcorr* was then used between the identical-length signals for each vessel across all days of imaging. The average cross-correlation as a function of lag time was take for each indivial vessel (n = 27 vessels) and then the population average taken across those 27 instances. The standard error (StD/sqrt(27)) is shown above and below the population mean. The peak time is shown as the mean and standard deviation of the 27 vessel cross-correlations individual peak times.

### Spectral coherence analysis

Behavioral data (whisker acceleration, piezo sensor) was processed to match the sampling rate and filter characteristics (2 Hz low-pass) of the vessel diameter. The chronux function *coherencyc* (http://chronux.org/) was then used between the identical-length signals for each vessel across all days of imaging. The average coherence as a function of frequency was take for each indivial vessel (n = 27 vessels) and then the population average taken across those 27 instances. The standard error (StD/sqrt(27)) is shown above and below the population mean. The 95% confidence interval is the singular most conservative instance taken from the *coherencyc* function's output [confC], which in this case is specifically from animal T82 vessel A3 who had only two fifteen-minute scans for that vessel. Confidence intervals were not averaged across vessels, and thus the highest (most concservative) is shown. Coherence parameters are:
- params.tapers = [10,19];
- params.pad = 1;
- params.Fs = 5; 
- params.fpass = [0,0.5]; 
- params.trialave = 1;
- params.err = [2,0.05];

### Animal and vessel information
Notes on each animal including surgery information, habituation, and imaging timeline can be found in each animal's Notes folder. The population consists of:
- N = 9 animals (8 with cortical sectioned histology)
- n =  27 vessels (all surface arterioles, MCA branch over barrels/somatosensory cortex). 
- Total time: 36.7 Hrs
    - Mean Time per Vessel: 81.6 min. +/- StD 47.8 min
    - Max: 195 min.
    - Min: 28 min.
- Baseline diameter 
    - Mean 29 uM +/- StD 7.6 uM 
    - Max 43.7 uM 
    - Min 18.2 uM 

---
## Acknowledgements
---
* multiWaitbar.m Author: Ben Tordoff https://www.mathworks.com/matlabcentral/fileexchange/26589-multiwaitbar-label-varargin
* colors.m Author: John Kitchin http://matlab.cheme.cmu.edu/cmu-matlab-package.html
* Chronux subfunctions http://chronux.org/
* Several functions utilize varying bits of code written by Dr. Patrick J. Drew and Dr. Aaron T. Winder https://github.com/DrewLab

#### Feel free to contact Patrick Drew or Kevin Turner (klt8@psu.edu) with any issues running the anaysis. 
