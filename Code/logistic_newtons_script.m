%% Logistic Regression using Newton's Method
% CS 229 Final Project
% 
% Data Parsing Script
% Coded by:
%   Robert Romano
%   Albert Ho
%   Alice Wu
% edits:
%   Alice - 11/15/12 - wrote code to run logistic regression using Newton's
%                      method from HW1

clear;
clc;
close all;

load('CarAuction_Parsed_Test');
load('CarAuction_Parsed_Train');

Y = Features_Train(:,1);
X = Features_Train(:,2:end);

N = size(Y);
N_train = floor(0.7*N);
N_CV = N-N_train;
Y_train = Y(1:N_train);
Y_true = Y(N_train:N);
%% run newton's method on 70% of the data set
[theta, ll] = logistic_newtons(X(1:N_train,:), Y, 10); % X, Y, max_iters

%% calculate the generalization error using 30% of the data set
%Y_test = sigmoid(X(j,:)*theta);
Y_test = sigmoid(X(N_train:N,:)*theta);
Y_test(Y_test>=0.5) = 1;
Y_test(Y_test<0.5) = 0;
error = sum(abs(Y_true - Y_test))/length(Y_true);
%cross validate data
%% run newton's method on the test data for submission onto Kaggle
[theta, ll] = logistic_newtons(X, Y, 10); % X, Y, max_iters
Y_Kaggle = sigmoid(Features_Test*theta);
Y_Kaggle(Y_Kaggle>=0.5) = 1;
Y_Kaggle(Y_Kaggle<0.5) = 0;
