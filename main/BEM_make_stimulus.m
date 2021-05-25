function [Stimulus, Aperture] = BEM_make_stimulus(Parameters)
% [Stimulus, Aperture] = BEM_make_stimulus(Parameters)
%
% Input
%   Parameters   [struct] See BEM_parameters
%
% Output
%   Stimulus.<>
%       ImL      [matrix] left eye stimulus image
%       ImR      [matrix] right eye stimulus image 
%   Aperture     [m x n x step] binary representation of stimulus aperture
% 
% Create (or load) stimulus images for left and right eye. The output
% format is  m x n x d x a x f, where <m x n> is a stimulus image,
% <d> are disparities, <a> are aperture steps and <f> are unique frames
% for each aperture step
%

% Changelog
% 28/06/2018    Written
% 05/06/2019    Multiple identical frames generated for grating stimulus
%               Dropped checkerboard stimulus type
%               Re-wrote to handle binary apertures
% 10/06/2019    Performing conversion from grating SF to period here
% 11/06/2019    Added more parameter options to noise and randot stimuli
%               Segregated stimulus frames and aperture positions
% 26/06/2019    Ouputs binary aperture
% 03/07/2019    Fixed waitbar bug
% 23/07/2019    Added radial checkerboard stimulus 
% 28/08/2019    Added linear checkerboard stimulus
% 29/08/2019    Enforce single-digit precision at pre-allocation point
% 18/10/2019    Added monochrome stimulus type
% 25/05/2021    Added wedge aperture type
%               Made randot dot color and correlation explicitly stated
%

%% Input

if nargin < 1
    help BEM_make_stimulus
    return
end

%% Parameters

% Convert degVA to pixels
Parameters = BEM_convertunit('deg2pix', Parameters);

% Round certain parameters to the nearest pixel
Parameters.ImSize = round(Parameters.ImSize);
Parameters.Stim.ApertureBarWidth = round(Parameters.Stim.ApertureBarWidth);
Parameters.Stim.Disparity = round(Parameters.Stim.Disparity);
Parameters.Stim.Randot.DotRadius = round(Parameters.Stim.Randot.DotRadius);

%% Make aperture

% Open UI
if Parameters.Waitbar
    wb = waitbar(0, 'Making aperture...');
end

% Define aperture options struct
Options.BarWidth = Parameters.Stim.ApertureBarWidth;
Options.BarOri = Parameters.Stim.ApertureBarOri;
Options.WedgeWidth = Parameters.Stim.ApertureWedgeWidth;
Options.WedgeDir = Parameters.Stim.ApertureWedgeDir;

% Make aperture
Aperture = BEM_aperture(Parameters.Stim.Aperture, ...
    Parameters.ImSize, ...
    Parameters.Stim.ApSteps, ...
    Options);

%% Make stimulus

% Update
if Parameters.Waitbar
    waitbar(0, wb, 'Making stimulus...');
end

% Pre-allocate with single precision zeros
Stimulus.ImL = zeros(Parameters.ImSize, Parameters.ImSize, ...
    length(Parameters.Stim.Disparity), Parameters.Stim.ApSteps, ...
    Parameters.Stim.Nframes, 'single');
Stimulus.ImR = Stimulus.ImL;

% Aperture & frames search space
[ga, gf] = ndgrid(1 : Parameters.Stim.ApSteps, 1 : Parameters.Stim.Nframes);

% Various options
switch lower(Parameters.Stim.Type)
    
    case 'grating'
       
        %% Sinusoidal grating
        
        % Convert grating spatial frequency (cycles per pixel) to grating 
        % period (pixels)
        GratingPeriod = 1 / Parameters.Stim.GratingSF;
        
        % Loop aperture steps & frames
        for i = 1 : numel(ga)
                
            % Indices
            a = ga(i);
            f = gf(i);
            
            % Make stimulus
            [Stimulus.ImL(:,:,:,a,f), Stimulus.ImR(:,:,:,a,f)] = BEM_stim_grating(...
                Aperture(:,:,a), ...
                Parameters.Stim.Disparity, ...
                GratingPeriod, ...
                Parameters.Stim.GratingOri, ...
                Parameters.Stim.GratingPhase);
            
            % Update waitbar
            waitbar(i / numel(ga), wb);
        end
        
    case 'noise'
        
        %% White noise
         
        % Loop aperture steps & frames
        for i = 1 : numel(ga)
                
            % Indices
            a = ga(i);
            f = gf(i);
            
            % Make stimulus
            [Stimulus.ImL(:,:,:,a,f), Stimulus.ImR(:,:,:,a,f)] = BEM_stim_noise(...
                Aperture(:,:,a), ...
                Parameters.Stim.Disparity, ...
                Parameters.Stim.NoiseBlockSize, ...
                Parameters.Stim.NoiseBackground);
            
            % Update waitbar
            waitbar(i / numel(ga), wb);
        end
        
    case 'monochrome'
        
        %% Monochrome
         
        % Loop aperture steps & frames
        for i = 1 : numel(ga)
                
            % Indices
            a = ga(i);
            f = gf(i);
            
            % Make stimulus
            [Stimulus.ImL(:,:,:,a,f), Stimulus.ImR(:,:,:,a,f)] = BEM_stim_monochrome(...
                Aperture(:,:,a), ...
                Parameters.Stim.Disparity, ...
                Parameters.Stim.MonochromeCol);
            
            % Update waitbar
            waitbar(i / numel(ga), wb);
        end
        
    case 'randot'
        
        %% Random dot stereogram

        % Loop aperture steps & frames
        for i = 1 : numel(ga)
                
            % Indices
            a = ga(i);
            f = gf(i);
                        
            % Make stimulus
            [Stimulus.ImL(:,:,:,a,f), Stimulus.ImR(:,:,:,a,f)] = BEM_stim_randot(...
                Aperture(:,:,a), ...
                Parameters.Stim.Disparity, ...
                Parameters.Stim.Randot.DotRadius, ...
                Parameters.Stim.Randot.DotNum, ...
                Parameters.Stim.Randot.ForegroundDotColor, ...
                Parameters.Stim.Randot.BackgroundDotColor, ...
                Parameters.Stim.Randot.ForegroundDotCorrelation, ...
                Parameters.Stim.Randot.BackgroundDotCorrelation);
            
            % Update UI
            if Parameters.Waitbar
                waitbar(i / numel(ga), wb);
            end
        end
        
    case 'lincheck'
        
        %% Linear checkerboard
        
        % Loop aperture steps & frames
        for i = 1 : numel(ga)
            
            % Indices
            a = ga(i);
            f = gf(i);
            
            % Make stimulus
            [Stimulus.ImL(:,:,:,a,f), Stimulus.ImR(:,:,:,a,f)] = BEM_stim_lincheck(...
                Aperture(:,:,a), ...
                 Parameters.Stim.Disparity, ...
                 Parameters.Stim.LinCheckNum);
            
            % Update UI
            if Parameters.Waitbar
                waitbar(i / numel(ga), wb);
            end
        end
                
    case 'radcheck'
 
        %% Radial checkerboard
        
        % Loop aperture steps & frames
        for i = 1 : numel(ga)
            
            % Indices
            a = ga(i);
            f = gf(i);
            
            % Make stimulus
            [Stimulus.ImL(:,:,:,a,f), Stimulus.ImR(:,:,:,a,f)] = BEM_stim_radcheck(...
                Aperture(:,:,a), ...
                Parameters.Stim.Disparity, ...
                Parameters.Stim.RadCheckWedges, ...
                Parameters.Stim.RadCheckRings);
            
            % Update UI
            if Parameters.Waitbar
                waitbar(i / numel(ga), wb);
            end
        end
        
    case 'load'
        
        %% Load file
        
        % Load
        load(Parameters.Stim.LoadFile, 'Stimulus');
        
    otherwise 
        
        % Error message
        warning('Not a valid stimulus type');
end

% Monocular option
if Parameters.Stim.Monocular
    Stimulus.ImR = zeros(size(Stimulus.ImL));
end

%% Close UI

% Close
if Parameters.Waitbar
    close(wb);
end

% Done
%