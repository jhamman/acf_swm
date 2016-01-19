#!/usr/bin/perl -w
use Date::Calc qw(Delta_Days Days_in_Month);
# edited by Shrad for WA ncast 02052007
# script replaces get.mon_srt_clim.scr from tmp_pxs retro work
# reads binary forcing data (transformed to ascii by external prog)
#  writes out monthly sorted PCP array for each grid cell in 0.5 degree dataset
# AWW-032504

#  --- settings ------------------------
# grid files

$DPATH = $ENV{'swm_ref_dir'};

$Listf = $ENV{'swm_file_list'};

($Syr, $Smo, $Sdy) = (1950,1,1);    # start record of gridded forcing data
($OutSyr, $OutEyr) = (1961, 2010);  # should match those used for distributions
                       #   of station files (../stn_info/lt_tser/Pavg)
$Stnoutf = $ENV{'swm_output_dir'} . $ENV{'swm_prefix'} . ".$OutSyr-$OutEyr.mon_clim.ptot"; #p mon-totals distrib. file

# forcing data input details ----------
 $Pscale = 100;  # scalar for how precip is packed in binary forcing files
 $recsize = 8;  # number of bytes in data record
 $template = "S s s S";  # template for binary data record (unsigned & signed shorts)
# ------ END settings ---------------------

# ------ open output file ---------------
open (OUTF, ">$Stnoutf") or die "can't open $Stnoutf: $!\n";

# open, read station list ----------
@cells = `cat $Listf`;       chomp(@cells);
#TEST
#@cells = `head  $Listf`;       chomp(@cells);
#($OutSyr, $OutEyr) = (1977, 1978);
#TEST

# figure out how much grid cell data must be skipped
$Nskip = Delta_Days($Syr, $Smo, $Sdy, $OutSyr, 1, 1);

#TEST
#print "NSKIP is $Nskip\n";
#exit(0);
#TEST

# make date arrays needed for processing data
$rec=0;
($y,$m,$d) = ($OutSyr, 1, 1);
for($y=$OutSyr;$y<=$OutEyr;$y++) {
  for($m=1;$m<13;$m++) {
    for($d=1;$d<=Days_in_Month($y,$m);$d++) {
      $year[$rec] = $y;
      $mon[$rec] = $m;
      $rec++;
    }
  }
}

# now loop through the binary forcing datafiles - unpack, total, sort,
#   and write new row in output file

for($c=0;$c<@cells;$c++) { # ===========================================
  print "processing cell $c:  $cells[$c]\n";
  @pcp_tot = ();

  open (GRDF, "<$DPATH$cells[$c]") or die "can't open $DPATH$cells[$c]: $!\n";
  $skipi=1;
  while($skipi<=$Nskip){
  $kk=<GRDF>;
  $skipi++;
  }

  for($r=0;$r<$rec;$r++) {
    # read one day's record
# TEST - UNcomment above line to restore
#    $chunksize = read(GRDF, $binrec, $recsize) ;
#    print "Chunk is $chunksize\n";
#    next;
#TEST - remove the above lines
#TEST - these are commented out for now - UNcomment
    $kk = <GRDF>;
    chomp $kk;
    @oneday = split(" ",$kk); # $oneday is int, $binrec is binary
    $pcp_tot[$year[$r]-$OutSyr][$mon[$r]] += $oneday[0];#/$Pscale;
#    print "@oneday\n";
#    print "$kk\n";
#TEST
  }
  close(GRDF);

# TEST
#exit(0);
# TEST
  for($m=1;$m<13;$m++) {
    @tmp = ();
    for($y=0;$y<=$OutEyr-$OutSyr;$y++) {
      $tmp[$y] = $pcp_tot[$y][$m];
    }
    @srt = sort numer @tmp;

    # write
    for($y=0;$y<=$OutEyr-$OutSyr;$y++) {
      printf OUTF "%.3f ", $srt[$y];
    }
    printf OUTF "    ";
  }
  printf OUTF "\n";

}  # end looping through cells ============================================

close(OUTF);
print "DONE!\n";



# %%%%%%%%%%%%%%%%%%%%%% SUBROUTINE %%%%%%%%%%%%%%%%%%%%%%%%%%
# set sort logic
sub numer { $a <=> $b; }
