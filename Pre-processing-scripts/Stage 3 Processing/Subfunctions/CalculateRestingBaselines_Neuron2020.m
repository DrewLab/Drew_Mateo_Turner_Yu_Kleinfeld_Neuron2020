function [RestingBaselines] = CalculateRestingBaselines_Neuron2020(animalID,targetMinutes,trialDuration_sec,RestData)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
%   Purpose: This function finds the resting baseline for all fields of the RestData.mat structure, for each unique day
%________________________________________________________________________________________________________________________

% The RestData.mat struct has all resting events, regardless of duration. We want to set the threshold for rest as anything
% that is greater than 10 seconds.
RestCriteria.Fieldname = {'durations'};
RestCriteria.Comparison = {'gt'};
RestCriteria.Value = {5};
[restLogical] = FilterEvents_Neuron2020(RestData.vesselDiameter,RestCriteria);
allRestFileIDs = RestData.vesselDiameter.fileIDs(restLogical,:);
allRestDurations = RestData.vesselDiameter.durations(restLogical,:);
allRestEventTimes = RestData.vesselDiameter.eventTimes(restLogical,:);
allRestVesselIDs = RestData.vesselDiameter.vesselIDs(restLogical,:);
uniqueVessels = unique(allRestVesselIDs);
dataTypes = fieldnames(RestData);
combDirectory = dir('*_MergedData.mat');
mergedDataFiles = {combDirectory.name}';
mergedDataFiles = char(mergedDataFiles);
for a = 1:size(mergedDataFiles)
    mergedDataFile = mergedDataFiles(a,:);
    [~,~,fileID,vesselID,~] = GetFileInfo2_Neuron2020(mergedDataFile);
    allFileDates{a,1} = fileID;
    allVesselIDs{a,1} = vesselID;
end
uniqueDates = GetUniqueDays_Neuron2020(allFileDates);
for b = 1:length(uniqueDates)
    uniqueDays{b,1} = ConvertDate_Neuron2020(uniqueDates{b,1});
end
tempBaseFileIDs = {};
tempBaseEventTimes = [];
tempBaseDurations = [];
% Find the fieldnames of RestData and loop through each field. Each fieldname should be a different dataType of interest.
% These will typically be CBV, Delta, Theta, Gamma, and MUA
for u = 1:length(uniqueVessels)
    uV = uniqueVessels{u};
    for c = 1:length(allVesselIDs)
        checkID = allVesselIDs{c,1};
        if strcmp(uV,checkID)
            validFiles(c,1) = 1;
        else
            validFiles(c,1) = 0;
        end
    end
    validFiles = logical(validFiles);
    validDays = allFileDates(validFiles);
    for v = 1:length(uniqueDays)
        uD = uniqueDays{v};
        for w = 1:length(dataTypes)
            dT = char(dataTypes(w));   % Load each loop iteration's fieldname as a character string
            allRestData = RestData.(dT).data(restLogical,:);
            disp(['Calculating the resting baseline of ' dT ' for vessel ' uV ' on ' uD '...']); disp(' ')
            vesselFilterLogical = zeros(length(allRestVesselIDs),1);   % Find all the vessels that correspond to this loop's vessel (A1, A2, A3, etc)
            for vF = 1:length(allRestVesselIDs)
                vessel = char(allRestVesselIDs(vF,1));
                if strcmp(uV,vessel)
                    vesselFilterLogical(vF,1) = 1;
                end
            end
            vesselFilterLogical = logical(vesselFilterLogical);
            singleVesselFileIDs = allRestFileIDs(vesselFilterLogical);
            singleVesselDurations = allRestDurations(vesselFilterLogical);
            singleVesselEventTimes = allRestEventTimes(vesselFilterLogical);
            singleVesselIDs = allRestVesselIDs(vesselFilterLogical);
            singleVesselData = allRestData(vesselFilterLogical);
            dayFilterLogical = zeros(length(singleVesselFileIDs),1);
            for dF = 1:length(singleVesselFileIDs)
                day = ConvertDate_Neuron2020(singleVesselFileIDs{dF,1}(1:6));
                if strcmp(uD,day)
                    dayFilterLogical(dF,1) = 1;
                end
            end
            dayFilterLogical = logical(dayFilterLogical);
            uniqueDayVesselFileIDs = singleVesselFileIDs(dayFilterLogical);
            uniqueDayVesselDurations = singleVesselDurations(dayFilterLogical);
            uniqueDayVesselEventTimes = singleVesselEventTimes(dayFilterLogical);
            uniqueDayVesselIDs = singleVesselIDs(dayFilterLogical);
            uniqueDayVesselData = singleVesselData(dayFilterLogical);
            if ~isempty(uniqueDayVesselFileIDs)
                uniqueDayFiles = unique(uniqueDayVesselFileIDs);
                cutOffTime = targetMinutes/(trialDuration_sec/60);
                dayLog = zeros(length(validDays),1);
                for x = 1:length(validDays)
                    for y = 1:length(uniqueDayFiles)
                        if strcmp(validDays{x,1},uniqueDayFiles{y,1})
                            dayLog(x,1) = 1;
                        end
                    end
                end
                dayLog = logical(dayLog);
                valDays = validDays(dayLog,:);
                try
                    baselineFiles = {valDays(1:cutOffTime,1)}';
                catch
                    baselineFiles = {valDays(1:end,1)}';
                end
                timeFilterLogical = zeros(length(uniqueDayVesselFileIDs),1);
                for tF = 1:length(uniqueDayVesselFileIDs)
                    uniqueDayVesselFileID = uniqueDayVesselFileIDs(tF,1);
                    for bF = 1:length(baselineFiles)
                        baselineFile = baselineFiles{bF,1};
                        if strcmp(baselineFile,uniqueDayVesselFileID)
                            timeFilterLogical(tF,1) = 1;
                        end
                    end
                end
                timeFilterLogical = logical(timeFilterLogical);
                baselineVesselFileIDs = uniqueDayVesselFileIDs(timeFilterLogical);
                baselineVesselDurations = uniqueDayVesselDurations(timeFilterLogical);
                baselineVesselEventTimes = uniqueDayVesselEventTimes(timeFilterLogical);
                baselineVesselIDs = uniqueDayVesselIDs(timeFilterLogical);
                baselineVesselData = uniqueDayVesselData(timeFilterLogical);
                % find the means of each the unique vessel from the unique day for valid files
                clear tempData_means
                for x = 1:length(baselineVesselData)
                    tempData_means(x,1) = mean(baselineVesselData{x,1});
                end
            else
                tempData_means = [];
                baselineVesselFileIDs = [];
                baselineVesselDurations = [];
                baselineVesselEventTimes = [];
                baselineVesselIDs = [];
                baselineVesselData = [];
            end
            RestingBaselines.(uV).(uD).(dT).baseLine = mean(tempData_means);
            RestingBaselines.(uV).(uD).(dT).fileIDs = baselineVesselFileIDs;
            RestingBaselines.(uV).(uD).(dT).durations = baselineVesselDurations;
            RestingBaselines.(uV).(uD).(dT).eventTimes = baselineVesselEventTimes;
            RestingBaselines.(uV).(uD).(dT).vesselIDs = baselineVesselIDs;
            RestingBaselines.(uV).(uD).(dT).restData = baselineVesselData;
            RestingBaselines.targetMinutes = targetMinutes;
        end
        tempBaseFileIDs = vertcat(tempBaseFileIDs,baselineVesselFileIDs);
        tempBaseEventTimes = vertcat(tempBaseEventTimes,baselineVesselEventTimes);
        tempBaseDurations = vertcat(tempBaseDurations,baselineVesselDurations);
    end
end
RestingBaselines.targetMinutes = targetMinutes;
RestingBaselines.baselineFileInfo.fileIDs = tempBaseFileIDs;
RestingBaselines.baselineFileInfo.eventTimes = tempBaseEventTimes;
RestingBaselines.baselineFileInfo.durations = tempBaseDurations;
save([animalID '_RestingBaselines.mat'],'RestingBaselines');

end
