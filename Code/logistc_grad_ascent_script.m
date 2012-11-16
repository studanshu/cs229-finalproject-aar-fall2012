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
[theta, ll] = logistic_grad_ascent(X(:,1:2),Y, 0.01,100); % X, Y, alpha, max_iters
%[theta, ll] = logistic_newtons(X, Y, 10); % X, Y, max_iters
