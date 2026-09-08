function F = runSimulation(mc,ts,room_index,i)
% Same as runSimulation, but takes the six Markov chains already built
% instead of building them from transition matrices on every call. mc is a
% 1x6 cell of dtmc objects, built from the TRANSPOSED matrices exactly as
% runSimulation does internally:  mc{q} = dtmc(T{q}','StateNames',V)
%
% V is not needed here: it was only used for the state names at construction.
%
% The x3/x4/x5 seeding below matches runSimulation as it now stands: each
% block starts where the previous one ended.

nv = size(mc{1}.P,1);

x0 = zeros(nv,1);
x0(room_index(i)) = 1;
X0 = simulate(mc{1},ts,'X0',x0);

x1 = zeros(nv,1);
x1(X0(end)) = 1;
X1 = simulate(mc{2},ts+1,'X0',x1);
X1 = X1(2:end);

x2 = zeros(nv,1);
x2(X1(end)) = 1;
X2 = simulate(mc{3},ts+1,'X0',x2);
X2 = X2(2:end);

x3 = zeros(nv,1);
x3(X2(end)) = 1;
X3 = simulate(mc{4},ts+1,'X0',x3);
X3 = X3(2:end);

x4 = zeros(nv,1);
x4(X3(end)) = 1;
X4 = simulate(mc{5},ts+1,'X0',x4);
X4 = X4(2:end);

x5 = zeros(nv,1);
x5(X4(end)) = 1;
X5 = simulate(mc{6},ts+1,'X0',x5);
X5 = X5(2:end);

F = [X0;X1;X2;X3;X4;X5];
end
