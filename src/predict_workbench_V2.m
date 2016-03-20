% 
%   Code based on my own implementation for Assignment 3 in Andrew Ng's ML 
%   online course, adapted for our ENF classifier
%

%% Initialization
clear ; close all; clc

%% Setup parameters
% num_features = size(feature_matrix);

num_labels = 9;           % 9 labels, from A to I   

%% =========== Loading data =============

% Load Training Data
fprintf('Loading and Visualizing Data ...\n')

% load('ex3data1.mat'); % training data stored in arrays X, y
features_1 = csvread('CV1_15_03_16_completefeatures.csv');
features_2 = csvread('CV2_15_03_16_completefeatures.csv');
features_3 = csvread('CV3_15_03_16_completefeatures.csv');
features_4 = csvread('CV4_15_03_16_completefeatures.csv');

% training_features = [features_1;features_2;features_4];
% validation_features = features_3;
% 
% training_features = [features_1;features_2;features_3];
% validation_features = features_4;
% 
training_features = [features_2;features_3;features_4];
validation_features = features_1;
% 
% training_features = [features_3;features_4;features_1];
% validation_features = features_2;

num_features = size(training_features);
num_samples = num_features(1);
num_features = num_features(2);

% training_features(:,1:num_features - 1) = zscore(training_features(:,1:num_features - 1));
% validation_features(:,1:num_features - 1) = zscore(validation_features(:,1:num_features - 1));

X_training = training_features(:,1:num_features - 1);
y_training = training_features(:,num_features);

X_validation = validation_features(:,1:num_features - 1)
y_validation = validation_features(:,num_features)

m = size(X_training, 1); %Remove, = num_training_samples

%% ============ Train one v. all Logistic Regression ============

fprintf('\nTraining One-vs-All Logistic Regression...\n')

lambda = 0;   
[all_theta] = oneVsAll(X_training, y_training, num_labels, lambda);

%% ================ Predict ================
pred = predictOneVsAll(all_theta, X_validation);

fprintf('\nTraining Set Accuracy: %f\n', mean(double(pred == y_validation)) * 100);
