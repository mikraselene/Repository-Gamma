clc;
clear;

[data, information] = ReadData(123);

function [output, information] = ReadData(n)

    fprintf('Reading base file...\n');

    file = fopen('data/1.txt', 'r');
    base_data = textscan(file, 'E%d %s %c %d');
    output = struct('id', [], 'name', [], 'credit', [], 'flag', [], 'info_in', [], 'info_out', []);
    for ii = 1:size(base_data{1})
        output(ii).id = base_data{1}(ii);
        output(ii).name = base_data{2}(ii);
        output(ii).credit = base_data{3}(ii);
        output(ii).flag = base_data{4}(ii);
    end
    fclose(file);

    fprintf('Complete.\n');

    fprintf('Reading sheet A...\n');

    file = fopen('data/2.txt', 'r');
    data = textscan(file, 'E%d %d %s A%d %f %f %f %d');
    index = data{1}(1:size(data{1}, 1));
    temp_info_in = struct('id', [], 'invno', [], 'date', [], 'serial_date', [], 'seller_id', [], 'amount', [], 'tax', [], 'total', [], 'tax_rate', [], 'flag', []);
    for ii = 1:size(data{1}, 1)
        temp_info_in(ii).id = data{1}(ii);
        temp_info_in(ii).invno = data{2}(ii);
        temp_info_in(ii).date = data{3}(ii);
        temp_info_in(ii).serial_date = datenum(data{3}(ii), 'yyyy/mm/dd');
        temp_info_in(ii).seller_id = data{4}(ii);
        temp_info_in(ii).amount = data{5}(ii);
        temp_info_in(ii).tax = data{6}(ii);
        temp_info_in(ii).total = data{7}(ii);
        temp_info_in(ii).tax_rate = data{6}(ii) / data{7}(ii);
        temp_info_in(ii).flag = data{8}(ii);
    end
    for ii = 1:n
        output(ii).info_in = temp_info_in(index == ii);
    end
    fclose(file);

    fprintf('Complete.\n');

    fprintf('Reading sheet B...\n');

    file = fopen('data/3.txt', 'r');
    data = textscan(file, 'E%d %d %s B%d %f %f %f %d');
    index = data{1}(1:size(data{1}, 1));
    temp_info_out = struct('id', [], 'invno', [], 'date', [], 'serial_date', [], 'seller_id', [], 'amount', [], 'tax', [], 'total', [], 'tax_rate', [], 'flag', []);
    for ii = 1:size(data{1}, 1)
        temp_info_out(ii).id = data{1}(ii);
        temp_info_out(ii).invno = data{2}(ii);
        temp_info_out(ii).date = data{3}(ii);
        temp_info_out(ii).serial_date = datenum(data{3}(ii), 'yyyy/mm/dd');
        temp_info_out(ii).seller_id = data{4}(ii);
        temp_info_out(ii).amount = data{5}(ii);
        temp_info_out(ii).tax = data{6}(ii);
        temp_info_out(ii).total = data{7}(ii);
        temp_info_out(ii).tax_rate = data{6}(ii) / data{7}(ii);
        temp_info_out(ii).flag = data{8}(ii);
    end
    for ii = 1:n
        output(ii).info_out = temp_info_in(index == ii);
    end
    fclose(file);

    fprintf('Complete.\n');

    fprintf('Reading info...\n');

    file = fopen('data/st.txt', 'r');
    data = textscan(file, '%f %f %f %f');
    information = struct('rate', [], 'A', [], 'B', [], 'C', []);
    for ii = 1:size(data{1}, 1)
        information(ii).rate = data{1}(ii);
        information(ii).A = data{2}(ii);
        information(ii).B = data{3}(ii);
        information(ii).C = data{4}(ii);
    end
    fclose(file);

    fprintf('Complete.\n');

end
