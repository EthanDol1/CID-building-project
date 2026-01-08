function T = createT(my_room, masterListOriginal, diaryData, avg_entries, avg_self_loops, V, edgeDictionary)
masterList = masterListOriginal;
masterList(find(V == my_room),3:4) = "my dorm";
masterList(find(V == my_room),5:6) = [avg_self_loops(1) avg_entries(1)];
masterList(find(V == my_room),7:end) = diaryData(1,2:end);

T = zeros(length(V));

for i = 1:length(V)
    T(i,i) = masterList(i,5);

    edgeList = edgeDictionary{i};
    num_edges = length(edgeList);

    edgePatterns = unique(masterList(edgeList,4));
    edgePatternTotals = zeros(length(edgePatterns),1);
    for j = 1:num_edges
        id = find(edgePatterns == masterList(edgeList(j),4));
        edgePatternTotals(id) = edgePatternTotals(id)+1;
    end

    edgePatternEntries = zeros(length(edgePatterns),1);
    for j = 1:length(edgePatterns)
        if edgePatterns(j) == "n/a"
            edgePatternEntries(j) = 0;
        else
            edgePatternEntries(j) = avg_entries(find(diaryData(:,1) == edgePatterns(j)));
        end
    end
    edgePatternEntriesNorm = edgePatternEntries./(sum(edgePatternEntries)*edgePatternTotals);
    edgeMasterList = [edgePatterns edgePatternTotals edgePatternEntriesNorm];

    for j = 1:num_edges
        id = find(masterList(edgeList(j),4)==edgePatterns);
        T(edgeList(j),i) = str2double(edgeMasterList(id,3))*(1-T(i,i));
    end
end

