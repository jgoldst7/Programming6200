#!/usr/bin/perl
return 1 if ( caller() );
use warnings;
use strict;
use Getopt::Long;
use Pod::Usage;
use feature qw(say);

########################################################################
# 
# File   :  nucleotideStatisticsFromFasta.pl
# History:  7-Oct-2018 (Jeremy) wrote skeleton of all subs and completed first 4.
#		 :  8-Oct-2018 (Jeremy) finished the body of the program
#		 :  9-Oct-2018 (Jeremy) added the return 1 if (caller()) for testing and cleaned up sub layout
#		: 11-Oct-2018 (Jeremy) fixed NT counter to count number of Ns as any other nucleotide and die if its not one of those
#           
########################################################################
#
# This program takes opens a fasta file and returns the number of every type of nucleotide, 
#length of sequence, and %GC for each sequence
#
########################################################################

my $file2open;  #fasta file to open
my $file2write2 ; #text file to write stats to
my $usage = "\n$0 [options] \n

Options:

	-infile	Provide a fasta sequence file name to complete the stats on
	-outfile Provide a output file to put the stats into
	-help	Show this message
";

#check the options
GetOptions(
	'infile=s'	=>\$file2open,
	'outfile=s' =>\$file2write2,
	help		=>sub{pod2usage($usage);},
	)or pod2usage($usage);

#check they gave a file
unless ($file2open){
	die "\nDying...Make sure to provide a file name of a sequence in FASTA format \n",
	$usage;
}
unless ($file2write2){
	die "\nDying... Make sure to provide an outfile name for the stats\n",
	$usage;
}

#get infile and  initialize and get 2 outfiles from sub getFh all in scalar context
my $fhIn = getFh('<', $file2open);
my $fhOut = getFh('>', $file2write2);

#get 2 array back after checking they are same size
my ($refArrHeaders, $refArrSeqs) = getHeaderAndSequenceArrayRefs($fhIn);

#main sub, prints all stats into outfile
printSequenceStats($refArrHeaders, $refArrSeqs, $fhOut);

#close files
close $fhIn;
close $fhOut;


#############################Subroutines#######################################
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
 		die "The size of the seqeunce and the header arrays is different\n
 		Are you sure the FASTA is in correct format at",  
 		$!;
 	}else{
		return;
   	}
 }
#--------------------------------------------------------------------------------------



#--------------------------------------------------------------------------------------
#void context printSequenceStats($refArrHeaders, $refArrSeqs, $fhOut)
#--------------------------------------------------------------------------------------
#prints header line and stats(some found in further subs) to outfile. 
#--------------------------------------------------------------------------------------
sub printSequenceStats{
	my ($refArrHeaders, $refArrSeqs, $fhOut) = @_;
	say $fhOut join("\t", "Number", "Accession", "A's", "G's", "C's", "T's", "N's", "Length", "GC%");
	my $number = 1;
	my $header = 0;
	foreach my $seq(@$refArrSeqs){
		my $numAs = _getNtOccurence('A',  \$seq);
		my $numCs = _getNtOccurence('C',  \$seq);
		my $numGs = _getNtOccurence('G',  \$seq);
		my $numTs = _getNtOccurence('T',  \$seq);
		my $numNs = _getNtOccurence('N',  \$seq);
		my $accession = _getAccession(@$refArrHeaders[$header]);
		$accession = sprintf("%-10s", $accession); 
		my $GC = sprintf("%.1f", (($numGs + $numCs)/($numGs + $numCs + $numAs + $numTs + $numNs)) * 100);
		say $fhOut join("\t", $number, $accession, $numAs, $numGs, $numCs, $numTs, $numNs, length($seq), $GC);	
		$number++;
		$header++;
	}
}
#--------------------------------------------------------------------------------------




#--------------------------------------------------------------------------------------
#scalar context _getNtOccurence('A',  \$seq)
#--------------------------------------------------------------------------------------
#returns number of NT that was passed in found in sequence. dies if non-NT passed
#--------------------------------------------------------------------------------------
 sub _getNtOccurence{
 	my ($nucleotide, $seq) = @_;
 	my $count;
 	if ($nucleotide !~ /[AGCTN]/){
 		die say "dies on unknown $nucleotide character";
 	}
 	if ($nucleotide =~ /[AGCT]/){
 		$count = () = $$seq =~ /$nucleotide/g;
 	}elsif ($nucleotide =~ /N/){
 		$count = () = $$seq =~ /[BDEFHIJKLMNOPQRSUVWXYZ]/g
 	}
 	
 	return ($count);
 }
 
#--------------------------------------------------------------------------------------




#--------------------------------------------------------------------------------------
#scalar context _getAccession(@$refArrHeaders[$header])
#--------------------------------------------------------------------------------------
#returns accession from header (everything until the first space)
 sub _getAccession{
 	my ($header) = @_;
 	if ($header =~ /(\S+)/){
 		return ($1);
 	}
 }
#--------------------------------------------------------------------------------------