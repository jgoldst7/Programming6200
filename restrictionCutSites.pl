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
# File   :  restrictionCutSites.pl
# History:  5-Dec-2018 
#		           
########################################################################
# This program reads a FASTA file and locates restriction cut sites, cloning the genomic region for the p54 gene
########################################################################

#global variables
my $fileInName  = './INPUT/p53_seq';    # default input
my $output = './OUTPUT'; # default output
my $seqIoObj;
my $seqObjLong;
my ( $begin, $end ) = ( 11717, 18680 ); # bio-friendly num of cut site
makeOutputDir('OUTPUT'); #make output directory

#CL flags
my $usage = "\n$0 [options] \n

Options:
	-cutStart start of cut site
	-cutEnd end of cut site
	-fileIn		genbank file name
	-help	Show this message
/n/n";

#check the options
GetOptions(
	'cutStart=i'=>\$begin,
	'cutEnd=i'=>\$end,
	'fileIn=s'	=>\$fileInName,
	help		=>sub{ pod2usage($usage); },
	)or pod2usage($usage);





$seqIoObj = FinalBioIO::SeqIO->new(filename => $fileInName, fileType => 'fasta'); # object creation



# loop through all seqs in $seqIoObj
while ( $seqObjLong = $seqIoObj->nextSeq() ) {
     say "The gene, gi", $seqObjLong->gi, ":";
     my $seqObjShort = $seqObjLong->subSeq($begin, $end );    # sub sequence
     #print Dumper $seqObjShort;
    
#     # check if the coding seq is valid
    if( $seqObjShort->checkCoding()) {
    	say "The sequence starts with ATG start codon and ends with Stop codon";
    }
    else{
       say "not a valid coding sequence";
    }
    
#     # check the cutting sites
      my ($pos, $sequence) = $seqObjShort->checkCutSite( 'GGATCC' ); #BamH1
      printResults($pos, $sequence, $seqObjShort, 'BamH1'); # you should implement the printResults subroutine

       ($pos, $sequence) = $seqObjShort->checkCutSite( 'CG[AG][CT]CG' ); #BsiEI
      printResults($pos, $sequence, $seqObjShort, 'BamH1'); # you should implement the printResults subroutine

       ($pos, $sequence) = $seqObjShort->checkCutSite( 'GAC\w{6}GTC' ); #DrdI
       say join(" ", "Found drdI cut site as position", "$pos", "of the coding region, here is the sequence", "$sequence");


#     .. #you can figure this out...
#     .. #you can figure this out...
 }


#############################Subroutines#######################################
#--------------------------------------------------------------------------------------
#void context printResults($pos, $sequence, $seqObjShort, 'BamH1')
#--------------------------------------------------------------------------------------
#receives four arguments: 1) the starting position of the cutsite match
#						  2) the cutsite match
#						  3) the seq object it matched
#						  4) the enzyme the cute is a aprt of
#--------------------------------------------------------------------------------------
#prints where a cutsite has been found to the user
#--------------------------------------------------------------------------------------
 sub printResults{
 	my $filledUsage = 'Usage: $self->writeFasta';
    # test the number of arguments passed in were correct 
    @_ == 4 or confess getErrorString4WrongNumberArguments() , $filledUsage;

    my ($pos, $sequence, $seqObj, $enzyme) =  @_;

    if (defined $pos and defined $sequence){ #would do nothing if cute wasn't found in checkCutSite
    	say join(" ", "Found", "$enzyme", "cut site as position", "$pos", "of the coding region"); 
    }
  }
  #--------------------------------------------------------------------------------------