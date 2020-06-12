function CellPop = BEM_make_cellpop(Parameters)
% CellPop = BEM_make_cellpop(Parameters)
%
% Input
%   Parameters   [struct] See BEM_parameters
%
% Output
%   CellPop.<>
%         X         [vector] Position in X, in degVA
%         Y         [vector] Position in Y, in degVA
%         SF        [vector] Spatial frequency, in cycles per degVA (cpd)
%         Sigma1    [vector] RF size along principal direction, in degVA
%         Sigma2    [vector] RF size along orthogonal direction, in degVA
%         TuningPos [vector] Position disparity tuning, in degVA
%         TuningPha [vector] Phase disparity tuning, in degVA
%         Ori       [vector] Orientation, in radians
%
% Generate a population of binocular complex cell definitions.

% Changelog
% 28/06/2018    Written
% 12/07/2018    Added 'joint' option to RF phase encoding
% 13/07/2018    Removed RadialGrid() dependency, pasted code here
% 26/07/2018    Fixed radial grid to avoid repeated dot positions
% 10/06/2019    Store Gabor grating spatial frequency instead of period
%

%% Input

if nargin < 1
    help BEM_make_cellpop
    return
end

%% Parameters

% Convert degVA to pixels
Parameters = BEM_convertunit('deg2pix', Parameters);

% How many complex cells. We will produce parameters for this number.
N = Parameters.NumCells;

% Size of the image matrix
ImSize = round(Parameters.ImSize);

%% RF position

% Positions can be:
% 'fixed'   all set to fixation
% 'normal'  distributed around fixation, with more RFs near the center
% 'grid'    equally spaced square grid of RF positions
% 'radial'  equally spaced radial grid of RF positions
% 'uniform' equally likely in all locations, fully random
%
% For random, grid, and normally distributed, the RF center will be 
% no closer to the edge of the image than the mean RF size + 2 SD 
% (for normally distributed RF size) or 1/2 of the maximum RF size 
% eccentricity bias range, whichever is greater.

% Find RF position clear border
Border(1) = Parameters.RF.SizeMean + Parameters.RF.SizeStd * 2; % RF size mean + 2 SD
Border(2) = Parameters.RF.SizeEccBiasRange(2); % Max RF size eccentricity bias
Border = round(max(Border) / 2);

% Options
switch Parameters.RF.PositionDist
 
    case 'fixed'
        % Place it in the center
        X = repmat(ImSize / 2, [N 1]);
        Y = repmat(ImSize / 2, [N 1]);
        
    case 'uniform'
        % Random positions within image & border
        X = randi([Border, ImSize - Border], N, 1);
        Y = randi([Border, ImSize - Border], N, 1);
        
    case 'grid'
        % Regularly spaced square grid
        XY = linspace(Border, ImSize - Border, ceil(sqrt(N)));
        [X, Y] = meshgrid(XY);
        X = X(1:N)';
        Y = Y(1:N)';
        
    case 'radial'
        % Regularly spaced radial grid
        Elem = ceil(sqrt(N));
        Radius = ImSize / 2;
        P = 2*pi/Elem : 2*pi/Elem : 2*pi;
        E = Radius/Elem : Radius/Elem : Radius;        
        [P, E] = meshgrid(P, E);
        [X, Y] = pol2cart(P, E);
        X = X(1:N)' + Radius;
        Y = Y(1:N)' + Radius;
        
    case 'normal'
        % Make a normal distribution
        nd = makedist('Normal');
        nd.mu = ImSize / 2;
        nd.sigma = Parameters.RF.PositionStd;
        
        % Truncate to within image size & border
        nd = truncate(nd, Border, ImSize - Border);
        
        % Sample from the distribution
        X = random(nd, N, 1);
        Y = random(nd, N, 1);
end

%% RF size (orthogonal)

% Define the orthorgonal RF size. i.e. if the RF is vertical, this is the
% horizontal size.
% RF size can be fixed, normally distributed, or biased by the RF location
% eccentricity
switch Parameters.RF.SizeDist
 
    case 'fixed'
        % Use the mean
        Sigma2 = repmat(Parameters.RF.SizeMean, [N, 1]);

    case 'normal'
        % Randomly sample from positive normal distribution
        nd = makedist('Normal');
        nd.mu = Parameters.RF.SizeMean;
        nd.sigma = Parameters.RF.SizeStd;
        nd = truncate(nd, 1, Inf);
        Sigma2 = random(nd, N, 1);
        
    case 'eccbias'
        % XY position relative to image center
        Xr = X - ImSize / 2;
        Yr = Y - ImSize / 2;
        
        % Find eccentricity position for every RF, and convert to fraction
        Ecc = sqrt(Xr .^ 2 + Yr .^ 2);
        Ecc = Ecc / max(Ecc);
        Ecc(isnan(Ecc)) = 0;
        
        % RF size is a pixel value, within the desired eccentricity bias
        % range
        Sigma2 = Ecc * diff(Parameters.RF.SizeEccBiasRange);
        Sigma2 = Sigma2 + Parameters.RF.SizeEccBiasRange(1);
        
        % Add noise
        Noise = (rand(N, 1) - 0.5) * 2 * Parameters.RF.SizeEccBiasNoise;
        Sigma2 = Sigma2 + Noise;
        
        % Ensure there are no values < 2 pixels
        Sigma2(Sigma2 < 2) = 2;
end

%% RF size (principal)

% Reflects the RF size along the principal direction, i.e. if the RF is
% vertical, this is the vertical size. Defined in relation to the
% orthogonal size. Size can be fixed or normally distributed.
switch Parameters.RF.AniDist

    case 'fixed'
        % Set to a fraction of the already-randomised orthogonal size
        Sigma1 = Sigma2 * Parameters.RF.AniMean;
        
    case 'normal'
        % Randomly sample ratios from normal distribution
        nd = makedist('Normal');
        nd.mu = Parameters.RF.AniMean;
        nd.sigma = Parameters.RF.AniStd;
        Ratio = random(nd, N, 1);
        
        % Orthogonal size is a weighted ratio of the orthogonal size
        Sigma1 = Sigma2 .* Ratio;
end

%% Grating spatial frequency

% The spatial frequency is defined either in cycles per pixels (cpp) or, 
% if anchored, in fractional steps relative to the orthogonal RF size
% (Sigma2). The output value will be in cycles per degree (cpd).
switch Parameters.RF.SFDist

    case 'fixed'
        
        % Use the mean
        SF = repmat(Parameters.RF.SFMean, [N, 1]);

    case 'normal'
        
        % Randomly sample spatial frequencies from normal distribution
        nd = makedist('Normal');
        nd.mu = Parameters.RF.SFMean;
        nd.sigma = Parameters.RF.SFStd;
        SF = random(nd, N, 1);
        
    case 'anchor'
    
        % Randomly sample scaling factors from normal distribution
        nd = makedist('Normal');
        nd.mu = Parameters.RF.SFAnchorMean;
        nd.sigma = Parameters.RF.SFAnchorStd;
        
        % Pull random values
        Anchor = random(nd, N, 1);
        
        % Force positive values
        Anchor = abs(Anchor);
        
        % Multiply the orthogonal RF size by scaling factor to get the
        % grating period, in pixels
        Period = Sigma2 .* Anchor;
        
        % Convert grating period to spatial frequency, in cycles per pixel
        SF = 1 ./ Period;
end

%% Disparity tuning - position encoding

% Disparity tuning by position encoding can be fixed, normal or gamma dist
% As an option, we can enforce size-disparity correlation, using the limit
% described in Prince 2002b of maximum disparity tuning of 1/2 grating
% period
switch Parameters.RF.PosEncodingDist
 
    case 'fixed'
        % Use the mean
        nd = makedist('Normal');
        nd.mu = Parameters.RF.PosEncodingMean;
        nd.sigma = 0;

    case 'normal'
        % Randomly sample from normal distribution
        nd = makedist('Normal');
        nd.mu = Parameters.RF.PosEncodingMean;
        nd.sigma = Parameters.RF.PosEncodingStd;
        
    case 'gamma'
        % Randomly sample from gamma distribution
        nd = makedist('Gamma');
        nd.a = 1;
        nd.b = Parameters.RF.PosEncodingMean;
        
    case 'uniform'
        nd = makedist('Uniform');
        nd.Lower = -2 * Parameters.RF.PosEncodingStd;
        nd.Upper = +2 * Parameters.RF.PosEncodingStd;
end

% Draw random samples
TuningPos = random(nd, N, 1);

% Enforce size-disparity correlation
if Parameters.RF.SizeDispCorr
 
    % Iteratively re-sample those cells that fall above the 1/2 grating 
    % period limit
    Offenders = 1;
    while sum(Offenders) > 0
        Offenders = abs(TuningPos) > Period / 2;
        TuningPos(Offenders) = random(nd, sum(Offenders), 1);
    end
end

%% Disparity tuning - phase encoding

% Disparity tuning by position encoding can be fixed, normal, gamma or 
% joint with position encoding. If joint is chosen, the final distribution
% is determined by the position encoding settings, and then split with half
% the contribution happening in position and half in phase encoding.
switch Parameters.RF.PhaseEncodingDist
 
    case 'fixed'
        % Use the mean
        TuningPha = repmat(Parameters.RF.PhaseEncodingMean, [N 1]);

    case 'normal'
        % Randomly sample from normal distribution
        nd = makedist('Normal');
        nd.mu = Parameters.RF.PhaseEncodingMean;
        nd.sigma = Parameters.RF.PhaseEncodingStd;
        TuningPha = random(nd, N, 1);

    case 'gamma'
        % Randomly sample from gamma distribution
        nd = makedist('Gamma');
        nd.a = 1;
        nd.b = Parameters.RF.PhaseEncodingMean;
        TuningPha = random(nd, N, 1);

    case 'uniform'
        nd = makedist('Uniform');
        nd.Lower = -2 * Parameters.RF.PhaseEncodingStd;
        nd.Upper = +2 * Parameters.RF.PhaseEncodingStd;
        TuningPha = random(nd, N, 1);

    case 'joint'
        TuningPos = TuningPos / 2;
        TuningPha = TuningPos;
end

% Enforce size-disparity correlation
if Parameters.RF.SizeDispCorr
 
    % Iteratively re-sample those cells that fall above the 1/2 grating 
    % period limit
    Offenders = 1;
    while sum(Offenders) > 0
        Offenders = abs(TuningPha) > Period / 2;
        TuningPha(Offenders) = random(nd, sum(Offenders), 1);
    end
end

%% Orientation

% Orientation can be fixed, or random
switch Parameters.RF.OriDist

    case 'fixed'
        % Set to 0 radians
        Ori = zeros(N, 1);
        
    case 'uniform'
        % Random values between 0 and pi radians
        Ori = rand(N, 1) * pi;
end

%% Store values

% Store
CellPop.X = X;
CellPop.Y = Y;
CellPop.SF = SF;
CellPop.Sigma1 = Sigma1;
CellPop.Sigma2 = Sigma2;
CellPop.TuningPos = TuningPos;
CellPop.TuningPha = TuningPha;
CellPop.Ori = Ori;

% Define current unit
CellPop.Units = 'pix';

% Convert from pixels to degVA
[~, CellPop] = BEM_convertunit('pix2deg', Parameters, CellPop);

% Done
%