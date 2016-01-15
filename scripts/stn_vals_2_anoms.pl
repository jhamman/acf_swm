#!/usr/bin/perl -w
# AWW-12-29-02
# Shrad edited for wash 16/02/2007
# calculate anomalies from values given precalculated means
# inputs:  .fmt file with values in same column order as
#        .info/.xyz type file with desired averages to remove
# outputs: .fmt file with anomalies

# AWW-103103:  using percentile method for precip - anomaly for temps only
#              expanding to use for 5 basins

# AWW-20050330:  modified to handle VOID in averages file
#                rewrote to work in chunks, avoid memory problems

# NOTE:  no screening in here for weird values

$void = -99.0;
$Chunk = 500;  # number of records to process at once, in fmt files


# %%%%%%%%%%%% LOOP OVER BASINS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


  # set basin specific files
$basedir = "/raid2/jhamman/projects/ACF/data/output";
$avgs = "$basedir/acf.ndx_stns.p-tx-tn.1961-2010.dlyavgs";
print "AVGS file is $avgs\n";
$tx_fmt = "$basedir/acf.ndx_stns.tx.fmt";
$tn_fmt = "$basedir/acf.ndx_stns.tn.fmt";
$tx_anom = "$basedir/acf.ndx_stns.txanom.fmt";
$tn_anom = "$basedir/acf.ndx_stns.tnanom.fmt";

  # open files
  open(TXFMT, "<$tx_fmt") or die "Can't open $tx_fmt: $!\n";
  open(TNFMT, "<$tn_fmt") or die "Can't open $tn_fmt: $!\n";
  open(AVGS, "<$avgs") or die "Can't open $avgs: $!\n";
  open(TXANOM, ">$tx_anom") or die "Can't open $tx_anom: $!\n";
  open(TNANOM, ">$tn_anom") or die "Can't open $tn_anom: $!\n";

  # read averages ---------------------------------------
  print "reading average files\n";
  $s=0;
  while ($line = <AVGS>) {
    ($name[$s],$pavg[$s],$txavg[$s],$tnavg[$s])=split(" ",$line);
    $s++;
  }
  close(AVGS);

  # read in data files
  print "reading value .fmt files\n";
  $c = $rectot = 0;
  while (<TXFMT>) {
    @tmp=split;
    for($s=0;$s<@tmp;$s++) {
      $tx[$c][$s] = $tmp[$s];
    }

    $line= <TNFMT>;
    @tmp=split(" ",$line);
    for($s=0;$s<@tmp;$s++) {
      $tn[$c][$s] = $tmp[$s];
    }
    $c++;

    # check to see if it's time to write out chunk of data
    if($c==$Chunk) {
      # write out anomaly .fmt files, handling voids
      # also, check tmax > tmin (crude QC in case not flagged elsewhere)
      print "writing anomaly files for records:  $rectot to ".($c+$rectot)." \n";
      for($c=0;$c<$Chunk;$c++) {
        for($s=0;$s<@name;$s++) {
          if($tx[$c][$s] != $void && $tn[$c][$s] != $void &&
            $txavg[$s] != $void && $tnavg[$s] != $void &&
            $tx[$c][$s] > $tn[$c][$s] ) {
            printf TXANOM "%.2f ",$tx[$c][$s]-$txavg[$s];
            printf TNANOM "%.2f ",$tn[$c][$s]-$tnavg[$s];
          } else {
            printf TXANOM "%d ", int $void;
            printf TNANOM "%d ", int $void;
          }
        }
        printf TXANOM "\n";
        printf TNANOM "\n";
      }
      $rectot += $c;
      $c=0;
    }  # end if condition for writing chunk

  } # end while reading data loop
  close(TXFMT);
  close(TNFMT);
  $lastrec = $c;

  # might be data remaining to write out, after final chunk increment
  # write out anomaly .fmt files, handling voids, possible tmax<tmin errors
  print "writing anomaly files for records:  $rectot to ".($c+$rectot)." \n";
  for($c=0;$c<$lastrec;$c++) {
    for($s=0;$s<@name;$s++) {
      if($tx[$c][$s] != $void && $tn[$c][$s] != $void &&
        $txavg[$s] != $void && $tnavg[$s] != $void &&
        $tx[$c][$s] > $tn[$c][$s] ) {
        printf TXANOM "%.2f ",$tx[$c][$s]-$txavg[$s];
        printf TNANOM "%.2f ",$tn[$c][$s]-$tnavg[$s];
      } else {
        printf TXANOM "%d ",int $void;
        printf TNANOM "%d ",int $void;
      }
    }
    printf TXANOM "\n";
    printf TNANOM "\n";
  }
  close(TXANOM);
  close(TNANOM);

