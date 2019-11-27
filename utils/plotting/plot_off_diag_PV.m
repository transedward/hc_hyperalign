function [mean_coefs_types, sem_coefs_types, all_coefs_types] = plot_off_diag_PV(cfg_in, datas, themes)
    % Plot Population Vector analysis
    cfg_def = [];
    cfg_def.fs = 12;
    cfg_def.ax = []; % handle to axes to plot in, e.g. ax = subplot(221)

    cfg = ProcessConfig(cfg_def, cfg_in);

    if ~isempty(cfg.ax)
        axes(cfg.ax);
    else
        cfg.ax = gca;
    end

    mean_coefs_types = zeros(length(datas), 1);
    sem_coefs_types = zeros(length(datas), 1);

    for d_i = 1:length(datas)
        data = datas{d_i};
        data = cellfun(@(x) [x.left, x.right], data, 'UniformOutput', false);
        coefs = cell(1, length(data));
        w_len = size(data{1}, 2);
        for i = 1:length(data)
            w_coefs = zeros(w_len, w_len);
            for j = 1:w_len
                for k = 1:w_len
                    [coef] = corrcoef(data{i}(:, j), data{i}(:, k));
                    w_coefs(j, k) = coef(1, 2);
                end
            end
            coefs{i} = w_coefs;
        end
        off_diag_coefs = zeros(w_len/2, length(data));
        for c_i = 1:length(coefs)
            off_diag_coefs(:, c_i) = diag(coefs{c_i}(1:w_len/2, (w_len/2+1):end));
        end
        
        mean_coefs_types(d_i) = nanmean(off_diag_coefs(:));
        sem_coefs_types(d_i) = nanstd(off_diag_coefs(:)) / sqrt(cfg.num_subjs(d_i));
        all_coefs_types{d_i} = off_diag_coefs;
    end

    dx = 0.1;
    x = dx * (1:length(datas));
    xpad = 0.05;
    h = errorbar(x, mean_coefs_types, sem_coefs_types, 'LineStyle', 'none', 'LineWidth', 2);
    set(h, 'Color', 'k');
    hold on;
    plot(x, mean_coefs_types, '.k', 'MarkerSize', 20);
    set(gca, 'XTick', x, 'YTick', [cfg.ylim(1):dx:cfg.ylim(2)], 'XTickLabel', themes, ...
        'XLim', [x(1)-xpad x(end)+xpad], 'YLim', [cfg.ylim(1) cfg.ylim(2)], 'FontSize', cfg.fs, ...
        'LineWidth', 1, 'TickDir', 'out');
    box off;
    plot([x(1)-xpad x(end)+xpad], [0 0], '--k', 'LineWidth', 1, 'Color', [0.7 0.7 0.7]);

end
