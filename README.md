# Binocular Energy Model

### Version

Version 1.0.0  --  18 October 2019

### Authors

Ivan Alvarez (University of Oxford)  
Marcus Daghlian (University of Oxford)  

### About

Matlab implementation of the binocular energy model (BEM) for binocular disparity detection in V1 complex cells.  

The principal model is based on Ohzawa et al. (1990), with additional details drawn from Henriksen et al. (2016). Binocular disparity encoding by position shift and phase shift is based on Fleet et al. (1996). The default parameters used for receptive field definitions are based on data from Cumming & Parker (2000), Nienborg et al. (2004), Prince et al. (2002a, 2002b) and Ringach (2003).  Population receptive field (pRF) modelling of BEM outputs is inspired by the original model proposed for fMRI signals in Dumoulin & Wandell (2008), and closely matched to previous implementations detailed in Alvarez et al. (2015).  

## List of functions

#### Demos
BEM_demo ---- Simple demo walking user through a simulation experiment  

#### GUI
BEM_gui ---- Graphic interface for testing single cell models  

#### Main functions
BEM_parameters ---- Define the default model specification  
BEM_make_stimulus ---- Create or load stimulus images  
BEM_make_cellpop ---- Create a list of parameters defining each complex cell  
BEM_run ---- Run the model  
BEM_run_parallel ---- Parallel pool-enabled modelling, faster  

#### Plotting functions
BEM_plot_cellpop  ---- Display distributions of cell properties  
BEM_plot_prffit ---- Display pRF input signal and model fit  
BEM_plot_receptivefield ---- Display receptive field profiles  
BEM_plot_sdc ---- Plot size-disparity correlation  
BEM_plot_stimulus ---- Display stimulus images  
BEM_plot_tuningcurve ---- Display responses with varying stimulus disparity and across apertures  

#### Core functions
BEM_aperture  ---- Create binary aperture for stimulus  
BEM_convertunit ---- Conversion to/from degrees of visual angle and pixels  
BEM_convolve ---- Convolve stimulus matrix with receptive field (reference only)  
BEM_filter ---- Create binocular receptive field filters  
BEM_gabor ---- Make a 2D Gabor filter  
BEM_gaussian ---- Make a 2D multivariate Gaussian filter  
BEM_grating ---- Make a 2D sinusoidal grating  
BEM_howlong ---- Estimate how long a model will take to run  
BEM_maxresponse ---- Estimate maximum possible response for a given cell  
BEM_parpool ---- Create or query the Matlab parallel pool  
BEM_radialcheck ---- Make a radial checkerboard image  
BEM_rectify ---- Signal rectification functions

#### pRF fitting functions
BEM_complex2ts ---- Summarise complex cell response into a timeseries  
BEM_prfcoarsefit ---- Fit model outputs with gridsearch approach  
BEM_prferrfun2 ---- pRF model error function with 2 free parameters  
BEM_prferrfun4 ---- pRF model error function with 4 free parameters  
BEM_prffit2 ---- Fit 2-parameter pRF model (size & amplitude)  
BEM_prffit4 ---- Fit 4-parameter pRF model (X,Y,size,amplitude)  
BEM_prfgsearchgrid ---- Generate pRF search grid  

## References
* Alvarez I, de Haas B, Clark CA, Rees G, Schwarzkopf DS (2005) Comparing different stimulus configurations for population receptive field mapping in human fMRI. Front Hum Neurosci 9:96.
* Cumming BG, Parker AJ (2000) Local disparity not perceived depth is signaled by binocular neurons in cortical area V1 of the macaque. J Neurosci 20:4758–4767.
* Dumoulin SO, Wandell BA (2008) Population receptive field estimates in human visual cortex. NeuroImage 39:647–660.
* Fleet DJ, Wagner H, Heeger DJ (1996) Neural encoding of binocular disparity: Energy models, position shifts and phase shifts. Vis Res 36:1839–1857.
* Henriksen S, Tanabe S, Cumming B (2016) Disparity processing in primary visual cortex. Philos Trans R Soc Lond, B, Biol Sci 371:20150255–12.
* Nienborg H, Bridge H, Parker AJ, Cumming BG (2004) Receptive field size in V1 neurons limits acuity for perceiving disparity modulation. J Neurosci 24:2065–2076.
* Ohzawa I, DeAngelis GC, Freeman RD (1990) Stereoscopic depth discrimination in the visual cortex: Neurons ideally suited as disparity detectors. Science 249:1037–1041.
* Prince SJD, Cumming BG, Parker AJ (2002a) Range and mechanism of encoding of horizontal disparity in macaque V1. J Neurophysiol 87:209–221.
* Prince SJD, Pointon AD, Cumming BG, Parker AJ (2002b) Quantitative analysis of the responses of V1 neurons to horizontal disparity in dynamic random-dot stereograms. J Neurophysiol 87:191–208.
* Ringach DL, Hawken MJ, Shapley R (2003) Dynamics of orientation tuning in macaque V1: The role of global and tuned suppression. J Neurophysiol 90:342–352.