function [Pred, R] = BEM_prfcoarsefit(Aperture, Rf, X, Y)
% [Pred, R] = BEM_prfcoarsefit(Aperture, Rf, X, Y)
% 
% Inputs
%   Aperture     [m x n x step] binary representation of stimulus aperture
%   Rf           [m x n x pred] 2D Gaussian receptive fields, one image
%                               per model prediction
%   X            [pred x param] fully sampled search grid parameters
%   Y            [vector] signal observed
%
% Output
%   Pred         [vector] parameters of best-fitting model prediction
%   R            [vector] correlation coefficient between signal observed
%                         and every prediction generated
%
% Perform grid search model fit.

% Changelog
% 26/06/2019    Written
%

%% Input

if nargin == 0
    help BEM_prfcoarsefit
    return
end

%% Main

% Find stimulated frames, if any
Stimulated = (squeeze(sum(sum(Aperture, 1), 2))) ~= 0;

% How many predictions
Npred = size(X, 1);

% Empty matrix
R = zeros(Npred, 1);

% Loop predictions in grid
for i = 1 : Npred

    % Convolve 2D Gaussian receptive field with aperture
    Yp = bsxfun(@times, Rf(:,:,i), Aperture);

    % Sum pixels
    Yp = squeeze(sum(sum(Yp, 1), 2));
    
    % Calculate correlation between signal observed and predicted
    R(i) = corr(Yp(Stimulated), Y(Stimulated));
end

% Find best-performing prediction
[~, Winner] = max(R);

% Parameters of winning prediction
Pred = X(Winner, :);

% Done
%