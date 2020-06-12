function M = BEM_maxresponse(Parameters, CellPop, Idx)
% M = BEM_maxresponse(Parameters, CellPop, Idx)
%
% Input
%   Parameters   [struct] See BEM_parameters
%   CellPop      [struct] See BEM_make_cellpop
%   Idx          [vector] Cell index
%
% Output
%   M            [matrix] Maximum simple response possible for a given cell
%                         Output has format [cell x phase]
%
% Return the maximum possible response of simple cells in model.

% Changelog
% 11/06/2019    Written
%

%% Input

% Help
if nargin == 0
    help BEM_maxresponse
    return
end

%% Settings

% Call variables for easier indexing
Phase = Parameters.RF.Phase;

%% Main

% Pre-allocate
M = zeros(length(Idx), length(Phase));

% Search space
[Gc, Gp] = ndgrid(Idx, Phase);

% Loop
for i = 1 : numel(Gc)

    % Make receptive field filters
    [rfL, rfR] = BEM_filter(Parameters, CellPop, Gc(i), Gp(i));

    % Multiply by itself
    cL = rfL .* rfL;
    cR = rfR .* rfR;
    
    % Sum across image
    cL = sum(cL(:));
    cR = sum(cR(:));

    % Sum left and right scalars and store as simple cell max response
    M(i) = cL + cR;
end

% Half-wave rectify and square
M = BEM_rectify(M, 'half-square');

% Done
%