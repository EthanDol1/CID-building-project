clearvars; close all; clc;
load("leaveOneOut.mat")
load("diaries.mat","diaryPatterns")
%%
meantimeusage = mean(usagedata);
stdtimeusage = std(usagedata);

figure
bar(meantimeusage)
hold on
errorbar(1:length(meantimeusage), meantimeusage, stdtimeusage, 'k', 'linestyle', 'none',"LineWidth",1)
set(gca, 'XTickLabel', diaryPatterns)
xlabel('Patterns',"FontSize",20)
ylabel('Average Time Spent (hours)',"FontSize",20)
ylim([0 16])
title('Average Time Spent in Patterns with Standard Deviation',"FontSize",23)
grid on
hold off