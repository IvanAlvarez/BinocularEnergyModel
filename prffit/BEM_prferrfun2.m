function [SSE, Pred] = BEM_prferrfun2(Aperture, Y, Loc, P)
% [SSE, Pred] = BEM_prferrfun2(Aperture, Y, Loc, P)
%
% Inputs
%   Aperture     [m x n x step] binary representation of stimulus aperture
%   Y            [vector] signal observed
%   Loc          [vector] X and Y position of pRF, in pixels
%   P            [vector] parameters to be optimised
%                         P(1) = Sigma (RF width)
%                         P(2) = Beta (amplitude scaling)
%  Outputs
%   SSE          [scalar] sum of squared errors
%   Pred         [vector] signal prediction 
%
% 2-parameter version of the pRF error function, fitting size (sigma) and 
% amplitude (beta)

% Changelog
% 26/05/2019    Written
% 08/07/2019    Split into 2- and 4-parameter versions
%

%% Main

% Infer image size from aperture
ImSize = size(Aperture, 1);

% Generate receptive field
Rf = BEM_gaussian(ImSize, Loc, [P(1), P(1)], 0);

% Convolve with aperture
Yp = bsxfun(@times, Rf, Aperture);

% Sum pixels
Yp = squeeze(sum(sum(Yp, 1), 2));

% Amplitude scaling
Yp = (Yp ./ max(Yp)) .* P(2);

% Calculate error
SSE = sum((Y - Yp) .^ 2);

% Create prediction output
if nargout > 1
    Pred = Yp;
end

% Done
%