# holoShow
Your favourite tool for analysing in-flight holography data manually is now available on GitHub! :D

author: Anatoli Ulmer
email: anatoli.ulmer@gmail.com

Tested for Matlab R2015a with following toolboxes:
  communication_toolbox
  image_toolbox
  matlab
  signal_toolbox

Decreasing needed toolboxes is in progress.

To start run 'holoShowV3.m' in Matlab. 

To use a psana machine to analyze data please use nomachine:
  1. Get nomachine - https://www.nomachine.com/
  2. Login into psnxana - howto: https://confluence.slac.stanford.edu/display/PCDS/Remote+Visualization
  3. ssh to a psana machine with available Matlab licence. 
  Get list of available licences using: '/reg/common/package/scripts/matlic'.
  Use available machine with: 'ssh -Y machinename'.
  4. Start Matlab using: '/reg/common/package/matlab/R2016a/bin/matlab'.
