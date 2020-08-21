clear;
clc;

start_time = clock;

% Information which is given in the problem.
require = [3, 7, 9, 12, 15, 18, 20, 25, 28, 36];
material_length = 3000;
material_width = 100;
component = struct('length', [], 'width', [], 'quantity', [], 'type', [], 'flag_4', [], 'id', []);
temp = load('m2.txt');
component.length = temp(:, 1);
component.width = temp(:, 2);
component.quantity = temp(:, 3);
n_component = length(component.length);

for i = 1:n_component
    component.id(i, 1) = i;
    component.flag_4(i, 1) = ismember(i, require);
    switch component.width(i)
        case 20
            component.type(i, 1) = 1;
        case 30
            component.type(i, 1) = 2;
        case 35
            component.type(i, 1) = 3;
        case 50
            component.type(i, 1) = 4;
    end
end

temp = struct('id', [], 'length', 0, 'quantity', [], 'flag_4', []);
sub_component = repmat(temp, [4, 1]);
temp = struct('pt_id', [], 'length', [], 'quantity', [], 'flag_4', []);
sub_c_temp = repmat(temp, [4, 1]);
clear temp;

for i = 1:4
    sub_component(i).id = component.id(component.type == i);
    sub_component(i).length = component.length(component.type == i);
    sub_component(i).quantity = component.quantity(component.type == i);
    sub_component(i).flag_4 = component.flag_4(component.type == i);
    n_sub_component = size(sub_component(i).length, 1);
    sub_c_temp(i) = SolutionLength(sub_component(i), n_sub_component, material_length, i);
end
clear sub_component;

sub_c.length = [sub_c_temp(1).length; sub_c_temp(2).length; sub_c_temp(3).length; sub_c_temp(4).length];
sub_c.quantity = [sub_c_temp(1).quantity; sub_c_temp(2).quantity; sub_c_temp(3).quantity; sub_c_temp(4).quantity];
sub_c.flag_4 = [sub_c_temp(1).flag_4; sub_c_temp(2).flag_4; sub_c_temp(3).flag_4; sub_c_temp(4).flag_4];
sub_c.pt_id = [sub_c_temp(1).pt_id; sub_c_temp(2).pt_id; sub_c_temp(3).pt_id; sub_c_temp(4).pt_id];
n_component = size(sub_c.length, 1);
clear sub_c_temp;

% Final solution.
SolutionWidth(sub_c, n_component, material_length, material_width);

function SolutionWidth(component, n_component, material_length, material_width)

    % Do not display unnecessary feedbacks.
    opts.lp = optimoptions('linprog', 'Display', 'off');
    opts.ip = optimoptions('intlinprog', opts.lp);

    % An initial feasible cutting pattern (the simplest patterns).
    patterns = diag(floor(material_width ./ component.length));
    n_patterns = size(patterns, 2);

    % Initialize the variables for the loop.
    reduced_cost = -inf;
    reduced_cost_tolerance = -0.0001;
    exit_flag = 1;

    % Call the loop, which is the main body of the solution_
    %clc;
    while reduced_cost < reduced_cost_tolerance && exit_flag

        lb = zeros(n_patterns, 1);
        f = lb + 1;
        A = -patterns;
        b = -component.quantity;
        [~, ~, exit_flag, ~, lambda] = ...
            linprog(f, A, b, [], [], lb, [], opts.lp);

        if exit_flag > 0

            % Generate a new pattern, if possible:
            % Call a subproblem to generate patterns until no further improvement is found.
            intcon = 1:n_component;
            f2 = -lambda.ineqlin; % linear inequalities corresponding to A and b
            lb2 = zeros(n_component, 1); % lower bound vector
            A2 = component.length';
            b2 = material_width;
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
            [is, ~] = IsRequired(f, A, b, lb, opts.ip, patterns, component);
            if is
                res.f = f;
                res.A = A;
                res.b = b;
                res.lb = lb;
                res.patterns = patterns;
            end
        end
    end

    % Do not display unnecessary feedbacks.
    opts.lp = optimoptions('linprog', 'Display', 'off');
    opts.ip = optimoptions('intlinprog', opts.lp);

    f = res.f;
    A = res.A;
    b = res.b;
    lb = res.lb;
    patterns = res.patterns;

    % Solve the problem again with final patterns.
    patterns_count = 0;
    bars_count_in_4 = 0;
    [values, used] = intlinprog(f, 1:length(lb), A, b, [], [], lb, [], opts.ip);
    values = round(values);
    used = round(used);
    total_waste = 0;
    for i = 1:size(values)
        if values(i) > 0
            flag_4 = 0;
            patterns_count = patterns_count + 1;
            fprintf('%g * [', values(i));
            count = 0;
            for j = 1:size(patterns, 1)
                if patterns(j, i) > 0
                    count = count + patterns(j, i);
                    switch component.length(j)
                        case 20
                            str = 'A';
                        case 30
                            str = 'B';
                        case 35
                            str = 'C';
                        case 50
                            str = 'D';
                    end
                    fprintf('%s%d(%d), ', str, component.pt_id(j), patterns(j, i));
                    if component.flag_4(j)
                        flag_4 = 1;
                    end
                end
            end
            fprintf('\b\b]');
            if flag_4
                fprintf(' {4}');
            end
            bars_count_in_4 = bars_count_in_4 + flag_4 * values(i);
            waste = 0;
            total_waste = total_waste + waste;
            fprintf('\n');
        end
    end
    total_waste = used * material_length * material_width - 134259120;
    ratio = 100 - total_waste * 100 / (used * material_length * material_width);
    fprintf('Optimal solution uses %g bar(s) of material.\n', used);
    fprintf('Optimal solution uses %g cutting patterns.\n', patterns_count);
    fprintf('Total waste is %g m^2.\n', total_waste / 1000000);
    fprintf('Utilization ratio is %g %%.\n', ratio);
    fprintf('Bar(s) count in 4 days is %g.\n', bars_count_in_4);

end

function [result] = SolutionLength(component, n_component, material_length, type_flag)

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
    r_min = inf;

    % Call the loop, which is the main body of the solution_
    while reduced_cost < reduced_cost_tolerance && exit_flag > 0

        lb = zeros(n_patterns, 1);
        f = lb + 1;
        A = -patterns;
        b = -component.quantity;
        % Finds the minimum of f' * x,
        % s.t.
        %   A * x <= b;
        %   lb <= x.
        % Generally, n_est_material = f' * x.
        [~, ~, exit_flag, ~, lambda] = ...
            linprog(f, A, b, [], [], lb, [], opts.lp);

        if exit_flag > 0

            % Generate a new pattern, if possible:
            % Call a subproblem to generate patterns until no further improvement is found.
            intcon = 1:n_component;
            f2 = -lambda.ineqlin; % linear inequalities corresponding to A and b
            lb2 = zeros(n_component, 1); % lower bound vector
            A2 = component.length';
            b2 = material_length;
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
            [~, r] = IsRequired(f, A, b, lb, opts.ip, patterns, component);

            if r < r_min
                r_min = r;
                res.f = f;
                res.A = A;
                res.b = b;
                res.lb = lb;
                res.patterns = patterns;
            end
        end

    end

    f = res.f;
    A = res.A;
    b = res.b;
    lb = res.lb;
    patterns = res.patterns;

    % Solve the problem again with final patterns.
    patterns_count = 0;
    values = intlinprog(f, 1:length(lb), A, b, [], [], lb, [], opts.ip);
    values = round(values);
    for i = 1:size(values)
        if values(i) > 0
            patterns_count = patterns_count + 1;
            str = ['A', 'B', 'C', 'D'];
            flag_4 = 0;
            fprintf('%s%g:\t%g * [', str(type_flag), patterns_count, values(i));
            count = 0;
            for j = 1:size(patterns, 1)
                if patterns(j, i) > 0
                    count = count + patterns(j, i);
                    fprintf('%d(%d), ', component.id(j), patterns(j, i));
                    if component.flag_4(j)
                        flag_4 = 1;
                    end
                end
            end
            fprintf('\b\b]');
            if flag_4
                fprintf(' {4}');
            end
            fprintf('\n');

            result.quantity(patterns_count, 1) = values(i);
            result.flag_4(patterns_count, 1) = flag_4;
            result.pt_id(patterns_count, 1) = patterns_count;
        end
    end

    num = [20, 30, 35, 50];
    result.length = zeros(length(result.quantity), 1) + num(type_flag);
    fprintf('\n');

end

function [is_required, result] = IsRequired(f, A, b, lb, o, patterns, component)

    is_required = 0;
    values = intlinprog(f, 1:length(lb), A, b, [], [], lb, [], o);
    bars_count_in_4 = 0;
    for i = 1:size(values)
        if values(i) > 0
            flag_4 = 0;
            for j = 1:size(patterns, 1)
                if patterns(j, i) > 0
                    if component.flag_4(j)
                        flag_4 = 1;
                    end
                end
            end
            bars_count_in_4 = bars_count_in_4 + flag_4 * values(i);
        end
    end
    if bars_count_in_4 <= 20 * 4
        is_required = 1;
    end
    result = bars_count_in_4;

end
