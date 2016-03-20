function feature_vector= extract_features(signal, grid_number)
Fs = 1000;
mle_values = mle(signal.values,'distribution','norm')
mean_value = mle_values(1);
std_deviation = mle_values(2);
median_value = nanmedian(signal.values);
max_value = max(signal.values);
min_value = min(signal.values);
[pksh,lcsh] = findpeaks(signal.values);
short = mean(diff(lcsh))/Fs;
occurences = double(length(lcsh));
peak_periodicity = occurences/length(signal.time+1);
[ar_coeff, ar_e] = aryule(signal.values, 2);
% [l_coeff, l_e] = lpc(signal.values,2);
% lev = 4;
% wname = 'sym2';
% [c,l] = wavedec(signal.values,lev,wname);
% [cA,cD] = dwt(signal.values,'sym2');
% mean_approximation_coeff = mean(cA);
range_value= max_value - min_value;

%    =======================================================
%    Find closest fundamental frequency candidate (50 or 60)
mod_50 = mod(mean_value,50);
mod_60 = mod(mean_value,60);

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
% %   ====================================================
Hzerocross = dsp.ZeroCrossingDetector;
crossings = double(step(Hzerocross,(signal.values-f_n)'));
%hdydanl = dsp.DyadicAnalysisFilterBank('Filter','Haar','NumLevels',1);
signal_integral = trapz(signal.time,signal.values-f_n)


feature_vector = [median_value min_value max_value range_value mean_value std_deviation short peak_periodicity ar_coeff(2) ar_coeff(3) ar_e crossings signal_integral grid_number]
end