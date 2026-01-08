clearvars; close all; clc;

% Loading model simulation data

load('randTopModel-Sims-200-102625.mat')
rtUseData = useData(:,[3 4 5 6 8]);
rtColData = collisionData(:,[3 4 5 6 8]);
load('eqProbModel-Sims-200-102525.mat')
eqUseData = useData(:,[3 4 5 6 8]);
eqColData = collisionData(:,[3 4 5 6 8]);
load('fullModel-Sims-200-101525.mat')
fmUseData = useData(:,[3 4 5 6 8]);
fmColData = collisionData(:,[3 4 5 6 8]);
%%
% Conv analysis

% Convergence analysis for random topology model

% Creating arrays with ith row the averages (SDs) for the first i full-day
% simulations
rtUseAvg = zeros(200,5);
rtUseSd = zeros(200,5);
for i = 1:length(rtUseData)
    if i == 1
        rtUseAvg(i,:) = rtUseData(1,:);
        rtUseSd(i,:) = [0 0 0 0 0];
    else
        rtUseAvg(i,:) = mean(rtUseData(1:i,:));
        rtUseSd(i,:) = std(rtUseData(1:i,:));
    end
end

upperbound = rtUseAvg + rtUseSd;
lowerbound = rtUseAvg - rtUseSd;

% Plotting the averages with their SDs
figure
plot(1:200, rtUseAvg(:,1), "b")
hold on
plot(1:200, upperbound(:,1), "k--", 1:200, lowerbound(:,1),"k--")
hold off
ylim([0 200])
xlabel("Num of simulations")
ylabel("Avg amount of usage (total person-hours)")
title("Evolution of average time usage of community assembly")

% Creating arrays with the ith row the averages (SDs) of the last 7
% averges
rtUseRAvg = zeros(200,5);
rtUseRSd = zeros(200,5);
for i = 1:length(rtUseAvg)
    if i == 1
        rtUseRAvg(i,:) = rtUseAvg(1,:);
        rtUseRSd(i,:) = rtUseSd(1,:);
    elseif i<21
        rtUseRAvg(i,:) = mean(rtUseAvg(1:i,:));
        rtUseRSd(i,:) = std(rtUseAvg(1:i,:));
    else
        rtUseRAvg(i,:) = mean(rtUseAvg(i-19:i,:));
        rtUseRSd(i,:) = std(rtUseAvg(i-19:i,:));
    end
end

upperbound = rtUseRAvg + rtUseRSd;
lowerbound = rtUseRAvg - rtUseRSd;

relerror = rtUseRSd(200,1)/rtUseRAvg(200,1);

figure
plot(1:200,rtUseRAvg(:,1),"b", "LineWidth",2)
hold on
plot(1:200, lowerbound, "k--", 1:200, upperbound, "k--","LineWidth",2)
hold off
ylim([0 200])
xlabel("Num of simulations","FontSize",19)
ylabel("Moving avg amount of usage (total person-hours)","FontSize",19)
title("Rolling average of time usage of community assembly","FontSize",22)
ylim([60 140])
text(110, 125, "sigma/mu is " + string(relerror) + " < 0.1","FontSize",18)
annotation('textarrow', [0.65 0.88], [0.74 0.45], 'Color', 'red');
legend("rolling average", "standard dev. of last 7 averages","FontSize",18)
grid on
set(gcf,'PaperPosition',[0,0,11,8.5]); print('-dpng','convergence-fig.png')

%%
% Next step is to iterate through and perform analysis for each room type
% for each model.

% Don't need to plot each thing, just need to check that it converges via
% mu/sigma.

alldata = {rtUseData,rtColData,eqUseData,eqColData,fmUseData,fmColData};
n = length(alldata);

for i = 1:n
    avg = zeros(length(alldata{i}),5);
    for j = 1:length(alldata{i})
        if j == 1
            avg(j,:) = alldata{i}(1,:);
        else
            avg(j,:) = mean(alldata{i}(1:j,:));
        end
    end
    
    for j = 1:5
        relerror = std(avg(41:60,j))/mean(avg(41:60,j));
        if relerror < 0.1
            fprintf('Model %d, Room %d converged with relerror: %.4f\n', i, j, relerror);
        else
            fprintf('Model %d, Room %d did not converge with relerror: %.4f\n', i, j, relerror);
        end
    end
end





