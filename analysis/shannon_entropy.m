%% Shannon entropy of model trajectories
% Measures how predictable each model's trajectories are. Every trajectory is
% recoded from node numbers into room-type patterns, the empirical
% distribution of length-2 pattern strings is counted across all residents of
% one iteration, and the Shannon entropy of that distribution is taken. A
% higher entropy means a less predictable model.
%
% All four models are processed in a single run: the outer loop walks the
% models and the inner loop their 200 iterations, so one pass fills every
% entropy vector and the plotting sections below need no manual bookkeeping.
%
% Produces three figures: the mean pattern-string distribution per model, a
% bar chart of mean entropy per model, and a swarm chart of the per-iteration
% entropies.

clearvars; close all;

resultsDir = fullfile(fileparts(mfilename('fullpath')), '..', 'results');
if ~isfolder(resultsDir), mkdir(resultsDir); end

%% Load simulation data
% Each model's 200 iterations are split across four files with uneven chunk
% sizes, so the slice indices differ between models and are not interchangeable.

fm = zeros(96,594,200);
ep = zeros(96,594,200);
rt = zeros(96,594,200);

load("fm_data.mat"); fm(:,:,:) = fm_simulation_matrix;
load("ep_data.mat"); ep(:,:,:) = ep_simulation_matrix;
load("rt_data.mat"); rt(:,:,:) = rt_simulation_matrix;

load('master_list.mat')   % masterList: column 4 is each node's room-type pattern

%% Models under analysis
% The order here sets the column order of se, mean_se and std_se, and must
% match modelLabels and the colour rows used by every figure below.
modelData = {fm, ep, rt};
modelLabels = ["Full Model", "Equal Probability", "Random Topology"];

%% Entropy per iteration
% For each iteration: drop trajectories that barely move, recode nodes as
% pattern indices, count how often each length-2 pattern string occurs across
% all residents, normalise to a distribution, and take its entropy.

nIterations = size(modelData{1},3);
nModels = numel(modelData);

se_vec = zeros(nIterations,1);
se = repmat({se_vec}, 1, nModels);

% All ordered pairs of the 12 pattern indices: the alphabet of length-2 strings.
T = table2array(combinations(1:12,1:12));

% Running total of each model's distribution, averaged over iterations after
% the loop. Plotting one curve per iteration would put 800 lines on one axis,
% so the mean distribution per model is what gets drawn.
pAvg = zeros(size(T,1), nModels);

for i = 1:size(modelData,2)
    
    data = modelData{i};

    for it = 1:nIterations
    
        x = data(:,:,it);
    
        % Keep only trajectories that visited at least three distinct rooms.
        % Residents who never really moved would otherwise dominate the counts.
        % Applied to every model here; see "Parked: filtering applied to the
        % random-topology model only" at the end of this file, which applied it
        % to rt alone.
        keep = false(size(x,2),1);
        for traj = 1:size(x,2)
            keep(traj) = numel(unique(x(:,traj))) >= 3;
        end
        x = x(:,keep);
    
        % Recode node numbers as pattern indices. masterList(x,4) flattens to a
        % column, so the reshape restores the 96-by-trajectory shape.
        x_str = masterList(x,4);
        patterns = unique(x_str);
    
        xpat = zeros(size(x_str));
        for ind_patterns = 1:length(patterns)
            xpat(strcmp(x_str,patterns(ind_patterns))) = ind_patterns;
        end
        xpat = reshape(xpat,size(x));
    
        % Empirical distribution over length-2 strings, pooled across trajectories.
        reps = size(x,2);
        p = zeros(size(T,1),1);
    
        for ind_rep = 1:reps
            % Consecutive pattern pairs down this trajectory.
            aux = [xpat(1:end-1,ind_rep), xpat(2:end,ind_rep)];
    
            for ind_trans = 1:length(T)
                p(ind_trans) = p(ind_trans) + sum(all(T(ind_trans,:)==aux,2));
            end
        end
        p = p/sum(p);

        % Accumulate before the zero-stripping below, which shortens p.
        pAvg(:,i) = pAvg(:,i) + p;

        % Shannon entropy; zero-probability strings contribute nothing and are
        % dropped so the log stays finite.
        p(p==0) = [];
        se{i}(it) = -sum(p.*log(p));
    end
end

pAvg = pAvg / nIterations;

%% Per-model entropy vectors
% Named aliases for the columns of se, in modelData order.
se_fm = se{1};
se_ep = se{2};
se_rt = se{3};

% Colours are generated to fit however many series each figure draws, so
% adding or removing a model needs no edit here. parula runs blue -> green ->
% yellow and stays distinguishable for any count.
modelColors = @(n) parula(n);

%% Does model type affect entropy? One-way ANOVA with Tukey post-hoc
% These are the statistics quoted in the caption of the entropy figure. They
% are computed here so that they update whenever the underlying data changes.
anovaY = [se_fm; se_ep; se_rt];
anovaGroup = [repmat(modelLabels(1), nIterations, 1); ...
              repmat(modelLabels(2), nIterations, 1); ...
              repmat(modelLabels(3), nIterations, 1)];

[pModel, anovaTbl, anovaStats] = anova1(anovaY, anovaGroup, 'off');
tukey = multcompare(anovaStats, 'CType', 'tukey-kramer', 'Display', 'off');

Fstat  = anovaTbl{2,5};
dfModel = anovaTbl{2,3};
dfError = anovaTbl{3,3};

fprintf('\nOne-way ANOVA, effect of model on block entropy:\n');
fprintf('  F(%d,%d) = %.4g, p = %.3g\n', dfModel, dfError, Fstat, pModel);

fprintf('Tukey-Kramer post-hoc comparisons:\n');
for r = 1:size(tukey,1)
    fprintf('  %-20s vs %-20s p = %.3g\n', ...
        modelLabels(tukey(r,1)), modelLabels(tukey(r,2)), tukey(r,6));
end

%% Mean pattern-string distribution per model
% One curve per model, averaged over its 200 iterations. The x axis indexes
% the 144 ordered pattern pairs in T; a flatter curve spreads probability over
% more strings and so carries higher entropy.
figure
h = plot(pAvg, 'LineWidth', 1.5);
set(h, {'Color'}, num2cell(modelColors(size(pAvg,2)),2));
xlabel('Length-2 pattern string index')
ylabel('Mean probability')
title("Pattern-string distributions", "FontSize", 20)
legend(modelLabels, 'Location', 'best')
ax = gca;
ax.FontSize = 16;
grid on

%% Mean entropy per model
% Computed from the se vectors above, so the chart always reflects the data
% loaded at the top of this script.
mean_se = [mean(se_fm) mean(se_ep) mean(se_rt)];
std_se  = [std(se_fm) std(se_ep) std(se_rt)];

figure
b = bar(1:numel(mean_se), mean_se, 'FaceColor', 'flat');
b.CData = modelColors(numel(mean_se));
hold on

er = errorbar(1:numel(mean_se), mean_se, std_se, std_se);
er.Color = [0 0 0];
er.LineStyle = 'none';
er.LineWidth = 1;

ylabel('Average Shannon Entropy across iterations')
ax = gca;
ax.FontSize = 16;
xticklabels(modelLabels)
title("Shannon entrophy of length 2 strings of trajectories", "FontSize", 20)
grid on
hold off

%% Per-iteration entropy, all models
% Sized explicitly rather than relying on the on-screen window, so the saved
% PNG is the same regardless of the display it was generated on. The four
% category labels are long at font size 20, so the figure is made wide enough
% for them to sit side by side without overlapping or being clipped.
figure('Units','inches','Position',[1 1 13 8]);
x = repmat(1:numel(modelLabels), nIterations, 1);
swarmchart(x, [se_fm, se_ep, se_rt], 30, modelColors(size(x,2)), 'filled')
ylabel('$H$','Interpreter','latex')
ax = gca;
ax.XTick = 1:numel(modelLabels);
ax.FontSize = 20;
xticklabels(modelLabels)
xlim([0.5 numel(modelLabels)+0.5])       % keep the outer swarms clear of the axes box
box on

set(findall(gcf,'Type','axes'),'Toolbar',[]);   % keep the hover toolbar out of the export
exportgraphics(gcf, fullfile(resultsDir,'shannon-entropy-swarm.png'), 'Resolution', 300);

%% ======================================================================
%  PARKED CODE
%  Kept for reference, not run. Each block below records something the
%  live code above does not capture.
%  ======================================================================

%% Parked: filtering applied to the random-topology model only
% This is the original three-model setup. Note that the >=3-rooms filter is
% built from model 3 (rt) alone and applied only when kmodel == 3, leaving fm
% and ep unfiltered. The live code applies the filter to every model, so the
% header comment "For random topology model, filter first" describes this
% block rather than what currently runs. Resolving that difference changes
% the fm and ep entropies.
%
% model(:,:,1) = fm_simulation_matrix;
% model(:,:,2) = ep_simulation_matrix;
% model(:,:,3) = rt_simulation_matrix;
%
% bina = zeros(size(model(:,:,3),2),1);
% for it = 1:size(model(:,:,3),2)
%     rooms_visited = unique(model(:,it,3));
%     if length(rooms_visited) < 3
%         bina(it) = 0;
%     else
%         bina(it) = 1;
%     end
% end
%
% idx = find(bina);
% rt_model = model(:,find(bina),3);
%
% ... and inside the iteration loop, selecting the filtered data for rt only:
%
% if kmodel == 3
%     x = rt_model;
% else
%     x = model(:,:,kmodel);
% end

%% Parked: original entropy implementation
% Superseded by the vectorised counting in the live loop, which gives the same
% distribution far faster. Retained for the embedded correction note: the
% length-3 condition marked WAS WRONG compared x_str(t-2) and x_str(t-1)
% against the same column of T. Worth re-reading before extending the analysis
% to length-3 strings.
%
% load('dataforAbaid.mat');
% load('master_list.mat')
%
% figure
%
% model(:,:,1) = fm_simulation_matrix;
% model(:,:,2) = ep_simulation_matrix;
% model(:,:,3) = rt_simulation_matrix;
%
% for kmodel = 1:3
%
%     x = model(:,:,kmodel);
%
%     x_str = masterList(x,4);
%     x_str = reshape(x_str,size(x));
%
%     patterns = unique(x_str);
%
%     % T = combinations(patterns,patterns,patterns);
%     T = combinations(patterns,patterns);
%
%     reps = size(x,2);
%     maxt = size(x,1);
%     p = zeros(size(T,1),1);
%
%     for k = 1:reps
%         for t = 2:maxt  % 3:maxt if using 3-long words
%             for kk = 1:size(T,1)
%                 % if x_str(t-2,k) == T.patterns(kk) && x_str(t-1,k) ==
%                 % T.patterns(kk) && x_str(t,k) == T.patterns_1(kk) WAS WRONG
%                 if x_str(t-1,k) == T.patterns(kk) && x_str(t,k) == T.patterns_1(kk)
%                     p(kk) = p(kk)+1;
%                 end
%             end
%         end
%     end
%     kmodel
%
%     p = p/sum(p);
%
%     plot(p), hold on
%
%     % compute shannon entropy
%     p(p==0) = [];
%     se(kmodel) = -sum(p.*log(p));
% end
% legend('fm','ep','rt')

%% Parked: time spent in own room
% A separate analysis, not an older version of anything above: histograms of
% how many timesteps each resident spends in their starting room, one panel
% per model. Depends on the three-model "model" array assembled in the blocks
% above, so it needs that structure to run.
%
% figure
% %%%%% how much time in your room
% fm = model(:,:,1);
% subplot(1,3,1),histogram(sum(fm - fm(1,:)==0),0:10:100), title('fm')
% ep = model(:,:,2);
% subplot(1,3,2),histogram(sum(ep - ep(1,:)==0),0:10:100), title('ep')
% rt = model(:,:,3);
% subplot(1,3,3),histogram(sum(rt - rt(1,:)==0),0:10:100), title('rt')
