function g = BEM_radialcheck(Size, Wedges, Rings)
% g = BEM_radialcheck(Size, Wedges, Rings)
%
% Inputs
%   Size     [scalar] width/height in pixels
%   Wedges   [scalar] number of wedge elements, must be even
%   Rings    [scalar] number of ring elements
%   
% Generate a radial checkerboard image.

% Changelog
% 23/07/2019    Written
%

%% Main

% Radial limit
RadLim = 2 * pi * (Rings / 2);

% Range of values to sample
Range = -RadLim : 2 * RadLim / (Size - 1) : RadLim;

% Cartesian grid
[x, y] = ndgrid(Range);

% Radial grid
Theta = atan2(x, y);
Rho = x .^ 2 + y .^ 2;

% Wedge segments
P1 = sign(sin(Theta * (Wedges / 2)) + eps);

% Ring segments
P2 = sign(sin(sqrt(Rho)));

% Combine
Im = P1 .* P2;

% Apply circle mask
Circle = Rho <= (RadLim ^ 2);
g = Im .* Circle;

% Done 
%