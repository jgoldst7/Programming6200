#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use Pod::Usage;
use feature qw(say);
use Carp qw( confess );
use BioIO::MyIO qw ( makeOutputDir);
use Data::Dumper;
use BioIO::MooseKinases;

########################################################################
# 
# File   :  kinaseMooseMap1.pl
# History:  26-Nov-2018 (jeremy completed)
#		           
########################################################################
# This program reads kinase_map or similar file and prints the gene symbol,
# gene name, and cyogenetic location in a tab-dilineated format. 
# However, it has the ability to print any values to the output file.
########################################################################

#global variables
my $fileInName  = './INPUT/kinases_map';    # default input
my $fileOutName = './OUTPUT/output1_1moose.txt'; # default output
my $kinaseObj;

#CL flags
my $usage = "\n$0 [options] \n

Options:

	-fileIn		kinase file name
	-fileOut 	output file name 
	-help	Show this message
/n/n";

#check the options
GetOptions(
	'fileIn=s'	=>\$fileInName,
	'fileOut=s'	=>\$fileOutName,
	help		=>sub{ pod2usage($usage); },
	)or pod2usage($usage);

makeOutputDir('OUTPUT');


#create kinase object
$kinaseObj = BioIO::MooseKinases->new(filename =>$fileInName);

#print kinase by 3 fields
$kinaseObj->printKinases($fileOutName, ['symbol','name','location'] );
say STDERR "Output printed to " , $fileOutName;

# I could also use the following with the implementation
#$kinaseObj->printKinases($fileOutName, ['date', 'symbol', 'omim_accession'] );