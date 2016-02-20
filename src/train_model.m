function B = trainer(feature_matrix)
num_features = size(feature_matrix);
num_features = num_features(2);
[B, dev, stats] = mnrfit(feature_matrix(:,1:num_features - 1), feature_matrix(num_features));

end