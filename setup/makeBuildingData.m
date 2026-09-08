%% makeBuildingData
% Builds CID_building.mat from the node and edge lists in CID_building.xlsx.
%
% This is the first script in the pipeline. It replaces the CID_building.mat
% save that used to live in old models/CID_building_code_ti.m, which could not
% be re-run from scratch: it loaded master_list.mat and edgeDictionary.mat,
% but CID_master_list.m and CID_edge_dictionary.m both need CID_building.mat
% in turn. Nothing below depends on any .mat file, so the chain now starts here.
%
% Run order:
%   1. makeBuildingData      -> CID_building.mat   (this script)
%   2. write_diaries         -> diaries.mat
%   3. diary_analysis        -> diary_data.mat
%   4. CID_master_list       -> master_list.mat
%   5. CID_edge_dictionary   -> edgeDictionary.mat
%
% Output variables:
%   V          410x1 string, room names (node i is V(i))
%   E          489x2 string, edge list by room name
%   E_num      489x2 double, the same edge list by node number
%   A          410x410 symmetric adjacency matrix, no self loops
%   room_index 594x1 double, node number of the room each of the 594
%              residents lives in

clearvars; close all; clc;

overwrite = false;  % set true to replace an existing CID_building.mat

%% Section 0: input and output files
% EDIT THIS to point at CID_building.xlsx wherever it lives on your machine.
buildingFile = "C:\Users\ethan\OneDrive\Desktop\PLOS One Paper\Copy_of_BUILD Code\data\CID_building.xlsx";
outputFile = "CID_building.mat";  % written to the current folder

if ~isfile(buildingFile)
    error('makeBuildingData:missingInput', ...
        'Could not find %s', buildingFile);
end

if isfile(outputFile) && ~overwrite
    error('makeBuildingData:willNotOverwrite', ...
        ['%s already exists. Everything downstream loads it, so it is not ' ...
         'overwritten by default. Set overwrite = true above to replace it.'], ...
        outputFile);
end

%% Section 1: read the node and edge lists
% V is the complete list of nodes (rooms). E is the complete list of edges
% (connections between rooms).
opts = spreadsheetImportOptions;
opts.Sheet = "nodes";
opts.DataRange = "A1:A410";
opts.VariableNames = "Nodes";
opts.VariableTypes = "string";
V = readtable(buildingFile, opts, "UseExcel", false);
clear opts

opts = spreadsheetImportOptions("NumVariables", 2);
opts.Sheet = "edges";
opts.DataRange = "A1:B489";
opts.VariableNames = ["Edge 1", "Edge 2"];
opts.VariableTypes = ["string", "string"];
E = readtable(buildingFile, opts, "UseExcel", false);
clear opts

V = table2array(V);
E = table2array(E);

%% Section 2: adjacency matrix and numeric edge list
% A is 410x410 with a_ij = 1 if you can go from node i to node j. We fill the
% upper triangular half and then symmetrize.
A = zeros(length(V));
for k = 1:length(E)
    A(find(V==E(k,1)), find(V==E(k,2))) = 1;
end
A = A+A';

% E_num is the edge list written with node numbers instead of room names.
E_num = zeros(size(E));
for ind = 1:length(E)
    E_num(ind,1) = find(V==E(ind,1));
    E_num(ind,2) = find(V==E(ind,2));
end

%% Section 3: resident room assignments
% Occupancy per living space: a suite houses 4 residents, a room houses 2,
% except for the single-occupancy rooms listed in SLs, which house 1.
SLs = ["roomB209","roomC217","roomA309","roomB317","roomC317","roomA409", ...
       "roomB409","roomC417","roomA509","roomB509","roomC517","roomC610"];

room_list = zeros(size(V));
room_list(contains(V, 'room')) = 2;
room_list(contains(V, 'suite')) = 4;
room_list(contains(V, SLs)) = 1;

% room_index(i) is the node number of the room of the ith person. Node
% numbers repeat once per resident of that room.
room_index = zeros(594,1);
t = 0;

for i = 1:length(room_list)
    if room_list(i) == 2
        for j = 1:2
            t = t+1;
            room_index(t) = i;
        end
    elseif room_list(i) == 4
        for j = 1:4
            t = t+1;
            room_index(t) = i;
        end
    elseif room_list(i) == 1
        t = t+1;
        room_index(t) = i;
    end
end

%% Section 4: checks
% These are the sizes the rest of the pipeline assumes. If the spreadsheet is
% ever edited, these will catch the mismatch here rather than three scripts later.
assert(length(V) == 410, 'Expected 410 nodes, read %d.', length(V))
assert(size(E,1) == 489, 'Expected 489 edges, read %d.', size(E,1))
assert(isequal(A, A'), 'Adjacency matrix is not symmetric.')
assert(all(diag(A) == 0), 'Adjacency matrix has self loops.')
assert(t == 594, ...
    ['Assigned %d residents, expected 594. The room/suite counts in the ' ...
     'spreadsheet have changed.'], t)
assert(all(room_index > 0), 'Some residents were not assigned a room.')

fprintf('%d nodes, %d edges, %d residents in %d living spaces.\n', ...
    length(V), size(E,1), t, nnz(room_list));

%% Section 5: save
save(outputFile, 'V', 'E', 'E_num', 'A', 'room_index')
fprintf('Wrote %s\n', outputFile);
