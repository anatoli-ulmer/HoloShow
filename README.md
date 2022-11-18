# HoloShow

Data analysis toolbox for in-flight holography experiments, performed at the Free-Electron Laser facilities:
  + LCLS (Linac Coherent Light Source) @ SLAC (Stanford Linear Accelerator Center)
  + FLASH (Free-Electron Laser Hamburg)


## Table of contents
* [General info](#general-info)
* [Features](#features)
* [Technologies](#technologies)
* [Setup](#setup)
* [Usage](#usage)
* [License](#license)


## General info

Analysis of scattering patterns of samples and holographic references, illuminated by a single FEL (Free-Electron Laser) pulse [[Gorkhover et al., 2018](https://doi.org/10.1038/s41566-018-0110-y)]. Data recorded on pnCCD scattering detectors with clusters as holographic references.

version: 4.0  
year: 2021  
author: Anatoli Ulmer  
email: anatoli.ulmer@gmail.com  


## Features
  + pnCCD detector corrections
  + holographic reconstruction
  + refocusing (manual and automated)
  + signal-to-noise estimation
  + Wiener devonvolution filter
  + graphical interface


## Technologies
Project is created with:
* MATLAB 2020a or later
* Image Processing Toolbox
* Parallel Computing Toolbox


## Setup
Optionally can be used on Maxwell (Desy) or psana (SLAC) remotely:

To use MATLAB on **Maxwell** please use FastX2:
  1. Get [FastX2](https://confluence.desy.de/display/IS/FastX2) from within the Desy network.
  2. Connect to `max-display.desy.de` with your desy credentials using FastX.
  3. (a) Start a XFCE session and start the terminal. OR (b) Start a xterm session.
  4. Run the desired MATLAB version with `matlab20XXx` in the terminal (e.g. `matlab2021a`).

To use MATLAB on **psana** please use nomachine:
  1. Get [nomachine](https://www.nomachine.com/)
  2. Login into psnxana - [HOWTO](https://confluence.slac.stanford.edu/display/PCDS/Remote+Visualization)
  3. ssh to a psana machine with available MATLAB licence. 
  Get list of available licences using: `/reg/common/package/scripts/matlic`.
  Use available machine with: `ssh -Y machinename`.
  4. Start MATLAB using: `/reg/common/package/matlab/R2016a/bin/matlab`.

## Usage

Run `HoloShow.mlapp` in MATLAB. 

holoShow reads scattering image data files in ASCII format with ending `.dat`, MATLAB files with ending `.mat` or HDF5 files with Hummingbird standard structure with ending `.cxi` or `.h5`.


INSTRUCTIONS:

1.) Start with executing `HoloShow.mlapp` and the control window will open together with the hologram window and the reconstruction window.

2.) Pick a file in the pre-chosen file list on the left or load new files with the button above the list. The button below the list will execute first evaluation steps.

3.) In the reconstruction window you see the patterson map consisting of the autocorrelation in the center and cross correlation terms. You can zoom inside this window and with the button 'choose CC' the current view will be set as the new region of interest (ROI). Smaller ROIs will give better results.

4.) The reconstruction usually is defocused in the beginning, because the sample and the reference were not in the same plane. Refocussing can be done manually with the phase slider or automatically with the 'find phase' button. To change the range of the slider you can use the edit field on the right side. With phase here the distance between the particles and the belonging propagation operator is meant.

5.) The focused reconstruction will still have artifacts due to unprecise centering of the hologram and position estimation of the two detector halves. To correct for these artifacts you can use the 'find center' and 'find shifts' buttons.

Now you should have a low resolution reconstruction. Keep in mind that depending on the focal length, information can be shifted between real and imaginary space. After all, what we reconstruct is just the exit wave of the particle. To further refine the reconsruction it is possible to make a deconvolution.


## License

see LICENSE file
