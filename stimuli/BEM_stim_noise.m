function [ImL, ImR] = BEM_stim_noise(Aperture, Disparity, BlockSize, Background)
% [ImL, ImR] = BEM_stim_noise(Aperture, Disparity, BlockSize, Background)
%
% Inputs
%   Aperture     [scalar] Binary image showing disparity target location
%   Disparity    [vector] Desired binocular disparity, pixels
%   BlockSize    [scalar] Width & height of each random element, pixels
%   Background   [string] 'correlated' matching zero-disparity background
%                         'uncorrelated' LE & RE background does not match
%                         'blank' LE & RE background set to zero
% Output
%   ImL          [matrix] m x n x d, where m x n are stimulus images,
%                         and d are disparities
%   ImR          [matrix] idem
%
% Given a binary aperture image, create a white noise pattern where
% binocular disparity has been added within the positive zone of the
% aperture image.
% The noise pattern contains square blocks with random values, where the
% width and height is determined by BlockSize.
%
% 24/07/2018    Written
% 17/08/2018    Made disparity shift direction consistent across stereo
%               scripts, i.e. LE=left, RE=right
% 22/08/2018    Re-wrote background handling
%               Added blank background option
% 06/09/2018    Fixed bug where multiple disparities were not handled
%               correctly, making all frames >1 incorrect
% 11/06/2019    Added block size
%
% Ivan Alvarez
% FMRIB Centre, University of Oxford

%% Main

% Infer image size from aperture
ImSize = size(Aperture);

% How many disparities
DispNum = length(Disparity);

% Direction of disparity shift for each eye
ShiftDir = [-1 +1];

% Find which pixels are inside the aperture
[ay, ax] = find(Aperture);
    
% Generate three noise distributions (foreground, background1, background2)
Noise = rand([ImSize, 3]);
Noise = (Noise * 2) - 1;

% Scale to the desired block size
Noise = Noise(1 : BlockSize : end, 1 : BlockSize : end, :);
Noise = repelem(Noise, BlockSize, BlockSize, 1);
Noise = Noise(1 : ImSize(1), 1 : ImSize(2), :);

% Noise image for foreground
NoiseFore = Noise(:, :, 1);

% Noise image for background
switch Background
    case 'correlated'
        NoiseBack{1} = Noise(:, :, 2);
        NoiseBack{2} = Noise(:, :, 2);
    case 'uncorrelated'
        NoiseBack{1} = Noise(:, :, 2);
        NoiseBack{2} = Noise(:, :, 3);        
    case 'blank'
        NoiseBack{1} = zeros(ImSize);
        NoiseBack{2} = zeros(ImSize);
end

% Start with blank image matrices
Im{1} = zeros([ImSize DispNum]);
Im{2} = zeros([ImSize DispNum]);

% Loop disparities
for d = 1:length(Disparity)

    % Disparity shift, one entry for each eye
    Dshift = round((Disparity(d) / 2) * ShiftDir);

    % Loop eyes
    for e = 1:2

        % Copy background image
        I = NoiseBack{e};
        
        % Target coordinates of shifted pixels
        tx = ax + Dshift(e);
        ty = ay;
        
        % Only include pixels that after shifting, fall inside the image
        Inside = tx > 0 & tx <= ImSize(1);
        
        % Coordinates to indices
        Source = sub2ind(ImSize, ay(Inside), ax(Inside));
        Target = sub2ind(ImSize, ty(Inside), tx(Inside));

        % Insert foreground pixels
        I(Target) = NoiseFore(Source);
        
        % Find indices of clear zone created by disparity shift
        Clear = ~ismember(ax, ax + Dshift(e));
        cx = ax(Clear);
        cy = ay(Clear);
        Clear = sub2ind(ImSize, cy, cx);
        
        % Fill clear zone with random pixels
        Fill = (rand(size(Clear)) * 2) - 1;
        I(Clear) = Fill;
        
        % Store image
        Im{e}(:,:,d) = I;
    end
end

% Assign matrices to each eye image
ImL = Im{1};
ImR = Im{2};

% Done
%