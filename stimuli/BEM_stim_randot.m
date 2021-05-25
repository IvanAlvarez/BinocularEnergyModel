function [ImL, ImR] = BEM_stim_randot(Aperture, Disparity, DotRadius, DotNum, ForeDotColor, BackDotColor, ForeDotCorr, BackDotCorr)
% [ImL, ImR] = BEM_stim_randot(Aperture, Disparity, DotRadius, DotNum, ForeDotColor, BackDotColor, ForeDotCorr, BackDotCorr)
%
% Inputs
%   Aperture     [scalar] Binary image showing disparity target location
%   Disparity    [vector] Desired binocular disparity, pixels
%   DotRadius    [scalar] Radius of the dots, pixels
%   DotNum       [scalar] Number of dots
%   ForeDotColor [string] Color of dots inside the aperture
%                           'monotone' = +1
%                           'bw' = -1/+1, split half-and-half
%   BackDotColor [string] Color of dots outside the aperture
%                           'monotone' = +1
%                           'bw' = -1/+1, split half-and-half
%   ForeDotCorr  [string] Correlation of dots inside the aperture
%                           'correlated' = same color, same position
%                           'uncorrelated' = same color, different position
%                           'anticorrelated' = same position, opposite color
%   BackDotCorr  [string] Correlation of dots outside the aperture
%                           'correlated' = same color, same position
%                           'uncorrelated' = same color, different position
%                           'anticorrelated' = same position, opposite color
%
% Output
%   ImL          [matrix] m x n x d, where m x n are stimulus images,
%                         and d are disparities
%   ImR          [matrix] idem
%
% Given a binary aperture image, create a random dot image pair where
% binocular disparity has been added within the positive zone of the
% aperture image. Non-dot background is always 0.

% Changelog
% 08/06/2018    Written
% 08/06/2018    Got rid of imtranslate and replaced with matrix indexing
%               for faster performance following feedback from J Hadida
% 25/06/2018    Enforced border clearance
% 27/06/2018    Added handling for multiple disparities
%               Border clearance is now for the largest disparity requested
% 18/07/2018    Made Circle an embeded function
% 19/07/2018    Complete re-write of dot position calculation
%               Works with any arbitrary aperture 
%               Now handles missing clear zone cases by removing excess
%               dots         
% 24/07/2018    Re-write of dot position calculation, better handling of 
%               extreme disparity values
% 17/09/2018    Made disparity shift direction consistent with other
%               options in BEM_make_stimulus
% 11/06/2019    Added dot color option
% 16/01/2021    Added differential specification of dot color for
%               foreground and background
% 25/05/2021    Explicit and independent specification of dot color and dot
%               correlation for both foreground and background dots 
%

%% Settings

% Infer image size from aperture
ImSize = size(Aperture);

% Aperture indices
[ay, ax] = find(Aperture);

% How many disparities
DispNum = length(Disparity);

% Horizontal clearance to make sure dots don't fall off the edge of the image
Clearance = round([DotRadius, ImSize(1) - DotRadius]);

%% Background dots position & color

% Background dot positions, randomised independently for each eye
xBack{1} = randi(Clearance, [DotNum 1]);
yBack{1} = randi(Clearance, [DotNum 1]);
xBack{2} = randi(Clearance, [DotNum 1]);
yBack{2} = randi(Clearance, [DotNum 1]);

% Background dot color
switch BackDotColor
    case 'monotone'
        cBack{1} = ones(DotNum, 1);
        cBack{2} = ones(DotNum, 1);
    case 'bw'
        cBack{1} = randsample([-1 1], DotNum, true)';
        cBack{2} = randsample([-1 1], DotNum, true)';
end

% Background dot correlation
switch BackDotCorr
    case 'correlated'
        % Copy positions and colours from LE to RE
        xBack{2} = xBack{1};
        yBack{2} = yBack{1};
        cBack{2} = cBack{1};
    case 'anticorrelated'
        % Copy positions and colours from LE to RE, invert color
        xBack{2} = xBack{1};
        yBack{2} = yBack{1};
        cBack{2} = -cBack{1};
    case 'uncorrelated'
        % Leave as is
end

%% Foreground dots position & color

% Foreground dot positions, randomised independently for each eye
xFore{1} = randi(Clearance, [DotNum 1]);
yFore{1} = randi(Clearance, [DotNum 1]);
xFore{2} = randi(Clearance, [DotNum 1]);
yFore{2} = randi(Clearance, [DotNum 1]);

% Foreground dot color
switch ForeDotColor
    case 'monotone'
        cFore{1} = ones(DotNum, 1);
        cFore{2} = ones(DotNum, 1);
    case 'bw'
        cFore{1} = randsample([-1 1], DotNum, true)';
        cFore{2} = randsample([-1 1], DotNum, true)';
end

% Foreground dot correlation
switch ForeDotCorr
    case 'correlated'
        % Copy positions and colours from LE to RE
        xFore{2} = xFore{1};
        yFore{2} = yFore{1};
        cFore{2} = cFore{1};
    case 'anticorrelated'
        % Copy positions and colours from LE to RE, invert color
        xFore{2} = xFore{1};
        yFore{2} = yFore{1};
        cFore{2} = -cFore{1};
    case 'uncorrelated'
        % Leave as is
end

%% Add disparity to foreground dots

% Find foreground dots that fall inside aperture
Inside{1} = ismember([xFore{1}, yFore{1}], [ax, ay], 'rows');
Inside{2} = ismember([xFore{2}, yFore{2}], [ax, ay], 'rows');

% Direction of disparity shift for each eye
ShiftDir = [-1 +1];

% Pre-assign cell arrays (disparity x eye)
xPos = cell(DispNum, 2);
yPos = cell(DispNum, 2);
cPos = cell(DispNum, 2);

% Loop disparities
for d = 1:DispNum
    
    % Disparity shift, one entry for each eye
    Dshift = round((Disparity(d) / 2) * ShiftDir);
    
    % Loop eyes
    for e = 1:2

        % Shift aperture by desired disparity
        as = ax + Dshift(e);
        
        % Find background dots that fall inside the shifted aperture, i.e.
        % the overlap zone
        Overlap = ismember([xBack{e}, yBack{e}], [as, ay], 'rows');
        
        % Select background dots that do not fall in the overlap zone
        xb = xBack{e}(~Overlap);
        yb = yBack{e}(~Overlap);
        cb = cBack{e}(~Overlap);
        
        % Shift horizontal position of foreground dots
        xs = xFore{e}(Inside{e}) + Dshift(e);
        ys = yFore{e}(Inside{e});
        cs = cFore{e}(Inside{e});
        
        % Discard shifted dots that fall outside the image
        Castaway = xs < Clearance(1) | xs > Clearance(2);
        xs = xs(~Castaway);
        ys = ys(~Castaway);
        cs = cs(~Castaway);
        
        % Build up image 
        xPos{d,e} = [xs; xb];
        yPos{d,e} = [ys; yb];
        cPos{d,e} = [cs; cb];
    end
end
     
%% Create dot images

% Make base dot
D = Circle(DotRadius);

% Dot as x,y coordinates in relation to its centre
[Dx, Dy] = find(D == 1);
Dx = Dx - DotRadius;
Dy = Dy - DotRadius;

% Start with blank images, one frame per disparity
% Set the color to the desired background value 
Im{1} = ones([ImSize DispNum]);
Im{2} = ones([ImSize DispNum]);

% Loop eyes & disparities
for e = 1:2
    for d = 1:DispNum
        
        % Make a blank image
        Bi = zeros(ImSize);
        
        % Loop dots
        for i = 1:length(xPos{d,e})
            
            % Target coordinates
            xTarget = xPos{d,e}(i) - Dx + 1;
            yTarget = yPos{d,e}(i) - Dy + 1;
            
            % Convert to matrix indices
            Ind = sub2ind([ImSize ImSize], yTarget, xTarget);
            
            % Insert dot in target zone, with the desired colour
            Bi(Ind) = cPos{d,e}(i);
        end
        
        % Store frame
        Im{e}(:,:,d) = Bi;
    end
end

% Store each eye image
ImL = Im{1};
ImR = Im{2};

% Done
%