#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use Pod::Usage;
use feature qw(say);
use Assignment4::MyIO qw (getFh);
use Data::Dumper;


########################################################################
# 
# File   :  categories.pl
# History:  23-Oct-2018 (Jeremy) Created program
#		 :	24-Oct-2018 (Jeremy) added defaults if no commans line arguments given
#		           
########################################################################
#
# This program counts how many genes are in each category based on the data from chr21_genes.txt.
#It prints the results in ascending order to an output file (categories.txt). 
#It adds what each catgeory represents with info from chr21_genes_categories.txt, ignoring the gene with no cateogry info
########################################################################

my ($file1, $file2);  #fasta files to open with gene data and category data, respectivly
my $outfile = 'OUTPUT/categories.txt'; #output file 

my $usage = "\n$0 [options] \n

Options:

	-file1	open the chromosome 21 gene data (chr21_genes.txt)
	-file2 open the chromose 21 gene category data (chr21_genes_categories.txt)
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
	$file2 = 'chr21_genes_categories.txt';
}




#get gene data file, gene category file, and open a file for reading using Assignment4::MyIO qw(getFh)
my $fhData = getFh('<', $file1);
my $fhCategory = getFh('<', $file2);
my $fhOut = getFh('>', $outfile);

#initialize hash
my %categories;

#Turn chr21_genes_categories.txt into a hash with category as key  and description as value
while (<$fhCategory>){
	chomp;
	my @columns = split /\t/;
	my $category = $columns[0];
	my $description = $columns[1];
	$categories{$category} = $description;
}

#initialize hash
my %count;

#Turn chr21_genes.txt into a hash with category as key, count of number of occurences of category as value
while (<$fhData>){
	chomp;
	#Don't process header line or the gene without category info
	if ($_ =~ /Category|KAPcluster/) {
		next};
	my @columns = split /\t/;
	my $category = $columns[2];
	if (exists $count{$category}){
		$count{$category}++;
	}
	else{
		$count{$category} = 1;
	}
}



#print header for outfile
say $fhOut join("\t", "Category", "Occurance", "Definition");

#print key and value for %count and value of that same key for %cateogires to get each line for output file
foreach  (sort keys %count){
	#format each variable and give it a better name
	my $category = sprintf("%-10s", $_);
	my $occurance = sprintf("%-10s", $count{$_});
	my $definition = sprintf("%-10s", $categories{$_});
	
	say $fhOut join("\t", $category, $occurance, $definition);
}







