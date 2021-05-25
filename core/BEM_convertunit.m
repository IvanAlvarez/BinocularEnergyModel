function [Parameters, CellPop] = BEM_convertunit(Direction, Parameters, CellPop)
% [Parameters, CellPop] = BEM_convertunit(Direction, Parameters, CellPop)
%
% Input
%   Direction    [string] 'deg2pix' from degrees VA to pixels
%                         'pix2deg' from pixels to degrees VA
%   Parameters   [struct] see BEM_parameters
%   CellPop      [struct] see BEM_make_cellpop
%
% Output
%   Parameters   [struct] as before, with units swapped
%   CellPop      [struct] as before, with units swapped

% Changelog
% 28/06/2018    Written
% 05/06/2019    Dropped checkerboard stimulus type
% 10/06/2019    Changed stimulus GratingPeriod to GratingSF
%               Fixed SF unit conversion bug
% 26/06/2019    Added pRF fit parameters
%

%% Input

if nargin < 2
    help BEM_convertunit
    return
end
if nargin < 3
    CellPop = [];
end

%% Safety check

% Trying to convert degrees to degrees
if strcmpi(Parameters.Units, 'deg') && strcmpi(Direction, 'pix2deg')
    error('Requested pix2deg, but Parameters are already in deg');
end

% Trying to convert pixels to pixels
if strcmpi(Parameters.Units, 'pix') && strcmpi(Direction, 'deg2pix')
    error('Requested deg2pix, but Parameters are already in pix')
end

%% Main

% Find conversion factor
switch Direction
    case 'deg2pix'
        CF = Parameters.PixPerDeg;
        OutputUnit = 'pix';
    case 'pix2deg'
        CF = 1 / Parameters.PixPerDeg;
        OutputUnit = 'deg';
end

% Parse Parameters
if ~isempty(Parameters)

    % General parameters
    Parameters.ImSize = Parameters.ImSize * CF;
    
    % Stimulus parameters
    Parameters.Stim.Disparity =        Parameters.Stim.Disparity * CF;
    Parameters.Stim.GratingSF =        Parameters.Stim.GratingSF * (1 / CF); % cycles per degree / cycles per pixel
    Parameters.Stim.Randot.DotRadius = Parameters.Stim.Randot.DotRadius * CF;
    Parameters.Stim.ApertureBarWidth = Parameters.Stim.ApertureBarWidth * CF;
    
    % Receptive field parameters    
    Parameters.RF.PositionStd =        Parameters.RF.PositionStd * CF;
    Parameters.RF.SizeMean =           Parameters.RF.SizeMean * CF;
    Parameters.RF.SizeStd =            Parameters.RF.SizeStd * CF;
    Parameters.RF.SizeEccBiasRange =   Parameters.RF.SizeEccBiasRange * CF;
    Parameters.RF.SizeEccBiasNoise =   Parameters.RF.SizeEccBiasNoise * CF;
    Parameters.RF.SFMean =             Parameters.RF.SFMean * (1 / CF); % cycles per degree / cycles per pixel
    Parameters.RF.SFStd =              Parameters.RF.SFStd * (1 / CF); % cycles per degree / cycles per pixel
    Parameters.RF.PosEncodingMean =    Parameters.RF.PosEncodingMean * CF;
    Parameters.RF.PosEncodingStd =     Parameters.RF.PosEncodingStd * CF;
    Parameters.RF.PhaseEncodingMean =  Parameters.RF.PhaseEncodingMean * CF;
    Parameters.RF.PhaseEncodingStd =   Parameters.RF.PhaseEncodingStd * CF;
    
    % pRF fit parameters
    Parameters.Prf.SearchGridX =       Parameters.Prf.SearchGridX * CF;
    Parameters.Prf.SearchGridY =       Parameters.Prf.SearchGridY * CF;
    Parameters.Prf.SearchGridSigma =   Parameters.Prf.SearchGridSigma * CF;
end

% Parse CellPop
if ~isempty(CellPop)
    
    % All cell parameters
    CellPop.X = CellPop.X * CF;
    CellPop.Y = CellPop.Y * CF;
    CellPop.SF = CellPop.SF * (1 / CF); % cycles per degree / cycles per pixel
    CellPop.Sigma1 = CellPop.Sigma1 * CF;
    CellPop.Sigma2 = CellPop.Sigma2 * CF;
    CellPop.TuningPos = CellPop.TuningPos * CF;
    CellPop.TuningPha = CellPop.TuningPha * CF;
end

% Change units string
if ~isempty(Parameters)
    Parameters.Units = OutputUnit;
end
if ~isempty(CellPop)
    CellPop.Units = OutputUnit;
end
   
% Done
%