function ModelFit = BEM_prffit4(Parameters, Aperture, Timeseries)
% ModelFit = BEM_prffit4(Parameters, Aperture, Timeseries)
% 
% Inputs
%   Parameters   [struct] See BEM_parameters
%   Aperture     [struct] See BEM_make_stimulus
%   Timeseries   [struct] see BEM_complex2ts
%
% Output
%   ModelFit     [struct] pRF model fit parameters
%
% For a BEM model output summarising the response of a population of cells
% over time, fit a 4-parameter population receptive field (pRF) model and 
% return the model parameters. The four parameters are pRF location (X,Y),
% pRF size (Sigma) and response amplitude (Beta). 
%
% Exploit parallel threading in Matlab, when requested & available.
%
% Changelog
% 26/06/2019    Written
% 08/07/2019    Split into 2- and 4-parameter versions
% 17/11/2020    Added parallel support

%% Input

if nargin == 0
    help BEM_prffit4
    return
end

%% Parameters

% Convert from degVA to pixels
Parameters = BEM_convertunit('deg2pix', Parameters);

% fminsearch options
SearchOpts = optimset('TolX', 1e-2, 'TolFun', 1e-2, 'Display', 'off');

% Pull single parameter out
PixPerDeg = Parameters.PixPerDeg;

% Number of timeseries to fit
Nfits = length(Timeseries);

%% Open UI

% Open
if Parameters.Waitbar && ~Parameters.ParallelPool
    wb = waitbar(0, 'prf fit...');
else
    wb = [];
end

%% Parallelisation

% Obtain parallel pool. The following options are available:
%  (1) If parallel pool present, use it
%  (2) If no parallel pool present, create one
%  (3) If not requested, disable parallel pooling
Poolobj = BEM_parpool(Parameters);

%% Search grid

% Generate search grid
[X, Rf] = BEM_prfsearchgrid(Parameters);

%% Main

% Empty structure
ModelFit = struct;

% Loop timeseries
parfor (i = 1 : Nfits, Poolobj.NumWorkers)

    % Pull signal
    Y = Timeseries(i).Response;
    
    % Approximate amplitude
    Beta = max(Y);
    
    % Perform coarse fit
    [Pred, ~] = BEM_prfcoarsefit(Aperture, Rf, X, Y);
    
    % Incorporate Beta parameter into prediction
    Pred = [Pred, Beta];
    
    % Define objective function
    ObjFun = @(P)BEM_prferrfun4(Aperture, Y, P);
    
    % Perform fine fit
    [Fit, SSE] = fminsearch(ObjFun, Pred, SearchOpts);
        
    % Get best-fit timeseries
    [~, Yp] = BEM_prferrfun4(Aperture, Y, Fit);
    
    % R^2
    SST = sum((Y - mean(Y)) .^ 2);
    R2 = 1 - (SSE ./ SST);
    
    % Convert fit parameters from pixels to degrees
    Fit(1:3) = Fit(1:3) / PixPerDeg;
    
    % Store
    ModelFit(i).Cell = Timeseries(i).Cell;
    ModelFit(i).Disparity = Timeseries(i).Disparity;
    ModelFit(i).Frame = Timeseries(i).Frame;
    ModelFit(i).TsObserved = Timeseries(i).Response;
    ModelFit(i).TsFit = Yp;
    ModelFit(i).Param = Fit; % X, Y, Sigma, Amplitude
    ModelFit(i).SSE = SSE;
    ModelFit(i).R2 = R2;
    
    % Update UI
    if ~isempty(wb)
        waitbar(i / Nfits, wb);
    end

end

%% Close UI

% Close
if ~isempty(wb)
    close(wb);
end

% Done
%