#! /usr/bin/perl
package BioIO::Kinases;
use warnings;
use strict;
use feature qw(say);
use Carp qw( croak confess);
use BioIO::MyIO qw(getFh);
use BioIO::Config qw(getErrorString4WrongNumberArguments);
use Data::Dumper;
use feature qw(say);

# just naming some attributes, b/c they are used in multiple places
my $aohAttribute        = '_aoh';
my $numKinasesAttribute = '_numberOfKinases';

=head1 NAME

BioIO::Kinases

=head1 SYNOPSIS

Creation:

    # create kinase object
    my $kinaseObj = BioIO::Kinases->new($fileInName);
    # print kinase by 3 fields
    $kinaseObj->printKinases($fileOutName, ['symbol','name','location'] );

=head1 DESCRIPTION

OO package to read each line in the kinase file, store each line 
in a hash, and store each hash in an array, which will be the internals of the object

=head1 METHODS 

=head2 new 

   Arg [1]    : File name to open

   Example    : my $kinaseObj = BioIO::Kinases->new($fileInName);;

   Description: new is a constructor, when you build a new obj, it calls _readKinases.
                The object has two attributes 'aoh' which stores an Array of Hashes, and numberOfKinases
                which is the number of kinases stores in the object

   Returntype : A BioIO::Kinases

   Status     : Stable

=cut

sub new {
    my $filledUsage = 'Usage: BioIO::Kinases->new($file)';
    # test the number of arguments passed in were correct 
    @_ == 2 or confess getErrorString4WrongNumberArguments() , $filledUsage;

    my ( $class, $fileInName ) = @_;
    my $aoh;    # this will be the AOH, that will be set to the attribute aoh

    if ( defined $fileInName ) {
        $aoh = _readKinases($fileInName);
    }
    else{
        croak "You must provide a file name for contruction of ", $0;
    }

    return bless( {
                     $aohAttribute          => $aoh,
                     $numKinasesAttribute   => scalar @$aoh,
                   }, $class    # Remember, $class =  BioIO::Kinases when it's called like:
                                # $kinaseObj = BioIO::Kinases->new($fileInName);
                 );
}

=head2 _readKinases

   Arg [1]    : File name to open

   Example    : $aoh = _readKinases($fileInName);

   Description: _readKinases recieves a filename and then build the internal data structure to be returned as a AoH

   Returntype : A reference to an array of hashes

   Status     : Stable

=cut

sub _readKinases {
    my $filledUsage = 'Usage: _readKinases($fileInName)';
    # test the number of arguments passed in were correct 
    @_ == 1 or confess getErrorString4WrongNumberArguments() , $filledUsage;
    my ($fileInName) = @_;
    my $fhIn = getFh( '<', $fileInName );
    my $arrRef = [];
    while (<$fhIn>) {
        chomp;
        /^(.*?)\|(.*?)\|(.*?)\|(.*?)\|(.*?)$/i;
        push(
            @$arrRef,
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
    return $arrRef;
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
    my $filledUsage = qq(Usage: \$kinaseObj->printKinases(\$fileOutName, ['symbol', 'name', 'location']) );
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

   Returntype : A new filtered BioIO::Kinases

   Status     : Stable 

=cut

sub filterKinases {
    my $filledUsage = qq(Usage: \$kinaseObj->filterKinases({ name=>'tyrosine' }) );
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

    return bless({
                   $aohAttribute => $selfFiltered,
                   $numKinasesAttribute => scalar @$selfFiltered,
                 }, ref($self) # remember, ref gives you a string version of the class type, here BioIO::Kinases.pm
    );
}

=head2 getAoh

   Arg [0]    : (None passed in), but recieves self 

   Example    : my $aoh = $kinaseObj->getAoh();

   Description: When called, returns the AoHs

   Returntype : AoH

   Status     : Stable 

=cut

sub getAoh{
    my $filledUsage = 'Usage: $kinaseObj->getAoh()';
    # test the number of arguments passed in were correct 
    @_ == 1 or confess getErrorString4WrongNumberArguments() , $filledUsage;

    my ($self) = @_;
    return $self->{$aohAttribute};
}

=head2 getNumberOfKinases

   Arg [0]    : (None passed in), but recieves self 

   Example    : my $numKinases = $kinaseObj->getNumberOfKinases();

   Description: Returns the number of kinases in the Kinases Object

   Returntype : scalar

   Status     : Stable 

=cut

sub getNumberOfKinases {
    my $filledUsage = 'Usage: $kinaseObj->getNumberOfKinases()';
    # test the number of arguments passed in were correct 
    @_ == 1 or confess getErrorString4WrongNumberArguments() , $filledUsage;

    my ($self) = @_;
    return $self->{$numKinasesAttribute};
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
1;

=head1 COPYRIGHT AND LICENSE

Copyright [2011-2017] Jeremy Goldsteim

This library is free software; you can redistribute it and/or modify it
under the same terms as Perl itself, either Perl version 5.8.4 or, at your
option, any later version of Perl 5 you may have available.

=head1 CONTACT

Please email comments or questions to Jeremy Goldstein goldstein.jer@husky.neu.edu
=cut
