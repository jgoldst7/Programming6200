#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use Pod::Usage;
use feature qw(say);
use Assignment4::MyIO qw (getFh);


########################################################################
# 
# File   :  chr21GeneNames.pl
# History:  23-Oct-2018 (Jeremy) creates program in working order
#		 :	24-Oct-2018 (Jeremy) added defaults if no command line arguments provided
#		           
########################################################################
#
# This program asks the user to enter a gene symbol and then prints the description for
# that gene based on data from the chr21_genes.txt file. It gives the user an error if 
# they enter a symbol not found in the table and continues to ask the user for genes until quit is given
########################################################################

my $file;  #fasta file to open

my $usage = "\n$0 [options] \n

Options:

	-file	open the chromosome 21 gene data (chr21_genes.txt)
	-help	Show this message
";

#check the options
GetOptions(
	'file=s'	=>\$file,
	help		=>sub{pod2usage($usage);},
	)or pod2usage($usage);

#provide default file if no command line arguments given
unless ($file){
	$file = 'chr21_genes.txt';
}



#get file using Asignment4::MyIO qw(getFh)
my $fH = getFh('<', $file);

#initialize hash
my %geneSymbols;

#process file, after passing over header line stores each symbol/description as key value pair in %geneSymbols
while (<$fH>){
	chomp;
	#don't process header line
	if ($_ =~ /Gene Symbol/){
		next;
	}
	#put gene symbol and description pair into hash after splitting on tab
	my @columns = split /\t/;
	$geneSymbols{$columns[0]} = $columns[1];
}




#infinite loop with user prompt unless they enter quit or their symbol isnt found in the table
while (1){
	print  "\nEnter gene name of interest. Type quit to exit:	";
	my $geneName = <STDIN>;
	chomp $geneName;
	#uppercase genename so that case is not a factor
	$geneName = uc $geneName;
	
	if ($geneName eq "QUIT"){
		exit;
	}elsif (exists ($geneSymbols{$geneName})){
		say "\n", "$geneName ", "found! Here is the description:"; 
		say "$geneSymbols{$geneName}", "\n";
		
	}else{
		say "Your gene name is not found in the file, try another...";
	}
}





