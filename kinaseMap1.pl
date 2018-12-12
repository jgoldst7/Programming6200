#! /usr/bin/perl
use warnings;
use strict;
use Getopt::Long;    #command line flags!
use Pod::Usage;      #command line flags!
use Data::Dumper;
use BioIO::MyIO qw( makeOutputDir);
use BioIO::Kinases;

################################################################################
# File   : kinaseMap1.pl
# Author : Jeremy Goldstein
# Created: 26-Noc-2018
#
################################################################################
# kinaseMap1.pl reads kinase_map or similar formated file, and prints the gene
# symbol, gene name and cytogenetic location, in a tab-delimited format.
################################################################################

#### global variables
my $fileInName  = 'INPUT/kinases_map';    # default input
my $fileOutName = 'OUTPUT/output1_1.txt'; # default output
my $kinaseObj;

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
$kinaseObj = BioIO::Kinases->new($fileInName);
# print kinase by 3 fields
$kinaseObj->printKinases($fileOutName, ['symbol','name','location'] );
say STDERR "Output printed to " , $fileOutName;
# I could also use the following with the implementation
#$kinaseObj->printKinases($fileOutName, ['date', 'symbol', 'omim_accession'] );