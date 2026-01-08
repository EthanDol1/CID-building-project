% Clear everything
clearvars; clc; close all
%%
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
%%

% Shape the data up to be analyzed via two Kruskal-Wallis tests, one two
% measure effect of room type, one to measure effect of semester

dataF23Use = [dataF23(:,1) dataF23(:,4) dataF23(:,7) dataF23(:,10) dataF23(:,13)];
dataS24Use = [dataS24(:,1) dataS24(:,4) dataS24(:,7) dataS24(:,10) dataS24(:,13)];
dataF24Use = [dataF24(:,1) dataF24(:,4) dataF24(:,7) dataF24(:,10) dataF24(:,13)];
dataS25Use = [dataS25(:,1) dataS25(:,4) dataS25(:,7) dataS25(:,10) dataS25(:,13)];

dataF23Enc = [max(dataF23(:,2:3),[],2) max(dataF23(:,5:6),[],2) max(dataF23(:,8:9),[],2) max(dataF23(:,11:12),[],2) max(dataF23(:,14:15),[],2)];
dataS24Enc = [max(dataS24(:,2:3),[],2) max(dataS24(:,5:6),[],2) max(dataS24(:,8:9),[],2) max(dataS24(:,11:12),[],2) max(dataS24(:,14:15),[],2)];
dataF24Enc = [max(dataF24(:,2:3),[],2) max(dataF24(:,5:6),[],2) max(dataF24(:,8:9),[],2) max(dataF24(:,11:12),[],2) max(dataF24(:,14:15),[],2)];
dataS25Enc = [max(dataS25(:,2:3),[],2) max(dataS25(:,5:6),[],2) max(dataS25(:,8:9),[],2) max(dataS25(:,11:12),[],2) max(dataS25(:,14:15),[],2)];

%%

% Use analysis

% First, Kruskal Wallis keeping room type fixed and varying semester.

% Start with community assembly. Use first column of each use data matrix.
% First, we'll get a look at the plots.

bins = 0.5:1:5.5;
figure
h1 = histcounts(dataF23Use(:,1),bins);
h2 = histcounts(dataS24Use(:,1),bins);
h3 = histcounts(dataF24Use(:,1),bins);
h4 = histcounts(dataS25Use(:,1),bins);
x = bins(1:end-1) + 0.5;
plot(x, h1, '-o', x, h2, '-o', x, h3, '-s', x, h4, '-s')
legend('Fall 23', 'Spring 24', 'Fall 24', 'Spring 25')
xlabel('Rating')
ylabel('Counts')
title('Distribution of usage rating of comm. assembly across semesters')
grid on

groups = {dataF23Use(:,1), dataS24Use(:,1), dataF24Use(:,1), dataS25Use(:,1)};

% Find the maximum length
maxLen = max(cellfun(@length, groups));

% Pad each group with NaN to max length
X = NaN(maxLen, numel(groups));   % preallocate
for i = 1:numel(groups)
    X(1:length(groups{i}), i) = groups{i};
end

[p, tbl, stats] = kruskalwallis(X);
c = multcompare(stats);

% Conclusion: No significant difference (p = 0.7206) for reported community assembly usage when varying
% semester.

%%
% Stairs.

groups = {dataF23Use(:,2), dataS24Use(:,2), dataF24Use(:,2), dataS25Use(:,2)};

% Find the maximum length
maxLen = max(cellfun(@length, groups));

% Pad each group with NaN to max length
X = NaN(maxLen, numel(groups));   % preallocate
for i = 1:numel(groups)
    X(1:length(groups{i}), i) = groups{i};
end

[p, tbl, stats] = kruskalwallis(X);
c = multcompare(stats);

% Conclusion: There is a significant difference (p = 0.0023) for reported stairs
% usage when varying semester. Groups: A: F23, S25; B: S24, F24, S25

% We can look at the plots.

bins = 0.5:1:5.5;
figure
h1 = histcounts(dataF23Use(:,2),bins);
h2 = histcounts(dataS24Use(:,2),bins);
h3 = histcounts(dataF24Use(:,2),bins);
h4 = histcounts(dataS25Use(:,2),bins);
x = bins(1:end-1) + 0.5;
plot(x, h1, '-o', x, h2, '-o', x, h3, '-s', x, h4, '-s')
legend('Fall 23', 'Spring 24', 'Fall 24', 'Spring 25')
xlabel('Rating')
ylabel('Counts')
title('Distribution of usage rating of stairs across semesters')
grid on

%%
uf23 = [dataF23Use(:,1); dataF23Use(:,2); dataF23(:,3); dataF23Use(:,4); dataF23Use(:,5)];
us24 = [dataS24Use(:,1); dataS24Use(:,2); dataS24(:,3); dataS24Use(:,4); dataS24Use(:,5)];
uf24 = [dataF24Use(:,1); dataF24Use(:,2); dataF24(:,3); dataF24Use(:,4); dataF24Use(:,5)];
us25 = [dataS25Use(:,1); dataS25Use(:,2); dataS25(:,3); dataS25Use(:,4); dataS25Use(:,5)];

groups = {uf23, us24, uf24, us25};

% Find the maximum length
maxLen = max(cellfun(@length, groups));

% Pad each group with NaN to max length
X = NaN(maxLen, numel(groups));   % preallocate
for i = 1:numel(groups)
    X(1:length(groups{i}), i) = groups{i};
end

[p, tbl, stats] = kruskalwallis(X);
c = multcompare(stats);

bins = 0.5:1:5.5;
figure
h1 = histcounts(dataF23Use(:,2),bins);
h2 = histcounts(dataS24Use(:,2),bins);
h3 = histcounts(dataF24Use(:,2),bins);
h4 = histcounts(dataS25Use(:,2),bins);
x = bins(1:end-1) + 0.5;
plot(x, h1, '-o', x, h2, '-o', x, h3, '-s', x, h4, '-s')
legend('Fall 23', 'Spring 24', 'Fall 24', 'Spring 25')
xlabel('Rating')
ylabel('Counts')
title('Distribution of usage rating of stairs across semesters')
grid on


%%
% Elevators.

groups = {dataF23Use(:,3), dataS24Use(:,3), dataF24Use(:,3), dataS25Use(:,3)};

% Find the maximum length
maxLen = max(cellfun(@length, groups));

% Pad each group with NaN to max length
X = NaN(maxLen, numel(groups));   % preallocate
for i = 1:numel(groups)
    X(1:length(groups{i}), i) = groups{i};
end

[p, tbl, stats] = kruskalwallis(X);
c = multcompare(stats);

% Conclusion: There is a significant difference (p = 0.0032) for reported
% elevator usage when varying semester. Groups: A: F23; B: S24, F24, S25

%%
% Hallways.

groups = {dataF23Use(:,4), dataS24Use(:,4), dataF24Use(:,4), dataS25Use(:,4)};

% Find the maximum length
maxLen = max(cellfun(@length, groups));

% Pad each group with NaN to max length
X = NaN(maxLen, numel(groups));   % preallocate
for i = 1:numel(groups)
    X(1:length(groups{i}), i) = groups{i};
end

[p, tbl, stats] = kruskalwallis(X);
c = multcompare(stats);

% Conclusion: No significant difference (p = 0.8116) for reported hallway usage usage when varying
% semester.

%%
% Bathrooms.

groups = {dataF23Use(:,5), dataS24Use(:,5), dataF24Use(:,5), dataS25Use(:,5)};

% Find the maximum length
maxLen = max(cellfun(@length, groups));

% Pad each group with NaN to max length
X = NaN(maxLen, numel(groups));   % preallocate
for i = 1:numel(groups)
    X(1:length(groups{i}), i) = groups{i};
end

[p, tbl, stats] = kruskalwallis(X);
c = multcompare(stats);

% Conclusion: No significant difference (p = 0.8279) for reported bathroom
% usage when varying across semester.

%%

% Second, Kruskal-Wallis keeping semester fixed and varying room type.

% Start with F23.

X = [dataF23Use(:,1), dataF23Use(:,2), dataF23Use(:,3), dataF23Use(:,4), dataF23Use(:,5)];

[p, tbl, stats] = kruskalwallis(X);
c = multcompare(stats);

% Conclusion: There is a significant difference (p = 2.28208e-45) for
% reported F23 usage when varying room type. Groups: A: Comm. Assembly; B:
% Stairs, Elevators; C: Bathrooms; D: Hallways

%%
% S24

X = [dataS24Use(:,1), dataS24Use(:,2), dataS24Use(:,3), dataS24Use(:,4), dataS24Use(:,5)];

[p, tbl, stats] = kruskalwallis(X);
c = multcompare(stats);

% Conclusion: There is a significant difference (p = 1.26654e-37) for
% reported S24 usage when varying room type. Groups: A: Comm. Assembly; B:
% Stairs; C: Elevators, Bathrooms; D: Hallways

%%
% F24

X = [dataF24Use(:,1), dataF24Use(:,2), dataF24Use(:,3), dataF24Use(:,4), dataF24Use(:,5)];

[p, tbl, stats] = kruskalwallis(X);
c = multcompare(stats);

% Conclusion: There is a significant difference (p = 5.95288e-65) for
% reported S24 usage when varying room type. Groups: A: Comm. Assembly; B:
% Stairs; C: Elevators, Bathrooms; D: Hallways

%%
% S25

X = [dataS25Use(:,1), dataS25Use(:,2), dataS25Use(:,3), dataS25Use(:,4), dataS25Use(:,5)];

[p, tbl, stats] = kruskalwallis(X);
c = multcompare(stats);

% Conclusion: There is a significant difference (p = 1.12544e-43) for
% reported S24 usage when varying room type. Groups: A: Comm. Assembly; B:
% Stairs; C: Elevators, Bathrooms; D: Hallways

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

% Next, need to do Kruskal-Wallis anova for encounters.

% First, Kruskal Wallis keeping room type fixed and varying semester.

% Start with community assembly.

groups = {dataF23Enc(:,1), dataS24Enc(:,1), dataF24Enc(:,1), dataS25Enc(:,1)};

% Find the maximum length
maxLen = max(cellfun(@length, groups));

% Pad each group with NaN to max length
X = NaN(maxLen, numel(groups));   % preallocate
for i = 1:numel(groups)
    X(1:length(groups{i}), i) = groups{i};
end

[p, tbl, stats] = kruskalwallis(X);
c = multcompare(stats);

% Conclusion: No significant difference (p = 0.4699) for reported community assembly encounters when varying
% semester.

%%
% Stairs.

groups = {dataF23Enc(:,2), dataS24Enc(:,2), dataF24Enc(:,2), dataS25Enc(:,2)};

% Find the maximum length
maxLen = max(cellfun(@length, groups));

% Pad each group with NaN to max length
X = NaN(maxLen, numel(groups));   % preallocate
for i = 1:numel(groups)
    X(1:length(groups{i}), i) = groups{i};
end

[p, tbl, stats] = kruskalwallis(X);
c = multcompare(stats);

% Conclusion: No significant difference (p = 0.7369) for reported stairs encounters when varying
% semester.

%%
% Elevators.

groups = {dataF23Enc(:,3), dataS24Enc(:,3), dataF24Enc(:,3), dataS25Enc(:,3)};

% Find the maximum length
maxLen = max(cellfun(@length, groups));

% Pad each group with NaN to max length
X = NaN(maxLen, numel(groups));   % preallocate
for i = 1:numel(groups)
    X(1:length(groups{i}), i) = groups{i};
end

[p, tbl, stats] = kruskalwallis(X);
c = multcompare(stats);

% Conclusion: No significant difference (p = 0.1006) for reported
% elevators encounters when varying semester.

%%
% Hallways.

groups = {dataF23Enc(:,4), dataS24Enc(:,4), dataF24Enc(:,4), dataS25Enc(:,4)};

% Find the maximum length
maxLen = max(cellfun(@length, groups));

% Pad each group with NaN to max length
X = NaN(maxLen, numel(groups));   % preallocate
for i = 1:numel(groups)
    X(1:length(groups{i}), i) = groups{i};
end

[p, tbl, stats] = kruskalwallis(X);
c = multcompare(stats);

% Conclusion: No significant difference (p = 0.3221) for reported hallways
% encounters when varying semester.

%%
% Bathrooms

groups = {dataF23Enc(:,5), dataS24Enc(:,5), dataF24Enc(:,5), dataS25Enc(:,5)};

% Find the maximum length
maxLen = max(cellfun(@length, groups));

% Pad each group with NaN to max length
X = NaN(maxLen, numel(groups));   % preallocate
for i = 1:numel(groups)
    X(1:length(groups{i}), i) = groups{i};
end

[p, tbl, stats] = kruskalwallis(X);
c = multcompare(stats);

% Conclusion: No significant difference (p = 0.8726) for reported
% bathrooms encoutners when varying semester.

%%
% Second, Kruskal Wallis keeping semester fixed and varying room type.

% F23

X = [dataF23Enc(:,1), dataF23Enc(:,2), dataF23Enc(:,3), dataF23Enc(:,4), dataF23Enc(:,5)];

[p, tbl, stats] = kruskalwallis(X);
c = multcompare(stats);

% Conclusion: There is a significant difference (p = 5.89615e-18) for
% reported F23 encounters when varying room type. Groups: A: Bathrooms, Stairs;
% B: Bathrooms, Stairs, Elevators; C: Stairs, Elevators, Comm. Assembly; D:
% Hallways

%%
% S24

X = [dataS24Enc(:,1), dataS24Enc(:,2), dataS24Enc(:,3), dataS24Enc(:,4), dataS24Enc(:,5)];

[p, tbl, stats] = kruskalwallis(X);
c = multcompare(stats);

% Conclusion: There is a significant difference (p = 2.93119e-21) for
% reported S24 encounters when varying room type. Groups: A: Bathrooms,
% Stairs; B: Comm. Assembly, Elevators; C: Hallways

%%
% F24

X = [dataF24Enc(:,1), dataF24Enc(:,2), dataF24Enc(:,3), dataF24Enc(:,4), dataF24Enc(:,5)];

[p, tbl, stats] = kruskalwallis(X);
c = multcompare(stats);

% Conclusion: There is a significant difference (p = 1.16258e-27) for
% reported F24 encounters when varying room type. Groups: A: Bathrooms,
% Stairs; B: Comm. Assembly, Elevators; C: Hallways

%%
% S25

X = [dataS25Enc(:,1), dataS25Enc(:,2), dataS25Enc(:,3), dataS25Enc(:,4), dataS25Enc(:,5)];

[p, tbl, stats] = kruskalwallis(X);
c = multcompare(stats);

% Conclusion: There is a significant difference (p = 1.59855e-15) for
% reported S25 encounters when varying room type. Groups: A: Bathrooms,
% Stairs; B: Bathrooms, Stairs, Elevators; C: Stairs, Elevators, Comm.
% Assembly; D: Hallways
%%
% Aggregating all semester and performing kruskal wallis analysis of
% variance on room type

X = [dataF23Enc(:,1), dataF23Enc(:,2), dataF23Enc(:,3), dataF23Enc(:,4), dataF23Enc(:,5);
     dataS24Enc(:,1), dataS24Enc(:,2), dataS24Enc(:,3), dataS24Enc(:,4), dataS24Enc(:,5);
     dataF24Enc(:,1), dataF24Enc(:,2), dataF24Enc(:,3), dataF24Enc(:,4), dataF24Enc(:,5);
     dataS25Enc(:,1), dataS25Enc(:,2), dataS25Enc(:,3), dataS25Enc(:,4), dataS25Enc(:,5)];

[p, tbl, stats] = kruskalwallis(X);
c = multcompare(stats);