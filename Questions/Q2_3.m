clc;
clear;

y = [1, 2, 3; 2, 3, 4; 6, 8, 9; 0, 11, 12];
f = Solution(y);

function [figure1] = Solution(y)
    x = [1, 2, 3, 4];
    figure1 = bar(x, y, 'stacked');
    title('Bar plot');
    xlabel('x');
    ylabel('y');
end
