#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use Pod::Usage;
use feature qw(say);
use Carp qw( confess );
use FinalBioIO::MyIO qw( makeOutputDir );
use FinalBioIO::SeqIO;
use FinalBioIO::Seq;
use Data::Dumper;

########################################################################
# 
# File   :  genBank2Fasta.pl
# History:  5-Dec-2018 
#		           
########################################################################
# This program reads a genBank file and prints the sequence out into Fasta format
########################################################################

#global variables
my $fileInName  = './INPUT/genbank_seq';    # default input
my $output = './OUTPUT'; # default output
my $seqIoObj;
makeOutputDir('OUTPUT'); #make output directory

#CL flags
my $usage = "\n$0 [options] \n

Options:

	-fileIn		genbank file name
	-help	Show this message
/n/n";

#check the options
GetOptions(
	'fileIn=s'	=>\$fileInName,
	help		=>sub{ pod2usage($usage); },
	)or pod2usage($usage);



$seqIoObj = FinalBioIO::SeqIO->new(filename => $fileInName, fileType => 'genbank'); # object creation


# go thru SeqIO obj and print all seq in fasta format
 while ( my $seqObj = $seqIoObj->nextSeq() ) {
    my $fileNameOut = $output . '/' . $seqObj->accn . ".fasta"; #create an output name
    $seqObj->writeFasta( $fileNameOut);  # write the Fasta File
    }  

