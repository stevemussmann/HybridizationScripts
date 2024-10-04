#!/usr/bin/perl

use warnings;
use strict;
use Getopt::Std;
use Data::Dumper;

# kill program and print help if no command line arguments were given
if( scalar( @ARGV ) == 0 ){
  &help;
  die "Exiting program because no command line options were used.\n\n";
}

# take command line arguments
my %opts;
getopts( 'hf:o:', \%opts );

# if -h flag is used, or if no command line arguments were specified, kill program and print help
if( $opts{h} ){
  &help;
  die "Exiting program because help flag was used.\n\n";
}

# parse the command line
my( $file, $out ) = &parsecom( \%opts );

my @fileLines;

# hashes to hold parsed data
my %hybClass;
my %hybProb;
my %hybPop;
my %matrix;

# hash to hold counts
my %cats;
my %pops;

&filetoarray( $file, \@fileLines ); # read lines from input file

# process header
my $header = shift( @fileLines );
my @head = split( /\t/, $header );

# populate counts hash
for( my $i=2; $i<@head; $i++ ){
	$cats{$head[$i]}++;
}

foreach my $line( @fileLines ){
	my $prob = 0.0;
	my $cat = "none";
	my @temp = split( /\t/, $line );
	for( my $i=2; $i<@temp; $i++ ){
		if( $temp[$i] > $prob ){
			$prob = $temp[$i];
			$cat = $head[$i];
		}
	}
	$hybClass{$temp[0]} = $cat;
	$hybProb{$temp[0]} = $prob;
	$hybPop{$temp[0]} = $temp[1];
	$pops{$temp[1]}++;
}

# populate matrix with 0 values
foreach my $pop( sort keys %pops ){
	foreach my $cat( sort keys %cats ){
		$matrix{$pop}{$cat} = 0;
		#$matrix{$cat}{$pop} = 0;
	}
}

# add data to the matrix
foreach my $ind( sort keys %hybClass ){
	$matrix{$hybPop{$ind}}{$hybClass{$ind}}++;
}

# print the matrix
print "Population";
foreach my $cat( sort keys %cats ){
	print "\t", $cat;
}
print "\n";
foreach my $pop( sort keys %pops ){
	print $pop;
	foreach my $cat( sort keys %cats ){
		print "\t", $matrix{$pop}{$cat};
	}
	print "\n";
}

#print Dumper( \%matrix );

exit;

#####################################################################################################
############################################ Subroutines ############################################
#####################################################################################################

# subroutine to print help
sub help{
  
  print "\nconfusionMatrix.pl is a perl script developed by Steven Michael Mussmann\n\n";
  print "To report bugs send an email to mussmann\@email.uark.edu\n";
  print "When submitting bugs please include all input files, options used for the program, and all error messages that were printed to the screen\n\n";
  print "Program Options:\n";
  print "\t\t[ -h | -f | -o ]\n\n";
  print "\t-h:\tDisplay this help message.\n";
  print "\t\tThe program will die after the help message is displayed.\n\n";
  print "\t-f:\tSpecify the name of the input file.\n";
  print "\t\tThis should be the aa-PofZ.relabeled.txt file produced from the relabelPofZ.pl script.\n\n";
  print "\t-o:\tSpecify output file (Optional).\n\n";
  
}

#####################################################################################################
# subroutine to parse the command line options

sub parsecom{ 
  
  my( $params ) =  @_;
  my %opts = %$params;
  
  # set default values for command line arguments
  my $file = $opts{f} || die "No input file specified (file is probably named aa-PofZ.relabeled.txt).\n\n"; #used to specify input file name.
  my $out = $opts{o} || "confusion.aa-PofZ.relabeled.txt"; #used to specify output file name.

  return( $file, $out );

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
