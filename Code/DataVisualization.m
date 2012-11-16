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
    title(strcat({'Scaled histogram of '},Labels_Train{i}));
    xlabel(Labels_Train{i});
    ylabel('Relative Frequency');
    legend('Good','Bad');
    saveas(gcf, strcat('..\Plots\HistogramScaled\HistogramScaled_',Labels_Train{i}), 'png')
    close;
end

%% Ratio Histograms
for i = 1:n
    edges = linspace(min(Features_Train(:,i)),max(Features_Train(:,i)),10);
    G = histc(Good(:,i),edges);
    B = histc(Bad(:,i),edges);
    figure;
    hold on;
    bar(edges,(B*factor)./G,1);
    plot(linspace(min(Features_Train(:,i)),max(Features_Train(:,i))),1,'r');
    title(strcat({'Histogram Ratio (Bad/Good) of '},Labels_Train{i}));
    xlabel(Labels_Train{i});
    ylabel('Bad/Good');
    saveas(gcf, strcat('..\Plots\HistogramRatio\HistogramRatio_',Labels_Train{i}), 'png')
    close;
end
