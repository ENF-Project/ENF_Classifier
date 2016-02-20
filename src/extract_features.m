function feature_vector= extract_features(signal, grid_number)
Fs = 1000;
[mean_value, std_deviation] = mle(signal,'distribution','norm')
median_value = nanmedian(signal.values);
max_value = max(signal.values);
min_value = min(signal.values);
[pksh,lcsh] = findpeaks(signal.values);
short = mean(diff(lcsh))/Fs;
occurences = double(length(lcsh));
peak_periodicity = occurences/length(signal.time+1);

feature_vector = [median_value max_value min_value mean_value std_deviation short peak_periodicity grid_number]
end