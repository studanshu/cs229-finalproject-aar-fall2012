function [predict_label, accuracy, decision_val, precision, recall,model] = ...
    SVM_fun(Y_train,X_train,Y_test,X_test)
% Code for implementing Liblinear v. 1.92
% 
% [PL,A,DV] = SVM_fun(Y_train,X_train,Y_test,X_test)
% 
% Inputs:
% Y_train - training set output (either as -1 and 1 or 0 and 1) arranged
%           so that each sample is represented by a row
% X_train - training set inputs arranged so that each sample is a row
% Y_test  - same as Y_train, but for testing (put arbitrary vector if
%           unavailable
% X_test  - same as X_train, but for testing
%
% Outputs:
% PL      - Label predictions for test data arranged so each sample is
%           a row
% A       - Accuracy of the predictions compared to the test values
%           provided
% DV      - Decision value
%
% Written by Robert Romano

% Add Liblinear to the path
addpath('liblinear-1.92/matlab');

% Set up the SVM training matrix (replace 0's with -1's)
Y_SVM_train = Y_train; 
Y_SVM_train(Y_SVM_train == 0) = -1;

% Set up the SVM testing matrix (replace 0's with -1's)
Y_SVM_test = Y_test; 
Y_SVM_test(Y_SVM_test == 0) = -1;

% Run liblinear to train on the data set and get a model
X_train_S = sparse(X_train);
model = train(Y_SVM_train, X_train_S);

% Run liblinear to come up with a predictive label on the test set
X_test_S = sparse(X_test);
[predict_label, accuracy, decision_val] = ...
    predict(Y_SVM_test,X_test_S,model);

% Find Precision: TP/(TP + FP)
TP = sum(Y_test(predict_label == 1));
FP = size(Y_test(predict_label == 1),1)-TP;
precision = TP/(TP + FP);

% Find Recall: TN/(TN + FN)
FN = sum(Y_test(predict_label == -1));
TN = size(Y_test(predict_label == -1),1)-FN;
recall = TP/(TP + FN);
