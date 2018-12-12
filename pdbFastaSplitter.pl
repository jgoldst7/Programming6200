#!/usr/bin/perl
return 1 if ( caller() );
use warnings;
use strict;
use Getopt::Long;
use Pod::Usage;
use feature qw(say);

########################################################################
# 
# File   :  pdbFastaSplitter.pl
# History:  7-Oct-2018 (Jeremy) created the majority of the program
#			9-Oct-2018 (Jeremy) added the return 1 if (caller()) for testing and cleaned up sub layout
#           
########################################################################
#
# This program takes opens a fasta file that has both protein sequences and secondary structure information
# It raises appropriate erros if file isnt given.
# It puts these 2 different type of information into 2 different outfiles, pdbProtein.fasta and pdbSS.fasta
# It also returns to user the number of sequences in both files.
# 
########################################################################


my $file2open;  #fasta file to open
my $protein_file_2_write_2 = 'pdbProtein.fasta'; #fasta file 2 write proteins
my $structure_file_2_write_2= 'pdbSS.fasta'; #fasta file 2 write SS
my $usage = "\n$0 [options] \n

Options:

	-infile	Provide a fasta sequence file name to do the splitting on, this file contains
              	two entries for each sequence, one with the protein sequence data, and one with  
              	the SS information
	-help	Show this message
";

#check the options
GetOptions(
	'infile=s'	=>\$file2open,
	help		=>sub{pod2usage($usage);},
	)or pod2usage($usage);

#check they gave a file
unless ($file2open){
	die "\nDying...Make sure to provide a file name of a sequence in FASTA format \n",
	$usage;
	}

#open infile and 2 outfiles
my $fhIn = getFh('<', $file2open);
my $fhOut_protein = getFh('>', $protein_file_2_write_2);
my $fhOut_structure = getFh('>', $structure_file_2_write_2);

#Get references to array of headers and sequences form infile
my ($refArrHeaders, $refArrSeqs) = getHeaderAndSequenceArrayRefs($fhIn) ;

#Process the 2 arrays and  if header matches seqeunce print to protein outfile, otherwise print to SS outfile	
 my $i = 0;
 my $SS_number = 0;
 my $protein_number = 0;
 foreach my $header (@$refArrHeaders){
	if ($header =~ /sequence/){
	 print $fhOut_protein ">$header\n"; 
	 print $fhOut_protein "@$refArrSeqs[$i]";
	 $protein_number++;
	}else{
		print $fhOut_structure ">$header\n";
	 	print $fhOut_structure "@$refArrSeqs[$i]";
 		$SS_number++; 	
  	}
  $i++;	
 }

 #close files
close $fhOut_structure;
close $fhOut_protein;
close $fhIn;
 
 #tell user how many sequences are in each file
print STDERR "Found $protein_number protein sequences\nFound $SS_number ss sequences\n";




#############################Subroutines#######################################
#--------------------------------------------------------------------------------------
# list context getHeaderAndSequenceArrayRefs($fhIn)
#--------------------------------------------------------------------------------------
# returns headers to @header and sequences to @seq after passing through -checkSizeOfArrRefs 
#--------------------------------------------------------------------------------------
sub getHeaderAndSequenceArrayRefs{
	my ($fhIn) = @_;
	my (@header, @seq);
	$/ = ">";
	 while (<$fhIn>){
	 	chomp;
		 if ($_ =~ /(.+)/){
		  	push (@header, $1);
		  	$_ =~ s/.+\n//;
		  	if ($_ !~ /^\s*$/){ 
		  		push (@seq, $_);
			}
		}
	 }
	 _checkSizeOfArrRefs(\@header, \@seq);
	return (\@header, \@seq);
}
#--------------------------------------------------------------------------------------



#--------------------------------------------------------------------------------------
# void context _checkSizeOfArrRefs(\@header, \@seq)
#--------------------------------------------------------------------------------------
#dies if arrays arent the same size and returns if they are
#--------------------------------------------------------------------------------------
 sub _checkSizeOfArrRefs{
 	my ($refArrHeaders, $refArrSeqs) = @_;
	if (scalar(@$refArrHeaders) != scalar(@$refArrSeqs)){
 		die "The size of the seqeunce and the header arrays is different\nAre you sure the FASTA is in correct format";
 	}else{
		return;
   	}
 }
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------
#scalar context getFh('<', $file2open);
#--------------------------------------------------------------------------------------
#opens file for reading/writing, notifying user if that fails or the wrong read/write symbol was passed
#--------------------------------------------------------------------------------------
sub getFh{
	my ($read_or_write, $Fh) = @_;
	if ($read_or_write !~ /<|>/) {
		die "\n Read or write symbol was not passed into subroutine\n";
	}  
	my $file_2_read_or_write;
	unless(open ($file_2_read_or_write, $read_or_write, $Fh)){
		die "Can't open ", $Fh, " for reading/writing: \n", $usage, "\n", $!;
	}
	return ($file_2_read_or_write);
}
#--------------------------------------------------------------------------------------
