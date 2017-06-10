# True Random Number Generator by Wold and Tang
True Random Number Generator for FPGA. Based on article by Wold and Tan [1].

## Navigating the repository
* `/`  
  contains the TRNG entity.
* `/simulation/`  
  contains a test bench for "stimulating" the TRNG and some .do-files for compiling the simulation files and displaying the waveforms nicely. The .do-macros are run in Modelsim by typing `do <filename.do>`.
* `/synthesis/`  
  contains a top for synthesizing the entity in an FPGA.

## Customizing
The degree of randomness is mainly controlled by the number of oscillator rings that are in parallel. There are other factors as well, which [1] explains very nicely.

[1] [Wold and Tan, "Analysis and Enhancement of Random Number Generator in FPGA Based on Oscillator Rings," International Journal of Reconfigurable Computing, Volume 2009](http://dx.doi.org/10.1155/2009/501672 "DOI link")
