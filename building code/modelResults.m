clearvars; close all; clc;
load("diaries.mat", "diaryPatterns")

% Loading model simulation data

load('randTopModel-Sims-200-102625.mat')
rtUseData = useData;
rtColData = collisionData;
load('eqProbModel-Sims-200-102525.mat')
eqUseData = useData;
eqColData = collisionData;
load('fullModel-Sims-200-101525.mat')
fmUseData = useData;
fmColData = collisionData;

% % Combine the use data and collision data from all models into a single structure
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
set(gcf,'PaperPosition',[0,0,11,8.5]); print('-dpng','meanUseModelComp.png')

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
set(gcf,'PaperPosition',[0,0,11,8.5]); print('-dpng','meanColModelComp.png')