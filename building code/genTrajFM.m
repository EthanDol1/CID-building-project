function fig = genTrajFM()
load('diaries.mat')
load('diary_data.mat')
load('master_list.mat')
load('CID_building.mat')

masterListOriginal = masterList;

my_room = "roomA301";
masterList(find(V == my_room),3:4) = "my dorm";
masterList(find(V == my_room),5:6) = [avg_self_loops(1) avg_entries(1)];
masterList(find(V == my_room),7:end) = diaryData(1,2:end);

[T_em, T_m, T_a, T_ee, T_le, T_n] = createTransitionMatrices(my_room,masterListOriginal,diaryData,V,E,E_num);
transitionMatrices = {T_em,T_m,T_a,T_ee,T_le,T_n};

ts = 15; % number of time steps in early morning
x0 = zeros(length(T),1); % init state vector
x0(108) = 1; % start in roomA301/my_room
mc = dtmc(T_em','StateNames',V); % generate trajectory using T_em
X0 = simulate(mc,ts,'X0',x0);

x1 = zeros(length(T),1);
x1(X0(end)) = 1;
mc = dtmc(T_m','StateNames',V);
X1 = simulate(mc,ts+1,'X0',x1);
X1 = X1(2:end);

x2 = zeros(length(T),1);
x2(X1(end)) = 1;
mc = dtmc(T_a','StateNames',V);
X2 = simulate(mc,ts+1,'X0',x2);
X2 = X2(2:end);

x3 = zeros(length(T),1);
x3(X1(end)) = 1;
mc = dtmc(T_ee','StateNames',V);
X3 = simulate(mc,ts+1,'X0',x3);
X3 = X3(2:end);

x4 = zeros(length(T),1);
x4(X1(end)) = 1;
mc = dtmc(T_le','StateNames',V);
X4 = simulate(mc,ts+1,'X0',x4);
X4 = X4(2:end);

x5 = zeros(length(T),1);
x5(X1(end)) = 1;
mc = dtmc(T_n','StateNames',V);
X5 = simulate(mc,ts+1,'X0',x5);
X5 = X5(2:end);

F = [X0;X1;X2;X3;X4;X5];

number_list = unique(F(1:end));
room_list = V(number_list(1:end));
n = length(room_list);

room_ticks = 1:length(room_list);
tick_list = [];
for i = 1:length(F)
    for j = 1:n
        if F(i) == number_list(j)
            tick_list = [tick_list j];
        end
    end
end

tick_labels = [];
for i = 1:n
    tick_labels = [tick_labels room_list(i)];
end

fig = figure
t = uint32(1):uint32(length(F));
plot(t, tick_list, '-o')
yticks(room_ticks)
yticklabels(cellstr(tick_labels))
title('Markov Chain Simulation')
ylabel('Node')
xlabel('Time step')
xlim([0 96])
ylim([0 length(room_ticks)+1])
xline(16,'--r', '8am', 'LabelOrientation', 'aligned','FontSize',15)
xline(32,'--r', '12pm', 'LabelOrientation', 'aligned','FontSize',15)
xline(48,'--r', '4pm', 'LabelOrientation', 'aligned','FontSize',15)
xline(64,'--r', '8pm', 'LabelOrientation', 'aligned','FontSize',15)
xline(80,'--r', '12am', 'LabelOrientation', 'aligned','FontSize',15)
ax = gca;
ax.FontSize = 15;
end