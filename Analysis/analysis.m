clear;
clf;

a = ReadData('sample', 14);
Ta = SampleFirst(a);
new_Ta = SampleSecond(a);

b = ReadData('test', 14);
Tb = TestFirst(b);
new_Tb = TestSecond(b);

sample_error = 0;

for i = 1:14
    sample_error = sample_error + CrossValidation(a, i);
end

test_error = 0;

for i = 1:14
    test_error = test_error + CrossValidation(b, i);
end

function [data] = ReadData(dataset, num)

    data = struct('index', [], 'value', [], 'type', 0);

    for i = 1:num
        filename = [dataset, '/', dataset, num2str(i), '.txt'];
        temp = load(filename);
        data(i).index = temp(:, 1);
        data(i).value = temp(:, 2);
        data(i).type = 0;
    end

end

function [feature] = GetFeature(data)

    for i = 1:14
        f(1) = size(data(i).value, 1);
        f(2) = median(data(i).value);
        f(3) = mean(data(i).value);
        f(4) = std(data(i).value);
        f(5) = var(data(i).value);
        f(6) = skewness(data(i).value);
        f(7) = kurtosis(data(i).value);
        f(8) = prctile(data(i).value, 75) - prctile(data(i).value, 25);
        f(9) = std(data(i).value) / mean(data(i).value);
        f(10) = corr(data(i).index, data(i).value);
        f(11) = corr(data(i).index, data(i).value, 'type', 'spearman');
        f(12) = corr(data(i).index, data(i).value, 'type', 'kendall');
        f(13) = range(data(i).value);
        [~, f(14)] = max(data(i).value);
        f(15) = (f(14) - 1) * corr(data(i).index(1:f(14)), data(i).value(1:f(14)), 'type', 'spearman');
        f(16) = (f(1) - f(14)) * corr(data(i).index(f(14):f(1)), data(i).value(f(14):f(1)), 'type', 'spearman');
        s = size(data(i).value, 1);
        count_peak = 0;

        for j = 100:s - 100
            max_value = max(data(i).value(j - 99:j + 99));
            r = range(data(i).value(j - 99:j + 99));

            if (max_value == data(i).value(j) && r > range(data(i).value) * 0.1)
                count_peak = count_peak + 1;
            end

        end

        count_bottom = 0;

        for j = 100:s - 100
            min_value = min(data(i).value(j - 99:j + 99));
            r = range(data(i).value(j - 99:j + 99));

            if (min_value == data(i).value(j) && r > range(data(i).value) * 0.1)
                count_bottom = count_bottom + 1;
            end

        end

        f(17) = count_peak;
        f(18) = count_bottom;

        ft = [1 2 6 7 9 13 14 15 16 17];
        %ft = [3 6 7 9 13 14 15 16 17];
        ft = ft';

        for j = 1:size(ft, 1)
            feature(i, j) = f(ft(j));
        end

    end

end

function [new_data] = PCA(data, rate)

    temp = zscore(data);
    [coeff, ~, ~, ~, explained] = pca(temp);
    count = 1;
    total_rate = 0;

    while total_rate < rate
        total_rate = total_rate + explained(count) / 100;
        count = count + 1;
    end

    new_data = data * coeff(:, 1:count);

end

function [T] = HierarchicalClustering(data, mu, metric, method, tt)

    figure;

    data = zscore(data);
    Y = pdist(data, metric);
    Z = linkage(Y, method);
    T = cluster(Z, 'Cutoff', mu * max(Z(:, 3)), 'Criterion', 'distance');
    H = dendrogram(Z, 'Orientation', 'right', 'ColorThreshold', mu * max(Z(:, 3)));
    set(H, 'LineWidth', 2);
    title(tt);

end

function [idx, centroid] = KMeans(data, dataset, flag)

    rng default;

    switch (dataset)
        case 'sample'
            graph = zeros(1, 4);
            [idx, centroid] = kmeans(data, 3, 'Distance', 'sqeuclidean', 'Replicates', 5);

            if (flag)
                figure;
                color = ['g', 'b', 'r'];

                for i = 1:3
                    graph(i) = plot(data(idx == i, 1), data(idx == i, 2), [color(i), '.'], 'MarkerSize', 12);
                    hold on;
                end

                graph(4) = plot(centroid(:, 1), centroid(:, 2), 'k+', 'MarkerSize', 10, 'LineWidth', 1);
                title("k 均值聚类散点图 - sample");
                xlabel("F1");
                ylabel("F2");
                legend([graph(3), graph(1), graph(2), graph(4)], 'A 类', 'B 类', 'C 类', '重心', 'Location', 'SE');
                box on;
            end

        case 'test'
            [idx, centroid] = kmeans(data, 4, 'Distance', 'sqeuclidean', 'Replicates', 5);
            graph = zeros(1, 5);

            if (flag)
                figure;
                color = ['g', 'b', 'r', 'k', 'c', 'm'];

                for i = 1:4

                    graph(i) = plot(data(idx == i, 1), data(idx == i, 2), [color(i), '.'], 'MarkerSize', 12);
                    hold on;

                end

                graph(5) = plot(centroid(:, 1), centroid(:, 2), 'k+', 'MarkerSize', 10, 'LineWidth', 1);
                title("k 均值聚类散点图 - test");
                xlabel("F1");
                ylabel("F2");
                legend([graph(3), graph(2), graph(1), graph(4), graph(5)], ...
                    'A 类', 'B 类', 'C 类', 'D 类', '重心', 'Location', 'NE');
                box on;
            end

    end

end

function [is_error] = CrossValidation(data, index)

    [feature] = GetFeature(data);
    [new_feature] = PCA(feature, 0.85);

    [old_index, ~] = KMeans(new_feature, 'sample', 0);
    [old_index, ~] = T2Cluster(old_index);

    test_data = new_feature(index, :);
    new_feature(index, :) = [];
    [new_index, C] = KMeans(new_feature, 'sample', 0);
    [~, cluster_index] = T2Cluster(new_index);

    [~, idx_test] = pdist2(C, test_data, 'euclidean', 'Smallest', 1);

    if (find(cluster_index == idx_test) ~= old_index(index))
        is_error = 1;
    else
        is_error = 0;
    end

end

function [C, cluster_idx] = T2Cluster(T)

    T = T';
    cluster = [1, 2, 3];

    cluster_idx = zeros(1, 3);
    C = zeros(1, size(T, 2));

    count = 0;

    for i = 1:size(T, 2)

        if (ismember(T(i), cluster_idx) == 0)
            cluster_idx(count + 1) = T(i);
            count = count + 1;
        end

        C(i) = cluster(cluster_idx == T(i));

    end

end

function [] = Scatter(data, dataset)

    switch dataset

        case 'sample'
            color = ['r', 'g', 'b'];
            point = ['+', 'x', 's'];
            k = 0;

        case 'test'
            color = ['r', 'g', 'b', 'k', 'c', 'k'];
            point = ['+', 'x', 's', '*', '^', 'd'];
            k = 1;
    end

    G = Set(data, k);
    num = size(G, 2);

    figure;

    graph = zeros(num, 1);

    for i = 1:num

        graph(i) = scatter(G{i}(:, 1), G{i}(:, 2), 300, color(i), point(i));
        hold on;

    end

    switch dataset

        case 'sample'
            legend([graph(1), graph(2), graph(3)], 'A 类', 'B 类', 'C 类', 'Location', 'SE');

        case 'test'
            legend([graph(1), graph(2), graph(3), graph(4), graph(5), graph(6)], ...
                'A 类', 'B 类', 'C 类', 'D 类', 'E 类 (无归属)', 'F 类 (无归属)', 'Location', 'SE');

    end

    set(get(gca, 'XLabel'), 'String', 'F1');
    set(get(gca, 'YLabel'), 'String', 'F2');
    title(['散点图 - ' dataset]);
    xlabel("F1");
    ylabel("F2");

    box on;
    hold off;

end

function [T] = SampleFirst(sample)

    pure_data = zeros(14, 2250);

    for i = 1:14
        pure_data(i, :) = sample(i).value(1:2250);
    end

    [T] = HierarchicalClustering(pure_data, 0.2, 'euclidean', 'ward', "title");

    figure;
    color = ['r', 'g', 'b', 'c'];

    for i = 1:14

        graph = plot(sample(i).index, sample(i).value);
        set(graph, 'color', color(T(i)));
        hold on;

    end

    hold off;

end

function [new_T] = SampleSecond(sample)

    [feature] = GetFeature(sample);
    [new_feature] = PCA(feature, 0.9);
    [new_T] = HierarchicalClustering(new_feature, 0.2, 'mahal', 'ward', "层次聚类树状图 - sample");
    Scatter(new_feature, 'sample');
    KMeans(new_feature, 'sample', 1);

end

function [T] = TestFirst(test)

    pure_data = zeros(14, 2250);

    for i = 1:14
        pure_data(i, :) = test(i).value(1:2250);
    end

    [T] = HierarchicalClustering(pure_data, 0.2, 'euclidean', 'ward', "title");

    figure;
    color = ['r', 'g', 'b', 'm', 'k', 'c'];

    for i = 1:14

        graph = plot(test(i).index, test(i).value);
        set(graph, 'color', color(T(i)));
        hold on;

    end

    hold off;

end

function [new_T] = TestSecond(test)

    [feature] = GetFeature(test);
    [new_feature] = PCA(feature, 0.85);
    [new_T] = HierarchicalClustering(new_feature, 0.2, 'mahal', 'ward', "层次聚类树状图 - test");
    Scatter(new_feature, 'test');
    new_feature([4, 8], :) = [];
    KMeans(new_feature, 'test', 1);

end

function [G] = Set(data, k)

    if (k == 1)
        G = cell(1, 4);
        G{1, 1} = ([data(1, :); data(3, :); data(9, :); data(11, :)]);
        G{1, 2} = ([data(2, :); data(6, :); data(12, :); data(13, :)]);
        G{1, 3} = ([data(7, :); data(14, :)]);
        G{1, 4} = ([data(5, :); data(10, :)]);
        G{1, 5} = (data(4, :));
        G{1, 6} = (data(8, :));
    else
        G = cell(1, 3);
        G{1, 1} = [data(1, :); data(2, :); data(3, :); data(11, :)];
        G{1, 2} = [data(4, :); data(5, :); data(6, :); data(12, :); data(13, :)];
        G{1, 3} = [data(7, :); data(8, :); data(9, :); data(10, :); data(14, :)];
    end

end
