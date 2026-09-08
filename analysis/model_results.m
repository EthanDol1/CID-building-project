clearvars; close all; clc;
resultsDir = fullfile(fileparts(mfilename('fullpath')), '..', 'results');
if ~isfolder(resultsDir), mkdir(resultsDir); end

load("diaries.mat", "diaryPatterns")

% Loading model use and collision data

% load('randTopModel-Sims-200-102625.mat')
% rtUseData = useData;
% rtColData = collisionData;
% load('eqProbModel-Sims-200-102525.mat')
% eqUseData = useData;
% eqColData = collisionData;
% load('fullModel-Sims-200-101525.mat')
% fmUseData = useData;
% fmColData = collisionData;

load('fullModel-Sims-200-101525.mat')
fm_oldUseData = useData;
fm_oldColData = collisionData;

load('fullModel_data.mat')
fmUseData = useData;
fmColData = collisionData;

load('eqProbModel_old_data.mat');
ep_oldUseData = useData;
ep_oldColData = collisionData;

load('eqProbModel_data.mat')
epUseData = useData;
epColData = collisionData;

load('randProbModel_data.mat');
rpUseData = useData;
rpColData = collisionData;

load('randTopModel-Sims-200-102625.mat')
rt_oldUseData = useData;
rt_oldColData = collisionData;

load('randTopModel_data.mat');
rtUseData = useData;
rtColData = collisionData;

modelLabels = ["Full Model (Old)", "Full Model", "Equal Probability (Old)", "Equal Probability", "Random Probability", "Random Topology (Old)", "Random Topology"];

%%
% 3 - CA, 4 - S, 5 - E, 6 - H, 8 - B

[p, tbl, stats] = kruskalwallis(fm_oldUseData(:,[3 4 5 6 8]));
c = multcompare(stats);

[p, tbl, stats] = kruskalwallis(fm_oldColData(:,[3 4 5 6 8]));
c = multcompare(stats);

%%

[p, tbl, stats] = kruskalwallis(fmUseData(:,[3 4 5 6 8]));
c = multcompare(stats);

[p, tbl, stats] = kruskalwallis(fmColData(:,[3 4 5 6 8]));
c = multcompare(stats);

%%

[p, tbl, stats] = kruskalwallis(ep_oldUseData(:,[3 4 5 6 8]));
c = multcompare(stats);

[p, tbl, stats] = kruskalwallis(ep_oldColData(:,[3 4 5 6 8]));
c = multcompare(stats);

%%

[p, tbl, stats] = kruskalwallis(epUseData(:,[3 4 5 6 8]));
c = multcompare(stats);

[p, tbl, stats] = kruskalwallis(epColData(:,[3 4 5 6 8]));
c = multcompare(stats);

%%

[p, tbl, stats] = kruskalwallis(rpUseData(:,[3 4 5 6 8]));
c = multcompare(stats);

[p, tbl, stats] = kruskalwallis(rpColData(:,[3 4 5 6 8]));
c = multcompare(stats);

%%

[p, tbl, stats] = kruskalwallis(rt_oldUseData(:,[3 4 5 6 8]));
c = multcompare(stats);

[p, tbl, stats] = kruskalwallis(rt_oldColData(:,[3 4 5 6 8]));
c = multcompare(stats);

%%

[p, tbl, stats] = kruskalwallis(rtUseData(:,[3 4 5 6 8]));
c = multcompare(stats);

[p, tbl, stats] = kruskalwallis(rtColData(:,[3 4 5 6 8]));
c = multcompare(stats);

%% Calculating rankings distances

% survey_use = [C S E B H];
% survey_col = [B S E C H];
% 
% fm_old_use = [C E S B H];
% fm_old_col = [B C S E H];
% 
% fm_use = [C E S B H];
% fm_col = [B C S E H];
% 
% ep_old_use = [C E S B H];
% ep_old_col = [C E S B H];
% 
% ep_use = [C E S B H];
% ep_col = [C E B S H];
% 
% rp_use = [C E S B H];
% rp_col = [C E S B H];
% 
% rt_old_use = [C E S B H];
% rt_old_col = [C S B E H];
% 
% rt_use = [C E S B H];
% rt_col = [C S B E H];

survey_use = [1 2 3 5 4];
survey_col = [5 2 3 1 4];

fm_old_use = [1 3 2 5 4];
fm_old_col = [5 1 2 3 4];

fm_use = [1 3 2 5 4];
fm_col = [5 1 2 3 4];

ep_old_use = [1 3 2 5 4];
ep_old_col = [1 3 2 5 4];

ep_use = [1 3 2 5 4];
ep_col = [1 3 5 2 4];

rp_use = [1 3 2 5 4];
rp_col = [1 3 2 5 4];

rt_old_use = [1 3 2 5 4];
rt_old_col = [1 2 5 3 4];

rt_use = [1 3 2 5 4];
rt_col = [1 2 5 3 4];

use_rankings = {fm_old_use, fm_use, ep_old_use, ep_use, rp_use, rt_old_use, rt_use};
col_rankings = {fm_old_col, fm_col, ep_old_col, ep_col, rp_col, rt_old_col, rt_col};

for i = 1:length(use_rankings)
    use_dist = kendallTauDistance(survey_use, use_rankings{i});
    col_dist = kendallTauDistance(survey_col, col_rankings{i});
    disp(modelLabels(i) +" Ranking Distance from Survey:")
    disp("usage ranking distance is: " + use_dist)
    disp("collision ranking distance is: " + col_dist)
end

%% Combine the use data and collision data from all models into a single structure
% combinedUseData = struct('rt', rtUseData, 'eq', eqUseData, 'fm', fmUseData);
% combinedColData = struct('rt', rtColData, 'eq', eqColData, 'fm', fmColData);

rtUseDataMean = mean(rtUseData)';
eqUseDataMean = mean(eqUseData)';
fmUseDataMean = mean(fmUseData)';
combinedUseDataMean = [rtUseDataMean eqUseDataMean fmUseDataMean];
combinedUseDataMean(2,:) = [];
rtUseDataSd = std(rtUseData)';
eqUseDataSd = std(eqUseData)';
fmUseDataSd = std(fmUseData)';
combinedUseDataSd = [rtUseDataSd eqUseDataSd fmUseDataSd];
combinedUseDataSd(2,:) = [];

figure
b = bar(combinedUseDataMean);
hold on
for k = 1:size(combinedUseDataMean,2)
    x = b(k).XEndPoints;
    errorbar(x, combinedUseDataMean(:,k), combinedUseDataSd(:,k), 'k', 'linestyle', 'none');
end
hold off
xlabel('Room type', 'FontSize', 20);
xticklabels({'My dorm', 'Comm. Assembly', 'Stairs', 'Elevators', 'Hallways', 'Kitchens', 'Bathrooms', 'LLC Lounges', 'Mezzanine', 'Other', 'Outside', 'Outside', 'Lounges'})
ylabel('Average total time (hrs) spent in room type', 'FontSize', 20);
ylim([0 8000]);
title('Comparison of average total use time for all three models', 'FontSize', 24)
legend('Random topology','Equal probability','Full model', 'FontSize', 18);
set(gcf,'PaperPosition',[0,0,11,8.5]); print('-dpng',fullfile(resultsDir,'meanUseModelComp.png'))

rtColDataMean = mean(rtColData)';
eqColDataMean = mean(eqColData)';
fmColDataMean = mean(fmColData)';
combinedColDataMean = [rtColDataMean eqColDataMean fmColDataMean];
combinedColDataMean([2 11 12],:) = [];
rtColDataSd = std(rtColData)';
eqColDataSd = std(eqColData)';
fmColDataSd = std(fmColData)';
combinedColDataSd = [rtColDataSd eqColDataSd fmColDataSd];
combinedColDataSd([2 11 12],:) = [];

figure
b = bar(combinedColDataMean);
hold on
for k = 1:size(combinedColDataMean,2)
    x = b(k).XEndPoints;
    errorbar(x, combinedColDataMean(:,k), combinedColDataSd(:,k), 'k', 'linestyle', 'none');
end
hold off
xlabel('Room type', 'FontSize', 20);
xticklabels({'My dorm', 'Comm. Assembly', 'Stairs', 'Elevators', 'Hallways', 'Kitchens', 'Bathrooms', 'LLC Lounges', 'Mezzanine', 'Other', 'Outside', 'Outside', 'Lounges'})
ylabel('Average number of collisions in room type', 'FontSize', 20);
ylim([0 65000])
title('Comparison of average number of collisions for all three models', 'FontSize', 24)
legend('Random topology','Equal probability','Full model', 'FontSize', 18);
set(gcf,'PaperPosition',[0,0,11,8.5]); print('-dpng',fullfile(resultsDir,'meanColModelComp.png'))