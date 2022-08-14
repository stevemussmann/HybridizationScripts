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
getopts( 'hm:n:o:p:', \%opts );

# if -h flag is used, or if no command line arguments were specified, kill program and print help
if( $opts{h} ){
  &help;
  die "Exiting program because help flag was used.\n\n";
}

# parse the command line
my( $map, $new, $poz, $out ) = &parsecom( \%opts );

my @maplines; #holds popmap file lines
my @newlines; #holds newhybrids genotype category file lines
my @pozlines; #holds newhybrids output file lines

my %cathash;

&filetoarray($map, \@maplines);
&filetoarray($new, \@newlines);
&filetoarray($poz, \@pozlines);

shift( @newlines );
foreach my $line( @newlines ){
	my @temp = split( /\s+/, $line );
	my $cat = shift( @temp );
	my @trunc;
	foreach my $freq( @temp ){
		push( @trunc, sprintf( "%.3f", $freq ) );
	}
	my $newstring = join( '/', @trunc );
	$cathash{$newstring} = $cat;
}

open( OUT, '>', $out ) or die "Can't open $out: $!\n\n";
my $header = shift( @pozlines );
my @temphead = split( /\s+/, $header );
shift( @temphead );
shift( @temphead );
my @newhead;
push( @newhead, "Sample" );
push( @newhead, "Population" );
foreach my $item( @temphead ){
	push( @newhead, $cathash{$item} );
}
my $newheadstring = join( "\t", @newhead );
print OUT $newheadstring, "\n";

for( my $i=0; $i<@pozlines; $i++ ){
	my @temp = split( /\s+/, $pozlines[$i] );
	my @maptemp = split( /\s+/, $maplines[$i] );
	shift( @temp );
	shift( @temp );
	unshift( @temp, @maptemp );
	my $newline = join( "\t", @temp );
	print OUT $newline, "\n";
}

close OUT;

exit;

#####################################################################################################
############################################ Subroutines ############################################
#####################################################################################################

# subroutine to print help
sub help{
  
  print "\nrelabelPofZ.pl is a perl script developed by Steven Michael Mussmann\n\n";
  print "To report bugs send an email to mussmann\@email.uark.edu\n";
  print "When submitting bugs please include all input files, options used for the program, and all error messages that were printed to the screen\n\n";
  print "Program Options:\n";
  print "\t\t[ -h | -m | -n | -o | -p  ]\n\n";
  print "\t-h:\tDisplay this help message.\n";
  print "\t\tThe program will die after the help message is displayed.\n\n";
  print "\t-m:\tSpecify the name of a popmap file.\n";
  print "\t\tIndividuals must be listed in same order as aa-PofZ.txt file.\n\n";
  print "\t-n:\tSpecify the newhybrids genotype category file.\n";
  print	"\t\tGenotype categories should be in same order used to execute NewHybrids.\n\n";
  print "\t-o:\tSpecify output file (Optional).\n";
  print "\t-p:\tSpecify NewHybrids output (Default=aa-PofZ.txt).\n\n";
  
}

#####################################################################################################
# subroutine to parse the command line options

sub parsecom{ 
  
  my( $params ) =  @_;
  my %opts = %$params;
  
  # set default values for command line arguments
  my $map = $opts{m} || die "No popmap specified.\n\n"; #used to specify popmap file name.
  my $new = $opts{n} || "ThreeGensGtypFreq.txt"; #specify newhybrid genotype category file
  my $poz = $opts{p} || "aa-PofZ.txt"; #specify newhybrids output
  my $out = $opts{o} || "aa-PofZ.relabeled.txt"; #used to specify output file name.

  return( $map, $new, $poz, $out );

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
