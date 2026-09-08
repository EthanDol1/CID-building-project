function [T_em, T_m, T_a, T_ee, T_le, T_n] = createTransitionMatrices(my_room, masterListOriginal, diaryData, V, E, E_num) %#ok<INUSD>
% CREATETRANSITIONMATRICES  Six time-of-day transition matrices for one room.
%
% Same outputs as before; the six near-identical blocks are now one loop over
% time of day, and every quantity that does not depend on the node being
% processed is computed once up front instead of inside the inner loops.
%
% E is no longer needed (neighbours come from E_num) but is kept in the
% signature so the five call sites do not have to change.

masterList = masterListOriginal;
masterList(find(V == my_room),3:4) = "my dorm";
masterList(find(V == my_room),7:end) = diaryData(1,2:end);

nv = length(V);

%% Neighbour lists
% The old code found the edges touching node i with
%   contains(E(:,1), V(i)) | contains(E(:,2), V(i))
% i.e. substring matching on room names, then took the matching rows of
% E_num. No node name is a substring of another (checked across all 410), so
% that is the same set as E_num(:,k) == i, which is integer work instead of
% ~2.4 million string tests per call. The swap below reproduces the original
% "put all the edges on one side" step, so nbrs{i} holds the far end of every
% edge touching i, in the same order.
nbrs = cell(nv,1);
for i = 1:nv
    m = (E_num(:,1) == i) | (E_num(:,2) == i);
    e = E_num(m,:);
    swap = e(:,2) == i;
    e(swap,:) = e(swap,[2 1]);
    nbrs{i} = e(:,2);
end

%% Pattern codes
% Replaces the repeated string comparisons against masterList(:,4).
% unique sorts, so patNames is in the same order the old edgePatterns was,
% and patCode(v) is the position of node v's pattern in that list.
[patNames, ~, patCode] = unique(masterList(:,4));
np = numel(patNames);

%% Entries per pattern, per time of day
% Old code did this per node per block:
%   if edgePatterns(j) == "n/a", 0, else diaryData(find(...),7+tod)
% The result depends only on the pattern, so it is a np-by-6 table.
entriesByPat = zeros(np,6);
for p = 1:np
    if patNames(p) ~= "n/a"
        r = find(diaryData(:,1) == patNames(p));
        for tod = 1:6
            entriesByPat(p,tod) = diaryData(r,7+tod);
        end
    end
end

%% Self-loop probabilities
% masterList columns 7..12, read once into a numeric nv-by-6 array. The
% assignment is the same one the old code did at T(i,i) = masterList(i,6+tod),
% so any implicit conversion behaves identically.
selfLoop = zeros(nv,6);
for i = 1:nv
    for tod = 1:6
        selfLoop(i,tod) = masterList(i,6+tod);
    end
end

%% Neighbour pattern grouping
% A node's neighbours and their pattern codes do not depend on the time of
% day, so this grouping is the same for all six matrices. Computing it once
% per node here rather than once per node per block cuts the unique() calls
% by a factor of six. uc is sorted, so it matches the ordering the old
% unique(masterList(edges,4)) produced; g maps each neighbour to its position
% in uc, and totals counts the neighbours carrying each pattern.
ucOf = cell(nv,1);
gOf = cell(nv,1);
totalsOf = cell(nv,1);
for i = 1:nv
    nb = nbrs{i};
    if isempty(nb)
        continue
    end
    [uc, ~, g] = unique(patCode(nb));
    ucOf{i} = uc;
    gOf{i} = g;
    totalsOf{i} = accumarray(g, 1);
end

%% Build the six matrices
Ts = cell(1,6);
for tod = 1:6
    T = zeros(nv);

    for i = 1:nv
        nb = nbrs{i};
        if isempty(nb)
            T(i,i) = 1;
            continue
        end

        g = gOf{i};
        totals = totalsOf{i};
        ent = entriesByPat(ucOf{i}, tod);   % entries per pattern
        s = sum(ent);

        if s > 0
            T(i,i) = selfLoop(i,tod);
            w = ent ./ (s * totals);        % same normalisation as before
            T(nb,i) = w(g) * (1 - T(i,i));
        else
            T(i,i) = 1;
        end
    end

    Ts{tod} = T;
end

[T_em, T_m, T_a, T_ee, T_le, T_n] = Ts{:};
end
