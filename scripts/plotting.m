imagesc(zscore_mat);
colorbar;
ylabel('Source Sessions');
xlabel('Target Sessions');
title('Z-score of distances including within subjects')

imagesc(percent_mat);
colorbar;
ylabel('Source Sessions');
xlabel('Target Sessions');
title('Percentile of distances including within subjects')

out_zscore_mat = set_withsubj_nan(zscore_mat);
imagesc(out_zscore_mat,'AlphaData', ~isnan(out_zscore_mat));
colorbar;
ylabel('Source Sessions');
xlabel('Target Sessions');
title('Z-score of distances excluding within subjects')

out_percent_mat = set_withsubj_nan(percent_mat);
imagesc(out_percent_mat,'AlphaData', ~isnan(out_percent_mat));
colorbar;
ylabel('Source Sessions');
xlabel('Target Sessions');
title('Percentile of distances excluding within subjects')

% Set Labels as Restrction Types
set(gca, 'XTick', 1:19, 'XTickLabel', restrictionLabels);
set(gca, 'YTick', 1:19, 'YTickLabel', restrictionLabels);

% Histoggram of z-scores and percentiles
histogram(out_zscore_mat)
title('Histogram of z-scores with matched trials')

histogram(out_percent_mat)
title('Histogram of percentiles with matched trials')

% % Plot shuffle distance histogram and true distance (by shuffling Q matrix)
% for i = 1:length(Q)
%     subplot(length(Q), 1, i)
%     histogram(rand_dists{i})
%     line([dist{i}, dist{i}], ylim, 'LineWidth', 2, 'Color', 'r')
%     line([dist_LR{i}, dist_LR{i}], ylim, 'LineWidth', 2, 'Color', 'g')
%     title('Distance betweeen using M* and its own aligned right trials')
% end

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
