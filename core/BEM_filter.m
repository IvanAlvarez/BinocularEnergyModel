function [rfL, rfR] = BEM_filter(Parameters, CellPop, Idx, Phase)
% [rfL, rfR] = BEM_filter(Parameters, CellPop, Idx, Phase)
% 
% Input
%   Parameters   [struct] See BEM_parameters
%   CellPop      [struct] See BEM_make_cellpop
%   Idx          [scalar] Cell index
%   Phase        [scalar] Gabor grating phase, in radians
%
% Output
%   rfL          [matrix] Receptive field image, grayscale
%   rfR          [matrix] Idem
%
% Generate receptive field filters for cell Idx specified in CellPop.
% Outputs one receptive fields per eye

% Changelog
% 28/06/2018    Written
% 02/07/2018    Simplified, now only outputs one phase
% 31/07/2018    Harmonised input order
% 17/08/2018    Made position tuning shift consistent with stimulus
%               generation, i.e. LE shift = left, RE shift = right
% 28/05/2019    Fixed phase-encoding bug, pixels values now correctly 
%               converted to radians
% 10/06/2019    CellPop now contains Gabor spatial frequency in cpd
%

%% Parameters

% Convert from degVA to pixels
[Parameters, CellPop] = BEM_convertunit('deg2pix', Parameters, CellPop);

% Pull values for easier calling
ImSize = round(Parameters.ImSize);

%% Main

% Pull parameters defining this receptive field
X = CellPop.X(Idx);
Y = CellPop.Y(Idx);
SF = CellPop.SF(Idx);
Sigma1 = CellPop.Sigma1(Idx);
Sigma2 = CellPop.Sigma2(Idx);
Ori = CellPop.Ori(Idx);
TuningPos = CellPop.TuningPos(Idx);
TuningPha = CellPop.TuningPha(Idx);

% Convert spatial frequency (cpp) to period (pixels)
Period = 1 ./ SF;

% Convert position encoding as 1/2 step for LE and RE, rounded to the 
% nearest pixel
TuningPos = round(TuningPos / 2);

% Convert phase encoding from pixels to radians by multiplying the desired
% shift by 2 pi and dividing by the period of the Gabor grating. Then take
% a 1/2 step for LE and RE
TuningPha = (TuningPha * 2 * pi) / Period;
TuningPha = TuningPha / 2;

% LE filter
rfL = BEM_gabor(ImSize, X - TuningPos, Y, Sigma1, Sigma2, Period, Ori, Phase - TuningPha);

% RE filter
rfR = BEM_gabor(ImSize, X + TuningPos, Y, Sigma1, Sigma2, Period, Ori, Phase + TuningPha);

% Done
%