function [X, Rf] = BEM_prfsearchgrid(Parameters)
% [X, Rf] = BEM_prfsearchgrid(Parameters)
%
% Inputs
%   Parameters   [struct] See BEM_parameters
% 
% Output
%   Grid         [pred x param] fully sampled search grid parameters
%   Rf           [m x n x pred] 2D Gaussian receptive field for each 
%                               combination of parameters in grid

% Changelog
% 26/05/2019    Written

%% Input

% Help
if nargin == 0
    help BEM_prfsearchgrid
    return
end

% Check parameters are expressed in pixels
if ~strcmpi(Parameters.Units, 'pix')
    error('Parameters defined in Deg. Please input parameters in Pix.');
end

%% Open UI

% Open
if Parameters.Waitbar
    wb = waitbar(0, 'Generating search grid...');
end

%% Main

% Generate searchgrid
[Xpos, Ypos, Sigma] = ndgrid(Parameters.Prf.SearchGridX, ...
    Parameters.Prf.SearchGridY, ...
    Parameters.Prf.SearchGridSigma);

% Put together
X = [Xpos(:), Ypos(:), Sigma(:)];

% How many predictions
Npred = size(X, 1);

% Empty matrix
Rf = zeros(Parameters.ImSize, Parameters.ImSize, Npred);

% Loop
for i = 1 : Npred
   
    % Create receptive field image
    Rf(:,:,i) = BEM_gaussian(Parameters.ImSize, [Xpos(i), Ypos(i)], [Sigma(i), Sigma(i)], 0);
    
    % Update UI
    if Parameters.Waitbar
        waitbar(i / Npred, wb);
    end
end

%% Close UI

% Close
if Parameters.Waitbar
    close(wb);
end

% Done
%