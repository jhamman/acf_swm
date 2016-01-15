#!/usr/bin/perl -w
# AWW-123002
# Shrad Edited for wash 16/02/2007
# calculate values from anomalies given precalculated means
# inputs:  .grd file with anomalies in same column order as
#        .info/.xyz type file with desired averages to apply
# outputs: .grd file with values
#          vicinput files
# AWW-083003:  memory problems with crb 1/8 deg (6392 cell), 2.7 yr period
#              changed to read about 1 year at a time (366 days)
#  NOTE: !!! must delete vic forcings in output directory first, so that
#            append doesn't have unintended consequences !!!

# AWW-103103:  modified to just write temperature grids, no precip or forcings
#              also to run a loop for all basins



$TOTRECS = 33238;  # set days in forcing period
$Chunk = 365;

$Void = -99;
$basedir = "/raid2/jhamman/projects/ACF/data/output";
$tx_anom = "$basedir/acf.txanom.grd";
$tn_anom = "$basedir/acf.tnanom.grd";
$avgs = "$basedir/acf.1961-2010.met_means.xyzz";
$tx_grd = "$basedir/acf.tx.grd";
$tn_grd = "$basedir/acf.tn.grd";

  # open files
  open(TXANOM, "<$tx_anom") or die "Can't open $tx_anom: $!\n";
  open(TNANOM, "<$tn_anom") or die "Can't open $tn_anom: $!\n";
  open(AVGS, "<$avgs") or die "Can't open $avgs: $!\n";
  open(TXGRD, ">$tx_grd") or die "Can't open $tx_grd: $!\n";
  open(TNGRD, ">$tn_grd") or die "Can't open $tn_grd: $!\n";

  # read averages ---------------------------------------
  print "reading average file: $avgs\n";
  @pavg = @name = @txavg = @tnavg = @wavg = ();
  $s=0;
  while ($line = <AVGS>) {
    ($name[$s],$pavg[$s],$txavg[$s],$tnavg[$s],$wavg[$s])=split(" ",$line);
    if($pavg[$s]==$Void || $txavg[$s]==$Void || $tnavg[$s]==$Void ||
       $wavg[$s]==$Void) {
      die "Voids found in grd avgs, row ". ($s+1) .
           ": fix them before using this program\n";
    }
    $s++;
  }
  close(AVGS);

  # %%% need to read/write in several iterations to keep memory usage down %%
  $num_iter = int($TOTRECS/$Chunk)+1;
  $tot_rec_cnt = 0;
  for($iter=1;$iter<$num_iter+1;$iter++) {

    # read in files
    print "reading anomaly .grd files\n";
    $rec = 0;
    @panom = @txanom = @tnanom = ();
    while ($rec<$Chunk && $tot_rec_cnt < $TOTRECS) {
    print "ITER $iter, record $rec\n";

      $line= <TXANOM>;
      (@tmp)=split(" ",$line);
      for($s=0;$s<@tmp;$s++) {
        $txanom[$rec][$s] = $tmp[$s];
      }

      $line= <TNANOM>;
      (@tmp)=split(" ",$line);
      for($s=0;$s<@tmp;$s++) {
        $tnanom[$rec][$s] = $tmp[$s];
      }
      $rec++;
      $tot_rec_cnt++;
    }  # end while ( for this reading iteration)

    # write out anomaly .grd files, handling voids (should be none)
    print "writing value .grd files\n";
    for($c=0;$c<$rec;$c++) {
      for($s=0;$s<@name;$s++) {
        printf TXGRD "%.2f ",$txanom[$c][$s]+$txavg[$s];
        printf TNGRD "%.2f ",$tnanom[$c][$s]+$tnavg[$s];
      }
      printf TXGRD "\n";
      printf TNGRD "\n";
    }  # end reading & writing grids

  } # %%%%%% end iteration through chunks of data %%%%%%%%%%%%%%%%
  close(TXANOM);
  close(TNANOM);
  close(TXGRD);
  close(TNGRD);


