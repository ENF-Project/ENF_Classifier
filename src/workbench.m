%November 11th 2015
clear


baseFolder = '../CVs/CV2/'; %Train_Grid_%s.wav

% Check to make sure that folder actually exists.  Warn user if it doesn't.
if ~isdir(baseFolder)
    errorMessage = sprintf('Error: The following folder does not exist:\n%s', baseFolder);
    uiwait(warndlg(errorMessage));
    return;
end

dirinfo = dir(baseFolder);
dirinfo(~[dirinfo.isdir]) = [];  %remove non-directories
tf = ismember( {dirinfo.name}, {'.', '..'});
dirinfo(tf) = [];  %remove current and parent directory.
recordings_counter = 0; %Keep track of number of processed recordings
features = zeros(length(dir(fullfile(baseFolder,dirinfo(1).name, '*.wav'))), 14);
% output = zeros(length(dir(fullfile(baseFolder,dirinfo(1).name, '*.wav'))),7)

for s = 1 : length(dirinfo)
    theFiles = dir(fullfile(baseFolder,dirinfo(s).name, '*.wav'));
    % Get a list of all files in the folder with the desired file name pattern.
    %filePattern = fullfile(myFolder, '*.wav'); % Change to whatever pattern you need.
    %theFiles = dir(myFolder);
    
    for k = 1 : length(theFiles)
        clearvars -except k fullFileName baseFileName theFiles baseFolder s dirinfo grid_name features;
        
        baseFileName = theFiles(k).name;
        fullFileName = fullfile(baseFolder,dirinfo(s).name, baseFileName);
        fprintf(1, 'Now reading %s\n', fullFileName);
        [combined, grid_number] = preprocessing(fullFileName);
        features(k, :) = extract_features(combined, grid_number);
        
        imageName = strcat(baseFileName, '.jpg');
        figure
        plot(combined.time,combined.values,'linewidth',1)
        xlabel('Time (s)')
        ylabel('Frequency (Hz)')
        title(sprintf('Curve Combination for %s', baseFileName))
        hgexport(gcf, imageName, hgexport('factorystyle'), 'Format', 'jpeg');
        close
    end
    dlmwrite('cv2_15_03_16_completefeatures.csv',features,'-append');
end