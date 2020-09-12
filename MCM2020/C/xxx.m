r = zeros(1, 96);
for ii = 1:96
    r(ii) = Stability(data(ii));
end
%{
test_sl = [1, 1, 2, 3, 4, 5, 5, 5, 6, 7, 8];
test_al = [100, 100, 10, 2, 333, 10, 10, 10, 3, 4, 44];
qw = FindGreatestSeller(test_sl, test_al);
%}

function [res] = F(data)
    xx = data.info_in;
    amount = cell2mat({xx.amount});
    tax = cell2mat({xx.tax});
    total = cell2mat({xx.total});
    datex = cell2mat({xx.serial_date});
    id1 = cell2mat({xx.id});
    id2 = cell2mat({xx.seller_id});
    tax_rate = tax ./ total;
    res = scatter(datex, id2, '+');
    hold on;
end

function [res] = Func(data)
    xx = data.info_in;

    id2 = cell2mat({xx.seller_id});

    res = mode(id2);

end

% 稳定性: 返回 稳定性
function [stability] = Stability(data)
    xx = data.info_in;
    serial_date = cell2mat({xx.serial_date});
    seller_id = cell2mat({xx.seller_id});
    amount = cell2mat({xx.amount});
    begin_date = serial_date(1);
    ii_t = 1;
    ii = 1;
    cnt = 1;
    res = zeros(1, ceil(size(serial_date, 2) / 30));
    while begin_date + 30 <= serial_date(size(serial_date, 2))
        while serial_date(ii) < begin_date + 30
            ii = ii + 1;
        end
        sl = seller_id(ii_t:ii - 1);
        am = amount(ii_t:ii - 1);
        if (size(sl, 2) ~= 0)
            %res(cnt) = FindGreatestSeller(sl, am);
            temp_sl = unique(sl);
            max_am = -inf;
            max_sl = 1;
            for jj = 1:size(temp_sl, 2)
                temp_am = sum(am(sl == temp_sl(jj)));
                if temp_am > max_am
                    max_am = temp_am;
                    max_sl = temp_sl(jj);
                end
            end
            res(cnt) = max_sl;
        else
            res(cnt) = 0;
        end
        begin_date = begin_date + 30;
        ii_t = ii;
        cnt = cnt + 1;
    end
    res(res == 0) = [];
    s = size(res, 2);
    temp1 = size(find(res == mode(res)), 2);
    res(res == mode(res)) = [];
    temp2 = size(find(res == mode(res)), 2);
    res(res == mode(res)) = [];
    temp3 = size(find(res == mode(res)), 2);
    res(res == mode(res)) = [];
    temp4 = size(find(res == mode(res)), 2);
    res(res == mode(res)) = [];
    temp5 = size(find(res == mode(res)), 2);
    stability = (temp1 + temp2 + temp3 + temp4 + temp5) / s;
end

% 信用等级: 返回 信用等级
function [credit_level] = Credit(n)
    credit_level = data(n).credit;
end

% 反常: 返回 [发票作废率, 退款率]
function [ai_rate, na_rate] = Abnormal(data)
    xx = data.info_in;
    flag = cell2mat({xx.flag});
    amount = cell2mat({xx.amount});
    % abandoned invoice rate
    ai_rate = size(find(flag == 0), 2) / size(flag, 2);
    % negative amount rate
    na_rate = size(find(amount < 0), 2) / size(flag, 2);
end

function [res] = Influence()
end
