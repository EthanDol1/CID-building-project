% Clear everything
clearvars; clc; close all

% Load data to be analyzed
opts = spreadsheetImportOptions("NumVariables", 15);
opts.Sheet = "Fall 2023";
opts.DataRange = "AC2:AQ151";
opts.VariableNames = ["q1","q2","q3","q4","q5","q6","q7","q8","q9","q10","q11","q12","q13","q14","q15"];
opts.VariableTypes = ["double","double","double","double","double","double","double","double","double","double","double","double","double","double","double"];
Data = readtable("C:\Users\13049\Desktop\matlab code\Research Code\building project\survey analyses\BUILD Survey Data_cleaned_4 semesters_master.xlsx", opts, "UseExcel", false);
dataF23 = table2array(Data);
clear opts
opts = spreadsheetImportOptions("NumVariables", 15);
opts.Sheet = "Spring 2024";
opts.DataRange = "AD2:AR127";
opts.VariableNames = ["q1","q2","q3","q4","q5","q6","q7","q8","q9","q10","q11","q12","q13","q14","q15"];
opts.VariableTypes = ["double","double","double","double","double","double","double","double","double","double","double","double","double","double","double"];
Data = readtable("C:\Users\13049\Desktop\matlab code\Research Code\building project\survey analyses\BUILD Survey Data_cleaned_4 semesters_master.xlsx", opts, "UseExcel", false);
dataS24 = table2array(Data);
clear opts
opts = spreadsheetImportOptions("NumVariables", 15);
opts.Sheet = "Fall 2024";
opts.DataRange = "AC2:AQ173";
opts.VariableNames = ["q1","q2","q3","q4","q5","q6","q7","q8","q9","q10","q11","q12","q13","q14","q15"];
opts.VariableTypes = ["double","double","double","double","double","double","double","double","double","double","double","double","double","double","double"];
Data = readtable("C:\Users\13049\Desktop\matlab code\Research Code\building project\survey analyses\BUILD Survey Data_cleaned_4 semesters_master.xlsx", opts, "UseExcel", false);
dataF24 = table2array(Data);
clear opts
opts = spreadsheetImportOptions("NumVariables", 15);
opts.Sheet = "Spring 2025";
opts.DataRange = "AC2:AQ117";
opts.VariableNames = ["q1","q2","q3","q4","q5","q6","q7","q8","q9","q10","q11","q12","q13","q14","q15"];
opts.VariableTypes = ["double","double","double","double","double","double","double","double","double","double","double","double","double","double","double"];
Data = readtable("C:\Users\13049\Desktop\matlab code\Research Code\building project\survey analyses\BUILD Survey Data_cleaned_4 semesters_master.xlsx", opts, "UseExcel", false);
dataS25 = table2array(Data);
clear opts

% Shape the data up to be analyzed via two Kruskal-Wallis tests, one two
% measure effect of room type, one to measure effect of semester

dataF23Use = [dataF23(:,1) dataF23(:,4) dataF23(:,7) dataF23(:,10) dataF23(:,13)];
dataS24Use = [dataS24(:,1) dataS24(:,4) dataS24(:,7) dataS24(:,10) dataS24(:,13)];
dataF24Use = [dataF24(:,1) dataF24(:,4) dataF24(:,7) dataF24(:,10) dataF24(:,13)];
dataS25Use = [dataS25(:,1) dataS25(:,4) dataS25(:,7) dataS25(:,10) dataS25(:,13)];

%dataF23Enc = [max(dataF23(:,2:3),[],2) max(dataF23(:,5:6),[],2) max(dataF23(:,8:9),[],2) max(dataF23(:,11:12),[],2) max(dataF23(:,14:15),[],2)];
%dataS24Enc = [max(dataS24(:,2:3),[],2) max(dataS24(:,5:6),[],2) max(dataS24(:,8:9),[],2) max(dataS24(:,11:12),[],2) max(dataS24(:,14:15),[],2)];
%dataF24Enc = [max(dataF24(:,2:3),[],2) max(dataF24(:,5:6),[],2) max(dataF24(:,8:9),[],2) max(dataF24(:,11:12),[],2) max(dataF24(:,14:15),[],2)];
%dataS25Enc = [max(dataS25(:,2:3),[],2) max(dataS25(:,5:6),[],2) max(dataS25(:,8:9),[],2) max(dataS25(:,11:12),[],2) max(dataS25(:,14:15),[],2)];

dataF23Enc = [dataF23(:,2) dataF23(:,5) dataF23(:,8) dataF23(:,11) dataF23(:,14)];
dataS24Enc = [dataS24(:,2) dataS24(:,5) dataS24(:,8) dataS24(:,11) dataS24(:,14)];
dataF24Enc = [dataF24(:,2) dataF24(:,5) dataF24(:,8) dataF24(:,11) dataF24(:,14)];
dataS25Enc = [dataS25(:,2) dataS25(:,5) dataS25(:,8) dataS25(:,11) dataS25(:,14)];

%%
% Aggregating all semester and performing kruskal wallis analysis of
% variance on room type

X = [dataF23Use(:,1), dataF23Use(:,2), dataF23Use(:,3), dataF23Use(:,4), dataF23Use(:,5);
     dataS24Use(:,1), dataS24Use(:,2), dataS24Use(:,3), dataS24Use(:,4), dataS24Use(:,5);
     dataF24Use(:,1), dataF24Use(:,2), dataF24Use(:,3), dataF24Use(:,4), dataF24Use(:,5);
     dataS25Use(:,1), dataS25Use(:,2), dataS25Use(:,3), dataS25Use(:,4), dataS25Use(:,5)];

[p, tbl, stats] = kruskalwallis(X);
c = multcompare(stats);

%%

% Stacked histogram
edges = 0.5:1:5.5;
h1 = histcounts(X(:,1),edges);
h1 = h1./sum(h1);
h2 = histcounts(X(:,2),edges);
h2 = h2./sum(h2);
h3 = histcounts(X(:,3),edges);
h3 = h3./sum(h3);
h4 = histcounts(X(:,4),edges);
h4 = h4./sum(h4);
h5 = histcounts(X(:,5),edges);
h5 = h5./sum(h5);
H = [h1;h2;h3;h4;h5];
colors = [
    0.2081 0.1663 0.5292   % deep blue
    0.1202 0.5216 0.7009   % blue-green
    0.1900 0.6930 0.5940   % green-cyan
    0.7060 0.7840 0.2880   % yellow-green
    0.9844 0.8344 0.2161   % yellow
];
figure
b = bar(H,'Stacked');
xticks([1 2 3 4 5])
xticklabels({'Comm. Assembly','Stairs','Elevators','Hallways','Bathrooms'})
xlabel('Room type','FontSize',25)
ylabel('Portion of respondents','FontSize',25)
title('Surveys responses on room type usage','FontSize',25)
legend('1','2','3','4','5','FontSize',20)
set(groot,"defaultAxesColorOrder",colors);
set(gcf,'PaperPosition',[0,0,8,5]); print('-dpng','stackdhist-survey-use.png')

%%

meanUsage = mean(X);
stdUsage = std(X);

figure
bar(meanUsage)
% hold on
% er = errorbar(1:length(meanUsage), meanUsage, stdUsage, stdUsage); 
% er.Color = [0 0 0];
% er.LineStyle = 'none';
% hold off
labels = {'A','B','C','D','E'};
for i = 1:length(meanUsage)
    text(i-0.2, meanUsage(i) + 0.1, labels{i}, ...
         'HorizontalAlignment','center', ...
         'VerticalAlignment','bottom', ...
         'FontSize',12, 'FontWeight','bold')
end
text(0.25,4.5, "A<B<C<E<D")
ylim([1 5])
xticklabels({'Comm. Assembly','Stairs','Elevators','Hallways','Bathrooms'})
xlabel('Room type')
ylabel('Average survey rating')
title('Average usage rating of different room types by survey respondents')


%%
% Aggregating all semesters and performing kruskal wallis test on variance
% of room type

X = [dataF23Enc(:,1), dataF23Enc(:,2), dataF23Enc(:,3), dataF23Enc(:,4), dataF23Enc(:,5);
     dataS24Enc(:,1), dataS24Enc(:,2), dataS24Enc(:,3), dataS24Enc(:,4), dataS24Enc(:,5);
     dataF24Enc(:,1), dataF24Enc(:,2), dataF24Enc(:,3), dataF24Enc(:,4), dataF24Enc(:,5);
     dataS25Enc(:,1), dataS25Enc(:,2), dataS25Enc(:,3), dataS25Enc(:,4), dataS25Enc(:,5)];

[p, tbl, stats] = kruskalwallis(X);
c = multcompare(stats);

%%

% Stacked histogram
edges = 0.5:1:5.5;
h1 = histcounts(X(:,1),edges);
h1 = h1./sum(h1);
h2 = histcounts(X(:,2),edges);
h2 = h2./sum(h2);
h3 = histcounts(X(:,3),edges);
h3 = h3./sum(h3);
h4 = histcounts(X(:,4),edges);
h4 = h4./sum(h4);
h5 = histcounts(X(:,5),edges);
h5 = h5./sum(h5);
H = [h1;h2;h3;h4;h5];
colors = [
    0.2081 0.1663 0.5292   % deep blue
    0.1202 0.5216 0.7009   % blue-green
    0.1900 0.6930 0.5940   % green-cyan
    0.7060 0.7840 0.2880   % yellow-green
    0.9844 0.8344 0.2161   % yellow
];
figure
bar(H,'Stacked')
xticks([1 2 3 4 5])
xticklabels({'Comm. Assembly','Stairs','Elevators','Hallways','Bathrooms'})
xlabel('Room type','FontSize',25)
ylabel('Portion of respondents','FontSize',25)
title('Surveys responses on room type collisions','FontSize',25)
legend('1','2','3','4','5','FontSize',20)
set(groot,"defaultAxesColorOrder",colors);
set(gcf,'PaperPosition',[0,0,8,5]); print('-dpng','stackdhist-survey-enc.png')

%%

meanEnc = mean(X);
stdEnc = std(X);

figure
bar(meanEnc)
% hold on
% er = errorbar(1:length(meanEnc), meanEnc, stdEnc, stdEnc); 
% er.Color = [0 0 0];
% er.LineStyle = 'none';
% hold off
labels = {'A','B','A','C','D'};
for i = 1:length(meanEnc)
    text(i-0.2, meanEnc(i) + 0.1, labels{i}, ...
         'HorizontalAlignment','center', ...
         'VerticalAlignment','bottom', ...
         'FontSize',12, 'FontWeight','bold')
end
text(0.25,4.75, "B<A<C<D")
ylim([1 5])
xticklabels({'Comm. Assembly','Stairs','Elevators','Hallways','Bathrooms'})
xlabel('Room type')
ylabel('Average survey rating')
title('Average encounter rating of different room types by survey respondents')