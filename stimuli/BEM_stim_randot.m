function [ImL, ImR] = BEM_stim_randot(Aperture, Disparity, DotRadius, DotNum, DotColor, Background)
% [ImL, ImR] = BEM_stim_randot(Aperture, Disparity, DotRadius, DotNum, DotColor, Background)
%
% Inputs
%   Aperture     [scalar] Binary image showing disparity target location
%   Disparity    [vector] Desired binocular disparity, pixels
%   DotRadius    [scalar] Radius of the dots, pixels
%   DotNum       [scalar] Number of dots
%   DotColor     [string] 'monotone' background = 0, dots = 1
%                         'bw' backgrouns = 0, dots = -1/+1 
%   Background   [string] 'correlated' background dots match LE & RE
%                         'uncorrelated' background dots do not match
% Output
%   ImL          [matrix] m x n x d, where m x n are stimulus images,
%                         and d are disparities
%   ImR          [matrix] idem
%
% Given a binary aperture image, create a random dot image pair where
% binocular disparity has been added within the positive zone of the
% aperture image. 

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
%

%% Calculate dot positions

% Infer image size from aperture
ImSize = size(Aperture);

% Aperture indices
[ay, ax] = find(Aperture);

% How many disparities
DispNum = length(Disparity);

% Horizontal clearance to make sure dots don't fall off the edge of the image
Clearance = round([DotRadius, ImSize(1) - DotRadius]);

% Background random dot positions, one for each eye
xBack{1} = randi(Clearance, [DotNum 1]);
yBack{1} = randi(Clearance, [DotNum 1]);
xBack{2} = randi(Clearance, [DotNum 1]);
yBack{2} = randi(Clearance, [DotNum 1]);

% Background random dot colour, one for each eye
switch DotColor
    case 'monotone'
        cBack{1} = ones(DotNum, 1);
        cBack{2} = ones(DotNum, 1);
    case 'bw'
        cBack{1} = randsample([-1 1], DotNum, true)';
        cBack{2} = randsample([-1 1], DotNum, true)';
end

% Background dot positions and colours
switch Background
    case 'uncorrelated'
        % Leave as is

    case 'correlated'
        % Copy positions and colours form LE to RE
        xBack{2} = xBack{1};
        yBack{2} = yBack{1};
        cBack{2} = cBack{1};
end

% Foreground dot positions
xFore = randi(Clearance, [DotNum 1]);
yFore = randi(Clearance, [DotNum 1]);


% Foreground dot colour
switch DotColor
    case 'monotone'
        cFore = ones(DotNum, 1);
    case 'bw'
        cFore = randsample([-1 1], DotNum, true)';
end

% Find foreground dots that fall inside aperture
Inside = ismember([xFore, yFore], [ax ay], 'rows');

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
        xs = xFore(Inside) + Dshift(e);
        ys = yFore(Inside);
        cs = cFore(Inside);
        
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
Im{1} = zeros([ImSize DispNum]);
Im{2} = zeros([ImSize DispNum]);

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