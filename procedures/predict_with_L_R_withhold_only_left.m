function [actual_dists_mat, id_dists_mat, predicted_Q_mat] = predict_with_L_R_withhold_only_left(cfg_in, Q)
    % Perform PCA, hyperalignment (with either two or all sessions)
    % and predict target matirx (only Q or TC matrix).
    % Note that target matrix would be excluded from the analysis and only used as ground truth.
    % The way that this function performs hyperalignment is concatenating left(L) and right(R) into [L, R].
    cfg_def.NumComponents = 10;
    % If shuffled is specified, source session would be identity shuffled.
    cfg_def.shuffled = 0;
    % Shuffling can be either row shuffles, 'row' or circular shift shuffles, 'shift'.
    cfg_def.shuffle_method = 'row';
    % Use 'all' to calculate a squared error (scalar) between predicted and actual.
    % Use 1 to sum across PCs (or units) and obtain a vector of squared errors.
    cfg_def.dist_dim = 'all';
    mfun = mfilename;
    cfg = ProcessConfig(cfg_def,cfg_in,mfun);
    w_len = size(Q{1}.left, 2);

    % Project [L, R] to PCA space.
    for p_i = 1:length(Q)
        pca_input = Q{p_i};
        [proj_Q{p_i}, eigvecs{p_i}, pca_mean{p_i}] = perform_pca(pca_input, cfg.NumComponents);
    end

    if cfg.shuffled
        % Shuffle right Q matrix
        s_Q = Q;
        for s_i = 1:length(Q)
            if strcmp(cfg.shuffle_method, 'row')
                shuffle_indices = randperm(size(Q{s_i}.right, 1));
                s_Q{s_i}.right = Q{s_i}.right(shuffle_indices, :);
            elseif strcmp(cfg.shuffle_method, 'shift')
                for r_i = 1:size(Q{s_i}.right, 1)
                    [shuffle_indices] = shift_shuffle(w_len);
                    R_row = Q{s_i}.right(r_i, :);
                    s_Q{s_i}.right(r_i, :) = R_row(shuffle_indices);
                end
            end
            s_pca_input = s_Q{s_i};
            [s_proj_Q{s_i}] = perform_pca(s_pca_input, cfg.NumComponents);
        end
    end

    actual_dists_mat  = zeros(length(Q));
    id_dists_mat  = zeros(length(Q));
    predicted_Q_mat = cell(length(Q));
    for sr_i = 1:length(Q)
        for tar_i = 1:length(Q)
            if sr_i ~= tar_i
                % Exclude target to be predicted
                ex_Q = Q;
                ex_Q{tar_i}.right = zeros(size(Q{tar_i}.right));
                % PCA
                ex_proj_Q = proj_Q;
                ex_eigvecs = eigvecs;
                ex_pca_mean = pca_mean;
                [ex_proj_Q{tar_i}, ex_eigvecs{tar_i}, ex_pca_mean{tar_i}] = perform_pca(ex_Q{tar_i}, cfg.NumComponents);

                % Perform hyperalignment on concatenated [L, R] in PCA for every source-target pair.
                if cfg.shuffled
                    hyper_input = {s_proj_Q{sr_i}.left, ex_proj_Q{tar_i}.left};
                else
                    hyper_input = {proj_Q{sr_i}.left, ex_proj_Q{tar_i}.left};
                end
                
                [aligned, transforms] = hyperalign(hyper_input{:});
                aligned_left_sr = aligned{1};
                
                if cfg.shuffled
                    aligned_right_sr = p_transform(transforms{1}, s_proj_Q{sr_i}.right);
                else
                    aligned_right_sr = p_transform(transforms{1}, proj_Q{sr_i}.right);
                end
                aligned_left_tar = aligned{2};
                transforms_tar = transforms{2};

                % Estimate M from L to R using source session.
                [~, ~, M] = procrustes(aligned_right_sr', aligned_left_sr', 'scaling', false);
                % Apply M to L of target session to predict.
                predicted_aligned = p_transform(M, aligned_left_tar);
                % Estimate using L (identity mapping).
                id_predicted_aligned = aligned_left_tar;

                % Project back to PCA space
                project_back_pca = inv_p_transform(transforms_tar, predicted_aligned);
                project_back_pca_id = inv_p_transform(transforms_tar, id_predicted_aligned);
               
                % Project back to Q space.
                project_back_Q = ex_eigvecs{tar_i} * project_back_pca + ex_pca_mean{tar_i};
                project_back_Q_right = project_back_Q;
                
                project_back_Q_id = ex_eigvecs{tar_i} * project_back_pca_id + ex_pca_mean{tar_i};
                project_back_Q_id_right = project_back_Q_id;

                p_target = project_back_Q_right;
                id_p_target = project_back_Q_id_right;
                ground_truth = Q{tar_i}.right;

                % Compare prediction using M with ground truth
                actual_dist = calculate_dist(cfg.dist_dim, p_target, ground_truth);
                id_dist = calculate_dist(cfg.dist_dim, id_p_target, ground_truth);
                actual_dists_mat(sr_i, tar_i) = actual_dist;
                id_dists_mat(sr_i, tar_i) = id_dist;
                predicted_Q_mat{sr_i, tar_i} = project_back_Q;
            end
        end
    end
end