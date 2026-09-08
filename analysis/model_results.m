%% Model comparison: usage and collisions by room type
% Loads the usage and collision statistics produced by each model, tests
% whether outcome depends on room type, ranks the room types, and compares
% those rankings against the survey rankings using Kendall tau distance.

clearvars; close all; clc;
resultsDir = fullfile(fileparts(mfilename('fullpath')), '..', 'results');
if ~isfolder(resultsDir), mkdir(resultsDir); end

load("diaries.mat", "diaryPatterns")

%% Load model use and collision data
% Each file holds useData and collisionData, both 200 x 13: iterations by
% room type. useData is person-hours, collisionData is co-occurrence counts.

load('fullModel_data.mat')
fmUseData = useData;
fmColData = collisionData;

load('eqProbModel_data.mat')
epUseData = useData;
epColData = collisionData;

load('randTopModel_data.mat')
rtUseData = useData;
rtColData = collisionData;

modelLabels = ["Full Model", "Equal Probability", "Random Topology"];

%% Kruskal-Wallis tests and multiple comparisons
% Columns 3, 4, 5, 6 and 8 are the five room types the survey asked about:
% community assembly, stairs, elevator, hallway, bathroom.
surveyCols = [3 4 5 6 8];

[p, tbl, stats] = kruskalwallis(fmUseData(:,surveyCols));
c = multcompare(stats);

[p, tbl, stats] = kruskalwallis(fmColData(:,surveyCols));
c = multcompare(stats);

%%

[p, tbl, stats] = kruskalwallis(epUseData(:,surveyCols));
c = multcompare(stats);

[p, tbl, stats] = kruskalwallis(epColData(:,surveyCols));
c = multcompare(stats);

%%

[p, tbl, stats] = kruskalwallis(rtUseData(:,surveyCols));
c = multcompare(stats);

[p, tbl, stats] = kruskalwallis(rtColData(:,surveyCols));
c = multcompare(stats);

%% Ranking distances from the survey
% Each vector below is an ORDERING: position k holds the code of the room type
% ranked kth, from least to most. Codes are C = 1, S = 2, E = 3, H = 4, B = 5.
%
% Kendall tau distance is defined over pairs of ITEMS - for each pair, do the
% two rankings disagree about which comes first - so it needs each ranking as a
% rank vector, r(item) = the position that item holds. The orderings below are
% converted with toRanks before the distance is taken. Passing the orderings
% straight in would compare room-type codes at matching positions, which is a
% different and meaningless quantity.
%
%   survey_use = [C S E B H];   survey_col = [B S E C H];
%   fm_use     = [C E S B H];   fm_col     = [B C S E H];
%   ep_use     = [C E S B H];   ep_col     = [C E B S H];
%   rt_use     = [C E S B H];   rt_col     = [C S B E H];

survey_use = [1 2 3 5 4];
survey_col = [5 2 3 1 4];

fm_use = [1 3 2 5 4];
fm_col = [5 1 2 3 4];

ep_use = [1 3 2 5 4];
ep_col = [1 3 5 2 4];

rt_use = [1 3 2 5 4];
rt_col = [1 2 5 3 4];

use_rankings = {fm_use, ep_use, rt_use};
col_rankings = {fm_col, ep_col, rt_col};

toRanks = @(ordering) accumarray(ordering(:), (1:numel(ordering))');

for i = 1:length(use_rankings)
    use_dist = kendallTauDistance(toRanks(survey_use), toRanks(use_rankings{i}));
    col_dist = kendallTauDistance(toRanks(survey_col), toRanks(col_rankings{i}));
    disp(modelLabels(i) + " Ranking Distance from Survey:")
    disp("usage ranking distance is: " + use_dist)
    disp("collision ranking distance is: " + col_dist)
end

%% Mean usage by room type, all models
% Friend's dorm (row 2) is dropped: no node carries that room type, so every
% model reports zero for it.
useKeep = setdiff(1:13, 2);
useLabels = {'My dorm','Comm. Assembly','Stairs','Elevators','Hallways', ...
    'Kitchens','Bathrooms','LLC Lounges','Mezzanine','Other','Outside','Lounges'};

combinedUseDataMean = [mean(fmUseData)' mean(epUseData)' mean(rtUseData)'];
combinedUseDataSd   = [std(fmUseData)'  std(epUseData)'  std(rtUseData)'];
combinedUseDataMean = combinedUseDataMean(useKeep,:);
combinedUseDataSd   = combinedUseDataSd(useKeep,:);

figure
b = bar(combinedUseDataMean);
hold on
for k = 1:size(combinedUseDataMean,2)
    errorbar(b(k).XEndPoints, combinedUseDataMean(:,k), combinedUseDataSd(:,k), ...
        'k', 'linestyle', 'none');
end
hold off
xlabel('Room type', 'FontSize', 20);
xticklabels(useLabels)
ylabel('Average total time (hrs) spent in room type', 'FontSize', 20);
title('Comparison of average total use time across models', 'FontSize', 24)
legend(modelLabels, 'FontSize', 18);
set(gcf,'PaperPosition',[0,0,11,8.5]);
print('-dpng',fullfile(resultsDir,'meanUseModelComp.png'))

%% Mean collisions by room type, all models
% Friend's dorm, other and outside (rows 2, 11, 12) are dropped: collisions
% there are not meaningful for the same reason.
colKeep = setdiff(1:13, [2 11 12]);
colLabels = {'My dorm','Comm. Assembly','Stairs','Elevators','Hallways', ...
    'Kitchens','Bathrooms','LLC Lounges','Mezzanine','Lounges'};

combinedColDataMean = [mean(fmColData)' mean(epColData)' mean(rtColData)'];
combinedColDataSd   = [std(fmColData)'  std(epColData)'  std(rtColData)'];
combinedColDataMean = combinedColDataMean(colKeep,:);
combinedColDataSd   = combinedColDataSd(colKeep,:);

figure
b = bar(combinedColDataMean);
hold on
for k = 1:size(combinedColDataMean,2)
    errorbar(b(k).XEndPoints, combinedColDataMean(:,k), combinedColDataSd(:,k), ...
        'k', 'linestyle', 'none');
end
hold off
xlabel('Room type', 'FontSize', 20);
xticklabels(colLabels)
ylabel('Average number of collisions in room type', 'FontSize', 20);
title('Comparison of average number of collisions across models', 'FontSize', 24)
legend(modelLabels, 'FontSize', 18);
set(gcf,'PaperPosition',[0,0,11,8.5]);
print('-dpng',fullfile(resultsDir,'meanColModelComp.png'))
