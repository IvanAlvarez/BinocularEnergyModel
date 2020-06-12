function [Simple, Complex] = BEM_run(Parameters, Stimulus, CellPop)
% [Simple, Complex] = BEM_run(Parameters, Stimulus, CellPop)
%
% Input
%   Parameters   [struct] See BEM_parameters
%   Stimulus     [struct] See BEM_make_stimulus
%   CellPop      [struct] See BEM_make_cellpop
%
% Output
%   Simple       [cell x disp x aperture x frame x phase] Simple binocular cell response
%   Complex      [cell x disp x aperture x frame] Complex binocular cell response
%
% Run the model. Take the receptive field properties specified in CellPop,
% create the corresponding filters, feed them the left and right eye inputs
% in Stimuli, and calculate the simple and complex binocular cell
% responses. 
% Computational time is reduced by only producing each unique receptive
% field filter once, and applying it to all the stimulus frames and
% disparities in one go, hence the vectorisation of image variables.

% Changelog
% 28/06/2018    Written
% 02/07/2018    Optimised matrix multiplication
% 12/07/2018    Replaced implicit matrix multiplication with explicit
%                bsxfun call for backwards compatibility
% 19/07/2018    Simple cell output is stored before non-linearity
% 05/09/2018    Half-squaring now done with BEM_rectify
% 11/06/2019    Segregated stimulus frames and aperture positions
%

%% Input

if nargin == 0
    help BEM_run
    return
end

%% Settings

% Call variables, for easier indexing
ImSize = size(Stimulus.ImL, 1);
Phase = Parameters.RF.Phase;

% Set the complex cell activation function
switch Parameters.RF.CxActivation
    case 'Linear'
        % As in cBEM
        CxActivationF = @(x) x;
    case 'Squared' 
        % As in gBEM 
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

%% Open UI

% Open
if Parameters.Waitbar
    wb = waitbar(0, 'Convolving...');
end

%% Vectorise stimulus

% Vectorise image dimension
ImL = reshape(Stimulus.ImL, [ImSize .^ 2, Ndisp, Nstep, Nframe]);
ImR = reshape(Stimulus.ImR, [ImSize .^ 2, Ndisp, Nstep, Nframe]);

%% Convolve

% Pre-allocate vectorised output matrix
Simple = nan(Ncell, Ndisp, Nstep, Nframe, Nphase);

% Loop convolutions
for i = 1:Nconv
    
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
    
    % Sum left and right scalars at each disparity & frame
    vLR = vL + vR;

    % Store
    Simple(c, :, :, :, p) = vLR;
    
    % Update UI
    if Parameters.Waitbar
        waitbar(i / Nconv);
    end
end

% Half-wave rectify and square
Simple = BEM_rectify(Simple, 'half-square');

% Sum simple cell responses
Complex = sum(Simple, ndims(Simple));

% Apply activation function
Complex = CxActivationF(Complex);

%% Close UI

% Close
if Parameters.Waitbar
    close(wb);
end

% Done
%