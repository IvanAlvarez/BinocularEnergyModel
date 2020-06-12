function f = BEM_gaussian(Size, Mu, Sigma, Phi)
% f = BEM_gaussian(Size, Mu, Sigma, Phi)
%
% Inputs
%   Size    [scalar] number of pixels in the gaussian
%   Mu      [vector] peak of the function in [X Y], in units of Size
%   Sigma   [vector] spread along [X Y], in standard deviations of Size
%   Phi     [scalar] rotation, in radians
%
% Generates a 2D multivariate gaussian function. 
% Phi = 0 is vertical, positive values rotate counter-clockwise.

% Changelog
% 29/11/2017    Written
% 31/07/2018    Harmonised input order
%

%% Main

% X and Y coordinates
[xi, yi] = meshgrid(1:Size, 1:Size); 

% Shift coordinates
xi = xi - Mu(1);
yi = yi - Mu(2);

% Shift Phi so 0 corresponds to vertical
Phi = Phi + pi / 2;

% Indices
a = (cos(Phi)^2 / (2 * Sigma(1)^2)) + (sin(Phi)^2 / (2 * Sigma(2)^2));
b = - (sin(2 * Phi) / (2 * Sigma(1)^2)) + (sin(2 * Phi) / (2 * Sigma(2)^2));
c = (sin(Phi)^2 / (2 * Sigma(1)^2)) + (cos(Phi)^2 / (2 * Sigma(2)^2));

% Gaussian function
f = exp(-a*(xi).^2 - b*(xi).*(yi) - c*(yi).^2);

% Done 
%