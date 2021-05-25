function Timeseries = BEM_complex2ts(Parameters, Complex)
% Timeseries = BEM_complex2ts(Parameters, Complex)
%
% Inputs
%   Parameters   [struct] See BEM_parameters
%   Complex      [cell x disp x aperture x frame] Complex binocular cell response
%
% Outputs
%   Timeseries   [cellar] BEM response timeseries, one entry per binocular cell
%                   
% Take the BEM complex cell output and summarise it into a response of one
% (or more) cells across time. Various summary options are detailed in 
% Parameters.
%
% Changelog
% 26/06/2019    Written
% 03/07/2019    Added normalisation of timeseries signal
% 05/07/2019    Normalisation how handled through Parameters flag
% 08/07/2019    Added explicit baseline specification through Parameters
% 29/08/2019    Removed cell use in ndgrid to allow compatibility with
%               R2016 used in cluster
%

%% Input

% Help
if nargin == 0
    help BEM_complex2ts
    return
end

%% Main

% Pull parameters
Cells = 1 : size(Complex, 1);
Disparity = Parameters.Stim.Disparity;
Frames = 1 : size(Complex, 4);

% Pull response
C = Complex;

% Summary options
if Parameters.Prf.AvgCells
    C = nanmean(C, 1);
    Cells = {'average'};
end
if Parameters.Prf.AvgDisparities
    C = nanmean(C, 2);
    Disparity = {'average'};
end
if Parameters.Prf.AvgFrames
    C = nanmean(C, 4);
    Frames = {'average'};
end

% Reshape into [aperture steps x observations]
C = permute(C, [3, 1, 2, 4]);
C = reshape(C, size(C, 1), []);

% Optional normalisation
if Parameters.Prf.SignalNormalization
    if ~isempty(Parameters.Prf.SignalBaseline)

        % User-specified baseline 
        C = C - Parameters.Prf.SignalBaseline;
        C = C ./ max(C(:));
    else
        % Infer baseline from data    
        C = C - median(C, 1);
        C = C ./ max(C(:));
    end
end

% Labels
[Cidx, Didx, Fidx] = ndgrid(1 : length(Cells), ...
    1 : length(Disparity), ...
    1 : length(Frames));
Cells = Cells(Cidx);
Disparity = Disparity(Didx);
Frames = Frames(Fidx);

% Handle all as cells
if ~iscell(Cells)
    Cells = num2cell(Cells(:));
end
if ~iscell(Disparity)
    Disparity = num2cell(Disparity(:));
end
if ~iscell(Frames)
    Frames = num2cell(Frames(:));
end

% Create timeseries structure
Timeseries = struct;
for i = 1 : size(C, 2)
    
    % Insert timeseries
    Timeseries(i).Response = C(:, i);
    
    % Insert labels
    Timeseries(i).Cell = Cells{i};
    Timeseries(i).Disparity = Disparity{i};
    Timeseries(i).Frame = Frames{i};
end

% Done
%