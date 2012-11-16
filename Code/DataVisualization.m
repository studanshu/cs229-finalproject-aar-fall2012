% Data Visualization
clear all;
close all;

load CarAuction_Parsed_Train.mat;

%% Separate Data into Good and Bad
[m,n] = size(Features_Train);
TrainSorted = sortrows(Features_Train,1);

for i = 1:m
    if (TrainSorted(i,1) == 1)
        break;
    end
end

Good = TrainSorted(1:i-1,:);
Bad = TrainSorted(i:end,:);

%% Histograms
factor = length(Good)/length(Bad);

for i = 1:n
    edges = linspace(min(Features_Train(:,i)),max(Features_Train(:,i)),10);
    G = histc(Good(:,i),edges);
    B = histc(Bad(:,i),edges);
    figure;
    hold on;
    bar(edges,[G,B*factor],1);
    title(Labels_Train{i});
    legend('Good','Bad');
    saveas(gcf, strcat('..\Plots\Histogram_',Labels_Train{i}), 'png')
    close;
end