clearvars; close all; clc;
load('diaries.mat')
load('diary_data.mat')
load('master_list.mat')
load('CID_building.mat')

% This is the full model

masterListOriginal = masterList;

ts = 95;

numSimulations = 30;

dataNodeUse = zeros(numSimulations,length(V));
dataGraphPatternUse = zeros(numSimulations,length(graphPatterns));
dataDiaryPatternUse = zeros(numSimulations,length(diaryPatterns));

dataRE = zeros(numSimulations,length(V));
dataGraphPE = zeros(numSimulations,length(graphPatterns));
dataDiaryPE = zeros(numSimulations,length(diaryPatterns));

totalTime = 0;

fm_simulation_matrix = zeros(ts+1,length(room_index),numSimulations);

for l = 1:numSimulations
    tic;
    disp("Beginning simulation " + l)

    simulation_matrix = zeros(96,length(room_index));

    for i = 1:length(room_index)
        my_room = V(room_index(i));
        ts = 15;

        [T_em, T_m, T_a, T_ee, T_le, T_n] = createTransitionMatrices(my_room,masterListOriginal,diaryData,V,E,E_num);
        T = {T_em,T_m,T_a,T_ee,T_le,T_n};

        F = runSimulation(T,V,ts,room_index,i);
        simulation_matrix(:,i) = F;
    end

    fm_simulation_matrix(:,:,l) = simulation_matrix;

    % Uncomment this to produce usage and collision statistics on the
    % simulations

    % nodeUse = zeros(1,length(V));
    % graphPatternUse = zeros(1,length(graphPatterns));
    % diaryPatternUse = zeros(1,length(diaryPatterns));
    % 
    % for i = 1:length(room_index)
    %     col = simulation_matrix(:,i);
    %     my_room = simulation_matrix(1,i);
    %     for j = 1:96
    %         nodeUse(col(j)) = nodeUse(col(j)) + 0.25;
    %         if simulation_matrix(j,i) == my_room
    %             graphPatternUse(1) = graphPatternUse(1) + 0.25;
    %             diaryPatternUse(1) = diaryPatternUse(1) + 0.25;
    %         else
    %             gPattern = masterList(simulation_matrix(j,i),3);
    %             idx = find(graphPatterns == gPattern);
    %             graphPatternUse(idx) = graphPatternUse(idx) + 0.25;
    %             dPattern = graphPatternsMapped(idx);
    %             idx = find(dPattern == diaryPatterns);
    %             diaryPatternUse(idx) = diaryPatternUse(idx) + 0.25;
    %         end
    %     end
    % end
    % 
    % dataNodeUse(l,:) = nodeUse;
    % dataGraphPatternUse(l,:) = graphPatternUse;
    % dataDiaryPatternUse(l,:) = diaryPatternUse;
    % 
    % n = size(simulation_matrix, 2);
    % num_pairs = n * (n - 1) / 2;
    % row_length = size(simulation_matrix, 1) + 2;  % 2 for i and j, rest for comparison
    % comparison_matrix = zeros(row_length, num_pairs);
    % encounter_matrix = zeros(length(simulation_matrix));
    % 
    % pair_idx = 1;
    % for i = 1:n-1
    %     for j = i+1:n
    %         comp = zeros(size(simulation_matrix(:,i)));
    %         for k = 1:length(simulation_matrix(:,i))
    %             if simulation_matrix(k,i) > 1
    %                 comp(k) = simulation_matrix(k,i) == simulation_matrix(k,j);
    %             end
    %         end
    %         encounter_matrix(i,j) = sum(comp);
    %         loc = zeros(size(comp));
    %         loc(comp == 1) = simulation_matrix(comp == 1,i);
    %         comparison_matrix(:, pair_idx) = [i; j; loc];
    %         pair_idx = pair_idx + 1;
    %     end
    % end
    % 
    % RE = zeros(1,length(V));
    % graphPE = zeros(1,length(graphPatterns));
    % diaryPE = zeros(1,length(diaryPatterns));
    % 
    % for i = 1:length(comparison_matrix)
    %     B = find(comparison_matrix(3:end,i) ~= 0);
    %     for j = 1:length(B)
    %         RE(comparison_matrix(B(j)+2,i)) = RE(comparison_matrix(B(j)+2,i))+1;
    %         if masterListOriginal(comparison_matrix(B(j)+2,i),3) == "room" || masterListOriginal(comparison_matrix(B(j)+2,i),3) == "suite" %*** NEED TO FIX THIS LATER ***%
    %             graphPE(1) = graphPE(1) + 1;
    %             diaryPE(1) = diaryPE(1) + 1;
    %         else
    %             GPEx = find(graphPatterns == masterList(comparison_matrix(B(j)+2,i),3));
    %             graphPE(GPEx) = graphPE(GPEx) + 1;
    %             DPEx = find(diaryPatterns == masterList(comparison_matrix(B(j)+2,i),3));
    %             diaryPE(DPEx) = diaryPE(DPEx) + 1;
    %         end
    %     end
    % end
    % 
    % dataRE(l,:) = RE;
    % dataGraphPE(l,:) = graphPE;
    % dataDiaryPE(l,:) = diaryPE;

    elapsedTime = toc;
    totalTime = totalTime + elapsedTime;
    disp("Simulation " + l + " took " + elapsedTime + " seconds.")
end
disp("Total simulation time: " + string(totalTime))

%% Uncomment if you're producing use and collision statistics
% useData = dataDiaryPatternUse;
% collisionData = dataDiaryPE;

save('fm_data.mat',"fm_simulation_matrix")
