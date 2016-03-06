features_1 = csvread('CV1_trimmed.csv');
features_2 = csvread('CV2_trimmed.csv');
features_3 = csvread('CV3_trimmed.csv');
features_4 = csvread('CV4_trimmed.csv');

training_features = [features_3;features_3;features_3];
validation_features = features_3;

B = train_model(training_features);

results = classify_grid(B, validation_features)
% csvwrite('crossval_regularized_123_4_predictions.csv', results);

accuracy = length(results(results == validation_features(:, end)))/length(validation_features)
