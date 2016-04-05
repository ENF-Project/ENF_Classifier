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
features_1 = csvread('cv1_curvature_9250_haar.csv');
features_2 = csvread('cv2_curvature_9250_haar.csv');
features_3 = csvread('cv3_curvature_9250_haar.csv');
features_4 = csvread('cv4_curvature_9250_haar.csv');

training_features = vertcat(features_1,features_2,features_3,features_4);



num_features = 25;
num_samples = 384;

%training_features(:,1:num_features - 1) = zscore(training_features(:,1:num_features - 1));
%validation_features(:,1:num_features - 1) = zscore(validation_features(:,1:num_features - 1));

%colwise_min = min(training_features(:,1:num_features-1));
%colwise_max = max(training_features(:,1:num_features-1));


% for i = 1 : num_samples
%     training_features(i, 1:num_features-1) = ((training_features(i, 1:num_features-1)-colwise_min)/(colwise_max-colwise_min));
% end

X_training = training_features(:,1:num_features - 1);
y_training = training_features(:,num_features);

[rows, columns] = size(y_training);
output = zeros(384,9);
for row = 1 : rows
    if y_training(row)== 1
       output(row,1)=1;
    elseif y_training(row)== 2
       output(row,2)=1;
    elseif y_training(row)== 3
       output(row,3)=1;
    elseif y_training(row)== 4
       output(row,4)=1;
    elseif y_training(row)== 5
       output(row,5)=1;
    elseif y_training(row)== 6
       output(row,6)=1;
    elseif y_training(row)== 7
       output(row,7)=1;
    elseif y_training(row)== 8
       output(row,8)=1;
    elseif y_training(row)== 9
       output(row,9)=1;
    end
end
%X_validation = validation_features(:,1:num_features - 1)
%y_validation = validation_features(:,num_features)

