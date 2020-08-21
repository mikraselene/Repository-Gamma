clear;
clc;

res = Q6_myparity([1, 2, 3, 4, 5.4, 1 + 2 * 1i]);

function result = Q6_myparity(x)
    result = zeros(1, size(x, 2));
    for ii = 1:size(x, 2)
        if (x(ii) == real(x(ii))) && (floor(x(ii)) == x(ii))
            result(ii) = mod(x(ii), 2) == 0;
        else
            result(ii) = -1;
        end
    end
end
