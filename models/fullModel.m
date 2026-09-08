clearvars; close all; clc;

%% Output location
% Resolved from this script's own location, so the folder can be moved
% without editing paths. Created if it does not already exist.
dataDir = fullfile(fileparts(mfilename('fullpath')), '..', 'data', 'fullModel_data');
if ~isfolder(dataDir), mkdir(dataDir); end
load('diaries.mat')
load('diary_data.mat')
load('master_list.mat')
load('CID_building.mat')

% This is the full model - correct topology and diary-informed transition
% probabilities.

masterListOriginal = masterList;

ts = 95;

numSimulations = 200;

dataNodeUse = zeros(numSimulations,length(V));
dataGraphPatternUse = zeros(numSimulations,length(graphPatterns));
dataDiaryPatternUse = zeros(numSimulations,length(diaryPatterns));

dataRE = zeros(numSimulations,length(V));
dataGraphPE = zeros(numSimulations,length(graphPatterns));
dataDiaryPE = zeros(numSimulations,length(diaryPatterns));

totalTime = 0;

fm_simulation_matrix = zeros(ts+1,length(room_index),numSimulations);

% --- Chain cache -------------------------------------------------------
% The six transition matrices depend only on which room the resident lives
% in, not on the simulation index: room_index names a room once per resident,
% so 594 residents occupy 259 distinct rooms. Building the chains once here
% replaces 110 x 594 = 65,340 createTransitionMatrices calls with 259, and
% 392,040 dtmc constructions with 1,554.
%
% Holds roughly 2 GiB (259 x 6 chains, each a 410x410 double). T is
% overwritten each iteration rather than accumulated, so only the chains are
% retained. Neither createTransitionMatrices nor dtmc draws random numbers,
% so this does not disturb the RNG stream used by the simulations below.
uniqueRooms = unique(room_index);                     % 259 x 1
[~, roomSlot] = ismember(room_index, uniqueRooms);    % 594 x 1, values 1..259

chainCache = cell(numel(uniqueRooms),1);
buildTimer = tic;
for u = 1:numel(uniqueRooms)
    my_room = V(uniqueRooms(u));

    [T_em, T_m, T_a, T_ee, T_le, T_n] = createTransitionMatrices(my_room,masterListOriginal,diaryData,V,E,E_num);
    T = {T_em,T_m,T_a,T_ee,T_le,T_n};

    mc = cell(1,6);
    for q = 1:6
        mc{q} = dtmc(T{q}','StateNames',V);
    end
    chainCache{u} = mc;
end
disp("Built chains for " + numel(uniqueRooms) + " rooms in " + toc(buildTimer) + " seconds.")
% -----------------------------------------------------------------------

for l = 1:numSimulations
    tic;
    disp("Beginning simulation " + l)

    simulation_matrix = zeros(96,length(room_index));

    for i = 1:length(room_index)
        ts = 15;

        F = runSimulation(chainCache{roomSlot(i)},ts,room_index,i);
        simulation_matrix(:,i) = F;
    end

    fm_simulation_matrix(:,:,l) = simulation_matrix;

    % Uncomment this to produce usage and collision statistics on the
    % simulations

    nodeUse = zeros(1,length(V));
    graphPatternUse = zeros(1,length(graphPatterns));
    diaryPatternUse = zeros(1,length(diaryPatterns));

    for i = 1:length(room_index)
        col = simulation_matrix(:,i);
        my_room = simulation_matrix(1,i);
        for j = 1:96
            nodeUse(col(j)) = nodeUse(col(j)) + 0.25;
            if simulation_matrix(j,i) == my_room
                graphPatternUse(1) = graphPatternUse(1) + 0.25;
                diaryPatternUse(1) = diaryPatternUse(1) + 0.25;
            else
                gPattern = masterList(simulation_matrix(j,i),3);
                idx = find(graphPatterns == gPattern);
                graphPatternUse(idx) = graphPatternUse(idx) + 0.25;
                dPattern = graphPatternsMapped(idx);
                idx = find(dPattern == diaryPatterns);
                diaryPatternUse(idx) = diaryPatternUse(idx) + 0.25;
            end
        end
    end

    dataNodeUse(l,:) = nodeUse;
    dataGraphPatternUse(l,:) = graphPatternUse;
    dataDiaryPatternUse(l,:) = diaryPatternUse;

    n = size(simulation_matrix, 2);
    num_pairs = n * (n - 1) / 2;
    row_length = size(simulation_matrix, 1) + 2;  % 2 for i and j, rest for comparison
    comparison_matrix = zeros(row_length, num_pairs);
    encounter_matrix = zeros(length(simulation_matrix));

    pair_idx = 1;
    for i = 1:n-1
        for j = i+1:n
            comp = zeros(size(simulation_matrix(:,i)));
            for k = 1:length(simulation_matrix(:,i))
                if simulation_matrix(k,i) > 1
                    comp(k) = simulation_matrix(k,i) == simulation_matrix(k,j);
                end
            end
            encounter_matrix(i,j) = sum(comp);
            loc = zeros(size(comp));
            loc(comp == 1) = simulation_matrix(comp == 1,i);
            comparison_matrix(:, pair_idx) = [i; j; loc];
            pair_idx = pair_idx + 1;
        end
    end

    RE = zeros(1,length(V));
    graphPE = zeros(1,length(graphPatterns));
    diaryPE = zeros(1,length(diaryPatterns));

    for i = 1:length(comparison_matrix)
        B = find(comparison_matrix(3:end,i) ~= 0);
        for j = 1:length(B)
            RE(comparison_matrix(B(j)+2,i)) = RE(comparison_matrix(B(j)+2,i))+1;
            if masterListOriginal(comparison_matrix(B(j)+2,i),3) == "room" || masterListOriginal(comparison_matrix(B(j)+2,i),3) == "suite" %*** NEED TO FIX THIS LATER ***%
                graphPE(1) = graphPE(1) + 1;
                diaryPE(1) = diaryPE(1) + 1;
            else
                GPEx = find(graphPatterns == masterList(comparison_matrix(B(j)+2,i),3));
                graphPE(GPEx) = graphPE(GPEx) + 1;
                DPEx = find(diaryPatterns == masterList(comparison_matrix(B(j)+2,i),3));
                diaryPE(DPEx) = diaryPE(DPEx) + 1;
            end
        end
    end

    dataRE(l,:) = RE;
    dataGraphPE(l,:) = graphPE;
    dataDiaryPE(l,:) = diaryPE;

    elapsedTime = toc;
    totalTime = totalTime + elapsedTime;
    disp("Simulation " + l + " took " + elapsedTime + " seconds.")
end
disp("Total simulation time: " + string(totalTime))

% Uncomment if you're producing use and collision statistics
useData = dataDiaryPatternUse;
collisionData = dataDiaryPE;
save(fullfile(dataDir,"fullModel_data.mat"), "useData", "collisionData")

save(fullfile(dataDir,'fm_data.mat'),"fm_simulation_matrix")
