function fig = genTrajRT()
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

randA = randomizeA(A);
randA = randA+eye(length(randA));

E = strings(489,2);
E_num = zeros(489,2);

for i = 1:nv
    for j = i+1:nv
        if randA(i,j)==1
            idx = find(E_num(:,1) == 0, 1);
            E_num(idx,:) = [i, j];
            E(idx,:) = [masterList(i,2), masterList(j,2)];
        end
    end
end


n = randi(length(room_index));
my_room = V(room_index(n));
ts = 15;

[T_em, T_m, T_a, T_ee, T_le, T_n] = createTransitionMatrices(my_room,masterList,diaryData,V,E,E_num);
T = {T_em,T_m,T_a,T_ee,T_le,T_n};

X = runSimulation(T,V,ts,room_index,room_index(n));

number_list = unique(X(1:96));
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