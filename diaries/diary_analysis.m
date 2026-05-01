clearvars; close all; clc;
load('diaries.mat')
format long
%%

% These vectors will store the total number of entries into each
% pattern-type coming from all diaries and the total number of self loops
% for each pattern-type coming from all diaries. One self loop means that
% from one time step to the next, agent stayed in pattern.
self_loops_total = [0 0 0 0 0 0 0 0 0 0 0 0 0];
entries_total = [0 0 0 0 0 0 0 0 0 0 0 0 0];
% There are 13 components representing the different pattern-types: 1:
% my_dorm, 2: friend_dorm, 3: community, 4: stairs, 5: elev, 6: hall, 7:
% kitchen, 8: bath, 9: llc, 10: mezzanine, 11: other, 12: outside, 13:
% lounge. NOTE: There are more than 13 patterns, we have some pattern-types
% covering multiple patterns, such as 11: other.

for i = 1:length(diaries)
    % Vectors storing the self loops and the entries for diary k.
    self_loops = [0 0 0 0 0 0 0 0 0 0 0 0 0];
    entries = [0 0 0 0 0 0 0 0 0 0 0 0 0];

    % For each diary, we analyze each of the 13 pattern-types individually.
    % First we find the self_loops data for the diary.
    for j = 1:13
        data = diaries{i}(j, :);
        total  = sum(data(1:end-1) == 1);
        stay_in = sum((data(1:end-1) == 1) & (data(2:end) == 1));
        self_loops(j) = stay_in / max(total, 1);

        % Variable tracking # of entries into pattern-type i.
        % If previous row value = 0 & current row value = 1, record entry.
        entry = sum(data(1:end-1) == 0 & data(2:end) == 1);

        % If sum(column) > 1, record entry; don't overcount
        addl_entries = data(1:end-1) == 1 & data(2:end) == 1 & (sum(diaries{i}(1:13, 1:end-1)) > 1);
        entries(j) = entry + sum(addl_entries);
    end

    % Add self_loops vector to running total of all self_loops vectors.
    self_loops_total = self_loops_total + self_loops;

    % Add entries vector to running total of all entries vectors.
    entries_total = entries_total + entries;
end

avg_self_loops = self_loops_total./length(diaries);
avg_entries = entries_total./length(diaries);

avg_self_loops = avg_self_loops';
avg_entries = avg_entries';

%% Early morning analysis
self_loops_total = [0 0 0 0 0 0 0 0 0 0 0 0 0];
entries_total = [0 0 0 0 0 0 0 0 0 0 0 0 0];

for i = 1:length(early_morning_diaries)
    % Vectors storing the self loops and the entries for diary k.
    self_loops = [0 0 0 0 0 0 0 0 0 0 0 0 0];
    entries = [0 0 0 0 0 0 0 0 0 0 0 0 0];

    % For each diary, we analyze each of the 13 pattern-types individually.
    % First we find the self_loops data for the diary.
    for j = 1:13
        data = early_morning_diaries{i}(j, :);
        total  = sum(data(1:end-1) == 1);
        stay_in = sum((data(1:end-1) == 1) & (data(2:end) == 1));
        self_loops(j) = stay_in / max(total, 1);

        % Variable tracking # of entries into pattern-type i.
        % If previous row value = 0 & current row value = 1, record entry.
        entry = sum(data(1:end-1) == 0 & data(2:end) == 1);

        % If sum(column) > 1, record entry; don't overcount
        addl_entries = data(1:end-1) == 1 & data(2:end) == 1 & (sum(early_morning_diaries{i}(1:13, 1:end-1)) > 1);
        entries(j) = entry + sum(addl_entries);
    end

    % Add self_loops vector to running total of all self_loops vectors.
    self_loops_total = self_loops_total + self_loops;

    % Add entries vector to running total of all entries vectors.
    entries_total = entries_total + entries;
end

early_morning_avg_self_loops = self_loops_total./length(diaries);
early_morning_avg_entries = entries_total./length(diaries);

%% Morning analysis
self_loops_total = [0 0 0 0 0 0 0 0 0 0 0 0 0];
entries_total = [0 0 0 0 0 0 0 0 0 0 0 0 0];

for i = 1:length(morning_diaries)
    % Vectors storing the self loops and the entries for diary k.
    self_loops = [0 0 0 0 0 0 0 0 0 0 0 0 0];
    entries = [0 0 0 0 0 0 0 0 0 0 0 0 0];

    % For each diary, we analyze each of the 13 pattern-types individually.
    % First we find the self_loops data for the diary.
    for j = 1:13
        data = morning_diaries{i}(j, :);
        total  = sum(data(1:end-1) == 1);
        stay_in = sum((data(1:end-1) == 1) & (data(2:end) == 1));
        self_loops(j) = stay_in / max(total, 1);

        % Variable tracking # of entries into pattern-type i.
        % If previous row value = 0 & current row value = 1, record entry.
        entry = sum(data(1:end-1) == 0 & data(2:end) == 1);

        % If sum(column) > 1, record entry; don't overcount
        addl_entries = data(1:end-1) == 1 & data(2:end) == 1 & (sum(morning_diaries{i}(1:13, 1:end-1)) > 1);
        entries(j) = entry + sum(addl_entries);
    end

    % Add self_loops vector to running total of all self_loops vectors.
    self_loops_total = self_loops_total + self_loops;

    % Add entries vector to running total of all entries vectors.
    entries_total = entries_total + entries;
end

morning_avg_self_loops = self_loops_total./length(diaries);
morning_avg_entries = entries_total./length(diaries);

%% Afternoon analysis
self_loops_total = [0 0 0 0 0 0 0 0 0 0 0 0 0];
entries_total = [0 0 0 0 0 0 0 0 0 0 0 0 0];

for i = 1:length(afternoon_diaries)
    % Vectors storing the self loops and the entries for diary k.
    self_loops = [0 0 0 0 0 0 0 0 0 0 0 0 0];
    entries = [0 0 0 0 0 0 0 0 0 0 0 0 0];

    % For each diary, we analyze each of the 13 pattern-types individually.
    % First we find the self_loops data for the diary.
    for j = 1:13
        data = afternoon_diaries{i}(j, :);
        total  = sum(data(1:end-1) == 1);
        stay_in = sum((data(1:end-1) == 1) & (data(2:end) == 1));
        self_loops(j) = stay_in / max(total, 1);

        % Variable tracking # of entries into pattern-type i.
        % If previous row value = 0 & current row value = 1, record entry.
        entry = sum(data(1:end-1) == 0 & data(2:end) == 1);

        % If sum(column) > 1, record entry; don't overcount
        addl_entries = data(1:end-1) == 1 & data(2:end) == 1 & (sum(afternoon_diaries{i}(1:13, 1:end-1)) > 1);
        entries(j) = entry + sum(addl_entries);
    end

    % Add self_loops vector to running total of all self_loops vectors.
    self_loops_total = self_loops_total + self_loops;

    % Add entries vector to running total of all entries vectors.
    entries_total = entries_total + entries;
end

afternoon_avg_self_loops = self_loops_total./length(diaries);
afternoon_avg_entries = entries_total./length(diaries);

%% Early evening analysis
self_loops_total = [0 0 0 0 0 0 0 0 0 0 0 0 0];
entries_total = [0 0 0 0 0 0 0 0 0 0 0 0 0];

for i = 1:length(early_evening_diaries)
    % Vectors storing the self loops and the entries for diary k.
    self_loops = [0 0 0 0 0 0 0 0 0 0 0 0 0];
    entries = [0 0 0 0 0 0 0 0 0 0 0 0 0];

    % For each diary, we analyze each of the 13 pattern-types individually.
    % First we find the self_loops data for the diary.
    for j = 1:13
        data = early_evening_diaries{i}(j, :);
        total  = sum(data(1:end-1) == 1);
        stay_in = sum((data(1:end-1) == 1) & (data(2:end) == 1));
        self_loops(j) = stay_in / max(total, 1);

        % Variable tracking # of entries into pattern-type i.
        % If previous row value = 0 & current row value = 1, record entry.
        entry = sum(data(1:end-1) == 0 & data(2:end) == 1);

        % If sum(column) > 1, record entry; don't overcount
        addl_entries = data(1:end-1) == 1 & data(2:end) == 1 & (sum(early_evening_diaries{i}(1:13, 1:end-1)) > 1);
        entries(j) = entry + sum(addl_entries);
    end

    % Add self_loops vector to running total of all self_loops vectors.
    self_loops_total = self_loops_total + self_loops;

    % Add entries vector to running total of all entries vectors.
    entries_total = entries_total + entries;
end

early_evening_avg_self_loops = self_loops_total./length(diaries);
early_evening_avg_entries = entries_total./length(diaries);

%% Late evening analysis
self_loops_total = [0 0 0 0 0 0 0 0 0 0 0 0 0];
entries_total = [0 0 0 0 0 0 0 0 0 0 0 0 0];

for i = 1:length(late_evening_diaries)
    % Vectors storing the self loops and the entries for diary k.
    self_loops = [0 0 0 0 0 0 0 0 0 0 0 0 0];
    entries = [0 0 0 0 0 0 0 0 0 0 0 0 0];

    % For each diary, we analyze each of the 13 pattern-types individually.
    % First we find the self_loops data for the diary.
    for j = 1:13
        data = late_evening_diaries{i}(j, :);
        total  = sum(data(1:end-1) == 1);
        stay_in = sum((data(1:end-1) == 1) & (data(2:end) == 1));
        self_loops(j) = stay_in / max(total, 1);

        % Variable tracking # of entries into pattern-type i.
        % If previous row value = 0 & current row value = 1, record entry.
        entry = sum(data(1:end-1) == 0 & data(2:end) == 1);

        % If sum(column) > 1, record entry; don't overcount
        addl_entries = data(1:end-1) == 1 & data(2:end) == 1 & (sum(late_evening_diaries{i}(1:13, 1:end-1)) > 1);
        entries(j) = entry + sum(addl_entries);
    end

    % Add self_loops vector to running total of all self_loops vectors.
    self_loops_total = self_loops_total + self_loops;

    % Add entries vector to running total of all entries vectors.
    entries_total = entries_total + entries;
end

late_evening_avg_self_loops = self_loops_total./length(diaries);
late_evening_avg_entries = entries_total./length(diaries);

%% Night analysis
self_loops_total = [0 0 0 0 0 0 0 0 0 0 0 0 0];
entries_total = [0 0 0 0 0 0 0 0 0 0 0 0 0];

for i = 1:length(night_diaries)
    % Vectors storing the self loops and the entries for diary k.
    self_loops = [0 0 0 0 0 0 0 0 0 0 0 0 0];
    entries = [0 0 0 0 0 0 0 0 0 0 0 0 0];

    % For each diary, we analyze each of the 13 pattern-types individually.
    % First we find the self_loops data for the diary.
    for j = 1:13
        data = night_diaries{i}(j, :);
        total  = sum(data(1:end-1) == 1);
        stay_in = sum((data(1:end-1) == 1) & (data(2:end) == 1));
        self_loops(j) = stay_in / max(total, 1);

        % Variable tracking # of entries into pattern-type i.
        % If previous row value = 0 & current row value = 1, record entry.
        entry = sum(data(1:end-1) == 0 & data(2:end) == 1);

        % If sum(column) > 1, record entry; don't overcount
        addl_entries = data(1:end-1) == 1 & data(2:end) == 1 & (sum(night_diaries{i}(1:13, 1:end-1)) > 1);
        entries(j) = entry + sum(addl_entries);
    end

    % Add self_loops vector to running total of all self_loops vectors.
    self_loops_total = self_loops_total + self_loops;

    % Add entries vector to running total of all entries vectors.
    entries_total = entries_total + entries;
end

night_avg_self_loops = self_loops_total./length(diaries);
night_avg_entries = entries_total./length(diaries);

selfLoops = [early_morning_avg_self_loops; morning_avg_self_loops; afternoon_avg_self_loops; early_evening_avg_self_loops; late_evening_avg_self_loops; night_avg_self_loops]';
entries = [early_morning_avg_entries; morning_avg_entries; afternoon_avg_entries; early_evening_avg_entries; late_evening_avg_entries; night_avg_entries]';

diaryData = [diaryPatterns compose("%.8g",selfLoops) compose("%.8g",entries)];

save('diary_data.mat','diaryData','selfLoops','entries','avg_self_loops','avg_entries')