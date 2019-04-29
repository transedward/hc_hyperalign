%% Prepare input
% Last 2.4 second, dt = 50ms
w_len = 48;
% Or last 41 bins (after all choice points) for TC
% w_len = 41;
rng(mean('hyperalignment'));

p_xor = 0;
p_same_mu = 1/10;
for q_i = 1:19
    % Number of neurons
    n_units = randi([60, 120]);
    Q{q_i}.left = zeros(n_units, w_len);
    Q{q_i}.right = zeros(n_units, w_len);
    for n_i = 1:n_units
        [Q{q_i}.left(n_i, :), Q{q_i}.right(n_i, :)] = get_mixture_cell(p_xor, p_same_mu);
    end
    % Different normalization.
    % Ind. normalization
    Q_norm_ind{q_i} = normalize_Q('ind', Q{q_i});
    % Concat. normalization
    Q_norm_concat{q_i} = normalize_Q('concat', Q{q_i});
    % Subtract the means
    Q_norm_sub{q_i} = normalize_Q('sub_mean', Q{q_i});
end
