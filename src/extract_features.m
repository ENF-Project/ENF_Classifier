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
ar2 = aryule(signal.values, 2);


feature_vector = [median_value max_value min_value mean_value std_deviation short peak_periodicity ar2(2) ar2(3) grid_number]
end