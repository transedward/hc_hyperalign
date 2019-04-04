cfg.use_adr_data = 0;
zscore_mat = zeros(length(data));
percent_mat = zeros(length(data));
for i = 1:length(data)
    for j = 1:length(data)
        sf_dists = squeeze(sf_dists_mat(i, j, :))';
        zs = zscore([sf_dists, actual_dists_mat(i, j)]);
        zscore_mat(i, j) = zs(end);
        percent_mat(i, j) = get_percentile(actual_dists_mat(i, j), sf_dists);
    end
end
out_zscore_mat = set_withsubj_nan(cfg, zscore_mat);
out_zscore_prop = sum(sum(out_zscore_mat < 0)) / sum(sum(~isnan(out_zscore_mat)));

%% Calculate common metrics
cfg.use_adr_data = 0;
% Proportion of actual distance and identity distance smaller than shuffled distances
actual_sf_mat = sum(actual_dists_mat < sf_dists_mat, 3);
id_sf_mat = sum(id_dists_mat < sf_dists_mat, 3);

out_actual_sf_mat = set_withsubj_nan(cfg, actual_sf_mat) / 1000;

% Matrix of differences between actual distance (identity distance) and mean of shuffled distance.

actual_mean_sf = actual_dists_mat - mean(sf_dists_mat, 3);
out_actual_mean_sf = set_withsubj_nan(cfg, actual_mean_sf);
out_M_ID = set_withsubj_nan(cfg, (actual_dists_mat - id_dists_mat));

% Proportion of distance obtained from M smaller than mean of shuffled distance.
out_actual_mean_sf_prop = sum(sum(out_actual_mean_sf < 0)) / sum(sum(~isnan(out_actual_mean_sf)));

% Proportion of distance obtained from M smaller than identity mapping
out_actual_dists = set_withsubj_nan(cfg, actual_dists_mat);
out_id_dists = set_withsubj_nan(cfg, id_dists_mat);
out_id_prop = sum(sum(out_actual_dists < out_id_dists)) / sum(sum(~isnan(out_actual_dists)));

% Binomial stats
bino_p_mean = calculate_bino_p(sum(sum(out_actual_mean_sf < 0)), sum(sum(~isnan(out_actual_mean_sf))), 0.5);
bino_p_id = calculate_bino_p(sum(sum(out_actual_dists < out_id_dists)), sum(sum(~isnan(out_actual_dists))), 0.5);

%% Welch’s t-test on errors from M prediction and ID prediction
cfg.use_adr_data = 0;
out_actual_dists = set_withsubj_nan(cfg, actual_dists_mat);
out_id_dists = set_withsubj_nan(cfg, id_dists_mat);

[t_h, t_p] = ttest2(out_actual_dists(:), out_id_dists(:), 'Vartype','unequal');

%% Test correlations within data
for i = 1:length(TC)
    [coef, p] = corrcoef(TC_norm{i}.left, TC_norm{i}.right);
    coefs(i, 1) = coef(1, 2);
    coefs(i, 2) = p(1, 2);
end
bar(1:19, [coefs]);

%% Calculate errors across locations/time
cfg.use_adr_data = 0;
out_dists = actual_dists_mat;
out_dists = set_withsubj_nan(cfg, out_dists);
out_keep_idx = cellfun(@(C) any(~isnan(C(:))), out_dists);
out_dists = out_dists(out_keep_idx);
out_dists = cell2mat(out_dists);

% Normalize within session to prevent average dominated by high errors
out_dists = zscore(out_dists, 0, 2);
mean_across_w = mean(out_dists, 1);
std_across_w = std(out_dists, 1);
errorbar(1:length(mean_across_w), mean_across_w, std_across_w);
title('Squared Errors from M prediction across time');
