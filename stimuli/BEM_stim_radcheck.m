function [ImL, ImR] = BEM_stim_radcheck(Aperture, Disparity, Wedges, Rings)
% [ImL, ImR] = BEM_stim_radcheck(Aperture, Disparity, Wedges, Rings)
%
% Inputs
%   Aperture     [scalar] Binary image showing disparity target location
%   Disparity    [vector] Desired binocular disparity, pixels
%   Wedges       [scalar] Number of wedge elements
%   Rings        [scalar] Number of ring elements 
%
% Output
%   ImL          [matrix] m x n x d, where m x n are stimulus images,
%                         and d are disparities
%   ImR          [matrix] idem
%
% Generate a radial checkerboard stimulus with binocular disparity, passed
% through a set of binary apertures.
% 
% Changelog
% 23/07/2019    Written
% 28/08/2019    Re-named
%

%% Main

% Infer image size from aperture
ImSize = mode(size(Aperture));

% Make radial checkerboard image
Im = BEM_radialcheck(ImSize, Wedges, Rings);
        
% Pre-allocate image matrices
ImL = nan(ImSize, ImSize, length(Disparity));
ImR = nan(ImSize, ImSize, length(Disparity));
        
% Loop disparities
for d = 1 : length(Disparity)
            
    % Shift LE and RE images
    ImL(:,:,d) = imtranslate(Im, [-round(Disparity(d) / 2), 0]);
    ImR(:,:,d) = imtranslate(Im, [+round(Disparity(d) / 2), 0]);
end
            
% Apply binary aperture
ImL = ImL .* Aperture;
ImR = ImR .* Aperture;

% Done
%