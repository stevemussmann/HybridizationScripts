#!/usr/bin/perl

use warnings;
use strict;
use Getopt::Std;
use Data::Dumper;

# kill program and print help if no command line arguments were given
#if( scalar( @ARGV ) == 0 ){
#  &help;
#  die "Exiting program because no command line options were used.\n\n";
#}

# take command line arguments
my %opts;
getopts( 'g:hm:o:z:Z:', \%opts );

# if -h flag is used, or if no command line arguments were specified, kill program and print help
if( $opts{h} ){
  &help;
  die "Exiting program because help flag was used.\n\n";
}

# parse the command line
my( $list, $map, $out ) = &parsecom( \%opts );

my @listLines;
my @mapLines;

my %maphash;

&filetoarray( $list, \@listLines );
&filetoarray( $map, \@mapLines );

foreach my $line( @mapLines ){
	my @temp = split( /\s+/, $line );
	$maphash{$temp[0]} = $temp[1];
}

open( OUT, '>', $out ) or die "Can't open $out: $!\n\n";
foreach my $line( @listLines ){
	my @temp = split( /_/, $line );
	print OUT $line, "\t", $maphash{$temp[0]}, "\n";
}
close OUT;

exit;
#####################################################################################################
############################################ Subroutines ############################################
#####################################################################################################

# subroutine to print help
sub help{
  
  print "\ngenepop2newhybrids.pl is a perl script developed by Steven Michael Mussmann\n\n";
  print "To report bugs send an email to mussmann\@email.uark.edu\n";
  print "When submitting bugs please include all input files, options used for the program, and all error messages that were printed to the screen\n\n";
  print "Program Options:\n";
  print "\t\t[ -h | -m | -o | -g | -z | -Z ]\n\n";
  print "\t-h:\tUse this flag to display this help message.\n";
  print "\t\tThe program will die after the help message is displayed.\n\n";
  print "\t-m:\tUse this to specify the name of a popmap file.\n\n";
  print "\t-o:\tUse this flag to specify the output file name.\n";
  print "\t\tIf no name is provided, the file extension \".newhybrids\" will be appended to the input file name.\n\n";
  print "\t-g:\tUse this to specify the name of a genepop file.\n\n";
  print "\t-z:\tUse this to specify the population name that corresponds to the first parental populations (z0). Multiple names should be comma-delimited.\n\n";
  print "\t-Z:\tUse this to specify the population name that corresponds to the second parental populations (z1). Multiple names should be comma-delimited.\n\n";
  
}

#####################################################################################################
# subroutine to parse the command line options

sub parsecom{ 
  
  my( $params ) =  @_;
  my %opts = %$params;
  
  # set default values for command line arguments
  my $list = $opts{l} || "simSampleList.txt"; #used to specify sample list file name.
  my $map = $opts{m} || "samplegroupMap.txt"; #used to specify sample group map file name.
  my $out = $opts{o} || "simSampleList.map.txt"  ; #used to specify output file name.

  return( $list, $map, $out );

}

#####################################################################################################
# subroutine to put file into an array

sub filetoarray{

  my( $infile, $array ) = @_;

  
  # open the input file
  open( FILE, $infile ) or die "Can't open $infile: $!\n\n";

  # loop through input file, pushing lines onto array
  while( my $line = <FILE> ){
    chomp( $line );
    next if($line =~ /^\s*$/);
    push( @$array, $line );
  }

  # close input file
  close FILE;

}

#####################################################################################################
