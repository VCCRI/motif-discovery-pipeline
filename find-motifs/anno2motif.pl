#!/usr/bin/perl 
#  For changing Homer annotation format to motif BED file.
#  Author: Xin Wang  flyboyleo@gmail.com

open FILE1, "$ARGV[0]";

my $first = 1;

while (<FILE1>) {
         
  #if the line counter is <= first
  if($first >= $.) {
    chomp;
    @head_name = split(/\t/);    #don't use 'my' here!
  }

  else {

    chomp;
    my @line = split(/\t/);

    for (my $i = 21; $i < @line; $i++) {

      #skip if empty
      next if $line[$i] eq '';

      #split the line, and corresponding part of the header line
      my @group = split(/\),/, $line[$i]);
      my @anno = split (/\//, $head_name[$i]);

      for (my $j = 0; $j < @group; $j++) {

        my  @motif=split(/[(,)]/, $group[$j]);

        my $new_start = $line[2] + $motif[0];
        my $motiflength = length($motif[1]);
        my $new_end = $new_start + $motiflength - 1 ; #inclusive end position

        #   print "$line[1]\t$new_start\t$new_end\t$line[4]\t$motif[2]\t$motif[3]\t$motif[1]\n";
        print join("\t",
                   $line[1], $new_start, $new_end,
                   $motif[1], $motif[2],
                   $anno[0], $anno[1],
                   $line[0], $line[1], $line[2], $line[3], $line[5]
                   )."\n";
      }
    }
  }
}


