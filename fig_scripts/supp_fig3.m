%%
rng(mean('hyperalignment'));
colors = get_hyper_colors();
sub_ids = get_sub_ids_start_end();

datas = {Q, Q_norm, TC, TC_norm};
themes = {'Q(int. rm)', 'Q(int. rm) norm.', 'TC(int. rm)', 'TC(int. rm) norm.'};

%% Example inputs
n_units = 30;
% Use indices in Q_int_rm in case index chosen from Q does not exist in
% Q_int_rm.
% ex_idx = datasample(1:length(Q_int_rm{1}.left), n_units, 'Replace', false);

for d_i = 1:length(datas)
    subplot(4, 2, (2*(d_i-1) + 1))
    imagesc([datas{d_i}{1}.left(1:n_units, :), datas{d_i}{1}.right(1:n_units, :)]);
    colorbar;
    set(gca, 'xticklabel', [], 'yticklabel', [], 'FontSize', 12);
    ylabel('neuron');
    title(themes{d_i});
end

set(gcf, 'Position', [572 1 941 954]);

%% Hyperalignment procedure
for d_i = 1:length(datas)
    data = datas{d_i};
    [actual_dists_mat{d_i}, id_dists_mat{d_i}, sf_dists_mat{d_i}] = predict_with_shuffles([], data, @predict_with_L_R);
end

%% HT prediction in various normalization.
x_limits = [-6.5, 6.5];
x_tick = -6:6;
binsizes = [1];

cfg_plot = [];
cfg_plot.hist_colors = {colors.HT.hist};
cfg_plot.fit_colors = {colors.HT.fit};

for d_i = 1:length(datas)
    [z_score{d_i}] = calculate_common_metrics([], actual_dists_mat{d_i}, ...
        id_dists_mat{d_i}, sf_dists_mat{d_i});

    matrix_objs = {{z_score{d_i}.out_zscore_mat}};
    for m_i = 1:length(matrix_objs)
        this_ax = subplot(4, 2, (2*(d_i-1) + 2));
        p_i = (m_i - 1) * 4 + d_i; % % plot index to access x_limits etc defined above
        matrix_obj = matrix_objs{m_i};

        cfg_plot.xlim = x_limits;
        cfg_plot.xtick = x_tick;
        cfg_plot.binsize = binsizes;
        cfg_plot.ax = this_ax;
        cfg_plot.insert_zero = 1; % plot zero xtick
        cfg_plot.fit = 'vline'; % 'gauss', 'kernel', 'vline' or 'none (no fit)

        plot_hist2(cfg_plot, matrix_obj);

    end
end