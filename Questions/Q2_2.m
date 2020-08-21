clc;
clear;

f = Solution(1.5, 0.5);

function [figure1] = Solution(r1, r2)
    [theta, phi] = meshgrid(0:pi / 100:2 * pi, 0:pi / 100:2 * pi);
    x = (r1 + r2 * cos(phi)) .* cos(theta);
    y = (r1 + r2 * cos(phi)) .* sin(theta);
    z = r2 * cos(phi);
    % z = r2 * sin(phi);
    % The question is wrong, it should be sin(phi), not cos(phi).
    figure1 = surf(x, y, z);
    xlabel('x');
    ylabel('y');
    zlabel('z');
    grid on;
    colormap jet;
    colorbar;
end
