function [ImL, ImR] = BEM_stim_grating(Aperture, Disparity, Period, Orientation, Phase)
% [ImL, ImR] = BEM_stim_grating(Aperture, Disparity, Period, Orientation, Phase)
%
% Inputs
%   Aperture     [scalar] Binary image showing disparity target location
%   Disparity    [vector] Desired binocular disparity, pixels
%   Period       [vector] Grating period, pixels
%   Orientation  [vector] Grating orientation, radians
%   Phase        [vector] Grating phase, radians
%
% Output
%   ImL          [matrix] m x n x d, where m x n are stimulus images,
%                         and d are disparities
%   ImR          [matrix] idem
%
% Generate a sinusoidal stimulus with binocular disparity, passed through 
% a set of binary apertures.
% 
% Changelog
% 05/06/2019    Written
%

%% Main

% Infer image size from aperture
ImSize = mode(size(Aperture));

% Make a sinusoidal grating image
Im = BEM_grating(ImSize, Period, Orientation, Phase);
        
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