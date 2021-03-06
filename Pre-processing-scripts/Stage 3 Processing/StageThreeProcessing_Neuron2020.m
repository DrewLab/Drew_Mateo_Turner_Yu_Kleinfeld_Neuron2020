%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
%   Purpse:  1) Additions to the MergedData structure including flags and scores.
%            2) A RestData.mat structure with periods of rest.
%            3) A EventData.mat structure with event-related information.
%            4) Find the resting baseline for vessel diameter and neural data.
%            5) Analyzing the spectrogram for each file and normalize by the resting baseline.
%________________________________________________________________________________________________________________________

%% BLOCK PURPOSE: [0] Load the script's necessary variables and data structures.
% Clear the workspace variables and command window.
clc;
clear;
disp('Analyzing Block [0] Preparing the workspace and loading variables.'); disp(' ')
mergedDirectory = dir('*_MergedData.mat');
mergedDataFiles = {mergedDirectory.name}';
mergedDataFiles = char(mergedDataFiles);
[animalID,~,~,~,~] = GetFileInfo2_Neuron2020(mergedDataFiles(1,:));
load(mergedDataFiles(1,:), '-mat');
trialDuration_Sec = MergedData.notes.trialDuration_Sec;
dataTypes = {'vesselDiameter','deltaPower','thetaPower','alphaPower','betaPower','gammaPower','muaPower'};

%% BLOCK PURPOSE: [1] Categorize data.
disp('Analyzing Block [1] Categorizing behavioral data, adding flags to MergedData structures.'); disp(' ')
CheckDataShape_Neuron2020(mergedDataFiles)
for a = 1:size(mergedDataFiles, 1)
    fileName = mergedDataFiles(a, :);
    disp(['Analyzing file ' num2str(a) ' of ' num2str(size(mergedDataFiles, 1)) '...']); disp(' ')
    CategorizeData_Neuron2020(fileName)
end

%% BLOCK PURPOSE: [2] Create RestData data structure.
disp('Analyzing Block [2] Creating RestData struct for vessels and neural data.'); disp(' ')
[RestData] = ExtractRestingData_Neuron2020(mergedDataFiles,dataTypes);
    
%% BLOCK PURPOSE: [3] Create EventData data structure.
disp('Analyzing Block [3] Creating EventData struct for vessels and neural data.'); disp(' ')
[EventData] = ExtractEventTriggeredData_Neuron2020(mergedDataFiles,dataTypes);

%% BLOCK PURPOSE: [4] Create Baselines data structure.
disp('Analyzing Block [4] Finding the resting baseline for vessel diameter and neural data.'); disp(' ')
targetMinutes = 30;
if strcmp(animalID,'T72') || strcmp(animalID,'T73') || strcmp(animalID,'T74') || strcmp(animalID,'T75') || strcmp(animalID,'T76')
    trialDuration_sec = 10;   % sec
elseif strcmp(animalID,'T80') || strcmp(animalID,'T81') || strcmp(animalID,'T82') || strcmp(animalID,'T83')
    trialDuration_sec = 30;   % sec
end
[RestingBaselines] = CalculateRestingBaselines_Neuron2020(animalID,targetMinutes,trialDuration_sec,RestData);

%% BLOCK PURPOSE [5] Analyze the spectrogram for each session.
disp('Analyzing Block [5] Analyzing the spectrogram for each file and normalizing by the resting baseline.'); disp(' ')
CreateTrialSpectrograms_Neuron2020(mergedDataFiles);
% Find spectrogram baselines for each day
specDirectory = dir('*_SpecData.mat');
specDataFiles = {specDirectory.name}';
specDataFiles = char(specDataFiles);
[RestingBaselines] = CalculateSpectrogramBaselines_Neuron2020(animalID,trialDuration_Sec,specDataFiles,RestingBaselines);
% Normalize spectrogram by baseline
NormalizeSpectrograms_Neuron2020(specDataFiles,RestingBaselines);

disp('Two Photon Stage Three Processing - Complete.'); disp(' ')
