function A = createAdjacencyMatrix(V,E)
%CREATEADJACENCYMATRIX  Symmetric adjacency matrix for the building graph.
%   A(i,j) = 1 if nodes V(i) and V(j) are joined by an edge in E. Only the
%   upper half is filled, then mirrored, so A is symmetric with a zero
%   diagonal. Callers that want self loops add eye(length(V)) themselves.
A = zeros(length(V));
for k = 1:length(E)
    A(find(V == E(k,1)), find(V == E(k,2))) = 1;
end
A = A+A'; % Make the adjacency matrix symmetric.
end
