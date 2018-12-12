#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use Pod::Usage;
use feature qw(say);
use Carp qw( confess );
use BioIO::MyIO qw (makeOutputDir);
use Data::Dumper;
use BioIO::Config qw(getErrorString4WrongNumberArguments);
use BioIO::MooseKinases;

########################################################################
# 
# File   :  kinaseMooseMap2.pl
# History:  29-Nov-2018 (jeremy completed)
#			 
#		           
########################################################################
# This program  is a modification of kinaseMooseMap1.pl, it prints a copy of the oroiginal object
# and prints that by filtering on nothing. It also has the ability to print only tyrosine
# kinase genes (i.e. only where the gene name contains the word tyrosine), 
# 
########################################################################

#### global variables
my $fileInName  = 'INPUT/kinases_map';    # default input
my $fileOutName = 'OUTPUT/output1_2moose.txt'; # default output
my ($kinase1, $kinase2); # store the object later

my $usage = "\n$0 [options] \n

Options:

	-fileIn       kinase file name
    -fileOut      output file name
	-help	Show this message
\n\n";

#check the options
GetOptions(
	'fileIn=s'    => \$fileInName,
    'fileOut=s'   => \$fileOutName,
	help		=>sub{pod2usage($usage);},
	)or pod2usage($usage);

makeOutputDir('OUTPUT');

# create kinase object
$kinase1 = BioIO::MooseKinases->new(filename => $fileInName);

#create a copy of the object
#$kinase2 = $kinase1->filterKinases({});

# Could also do the following
$kinase2 = $kinase1->filterKinases({name=>'tyrosine', symbol=>'EPLG4'});

#print object to outfile
$kinase2->printKinases($fileOutName, ['symbol','name','location', 'omim_accession']);
say STDERR "Output printed to " , $fileOutName;
