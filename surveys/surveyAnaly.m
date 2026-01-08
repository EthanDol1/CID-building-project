clearvars; clc; close all
format short

% Loading all data
opts = spreadsheetImportOptions("NumVariables", 15);
opts.Sheet = "Fall 2023";
opts.DataRange = "AC2:AQ151";
opts.VariableNames = ["q1","q2","q3","q4","q5","q6","q7","q8","q9","q10","q11","q12","q13","q14","q15"];
opts.VariableTypes = ["double","double","double","double","double","double","double","double","double","double","double","double","double","double","double"];
Data = readtable("C:\Users\13049\Desktop\matlab code\Research Code\survey analyses\BUILD Survey Data_cleaned_4 semesters_master.xlsx", opts, "UseExcel", false);
dataF23 = table2array(Data);
clear opts
opts = spreadsheetImportOptions("NumVariables", 15);
opts.Sheet = "Spring 2024";
opts.DataRange = "AD2:AR127";
opts.VariableNames = ["q1","q2","q3","q4","q5","q6","q7","q8","q9","q10","q11","q12","q13","q14","q15"];
opts.VariableTypes = ["double","double","double","double","double","double","double","double","double","double","double","double","double","double","double"];
Data = readtable("C:\Users\13049\Desktop\matlab code\Research Code\survey analyses\BUILD Survey Data_cleaned_4 semesters_master.xlsx", opts, "UseExcel", false);
dataS24 = table2array(Data);
clear opts
opts = spreadsheetImportOptions("NumVariables", 15);
opts.Sheet = "Fall 2024";
opts.DataRange = "AC2:AQ173";
opts.VariableNames = ["q1","q2","q3","q4","q5","q6","q7","q8","q9","q10","q11","q12","q13","q14","q15"];
opts.VariableTypes = ["double","double","double","double","double","double","double","double","double","double","double","double","double","double","double"];
Data = readtable("C:\Users\13049\Desktop\matlab code\Research Code\survey analyses\BUILD Survey Data_cleaned_4 semesters_master.xlsx", opts, "UseExcel", false);
dataF24 = table2array(Data);
clear opts
opts = spreadsheetImportOptions("NumVariables", 15);
opts.Sheet = "Spring 2025";
opts.DataRange = "AC2:AQ117";
opts.VariableNames = ["q1","q2","q3","q4","q5","q6","q7","q8","q9","q10","q11","q12","q13","q14","q15"];
opts.VariableTypes = ["double","double","double","double","double","double","double","double","double","double","double","double","double","double","double"];
Data = readtable("C:\Users\13049\Desktop\matlab code\Research Code\survey analyses\BUILD Survey Data_cleaned_4 semesters_master.xlsx", opts, "UseExcel", false);
dataS25 = table2array(Data);
clear opts
%%

% Analysing the data

% Fall 2023

affirmativeEncF23 = dataF23(:,2:3)>3;
nonSequitors = (affirmativeEncF23(:,1) == 0) & (affirmativeEncF23(:,2) == 1);
encF23 = affirmativeEncF23(:,1)|affirmativeEncF23(:,2);
percEncCommAss = encF23/numel(encF23);

function A = getEncData(data,threshold)
    encCA = data(:,2)>=threshold|data(:,3)>=threshold;
    peCA = sum(encCA)/numel(encCA);
    encS = data(:,5)>=threshold|data(:,6)>=threshold;
    peS = sum(encS)/numel(encS);
    encE = data(:,8)>=threshold|data(:,9)>=threshold;
    peE = sum(encE)/numel(encE);
    encH = data(:,11)>=threshold|data(:,12)>=threshold;
    peH = sum(encH)/numel(encH);
    encB = data(:,14)>=threshold|data(:,15)>=threshold;
    peB = sum(encB)/numel(encB);
    numRespondents = size(data, 1);
    A = [peCA, peS, peE, peH, peB, numRespondents, numel(encB)];
end

function s = weightedStd(x, w)
    mu = sum(w .* x) / sum(w);
    s = sqrt( sum(w .* (x - mu).^2) / sum(w) );
end

encF23 = getEncData(dataF24,4);
encS24 = getEncData(dataS24,4);
encF24 = getEncData(dataF24,4);
encS25 = getEncData(dataS25,4);
%%
labels = ["Comm. Assembly","Stairs","Elevators","Hallways","Bathrooms"];
[sortedEncF23,index] = sort(encF23(1:5));
sortedLabelsF23 = labels(index);
[sortedEncS24,index] = sort(encS24(1:5));
sortedLabelsS24 = labels(index);
[sortedEncF24,index] = sort(encF24(1:5));
sortedLabelsF24 = labels(index);
[sortedEncS25,index] = sort(encS25(1:5));
sortedLabelsS25 = labels(index);
%%
ca = [encF23(1) encS24(1) encF24(1) encS25(1)];
s = [encF23(2) encS24(2) encF24(2) encS25(2)];
e = [encF23(3) encS24(3) encF24(3) encS25(3)];
h = [encF23(4) encS24(4) encF24(4) encS25(4)];
b = [encF23(5) encS24(5) encF24(5) encS25(5)];
w = [encF23(6) encS24(6) encF24(6) encS25(6)];

meanData = [mean(ca) mean(s) mean(e) mean(h) mean(b)];
weightedMeanData = [sum(ca.*w)/sum(w) sum(s.*w)/sum(w) sum(e.*w)/sum(w) sum(h.*w)/sum(w) sum(b.*w)/sum(w)];
[sortedMeanData,index] = sort(meanData);
sortedLabels = labels(index);
stdData = [std(ca) std(s) std(e) std(h) std(b)];
sortedStdData = stdData(index);
[sortedWeightedMeanData, index] = sort(weightedMeanData);
sortedWeightedLabels = labels(index);
weightedStdData = [weightedStd(ca,w) weightedStd(s,w) weightedStd(e,w) weightedStd(h,w) weightedStd(b,w)];
sortedWeightedStdData = weightedStdData(index);
%%
figure
bar(sortedMeanData)
hold on
errorbar(sortedMeanData, sortedStdData, 'k', 'linestyle', 'none')
hold off
xticklabels(sortedLabels)
ylim([0 1])
title("Average Encounter Data (Surveys)")
ylabel("Proportion of respondents encountering other often")
xlabel("Patterns")
%%
figure
bar(sortedWeightedMeanData*100)
hold on
errorbar(sortedWeightedMeanData*100, sortedWeightedStdData*100, 'k', 'linestyle', 'none')
hold off
xticklabels(sortedWeightedLabels)
ylim([0 100])
title("Weighted Average Encounter Data (Surveys)")
ylabel("% Respondents encountering other often")
xlabel("Patterns")

%%
figure
bar(100*sortedEncF23(1:5))
ylim([0 100])
title("Fall 2023 CID Survey Data (Encounters)")
ylabel("% Respondents often acknowledging others")
xticklabels(sortedLabelsF23)
figure
bar(100*sortedEncS24(1:5))
ylim([0 100])
title("Spring 2024 CID Survey Data (Encounters)")
ylabel("% Respondents often acknowledging others")
xticklabels(sortedLabelsS24)
figure
bar(100*sortedEncF24(1:5))
ylim([0 100])
title("Fall 2024 CID Survey Data (Encounters)")
ylabel("% Respondents often acknowledging others")
xticklabels(sortedLabelsF24)
figure
bar(100*sortedEncS25(1:5))
ylim([0 100])
title("Spring 2025 CID Survey Data (Encounters)")
ylabel("% Respondents often acknowledging others")
xticklabels(sortedLabelsS25)

%%
ca = [encF23(1), encS24(1), encF24(1), encS25(1)]*100; % should I weight these according to the number of respondents????
s = [encF23(2), encS24(2), encF24(2), encS25(2)]*100;
e = [encF23(3), encS24(3), encF24(3), encS25(3)]*100;
h = [encF23(4), encS24(4), encF24(4), encS25(4)]*100;
b = [encF23(5), encS24(5), encF24(5), encS25(5)]*100;

% Prepare data for plotting
data = [mean(ca) mean(s) mean(e) mean(h) mean(b)];
[sortedData, indices] = sort(data);
sortedErrors = [std(b) std(s) std(e) std(ca) std(h)];
sortedLabels = {"Bathrooms", "Stairs", "Elevators", "Halls", "Comm. Assembly"};

% Create a bar plot with error bars
figure
bar(sortedData)
hold on
errorbar(sortedData, sortedErrors, 'k', 'linestyle', 'none')
ylim([0 100])
title("Average Encounters with Error Bars (sorted)")
ylabel("% Respondents often acknowledging others")
xticklabels(sortedLabels)
hold off

%% Now looking at use data

function A = getUseData(data,threshold)
    if threshold > 5 || threshold < 1
        disp('Error! Threshold must be either 1, 2, 3, 4, or 5!')
    else
        useCA = sum(data(:,1)>=threshold)/numel(data(:,1));
        useS = sum(data(:,4)>=threshold)/numel(data(:,1));
        useE = sum(data(:,7)>=threshold)/numel(data(:,1));
        useH = sum(data(:,10)>=threshold)/numel(data(:,1));
        useB = sum(data(:,13)>=threshold)/numel(data(:,1));
        numRespondents = size(data, 1);
        A = [useCA, useS, useE, useH, useB, numRespondents];
    end
end

useF23 = getUseData(dataF23,4);
useS24 = getUseData(dataS24,4);
useF24 = getUseData(dataF24,4);
useS25 = getUseData(dataS25,4);
%%
ca = [useF23(1), useS24(1), useF24(1), useS25(1)]; % should I weight these according to the number of respondents????
s = [useF23(2), useS24(2), useF24(2), useS25(2)];
e = [useF23(3), useS24(3), useF24(3), useS25(3)];
h = [useF23(4), useS24(4), useF24(4), useS25(4)];
b = [useF23(5), useS24(5), useF24(5), useS25(5)];

w = [useF23(6) useS24(6) useF24(6) useS25(6)];

% Prepare data for plotting
weightedData = [sum(ca.*w)/sum(w) sum(s.*w)/sum(w) sum(e.*w)/sum(w) sum(h.*w)/sum(w) sum(b.*w)/sum(w)];
% data = [mean(ca) mean(s) mean(e) mean(h) mean(b)];
data = useS25(1:5)*100;
[sortedData, indices] = sort(data);
% sortedData is [ca s e b h]
%%
sortedWeightedErrors = [weightedStd(ca,w) weightedStd(s,w) weightedStd(e,w) weightedStd(b,w) weightedStd(h,w)];
sortedErrors = [std(ca) std(s) std(e) std(b) std(h)];
%%
sortedLabels = ["Comm. Assembly", "Stairs", "Elevators", "Bathrooms", "Hallways"];

% Create a bar plot with error bars
fig = figure;
bar(sortedData)
hold on
% errorbar(sortedData, sortedErrors, 'k', 'linestyle', 'none')
ylim([0 100])
title("Average Usage with Error Bars (sorted)")
ylabel("% Respondents often using pattern")
xticklabels(sortedLabels)
hold off
%%
