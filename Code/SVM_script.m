% CS 229 Final Project Script 
% Applying SVM to Car Auction Data
%
% Written by Robert Romano
clear;
clc;
close all;

% Load data resulting from data parsing MATLAB script
load('CarAuction_Parsed_Test');
load('CarAuction_Parsed_Train');

% Split Y values from X values in training set
Y = Features_Train(:,1);
X = Features_Train(:,2:end);
 
% Create a 70-30 split of training data for cross-validation
% Record number of samples in 70-30 split
N = size(Y,1);
N_train = floor(0.7*N);
N_CV = N-N_train;

% Choose a random set of indices to train on and ensure they are unique
train_index = ceil(N.*rand(N_train,1));
while (size(unique(train_index),1) ~= size(train_index,1))
    train_index = unique(train_index);
    unique_needed = N_train - size(train_index,1);
    train_index = [train_index ; ceil(N.*rand(unique_needed,1))];
end
test_index = setdiff(1:N,train_index)';

% Split the Y and X data
Y_train = Y(train_index);
Y_CV = Y(test_index);
X_train = X(train_index,:);
X_CV = X(test_index,:);


%%
% Run SVM using custom SVM function that uses liblinear on cross
%   validation set
[Prediction, Accuracy, DV] = ...
    SVM_fun(Y_train,X_train,Y_CV,X_CV);

%%
% Run SVM using custom SVM function that uses liblinear on all
%   available training data
% Y_dummy = zeros(size(Features_Test,1),1);
Y_dummy = ones(size(Features_Test,1),1);
[Submission, Accuracy, DV] = ...
    SVM_fun(Y_train,X_train,Y_dummy,Features_Test);