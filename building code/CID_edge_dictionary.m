clearvars; close all; clc;
load('diaries.mat')
load('diary_data.mat')
load('master_list.mat')
load('CID_building.mat')
masterListOriginal = masterList; % only to be used for making copies of masterList

V_num = 1:length(V);
edgeList = cell(size(V_num));

for i = 1:length(V)
    c1 = contains(E(:,1), V(i));
    c2 = contains(E(:,2), V(i));
    c = c1|c2;
    edges_to_weight = E_num(c,:); % list of edge numbers
    num_edges = size(edges_to_weight(:,1),1); % number of edges

    for j = 1:num_edges
        if edges_to_weight(j,2) == i
            placeholder = edges_to_weight(j,:);
            edges_to_weight(j,1) = placeholder(2);
            edges_to_weight(j,2) = placeholder(1);
        end
    end
    edgeList{i} = edges_to_weight(:,2);
end

edgeDictionary = dictionary(V_num,edgeList);

save('edgeDictionary.mat','edgeDictionary')