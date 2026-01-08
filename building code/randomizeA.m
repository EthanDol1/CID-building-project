function randA = randomizeA(A)
randA = A;

for i = 1:length(randA)
    edges = find(randA(i,:));
    r = zeros(length(edges),1);
    for j = 1:length(edges)
        j_edges = find(randA(edges(j),:));
        allowed = setdiff(1:410,[i edges]); % r can't already be connected to i, r can't be i
        r(j) = allowed(randi(length(allowed)));

        r_edges = find(randA(r(j),:));
        r_edges = setdiff(r_edges, [r(j) j_edges]); % s can't already be connected to j
        if isempty(r_edges)
            break
        end
        s = r_edges(randi(length(r_edges)));

        if randA(i, r(j)) || randA(edges(j), s) || i==r(j) || edges(j)==s
            continue; % reject this proposal
        end

        randA(i,edges(j)) = 0;
        randA(i,r(j)) = 1;
        randA(edges(j),i) = 0;
        randA(edges(j),s) = 1;
        randA(r(j),s) = 0;
        randA(r(j),i) = 1;
        randA(s,r(j)) = 0;
        randA(s,edges(j)) = 1;

        edges(j) = r(j);
    end
end