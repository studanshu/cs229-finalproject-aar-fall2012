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

% Booboo Style
[Numeric,Txt,Raw] = xlsread('../../CarAuction_Parsed_Train_Train_Str.csv');

Y_train = Numeric(:,1);
X_train = Numeric(:,2:end);

for feature = size(Numeric,2)+1:size(Raw,2)
    for sample = 2:size(Raw,1)
        Raw_mat = cell2mat(Raw(sample,feature));
        X_train(sample-1,feature-1) = str2double(Raw_mat(2:end));
    end
end

for feature = 1:size(Raw,2)-1
    X_train(:,feature) = X_train(:,feature) - min(X_train(:,feature));
    X_train(:,feature) = X_train(:,feature)/max(X_train(:,feature));
end

[Numeric,Txt,Raw] = xlsread('../../CarAuction_Parsed_Train_Test_Str.csv');

Y_true = Numeric(:,1);
X_test = Numeric(:,2:end);

for feature = size(Numeric,2)+1:size(Raw,2)
    for sample = 2:size(Raw,1)
        Raw_mat = cell2mat(Raw(sample,feature));
        X_test(sample-1,feature-1) = str2double(Raw_mat(2:end));
    end
end

for feature = 1:size(Raw,2)-1
    X_test(:,feature) = X_test(:,feature) - min(X_test(:,feature));
    X_test(:,feature) = X_test(:,feature)/max(X_test(:,feature));
end

% % balance data
% % Repeat positive examples so that there is a more even distribution
% balance = 0;
% if (balance == 0)
%     X_positive = X_train(Y_train==1,:);
%     Y_positive = ones(size(X_positive,1),1);
%     N_positive = (length(Y_train)-length(Y_positive))/length(Y_positive);
%     N_pos_mod = mod(length(Y_train)-length(Y_positive),length(Y_positive));
%     for i = 1:(floor(N_positive)-1)
%         X_train = [X_train; X_positive];
%         Y_train = [Y_train; Y_positive];
%     end
%     X_train = [X_train; X_positive(1:N_pos_mod,:)];
%     Y_train = [Y_train; Y_positive(1:N_pos_mod)];
%     clear('X_positive','Y_positive','N_positive','N_pos_mod');
%     balance = 1;
% end

Train = [X_train Y_train];
Test = [X_test Y_true];
%%
prediction = RUSBoost(Train,Test,'tree');

