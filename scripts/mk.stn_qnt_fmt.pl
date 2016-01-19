#!/usr/bin/perl -w
# shrad edited for wash 02/10/2007
# reads monthly station timeseries
# calculates percentiles relative to monthly climatologies
# writes out monthly precip quantiles for all stations into one big .fmt file
# AWW-032805

# --------------- settings -------------------------

$StnList = $ENV{'swm_stations'};
$BASEDIR = $ENV{'swm_output_dir'};
# wash
# retro TS
$TSDIR = "$BASEDIR/mon.aciscan/";
# current spinup TS 
#$TSDIR = $BASEDIR . "/forc/rt_data/currmon/";
$CLIMDIR = "$BASEDIR/Pavg/";
$OutFl = "$BASEDIR" . $ENV{'swm_prefix'} . ".ndx_stns.p-monqnt.fmt"; 
$Debug = 0;


($ClimSyr, $ClimEyr) = (1961,2010); # must match input clim files
$Void = -99.0;   $Voidstr = "-99";  # should match (used for reducing output)
# ----------- END settings ---------------------------
$Nyrs = $ClimEyr-$ClimSyr+1;

# open, read station list ----------
open (INFO, "<$StnList") or die "can't open $StnList: $!\n";
$Nsta = <INFO>;  chomp($Nsta); # number of stations

# ================== LOOP over all stations =========================
@qnt = (); # initialize
$s=0;
while (<INFO>) {
  ($junk,$junk,$junk,$Stn_ID,@tmp) = split;
  print "processing station $s:  $Stn_ID\n";

  @prcp = @clim = ();   # initialize

  # read climatology (a one-row file)
  $MonClim = "$CLIMDIR$Stn_ID";
  open (CLIM, "<$MonClim") or die "can't open $MonClim: $!\n";
  $line = <CLIM>;
  ## Seperating station ID from other data
  
  ($id,@tmp) = split(" ",$line);
  for($m=1;$m<13;$m++) {
    for($y=0; $y<$Nyrs; $y++) {
      $clim[$m][$y] = $tmp[($m-1)*$Nyrs + $y ];
    }
  }

  # read in monthly TS
  $MonTS = "$TSDIR$Stn_ID";
  open (TS, "<$MonTS") or die "can't open $MonTS: $!\n";
  $rec = 0;
  while (<TS>) {
    ($yr, $mon[$rec], $prcp[$rec], @junk) = split;

    if ( $Debug == 1) {
      print "Yr $yr, Mon $mon[$rec], P $prcp[$rec]\n";
    }
    $rec++;

  }
  close(TS);

  # now find quantiles, cycling through months
  for($m=1;$m<13;$m++) {

    # get sorted clim to use for this month
    @srt = ();
    for($y=0; $y<$Nyrs; $y++) {
      $srt[$y] = $clim[$m][$y];
    }

    for($r=0;$r<$rec;$r++) {
      if($m == $mon[$r]) {
        if($prcp[$r] == $Void) {
          $qnt[$r][$s] = $Void;
        } else {
          $qnt[$r][$s] =
             F_given_val_with_voids($prcp[$r],$Void,@srt);
        }
      }  # end matching current
    }  # end looping through records
  } # end month loop

  $s++;  # increment station counter
} # end looping through stations ==============================
close(INFO);

print "Writing quantile fmt file ...\n";
open (OUTF, ">$OutFl") or die "can't open $OutFl: $!\n";

# print the quantiles out in a fmt format
for($r=0;$r<$rec;$r++){
  for($s=0;$s<$Nsta;$s++){
    unless ( defined ( $qnt[$r][$s] ) ){
      print "R is $r, S is $s, REC is $rec, Nsta is $Nsta, and QNT not defined\n";
      exit(0);
    }
   

    if($qnt[$r][$s] == $Void) {
      printf OUTF "%s ", $Voidstr;
    } else {
      printf OUTF "%.4f ", $qnt[$r][$s];
    }

    if ( $Debug ) {
      if ( $qnt[$r][$s] < 0 ) {
        print "QNT is $qnt[$r][$s] for rec $r and sta $s\n";
      }
    }


  }
  printf OUTF "\n";
}
close(OUTF);
print "DONE!\n";


# %%%%%%%%%%%%%%%%%%%%%%%%% SUBROUTINES %%%%%%%%%%%%%%%%%%%%%%

# given a SORTED array and value, return the associated non-exceed. %-ile.
# this version allows voids in sorted array, but they must come first
#   e.g., -99 is pretty much lower then temp & precip, so this works
sub F_given_val_with_voids {
  my ($val, $void, @array) = @_;

  @srt_arr = @weib = ();  # INITIALIZE
  # reduce array length by taking out voids
  $n2 = 0;
  for($n=0;$n<@array;$n++) {
    if($array[$n] != $void) {
      $srt_arr[$n2] = $array[$n];
      $n2++;
    }
  }
  $LEN = @srt_arr;  # dimension of array

  for($i=0;$i<$LEN;$i++) {  # nonexceed. prob arrays go low to high
    $weib[$i] = ($i+1)/($LEN+1);
  }

  # check for sample limits problems (extrapolate to a bit outside qnt bounds)
  if($srt_arr[0] > $val ) {
    return 1/($LEN+1)/2;
  } elsif ($srt_arr[$LEN -1] < $val) {
    return 1-1/($LEN+1)/2;
  }

  # find interpolation weight and index of values to interpolate
  $ndx = $weight = 0;
  for($i=1;$i<$LEN;$i++) { # start at 1 since other cases handled earlier
    if($srt_arr[$i] >= $val) {
      # could be % by zero problem if adjacent distrib. values are equal
      if($srt_arr[$i]-$srt_arr[$i-1] == 0) {
        $weight = 0.5;
      } else {
        #weight multiplies upper value, (1-weight) mult. lower value
        $weight = ($val-$srt_arr[$i-1])/($srt_arr[$i]-$srt_arr[$i-1]);
      }
      $ndx = $i-1; # lower one
      last;
    }
  }

  # Handle case of bad logic above
  unless ( ( defined ( $weib[$ndx] )) && ( defined ( $weib[$ndx + 1] )) ) {
    $qnt = $Void;
    return $qnt;
  }

  # calculate value-associated quantile
  $qnt = $weib[$ndx]*(1-$weight) + $weib[$ndx+1]*($weight);

  return $qnt;
}
