function Time = BEM_howlong(Parameters, Stimulus, CellPop)
% Time = BEM_howlong(Parameters, Stimulus, CellPop)
%
% Input
%   Parameters   [struct] See BEM_parameters
%   Stimulus     [struct] See BEM_make_stimulus
%   CellPop      [struct] See BEM_make_cellpop
%
% Output
%   Time         [scalar] How long the model will take to run, in seconds
%
% For planning a modelling session, calculate the approximate amount of 
% time it will take to run all convolutions.

% Changelog
% 05/07/2018    Written
%

%% Input

if nargin == 0
    help BEM_howlong
    return
end

%% Settings

% Call variables for easier indexing
ImSize = size(Stimulus.ImL, 1);

% How many complex cells, phases, stimulus frames, stimulus disparities
Ncell = Parameters.NumCells;
Nphase = length(Parameters.RF.Phase);
Nframe = size(Stimulus.ImL, 3);
Ndisp = size(Stimulus.ImL, 4);

% How many individual convolutions to run, in total
Nconv = Ncell * Nphase;

%% Main

% Vectorise stimulus (this is only done once)
ImL = reshape(Stimulus.ImL, [ImSize .^ 2, Nframe, Ndisp]);
ImR = reshape(Stimulus.ImR, [ImSize .^ 2, Nframe, Ndisp]);

% Start clock
tic;

% Make a single filter pair & convolve with stimulus image
[rfL, rfR] = BEM_filter(Parameters, CellPop, 1, 0);
ImL .* rfL(:);
ImR .* rfR(:);

% End clock
T1 = toc;

% Multiply by the desired number of convolutions
Time = T1 * Nconv;

% Done
%