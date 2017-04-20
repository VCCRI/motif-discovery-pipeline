#!/usr/bin/perl 

#  Author: Xin Wang  flyboyleo@gmail.com
#  Author: Joe Godbehere
# Update all lines from a .bed file with corresponding peak information from a .anno

if(@ARGV != 2) {
  print STDERR "ERROR: required arguments: <sorted annotation file> <sorted bed file>";
  exit 1;
}

my $sorted_anno_filename = $ARGV[0];
my $sorted_bed_filename = $ARGV[1];
my $peak_seek_failures = 0;

#open the pre-sorted annotation file and prepare to yield lines from it as required
open SORTED_ANNO_FILE, "<", "$sorted_anno_filename"
  or die "Can't open '$sorted_anno_filename' for reading. $!";

#open the pre-sorted bed file
open SORTED_BED_FILE, "<", "$sorted_bed_filename"
  or die "Can't open '$sorted_bed_filename' for reading. $!";

#get first peak
#@peak = split(/\t/, <SORTED_ANNO_FILE>);

#for each line in the bed file, update the peak information and output it
while(<SORTED_BED_FILE>) {

  #strip and split the line by column (tabs)
  #chomp;
  my @line = split(/\t/);

  #while the line does not fit in the current peak, iterate to the next one
  while($line[0] ne $peak[1] || $line[1] < $peak[2] || $line[2] > $peak[3]) {
    if(defined(my $raw_peak = <SORTED_ANNO_FILE>)) {
      #successfully fetched another peak line, continue looping
      chomp $raw_peak;
      @peak = split(/\t/, $raw_peak);
      next;
    }
    else {
      #ran out of peaks! die with error message!
      #die "ERROR: could not find peak for: $line[0], $line[1], $line[2]\nWas the annotation file sorted like the bed file?";
      print STDERR "WARNING: could not find peak for:\n";
      print STDERR join("\t", @line)."\n";
      $peak_seek_failures++;
      #undefine the peak, to avoid giving invalid output
      undef @peak;
      #reset to begining of file, then exit the loop
      seek SORTED_ANNO_FILE, 0, SEEK_SET;
      last;
    }
  }

  # output the line with the peak information replaced with the matched peak
  # peaks have no overlap, so we're safe to replace this data even for lines which
  # already had peaks attached 
  print join("\t",
             $line[0], $line[1], $line[2], $line[3], $line[4], $line[5], $line[6],
             $peak[0], $peak[1], $peak[2], $peak[3], $peak[5]
             )."\n";
}

if($peak_seek_failures) {
  print STDERR "WARNING: at least one sequence was not matched to a peak.\n";
  print STDERR "If there were many such warnings, the annotation file probably isn't ordered like the bed file\n";
  print STDERR "Otherwise, some (merged?) motifs cross multiple peaks, which implies peak overlap. Check the data source.\n\n";
}
