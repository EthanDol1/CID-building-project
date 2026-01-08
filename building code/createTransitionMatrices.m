function [T_em, T_m, T_a, T_ee, T_le, T_n] = createTransitionMatrices(my_room, masterListOriginal, diaryData, V, E, E_num)
masterList = masterListOriginal;
masterList(find(V == my_room),3:4) = "my dorm";
masterList(find(V == my_room),7:end) = diaryData(1,2:end);

T_em = zeros(size(V));
for i = 1:410
    % Create list of connections
    c1 = contains(E(:,1), V(i));
    c2 = contains(E(:,2), V(i));
    c = c1|c2;

    edges_to_weight = E_num(c,:); % list of edge numbers
    num_edges = size(edges_to_weight(:,1),1); % number of edges

    % Swap all the edges to be on one side
    for j = 1:num_edges
        if edges_to_weight(j,2) == i
            placeholder = edges_to_weight(j,:);
            edges_to_weight(j,1) = placeholder(2);
            edges_to_weight(j,2) = placeholder(1);
        end
    end

    edgePatterns = unique(masterList(edges_to_weight(:,2),4));

    edgePatternTotals = zeros(length(edgePatterns),1);
    for j = 1:num_edges
        id = find(edgePatterns == masterList(edges_to_weight(j,2),4));
        edgePatternTotals(id) = edgePatternTotals(id)+1;
    end

    edgePatternEntries = zeros(length(edgePatterns),1);
    for j = 1:length(edgePatterns)
        if edgePatterns(j) == "n/a"
            edgePatternEntries(j) = 0;
        else
            edgePatternEntries(j) = diaryData(find(diaryData(:,1) == edgePatterns(j)),8);
        end
    end

    if sum(edgePatternEntries)>0
        T_em(i,i) = masterList(i,7);

        edgePatternEntriesNorm = edgePatternEntries./(sum(edgePatternEntries)*edgePatternTotals);
        edgeMasterList = [edgePatterns edgePatternTotals edgePatternEntriesNorm];

        for j = 1:num_edges
            id = find(masterList(edges_to_weight(j,2),4)==edgePatterns);
            T_em(edges_to_weight(j,2),i) = str2double(edgeMasterList(id,3))*(1-T_em(i,i));
        end
    else
        T_em(i,i) = 1;
    end
end

T_m = zeros(size(V));
for i = 1:length(V)
    % Create list of connections for node i
    c1 = contains(E(:,1), V(i));
    c2 = contains(E(:,2), V(i));
    c = c1|c2;
    edges_to_weight = E_num(c,:); % list of edge numbers
    num_edges = size(edges_to_weight(:,1),1); % number of edges

    % Swap all the edges to be on one side
    for j = 1:num_edges
        if edges_to_weight(j,2) == i
            placeholder = edges_to_weight(j,:);
            edges_to_weight(j,1) = placeholder(2);
            edges_to_weight(j,2) = placeholder(1);
        end
    end

    edgePatterns = unique(masterList(edges_to_weight(:,2),4));

    edgePatternTotals = zeros(length(edgePatterns),1);
    for j = 1:num_edges
        id = find(edgePatterns == masterList(edges_to_weight(j,2),4));
        edgePatternTotals(id) = edgePatternTotals(id)+1;
    end

    edgePatternEntries = zeros(length(edgePatterns),1);
    for j = 1:length(edgePatterns)
        if edgePatterns(j) == "n/a"
            edgePatternEntries(j) = 0;
        else
            edgePatternEntries(j) = diaryData(find(diaryData(:,1) == edgePatterns(j)),9);
        end
    end

    if sum(edgePatternEntries)>0
        T_m(i,i) = masterList(i,8);
    
        edgePatternEntriesNorm = edgePatternEntries./(sum(edgePatternEntries)*edgePatternTotals);
        edgeMasterList = [edgePatterns edgePatternTotals edgePatternEntriesNorm];
    
        for j = 1:num_edges
            id = find(masterList(edges_to_weight(j,2),4)==edgePatterns);
            T_m(edges_to_weight(j,2),i) = str2double(edgeMasterList(id,3))*(1-T_m(i,i));
        end
    else
        T_m(i,i) = 1;
    end
end

T_a = zeros(size(V));
for i = 1:length(V)
    % Create list of connections for node i
    c1 = contains(E(:,1), V(i));
    c2 = contains(E(:,2), V(i));
    c = c1|c2;
    edges_to_weight = E_num(c,:); % list of edge numbers
    num_edges = size(edges_to_weight(:,1),1); % number of edges

    % Swap all the edges to be on one side
    for j = 1:num_edges
        if edges_to_weight(j,2) == i
            placeholder = edges_to_weight(j,:);
            edges_to_weight(j,1) = placeholder(2);
            edges_to_weight(j,2) = placeholder(1);
        end
    end

    edgePatterns = unique(masterList(edges_to_weight(:,2),4));

    edgePatternTotals = zeros(length(edgePatterns),1);
    for j = 1:num_edges
        id = find(edgePatterns == masterList(edges_to_weight(j,2),4));
        edgePatternTotals(id) = edgePatternTotals(id)+1;
    end

    edgePatternEntries = zeros(length(edgePatterns),1);
    for j = 1:length(edgePatterns)
        if edgePatterns(j) == "n/a"
            edgePatternEntries(j) = 0;
        else
            edgePatternEntries(j) = diaryData(find(diaryData(:,1) == edgePatterns(j)),10);
        end
    end

    if sum(edgePatternEntries)>0
        T_a(i,i) = masterList(i,9);
    
        edgePatternEntriesNorm = edgePatternEntries./(sum(edgePatternEntries)*edgePatternTotals);
        edgeMasterList = [edgePatterns edgePatternTotals edgePatternEntriesNorm];
    
        for j = 1:num_edges
            id = find(masterList(edges_to_weight(j,2),4)==edgePatterns);
            T_a(edges_to_weight(j,2),i) = str2double(edgeMasterList(id,3))*(1-T_a(i,i));
        end
    else
        T_a(i,i) = 1;
    end
end

T_ee = zeros(size(V));
for i = 1:length(V)
    % Create list of connections for node i
    c1 = contains(E(:,1), V(i));
    c2 = contains(E(:,2), V(i));
    c = c1|c2;
    edges_to_weight = E_num(c,:); % list of edge numbers
    num_edges = size(edges_to_weight(:,1),1); % number of edges

    % Swap all the edges to be on one side
    for j = 1:num_edges
        if edges_to_weight(j,2) == i
            placeholder = edges_to_weight(j,:);
            edges_to_weight(j,1) = placeholder(2);
            edges_to_weight(j,2) = placeholder(1);
        end
    end

    edgePatterns = unique(masterList(edges_to_weight(:,2),4));
    edgePatternTotals = zeros(length(edgePatterns),1);
    for j = 1:num_edges
        id = find(edgePatterns == masterList(edges_to_weight(j,2),4));
        edgePatternTotals(id) = edgePatternTotals(id)+1;
    end

    edgePatternEntries = zeros(length(edgePatterns),1);
    for j = 1:length(edgePatterns)
        if edgePatterns(j) == "n/a"
            edgePatternEntries(j) = 0;
        else
            edgePatternEntries(j) = diaryData(find(diaryData(:,1) == edgePatterns(j)),11);
        end
    end

    if sum(edgePatternEntries)>0
        T_ee(i,i) = masterList(i,10);
    
        edgePatternEntriesNorm = edgePatternEntries./(sum(edgePatternEntries)*edgePatternTotals);
        edgeMasterList = [edgePatterns edgePatternTotals edgePatternEntriesNorm];
    
        for j = 1:num_edges
            id = find(masterList(edges_to_weight(j,2),4)==edgePatterns);
            T_ee(edges_to_weight(j,2),i) = str2double(edgeMasterList(id,3))*(1-T_ee(i,i));
        end
    else
        T_ee(i,i) = 1;
    end
end

T_le = zeros(size(V));
for i = 1:length(V)
    % Create list of connections for node i
    c1 = contains(E(:,1), V(i));
    c2 = contains(E(:,2), V(i));
    c = c1|c2;
    edges_to_weight = E_num(c,:); % list of edge numbers
    num_edges = size(edges_to_weight(:,1),1); % number of edges

    % Swap all the edges to be on one side
    for j = 1:num_edges
        if edges_to_weight(j,2) == i
            placeholder = edges_to_weight(j,:);
            edges_to_weight(j,1) = placeholder(2);
            edges_to_weight(j,2) = placeholder(1);
        end
    end

    edgePatterns = unique(masterList(edges_to_weight(:,2),4));
    edgePatternTotals = zeros(length(edgePatterns),1);
    for j = 1:num_edges
        id = find(edgePatterns == masterList(edges_to_weight(j,2),4));
        edgePatternTotals(id) = edgePatternTotals(id)+1;
    end

    edgePatternEntries = zeros(length(edgePatterns),1);
    for j = 1:length(edgePatterns)
        if edgePatterns(j) == "n/a"
            edgePatternEntries(j) = 0;
        else
            edgePatternEntries(j) = diaryData(find(diaryData(:,1) == edgePatterns(j)),12);
        end
    end

    if sum(edgePatternEntries)>0
        T_le(i,i) = masterList(i,11);
    
        edgePatternEntriesNorm = edgePatternEntries./(sum(edgePatternEntries)*edgePatternTotals);
        edgeMasterList = [edgePatterns edgePatternTotals edgePatternEntriesNorm];
    
        for j = 1:num_edges
            id = find(masterList(edges_to_weight(j,2),4)==edgePatterns);
            T_le(edges_to_weight(j,2),i) = str2double(edgeMasterList(id,3))*(1-T_le(i,i));
        end
    else
        T_le(i,i) = 1;
    end
end

T_n = zeros(size(V));
for i = 1:length(V)
    % Create list of connections for node i
    c1 = contains(E(:,1), V(i));
    c2 = contains(E(:,2), V(i));
    c = c1|c2;
    edges_to_weight = E_num(c,:); % list of edge numbers
    num_edges = size(edges_to_weight(:,1),1); % number of edges

    % Swap all the edges to be on one side
    for j = 1:num_edges
        if edges_to_weight(j,2) == i
            placeholder = edges_to_weight(j,:);
            edges_to_weight(j,1) = placeholder(2);
            edges_to_weight(j,2) = placeholder(1);
        end
    end

    edgePatterns = unique(masterList(edges_to_weight(:,2),4));
    edgePatternTotals = zeros(length(edgePatterns),1);
    for j = 1:num_edges
        id = find(edgePatterns == masterList(edges_to_weight(j,2),4));
        edgePatternTotals(id) = edgePatternTotals(id)+1;
    end

    edgePatternEntries = zeros(length(edgePatterns),1);
    for j = 1:length(edgePatterns)
        if edgePatterns(j) == "n/a"
            edgePatternEntries(j) = 0;
        else
            edgePatternEntries(j) = diaryData(find(diaryData(:,1) == edgePatterns(j)),13);
        end
    end

    if sum(edgePatternEntries)>0
        T_n(i,i) = masterList(i,12);
    
        edgePatternEntriesNorm = edgePatternEntries./(sum(edgePatternEntries)*edgePatternTotals);
        edgeMasterList = [edgePatterns edgePatternTotals edgePatternEntriesNorm];
    
        for j = 1:num_edges
            id = find(masterList(edges_to_weight(j,2),4)==edgePatterns);
            T_n(edges_to_weight(j,2),i) = str2double(edgeMasterList(id,3))*(1-T_n(i,i));
        end
    else
        T_n(i,i) = 1;
    end
end
