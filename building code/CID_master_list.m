% masterList has the node number, the node name, the pattern, the diary
% pattern, and all 6 self loops

clearvars; close all; clc;
load('diaries.mat')
load('diary_data.mat')

opts = spreadsheetImportOptions;
opts.Sheet = "nodes";
opts.DataRange = "A1:A410";
opts.VariableNames = "Nodes";
opts.VariableTypes = "string";
V = readtable("C:\Users\13049\Desktop\matlab code\Research Code\building code\CID_building.xlsx", opts, "UseExcel", false);
clear opts
opts = spreadsheetImportOptions("NumVariables", 2);
opts.Sheet = "edges";
opts.DataRange = "A1:B489";
opts.VariableNames = ["Edge 1", "Edge 2"];
opts.VariableTypes = ["string", "string"];
E = readtable("C:\Users\13049\Desktop\matlab code\Research Code\building code\CID_building.xlsx", opts, "UseExcel", false);
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

save('master_list.mat','masterList','graphPatterns','graphPatternsMapped')