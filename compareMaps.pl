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
getopts( 'hm:p:r:', \%opts );

# if -h flag is used, or if no command line arguments were specified, kill program and print help
if( $opts{h} ){
  &help;
  die "Exiting program because help flag was used.\n\n";
}

# parse the command line
my( $map, $pro, $res ) = &parsecom( \%opts );

my @mapLines;
my @proLines;
my @resLines;

my %maphash;
my %prohash;
my %reshash;

&filetoarray( $map, \@mapLines );
&filetoarray( $pro, \@proLines );
&filetoarray( $res, \@resLines );

foreach my $line( @mapLines ){
	my @temp = split( /\s+/, $line );
	$maphash{$temp[0]} = $temp[1];
}

foreach my $line( @proLines ){
	my @temp = split( /\s+/, $line );
	for( my $i=1; $i<@temp; $i++ ){
		push( @{$prohash{$temp[0]}}, $temp[$i] );
	}
}

foreach my $line( @resLines ){
	my @temp = split( /\s+/, $line );
	$reshash{$temp[0]} = $temp[1];
}

foreach my $ind( sort keys %reshash ){
	if( $reshash{$ind} ne $maphash{$ind} ){
		my $mean = &arrayMean( \@{$prohash{$ind}} );
		$mean = sprintf( "%.3f", $mean );
		print "$ind classified as $reshash{$ind} with average probability $mean but should be $maphash{$ind}.\n";
	}
}

#print Dumper( \%prohash );

exit;

#####################################################################################################
############################################ Subroutines ############################################
#####################################################################################################

# subroutine to print help
sub help{
  
  print "\ncompareMaps.pl is a perl script developed by Steven Michael Mussmann\n\n";
  print "To report bugs send an email to mussmann\@email.uark.edu\n";
  print "When submitting bugs please include all input files, options used for the program, and all error messages that were printed to the screen\n\n";
  print "Program Options:\n";
  print "\t\t[ -h | -m | -p | -r  ]\n\n";
  print "\t-h:\tDisplay this help message.\n";
  print "\t\tThe program will die after the help message is displayed.\n\n";
  print "\t-m:\tSpecify expected map file (default = simSampleList.map.txt).\n\n";
  print "\t-p:\tSpecify probabilities file from compareNewhybrids.pl (default = prob.txt).\n\n";
  print "\t-r:\tSpecify results file from compareNewhybrids.pl (default = resultmap.txt).\n\n";
  
}

#####################################################################################################
# subroutine to parse the command line options

sub parsecom{ 
  
  my( $params ) =  @_;
  my %opts = %$params;
  
  # set default values for command line arguments
  my $map = $opts{m} || "simSampleList.map.txt";
  my $pro = $opts{p} || "prob.txt";
  my $res = $opts{r} || "resultmap.txt";

  return( $map, $pro, $res );

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
# subroutine to calculate mean of array

sub arrayMean{

	my( $arrayref ) = @_;

	my $total = 0;
	foreach my $value( @$arrayref ){
		$total+=$value;
	}

	my $mean = $total/scalar(@$arrayref);

	return $mean;

}

#####################################################################################################
