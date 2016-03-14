features_1 = csvread('CV1.csv');
features_2 = csvread('CV2.csv');
features_3 = csvread('CV3.csv');
features_4 = csvread('CV4.csv');

training_features = [features_1;features_2;features_3];
validation_features = features_4;

B = train_model(training_features);

results = classify_grid(B, validation_features)
% csvwrite('crossval_regularized_123_4_predictions.csv', results);

accuracy = length(results(results == validation_features(:, end)))/length(validation_features)
