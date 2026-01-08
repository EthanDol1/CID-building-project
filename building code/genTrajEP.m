function fig = genTrajEP()
load('diaries.mat')
load('diary_data.mat')
load('master_list.mat')
load('CID_building.mat')

nv = length(V);

A = zeros(length(V));
for k = 1:length(E)
    A(find(V == E(k,1)), find(V == E(k,2)))=1;
end
A = A+A';
A = A+eye(length(A));

T = zeros(nv);

for i = 1:nv
    v = A(i,:);
    idx = find(v);
    T(idx, i) = 1/length(idx);
end

ts = 95;
x0 = zeros(length(T),1);
x0(108) = 1;
mc = dtmc(T','StateNames',V);
X = simulate(mc,ts,'X0',x0);

number_list = unique(X(1:ts+1));
room_list = V(number_list(1:length(number_list)));
room_ticks = 1:length(room_list);

n = length(room_list);

tick_list = [];

for i = 1:length(X)
    for j = 1:n
        if X(i) == number_list(j)
            tick_list = [tick_list j];
        end
    end
end

tick_labels = [];
for i = 1:n
    tick_labels = [tick_labels room_list(i)];
end

figure
plot(uint32(1):uint32(length(X)),tick_list, '-o')
yticks(room_ticks)
yticklabels(cellstr(tick_labels))
title('Markov Chain Simulation (full day)')
ylabel('Room Number')
xlabel('Time step')
xline(16,'--r', '8am', 'LabelOrientation', 'aligned', 'FontSize', 12)
xline(32,'--r', '12pm', 'LabelOrientation', 'aligned', 'FontSize', 12)
xline(48,'--r', '4pm', 'LabelOrientation', 'aligned', 'FontSize', 12)
xline(64,'--r', '8pm', 'LabelOrientation', 'aligned', 'FontSize', 12)
xline(80,'--r', '12am', 'LabelOrientation', 'aligned', 'FontSize', 12)
ax = gca;
ax.FontSize = 15;

end
