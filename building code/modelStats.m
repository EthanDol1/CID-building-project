clearvars; clc;

load('diaries.mat')
load('diary_data.mat')
load('master_list.mat')
load('CID_building.mat')

load('100tdSimuls_91625.mat')

useMatrix = zeros(100,13);
for i = 1:100
    useMatrix(i,:) = mean(dataDiaryPatternUse((i-1)*594 + 1:i*594,:));
end

%%

edges = 0:1:40;

A = zeros(100,40,5);

l = length(room_index);
n = 100; %numSimulations

for i = 1:n
    B = dataDiaryPatternUse(l*(i-1)+1:i*l,[3 4 5 6 8]);
    for j = 1:5
        A(i,:,j) = histcounts(B(:,j), edges);
    end
end

C1 = round(mean(A(:,:,1)));
C2 = round(mean(A(:,:,2)));
C3 = round(mean(A(:,:,3)));
C4 = round(mean(A(:,:,4)));
C5 = round(mean(A(:,:,5)));

X = edges(1:end-1);
figure(1)
% Prepare data for plotting
plot(X,C1,X,C2,X,C3,X,C4,X,C5,'LineWidth',2)
legend('Comm. Assembly','Stairs','Elevator','Hall','Bathroom','FontSize',20)
xlabel("Amount of time spent (hours)", 'FontSize', 25)
ylabel("Counts (# of trajectories)",'FontSize',25)
title('Time usage histogram (averaged)','FontSize',25);

set(gcf,'PaperPosition',[0,0,8,5]); print('-dpng','usagehistogram-avgd.png')

C = [C1' C2' C3' C4' C5'];

save("avgHistcountsModel.mat", "C")

%%

figure
violinplot(dataDiaryPatternUse(:,[3 4 5 6 8]))
ylim([-2 20])

% Problem with violinplot is it shows kernel density estimate of pdf from
% data -> can include negative values

%%

% Swarm chart does better

x = [ones(59400,1) 2*ones(59400,1) 3*ones(59400,1) 4*ones(59400,1) 5*ones(59400,1)];
figure
swarmchart(x,dataDiaryPatternUse(:,[3 4 5 6 8]))
aves = mean(dataDiaryPatternUse(:,[3 4 5 6 8]));
stds = std(dataDiaryPatternUse(:,[3 4 5 6 8]));
xticks([1 2 3 4 5])
xticklabels({'Comm. Assembly','Stairs','Elevators','Hallways','Bathrooms'})
xlabel('Room Type', 'FontSize',22)
ylabel('Amount of time spent (hours)','FontSize',22)
title('Distribution of time usage across 100 iterations','FontSize',24)
hold on
x = [1 2 3 4 5];
errorbar(x, aves, stds, 'o', 'LineStyle','none','Color','k','LineWidth',1);
hold off
ylim([0 20])
set(gcf,'PaperPosition',[0,0,8,5]); print('-dpng','swarm-chart-use-all.png')

%%

x = [ones(100,1) 2*ones(100,1) 3*ones(100,1) 4*ones(100,1) 5*ones(100,1)];
figure
swarmchart(x,dataDiaryPE(:,[3 4 5 6 8]))
aves = mean(dataDiaryPE(:, [3 4 5 6 8]));
stds = std(dataDiaryPE(:, [3 4 5 6 8]));
xticks([1 2 3 4 5])
xticklabels({'Comm. Assembly','Stairs','Elevators','Hallways','Bathrooms'})
xlabel('Room Type', 'FontSize',22)
ylabel('Amount of encounters','FontSize',22)
title('Distribution of collisions across 100 iterations','FontSize',20)
hold on
x = [1 2 3 4 5];
errorbar(x, aves, stds, 'o', 'LineStyle','none','Color','k','LineWidth',1);
hold off
set(gcf,'PaperPosition',[0,0,8,5]); print('-dpng','swarm-chart-col-all.png')

%%

values = 0:(numel(C1)-1);
data = repelem(values, C1)';
f1 = fitdist(data,"Poisson");

x_vals = 0:1:39;

y = 594*pdf(f1,X);

figure
plot(X,C1, x_vals, y, 'r--','LineWidth',2)
ylabel('Counts (# of trajectories)', 'FontSize', 15)
xlabel('Amount of time spent (hours)', 'FontSize', 15)
leg = legend('Comm. Assembly Counts', 'Poisson Fit', 'FontSize', 15);
title('Comm. Assembly counts with fitted Poisson dist.', 'FontSize', 15)

chi2stat = sum((C1 - y).^2 ./ y);
df = length(C1) - 1 - 1;
pval = 1 - chi2cdf(chi2stat, df);

str = sprintf('p = %.3f', pval);
text(22.5, 340, str, 'FontSize', 18, 'Color', 'k')
str = sprintf('X^2 = %.3f', chi2stat);
text(22.5, 315, str, 'FontSize', 18, 'Color', 'k')

set(gcf,'PaperPosition',[0,0,8,5]); print('-dpng','commassembly-fit.png')


%%

values = 0:(numel(C2)-1); 
data = repelem(values, C2)';
f2 = fitdist(data,"Poisson");

y = 594*pdf(f2,x_vals);

figure
plot(X,C2, x_vals, y, 'r--','LineWidth',2);
ylabel('Counts (# of trajectories)', 'FontSize', 15)
xlabel('Amount of time spent (hours)', 'FontSize', 15)
leg = legend('Stairs Counts', 'Poisson Fit', 'FontSize', 10);
title('Stairs counts with fitted Poisson dist.', 'FontSize', 15)

chi2stat = sum((C2 - y).^2 ./ y);

df = length(C2) - 1 - 1;
pval = 1 - chi2cdf(chi2stat, df);

str = sprintf('p = %.3f', pval);
text(30, 135, str, 'FontSize', 18, 'Color', 'k')
str = sprintf('X^2 = %.3f', chi2stat);
text(30, 124, str, 'FontSize', 18, 'Color', 'k')

set(gcf,'PaperPosition',[0,0,8,5]); print('-dpng','stairs-fit.png')

%%

values = 0:(numel(C3)-1);
data = repelem(values, C3)';
f3 = fitdist(data,"Poisson");

y = 594*pdf(f3,x_vals);

figure
plot(X,C3, x_vals, y, 'r--','LineWidth',2);
ylabel('Counts (# of trajectories)', 'FontSize', 15)
xlabel('Amount of time spent (hours)', 'FontSize', 15)
leg = legend('Elevators Counts', 'Poisson Fit', 'FontSize', 10);
title('Elevators counts with fitted Poisson dist.', 'FontSize', 15)

chi2stat = sum((C3 - y).^2 ./ y);

df = length(C3) - 1 - 1;
pval = 1 - chi2cdf(chi2stat, df);

str = sprintf('p = %.3f', pval);
text(30, 135, str, 'FontSize', 18, 'Color', 'k')
str = sprintf('X^2 = %.3f', chi2stat);
text(30, 124, str, 'FontSize', 18, 'Color', 'k')

set(gcf,'PaperPosition',[0,0,8,5]); print('-dpng','elev-fit.png')


%%

values = 0:(numel(C4)-1);
data = repelem(values, C4)';
f4 = fitdist(data,"Poisson");

y = 594*pdf(f4,x_vals);

figure
plot(X,C4, x_vals, y, 'r--','LineWidth',2);
ylabel('Counts (# of trajectories)', 'FontSize', 25)
xlabel('Amount of time spent (hours)', 'FontSize', 25)
leg = legend('Hallways Counts', 'Poisson Fit', 'FontSize', 20);
title('Hallways counts with fitted Poisson dist.', 'FontSize', 25)

chi2stat = sum((C4 - y).^2 ./ y);

df = length(C4) - 1 - 1;
pval = 1 - chi2cdf(chi2stat, df);

str = sprintf('p = %.3f', pval);
text(31, 44, str, 'FontSize', 18, 'Color', 'k')
str = sprintf('X^2 = %.3f', chi2stat);
text(31, 40, str, 'FontSize', 18, 'Color', 'k')

set(gcf,'PaperPosition',[0,0,8,5]); print('-dpng','hallways-fit.png')

%%

values = 0:(numel(C5)-1);
data = repelem(values, C5)';
f5 = fitdist(data,"Poisson");

y = 594*pdf(f5,x_vals);

figure
plot(X,C5, x_vals, y, 'r--','LineWidth',2);
ylabel('Counts (# of trajectories)', 'FontSize', 25)
xlabel('Amount of time spent (hours)', 'FontSize', 25)
leg = legend('Bathroom Counts', 'Poisson Fit', 'FontSize', 20);
title('Bathroom counts with fitted Poisson dist.', 'FontSize', 25)

chi2stat = sum((C5 - y).^2 ./ y);

df = length(C5) - 1 - 1;
pval = 1 - chi2cdf(chi2stat, df);

str = sprintf('p = %.3f', pval);
text(30, 115, str, 'FontSize', 18, 'Color', 'k')
str = sprintf('X^2 = %.3f', chi2stat);
text(30, 105, str, 'FontSize', 18, 'Color', 'k')

set(gcf,'PaperPosition',[0,0,8,5]); print('-dpng','bathroom-fit.png')