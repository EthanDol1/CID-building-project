clearvars; close all; clc;

%% Output location
% Resolved from this script's own location, so the folder can be moved
% without editing paths. Created if it does not already exist.
dataDir = fullfile(fileparts(mfilename('fullpath')), '..', 'data', 'randTopModel_data');
if ~isfolder(dataDir), mkdir(dataDir); end
load('diaries.mat')
load('diary_data.mat')
load('master_list.mat')
load('CID_building.mat')
load('edgeDictionary.mat')

% This a model with the a randomized topology (same degree for each node,
% but random connections), but diary-informed transition probabilities.

nv = length(V);

A = createAdjacencyMatrix(V, E);

ts = 95;

nr = length(room_index);

numSimulations = 200;

dataNodeUse = zeros(numSimulations,nv);
dataGraphPatternUse = zeros(numSimulations,length(graphPatterns));
dataDiaryPatternUse = zeros(numSimulations,length(diaryPatterns));

dataRE = zeros(numSimulations,nv);
dataGraphPE = zeros(numSimulations,length(graphPatterns));
dataDiaryPE = zeros(numSimulations,length(diaryPatterns));

totalTime = 0;

rt_simulation_matrix = zeros(ts+1,nr,numSimulations);

for l = 1:numSimulations
    tic;
    disp("Beginning simulation " + l)

    randA = randomizeA(A);
    randA = randA+eye(length(randA));

    E = strings(489,2);
    E_num = zeros(489,2);
    
    for i = 1:nv
        for j = i+1:nv
            if randA(i,j)==1
                idx = find(E_num(:,1) == 0, 1);
                E_num(idx,:) = [i, j];
                E(idx,:) = [masterList(i,2), masterList(j,2)];
            end
        end
    end

    simulation_matrix = zeros(96,nr);
    % The six transition matrices depend only on which room the resident
    % lives in. room_index names a room once per resident and lists roommates
    % consecutively, so rebuilding only when the room number changes cuts this
    % from 594 builds per simulation to 259. The cache cannot be carried
    % across the outer loop: randomizeA rewires the graph every simulation, so
    % E and E_num differ each time.
    lastRoom = -1;
    mc = cell(1,6);
    ts = 15;

    for i = 1:nr
        if room_index(i) ~= lastRoom
            my_room = V(room_index(i));

            [T_em, T_m, T_a, T_ee, T_le, T_n] = createTransitionMatrices(my_room,masterList,diaryData,V,E,E_num);
            T = {T_em,T_m,T_a,T_ee,T_le,T_n};

            for q = 1:6
                mc{q} = dtmc(T{q}','StateNames',V);
            end
            lastRoom = room_index(i);
        end

        F = runSimulation(mc,ts,room_index,i);
        simulation_matrix(:,i) = F;
    end

    rt_simulation_matrix(:,:,l) = simulation_matrix;
    
    % Uncomment these if you want to produce usage and collision statistics
    nodeUse = zeros(1,nv);
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
            if masterList(comparison_matrix(B(j)+2,i),3) == "room" || masterList(comparison_matrix(B(j)+2,i),3) == "suite" %*** NEED TO FIX THIS LATER ***%
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

% Uncomment if you're producing the usage and collision statistics
useData = dataDiaryPatternUse;
collisionData = dataDiaryPE;
save(fullfile(dataDir,"randTopModel_data.mat"), "useData", "collisionData")

save(fullfile(dataDir,'rt_data.mat'),"rt_simulation_matrix")