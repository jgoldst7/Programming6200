#! /usr/bin/perl
use warnings;
use strict;
use Getopt::Long;    #command line flags!
use Pod::Usage;      #command line flags!
use Data::Dumper;
use BioIO::MyIO qw( makeOutputDir);
use BioIO::Kinases;

################################################################################
# File   : kinaseMap2.pl
# Author : Jeremy Goldstein
# Created: 26-Nov-2018

################################################################################
# kinaseMap2.pl is a modification of kinaseMap1.pl, it prints only tyrosine 
# kinase genes (i.e. only where the gene name contains the word tyrosine), 
################################################################################

#### global variables
my $fileInName  = 'INPUT/kinases_map';    # default input
my $fileOutName = 'OUTPUT/output1_2.txt'; # default output
my ($kinase1, $kinase2); # store the object later

#### CLI flags
my $usage = "\n$0 [options]\n\n

Options:

    -fileIn       kinase file name
    -fileOut      output file name
    -help         display this message

        
\n\n";

GetOptions(
    'fileIn=s'    => \$fileInName,
    'fileOut=s'   => \$fileOutName,
    help            => sub { pod2usage($usage); }
) or pod2usage(2);    # exit status if something goes wrong

makeOutputDir('OUTPUT');
# create kinase object
$kinase1 = BioIO::Kinases->new($fileInName);
$kinase2 = $kinase1->filterKinases({});
# Could also do the following
#$kinase2 = $kinase1->filterKinases({name=>'tyrosine', symbol=>'EPLG4'});
$kinase2->printKinases($fileOutName, ['symbol','name','location', 'omim_accession']);
say STDERR "Output printed to " , $fileOutName;
