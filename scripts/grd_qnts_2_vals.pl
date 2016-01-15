#!/usr/bin/perl -w
# use Date::Calc qw(Add_Delta_YM);
# syntax ($year,$month,$day) = Add_Delta_YM($year,$month,$day,$Dy,$Dm);
# Shrad 02132007 Edited by Shrad for WA
# transforming gridded MONTHLY quantiles to gridded values
#   using precalculated monthly distributions for each grid cell
#   for precip only
# inputs:  monthly qnt. grid for spinup period data (cols=cells, 1 row per tstep)
#          monthly dist. file (one row per cell <mon1 dist><mon2 dist>
# output:  monthly amount grid for spinup data (rows=cells, cols=months)
#          note, this is transposed relative to the input qnt grid
# AWW-100803
# note, last month may be partial, so need to account for that AWW-013104


$lastmon_fract = 31/31;  # to prorate amt for final month  (not needed)
$Ndist = 50;  # obs clim sample size ## should be changed the same as years of Fmondist
$smo = 1;   # start month for mon quantiles


# %%%%%%%%%%%% LOOP OVER BASINS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



  
  # set basin specific files
  
  $Fmondist = "/raid2/jhamman/projects/ACF/data/output/acf.1961-2010.mon_clim.ptot"; # didn't follow name convention
  $Fmonqnt = "/raid2/jhamman/projects/ACF/data/output/acf.0625.p-monqnt.grd"; # input
  $Fmonamt = "/raid2/jhamman/projects/ACF/data/output/acf.0625.p-monamt.grd"; # output



  # ===== open, read in obs quantiles ================
  print "reading in observed monthly quantile tser\n";
  open(INF, "<$Fmonqnt") or die "Can't open $Fmonqnt $!\n";
  $m=0;
  while ($line = <INF>) {
    @tmp = split(" ",$line);
    for($c=0;$c<@tmp;$c++) {
      $monqnt[$m][$c] = $tmp[$c];
    }
    $rm[$m] = ($smo + $m - 1)%12 + 1;  # real month variable
    $m++;
  }
  close(INF);
  $nmon = $m;
  print "$nmon\n";
# ===== read in obs distributions ================
  # NOTE, if memory use gets too large, could operate one cell at a time without
  #       storing distributions
  open(INF, "<$Fmondist") or die "Can't open $Fmondist $!\n";
  $c=0;
  while ($line = <INF>) {
    print "reading obs dist for cell $c\n";
    @tmp = split(" ",$line);
#    $tmpsize = $#tmp;
#    print "SIZE of line for cell $c is $tmpsize\n";
    for($m=0;$m<12;$m++) {
      for($s=0;$s<$Ndist;$s++) {
        $mondist[$c][$m][$s] = $tmp[$s+$m*$Ndist];
# TEST
#	unless ( defined ( $tmp[$s+$m*$Ndist] ) ) {
#  print "Undef value for cell $c with index s = $s, m = $m, Ndist = $Ndist\n";
#  $index = $s + $m * $Ndist;
#  print "Index is $index\n";
#  print "Prev value = $tmp[$index - 1]\n";
#  print "LINE $line\n";
#   die "Dying\n";
#}
      }
    }
    $c++;
  }
  close(INF);
  $cells=$c;


# ==== assign amounts and write out amount grd ========
  print "writing amount grid\n";
  open(OUT, ">$Fmonamt") or die "Can't open $Fmonamt $!\n";
  for($c=0;$c<$cells;$c++) {  # loop through cells
    for($m=0;$m<$nmon;$m++) {  # write tser months along row
      @tmp = ();
      for($s=0;$s<$Ndist;$s++) {  # make tmp dist array for cell & month
        $tmp[$s] = $mondist[$c][$rm[$m]-1][$s];
      }
 #     print "ARG for sub is $monqnt[$m][$c], with m = $m, c = $c\n";
 #      print "$monqnt[$m][$c]  $m   $c\n";
      $monamt = val_given_F_bounded($monqnt[$m][$c], @tmp);
      # NOTE this lookout assumes no voids in distribution or lookup value (F)

      # now prorate final month amount if month is only partial
      if($m==$nmon-1) {
        $monamt *= $lastmon_fract;
      }
      printf OUT "%.3f ", $monamt;
    }
    printf OUT "\n";
  }
  close(OUT);

 # END basin loop
# END of program


# %%%%%%%%%%%%%%%%%%%% SUBROUTINES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

# set sort logic
#sub numer { $a <=> $b; }

# given a *SORTED* (low to high) array and non-exceed. %-ile, return the associated value.
# for this case, bound results by distribution (don't extrapolate at ends).
# (another version allowing unsorted arrays in different program - check sfc pred work)
sub val_given_F_bounded {
  my ($qnt, @array) = @_;
  $LEN = @array;  # dimension of array

#  print "INSUB ARG1 is $qnt, LEN is $LEN, SIZE -1 is $#array\n";
#  for ( $j = 0; $j < $LEN; $j++){
#      print "Arr $j is $array[$j].\n";
#  }
  @weib = ();
  for($i=0;$i<$LEN;$i++) {  # nonexceed. prob arrays go low to high
    $weib[$i] = ($i+1)/($LEN+1);
  }
  # check for sample size problems (no extrapolation allowed) - replace w/ following
#  if($weib[0] > $qnt || $weib[$LEN -1] < $qnt) {
#    printf STDERR "array too small for quant. calc; need larger sample or diff. quant.\n";
#    printf STDERR "qnt: $qnt   dist bounds: $weib[0], $weib[$LEN -1]\n";
#    die;
#  }

  # check for sample size problems (don't extrapolate - just use array bounds)
  if($weib[0] > $qnt ) {
    return $array[0];   # if quant too low, return lowest val
  } elsif($weib[$LEN -1] < $qnt) {
    return $array[$LEN -1]; # if quant too high, return highest val

  } else {  # quantile w/in bounds

    # find interpolation weight and index of values to interpolate
    $ndx = $weight = 0;
    for($i=1;$i<$LEN;$i++) { # start from one, since no extrapolation
      if($weib[$i] >= $qnt) {
        #weight multiplies upper value, (1-weight) mult. lower value
        $weight = ($qnt-$weib[$i-1])/($weib[$i]-$weib[$i-1]);
        $ndx = $i-1; # lower one
        last;
      }
    }
#    print "NDX = $ndx, weight = $weight, i = $i\n";
    # sort array (using logic set in other subroutine)
    # don't need this for this application: AWW-100803
    #  print "val_given_F: F=$qnt\n";
#    @srt_arr = ();
#    @srt_arr = sort numer @array;
    # calculate quantile-associated value
#    $val = $srt_arr[$ndx]*(1-$weight) + $srt_arr[$ndx+1]*($weight);

    $val = $array[$ndx]*(1-$weight) + $array[$ndx+1]*($weight);

    return $val;
  }
}

