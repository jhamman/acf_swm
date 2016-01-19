#!/usr/bin/perl -w
# AWW-100803
# This does same thing as vicinput, but also adds wind avgs
# Shrad 20022007 Shrad edited for Wash
# inputs:  Tmax & Tmin .grd file with values calculated in anom_meth/ dir by
#            anoms_2_vals.PNW_125.pl script
#          Pcp rescaled .rsc file calc'd by grd_monamt_2_dlyamt.pl, this dir.
#          .info/.xyz type file with desired averages to apply (for wind)
# outputs: vicinput tser files, ascii

# AWW-083003:  memory problems with crb 1/8 deg (6392 cell), 2.7 yr period
#              changed to read about 1 year at a time (366 days)
# AWW-103003:  modified to run over 5 basins in sequence

# AWW-2005331:  modified to use memory differently, and to write over all 
#               filehandles at once

# not best for long term forcings:  better to do them in binary, really.

#$DATESTR = "1971-2000";
$TOTRECS = 33238;  # set days in forcing period

$Chunk = 365;


  # set basin specific files
  
  $basedir = $ENV{'swm_output_dir'};
  $avgs   = "$basedir" . $ENV{'swm_prefix'} . ".1961-2010.met_means.xyzz"; 
  $p_rsc  = "$basedir" . $ENV{'swm_prefix'} . ".0625.p-dlyamt.grd";
  $tx_grd = "$basedir" . $ENV{'swm_prefix'} . ".tx.grd";
  $tn_grd = "$basedir" . $ENV{'swm_prefix'} . ".tn.grd";
  $forcdir = $ENV{'swm_output_dir'}; 

  # open files
  open(AVGS, "<$avgs") or die "Can't open $avgs: $!\n";
  open(P_RSC, "<$p_rsc") or die "Can't open $p_rsc: $!\n";
  open(TXGRD, "<$tx_grd") or die "Can't open $tx_grd: $!\n";
  open(TNGRD, "<$tn_grd") or die "Can't open $tn_grd: $!\n";

  # read averages ------------------------------------------
  print "reading average file\n";
  @name = @pavg = @txavg = @tnavg = @wavg = @FH = ();
  $s=0;
  while ($line = <AVGS>) {
    ($name[$s],$pavg[$s],$txavg[$s],$tnavg[$s],$wavg[$s])=split(" ",$line);

    # to open all output files at once, use next 2 lines (check machine limits)
    # if not, the other option is opening them one by one, appending and closing
#    $FH[$s] = "FH$s";   # file handle array
#    print "opened file $s\n";
#    open ($FH[$s], ">$forcdir$name[$s]") or die "can't open $forcdir$name[$s]: $!\n";

    $s++;
  }
  close(AVGS);

  # %%%% need to read/write in several iterations to keep memory usage down %%%%
  $num_iter = int($TOTRECS/$Chunk)+1;

  $tot_rec_cnt = 0;
  for($iter=1;$iter<$num_iter+1;$iter++) {

    # read in files
    print "reading .grd/.rsc files\n";
    $rec = 0;
    @p = @tx = @tn = ();
    while ($rec<$Chunk && $tot_rec_cnt < $TOTRECS) {
      $line = <P_RSC>;    # these reads assume no problem w/ file lengths
      print "ITER $iter, record $rec\n";
      (@tmp)=split(" ",$line);
      for($s=0;$s<@tmp;$s++) {
        $p[$rec][$s] = $tmp[$s];
      }

      $line= <TXGRD>;
      (@tmp)=split(" ",$line);
      for($s=0;$s<@tmp;$s++) {
        $tx[$rec][$s] = $tmp[$s];
      }

      $line= <TNGRD>;
      (@tmp)=split(" ",$line);
      for($s=0;$s<@tmp;$s++) {
        $tn[$rec][$s] = $tmp[$s];
      }
      $rec++;
      $tot_rec_cnt++;
    }  # end while

    # now loop through and write forcing files
    print "writing forcings\n";
    for($s=0;$s<@name;$s++) {

      # use following lines only if opening output files one by one
        $fname = $forcdir . $name[$s];
        open(FORC, ">>$fname") or die "Can't open $fname: $!\n";
       for($c=0;$c<$rec;$c++) {
         printf FORC "%.2f %.2f %.2f %.1f\n",
           $p[$c][$s], $tx[$c][$s], $tn[$c][$s], $wavg[$s];
       }
       close(FORC);

      # use following if opening all output files at once
      #$tmpfh = $FH[$s];
      #for($c=0;$c<$rec;$c++) {
      #  printf $tmpfh "%.2f %.2f %.2f %.1f\n",
      #    $p[$c][$s], $tx[$c][$s], $tn[$c][$s], $wavg[$s];
      #}

    }

  } # %%%%%% end iteration through chunks of data %%%%%%%%%%%%%%%%
  close(P_RSC);
  close(TXGRD);
  close(TNGRD);
# Use the following if opening all files at once.  
#  for($s=0;$s<@name;$s++) {
#    close($FH[$s]);
#  }


