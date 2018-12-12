#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use Pod::Usage;
use feature qw(say);
use Assignment4::MyIO qw (getFh);


########################################################################
# 
# File   :  intersection.pl
# History:  23-Oct-2018 (Jeremy) fully fleshed out program
#		           
########################################################################
#
# This program finds all the gene symbols that appear in both chr21_genes.txt and HUGO_genes.txt
#They are printed alphabetically into intersectionOutput.txt and prints the total # of gene symbols to STDOUT
########################################################################

my ($file1, $file2);  #fasta files to open with Chromosome 21 gene data and HUGO gene data, respectivly
my $outfile = 'OUTPUT/intersectionOutput.txt'; #output file 

my $usage = "\n$0 [options] \n

Options:

	-file1	open the chromosome 21 gene data (chr21_genes.txt)
	-file2 open the HUGO gene data (HUGO_genes.txt)
	-help	Show this message
";

#check the options
GetOptions(
	'file1=s'	=>\$file1,
	'file2=s'	=>\$file2,
	help		=>sub{pod2usage($usage);},
	)or pod2usage($usage);

#provide default files if no command line arguments given
unless ($file1){
	$file1 = 'chr21_genes.txt';
}
unless ($file2){
	$file2 = 'HUGO_genes.txt';
}

#get gene data file, gene category file, and open a file for reading using Assignment4::MyIO qw(getFh)
my $fhGeneData = getFh('<', $file1);
my $fhHUGO = getFh('<', $file2);
my $fhOut = getFh('>', $outfile);

#get arrays of gene symbols from both files using sub
my (@chr21Genes) = getGeneSymbols($fhGeneData);
my (@HUGOGenes) = getGeneSymbols($fhHUGO);


#turn chr21 genes into a temporary hash with all undefined values to be used in finding intersection
my %chr21Genes = map {$_ => undef} @chr21Genes;

#go through HUGO genes array and filter only those that are found in chr21Gene hash
 my @matchingGenes = grep(exists $chr21Genes{$_}, @HUGOGenes);

#print array to outfile with each element on a newline and sorted alphabetically
 print  $fhOut join("\n", sort @matchingGenes);

 say STDERR join(" ", "There were", scalar(@matchingGenes) , "common gene symbols found");




#############################Subroutines#######################################
#--------------------------------------------------------------------------------------
#scalar context getGeneSymbols($fh);
#--------------------------------------------------------------------------------------
#processes file handle, returning an array of the first column of data aka gene symbols
#--------------------------------------------------------------------------------------
sub getGeneSymbols{
	my ($filehandle) = @_;
	my @geneList; #ititialize array that will contain genes
	
	#split each line by tab so you can put the first column (genes) into the array
	while (<$filehandle>){
		chomp;
		my @columns = split /\t/;
		push @geneList, $columns[0];
	}

	#remove first element from array since it is the header and return array 
	shift @geneList;
	return @geneList;
}

