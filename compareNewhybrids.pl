#!/usr/bin/perl

use warnings;
use strict;
use Cwd;
use File::Copy;
use Getopt::Std;
use Path::Class;
use Data::Dumper;

# kill program and print help if no command line arguments were given
#if( scalar( @ARGV ) == 0 ){
#  &help;
#  die "Exiting program because no command line options were used.\n\n";
#}

# take command line arguments
my %opts;
getopts( 'hp:', \%opts );

# if -h flag is used, or if no command line arguments were specified, kill program and print help
if( $opts{h} ){
  &help;
  die "Exiting program because help flag was used.\n\n";
}

# parse the command line
my( $poz ) = &parsecom( \%opts );

my $compDir = "run_comparison";

&makeDir( $compDir );

my $dir = getcwd;

my %classHash;
my %probHash;
my %agreeHash;

opendir( DIR, $dir ) or die "Can't open $dir: $!\n\n";
my @files = readdir( DIR );
closedir DIR;

foreach my $item( @files ){
	if( -d $item ){
		if( $item =~ /^run_\d+$/ ){
			#print $item, "\n";
			my $file = file( $item, $poz);
			if( -f $file ){
				#print $file, "\n";
				my @splitDir = split(/_/, $item);
				my $num = pop( @splitDir );
				my @splitFile = split( /\./, $poz );
				my $ext = pop( @splitFile );
				push( @splitFile, $num );
				push( @splitFile, $ext );
				my $newfile = join( ".", @splitFile );
				$newfile = file( $compDir, $newfile );
				copy( $file, $newfile ) or die "copy failed: $!\n\n";
			}
		}
	}
}

opendir( DIR, $compDir ) or die "Can't open $compDir: $!\n\n";
my @contents = readdir( DIR );
closedir DIR;

my @sorted = sort( @contents );
foreach my $item( @sorted ){
	if( $item =~ /^aa-PofZ\.relabeled\.\d+\.txt$/ ){
		my $file = file( $compDir, $item );
		if( -f $file ){
			#print $file, "\n";
			my @lines;
			&filetoarray( $file, \@lines );
			&compare( $item, \@lines, \%classHash, \%probHash, \%agreeHash );
		}
	}
}

my $outclass = "class.txt";
my $outprob = "prob.txt";
my $resultmap = "resultmap.txt";

open( CLASS, '>', $outclass ) or die "Can't open $outclass: $!\n\n";
#foreach my $ind( sort { $a <=> $b } keys %classHash ){
foreach my $ind( sort keys %classHash ){
	print CLASS $ind;
	foreach my $file( sort keys %{$classHash{$ind}} ){
		print CLASS "\t", $classHash{$ind}{$file};
	}
	print CLASS "\n";
}
close CLASS;

open( PROB, '>', $outprob ) or die "Can't open $outprob: $!\n\n";
#foreach my $ind( sort { $a <=> $b } keys %probHash ){
foreach my $ind( sort keys %probHash ){
	print PROB $ind;
	foreach my $file( sort keys %{$probHash{$ind}} ){
		print PROB "\t", $probHash{$ind}{$file};
	}
	print PROB "\n";
}
close PROB;

open( RESULTMAP, '>', $resultmap ) or die "Can't open $resultmap: $!\n\n";

#foreach my $ind( sort { $a <=> $b } keys %agreeHash ){
foreach my $ind( sort keys %agreeHash ){
	print RESULTMAP $ind;
	foreach my $class( sort keys %{$agreeHash{$ind}} ){
		print RESULTMAP "\t", $class;
	}
	print RESULTMAP "\n";
}

close RESULTMAP;

#print Dumper( \%agreeHash );

exit;

#####################################################################################################
############################################ Subroutines ############################################
#####################################################################################################

# subroutine to print help
sub help{
  
  print "\ncompareNewhybrids.pl is a perl script developed by Steven Michael Mussmann\n\n";
  print "To report bugs send an email to mussmann\@email.uark.edu\n";
  print "When submitting bugs please include all input files, options used for the program, and all error messages that were printed to the screen\n\n";
  print "Program Options:\n";
  print "\t\t[ -h | -p  ]\n\n";
  print "\t-h:\tDisplay this help message.\n";
  print "\t\tThe program will die after the help message is displayed.\n\n";
  print "\t-p:\tSpecify NewHybrids output (Default=aa-PofZ.relabeled.txt).\n\n";
  
}

#####################################################################################################
# subroutine to parse the command line options

sub parsecom{ 
  
  my( $params ) =  @_;
  my %opts = %$params;
  
  # set default values for command line arguments
  my $poz = $opts{p} || "aa-PofZ.relabeled.txt"; #specify newhybrids output

  return( $poz );

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
# subroutine to make a directory

sub makeDir{

  my( $dirname ) = @_;

  unless( -e $dirname or mkdir $dirname ){
		die "Unable to make $dirname: $!.\n\n";
  }

}

#####################################################################################################
#subroutine to compare results of multiple newhybrids runs

sub compare{

	my( $name, $linesref, $classHashref, $probHashref, $agreeHashref ) = @_;

	my $header = shift( @$linesref );
	my @headerArray = split( /\s+/, $header );
	shift( @headerArray );
	shift( @headerArray );

	foreach my $line( @$linesref ){
		#print $line, "\n";
		my @ind = split( /\s+/, $line );
		my $samplename = shift( @ind );
		my $samplepop = shift( @ind );

		my ( $prob, $class ) = &getBest( \@headerArray, \@ind );
		#print $samplename, "\t", $class, "\t", $prob, "\n";
		$$classHashref{$samplename}{$name} = $class;
		$$probHashref{$samplename}{$name} = $prob;
		$$agreeHashref{$samplename}{$class}++;
	}

}
#####################################################################################################
#subroutine to get best classification

sub getBest{

	my( $headerRef, $lineRef ) = @_;


	my $prob = 0.0;
	my $class = "none";
	for( my $i=0; $i<@$lineRef; $i++ ){
		if( $$lineRef[$i] > $prob ){
			$prob = $$lineRef[$i];
			$class = $$headerRef[$i];
		}
	}

	return($prob, $class);

}
#####################################################################################################
