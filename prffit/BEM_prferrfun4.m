function [SSE, Pred] = BEM_prferrfun4(Aperture, Y, P)
% [SSE, Pred] = BEM_prferrfun4(Aperture, Y, P)
%
% Inputs
%   Aperture     [m x n x step] binary representation of stimulus aperture
%   Y            [vector] signal observed
%   P            [vector] parameters to be optimised
%                         P(1) = X position
%                         P(2) = Y position
%                         P(3) = Sigma (RF width)
%                         P(4) = Beta (amplitude scaling)
%  Outputs
%   SSE          [scalar] sum of squared errors
%   Pred         [vector] signal prediction 
%
% 4-parameter version of the pRF error function, fitting position (X,Y),
% size (sigma) and amplitude (beta).

% Changelog
% 26/05/2019    Written
% 08/07/2019    Split into 2- and 4-parameter versions
%

%% Main

% Infer image size from aperture
ImSize = size(Aperture, 1);

% Generate receptive field
Rf = BEM_gaussian(ImSize, [P(1), P(2)], [P(3), P(3)], 0);

% Convolve with aperture
Yp = bsxfun(@times, Rf, Aperture);

% Sum pixels
Yp = squeeze(sum(sum(Yp, 1), 2));

% Amplitude scaling
Yp = (Yp ./ max(Yp)) .* P(4);

% Calculate error
SSE = sum((Y - Yp) .^ 2);

% Create prediction output
if nargout > 1
    Pred = Yp;
end

% Done
%