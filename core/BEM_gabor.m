function g = BEM_gabor(Size, X0, Y0, Sigma1, Sigma2, Period, Ori, Phase)
% g = BEM_gabor(Size, X0, Y0, Sigma1, Sigma2, Period, Ori, Phase)
%
% Inputs
%   Size     [scalar] width/height in pixels
%   X0       [scalar] peak of the function in X, in pixels
%   Y0       [scalar] peak of the function in Y, in pixels
%   Sigma1   [scalar] spread along principal direction, in pixels
%   Sigma2   [scalar] spread along orthogonal direction, in pixels
%   Period   [scalar] grating period, in pixels
%   Ori      [scalar] orientation of the grating, in radians
%   Phase    [scalar] phase of the grating, in radians
%   
% Generate a 2D Gabor patch from scratch.

% Changelog
% 05/12/2017    Written
% 31/07/2018    Harmonised input order
% 17/08/2018    Added phase adjustment to ensure the same point of the
%               grating is at the centre of the Gabor, independent of the
%               period of the grating
% 18/08/2018    Grating reference is mid-point
% 05/10/2018    Sigma now expressed in standard deviations, not the full
%               width of the Gaussian envelope
% 16/05/2019    Removed thresholding
%               Re-wrote BEM_grating, phase adjustment no longer necessary
%

%% Main

% Coordinates relative to image center
Center = Size / 2;
X0 = X0 - Center;
Y0 = Y0 - Center;

% Generate grating
g1 = BEM_grating(Size, Period, Ori, Phase);

% Generate Gaussian at centroid
g2 = BEM_gaussian(Size, [Center Center], [Sigma1 Sigma2], Ori);

% Multiply
g = g1 .* g2;

% Translate to requested coordinates
g = imtranslate(g, [X0, Y0]);

% Done 
%