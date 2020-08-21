clc;
clear;

mtx = [1 + 2 * 1i, 0 + 0.008 * 1i, -3 - 4 * 1i; ...
        4 + 0 * 1i, 0 - 1 * 1i, -2 + 2 * 1i];
out = Solution(mtx);
out;

function [out] = Solution(mtx)
    % Euler's formula: exp(i * x) = cos(x) + i * sin(x)
    out = cell(2, 3);
    for ii = 1:2
        for jj = 1:3
            a = real(mtx(ii, jj));
            b = imag(mtx(ii, jj));
            theta = atan(b / a);
            x = sqrt(a^2 + b^2);
            if x < 0.01
                out{ii, jj} = [];
            else
                if theta > 0
                    out{ii, jj} = [num2str(x, 2), 'exp(+', num2str(theta, 2), ')'];
                else
                    if theta < 0
                        out{ii, jj} = [num2str(x, 2), 'exp(', num2str(theta, 2), ')'];
                    else
                        out{ii, jj} = num2str(x, 2);
                    end
                end
            end
        end
    end

end
% QAQ
