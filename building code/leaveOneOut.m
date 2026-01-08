%% Leave one out analysis
clearvars; close all; clc;

load("diaries.mat", "diaries", "diaryPatterns")
load("diary_data.mat", "avg_self_loops", "avg_entries") % Note: avg_self_loops and avg_entries are being loaded in from the full diary analysis
load("CID_building.mat", "room_index")

fullDiaries = diaries;

leaveOneOutData = zeros(length(room_index), 13, 45);
totalTime = 0;
for l = 1:45
    disp("Starting LeaveOneOut simulations " + l)
    tic;
    diaries = fullDiaries;

    % We train on all diaries except the one left out
    diaries(l) = [];
    
    % Partition the diaries according to time of day
    early_morning_diaries = cell(length(diaries),1);
    for i = 1:length(diaries)
        early_morning_diaries{i} = diaries{i}(:,3:18);
    end
    
    morning_diaries = cell(length(diaries),1);
    for i = 1:length(diaries)
        morning_diaries{i} = diaries{i}(:,19:34);
    end
    
    afternoon_diaries = cell(length(diaries),1);
    for i = 1:length(diaries)
        afternoon_diaries{i} = diaries{i}(:,35:50);
    end
    
    early_evening_diaries = cell(length(diaries),1);
    for i = 1:length(diaries)
        early_evening_diaries{i} = diaries{i}(:,51:65);
    end
    
    late_evening_diaries = cell(length(diaries),1);
    for i = 1:length(diaries)
        late_evening_diaries{i} = diaries{i}(:,67:82);
    end
    
    night_diaries = cell(length(diaries),1);
    for i = 1:length(diaries)
        night_diaries{i} = [diaries{i}(:,83:96) diaries{i}(:,1:2)];
    end
    
    % Perform diary analysis
    format long
    
    % Early morning analysis
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
    
    % Morning analysis
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
    
    % Afternoon analysis
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
    
    % Early evening analysis
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
    
    % Late evening analysis
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
    
    % Night analysis
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
    
    % Recreate the master list
    opts = spreadsheetImportOptions;
    opts.Sheet = "nodes";
    opts.DataRange = "A1:A410";
    opts.VariableNames = "Nodes";
    opts.VariableTypes = "string";
    V = readtable("C:\Users\13049\Desktop\matlab code\Research Code\building project\building code\CID_building.xlsx", opts, "UseExcel", false);
    clear opts
    opts = spreadsheetImportOptions("NumVariables", 2);
    opts.Sheet = "edges";
    opts.DataRange = "A1:B489";
    opts.VariableNames = ["Edge 1", "Edge 2"];
    opts.VariableTypes = ["string", "string"];
    E = readtable("C:\Users\13049\Desktop\matlab code\Research Code\building project\building code\CID_building.xlsx", opts, "UseExcel", false);
    clear opts
    
    V = table2array(V);
    E = table2array(E);
    
    E_num = zeros(size(E));
    for ind = 1:length(E)
        E_num(ind,1) = find(V==E(ind,1));
        E_num(ind,2) = find(V==E(ind,2));
    end
    
    V_num = (1:length(V))';
    
    graphPatterns = ["my dorm", "friend dorm", "office", "hall", "alcove", "stairs", "lounge", "llc", "suite", "room", "bath", "kitchen", "elev", ...
        "maincorr", "outside", "community", "makerspace", "meetingstudy", "mezz"];
    graphPatternsMapped = ["my dorm", "friend dorm", "other", "hall", "hall", "stairs", "lounge", "llc", "n/a", "n/a", "bath", "kitchen", "elev", ...
        "hall", "outside", "community", "other", "other", "mezz"];
    
    nodePatterns = strings(length(V),1); % List of patterns of every node
    for i = 1:length(V_num)
        nodePatterns(i) = graphPatterns{find(cellfun(@(p) contains(V{i}, p), graphPatterns),1)};
    end
    
    nodeDiaryPatterns = strings(length(V),1);
    for i = 1:length(V_num)
        nodeDiaryPatterns(i) = graphPatternsMapped{find(cellfun(@(p) contains(V{i}, p), graphPatterns),1)};
    end
    
    masterList = [num2cell(V_num) V nodePatterns nodeDiaryPatterns];
    
    list1 = strings(length(V),1);
    list2 = strings(length(V),1);
    for i = 1:length(V_num)
        if masterList(i,4) == "n/a"
            list1(i) = 0;
            list2(i) = 0;
        else
            list1(i) = compose("%.8g",avg_self_loops(find(masterList(i,4) == diaryPatterns)));
            list2(i) = compose("%.8g",avg_entries(find(masterList(i,4) == diaryPatterns)));
        end
    end
    masterList = [masterList list1 list2];
    
    for i = 1:12
        list = zeros(length(V),1);
        for j = 1:length(V)
            if masterList(j,4) == "n/a"
                list(j) = 0;
            else
                list(j) = diaryData(find(cellfun(@(p) contains(nodeDiaryPatterns{j}, p), diaryData(:,1)),1),i+1);
            end
        end
        masterList = [masterList compose("%.8g",list)];
    end
    
    % We iterate through all dorms. We generate 100 trajectories per dorm and
    % we find the average time usage for each dorm. We store those
    format short
    avgPatternUse = zeros(length(room_index),13);
    for k = 1:length(room_index)
    
        x = room_index(k);
        my_room = V(x);
        [T_em, T_m, T_a, T_ee, T_le, T_n] = createTransitionMatrices(my_room,masterList,diaryData,V,E,E_num);
        
        % Generate and store n trajectories starting from a given location
        transitionMatrices = {T_em,T_m,T_a,T_ee,T_le,T_n};
        
        n = 80;
        trajectoryMatrix = zeros(96,n);
        
        for i = 1:n
        
            ts = 15; % number of time steps in early morning
            x0 = zeros(410,1); % init state vector
            x0(x) = 1; % start in roomA301/my_room
            mc = dtmc(T_em','StateNames',V); % generate trajectory using T_em
            X0 = simulate(mc,ts,'X0',x0);
        
            x1 = zeros(410,1);
            x1(X0(end)) = 1;
            mc = dtmc(T_m','StateNames',V);
            X1 = simulate(mc,ts+1,'X0',x1);
            X1 = X1(2:end);
        
            x2 = zeros(410,1);
            x2(X1(end)) = 1;
            mc = dtmc(T_a','StateNames',V);
            X2 = simulate(mc,ts+1,'X0',x2);
            X2 = X2(2:end);
        
            x3 = zeros(410,1);
            x3(X1(end)) = 1;
            mc = dtmc(T_ee','StateNames',V);
            X3 = simulate(mc,ts+1,'X0',x3);
            X3 = X3(2:end);
        
            x4 = zeros(410,1);
            x4(X1(end)) = 1;
            mc = dtmc(T_le','StateNames',V);
            X4 = simulate(mc,ts+1,'X0',x4);
            X4 = X4(2:end);
        
            x5 = zeros(410,1);
            x5(X1(end)) = 1;
            mc = dtmc(T_n','StateNames',V);
            X5 = simulate(mc,ts+1,'X0',x5);
            X5 = X5(2:end);
        
            F = [X0;X1;X2;X3;X4;X5];
        
            trajectoryMatrix(:,i) = F; % Store the trajectory for the current iteration
        end
        
        % Perform use analysis on the 100 simulated trajectories
        diaryPatternUse = zeros(n,length(diaryPatterns));
        
        for i = 1:n
            col = trajectoryMatrix(:,i);
            my_room = x;
            for j = 1:96
                if col(j) == my_room
                    diaryPatternUse(i,1) = diaryPatternUse(i,1) + 0.25;
                else
                    gPattern = masterList(trajectoryMatrix(j,i),3);
                    idx = find(graphPatterns == gPattern);
                    dPattern = graphPatternsMapped(idx);
                    idx = find(dPattern == diaryPatterns);
                    diaryPatternUse(i,idx) = diaryPatternUse(i,idx) + 0.25;
                end
            end
        end
        
        avgPatternUse(k,:) = mean(diaryPatternUse);
    end
    leaveOneOutData(:,:,l) = avgPatternUse;
    elapsedTime = toc;
    totalTime = totalTime + elapsedTime;
    disp("LeaveOneOut Simulation " + l + " took " + elapsedTime + " seconds.")
end
disp("Total simulation time: " + string(totalTime))
% save("leaveOneOut.mat","leaveOneOutData")