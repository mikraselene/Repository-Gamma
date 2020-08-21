clc;
clear;

f = Solution();

function [figure1] = Solution()
    t = 0:1/100:50;
    x = cos(0.05 .* t) .* cos(2 .* t);
    y = cos(0.05 .* t) .* sin(2 .* t);
    figure1 = plot3(x, y, t);
    title('Three-Dimensional Line Plot')
    xlabel('x');
    ylabel('y');
    zlabel('time');
    grid on;
end
