#!/usr/bin/perl

#  Author: Joe Godbehere
# split a motif file into chunks, each containing an ~equal quantity of motifs

use POSIX (ceil);
use File::Basename;

sub printUsage {
  print STDERR "Required arguments:\n";
  print STDERR "\t-m <motif file>\n";
  print STDERR "\t-n <number of chunks>\n";
  print STDERR "Optional arguments:\n";
  print STDERR "\t-pre <chunk filename prefix>\n";
  print STDERR "\t-post <chunk filename postfix>\n";
  print STDERR "\t-d <output directory>\n";
  print STDERR "\t-min <minimum motif length>\n";
}

my $motif_filename;
my $chunk_count;
my $prefix;
my $postfix = "";
my $output_dir = ".";
my $min_motif_length = 0;
my $max_motifs_per_chunk = 200; #work around HOMER limitation

for(my $i=0; $i < @ARGV; ++$i) {
  if($ARGV[$i] eq "-m") {
    $motif_filename = $ARGV[++$i];
  }
  elsif($ARGV[$i] eq "-n") {
    $chunk_count = $ARGV[++$i];
  }
  elsif($ARGV[$i] eq "-pre") {
    $prefix = $ARGV[++$i];
  }
  elsif($ARGV[$i] eq "-post") {
    $postfix = $ARGV[++$i];
  }
  elsif($ARGV[$i] eq "-d") {
    $output_dir = $ARGV[++$i];
  }
  elsif($ARGV[$i] eq "-min") {
    $min_motif_length = $ARGV[++$i];
  }
  else {
    print STDERR "ERROR: Invalid argument.\n";
    printUsage();
    exit 1;
  }
}

if(not defined $motif_filename) {
    print STDERR "ERROR: Motif file not specified.\n";
    printUsage();
    exit 1;
}

if(not defined $chunk_count) {
    print STDERR "ERROR: Number of chunks not specified.\n";
    printUsage();
    exit 1;
}

if(not defined $prefix) {
    print STDERR "Warning: Prefix not specified, defaulting to motif filename.\n";
    $prefix = basename($motif_filename);
}

if(not -d $output_dir) {
    if(-e $output_dir) {
      print STDERR "Output directory '$output_dir' is not a directory.\n";
    } else {
      print STDERR "Output directory '$output_dir' does not exist.\n";
    }
    exit 1;
}

open MOTIF_FILE, "<", "$motif_filename"
  or die "Can't open '$motif_filename' for reading. $!\n";

#get a count of the motifs
my $motif_count = 0;
my $motif_length = -1;
my $motif_rejected_count = -1;

while(<MOTIF_FILE>) {
  if(/^>/) {
    if($motif_length >= $min_motif_length) {
      ++$motif_count;
    } else {
      ++$motif_rejected_count;
    }
    $motif_length = 0;
  } else {
    ++$motif_length;
  }
}
#make sure we count the last one
if($motif_length >= $min_motif_length) {
  ++$motif_count
} else {
  ++$motif_rejected_count;
}

print STDERR "Read motifs: $motif_count, rejected motifs: $motif_rejected_count\n";

my $motifs_per_chunk = ceil($motif_count / $chunk_count);

if($motifs_per_chunk > $max_motifs_per_chunk) {
  print STDERR "The specified number of chunks ($chunk_count) would result in $motifs_per_chunk motifs per chunk, but we require that there are at most $max_motifs_per_chunk in each chunk. Please run the script again, specifying a larger number of chunks.\n";
  exit 1;
}

if($chunk_count < 2) {
  print STDERR "No need to split the input into chunks.\n";
  exit 0;
}

seek MOTIF_FILE, 0, SEEK_SET; #return to start of file

my $chunk_index = 1;
my $chunk_motifs;
my $chunk_file;
my $motif;

sub openChunk {
  my $chunk_filename = sprintf("%s/%s.part%02d%s", $output_dir, $prefix, $chunk_index, $postfix);
  open $chunk_file, ">", $chunk_filename
    or die "Can't open '$chunk_filename' for writing. $!";
}

sub endMotif {
  if($motif_length >= $min_motif_length) {
    #output the motif
    print $chunk_file $motif;
    ++$chunk_motifs;
  }
}

sub startMotif {
  $motif = "";
  $motif_length = -1; #-1 to offset header row
}

openChunk();
startMotif();

while(<MOTIF_FILE>) {
  if(/^>/) {
    endMotif();
    startMotif();
    #move to the next chunk if the current one is at capacity
    if($chunk_motifs >= $motifs_per_chunk) {
      $chunk_motifs = 0;
      ++$chunk_index;
      openChunk();
    }
  }
  $motif = $motif . $_;
  ++$motif_length;
}
#make sure we count the last one
endMotif();

print STDERR "Done\n";
