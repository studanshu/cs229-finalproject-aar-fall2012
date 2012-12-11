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
    Txt(2:end,30) = cellstr(num2str(Numeric(:,30)));
else
    [Numeric, Txt, Raw, dateNums] = xlsread('test.csv','test','','',@convertSpreadsheetDates);
    Txt(2:end,29) = cellstr(num2str(Numeric(:,29)));
end
%% Numeric Data Parsing
% Set up variables for easier manipulation
[m,n] = size(Numeric);
Labels = cell(n,1);
for i = 1:n
    Labels{i,1} = Txt{1,i};
end
ParsedData = Numeric;

IsOnlineSale = ParsedData(:,33);

% Columns of data containing non-numeric or irrelevant data that will be knocked out of the data set
Knockout = [1,3:4,7:14,16:18,27:29,30,31,33];
if Set == 0
    Knockout = Knockout - 1;
    Knockout(1) = 1;
end

% Identifiers for particular columns 
MMR = 19:26;    % All MMR values
if Set == 0
    MMR = MMR -1;
end

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

% Normalize numeric data
mins = min(ParsedData);
maxes = max(ParsedData);
mins_expand = repmat(mins,size(ParsedData,1),1);
ranges = maxes - mins;
ranges_expand = repmat(ranges,size(ParsedData,1),1);
ParsedData = ParsedData - mins_expand;
ParsedData = ParsedData./ranges_expand;

% Create category labels
TempLabel = Labels;
Labels = cell(n-length(Knockout),1);
index = 1;
for i = 1:n
    if (isempty(TempLabel{i})==0)
        Labels{index} = TempLabel{i};
        index = index + 1;
    end
end

%% Date Parsing
% 
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
dateData = [year month day];

% year = year - min(year);

% Normalize data
mins = min(dateData);
maxes = max(dateData);
mins_expand = repmat(mins,size(dateData,1),1);
ranges = maxes - mins;
ranges_expand = repmat(ranges,size(dateData,1),1);
dateData = dateData - mins_expand;
dateData = dateData./ranges_expand;

% % normalize data
% year = year./max(year);
% month = month./max(month);
% day = day./max(day);

ParsedData = [ParsedData dateData];
Labels{end+1} = 'PurchYear';
Labels{end+1} = 'PurchMonth';
Labels{end+1} = 'PurchDay';

%% Non-Numeric Data Parsing
% load('Txt.mat');
% keep('TxtB');
% Txt = TxtB;

% Remove empty columns from Txt
Knockout = [1:3,5:6,13,15,19:26,29,32:34];
if Set == 0
    Knockout = Knockout - 1;
    Knockout = Knockout(2:end);
end
Knockout = fliplr(Knockout);
for i = Knockout
    Txt(:,i) = [];
end

% Add IsOnlineSale
% IsOnlineSale = num2cell(IsOnlineSale);
% IsOnlineSale = num2str(IsOnlineSale);
IsOnlineSale = cellstr(num2str(IsOnlineSale(:)));
IsOnlineSale = ['IsOnlineSale'; IsOnlineSale];
Txt = [Txt IsOnlineSale];

% Enumerate unique strings and replace them with enumeration
for i = 1:size(Txt,2)
    newParsed = enumText(Txt(2:end,i));
    ParsedData = [ParsedData newParsed];
    Labels(end+1) = Txt(1,i);
end

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

    