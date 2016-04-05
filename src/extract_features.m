function feature_vector= extract_features(signal, grid_number)
Fs = 1000;
mle_values = mle(signal.values,'distribution','norm')
mean_value = mle_values(1);
std_deviation = mle_values(2);
median_value = nanmedian(signal.values);
max_value = max(signal.values);
min_value = min(signal.values);
[pksh,lcsh] = findpeaks(signal.values);
avg_distance_peaks = mean(diff(lcsh))/Fs;
occurences = double(length(lcsh));
peak_periodicity = occurences/length(signal.time);    %Was /length(signal.time+1)

% fourier_values = fft(signal.values,2);
vertices = [signal.values;signal.time]
% normals = LineNormals2D(vertices);
% vertices = vertices
curvature = LineCurvature2D(vertices');
curvature = 10000000*var(curvature);


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
crossings = (double(step(Hzerocross,(signal.values-f_n)')))/length(signal.time);
%hdydanl = dsp.DyadicAnalysisFilterBank('Filter','Haar','NumLevels',4);
%C = step(hdydanl, signal.values);

signal_integral = (trapz(signal.time,signal.values-f_n))/length(signal.time)

[ar_coeff, ar_e] = aryule(signal.values-f_n, 2);

% Dummy coded variables
is_50 = 0;
is_60 = 0;
if(f_n == 60)
    is_60 = 1.0;
else
    is_50 = 1.0;
end

[C,L] = wavedec(signal.values,6,'db4');
[d1,d2,d3,d4, d5, d6] = detcoef(C,L,[1 2 3 4 5 6]);
a1 = appcoef(C,L,'db4',1);
a2 = appcoef(C,L,'db4',2);
a3 = appcoef(C,L,'db4',3);
a4 = appcoef(C,L,'db4',4);
a5 = appcoef(C,L,'db4',5);
a6 = appcoef(C,L,'db4',6);

var_d1 = var(d1)*10000;
var_d2 = var(d2)*10000;
var_d3 = var(d3)*10000;
var_d4 = var(d4)*10000;
var_d5 = var(d5)*10000;
var_d6 = var(d6)*10000;

var_a1 = var(a1)*10000;
var_a2 = var(a2)*10000;
var_a3 = var(a3)*10000;
var_a4 = var(a4)*10000;
var_a5 = var(a5)*10000;
var_a6 = var(a6)*10000;

% len=length(signal.values);
% cfd=zeros(4,len);
% for k=1:4
%     d=detcoef(C,L,k);
%     d=d(ones(1,2^k),:);
%     cfd(k,:)=wkeep(d(:)',len);
% end
% cfd=cfd(:);
% I=find(abs(cfd) <sqrt(eps));
% cfd(I)=zeros(size(I));
% cfd=reshape(cfd,4,len);
% image(flipud(wcodemat(cfd,255,'row')));
% close



feature_vector = [median_value min_value max_value range_value mean_value std_deviation avg_distance_peaks peak_periodicity ar_coeff(2) ar_coeff(3) ar_e crossings signal_integral curvature var_d1 var_d2 var_d3 var_d4 var_d5 var_d6 var_a1 var_a2 var_a3 var_a4 var_a5 var_a6 is_50 is_60 grid_number]
end
