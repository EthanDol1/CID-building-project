clearvars; clc;
load('randTopModel-Sims-200-102625.mat')
%%
[p, tbl, stats] = kruskalwallis(useData(:,[3 4 5 6 8]));
c = multcompare(stats);
%%
[p, tbl, stats] = kruskalwallis(collisionData(:,[3 4 5 6 8]));
c = multcompare(stats);