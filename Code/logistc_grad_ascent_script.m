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

%%
[theta, ll] = logistic_grad_ascent(X(1:N_train,:),Y_train, 1e-14,500); % X, Y, alpha, max_iters
%[theta, ll] = logistic_newtons(X, Y, 10); % X, Y, max_iters
%%
X_test = [ones(size(X(N_train:N,:),1),1), X(N_train:N,:)];
Y_test = sigmoid([X_test*theta]);
Y_test(Y_test>=0.5) = 1;
Y_test(Y_test<0.5) = 0;
error = sum(abs(Y_true - Y_test))/length(Y_true);