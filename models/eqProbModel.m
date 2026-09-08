clearvars; close all; clc;

%% Output location
% Resolved from this script's own location, so the folder can be moved
% without editing paths. Created if it does not already exist.
dataDir = fullfile(fileparts(mfilename('fullpath')), '..', 'data', 'eqProbModel_data');
if ~isfolder(dataDir), mkdir(dataDir); end
load('diaries.mat')
load('diary_data.mat')
load('master_list.mat')
load('CID_building.mat')

% This is a model with the correct topology but equal transition
% probabilities.
%
% Differs from eqProbModel only in transposing T at the dtmc call. T is built
% column-stochastic (column i is the outgoing distribution of node i), but
% dtmc requires a row-stochastic matrix. Passing T untransposed made dtmc
% row-normalise it, simulating P(i,j) proportional to 1/deg(j) rather than the
% intended uniform 1/deg(i). fullModel and randTopModel already transpose.

nv = length(V);

A = createAdjacencyMatrix(V, E);
A = A + eye(410);

T = zeros(nv);

for i = 1:nv
    v = A(i,:);
    idx = find(v);
    T(idx, i) = 1/length(idx);
end

mc = dtmc(T','StateNames',V);   % transposed: dtmc wants row-stochastic

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

ep_simulation_matrix = zeros(ts+1,nr,numSimulations);

for l = 1:numSimulations
    tic;
    disp("Beginning simulation " + l)

    simulation_matrix = zeros(ts+1,nr);

    for i = 1:nr
        my_room = room_index(i);

        x0 = zeros(nv,1);
        x0(my_room) = 1;
        X = simulate(mc,ts,'X',x0);

        simulation_matrix(:,i) = X;
    end

    ep_simulation_matrix(:,:,l) = simulation_matrix;

    % Uncomment if you want to produce statistics about the usage and
    % collisions
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

% Uncomment if you're producing usage and collision statistics
useData = dataDiaryPatternUse;
collisionData = dataDiaryPE;
save(fullfile(dataDir,"eqProbModel_data.mat"), "useData", "collisionData")

save(fullfile(dataDir,'ep_data.mat'), 'ep_simulation_matrix')