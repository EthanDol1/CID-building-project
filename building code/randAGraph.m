clearvars; close all; clc;
load('diaries.mat')
load('diary_data.mat')
load('master_list.mat')
load('CID_building.mat')

function A = createAdjacencyMatrix(V,E)
    A = zeros(length(V));
    for k = 1:length(E)
        A(find(V == E(k,1)), find(V == E(k,2)))=1;
    end
    A = A+A'; % Make the adjacency matrix symmetric.
end

A = createAdjacencyMatrix(V, E);

randA = randomizeA(A);

figure
g = graph(randA);
p = plot(g,'Layout','circle');

node_markers = ["x", "+", "o", ">", ">", "^", "s", "s", "<", "<", "v", "p", "^", ">", "*", "d", "o", "o", "d"];
node_colors = hsv(length(graphPatterns));
node_type = zeros(length(V),1);

% Here you can input which room you wish to mark as your room and which
% room you wish to mark as your friends' rooms.
my_room = "roomA301";
masterList(find(V == my_room),3:4) = "my dorm";
masterList(find(V == my_room),5:6) = [avg_self_loops(1) avg_entries(1)];
masterList(find(V == my_room),7:end) = diaryData(1,2:end);

% Here we label each node with its pattern. The correct pattern of
% the room is determined from the name of the room.
for i = 1:length(V)
    node_type(i) = find(masterList(i,3)==graphPatterns);
end

% Here we label the nodes of the graph and color them according to their
% pattern.
for k = 1:length(graphPatterns)
    highlight(p, find(node_type==k), 'NodeColor', node_colors(k,:), 'Marker',node_markers{k}, 'MarkerSize',2)
end
set(gcf,'PaperPosition',[0,0,6,6]); print('-dpdf','randA.pdf')