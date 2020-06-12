function g = BEM_grating(Size, Period, Ori, Phase)
% g = BEM_grating(Size, Period, Ori, Phase)
% 
% Inputs
%   Size     [scalar] matrix size, in pixels
%   Period   [scalar] period of one cycle, in pixels
%   Ori      [scalar] orientation, in radians
%   Phase    [scalar] phase of the grating, in radians
%
% Generates a sinusoidal 2D grating, with the desired parameters.
% Values in the grating span -1 to +1
%

% Changelog
% 25/10/2017    Written
% 16/05/2019    Complete re-write. The mesh space now includes negative
%               and positive values to avoid shifting bar position with
%               rotation
%

%% Main

% Create mesh grid
XY = linspace(-(Size / 2), +(Size / 2), Size);
[X, Y] = meshgrid(XY);

% Rotate space
P = X .* cos(Ori) - Y .* sin(Ori);

% Trig function
g = cos(-2 * pi .* P ./ Period + Phase);

% Done 
%