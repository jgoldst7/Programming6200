#! /usr/bin/perl
package BioIO::MooseKinases;
use warnings;
use strict;
use feature qw(say);
use Carp qw( croak confess);
use BioIO::MyIO qw(getFh);
use BioIO::Config qw(getErrorString4WrongNumberArguments);
use feature qw(say);
use Moose;
use Moose::Util::TypeConstraints;
use MooseX::StrictConstructor;
use namespace::autoclean;


# just naming some attributes, b/c they are used in multiple places
my $aohAttribute        = '_aoh';
my $numKinasesAttribute = '_numberOfKinases';
my $class = 'BioIO::MooseKinases';

=head1 NAME

BioIO::MooseKinases

=head1 SYNOPSIS

Creation:
	#create kinase object
	my $kinaseObj = BioIO::MooseKinases->new($fileInName);

	#print kinase by 3 fields
	$kinaseObj->printKinases( $fileOutName, ['symbol', 'name', 'location'] );

=head1 DESCRIPTION

OO package using Moose to read each line in the kinase file, store each line in a hash,
and store each hash in an array, which will be the object
	

=cut

has '_aoh' => (
	isa		=> 'ArrayRef',
	is		=> 'ro',
	reader	=> 'getAoh',
	writer 	=> '_writer_aoh',	
 
);

has '_numberOfKinases' => (
	isa		=> 'Int',
	is		=> 'ro',
	reader	=> 'getNumberOfKinases',
	writer 	=> '_writer_numberOfKinases',	

);

has 'filename' => (
	isa		=> 'Str',
  is		=> 'ro',
);

sub BUILD {
  my ($self) = @_;
  if ($self->filename){
    my $refArr = $self->_readKinases;
    $self->_writer_aoh( $refArr );
    $self->_writer_numberOfKinases( scalar @$refArr);
  }
  else{
    return;
    #was created with filteredKinases and so already has it's attributes made without needing to read in a file
  }
}


=head1 METHODS		

=head2 _readKinases

   Arg [0]    : None, but receives self

   Example    : my $refArr = $self->_readKinases();

   Description: _readKinases recieves a filename and then build the internal data structure to be returned as a AoH

   Returntype : scalar

   Status     : Stable 
=cut

sub _readKinases{
	 my $filledUsage = 'Usage: $self->_readKinases()';
    # test the number of arguments passed in were correct 
    @_ == 1 or confess getErrorString4WrongNumberArguments() , $filledUsage;
    
    #get filehandle from object
    my ($self) = @_;
    my $fileInName = $self->filename;
    my $fhIn = getFh( '<', $fileInName );
   
    my $refArr = [];
    while (<$fhIn>) {
        chomp;
        /^(.*?)\|(.*?)\|(.*?)\|(.*?)\|(.*?)$/i;
        push(
            @$refArr,
            {
                symbol         => $1,
                name           => $2,
                date           => $3,
                location       => $4,
                omim_accession => $5,
            }
        );
    }
     close($fhIn);
    return $refArr;
}



=head2 printKinases

   Arg [2]    : a filename indicating output, and reference to an array, that's a list of fields.

   Example    : void context $kinaseObj->printKinases($fileOutName, ['symbol', 'name', 'location']);
                void context $kinaseObj->printKinases($fileOutName, ['symbol', 'name', 'location', 'omim_accession']);

   Description: Prints all the kinases in a Kinases object, according to the requested list of keys.

   Returntype : Void

   Status     : Stable 

=cut

sub printKinases {
    my $filledUsage = 'Usage: $self->printKinases(\$fileOutName, ["symbol", "name", "location"])';
    # test the number of arguments passed in were correct 
    @_ == 3 or confess getErrorString4WrongNumberArguments() , $filledUsage;

    my ($self, $fileOutName, $refArrFields) = @_;

    my $fhOut = getFh( '>', $fileOutName );
    foreach my $item (@{ $self->getAoh }) {
        my @fieldArr = (); # construct a output string, will be flatten by join()
        foreach (@$refArrFields) {
            push( @fieldArr, $item->{$_} );
        }                  # end inner foreach: all fields
        say $fhOut join( "\t", @fieldArr );
    }    # end outer foreach: all kinases

    close($fhOut);
    return;
}

=head2 filterKinases

   Arg [1]    : Receives a hash reference with field-criterion for filtering the Kinases of interest. 

   Example    : scalar context(Kinases Object) $kinaseObj2 = $kinaseObj->filterKinases( { name=>'tyrosine' } );
                scalar context(Kinases Object) $kinaseObj2 = $kinaseObj->filterKinases( { name=>'tyrosine', symbol=>'EPLG4' } );

   Description: It returns a new Kinases object which contains the kinases meeting the requirement (filter parameters)
                passed into the method.  This method must us named parameters, since you could
                pass any of the keys to the hashes found in the AOH: symbol, name, location, date, omim_accession.
                If no filters are passed in, then it would just return another Kinases object with all the same entries
                This could be used to create an exact copy of the object. Remember, creating a exact copy of an object, requires
                a new object with new data, you can't just create a copy, i.e. $kinaseObj2 = $kinaseObj would not work.

   Returntype : A new filtered BioIO::MooseKinases

   Status     : Stable 

=cut

sub filterKinases {
    my $filledUsage = 'Usage: $kinaseObj->filterKinases({ name=>"tyrosine" }) ';
    # test the number of arguments passed in were correct 
    @_ == 2 or confess getErrorString4WrongNumberArguments() , $filledUsage;

    my ($self, $args) = @_;

    my $symbol    = exists $args->{symbol}         ? $args->{symbol}         : ".";
    my $name      = exists $args->{name}           ? $args->{name}           : ".";
    my $location  = exists $args->{location}       ? $args->{location}       : ".";
    my $date      = exists $args->{date}           ? $args->{date}           : ".";
    my $accession = exists $args->{omim_accession} ? $args->{omim_accession} : ".";

    # using grep to filter
    my $selfFiltered = [
        grep {
                 $_->{symbol}         =~ /$symbol/i
              && $_->{name}           =~ /$name/i
              && $_->{location}       =~ /$location/i
              && $_->{date}           =~ /$date/i
              && $_->{omim_accession} =~ /$accession/i

          } @{ $self->getAoh }
    ];
   
   
    return $class->new(
                    $aohAttribute => $selfFiltered,
                    $numKinasesAttribute => scalar @$selfFiltered,
                  
                 );# 
}


=head2 getElementInArray

   Arg [1]    : Take one argument (an index)
   
   Example    : my $hasRef = $kinaseObj->getElementInArray(1);

   Description: Take one argument (an index) and return the element of the Array of Hashes stored in Kinases instance
                Which is an reference to a hash

   Returntype : A reference to a hash

   Status     : Stable 

=cut

sub getElementInArray {
    my $filledUsage = 'Usage: $kinaseObj->getElementInArray(1)';
    # test the number of arguments passed in were correct 
    @_ == 2 or confess getErrorString4WrongNumberArguments() , $filledUsage;

    my ($self, $index) = @_;
    my $arrRef = $self->getAoh;
    if ($arrRef->[$index]) {
        return $arrRef->[$index];
    }
    else {
        return;
    }
}


__PACKAGE__->meta->make_immutable;
1;