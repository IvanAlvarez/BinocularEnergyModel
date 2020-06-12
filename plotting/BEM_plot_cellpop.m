function BEM_plot_cellpop(Parameters, CellPop)
% BEM_plot_cellpop(Parameters, CellPop)
%
% Input
%   Parameters     [struct] in degVA
%   CellPop        [struct] in degVA

% Changelog
% 18/01/2018    Written
% 11/06/2019    Fixed spatial frequency call
%

%% Input

if nargin < 2
    help BEM_plot_cellpop
    return
end

%% Pull data

% Data
N = Parameters.NumCells;
X = CellPop.X;
Y = CellPop.Y;
SF = CellPop.SF;
Sigma1 = CellPop.Sigma1;
Sigma2 = CellPop.Sigma2;
TuningPos = CellPop.TuningPos;
TuningPha = CellPop.TuningPha;
Ori = CellPop.Ori;

% Image size relative to center
MaxEcc = Parameters.ImSize / 2;

% Spatial period of grating
Period = 1 ./ SF;

% RF position relative to image center
X = X - MaxEcc;
Y = Y - MaxEcc;

%% Create figure

% Figure
f = figure;
f.Position = [200 200 1200 800];
f.Color = [1 1 1];

% Subplot rows and columns
Rows = 3;
Columns = 4;

% Plot counter
Pc = 0;

%% Plot: XY location

% Update counter & select subplot
Pc = Pc + 1;
subplot(Rows, Columns, Pc);

% Plot
h = scatter(X, Y);

% Tidy
h.Marker = '.';
h.SizeData = 100;
xlim([-MaxEcc +MaxEcc]);
ylim([-MaxEcc +MaxEcc]);
title('RF location')
xlabel('Horizontal position (°)')
ylabel('Vertical position (°)');

%% Plot: XY location 2D histogram

% Update counter & select subplot
Pc = Pc + 1;
subplot(Rows, Columns, Pc);

% Plot
h = histogram2(X, Y, 20, 'DisplayStyle', 'tile');

% Tidy
colormap(winter)
xlim([-MaxEcc +MaxEcc]);
ylim([-MaxEcc +MaxEcc]);
title('RF location histogram')
xlabel('Horizontal position (°)')
ylabel('Vertical position (°)');

%% Plot: Eccentricity histogram
% Squared because regular eccentricity is log-normal distributed

% Update counter & select subplot
Pc = Pc + 1;
subplot(Rows, Columns, Pc);

% Plot
E = sqrt(X.^2 + Y.^2);
h = histogram(E, 100);

% Tidy
h.EdgeColor = 'none';
title('Eccentricity (log-normal)')
xlabel('Eccentricity (°)');
ylabel('Count');

%% Plot: Sigma ratio

% Update counter & select subplot
Pc = Pc + 1;
subplot(Rows, Columns, Pc);

% Plot
Ratio = Sigma1 ./ Sigma2;
h = histogram(Ratio, 100);

% Tidy
h.EdgeColor = 'none';
title('RF size ratio')
xlabel('Sigma1 / Sigma2')
ylabel('Count')

%% Plot: Sigma distribution (principal direction)

% Update counter & select subplot
Pc = Pc + 1;
subplot(Rows, Columns, Pc);

% Plot
h = histogram(Sigma1, 100);

% Tidy
h.EdgeColor = 'none';
xlim([0 max([Sigma1; Sigma2])])
title('RF size (principal)')
xlabel('Sigma1 (°)')
ylabel('Count')

%% Plot: Sigma distribution (orthogonal direction)

% Update counter & select subplot
Pc = Pc + 1;
subplot(Rows, Columns, Pc);

% Plot
h = histogram(Sigma2, 100);

% Tidy
h.EdgeColor = 'none';
xlim([0 max([Sigma1; Sigma2])])
title('RF size (orthogonal)')
xlabel('Sigma2 (°)')
ylabel('Count')

%% Plot: SF distribution

% Update counter & select subplot
Pc = Pc + 1;
subplot(Rows, Columns, Pc);

% Plot
h = histogram(SF, 100);

% Tidy
h.EdgeColor = 'none';
xlim([0 mean(SF) + std(SF) * 2])
title('Spatial frequency')
xlabel('Spatial frequency (cpd)')
ylabel('Count')

%% Plot: Grating period 

% Update counter & select subplot
Pc = Pc + 1;
subplot(Rows, Columns, Pc);

% Plot
h = histogram(Period, 100);

% Tidy
h.EdgeColor = 'none';
title('Grating period')
xlabel('Grating period (°)')
ylabel('Count')

%% Plot: RF orientation

% Update counter & select subplot
Pc = Pc + 1;
subplot(Rows, Columns, Pc);

% Plot
h = histogram(Ori, 100);

% Tidy
h.EdgeColor = 'none';
ax = gca;
ax.XLim = [-pi * 2, +pi * 2];
ax.XTick = [-pi * 2, 0, +pi * 2];
ax.XTickLabel = {'-2{\pi}', 0, '+2{\pi}'};
title('RF orientation')
xlabel('Orientation (rad)')
ylabel('Count')

%% Plot: Tuning through position encoding
 
% Update counter & select subplot
Pc = Pc + 1;
subplot(Rows, Columns, Pc);

% Plot
h = histogram(TuningPos, 100);

% Tidy
h.EdgeColor = 'none';
title('Tuning by position encoding')
xlabel('Position disparity (°)')
ylabel('Count')

%% Plot: Tuning through phase encoding (degVA)

% Update counter & select subplot
Pc = Pc + 1;
subplot(Rows, Columns, Pc);

% Plot
h = histogram(TuningPha, 100);

% Tidy
h.EdgeColor = 'none';
title('Tuning by phase encoding')
xlabel('Phase shift in equivalent position displacement (°)')
ylabel('Count')

%% Plot Tuning through phase encoding (rad)

% Update counter & select subplot
Pc = Pc + 1;
subplot(Rows, Columns, Pc);

% Plot
TuningPhaRad = (TuningPha ./ Period) * 2 * pi;
h = histogram(TuningPhaRad, 100);

% Tidy
h.EdgeColor = 'none';
ax = gca;
ax.XLim = [-pi * 2, +pi * 2];
ax.XTick = [-pi * 2, 0, +pi * 2];
ax.XTickLabel = {'-2{\pi}', 0, '+2{\pi}'};
title('Tuning by phase encoding')
xlabel('Phase shift (rad)');
ylabel('Count');

%% Finish plot

% General tidy
for i = 1:Pc
    subplot(Rows, Columns, i);
    ax = gca;
    ax.FontSize = 12;
    axis square;
    box on;
end

% Done
%