clearvars; close all; clc;
resultsDir = fullfile(fileparts(mfilename('fullpath')), '..', 'results');
if ~isfolder(resultsDir), mkdir(resultsDir); end

load('diaries.mat')

% This script plots the self loop probabilities and avg number of entries
% for each room type and each time period as you add more diaries. The
% point is to demonstrate that the values are converging.

diaryPatternLabels = ["My Dorm", "Friend Dorm", "Comm. Assembly", "Stairs", "Elevator", "Hall", "Kitchen", "Bathroom", "LLC Lounge", "Mezzanine", "Other", "Outside", "Lounge"];
titles = ["Early Morning", "Morning", "Afternoon", "Early Evening", "Late Evening", "Night"];

em_self_loops_conv_array = zeros(45, 13);
em_entries_conv_array = zeros(45,13);

m_self_loops_conv_array = zeros(45, 13);
m_entries_conv_array = zeros(45,13);

a_self_loops_conv_array = zeros(45, 13);
a_entries_conv_array = zeros(45,13);

ee_self_loops_conv_array = zeros(45, 13);
ee_entries_conv_array = zeros(45,13);

le_self_loops_conv_array = zeros(45, 13);
le_entries_conv_array = zeros(45,13);

n_self_loops_conv_array = zeros(45, 13);
n_entries_conv_array = zeros(45,13);

self_loops_conv = {em_self_loops_conv_array, m_self_loops_conv_array, a_self_loops_conv_array, ee_self_loops_conv_array, le_self_loops_conv_array, n_self_loops_conv_array};
entries_conv = {em_entries_conv_array, m_entries_conv_array, a_entries_conv_array, ee_entries_conv_array, le_entries_conv_array, n_entries_conv_array};

% The diary set for each time period, in the same order as self_loops_conv,
% entries_conv and titles. The loop below indexes this so that each period is
% computed from its own diaries.
diarySets = {early_morning_diaries, morning_diaries, afternoon_diaries, early_evening_diaries, late_evening_diaries, night_diaries};

for l = 1:length(self_loops_conv)
    period_diaries = diarySets{l};
    for k = 1:45
        self_loops_total = zeros(1,13);
        entries_total = zeros(1,13);
    
        for i = 1:k
            % Vectors storing the self loops and the entries for diary k.
            self_loops = [0 0 0 0 0 0 0 0 0 0 0 0 0];
            entries = [0 0 0 0 0 0 0 0 0 0 0 0 0];
    
            % For each diary, we analyze each of the 13 pattern-types individually.
            % First we find the self_loops data for the diary.
            for j = 1:13
                data = period_diaries{i}(j, :);
                total  = sum(data(1:end-1) == 1);
                stay_in = sum((data(1:end-1) == 1) & (data(2:end) == 1));
                self_loops(j) = stay_in / max(total, 1);
    
                % Variable tracking # of entries into pattern-type i.
                % If previous row value = 0 & current row value = 1, record entry.
                entry = sum(data(1:end-1) == 0 & data(2:end) == 1);
    
                % If sum(column) > 1, record entry; don't overcount
                addl_entries = data(1:end-1) == 1 & data(2:end) == 1 & (sum(period_diaries{i}(1:13, 1:end-1)) > 1);
                entries(j) = entry + sum(addl_entries);
            end
    
            % Add self_loops vector to running total of all self_loops vectors.
            self_loops_total = self_loops_total + self_loops;
    
            % Add entries vector to running total of all entries vectors.
            entries_total = entries_total + entries;
        end
    
        self_loops_conv{l}(k,:) = self_loops_total./k;
        entries_conv{l}(k,:) = entries_total./k;
    end
end
%%

% MATLAB's default color order only has 7 colors, so with 13 pattern-types
% the colors repeat and series become indistinguishable. Below is a 13-color
% qualitative palette; colors 1-7 are drawn solid and 8-13 dashed, so no two
% series ever share both a color and a line style.
patternColors = [0.1216 0.4667 0.7059    % My Dorm
                 1.0000 0.4980 0.0549    % Friend Dorm
                 0.1725 0.6275 0.1725    % Comm. Assembly
                 0.8392 0.1529 0.1569    % Stairs
                 0.5804 0.4039 0.7412    % Elevator
                 0.5490 0.3373 0.2941    % Hall
                 0.8902 0.4667 0.7608    % Kitchen
                 0.0902 0.7451 0.8118    % Bathroom
                 0.7373 0.7412 0.1333    % LLC Lounge
                 0.4980 0.4980 0.4980    % Mezzanine
                 0.2235 0.2314 0.4745    % Other
                 0.5490 0.4275 0.1922    % Outside
                 0.0000 0.0000 0.0000];  % Lounge
patternStyles = [repmat({'-'},7,1); repmat({'--'},6,1)];

% A 13-entry legend will not fit on one row above a 3x2 layout, so the figure
% is sized explicitly and the legend wrapped onto two rows of seven. Sizing
% the figure rather than relying on the on-screen window also makes the saved
% PNG reproducible regardless of the display it was generated on.
figWidth = 16;   % inches
figHeight = 11;

figure('Units','inches','Position',[1 1 figWidth figHeight]);
t = tiledlayout(3,2);
t.TileSpacing = 'compact';
t.Padding = 'compact';
for l = 1:length(self_loops_conv)
    ax = nexttile;
    h = plot(1:size(self_loops_conv{l},1), self_loops_conv{l}, 'LineWidth',1.5);
    set(h, {'Color'}, num2cell(patternColors,2));
    set(h, {'LineStyle'}, patternStyles);
    xlabel('Number of diaries (k)', 'FontSize', 14);
    ylabel('Self-loop probability', 'FontSize', 14);
    title(titles(l), 'FontSize', 16);
end
sgtitle(t, 'Self-loop Probability Convergence', 'FontSize', 20);
lgd = legend(ax, diaryPatternLabels, 'FontSize',12);
lgd.Layout.Tile = 'north';
lgd.NumColumns = 7;
set(findall(gcf,'Type','axes'),'Toolbar',[]);   % keep the hover toolbar out of the export
exportgraphics(gcf, fullfile(resultsDir,'diary-convergence-self-loops.png'), 'Resolution', 200);

figure('Units','inches','Position',[1 1 figWidth figHeight]);
t = tiledlayout(3,2);
t.TileSpacing = 'compact';
t.Padding = 'compact';
for l = 1:length(entries_conv)
    ax = nexttile;
    h = plot(1:size(entries_conv{l},1), entries_conv{l}, 'LineWidth',1.5);
    set(h, {'Color'}, num2cell(patternColors,2));
    set(h, {'LineStyle'}, patternStyles);
    xlabel('Number of diaries (k)', 'FontSize', 14);
    ylabel('Avg # of entries', 'FontSize', 14);
    title(titles(l), 'FontSize', 16);
end
sgtitle(t, 'Avg # of Entries Convergence', 'FontSize', 20);
lgd = legend(ax, diaryPatternLabels, 'FontSize',12);
lgd.Layout.Tile = 'north';
lgd.NumColumns = 7;
set(findall(gcf,'Type','axes'),'Toolbar',[]);   % keep the hover toolbar out of the export
exportgraphics(gcf, fullfile(resultsDir,'diary-convergence-entries.png'), 'Resolution', 200);
