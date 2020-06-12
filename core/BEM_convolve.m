function [SS, CS] = BEM_convolve(ImL, ImR, rfL, rfR)
% [SS, CS] = BEM_convolve(ImL, ImR, rfL, rfR)
%
% Input
%   ImL          [matrix] 2D matrix containing stimulus image for the left eye
%   ImR          [matrix] idem for right eye
%   rfL          [matrix] 3D matrix containing the receptive field image
%                           for the left eye. One slice (z) per Gabor phase
%   rfR          [matrix] idem for right eye
%
% Output
%   SS                     [vector] Simple cell responses, one per Gabor phase
%   CS                     [scalar] Complex cell response
%
% Convolve a single stimulus image pair (ImL, ImR) with four simple
% receptive fields (rfL, rfR) to calculate the simple and complex 
% binocular cell response.

% Changelog
% 05/06/2018    Written
%

%% Main

% Pre-allocate
SS = zeros(1, size(rfL, 3));

% Loop phases
for p = 1:size(rfL, 3)

    % Multiply stimulus image with receptive field
    vL = ImL .* rfL(:,:,p);
    vR = ImR .* rfR(:,:,p);
    
    % Sum pixels
    vL = sum(vL(:));
    vR = sum(vR(:));

    % Sum left and right scalars and store as simple cell response
    SS(p) = vL + vR;
end

% Apply half-squaring to simple cell responses
CS = max(SS, 0) .^ 2;

% Sum across phases to obtain complex cell response
CS = sum(CS);

% Done
%