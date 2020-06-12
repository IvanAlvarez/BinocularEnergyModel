function [ImL, ImR] = BEM_stim_lincheck(Aperture, Disparity, CheckNum)
% [ImL, ImR] = BEM_stim_lincheck(Aperture, Disparity, CheckNum)
%
% Inputs
%   Aperture     [scalar] Binary image showing disparity target location
%   Disparity    [vector] Desired binocular disparity, pixels
%   CheckNum     [scalar] Number of checkerboards in X and Y
%
% Output
%   ImL          [matrix] m x n x d, where m x n are stimulus images,
%                         and d are disparities
%   ImR          [matrix] idem
%
% Generate a linear checkerboard stimulus with binocular disparity, passed
% through a set of binary apertures.
% 
% Changelog
% 28/08/2019    Written
%

%% Main

% Infer image size from aperture
ImSize = mode(size(Aperture));

% Make linear checkerboard image
Im = BEM_linearcheck(ImSize, CheckNum);

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