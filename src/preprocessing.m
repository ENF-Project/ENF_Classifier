function [enf_signal, grid_letter] = preprocessing(recording)

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
STEP_SIZE = .001
N_BIN = 500
LARGE_NUMBER = 1000000

% REMOVE Maps when not used later on
ranges = containers.Map('KeyType','int32','ValueType','any');
f = containers.Map('KeyType','int32','ValueType','any');
p = containers.Map('KeyType','int32','ValueType','any');
p_db = containers.Map('KeyType','int32','ValueType','any');
h = containers.Map('KeyType','int32','ValueType','any');




for i=1:6
    ranges(i) = [(i*f_n - i):STEP_SIZE:(i*f_n + i)];
    [~,f(i),t,p(i)] = spectrogram(signal,N_WINDOW,N_OVERLAP,ranges(i),Fs);
    p_temp = p(i);  %   Temporary variable to index into a list element we've indexed into
    p_db(i) = 10*log10(p_temp(logical(f(i)),logical(t)));
    p_db_temp = p_db(i);    %   Temporary variable to index into a list element we've indexed into
    p_db(i) = p_db_temp(:);
    h(i) = histfit(p_db(i),N_BIN, 'kernel');
    h_temp = h(i);
    x = h_temp(2).XData;
    y = h_temp(2).YData;
    y_inverse = LARGE_NUMBER - y;
    [pks,locs] = findpeaks(y_inverse,x);
    if ~isempty(locs)
        min_tresh(i) = locs(1)
    else
        min_tresh(i) = NaN;
    end
end