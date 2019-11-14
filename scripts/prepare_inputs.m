%% Get Carey Q inputs.
cfg_data = [];
cfg_data.use_adr_data = 0;
cfg_data.removeInterneurons = 1;
% cfg_data.normalization = 'norm_average';
[Q] = prepare_all_Q(cfg_data);

% Remove cells that are significantly correlated between L and R.
% cfg_data.removeCorrelations = 'pos';
% Q = remove_corr_cells(Q, cfg_data.removeCorrelations);

%% Get ADR Q input
cfg_data = [];
cfg_data.use_adr_data = 1;
cfg_data.removeInterneurons = 1;
% cfg_data.normalization = 'norm_average';
[adr_Q] = prepare_all_Q(cfg_data);

%% Get simulated inputs.
Q_xor = L_xor_R([]);
Q_ind = L_R_ind([]);
Q_same_ps = L_R_ind(struct('same_params', [1, 1, 1]));
Q_sim_HT = sim_HT([]);

%% Get TC inputs.
cfg_data = [];
cfg_data.only_use_cp = 1;
[TC] = prepare_all_TC(cfg_data);
