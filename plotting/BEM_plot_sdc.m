function BEM_plot_sdc(Parameters, CellPop)
% BEM_plot_sdc(Parameters, CellPop)
%
% Input
%   Parameters     [struct] in degVA
%   CellPop        [struct] in degVA
%
% Plot size-disparity correlation, in the same format as Prince 2002b.

% Changelog
% 01/03/2018    Written
% 26/07/2018    Removed dependencies
%

%% Input

if nargin == 0
    help BEM_plot_sdc
    return
end

%% Main

% Figure
f = gcf;
f.Color = [1 1 1];

% Prince's 'Disparity frequency'
% The spatial frequency of the Gabor, in cycles per degree
SF = CellPop.SF;

% Prince's 'Maximum Interaction Position'
% The peak disparity tuning for a given cell, in degrees
TuningPos = abs(CellPop.TuningPos);
TuningPha = abs(CellPop.TuningPha);

% The size-disparity correlation limit, as defined in Prince 2002b
LineX = 0.1 : 0.01 : 11;
LineY = (1 ./ LineX) ./ 2;

% Plot 1: position-shift disparity tuning
subplot(1,2,1)
hold on;
h1 = plot(LineX, LineY);
h2 = scatter(SF, TuningPos);
hold off;

% Tidy
h1.Color = [0 0 0];
h1.LineWidth = 2;
h2.Marker = 'square';
ax = gca;
ax.FontSize = 14;
ax.XScale = 'log';
ax.XLim = [0.1 11];
ax.YLim = [0 1];
axis square;
xlabel('Spatial frequency (cpd)')
ylabel('Position disparity tuning (°)')
title('Position-shift disparity')

% Plot 2: phase-shift disparity tuning
subplot(1,2,2)
hold on;
h1 = plot(LineX, LineY);
h2 = scatter(SF, TuningPha);
hold off;

% Tidy
h1.Color = [0 0 0];
h1.LineWidth = 2;
h2.Marker = 'square';
ax = gca;
ax.FontSize = 14;
ax.XScale = 'log';
ax.XLim = [0.1 11];
ax.YLim = [0 1];
axis square;
xlabel('Spatial frequency (cpd)')
ylabel('Phase disparity tuning (°)')
title('Phase-shift disparity')

% Done
%