# holoShow
Your favourite tool for analysing in-flight holography data manually is now available on GitHub! :D

author: Anatoli Ulmer,
email: anatoli.ulmer@gmail.com

NOT READY TO USE. NOT ALL FUNCTIONS NEEDED INCLUDED YET.

Tested for Matlab R2015a with following toolboxes:

1. Image Processing Toolbox
2. Parallel Computing Toolbox

Decreasing amount of needed toolboxes is in progress.

To start run 'holoShowV3.m' in Matlab. 

To use a psana machine to analyze data please use nomachine:
  1. Get nomachine - https://www.nomachine.com/
  2. Login into psnxana - howto: https://confluence.slac.stanford.edu/display/PCDS/Remote+Visualization
  3. ssh to a psana machine with available Matlab licence. 
  Get list of available licences using: '/reg/common/package/scripts/matlic'.
  Use available machine with: 'ssh -Y machinename'.
  4. Start Matlab using: '/reg/common/package/matlab/R2016a/bin/matlab'.

holoShow reads scattering image data files in ASCII format with ending '.dat', Matlab files with ending '.mat' or HDF5 files with Hummingbird standart structure with ending '.cxi' or '.h5'.


INSTRUCTIONS:

1.) Start with executing holoShowV3.m and the control GUI will open together with the hologram window and the reconstruction window.
2.) Pick a file in the prechosen filelist on the left or load new files with the button above the list. The button below the list will execute first eveluation steps.
3.) In the reconstruction window you see the patterson map consisting of the autocorrelation in the center and cross correlation terms. With the button 'choose CC' you can pick a cross correlation term for further analysis by choosing an area with your mouse. Smaller ROIs will give better results.
4.) The reconstruction is in the beginning defocused because the sample and the reference were not in the same plane. Refocussing can be done manually with the focus slider or automatically with the 'find focus' button. To change the range of the slider you can use the edit field on the right side.
5.) The focused reconstruction will still have artifacts due to unprecise centering of the hologram and position estimateion of the two detector halves. To correct for these artifacts you can use the 'find center' and 'find shifts' buttons.

Now you should have a low resolution reconstruction. Keep in mind that depending on the focal length, information can be shiften between real and imaginary space. After all, what we reconstruct is just the exit wave of the particle. To further refine the reconsruction it is possible to make a deconvolution.
