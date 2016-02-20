#!/usr/bin/env bash

swm_prefix='acf'

# input files
swm_dem=/raid2/jhamman/projects/ACF/data/input/acf.dem.txt
swm_file_list=/raid2/jhamman/projects/ACF/data/input/acf.file.list
swm_stations=/raid2/jhamman/projects/ACF/data/input/acf.stns.info

# regrid exe
regrid_exe=/raid2/jhamman/projects/ACF/scripts/regrid/regrid

# input data directories
swm_ref_dir=/raid2/jhamman/projects/ACF/data/input/livneh_asc
swm_stn_dir=/raid2/jhamman/projects/ACF/data/input/stns/
# output directories
swm_output_dir=/raid2/jhamman/projects/ACF/data/output/
swm_force_dir=/raid2/jhamman/projects/ACF/data/forcings/acf_swm/

# sizes and dims
swm_clim_ref_idate="1915-01-01"
swm_clim_ref_sdate="1950-01-01"
swm_clim_ref_syear="1961"
swm_clim_ref_eyear="2010"

#-----------------------------------------------------------------------------#
# calculated values
swm_clim_n_recs=23376 # from 1950,01,01 to 2013,12,31
swm_clim_s_rec=4019 # start,end records for averaging (1961,1,1)
swm_clim_e_rec=21915 # figure out ahead of time, it's quicker (2010,12,31)




