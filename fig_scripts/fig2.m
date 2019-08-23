colors = get_hyper_colors();

%% Hyperalignment procedure
% Carey: 1, ADR: 2;
datas = {Q, adr_Q};
for d_i = 1:length(datas)
    data = datas{d_i};
    [actual_dists_mat{d_i}, id_dists_mat{d_i}, sf_dists_mat{d_i}] = predict_with_shuffles([], data, @predict_with_L_R);
    [actual_dists_mat_pca{d_i}, id_dists_mat_pca{d_i}, sf_dists_mat_pca{d_i}] = predict_with_shuffles([], data, @predict_with_L_R_pca);
end

%% Source-target figures in Carey
[z_score, mean_shuffles, proportion] = calculate_common_metrics([], actual_dists_mat{1}, ...
    id_dists_mat{1}, sf_dists_mat{1});

titles = {'HT z-score vs. shuffle', 'HT distance - shuffled dist.', 'p(HT dist. > shuffled dist.)'};

cfg_plot = [];
clims = {[-6 6], [-1000 1000], [0 1]};

matrix_obj = {z_score.out_zscore_mat, mean_shuffles.out_actual_mean_sf, proportion.out_actual_sf_mat};
for m_i = 1:length(matrix_obj)
    this_ax = subplot(3, 3, m_i);

    cfg_plot.ax = this_ax;
    cfg_plot.clim = clims{m_i};
    cfg_plot.title = titles{m_i};

    plot_matrix(cfg_plot, matrix_obj{m_i});

end
set(gcf, 'Position', [316 185 898 721]);

%% Hypertransform and PCA-only in Carey and ADR
% themes = {'Carey', 'ADR'};
x_limits = {[-6.5, 6.5], [-1050, 1050], [0, 1], [-6.5, 6.5], [-1050, 1050], [0, 1]}; % two rows, three columns in figure
x_tick = {-6:6, -1000:250:1000, 0:0.2:1, -6:6, -1000:250:1000, 0:0.2:1};
binsizes = [1, 150, 0.1]; % for histograms

cfg_plot = [];
cfg_plot.hist_colors = {colors.HT.hist, colors.pca.hist};
cfg_plot.fit_colors = {colors.HT.fit, colors.pca.fit};

for d_i = 1:length(datas) % one row each for Carey, ADR
    [z_score, mean_shuffles, proportion] = calculate_common_metrics([], actual_dists_mat{d_i}, ...
        id_dists_mat{d_i}, sf_dists_mat{d_i});
    [z_score_pca, mean_shuffles_pca, proportion_pca] = calculate_common_metrics([], actual_dists_mat_pca{d_i}, ...
        id_dists_mat_pca{d_i}, sf_dists_mat_pca{d_i});

    matrix_objs = {{z_score.out_zscore_mat, z_score_pca.out_zscore_mat}, ...
        {mean_shuffles.out_actual_mean_sf, mean_shuffles_pca.out_actual_mean_sf}, ...
        {proportion.out_actual_sf_mat, proportion_pca.out_actual_sf_mat}};

    for m_i = 1:length(matrix_objs) % loop over columns
        this_ax = subplot(3, 3, (3 * d_i) + m_i);
        p_i = (d_i - 1)*3 + m_i; % plot index to access x_limits etc defined above
        matrix_obj = matrix_objs{m_i};

        cfg_plot.xlim = x_limits{p_i};
        cfg_plot.xtick = x_tick{p_i};
        cfg_plot.binsize = binsizes(m_i);
        cfg_plot.ax = this_ax;
        cfg_plot.insert_zero = 1; % plot zero xtick
        cfg_plot.fit = 'vline'; % 'gauss', 'kernel', 'vline' or 'none (no fit)
        if m_i == 3
            cfg_plot.fit = 'none';
            cfg_plot.insert_zero = 0;
        end

        plot_hist2(cfg_plot, matrix_obj); % ht, then pca

    end
end
