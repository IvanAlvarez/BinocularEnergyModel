function Parameters = BEM_parameters
% Parameters = BEM_parameters
%
% Input
%   <none>
% Output
%   Parameters     [struct]
%
% Changelog
% 28/06/2018    Written
% 02/07/2018    Added parallel pool options
% 12/07/2018    Added 'joint' option to RF phase encoding
% 26/07/2018    Updated RF size priors
% 04/08/2018    Added complex cell output parameter to RF. [MD]
% 05/06/2019    Converted from script to function to allow internal calls
% 05/06/2019    Dropped checkerboard stimulus type
%               Added stimulus aperture options
%               More consistent use of the word 'frame' for stimuli
% 10/06/2019    Changed stimulus GratingPeriod to GratingSF
% 11/06/2019    Added multiple stimulus options
%               Segregated stimulus frames and aperture positions
% 26/06/2019    Added pRF fitting parameters
% 05/07/2019    Added pRF signal normalisation
% 08/07/2019    Added baseline specification for pRF signal normalisation
% 23/07/2019    Added radial checkerboard stimulus options
% 18/10/2019    Added monochrome stimulus type
% 25/05/2021    Added wedge aperture type
%               Made randot dot color and correlation explicitly stated
%

%% Startup

% Empty structure
Parameters = struct;

%% General parameters

% General
Parameters.NumCells = 1; % How many complex binocular cells

% 'Physical' display
Parameters.ImSize = 10; % degVA
Parameters.PixPerDeg = 30; % Pixels

% File & UI
Parameters.SaveDir = '/vols/Scratch/ialvarez/Projects/BEM';
Parameters.Waitbar = 1; % on/off

% File units
Parameters.Units = 'deg'; % pix or deg. Start with all values defined in degrees.

%% Parallel computing parameters

% Matlab parallelisation
Parameters.ParallelPool = 0; % on/off

% NOTE: UI progress bar in parallel jobs requires the ParforProgMon toolbox

%% Stimulus parameters

% Stimulus type
% 'grating'     Sinusoidal grating
% 'noise'       White noise
% 'monochrome'  Solid color inside aperture
% 'randot'      Black and white random dots
% 'lincheck'    Linear checkerboard
% 'radcheck'    Radial checkerboard
% 'load'        Load an existing file
%
% If stimulus set to 'load', the target file should contain a structure 
% called 'Stimulus' containing two fields, Stimulus.ImL and Stimulus.ImR. 
%
% These contain the stimulus images for the left and right eye respectively 
% Each has the format m x n x d x a x f, where <m x n> is a stimulus image,
% <d> are disparities, <a> are aperture steps and <f> are unique frames for
% each aperture step
%
Parameters.Stim.Type = 'grating';

% Stimulus disparity
Parameters.Stim.Disparity = -1 : 0.1 : 1; % Disparities, degVA

% Grating stimulus
Parameters.Stim.GratingSF = 0.5;     % Grating spatial frequency, cpd
Parameters.Stim.GratingOri = 0;      % Grating orientation, radians
Parameters.Stim.GratingPhase = 0;    % Grating phase, radians

% Noise stimulus
Parameters.Stim.NoisePower = 0;      % White Gaussian noise power, dBW
Parameters.Stim.NoiseBlockSize = 1;  % Block width x height, pixels
Parameters.Stim.NoiseBackground = 'uncorrelated'; % correlated, uncorrelated, blank

% Monochrome stimulus
Parameters.Stim.MonochromeCol = 1;   % Grayscale value inside aperture, 0-1

% Random dot stimulus
Parameters.Stim.RandotDotRadius = 0.2;             % Dot radius, degVA
Parameters.Stim.RandotDotNum = 500;                % Number of dots
Parameters.Stim.Randot.ForegroundDotColor = 'bw';  % monotone, bw
Parameters.Stim.Randot.BackgroundDotColor = 'bw';  % monotone, bw
Parameters.Stim.Randot.ForegroundDotCorrelation = 'correlated';  % correlated, uncorrelated, anticorrelated
Parameters.Stim.Randot.BackgroundDotCorrelation = 'uncorrelated';  % correlated, uncorrelated, anticorrelated

% Linear checkerboard stimulus
Parameters.Stim.LinCheckNum = 300;     % Number of checkers, total 

% Radial checkerboard stimulus
Parameters.Stim.RadCheckWedges = 20;   % Number of wedge elements
Parameters.Stim.RadCheckRings = 10;    % Number of ring elements

% Load stimulus
Parameters.Stim.LoadFile = [];

%% Aperture parameters

% Aperture types
% 'full'      Full-field stimulus
% 'bar'       Sweeping bar
% 'wedge'     Rotating wedge
%
% Apertures are binary masks added on top of the stimulus generated. Each
% individual frame is independent.
Parameters.Stim.Aperture = 'full';

% Aperture settings
Parameters.Stim.ApSteps = 1;          % How many aperture steps
Parameters.Stim.Nframes = 1;          % How many frames per aperture step

% Bar aperture settings
Parameters.Stim.ApertureBarOri = 'lr'; % ud, lr, diag1, diag2
Parameters.Stim.ApertureBarWidth = 1; % degVA

% Wedge aperture settings
Parameters.Stim.ApertureWedgeWidth = 20; % degrees of unit circle
Parameters.Stim.ApertureWedgeDir = '+'; % + (clockwise), - (counter-clockwise)

% Force monocular stimulus (only present LE)
Parameters.Stim.Monocular = false;

%% Receptive field parameters

% RF position
%
% 'fixed'   all set to fixation
% 'normal'  distributed around fixation, with more RFs near the center
% 'grid'    equally spaced square grid of RF positions
% 'radial'  equally spaced radial grid of RF positions
% 'uniform' equally likely in all locations, fully random
%
Parameters.RF.PositionDist = 'normal';

% If position set to normal, define standard deviation of Gaussian
%
Parameters.RF.PositionStd = 3; % degVA

% RF size
%
% 'fixed'   all set to the mean value
% 'normal'  distributed around mean ± std
% 'eccbias' anchored to the RF position eccentricity
%
% Define the RF size along the orthogonal direction, i.e. aligned with the
% horizontal grating, when the RF is vertically oriented.
% For the eccentricity bias option, we force the RF size to be scaled by RF
% position, in relation to the centre of the image. Optional noise can be
% added to the RF positions.
%
% A reasonable sigma range for V1 spanning eccentricities 0-10 is [0.1 2] 
% at the population level, according to Wandell & Winawer, 2015.
%
Parameters.RF.SizeDist = 'eccbias';
Parameters.RF.SizeMean = 1.00; % degVA
Parameters.RF.SizeStd = 0.20; % degVA
Parameters.RF.SizeEccBiasRange = [0.1 1]; % degVA
Parameters.RF.SizeEccBiasNoise = 0; % ±degVA

% RF anisotropy ratio
%
% 'fixed'   all set to the mean value
% 'normal'  distributed around mean ± std
%
% Simple V1 receptive fields are not isotropic. Acording to macaque data 
% in Ringach et al. (2003), the principal direction is about 1.5x the 
% orthogonal direction. The values below define the RF size along the 
% principal direction, in relation to the size defined above for the
% orthogonal direction. If the receptive field is vertically oriented, then
% it's the fraction below defined the vertical extent.
%
Parameters.RF.AniDist = 'fixed';
Parameters.RF.AniMean = 1.50; % fraction
Parameters.RF.AniStd = 0; % fraction

% RF spatial frequency
%
% 'fixed'   all set to the mean value
% 'normal'  distributed around mean ± std
% 'anchor'  anchored to the ortogonal RF size (Sigma2)
%
% Spatial frequency is defined in cycles per degree (cpd). However, in real
% cells the SF is correlated with the orthogonal RF size. The option
% 'anchor' allows the SF to be set as a fraction of the orthogonal RF size
% (Sigma2), with some variability. 
% If the option 'anchor' is chosen, the scaling factor on Sigma2 is normally
% distributed around SFanchorMean ±SFanchorStd. Variability is defined on
% the scaling factor, not on the spatial frequency in cpd.
%
Parameters.RF.SFDist = 'anchor';
Parameters.RF.SFMean = 1; % cpd
Parameters.RF.SFStd = 0.1; % cpd
Parameters.RF.SFAnchorMean = 3; % scaling factor on Sigma2
Parameters.RF.SFAnchorStd = 0; % ± scaling factor

% RF position encoding
%
% 'fixed'   all set to the mean value
% 'normal'  distributed around mean ± std
% 'gamma'   gamma distribution with mean as the spread parameter
% 'uniform' equally likely in the range ± 2 std, fully random
%
% Disparity tuning can be introduced by either position or phase encoding
% (Prince et al. 2002b). Position encoding is shifting the RF center in the 
% LE and RE by a certain value away from each other.
% Prince et al. (2002b) reports phase encoded disparities in the ±0.5deg range
%
Parameters.RF.PosEncodingDist = 'uniform';
Parameters.RF.PosEncodingMean = 0; % degVA
Parameters.RF.PosEncodingStd = 0.25; % degVA

% RF phase encoding
%
% 'fixed'   all set to the mean value
% 'normal'  distributed around mean ± std
% 'gamma'   gamma distribution with mean as the spread parameter
% 'uniform' equally likely in the range ± 2 std, fully random
% 'joint'   enforce equal contribution of position and phase encoding
%
% Disparity tuning can be introduced by either position or phase encoding
% (Prince et al. 2002b). Phase encoding is shifting the RF phase in LE and
% RE by a give value away from each other. We define it in equivalent steps
% of degrees of visual angle here, then convert it to radians later.
% Prince et al. (2002b) reports phase encoded disparities in the ±0.5deg range
%
Parameters.RF.PhaseEncodingDist = 'fixed';
Parameters.RF.PhaseEncodingMean = 0; % degVA
Parameters.RF.PhaseEncodingStd = 0.25; % degVA

% RF size-disparity correlation
%
% In V1 neurons, preferred disparity is limited by the size of the RF (or
% more correctly, by the period of the RF grating). If this is turned on,
% both RF position and phase encoding will be restricted to be at or below
% 1/2 of the period of the sinusoidal grating, consistent with data in
% Prince et al. (2002b).
%
Parameters.RF.SizeDispCorr = true; % true/false

% RF orientation
%
% 'fixed'    all set to vertical (0)
% 'uniform'  equally likely in all orientations, fully random
%
% Disparity-tuned V1 cells occur equally in all orientations (Prince 
% 2002a). However, for modelling purposes we will set all RF to be
% vertically oriented.
%
Parameters.RF.OriDist = 'fixed';

% RF phase
% Set to quadrature pair for BEM
%
Parameters.RF.Phase = [0, pi, pi*0.5, pi*1.5]; % radians, two pairs

% Complex cell output
% Can be 'Linear' as in cBEM or 'Squared' as in gBEM
%
Parameters.RF.CxActivation = 'Linear';

%% pRF fitting parameters

% Timeseries conversion
%
% Define how we wish to convert the complex cell response from the model
% fit into a timeseries response
%
Parameters.Prf.AvgCells = false; % true/false
Parameters.Prf.AvgDisparities = false; 
Parameters.Prf.AvgFrames = true;
Parameters.Prf.SignalNormalization = true; 
Parameters.Prf.SignalBaseline = []; % Amplitude value

% pRF coarse fit
%
Parameters.Prf.SearchGridX = 0 : 1 : 10; % degVA
Parameters.Prf.SearchGridY = 0 : 1 : 10; % degVA
Parameters.Prf.SearchGridSigma = 0.01 : 0.1 : 2; % degVA

% Done
%