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
range1 = [(f_n -1):.001:(f_n +1)];
range2 = [(2*f_n -2):.001:(2*f_n +2)];
range3 = [(3*f_n -3):.001:(3*f_n +3)];
range4 = [(4*f_n -4):.001:(4*f_n +4)];
range5 = [(5*f_n -5):.001:(5*f_n +5)];
range6 = [(6*f_n -6):.001:(6*f_n +6)];