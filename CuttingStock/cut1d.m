clear;
clc;

start_time = clock;

% Information which is given in the problem.
require.four = [5, 7, 9, 12, 15, 18, 20, 25, 28, 36, 48];
require.six = [4, 11, 24, 29, 32, 38, 40, 46, 50];
material_length = 3000;
loss = 5;
component = struct('length', [], 'quantity', []);
temp = load('m1.txt');
component.length = temp(:, 1);
component.quantity = temp(:, 2);
n_component = length(component.length);

% If fast_solution is ON, only solve when n_est_material >= 800.
fast_solution = 1;
Solution(component, n_component, material_length, loss, fast_solution, require);

% Calculate total time used when solving the problem.
end_time = clock;
fprintf('Time cost: %gs.\n', etime(end_time, start_time));

function [] = Solution(component, n_component, material_length, loss, fast_solution, require)

    % Do not display unnecessary feedbacks.
    opts.lp = optimoptions('linprog', 'Display', 'off');
    opts.ip = optimoptions('intlinprog', opts.lp);

    % An initial feasible cutting pattern (the simplest patterns).
    patterns = diag(floor(material_length ./ component.length));
    n_patterns = size(patterns, 2);

    % Initialize the variables for the loop.
    reduced_cost = -inf;
    reduced_cost_tolerance = -0.0001;
    exit_flag = 1;

    % Call the loop, which is the main body of the solution_
    while reduced_cost < reduced_cost_tolerance && exit_flag > 0
        fast_exit_flag = 0;
        lb = zeros(n_patterns, 1);
        f = lb + 1;
        A = -patterns;
        b = -component.quantity;
        % Finds the minimum of f' * x,
        % s.t.
        %   A * x <= b;
        %   lb <= x.
        % Generally, n_est_material = f' * x.
        [~, n_est_material, exit_flag, ~, lambda] = ...
            linprog(f, A, b, [], [], lb, [], opts.lp);

        if exit_flag > 0
            clc;
            fprintf('Solving...\n');

            % Only solve when n_est_material >= 800.
            if n_est_material < 800 && fast_solution
                fast_exit_flag = 1;
            end

            % Generate a new pattern, if possible:
            % Call a subproblem to generate patterns until no further improvement is found.
            intcon = 1:n_component;
            f2 = -lambda.ineqlin; % linear inequalities corresponding to A and b
            lb2 = zeros(n_component, 1); % lower bound vector
            A2 = component.length' + loss;
            b2 = material_length + loss;
            % Finds the minimum of f2' * x,
            % s.t.
            %   A2 * x <= b2;
            %   lb2 <= x.
            % Generally, values = x, reduced_cost = f' * x.
            [values, reduced_cost, new_exit_flag] = ...
                intlinprog(f2, intcon, A2, b2, [], [], lb2, [], opts.ip);
            reduced_cost = reduced_cost + 1;
            new_pattern = round(values);

            if new_exit_flag > 0 && reduced_cost < reduced_cost_tolerance
                % Expand patterns.
                patterns = [patterns, new_pattern]; % Do not care the warning here.
                n_patterns = n_patterns + 1;
            end

            if IsRequired(f, A, b, lb, opts.ip, patterns, require)
                result.f = f;
                result.A = A;
                result.b = b;
                result.lb = lb;
                result.patterns = patterns;
            end
        end

        if fast_exit_flag
            break;
        end
    end

    f = result.f;
    A = result.A;
    b = result.b;
    lb = result.lb;
    patterns = result.patterns;

    % Solve the problem again with final patterns.
    clc;
    [values, used] = intlinprog(f, 1:length(lb), A, b, [], [], lb, [], opts.ip);
    values = round(values);
    used = round(used);
    total_waste = 0;
    patterns_count = 0;
    bars_count_in_4 = 0;
    bars_count_in_6 = 0;

    for i = 1:size(values)
        if values(i) > 0
            flag_4 = 0;
            flag_6 = 0;
            patterns_count = patterns_count + 1;
            fprintf('%g * [', values(i));
            count = 0;
            for j = 1:size(patterns, 1)
                if patterns(j, i) > 0
                    count = count + patterns(j, i);
                    fprintf('%d(%d), ', j, patterns(j, i));
                    if ismember(j, require.four)
                        flag_4 = 1;
                    end
                    if ismember(j, require.six)
                        flag_6 = 1;
                    end
                end
            end
            bars_count_in_4 = bars_count_in_4 + flag_4 * values(i);
            bars_count_in_6 = bars_count_in_6 + flag_6 * values(i);
            waste = material_length ...
                - dot(patterns(:, i), component.length) + loss * values(i) * count;
            total_waste = total_waste + waste;
            fprintf('\b\b]');
            if flag_4 == 1 && flag_6 == 0
                fprintf(' {4}');
            end
            if flag_6 == 1 && flag_4 == 0
                fprintf(' {6}');
            end
            if flag_4 && flag_6
                fprintf(' {4, 6}');
            end
            fprintf('\n');
        end
    end

    ratio = 100 - total_waste * 100 / (used * material_length);
    fprintf('Optimal solution uses %g bar(s) of material.\n', used);
    fprintf('Optimal solution uses %g cutting patterns.\n', patterns_count);
    fprintf('Total waste is %g mm.\n', total_waste);
    fprintf('Utilization ratio is %g %%.\n', ratio);
    fprintf('Bar(s) count in 4 days is %g.\n', bars_count_in_4);
    fprintf('Bar(s) count in 6 days is %g.\n', bars_count_in_4 + bars_count_in_6);

end

function is_required = IsRequired(f, A, b, lb, o, patterns, require)

    is_required = 0;
    values = intlinprog(f, 1:length(lb), A, b, [], [], lb, [], o);
    bars_count_in_4 = 0;
    bars_count_in_6 = 0;
    for i = 1:size(values)
        if values(i) > 0
            flag_4 = 0;
            flag_6 = 0;
            for j = 1:size(patterns, 1)
                if patterns(j, i) > 0
                    if ismember(j, require.four)
                        flag_4 = 1;
                    end
                    if ismember(j, require.six)
                        flag_6 = 1;
                    end
                end
            end
            bars_count_in_4 = bars_count_in_4 + flag_4 * values(i);
            bars_count_in_6 = bars_count_in_6 + flag_6 * values(i);
        end
    end
    if bars_count_in_4 <= 400 && bars_count_in_4 + bars_count_in_6 <= 600
        is_required = 1;
    end

end
