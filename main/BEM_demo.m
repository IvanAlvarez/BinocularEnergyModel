%% BEM_demo.m
%
% Demonstration of the BEM toolbox.

% Changelog
% 29/06/2018    Written
% 05/06/2019    Explicit default parameters call
%

%% Main model example

% First, orientation. All the settings for running the BEM toolbox are
% stored in BEM_parameters.m. You can either load the default settings and
% modify them in a script, or change§ them directly in BEM_parameters.m
%
% For example, the default save directory is probably something you want to
% set to the same location on your computer. Go to BEM_parameters.m, and
% change line 23 to:
Parameters.SaveDir = '/path/to/my/save/directory';

% However, if we are running individual models, it is easier to modify the
% desired parameters on the fly. Let us start by loading the default
% parameters.
Parameters = BEM_parameters;

% Next, let's modify some settings. To see what each of these mean, look at
% BEM_parameters.m
Parameters.NumCells = 2;

% To create the stimulus with the settings stored in Parameters, run:
Stimulus = BEM_make_stimulus(Parameters);

% Let us visualise the stimulus
BEM_plot_stimulus(Parameters, Stimulus);

% Our model cells are defined by a set of parameters. Instead of creating
% the receptive field image for each cell, we store the parameters that
% define it, such as position, size, etc. As the process is deterministic, 
% we can always generate the receptive field image from scratch if we have 
% these values. The output variable CellPop contains one entry for each
% complex binocular cell.
CellPop = BEM_make_cellpop(Parameters);

% Visualise cell population
BEM_plot_cellpop(Parameters, CellPop);

% Visualise receptive fields
BEM_plot_receptivefield(Parameters, CellPop);

% Now we have both the stimulus and the cell definitions, it's time to run
% the model. The output of this step are the simple and complex binocular
% cell responses to the stimulus, at every aperture step, on every frame, 
% and at every stimulus disparity.
[Simple, Complex] = BEM_run(Parameters, Stimulus, CellPop);

% Visualise the disparity tuning cuves, and response across time
BEM_plot_tuningcurve(Parameters, CellPop, Simple, Complex);

%% pRF fitting example

% A secondary module of the BEM toolbox is the ability to fit population
% receptive fields (pRF) to the model predictions we just inspected. This
% is motivated by the need to generate computational model predictions for
% fMRI experiments.
% To do this, we must first create a stimulus that varies across space,
% which will give us a signature to be detected during pRF fitting. We do
% this by changing stimulus parameters
Parameters.Stim.Aperture = 'bar';
Parameters.Stim.ApSteps = 10;

% And generating a new stimulus. This time, we will also save the binary
% aperture of the stimulus
[Stimulus, Aperture] = BEM_make_stimulus(Parameters);

% Generate the cell population
CellPop = BEM_make_cellpop(Parameters);

% And run the model
[Simple, Complex] = BEM_run(Parameters, Stimulus, CellPop);

% Next, we need to summarise the BEM model outputs into a timeseries to be
% fitted with the pRF model. In this case, we want to average across all
% disparities tested.
Parameters.Prf.AvgDisparities = true;

% Summarise. Each entry contains a model response across aperture steps
Timeseries = BEM_complex2ts(Parameters, Complex);

% Fit the pRF model. This is the 4-parameter version of the model, which
% fits pRF location (X,Y), size (Sigma) and signal amplitude (Beta)
ModelFit = BEM_prffit4(Parameters, Aperture, Timeseries);

% Visualise the model fits
BEM_plot_prffit(Parameters, ModelFit);

% Done
%