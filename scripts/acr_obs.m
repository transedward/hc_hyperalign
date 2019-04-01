%% Get Q inputs.
cfg_data = [];
cfg_data.use_adr_data = 0;
[Q] = prepare_all_Q(cfg_data);

%% Get TC inputs.
cfg_data = [];
cfg_data.only_use_cp = 1;
[TC] = prepare_all_TC(cfg_data);

%% Main Procedure
data = Q;
cfg_pre = [];
cfg_pre.NNPCA = true;
cfg_pre.hyperalign_all = false;
cfg_pre.predict_target = 'Q';
cfg_pre.normalization = 'ind';
cfg_pre.dist_dim = 'all';
[actual_dists_mat, id_dists_mat, predicted_Q_mat] = predict_with_L_R(cfg_pre, data);

%% Shuffling operations
n_shuffles = 1000;
sf_dists_mat  = zeros(length(data), length(data), n_shuffles);

for i = 1:n_shuffles
    cfg_pre.shuffled = 1;
    [s_actual_dists_mat] = predict_with_L_R(cfg_pre, data);
    sf_dists_mat(:, :, i) = s_actual_dists_mat;
end
