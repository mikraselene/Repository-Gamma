clc;
clear;

f = Solution([3, 1, 4, 2], [2, 3, 1, 4]);

function [fun] = Solution(num, func)
    fun = cell(4);
    fun{1} = @sin;
    fun{2} = @cos;
    fun{3} = @exp;
    fun{4} = @(x)log(1 + x);

    x = -1:2/100:5;
    for i = 1:4
        subplot(2, 2, num(i));
        plot(x, fun{func(i)}(x));
        if i ~= 4
            title(['y = ', func2str(fun{func(i)}), '(x)']);
        else
            title('y = log(1 + x)');
        end
    end
end
