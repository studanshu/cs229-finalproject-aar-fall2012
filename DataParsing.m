% CS 229 Final Project
% 
% Data Parsing Script
% Coded by:
%   Robert Romano
%   Albert Ho
%   Alice Wu
clear;
clc;
close all;

% Is this run for the test or training set?
%   1-Training Set, 0-Test Set
Set = 1;

% Read in the appropriate data set from the excel sheets
if Set == 1
    [Numeric,Txt,Raw] = xlsread('training.xlsx');
else
    [Numeric,Txt,Raw] = xlsread('test.xlsx');
end

%%
clc;

% Setting up variables for easier manipulation
M = size(Numeric,1);
N = size(Numeric,2);
Labels = cell(N,1);
for i = 1:N
    Labels{i,1} = Txt{1,i};
end
ParsedData = Numeric;

% Columns of data that will be knocked out of the data set
Knockout = [1,3:4,7:12,14,16:18,27:28,31];
if Set == 0
    Knockout = Knockout - 1;
    Knockout(1) = 1;
end

% Identifiers for particular columns 
WhTyID = 13;    % Wheel Type ID
MMR = 19:26;    % All MMR values
if Set == 0
    WhTyID = WhTyID -1;    
    MMR = MMR -1;
end

% Convert Dates into Day, Month, and Year
% ParsedData(:,N+1) = zeros(M,1);
% Knockout = [Knockout, 3];

% Replace empty values in WheelTypeID column with 4's
ParsedData(isnan(ParsedData(:,WhTyID)),WhTyID) = 4;

% Replace all empty MMR values with the average value across all samples
for i = MMR
    MMRAvg = mean(ParsedData(~isnan(ParsedData(:,i)),i));
    ParsedData(isnan(ParsedData(:,i)),i) = MMRAvg;
end

% Take out Knocked out labels and data columns, leaving data to be used
%   and the final group of labels
Knockout = fliplr(Knockout);
for i = Knockout
    Labels{i} = {};
    ParsedData(:,i) = [];
end
TempLabel = Labels;
Labels = cell(N-length(Knockout),1);
index = 1;
for i = 1:N
    if (isempty(TempLabel{i})==0)
        Labels{index} = TempLabel{i};
        index = index + 1;
    end
end

%%
if Set == 1
    Labels_Train = Labels;
    Features_Train = ParsedData;
    keep('Labels_Train','Features_Train','Set');
else
    Labels_Test = Labels;
    Features_Test = ParsedData;
    keep('Labels_Test','Features_Test','Set');
end

if Set == 1
    clear('Set');
    save('CarAuction_Parsed_Train');
else
    clear('Set');
    save('CarAuction_Parsed_Test');
end

    