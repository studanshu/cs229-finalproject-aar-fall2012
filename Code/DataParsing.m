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

%% Import Data

% Is this run for the test or training set?
%   1-Training Set, 0-Test Set
Set = 0;

% converts dates to datenum format
if Set == 1
    [Numeric, Txt, Raw, dateNums] = xlsread('training.csv','training','','',@convertSpreadsheetDates);
else
    [Numeric, Txt, Raw, dateNums] = xlsread('test.csv','test','','',@convertSpreadsheetDates);
end
%% Numeric Data Parsing
% Set up variables for easier manipulation
[m,n] = size(Numeric);
Labels = cell(n,1);
for i = 1:n
    Labels{i,1} = Txt{1,i};
end
ParsedData = Numeric;

% Columns of data containing non-numeric or irrelevant data that will be knocked out of the data set
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
Labels = cell(n-length(Knockout),1);
index = 1;
for i = 1:n
    if (isempty(TempLabel{i})==0)
        Labels{index} = TempLabel{i};
        index = index + 1;
    end
end

%% Non-Numeric Data Parsing

% Generate year, month, and day features
% Replace date strings by MATLAB datenums
% R = ~cellfun(@isequalwithequalnans,dateNums,raw) & cellfun('isclass',raw,'char'); % Find Excel dates
% raw(R) = dateNums(R);

if Set == 1
    dateNumVec = dateNums(2:end,3);
else
    dateNumVec = dateNums(2:end,2);
end
dateNumVec = cell2mat(dateNumVec);
[year month day] = datevec(dateNumVec);

ParsedData = [ParsedData year month day];
Labels{end+1} = 'Year';
Labels{end+1} = 'Month';
Labels{end+1} = 'Day';

% % Replace specified string with 1.0
% R = cellfun(@(x) ischar(x) && strcmp(x,'MAZDA'),raw); % Find non-numeric cells
% raw(R) = {1.0}; % Replace non-numeric cells
% 
% % Replace non-numeric cells with 0.0
% R = cellfun(@(x) ~isnumeric(x) || isnan(x),raw); % Find non-numeric cells
% raw(R) = {0.0}; % Replace non-numeric cells
% 
% % Create output variables
% Numeric = cell2mat(raw);

% Clear temporary variables
% clearvars raw dateNums R;

%% Clean Up and Save Parsed Data
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

    