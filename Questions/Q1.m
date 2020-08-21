clc;
clear;

[a, b, c, d] = Solution(2.2, 4);

function [a, b, c, d] = Solution(x, y)
    a = (4/3) * pi * y^2;
    b = (2 * y^(-2)) / (x + y)^2;
    c = y^3 / (y^3 - x^3);
    d = (4/3) * pi * y^2;
end
