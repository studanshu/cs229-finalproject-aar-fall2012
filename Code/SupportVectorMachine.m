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


%%
% Add Liblinear to the path
addpath('liblinear-1.92/matlab');

% Set up the SVM training matrix (replace 0's with -1's)
Y_SVM = Y; 
Y_SVM(Y_SVM == 0) = -1;

% Run liblinear to train on the data set and get a model
X_S = sparse(X);
model = train(Y_SVM, X_S);

% Run liblinear to come up with a predictive label on the test set
X_test = Features_Test;
X_test_S = sparse(X_test);
[predict_label, accuracy, decision_val] = ...
    predict(ones(size(X_test,1),1),X_test_S,model);

%%