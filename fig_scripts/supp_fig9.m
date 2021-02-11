rng(mean('hyperalignment'));

%% Plot left vs. right fields for both actual and predicted data
data = Q;
[~, ~, predicted_Q_mat] = predict_with_L_R([], data);
out_predicted_Q_mat = set_withsubj_nan([], predicted_Q_mat);
w_len = size(data{1}.left, 2);

figure;
set(gcf, 'Position', [395 524 1023 366]);
datas = {Q, out_predicted_Q_mat};
exp_cond = {'actual', 'predicted'};
for d_i = 1:length(datas)
    data = datas{d_i};
    max_fields = zeros(w_len, w_len);
    neu_w_fields_idx = cell(size(data));
    left_only_count = 0;
    right_only_count = 0;
    for sess_i = 1:length(data(:))
        if d_i == 1
            Q_sess = [data{sess_i}.left, data{sess_i}.right];
        else
            Q_sess = out_predicted_Q_mat{sess_i};
        end
        if ~isnan(Q_sess)
            for neu_i = 1:size(Q_sess, 1)
                FR_thres = 5;
                [L_max_v, max_L_idx] = max(Q_sess(neu_i, 1:w_len));
                [R_max_v, max_R_idx] = max(Q_sess(neu_i, w_len+1:end));

                FR_left_same = abs(Q_sess(neu_i, 1:w_len) - L_max_v) < 1;
                FR_right_same = abs(Q_sess(neu_i, w_len+1:end) - R_max_v) < 1;

                if L_max_v > FR_thres && R_max_v > FR_thres && ~all(FR_left_same) && ~all(FR_right_same)
                    max_fields(max_L_idx, max_R_idx) = max_fields(max_L_idx, max_R_idx) + 1;
                    neu_w_fields_idx{sess_i} = [neu_w_fields_idx{sess_i}, neu_i];
                elseif L_max_v > FR_thres && ~all(FR_left_same)
                    left_only_count = left_only_count + 1;
                elseif R_max_v > FR_thres && ~all(FR_right_same)
                    right_only_count = right_only_count + 1;
                end
            end
        end
    end

    max_fields = max_fields / sum(sum(max_fields));
    cfg_plot = [];
    cfg_plot.ax = subplot(1, 2, d_i);
    cfg_plot.fs = 20;
    plot_matrix(cfg_plot, max_fields);
    title(exp_cond{d_i});

%     imagesc(max_fields); colorbar;
    set(gca,'YDir','normal');
    xlabel('L');
    ylabel('R');
end