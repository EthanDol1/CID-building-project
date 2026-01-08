function F = runSimulation(T,V,ts,room_index,i)
x0 = zeros(length(T{1}),1);
x0(room_index(i)) = 1;
mc = dtmc(T{1}','StateNames',V);
X0 = simulate(mc,ts,'X0',x0);

x1 = zeros(length(T{2}),1);
x1(X0(end)) = 1;
mc = dtmc(T{2}','StateNames',V);
X1 = simulate(mc,ts+1,'X0',x1);
X1 = X1(2:end);

x2 = zeros(length(T{3}),1);
x2(X1(end)) = 1;
mc = dtmc(T{3}','StateNames',V);
X2 = simulate(mc,ts+1,'X0',x2);
X2 = X2(2:end);

x3 = zeros(length(T{4}),1);
x3(X1(end)) = 1;
mc = dtmc(T{4}','StateNames',V);
X3 = simulate(mc,ts+1,'X0',x3);
X3 = X3(2:end);

x4 = zeros(length(T{5}),1);
x4(X1(end)) = 1;
mc = dtmc(T{5}','StateNames',V);
X4 = simulate(mc,ts+1,'X0',x4);
X4 = X4(2:end);

x5 = zeros(length(T{6}),1);
x5(X1(end)) = 1;
mc = dtmc(T{6}','StateNames',V);
X5 = simulate(mc,ts+1,'X0',x5);
X5 = X5(2:end);

F = [X0;X1;X2;X3;X4;X5];
end