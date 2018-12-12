#! /usr/bin/perl
package FinalBioIO::SeqIO;
use warnings;
use strict;
use feature qw(say);
use Carp qw( croak confess);
use FinalBioIO::MyIO qw(getFh);
use FinalBioIO::Config qw(getErrorString4WrongNumberArguments);
use FinalBioIO::Seq qw(writeFasta);
use feature qw(say);
use Moose;
use Moose::Util::TypeConstraints;
use MooseX::StrictConstructor;
use namespace::autoclean;
use Data::Dumper;


=head1 NAME

FinalBioIO::SeqIO

=head1 SYNOPSIS

Creation:
	#create kinase object
	$seqIoObj = FinalBioIO::SeqIO->new(filename => $fileInName, fileType => 'genbank');
	
	while ( $seqObj = $seqIoObj->nextSeq() ) {
   my $fileNameOut = $output . '/' . $seqObj->accn . ".fasta"; #create an output name
   $seqObj->writeFasta( $fileNameOut);    # write the Fasta File

=head1 DESCRIPTION

OO package using Moose to bring in a Genbank/Fasta file, store each seqeunce with its header information as an object,
and be able to store each individual sequence as a Seq object 
	

=cut

has '_gi' => (
	isa		=> 'ArrayRef',
	is		=> 'ro',
	writer 	=> '_writer_gi',
	init_arg=> undef,	
 
);

has '_seq' => (
	isa		=> 'HashRef',
	is		=> 'ro',
	writer 	=> '_writer_seq',
	init_arg=> undef,	

);

has '_def' => (
	isa		=> 'HashRef',
	is		=> 'ro',
	writer 	=> '_writer_def',
	init_arg=> undef,	

);

has '_accn' => (
	isa		=> 'HashRef',
	is		=> 'ro',
	writer 	=> '_writer_accn',	
	init_arg=> undef,

);

has '_current' => (
	isa		=> 'Int',
	is		=> 'ro',
	writer 	=> '_writer_current',	
	init_arg=> undef,
	default => 0,

);

has 'filename' => (
	isa		=> 'Str',
  is		=> 'ro',
  required  => 1,
);

#makes sure the file passed in is only in genbank or fasta format
subtype 'FileType',
	as 'Str',
	where {$_ eq 'fasta' or $_ eq 'genbank'},
	message {"$_ is not fasta/genbank"};

has 'fileType' => (
	isa		=> 'FileType',
	is		=> 'ro',
	required => 1,

);


#uses the correct method to build object depending on what filetype is is
sub BUILD {
  my ($self) = @_;
  if ($self->filename){
  	if ($self->fileType eq 'genbank'){
   		my ($refArrGis, $refHashAccns, $refHashDefs, $refHashSeqs) = $self->_getGenbankSeqs;

   		$self->_writer_gi($refArrGis);
   		$self->_writer_accn($refHashAccns);
   		$self->_writer_def($refHashDefs);
   		$self->_writer_seq($refHashSeqs);
   
   	}
  	elsif ($self->fileType eq 'fasta'){
    	my ($refArrGis, $refHashAccns, $refHashDefs, $refHashSeqs) = $self->_getFastaSeqs;
    	$self->_writer_gi($refArrGis);
   		$self->_writer_accn($refHashAccns);
   		$self->_writer_def($refHashDefs);
   		$self->_writer_seq($refHashSeqs);
    }
  }
}


=head1 METHODS		

=head2 _getGenbankSeqs

   Arg [0]    : None, but receives self

   Example    : my ($refArrGis, $refHashAccns, $refHashDefs, $refHashSeqs) = $self->_getGenbankSeqs;

   Description: read seqs and info, and fills in the SeqIO attributes 
 	with _gi, _accn, _def and _seq attributes created

   Returntype : scalar refs of each private attribute

   Status     : Stable 
=cut

sub _getGenbankSeqs{
	my $filledUsage = 'Usage: $self->_getGenbankSeqs';
    # test the number of arguments passed in were correct 
    @_ == 1 or confess getErrorString4WrongNumberArguments() , $filledUsage;

    #declre data structures 
    my $refArrGis = [];
	my ($refHashAccns, $refHashDefs, $refHashSeqs) = {};
	my $gi;

	#get filehandle from filename passed in
	 my ($self) = @_;
    my $fileInName = $self->filename;
    my $fhIn = getFh( '<', $fileInName );

	 $/ = "//\n"; # set the file delimiter to the record separator for a GenBank file
	while (my $genbankData = <$fhIn>){
		chomp $genbankData; 
		
		#pull gis and add to refArray
		if($genbankData =~ /\s+GI:(\d*)\s+/){
			$gi = $1;
			push @$refArrGis, $gi;
		}
		#pull accs and add to ref Hash
		if($genbankData =~ /VERSION\s+(\S+)/g){
			my $acc = $1;
			$refHashAccns->{$gi} = $acc;
		}
		#pull defs and add to ref Hash
		if($genbankData =~ /DEFINITION\s+(.*)ACCESSION/s){
			my $definition = $1;
			$definition =~ s/ +/ /g; #get rid of newline characters, periods, and multiple spaces
			$definition =~ s/\.\n//g;
			$refHashDefs->{$gi} = $definition;
		}
		#pull seqs and add to ref hash
		if ($genbankData =~ /ORIGIN(.*)/s){
		my $seq = $1;
		$seq =~ s/[\s\d]//g; #get rid of digits, space and newline characters and uppercase sequence
		$seq = uc($seq);
		$refHashSeqs->{$gi} = $seq;
		 
		}
	}
	return ($refArrGis, $refHashAccns, $refHashDefs, $refHashSeqs);
}

=head2 _getFastaSeqs

   Arg [0]    : None, but receives self

   Example    : my ($refArrGis, $refHashAccns, $refHashDefs, $refHashSeqs) = $self->_getFastaSeqs;

   Description: read seqs and info, and fills in the SeqIO attributes 
 	with _gi, _accn, _def and _seq attributes created

   Returntype : scalar ref of all private attributes

   Status     : Stable 
=cut
sub _getFastaSeqs{
	my $filledUsage = 'Usage: $self->_getGenbankSeqs';
    # test the number of arguments passed in were correct 
    @_ == 1 or confess getErrorString4WrongNumberArguments() , $filledUsage;

    #declare data structures 
    my $refArrGis = [];
	my ($refHashAccns, $refHashDefs, $refHashSeqs) = {};

	#get filehandle from filename passed in
	my ($self) = @_;
    my $fileInName = $self->filename;
    my $fhIn = getFh( '<', $fileInName );

  
    local $/ = ">"; # set the file delimiter to the record separator for a GenBank file
    while ( <$fhIn>){
		chomp; 
		my $fastaData = $_;
		#print $fastaData;
		if( $fastaData =~ s/gi\|(.+)\|.+\|(.+)\|(.+)\n//){; #grab header attributes and get rid of header so only sequence left in variable
			
			#pull gis and add to refArray
			my $gi = $1; 
			push @$refArrGis, $gi;
			
			#pull accs and add to ref Hash
			my $acc = $2;
			$refHashAccns->{$gi} = $acc;

			#pull defs and add to ref Hash
			my $def = $3;
			$def =~ s/\.//g; #get rid of periods
			$refHashDefs->{$gi} = $def;

			#pull seqs and add to ref hash
			$fastaData =~ s/[\n\s]//g; #get rid of newlines and whitepace
			my $seq = $fastaData;
			$refHashSeqs->{$gi} = $seq;	
		}
	}
	return ($refArrGis, $refHashAccns, $refHashDefs, $refHashSeqs);

}


=head2 nextSeq

   Arg [0]    : None, but receives self

   Example    : while ( $seqObj = $seqIoObj->nextSeq() ) {
   my $fileNameOut = $output . '/' . $seqObj->accn . ".fasta"; #create an output name

   Description: creates a seq object out of each individual sequence in teh seqIO object

   Returntype : scalar seq object

   Status     : Stable 
=cut

sub nextSeq{
	my $filledUsage = 'Usage: $self->nextSeq';
    # test the number of arguments passed in were correct 
    @_ == 1 or confess getErrorString4WrongNumberArguments() , $filledUsage;
	my ($self) = (@_);

	#get all private attributes
	my $refArrGis = $self->_gi;
	my $refHashAccns = $self->_accn;
	my $refHashDefs = $self->_def;
	my $refHashSeqs = $self->_seq;
	
	
	my $current = $self->_current; #current will give the number sequence you are on in the seqIO object
	
	#if there is a gi left in the array then create a seq object, increment current
	while (my $gi = shift @$refArrGis){
		if (exists $refHashSeqs->{$gi}){
			$current++;
			$self->_writer_current($current);

			my $seqObj = FinalBioIO::Seq->new( 	gi =>$gi,
												accn=> $refHashAccns->{$gi},
												def=> $refHashDefs->{$gi},
												seq=>$refHashSeqs->{$gi} 
												);
			return $seqObj;
			
		}
		else{
		return undef; #once you run out of gis, and consequently sequences
		}
	}
}



__PACKAGE__->meta->make_immutable;
1;