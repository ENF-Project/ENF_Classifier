function [enf_signal, grid_number] = preprocessing(recording)

grid_letter = recording(15);
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
N_WINDOW = 20000;
N_OVERLAP = N_WINDOW/2;
STEP_SIZE = .001;
N_BIN = 500;
LARGE_NUMBER = 100000;

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
    y_inverse = LARGE_NUMBER - y;
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
while (~isempty(find(isnan(combined))))
    %   NEED TO REFACTOR THIS
    if(length(find(isnan(combined)))==1 && isnan(combined(length(combined))))
        break;
    end
    position = 1;
    %while position < length(combined)
    while 1
        start_point = 0;
        end_point = 0;

        %   Determine start position of empty part
        for i=position:length(combined)
            if isnan(combined(i))
                start_point = i;
                break;
            end
        end

        %   If went through entire curve and cannot reduce more then break
        if (i ==length(combined))
           break;
        end

        %   Determine end position of empty part
        while isnan(combined(i)) && i~=length(combined)
            end_point = i;
            i=i+1;
        end
        position = i;

        %   Add extra for coninuity
        if(end_point ~= length(combined))
           end_point = end_point +1;
        end
        if(start_point ~= 1)
            start_point = start_point -1;
        end
        %try to get the missing portion of the curve with a new threshold

        [~,f_subset,t_subset,p_subset] = spectrogram(signal,N_WINDOW,N_OVERLAP,range_new,Fs, 'MinThreshold',min_thresh_new - decrement_min_thresh );
        [m_subset,pm_subset] = medfreq(p_subset(logical(f_subset),logical(t_subset)),f_subset); %take median frequency over that range
        m_subset = m_subset((start_point):(end_point));
        
        %lenght_m_sub =length(m_subset)
        %length_comb = length(combined)
        %   Combine original with extra curve parts obtained from more
        %   lenient threshold
        for j=1:length(combined)
           if(j>= (start_point) && j<(end_point))
               combined(j) = m_subset(j-(start_point-1))/highest_powered_curve;
           end
        end
    end
    %   Decrement further the treshold if necessary
    decrement_min_thresh = decrement_min_thresh+1;
end
enf_signal = struct('time',t, 'values', combined);
%enf_signal = combined;

Alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
[~, grid_number] = find(Alphabet == grid_letter)
end