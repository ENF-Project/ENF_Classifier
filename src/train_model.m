function B = train_model(feature_matrix)
num_features = size(feature_matrix);
num_samples = num_features(1);
num_features = num_features(2);

% for i = 1 : num_samples
%     
%     feature_matrix(i, 1:num_features - 1) = zscore(feature_matrix(i,1:num_features - 1));
% end
feature_matrix(:,1:num_features - 1) = zscore(feature_matrix(:,1:num_features - 1));

[B, dev, stats] = mnrfit(feature_matrix(:,1:num_features - 1), feature_matrix(:,num_features));
 
% lambda = 0.8;
% B = B * (1-lambda);

end