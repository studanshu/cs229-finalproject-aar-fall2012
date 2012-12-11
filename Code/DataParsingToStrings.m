%% Setup
close all;
clear all;

% Is this run for the test or training set?
%   1-Training Set, 0-Test Set
Set = 0;

if Set == 1
    load('CarAuction_Parsed_Train.mat');
    data = Labels_Train';
    data = [data; num2cell(Features_Train)];
    start = 15;
else
    load('CarAuction_Parsed_Test.mat');
    data = Labels_Test';
    data = [data; num2cell(Features_Test)];
    start = 14;
end
    
%% Replace isBadBuy with true/false
if Set == 1
    for i = 2:size(data,1)
        if data{i,1} == 0
            data{i,1} = 'false';
        else
            data{i,1} = 'true';
        end
    end
end

%% Replace rest of categorical dataset
for i = 2:size(data,1)
    for j = start:size(data,2)
        data{i,j} = strcat('a', num2str(data{i,j}));
    end
end

%% Write to CSV
if Set == 1
    cell2csv('CarAuction_Parsed_Train_Str.csv',data);
else
    cell2csv('CarAuction_Parsed_Test_Str.csv',data);
end