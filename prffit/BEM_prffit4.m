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

% Changelog
% 26/06/2019    Written
% 08/07/2019    Split into 2- and 4-parameter versions
%

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

%% Search grid

% Generate search grid
[X, Rf] = BEM_prfsearchgrid(Parameters);

%% Open UI

% Open
if Parameters.Waitbar   
    wb = waitbar(0, 'prf fit...');
end

%% Main

% Empty structure
ModelFit = struct;

% Loop timeseries
for i = 1 : length(Timeseries)

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
    Fit(1:3) = Fit(1:3) / Parameters.PixPerDeg;
    
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
    if Parameters.Waitbar
        waitbar(i / length(Timeseries), wb);
    end
end

%% Close UI

% Close
if Parameters.Waitbar
    close(wb);
end

% Done
%