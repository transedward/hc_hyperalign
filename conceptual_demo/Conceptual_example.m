% load example data
load T_maze_demo.mat pos1 Q1 

% Pos1 is a vector describing where the animial is at each time point.
% Q1 is a vector how each neuron responds at each time point

%% B (Behavioral) matrix --> Time by location maxtrix  T by L
pos1.data; % location data, can be binned data 
pos1.tvec;  % time data, can be bined data 

% pos1.data generate random location
% pos1.data(5001:end) = randi(100,1,5000);

[N,Xedges,Yedges] = histcounts2(pos1.tvec,pos1.data,1:10001,1:11);

B=[];
for it = 1:size(pos1.tvec,2)
    for ic = 1:100
        if pos1.data(it) ==ic
            B(it,ic) = 1;
        else
            B(it,ic) = 0;
        end
    end
end
figure(1);subplot(1,4,1);imagesc(B');
title('Behavioral Matrix: Location by Time')

%% Q matrix --> neuron  by Time  matrix  size(Q1) N by T
Q = Q1(:,1:10000); % 10 by 10000 by one trial; the Q1 matrix has 5 trials
figure(1);subplot(1,4,2);imagesc(Q);
title('Neuron Matrix: Neuronal spike by Time')


%% R matrix --> Q*B  Neuron by location matrix N by L
R = B'*Q';
figure(1);subplot(1,4,3);imagesc(R);
title('Representaitonal Matrix: Neuronal By loction')


%% reduce the factors (neurons) to 3 major components
[reducedR scoreR] = pca(R,'NumComponents',10);

for i=1:20
figure(1);subplot(1,4,4);
plot3(scoreR([1:floor(100/20)*i-10],1),scoreR([1:floor(100/20)*i-10],2),scoreR([1:floor(100/20)*i-10],3),'r.');
axis([min(scoreR(:,1)) max(scoreR(:,1)) min(scoreR(:,2)) max(scoreR(:,2)) min(scoreR(:,3)) max(scoreR(:,3))]);
hold on; WaitSecs(0.1)
title('Dimension reduction to 3 components')
end





