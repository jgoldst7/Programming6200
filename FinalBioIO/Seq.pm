#! /usr/bin/perl
package FinalBioIO::Seq;
use warnings;
use strict;
use feature qw(say);
use Carp qw( croak confess);
use FinalBioIO::MyIO qw(getFh);
use FinalBioIO::Config qw(getErrorString4WrongNumberArguments);
use feature qw(say);
use Moose;
use Moose::Util::TypeConstraints;
use MooseX::StrictConstructor;
use namespace::autoclean;
use Data::Dumper;

=head1 NAME

FinalBioIO::Seq

=head1 SYNOPSIS

Creation:
	my $fileNameOut = $output . '/' . $seqObj->accn . ".fasta"; #create an output name
   $seqObj->writeFasta( $fileNameOut);    # write the Fasta File
	
	

=head1 DESCRIPTION
OO package using Moose that contains a sequence with its relative info. 
Can write it to an outfile in fasta format, create a new instance with a restricted sequence,
check if a subsequence is contained within the sequence, and chekc if a sequence contains start/stop codons

=cut

has 'gi' => (
	isa		=> 'Int',
	is		=> 'rw',
	required => 1,	
 
);

has 'seq' => (
	isa		=> 'Str',
	is		=> 'rw',
	required => 1,	
 
);

has 'def' => (
	isa		=> 'Str',
	is		=> 'rw',
	required => 1,	
 
);

has 'accn' => (
	isa		=> 'Str',
	is		=> 'rw',
	required => 1,	
 
);

=head1 METHODS		

=head2 writeFasta

   Arg [2]    : receives self, along with a name for the outfile and the width of the sequence liens to print out

   Example    :  $seqObj->writeFasta($fileNameOut, $width)

   Description: write the seq object to fasta file, where $fileNameOut is the outfile and $width is 
	 the width of the sequence column (default 70 if none provided)

   Returntype : void

   Status     : Stable 
=cut

sub writeFasta{
	my $filledUsage = 'Usage: $self->writeFasta';
    # test the number of arguments passed in were correct (width argument is optional)
    (@_ == 2 or @_ == 3) or confess getErrorString4WrongNumberArguments() , $filledUsage;
	
	my ($self, $outfile, $width) = @_;
	#say $outfile;
    
    #default width of 70 if none provided
    unless (defined $width){
    	$width = 70;
    }

    #get filehandle and print sequence and header to outfile
    my $fhOut = getFh( '>', $outfile );
    say $fhOut join("|", ">gi", $self->gi, "ref", $self->accn, $self->def); #header
    
    for my $line ($self->seq =~ m/.{1,$width}/gs) { #print sequence with specified width
    say $fhOut $line;
}

 }

=head2 subSeq

	Arg[2] : self, beginning and end of cut site

	Example; scalar context: my $newSeqObj = $seqObj->subSeq($begin, $end)

	Description: subSeq receives the beginning and the ending sites, and returns a new FinalBioIO::Seq object
 	between the sites (inclusive, sites are bio-friendly num). 

	ReturnType: scalar seq object

	Status: Stable

=cut

sub subSeq{
	my $filledUsage = 'Usage: $self->writeFasta';
    # test the number of arguments passed in were correct 
    @_ == 3 or confess getErrorString4WrongNumberArguments() , $filledUsage;

    my ($self, $begin, $end) =  @_;
    
    #check if begin and end are defined
   unless (defined $begin and defined $end){
    	confess "no valid beginning/ending site given";
    }


    my $cutLength = ($end - $begin + 1); # +1 to get right length
    
 
    #find sequence and its length
    my $seq = $self->seq; #sequence 
	my $sequenceLength = length($seq);

	#check that cut is within sequence
	if ($end > $sequenceLength){
		confess "cannot subseq outside the scope of the sequence";
	} 

	#get shorter sequence
	my $shortSeq = substr($seq, ($begin - 1), $cutLength);
	
	#contruct new seq obj with shortened sequence
	my $seqObjShort = FinalBioIO::Seq->new( gi =>$self->gi,
											def=>$self->def,
											accn=>$self->accn,
											seq =>$shortSeq,
										);
	return ($seqObjShort);
}


=head2 checkCoding

	Arg[0] : none, but receives self

	Example; my $isCoding = $seqObj->checkCoding()

	Description: checkCoding check if a seq starts with ATG codon, and ends with a stop codon,
 i.e., TAA, TAG, or TGA

	ReturnType: scalar (bool = 1 or return)

	Status: Stab;e

=cut

sub checkCoding{
	my $filledUsage = 'Usage: $self->writeFasta';
    # test the number of arguments passed in were correct 
    @_ == 1 or confess getErrorString4WrongNumberArguments() , $filledUsage;

    my ($self) =  @_;

    my $seq = $self->seq; 

    #check if first codon is a start codon and last is a stop codon
    if ($seq =~ /^ATG.+TAA|TAG|TGA$/){
		return 1; #will return true
	}
	else{ 
		return; #will return false
	}
}



=head2 checkCutSite

	Arg[2] : self, and a shorter sequence to check against

	Example; my ($pos, $seqFound) = $seqObj->checkCutSite( 'GGATCC' );

	Description: checkCutSite receives a  site pattern. It searches the
 seq, and determine the location of cutting site, and returns the position and the sequence
 that matched.

	ReturnType: 2 scalar variables, position of where the match starts, and the match

	Status: Stable

=cut

sub checkCutSite{
	my $filledUsage = 'Usage: $self->writeFasta';
    # test the number of arguments passed in were correct 
    @_ == 2 or confess getErrorString4WrongNumberArguments() , $filledUsage;

    my ($self, $cutSite) =  @_;

    if ($self->seq =~/$cutSite/){
    	#where match started (+ 1 to make it biology friendly)
    	my $pos = (length $`) + 1;
    	my $seq = $&; #actual match
    	return ($pos, $seq);
    }
   	else{
   		return; #will return false and so return variables will be undef
   }
}

__PACKAGE__->meta->make_immutable;
1;