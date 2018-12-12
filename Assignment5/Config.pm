package Assignment5::Config 1.01;
use strict;
use warnings;
use Carp qw( confess );
use Exporter 'import';
our @EXPORT_OK = qw(getErrorString4WrongNumberArguments
					getUnigeneDirectory
					getUnigeneExtension
					getHostKeywords
);
use Readonly;

#path to directory of unigene files. exported via the function
#getUnigeneDirectory
Readonly our $UNIGENE_DIR => '/data/PROGRAMMING/assignment5'; 

#for ending of unigene files. exported via the function
#getUnigeneExtension
Readonly our $UNIGENE_FILE_ENDING => 'unigene';

#hash reference for keywords for host organism. exported via the function
#getHostKeywords
Readonly our $HOST_KEYWORDS => {
								'bos taurus'		=> 'Bos_taurus',
								'cow'				=> 'Bos_taurus',
								'cows'		 		=> 'Bos_taurus',
								'homo sapiens'		=> 'Homo_sapiens',
								'human'				=> 'Homo_sapiens',
								'humans'			=> 'Homo_sapiens',
								'equus caballus'	=> 'Equus_caballus',
								'horse'				=> 'Equus_caballus',
								'horses'			=> 'Equus_caballus',
								'mus musculus'		=> 'Mus_musculus',
								'mouse'				=> 'Mus_musculus',
								'mice'				=> 'Mus_musculus',
								'ovis aries'		=> 'Ovis_aries',
								'sheep'				=> 'Ovis_aries',
								'sheeps'			=> 'Ovis_aries',
								'rattus norvegicus' => 'Rattus_norvegicus', 
								'rat'				=> 'Rattus_norvegicus',
								'rats'				=> 'Rattus_norvegicus',
};

#error string for subs in this module. exported via the function
#getErrorString4WrongNumberArguments
Readonly our $ERROR_STRING_FOR_BAD_NUMBER_ARGUMENTS => "\nIncorrect number of arguments in call to subroutine. ";



=head1 NAME

Assignment5::Config - package to create a config file

=head1 SYNOPSIS

Creation:

	use Assignment5::Config qw(getErrorString4WrongNumberArguments
					getUnigeneDirectory
					getUnigeneExtension
					getHostKeywords
);

	my $directory = getUnigeneDirectory();

	my $extension = getUnigeneExtension();

	my $hostHashRef = getHostKeywords();

	

=head1 DESCRIPTION	

 This module was designed for use by the Assignment 5 programs, 
 and creates a configuration perl package specifically for a local directory of specific unigene files

=head1 EXPORTS

=head2 Default behavior

Nothing by default

use Assignment5::Config qw(getErrorString4WrongNumberArguments 
                    getUnigeneDirectory 
                    getUnigeneExtension 
                    getHostKeywords
);


=head1 FUNCTIONS 

=head2 getUnigeneDirectory

	Arg[1]		:	No Arguments
	

	Example		:	my $directory = getUnigeneDirectory();


   	DESCRIPTION	:	This will return the directory where all of the unigene files are stored

   	Returntype	:	A scalar variable

   	Status		:	Stable

=cut
sub getUnigeneDirectory{
	my $filledUsage = join(' ' , 'Usage:', (caller(0))[3]) . '()';
	#test number of arguments passed in were correct
	@_ == 0 or confess $ERROR_STRING_FOR_BAD_NUMBER_ARGUMENTS, $filledUsage;
	return $UNIGENE_DIR;

}

=head2 getUnigeneExtension

	Arg[1]		:	No Arguments
	

	Example		:	my $extension = getUnigeneExtension();


   	DESCRIPTION	:	This will return the ending to all the unigene files (.unigene)

   	Returntype	:	A scalar variable

   	Status		:	Stable


=cut

sub getUnigeneExtension{
	my $filledUsage = join(' ' , 'Usage:', (caller(0))[3]) . '()';
	#test number of arguments passed in were correct
	@_ == 0 or confess $ERROR_STRING_FOR_BAD_NUMBER_ARGUMENTS, $filledUsage;
	return $UNIGENE_FILE_ENDING;
}



=head2 getHostKeywords

	Arg[1]		:	No Arguments
	

	Example		:	my $hostHashRef = getHostKeywords();


   	DESCRIPTION	:	This will return a has reference containing all the keywords for host species as the keys
   					and the species as the appear in the file names as the values

   	Returntype	:	A scalar hash reference variable

   	Status		:	Stable

=cut

sub getHostKeywords{
	my $filledUsage = join(' ' , 'Usage:', (caller(0))[3]) . '()';
	#test number of arguments passed in were correct
	@_ == 0 or confess $ERROR_STRING_FOR_BAD_NUMBER_ARGUMENTS, $filledUsage;
	return $HOST_KEYWORDS;

}



=head2 getErrorString4WrongNumberArguments

	Arg[1]		:	No Arguments
	

	Example		:	@_ == 0 or confess getErrorString4WrongNumberArguments() , $filledUsage; 


   	DESCRIPTION	:	This will return the error string defined by the constant $ERROR_STRING_FOR_BAD_NUMBER_ARGUMENTS
					It is used to get a generic string for error handling with the incorrect number of parameters 
					are passd into a modules function		

   	Returntype	:	A scalar variable

   	Status		:	Stable
=cut


sub getErrorString4WrongNumberArguments{
	my $filledUsage = join(' ' , 'Usage:', (caller(0))[3]) . '()';
	#test number of arguments passed in were correct
	@_ == 0 or confess $ERROR_STRING_FOR_BAD_NUMBER_ARGUMENTS, $filledUsage;
	return $ERROR_STRING_FOR_BAD_NUMBER_ARGUMENTS;

}



=head1 LICENSE AND COPYRIGHT

Copyright 2018 Jeremy Goldstein.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

=head1 CONTACT

Please email comments or questions to Jeremy Goldstein at goldstein.jer@husky.neu.edu

=head1 SETTING PATH

if PERL5LIB is not set in the .bashrc eg

PERL5LIB=/Users/jeremysports7/Fall_2018/programming6200/assignment5
export PERL5LIB

then must use 

use lib '/Users/jeremysports7/Fall_2018/programming6200/assignment5';

=cut
1;

