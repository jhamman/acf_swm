ACF SWM
=====

This source code repository includes the tools, scripts, source code, and input datasets required to run the 1/16 SWM over the Apalachicola-Chattahoochee-Flint (ACF) River Basin. This work was conducted on behalf of the State of Florida, Department of Environmental Protection (“FDEP”), in connection with State of Florida v. State of Georgia, in the Supreme Court of the United States, Original Action No. 142. This repository and the 1/16th-deg SWM was developed by Joseph Hamman, PE conjunction with the Dennis Lettenmaier's export hydroclimatology report.

## Overview

The `acf_swm` repository includes two main components:
1.  `scripts`: The SWM system uses a series of `Bash`, `Python`, `Perl`, `C-shell`, and `Fortran` scripts and programs. A top level script (`run_all.scr`) is used to run the forcing generation portion of the system. A configuration file (`data/input/swm_config.acf.bash`) is used to set the location of the input/output files in the system.
1.  `data`: The data directory only includes the basic configuration and settings files for the system.  The remaining files are provided in the `ACF_DATA_DIR`.

### VIC simulations
VIC version 4.1.2.g was run over the ACF basin using the forcings generated from the system described above. The global parameter file used for this simulation can be found at `data/vic_params/global.param.4.1.2.g.acf.txt`.  

## Requirements

The tools required to run this package are fairly basin UNIX tools. A summary of the core requirements are:
- gfortran
- gcc
- bash
- C-shell
- Python 2.7 or later
- Perl
- VIC 4.1.2.g

## License
```
Copyright (C) Hamman Consulting Services, LLC - All Rights Reserved
Unauthorized copying of this file, via any medium is strictly prohibited
Proprietary and confidential
Written by Joseph Hamman, PE - December 2015
```

## Credits

This work has been done in close collaboration with Dennis Lettenmaier.  The SWM system itself has been developed over a number of years by a range of graduate students and research scientists including Andy Wood, Shraddhanand Shukla, and Mu Xiao.  
