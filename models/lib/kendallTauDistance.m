function d = kendallTauDistance(a, b, normalize)
%KENDALLTAUDISTANCE Number of item pairs that two rankings order differently.
%   D = KENDALLTAUDISTANCE(A,B) counts the pairs of items (i,j) placed in
%   opposite relative order by A and B. A and B are equal-length vectors
%   giving a score or rank for the SAME items in the SAME positions: A(k) and
%   B(k) must describe item k under both rankings.
%
%   D runs from 0 (the two rankings agree completely) to n*(n-1)/2 (one is the
%   reverse of the other), where n = numel(A).
%
%   D = KENDALLTAUDISTANCE(A,B,true) divides by n*(n-1)/2, giving a value in
%   [0,1] that can be compared across different numbers of items.
%
%   Only the relative order of the entries matters, not their magnitudes, so
%   ranks (1,2,3,...) and raw scores give the same answer.
%
%   Ties: a pair tied in one ranking but ordered in the other counts as
%   discordant. Other conventions exist; if you need one of those, this is the
%   line to change.
%
%   Without ties this agrees exactly with the Statistics Toolbox result:
%       d == (1 - corr(a,b,'Type','Kendall')) * n * (n-1) / 4
%   With ties, corr returns tau-b, whose tie correction breaks that identity;
%   this function stays correct either way.
%
%   Example:
%       a = [1 2 3 4 5];        % item 3 ranked 3rd by A
%       b = [1 2 3 5 4];        % ... and 3rd by B, but items 4 and 5 swapped
%       kendallTauDistance(a,b)         % 1 discordant pair
%       kendallTauDistance(a,b,true)    % 0.1 of the 10 possible pairs

if nargin < 3
    normalize = false;
end

a = a(:);
b = b(:);

if numel(a) ~= numel(b)
    error('kendallTauDistance:sizeMismatch', ...
        'A and B must have the same number of elements (got %d and %d).', ...
        numel(a), numel(b));
end

n = numel(a);
if n < 2
    d = 0;
    return
end

% Every unordered pair (i,j) with i < j, compared once.
[I, J] = find(triu(true(n), 1));
d = sum(sign(a(I)-a(J)) ~= sign(b(I)-b(J)));

if normalize
    d = d / (n*(n-1)/2);
end
end
