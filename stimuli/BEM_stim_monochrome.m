function [ImL, ImR] = BEM_stim_monochrome(Aperture, Disparity, Color)
% [ImL, ImR] = BEM_stim_monochrome(Aperture, Disparity, Color)
%
% Inputs
%   Aperture     [scalar] Binary image showing disparity target location
%   Disparity    [vector] Desired binocular disparity, pixels
%   Color        [scalar] Grayscale value, 0-1
%
% Output
%   ImL          [matrix] m x n x d, where m x n are stimulus images,
%                         and d are disparities
%   ImR          [matrix] idem
%
% Given a binary aperture image, fill the aperture with the desired
% grayscale monochrome value.
%
% 18/10/2019    Written
%
% Ivan Alvarez
% FMRIB Centre, University of Oxford

%% Main

% Infer image size from aperture
ImSize = mode(size(Aperture));

% Color in aperture with desired grayscale shade
Im = zeros(size(Aperture));
Im(Aperture) = Color;

% Pre-allocate image matrices
ImL = nan(ImSize, ImSize, length(Disparity));
ImR = nan(ImSize, ImSize, length(Disparity));

% Loop disparities
for d = 1 : length(Disparity)
            
    % Shift LE and RE image
    ImL(:,:,d) = imtranslate(Im, [-round(Disparity(d) / 2), 0]);
    ImR(:,:,d) = imtranslate(Im, [+round(Disparity(d) / 2), 0]);
end
            
% Done
%