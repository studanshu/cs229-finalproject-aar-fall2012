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
%   Alice - 12/08/12 - used albert's normalize data, input code for false
%                      positives/negatives

clear;
clc;
close all;

balance = 0;

load('CarAuction_Parsed_Test');
load('CarAuction_Parsed_Train');

Y = Features_Train(:,1);
X = Features_Train(:,2:end);

N = size(Y);
N_train = floor(0.7*N);
N_CV = N-N_train;
X_train = X(1:N_train,:);
Y_train = Y(1:N_train);
X_test = X(N_train:N,:);
Y_true = Y(N_train:N);

%% balance data
% Repeat positive examples so that there is a more even distribution
if (balance == 0)
    X_positive = X_train(Y_train==1,:);
    Y_positive = ones(size(X_positive,1),1);
    N_positive = (length(Y_train)-length(Y_positive))/length(Y_positive);
    N_pos_mod = mod(length(Y_train)-length(Y_positive),length(Y_positive));
    for i = 1:(floor(N_positive)-1)
        X_train = [X_train; X_positive];
        Y_train = [Y_train; Y_positive];
    end
    X_train = [X_train; X_positive(1:N_pos_mod,:)];
    Y_train = [Y_train; Y_positive(1:N_pos_mod)];
    clear('X_positive','Y_positive','N_positive','N_pos_mod');
    balance = 1;
end
%% run newton's method on 70% of the data set
[theta, ll] = logistic_newtons(X_train, Y_train, 10); % X, Y, max_iters

%% calculate the generalization error using 30% of the data set
%Y_test = sigmoid(X(j,:)*theta);
Y_test = sigmoid(X_test*theta);
Y_test(Y_test>=0.63) = 1;
Y_test(Y_test<0.63) = 0;
error = sum(abs(Y_true - Y_test))/length(Y_true);
%cross validate data
%% precision/recall
tp = 0;
fp = 0;
tn = 0;
fn = 0;
correct_prediction = sum(Y_test)/sum(Y_true);

for i = 1:length(Y_test);
    if     ((Y_test(i) == 1) && (Y_true(i) == 1))
        tp = tp+1;
    elseif ((Y_test(i) == 1) && (Y_true(i) == 0))
        fp = fp+1;
    elseif ((Y_test(i) == 0) && (Y_true(i) == 0))
        tn = tn+1;
    elseif ((Y_test(i) == 0) && (Y_true(i) == 1))
        fn = fn+1;
    else
        disp('error!!!');
    end
end

precision = tp/(tp+fp)
recall = tp/(tp+fn)

%% change output threshold - stricter criteria
% calculate the generalization error using 30% of the data set
%Y_test = sigmoid(X(j,:)*theta);

output_threshold = 0.1:0.1:1;

for o = 1:length(output_threshold)
    Y_test = sigmoid(X(N_train:N,:)*theta);
    Y_test(Y_test>=output_threshold(o)) = 1;
    Y_test(Y_test<output_threshold(o)) = 0;
    number_predicted(o) = sum(Y_test>=output_threshold(o));
    error(o) = sum(abs(Y_true - Y_test))/length(Y_true);
    %cross validate data
    % precision/recall
    tp = 0;
    fp = 0;
    tn = 0;
    fn = 0;
    correct_prediction = sum(Y_test)/sum(Y_true);

    for i = 1:length(Y_test);
        if ((Y_test(i) == 1) && (Y_true(i) == 1))
            tp = tp+1;
        elseif ((Y_test(i) == 1) && (Y_true(i) == 0))
            fp = fp+1;
        elseif ((Y_test(i) == 0) && (Y_true(i) == 0))
            tn = tn+1;
        elseif ((Y_test(i) == 0) && (Y_true(i) == 1))
            fn = fn+1;
        else
            disp('error!!!');
        end
    end

    precision(o) = tp/(tp+fp);
    recall(o) = tp/(tp+fn);
end

figure()
plot(output_threshold, precision, 'bo-')
hold on
plot(output_threshold, recall, 'ro-')
plot(output_threshold, error, 'go-')
plot(output_threshold, number_predicted/max(number_predicted), 'mo-')
hold off
xlabel('output threshold')
ylabel('metric (%)')
legend('precision', 'recall', 'error', 'number predicted', 'location', 'best')
title('logistic regression ')
%%
figure()
plot(recall, precision, 'o')
xlabel('recall')
ylabel('precision')
%%
auc=colAUC(X_test,Y_test, 'algorithm', 'Wilcoxon', 'plot', false, 'abs', false);
out = [colLabel; num2cell(auc)];
disp(out); 

%% plot data for testing data
%{
%vehicle age (2)
%mmrcurrent auction avg price (9)
%warranty cost (17)
figure();
%plot3(X(N_train:N,2), X(N_train:N,10), X(N_train:N,17), 'o');
n_train = N_train(1);
temp = zeros(length(Y_true)-1, 3);
for i=1:length(Y_true)-1
    if(Y_true(i)==0)
        temp1(i,1) = X(n_train+i,2);
        temp1(i,2) = X(n_train+i,10);
        temp1(i,3) = X(n_train+i,17);
        %plot3(X(N_train+i,2), X(N_train+i,10), X(N_train+i,17));
        %plot(q1x(i,2),q1x(i,3),'rx');
    else
        temp2(i,1) = X(n_train+i,2);
        temp2(i,2) = X(n_train+i,10);
        temp2(i,3) = X(n_train+i,17);
        %plot3(X(N_train+i,2), X(N_train+i,10), X(N_train+i,17));
        %plot(q1x(i,2),q1x(i,3),'go');
    end
end
plot3(temp1(:,1), temp1(:,2), temp1(:,3), 'rx');
hold on;
plot3(temp2(:,1), temp2(:,2), temp2(:,3), 'go');
hold off;
xlabel('Vehicle Age (Years)');
ylabel('MMRCurrentAuctionAvgPrice (Dollars)');
zlabel('Warranty Cost (Dollars)');
grid on;
%}
%% run newton's method on the test data for submission onto Kaggle
[theta, ll] = logistic_newtons(X, Y, 10); % X, Y, max_iters
Y_Kaggle = sigmoid(Features_Test*theta);
Y_Kaggle(Y_Kaggle>=0.5) = 1;
Y_Kaggle(Y_Kaggle<0.5) = 0;
