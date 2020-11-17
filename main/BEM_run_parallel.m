function [Simple, Complex] = BEM_run_parallel(Parameters, Stimulus, CellPop)
% [Simple, Complex] = BEM_run_parallel(Parameters, Stimulus, CellPop)
%
% Input
%   Parameters   [struct] See BEM_parameters
%   Stimulus     [struct] See BEM_make_stimulus
%   CellPop      [struct] See BEM_make_cellpop
%
% Output
%   Simple       [cell x frame x disp x phase] Simple binocular cell response
%   Complex      [cell x frame x disp] Complex binocular cell response
%
% Run the model. Take the receptive field properties specified in CellPop,
% create the corresponding filters, feed them the left and right eye inputs
% in Stimuli, and calculate the simple and complex binocular cell
% responses.
% Computational time is reduced by only producing each unique receptive
% field filter once, and applying it to all the stimulus frames across
% frames and disparities in one go, hence the vectorisation of image 
% variables.
%
% This version exploits parallel threading in Matlab, when available.
%
% Changelog
% 28/06/2018    Written
% 12/07/2018    Removed waitbar for cluster use
%               Added convolution counter
%               Replaced implicit matrix multiplication with explicit
%                bsxfun call for backwards compatibility
% 19/07/2018    Simple cell output is stored before non-linearity
% 17/08/2018    Added ParforProgMon support
% 05/09/2018    Half-squaring now done with BEM_rectify
% 11/06/2019    Segregated stimulus frames and aperture positions
%               Fixed stimulus vectorisation
% 17/11/2020    Dropped ParforProgMon dependency

%% Input

if nargin == 0
    help BEM_run_parallel
    return
end

%% Settings

% Call variables, for easier indexing
ImSize = size(Stimulus.ImL, 1);
Phase = Parameters.RF.Phase;

% Set the complex cell activation function
switch Parameters.RF.CxActivation
    case 'Linear'
        % cBEM
        CxActivationF = @(x) x;
    case 'Squared' 
        % gBEM 
        CxActivationF = @(x) x.^2;
end

% How many complex cells, RF phases, stimulus disparities, aperture steps
% and frames
Ncell = Parameters.NumCells;
Nphase = length(Parameters.RF.Phase);
Ndisp = length(Parameters.Stim.Disparity);
Nstep = Parameters.Stim.ApSteps;
Nframe = Parameters.Stim.Nframes;

% Search grid
[Gx, Gy] = ndgrid(1:Ncell, 1:Nphase);

% How many individual convolutions to run, in total
Nconv = numel(Gx);

%% Parallelisation

% Obtain parallel pool. The following options are available:
%  (1) If parallel pool present, use it
%  (2) If no parallel pool present, create one
%  (3) If not requested, disable parallel pooling
Poolobj = BEM_parpool(Parameters);

%% Vectorise stimulus

% Vectorise image dimension
ImL = reshape(Stimulus.ImL, [ImSize .^ 2, Ndisp, Nstep, Nframe]);
ImR = reshape(Stimulus.ImR, [ImSize .^ 2, Ndisp, Nstep, Nframe]);

%% Convolve

% Report to user
disp(['Running ' num2str(Nconv) ' convolutions.'])

% Pre-allocate vectorised output matrix
SS = nan(Nconv, Ndisp * Nstep * Nframe);

% Loop convolutions
parfor (i = 1:Nconv, Poolobj.NumWorkers)
    
    % Get indices
    c = Gx(i); % Cell
    p = Gy(i); % Phase
    
    % Make filters
    [rfL, rfR] = BEM_filter(Parameters, CellPop, c, Phase(p));
    
    % Vectorise filters
    rfL = rfL(:);
    rfR = rfR(:);
    
    % Multiply filter & stimulus (across frames and disparities)
    cL = bsxfun(@times, ImL, rfL);
    cR = bsxfun(@times, ImR, rfR);
    
    % Sum across image
    vL = sum(cL, 1);
    vR = sum(cR, 1);
    
    % Sum left and right scalars at each disparity & frames
    vLR = vL + vR;

    % Reshape
    vLR = permute(vLR, [2 3 4 1]);
    vLR = vLR(:);
    
    % Store
    SS(i, :) = vLR;    
end

%% Reshape data

% Reshape
SS = reshape(SS, [Nconv, Ndisp, Nstep, Nframe]);

% Pre-allocate output variable
Simple = nan(Ncell, Ndisp, Nstep, Nframe, Nphase);

% Allocate
for i = 1:Nconv
    Simple(Gx(i), :, :, :, Gy(i)) = SS(i, :, :, :);
end
    
% Half-wave rectify and square
Simple = BEM_rectify(Simple, 'half-square');

% Sum simple cell responses across phase
Complex = sum(Simple, 5);

% Apply activation function
Complex = CxActivationF(Complex);

% Done
%