function [enf_signal, grid_number] = preprocessing(recording)
grid_letter = recording(27);
[signal, Fs]= audioread(recording);
[~,~,fundfreq,~,~] = toi(signal);
f_0 = fundfreq(2)*Fs;

%   ==========
%   Find closest fundamental frequency candidate (50 or 60)

mod_50 = mod(f_0,50);
mod_60 = mod(f_0,60);

%   Compute variation from 50 Hz
if((mod_50>25))
    var_50 = abs(mod_50-50);
else
    var_50 = abs(mod_50);
end

%   Compute variation from 60 Hz
if((mod_60>30))
    var_60 = abs(mod_60-60);
else
    var_60 = abs(mod_60);
end
    
%   Pick most likely nominal frequecy
if(var_50 < var_60)
    f_n = 50
else
    f_n = 60
end

%   ==========
%   Determine highest powered curve
highest_powered_curve = 1;

for (i = 2:6)
    if (abs(f_0 - i*f_n) <abs(f_0 - (i-1)*f_n))
        highest_powered_curve = i;
    end
end

%   ======================
%   Find proper threshold
%   Repeat at each harmonic
%   Used Map containers to avoid issues with different sizes
N_WINDOW = 9250;
N_OVERLAP = N_WINDOW/2;
STEP_SIZE = .001;
N_BIN = 500;
% LARGE_NUMBER = 100000;

% TODO: REMOVE unused MAPs
ranges = containers.Map('KeyType','int32','ValueType','any');
f = containers.Map('KeyType','int32','ValueType','any');
p = containers.Map('KeyType','int32','ValueType','any');
p_db = containers.Map('KeyType','int32','ValueType','any');
h = containers.Map('KeyType','int32','ValueType','any');
m = containers.Map('KeyType','int32','ValueType','any');

%   Compute a min_thresh for each harmonic
for i=1:6
    ranges(i) = [(i*f_n - i):STEP_SIZE:(i*f_n + i)];
    [~,f(i),t,p(i)] = spectrogram(signal,N_WINDOW,N_OVERLAP,ranges(i),Fs);
    p_temp = p(i);  %   Temporary variable to index into a list element we've indexed into
    p_db(i) = 10*log10(p_temp(logical(f(i)),logical(t)));
    p_db_temp = p_db(i);    %   Temporary variable to index into a list element we've indexed into
    p_db(i) = p_db_temp(:);
    h(i) = histfit(p_db(i), N_BIN, 'kernel');
    h_temp = h(i);
    x = h_temp(2).XData;
    y = h_temp(2).YData;
    y_inverse = -y;
    [pks,locs] = findpeaks(y_inverse,x);
    if ~isempty(locs)
        min_thresh(i) = locs(1);
    else
        min_thresh(i) = NaN;
    end
    clear p(i)
    %   Now find curves at each harmonic by removing the noise through recomputation of the spectrogram (thresholding)
    [~,f(i),t,p(i)] = spectrogram(signal,N_WINDOW,N_OVERLAP,ranges(i),Fs,'MinThreshold',min_thresh(i));
    p_temp = p(i);  %   Re-assign temporary variable to index into a list element we've indexed into
    [m(i),~] = medfreq(p_temp(logical(f(i)),logical(t)),f(i)); %take median frequency over that range    
    close
end

if (highest_powered_curve == 1)
    range_new = ranges(1);
    min_thresh_new = min_thresh(1);
    combined = m(1);
elseif (highest_powered_curve == 2)
    range_new = ranges(2);
    min_thresh_new = min_thresh(2);
    combined = m(2)/2;
elseif (highest_powered_curve == 3)
    range_new = ranges(3);
    min_thresh_new = min_thresh(3);
    combined = m(3)/3;
elseif (highest_powered_curve == 4)
    range_new = ranges(4);
    min_thresh_new = min_thresh(4);
    combined = m(4)/4;
elseif (highest_powered_curve == 5)
    range_new = ranges(5);
    min_thresh_new = min_thresh(5);
    combined = m(5)/5;
else
    range_new = ranges(6);
    min_thresh_new = min_thresh(6);
    combined = m(6)/6;
end
decrement_min_thresh = 1;
nan_count = length(find(isnan(combined)));

while (nan_count > 0)
    nan_indices = find(isnan(combined))
    
    %   Careful : Indexes into nan_indices
    d = [0,diff(nan_indices)==1,0];
    start_ind = strfind(d,[0 1])
    end_ind = strfind(d,[1 0])
    if ~isempty(start_ind)
        first_nan_index = nan_indices(start_ind(1))
        last_nan_index = nan_indices(end_ind(1))
    else
        first_nan_index = nan_indices(1)
        last_nan_index = nan_indices(1)
    end

    [~,f_subset,t_subset,p_subset] = spectrogram(signal,N_WINDOW,N_OVERLAP,range_new,Fs, 'MinThreshold',min_thresh_new - decrement_min_thresh );
    [m_subset,pm_subset] = medfreq(p_subset(logical(f_subset),logical(t_subset)),f_subset); %take median frequency over that range
    m_subset = m_subset((first_nan_index):(last_nan_index));
        
    %   Combine original with extra curve parts obtained from more
    %   lenient threshold
    for j=1:length(combined)
       if(j>= (first_nan_index) && j<=(last_nan_index))
           combined(j) = m_subset(j-(first_nan_index-1))/highest_powered_curve;
       end
    end
    nan_count = length(find(isnan(combined)));
    %   Decrement further the treshold if necessary
    decrement_min_thresh = decrement_min_thresh+1;
end

% Now remove points seen as noise
%combined(combined>(mean(combined)+std(combined))||combined(combined<(mean(combined)-std(combined))=NaN;
for i=1:length(combined)
    if (i>1 && i< length(combined))
        if(combined(i)>combined(i-1)+nanstd(combined) && combined(i)>combined(i+1)+nanstd(combined))
            combined(i) = NaN
        elseif(combined(i)<combined(i-1)-nanstd(combined) && combined(i)<combined(i+1)-nanstd(combined))
            combined(i) = NaN
        end
    end
end

% New curve filling using inpaint_nans
combined = inpaint_nans(combined);

enf_signal = struct('time',t, 'values', combined);
%enf_signal = combined;

Alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
[~, grid_number] = find(Alphabet == grid_letter)
end