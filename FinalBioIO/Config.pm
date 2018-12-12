package FinalBioIO::Config 1.01;
use strict;
use warnings;
use Carp qw( confess );
use Exporter 'import';
our @EXPORT_OK = qw(getErrorString4WrongNumberArguments);
use Readonly;



#error string for subs in this module. exported via the function
#getErrorString4WrongNumberArguments
Readonly our $ERROR_STRING_FOR_BAD_NUMBER_ARGUMENTS => "\nIncorrect number of arguments in call to subroutine. ";



=head1 NAME

FinalBioIO::Config - package to create a config file

=head1 SYNOPSIS

Creation:

	use FinalBioIO::Config qw(getErrorString4WrongNumberArguments);


=head1 DESCRIPTION	

 This module was designed for use by the final programs, 
 and creates a configuration perl package for alerting the user when the wrong number of arguments are passed into a subroutine

=head1 EXPORTS

=head2 Default behavior

Nothing by default

use FinalBioIO::Config qw(getErrorString4WrongNumberArguments);


=head1 FUNCTIONS 

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

PERL5LIB=/Users/jeremysports7/Fall_2018/programming6200/final
export PERL5LIB

then must use 

use lib '/Users/jeremysports7/Fall_2018/programming6200/final';

=cut
1;