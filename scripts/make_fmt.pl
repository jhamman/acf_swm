#!/usr/bin/perl
#
#
#
# shrad 02/10/2007 edited for Wash
# reads station timeseries and collates them into a fmt file
# input format:  y m d p tx tn
# ASA-020205 (AWW, rewritten)

# loop through in chunks of $chunk data, reading and writing files, to
# avoid maxing out on memory

# WARNING, must have fewer stations than maximum filehandles

# ------- settings ---------------
$DATDIR = "/raid8/forecast/sw_monitor/data/conus/forcing/acis/lt_data/";
$OUTDIR = "/raid2/jhamman/projects/ACF/data/output/";
$StnList = "/raid2/jhamman/projects/ACF/data/input/CONUS.stns.info";

$chunk = 250;

$TOTRECS = 33238;  # length of station timeseries in days (1920/1/1-2010/12/31)
$Void = -99.0;   $Voidstr = "-99";   # these should match (used for reducing output)
$DEBUG = 1; 
# ------- END settings ------------

# open output files

$prefix = 'acf';

$OutPcp = $OUTDIR . $prefix . ".ndx_stns.p.fmt";
$OutTx  = $OUTDIR . $prefix . ".ndx_stns.tx.fmt";
$OutTn  = $OUTDIR . $prefix . ".ndx_stns.tn.fmt";
open (OUTP, ">$OutPcp") or die "can't open $OutPcp: $!\n";
open (OUTX, ">$OutTx") or die "can't open $OutTx: $!\n";
open (OUTN, ">$OutTn") or die "can't open $OutTn: $!\n";

# read station list, open files and get data
open (STNF, "$StnList") or die "can't open $StnList: $!\n";
$Nsta = <STNF>;  chomp($Nsta);  # header has N stations
$k=0;
while (<STNF>) {
  ($junk,$junk,$junk,$Stn_ID[$k],@tmp) = split;
  $StnDat = "$DATDIR" . $Stn_ID[$k];  # station names
  $FH[$k] = "FH$k";   # file handle array
  # open all files at once
  open ($FH[$k], "<$StnDat") or die "can't open $StnDat: $!\n";
  $k++;
}
close(STNF);
print "opened $k station files ... \n";




# %%%% need to read/write in several iterations to keep memory usage down %%%%
$num_iter = int($TOTRECS/$chunk)+1;

print "Num Iterations $num_iter\n";


$tot_rec_cnt = 0;
for($iter=0;$iter<$num_iter;$iter++) {
   print "ITERATIONS $tot_rec_cnt -- ". ($tot_rec_cnt+$chunk-1) . " \n";  # Print number of records

  @prcp = @tmax = @tmin = ();  # initialize

  # loop over stations, getting data
  for($stn=0;$stn<$Nsta;$stn++) {
    $tmpfh = $FH[$stn];  # point to pre-opened file
    if ( $DEBUG ) {
     print "Reading file for stn $Stn_ID[$stn]\n";
    }

    # read, store each station's data
    $rec = 0;
    while ($rec < $chunk  &&  $tot_rec_cnt+$rec < $TOTRECS) {

      # Skip the first header line that's in some data files. This will slow down run time
      if ( ( $DATDIR =~ /rt_data/) && ( $rec == 0 ) && ( $iter == 0 ) ){
        $line = <$tmpfh>;
      }

      $line = <$tmpfh>;
      @tmp = split(" ", $line);
      $prcp[$rec][$stn]=$tmp[3];
      $tmax[$rec][$stn]=$tmp[4];
      $tmin[$rec][$stn]=$tmp[5];
      if ( $DEBUG ) {
        for ( $kk = 3; $kk < 6; $kk++) {
          unless ( defined ( $tmp[$kk] ) ) {
            print "Undef for tmp $kk at rec $rec, stn $stn, chunk $chunk\n";
            print "Line is $line\n";
            die;
          }
        }
      }

      $rec++;
    }

  } # done reading chunk for all stations, now write out chunk

  print "  writing $rec records (last set may be partial) ...\n";
  for($r=0;$r<$rec;$r++) {
    for($s=0;$s<$Nsta;$s++) {
      if ( $DEBUG ) {
        unless ( defined ( $prcp[$r][$s] ) ){
          print "Undef for prcp r = $r, s = $s\n";
          die;
	}
      }
      if($prcp[$r][$s] == $Void) {
        printf OUTP "%s ", $Voidstr;
      } else {
        printf OUTP "%.3f ", $prcp[$r][$s];
      }
    }
    printf OUTP "\n";
  }

  for($r=0;$r<$rec;$r++) {
    for($s=0;$s<$Nsta;$s++) {
      if ( $DEBUG ) {
        unless ( defined ( $tmax[$r][$s] ) ){
          print "Undef for tmax r = $r, s = $s\n";
          die;
	}
      }
      if($tmax[$r][$s] == $Void) {
        printf OUTX "%s ", $Voidstr;
      } else {
        printf OUTX "%.2f ", $tmax[$r][$s];
      }
    }
    printf OUTX "\n";
  }

  for($r=0;$r<$rec;$r++) {
    for($s=0;$s<$Nsta;$s++) {
      if ( $DEBUG ) {
        unless ( defined ( $tmin[$r][$s] ) ){
          print "Undef for tmin r = $r, s = $s\n";
          die;
	}
      }
      if($tmin[$r][$s] == $Void) {
        printf OUTN "%s ", $Voidstr;
      } else {
        printf OUTN "%.2f ", $tmin[$r][$s];
      }
    }
    printf OUTN "\n";
  }

  $tot_rec_cnt += $rec;

}  # done reading/writing all chunks of station data

# finish up ---
print "closing files...\n";
close(OUTP);
close(OUTX);
close(OUTN);
for($s=0;$s<$Nsta;$s++) {
  close($FH[$s]);
}
