% Common binning and windowing configurations.
cfg = [];
cfg.dt = 0.05;
cfg.smooth = 'gauss';
cfg.gausswin_size = 1;
cfg.gausswin_sd = 0.02;

% Get processed data
Q_42 = get_processed_Q(cfg, '/R042-2013-08-18/');
Q_44 = get_processed_Q(cfg, '/R044-2013-12-21/');
Q_64 = get_processed_Q(cfg, '/R064-2015-04-20/');

% PCA
NumComponents = 10;
proj_Q{1} = perform_pca(Q_42, NumComponents);
proj_Q{2} = perform_pca(Q_44, NumComponents);
proj_Q{3} = perform_pca(Q_64, NumComponents);

% Average across all left (and right) trials
for i = 1:length(proj_Q)
    mean_proj_Q.left{i} = mean(cat(3, proj_Q{i}.left{:}), 3);
    mean_proj_Q.right{i} = mean(cat(3, proj_Q{i}.right{:}), 3);
end

% Hyperalignment
[aligned, transforms] = hyperalign(mean_proj_Q.left{1:3}, mean_proj_Q.right{1:3});

aligned_left = aligned(1:3);
transforms_left = transforms(1:3);

aligned_right = aligned(4:6);
transforms_right = transforms(4:6);

% Calculate distance between left and right aligned trajectories
for i = 1:length(aligned_left)
    dist{i} = calculate_dist(aligned_left{i}, aligned_right{i});
end

% Shuffle aligned Q matrix
rand_dists  = cell(1, 3);
for i = 1:100
%     for j = 1:length(aligned_right)
%         shuffle_indices{j} = randperm(NumComponents);
%         shuffled_right{j} = mean_proj_Q.right{j}(shuffle_indices{j}, :);
%         s_aligned_right{j} = p_transform(transforms_right{j}, shuffled_right{j});
%         rand_dists{j} = [rand_dists{j}, calculate_dist(aligned_left{j}, s_aligned_right{j})];
%     end
    for j = 1:length(aligned_right)
        win_len = size(aligned_right{j}, 2);
        for k = 1:NumComponents
            shuffle_indices = shift_shuffle(win_len);
            shuffled_right{j}(k, :) = mean_proj_Q.right{j}(k, shuffle_indices);
        end
%         s_aligned_right{j} = p_transform(transforms_right{j}, shuffled_right{j});
%         rand_dists{j} = [rand_dists{j}, calculate_dist(aligned_left{j}, s_aligned_right{j})];
    end
    % Perform hyperalignment on independently shuffled right Q matrix
    [s_aligned, ~] = hyperalign(mean_proj_Q.left{1:3}, shuffled_right{1:3});
    s_aligned_left = s_aligned(1:3);
    s_aligned_right = s_aligned(4:6);
    % Calculate distance
    for dist_i = 1:length(s_aligned_right)
        rand_dists{dist_i} = [rand_dists{dist_i}, calculate_dist(s_aligned_left{dist_i}, s_aligned_right{dist_i})];
    end
end

% Plot shuffle distance histogram and true distance (by shuffling Q matrix)
subj_list = [42, 44, 64];
for i = 1:length(subj_list)
    subplot(3, 1, i)
    histogram(rand_dists{i})
    line([dist{i}, dist{i}], ylim, 'LineWidth', 2, 'Color', 'r');
    title(sprintf('Subject %d: Distance after shuffling Q matrix between left and right', subj_list(i)))
end
%% Plot the data
% mat = proj_Q_42;
% figinx = 101;
%
% colors = linspecer(2);
% % need to fix the trial level
% for i = 1: numel(mat.left)
%     Q_left(:,:,i) = mat.left{i};
%     figure(figinx);
%     p1=plot3(Q_left(:,1,i), Q_left(:,2,i), Q_left(:,3,i), '-','color',[0 0 1],'LineWidth',3);
%     p1.Color(4) = 0.1;
%     hold on;
% end
% grid on;
%
% for i = 1:numel(mat.right)
%     Q_right(:,:,i) = mat.right{i};
%     figure(figinx);
%     p1=plot3(Q_right(:,1,i), Q_right(:,2,i), Q_right(:,3,i), '-','color',[1 0 0],'LineWidth',3);
%     p1.Color(4) = 0.1;
%     hold on;
% end
% grid on;

% plot the average
% all_right = mean(Q_right,3);
% figure(figinx);
% p1=plot3(all_right(:,1), all_right(:,2), all_right(:,3), '-','color',[1 0 0],'LineWidth',3);
% p1.Color(4) = 1;
% xlabel('Component 1');ylabel('Component 2');zlabel('Component 3')

% all_left = mean(Q_left,3);
% figure(figinx);hold on
% p1=plot3(all_left(:,1), all_left(:,2), all_left(:,3), '-','color',[0 0 1],'LineWidth',3);
% p1.Color(4) = 1;
% xlabel('Component 1');ylabel('Component 2');zlabel('Component 3')
% title([datatoload ' : Blue - Left, Red - Right'])

% Plot trajectory
% left
% trajectory_plotter(5, aligned_left{1}', aligned_left{2}', aligned_left{3}');
%
% right
% trajectory_plotter(5, aligned_right{1}', aligned_right{2}', aligned_right{3}');
%
% non-aligned right trials
% trajectory_plotter(5, mean_proj_Q.right{1}', mean_proj_Q.right{2}', mean_proj_Q.right{3}');
