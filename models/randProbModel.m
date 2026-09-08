clearvars; close all; clc;

%% Output location
% Resolved from this script's own location, so the folder can be moved
% without editing paths. Created if it does not already exist.
dataDir = fullfile(fileparts(mfilename('fullpath')), '..', 'data', 'randProbModel_data');
if ~isfolder(dataDir), mkdir(dataDir); end
load('diaries.mat')
load('diary_data.mat')
load('master_list.mat')
load('CID_building.mat')

% This is a model with the correct topology and random transition
% probabilities. For each node, every edge including its self-loop is given a
% uniform random weight on [0,1], and the weights out of that node are
% normalised to sum to 1. The probabilities are redrawn for each full-day
% simulation, so the run samples across probability assignments rather than
% reporting the behaviour of a single arbitrary draw.
%
% It is the counterpart of randTopModel: that model randomises the topology
% and keeps the diary-informed probabilities, this one keeps the true topology
% and randomises the probabilities.

nv = length(V);

A = createAdjacencyMatrix(V, E);
A = A + eye(nv);   % every node gets a self-loop

% Neighbour list per node, including the self-loop. Fixed across simulations
% because only the probabilities are redrawn, not the topology.
edgesOf = cell(nv,1);
for i = 1:nv
    edgesOf{i} = find(A(i,:));
end

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

rp_simulation_matrix = zeros(ts+1,nr,numSimulations);

for l = 1:numSimulations
    tic;
    disp("Beginning simulation " + l)

    % Draw a fresh transition matrix. Column i is the outgoing distribution of
    % node i, so T is column-stochastic and is transposed at the dtmc call
    % below, which requires a row-stochastic matrix.
    T = zeros(nv);
    for i = 1:nv
        idx = edgesOf{i};
        r = rand(numel(idx),1);
        T(idx,i) = r / sum(r);
    end

    mc = dtmc(T','StateNames',V);

    simulation_matrix = zeros(ts+1,nr);

    for i = 1:nr
        my_room = room_index(i);

        x0 = zeros(nv,1);
        x0(my_room) = 1;
        X = simulate(mc,ts,'X0',x0);

        simulation_matrix(:,i) = X;
    end

    rp_simulation_matrix(:,:,l) = simulation_matrix;

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

disp("Total simulation time: " + string(totalTime))

% Uncomment if you're producing usage and collision statistics
useData = dataDiaryPatternUse;
collisionData = dataDiaryPE;
save(fullfile(dataDir,"randProbModel_data.mat"), "useData", "collisionData")

save(fullfile(dataDir,'rp_data.mat'), 'rp_simulation_matrix')
