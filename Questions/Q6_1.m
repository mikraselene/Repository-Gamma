clear;
clc;

result = Q6_findzero(@sin, [1, 5]);

function result = Q6_findzero(fun, span)
    hi = span(2);
    lo = span(1);
    fun_hi = fun(hi);
    fun_lo = fun(lo);
    while (fun_hi * fun_lo < 0)
        mid = (hi + lo) / 2;
        res = fun(mid);
        if (res * fun_lo < 0)
            hi = mid;
        else
            lo = mid;
        end
        if (abs(hi - lo) < 0.0001)
            break;
        end
    end
    result = (hi + lo) / 2;
end
