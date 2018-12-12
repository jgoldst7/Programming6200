package Assignment5::MyIO 1.01;
use strict;
use warnings;
use Assignment5::Config qw(getErrorString4WrongNumberArguments);
use Carp qw( confess );
use Exporter 'import';
our @EXPORT_OK = qw( getFh );

=head1 NAME

Assignment5::MyIO - package to handle opening of files and passing filehandles

=head1 SYNOPSIS

Creation:

	use Assignment5::MyIO qw(getFh);
	my $infile = 'test.txt'
   	# get a filehandle for reading
   	my $fh = getFh('<', $infile);


=head1 DESCRIPTION	

 This module was designed for use by the Assignment 5 programs, and shows how to create a Perl a Perl package for file IO


=head2 Default behavior

nothing by default

use Assignment5::MyIO qw( getGh);


qqq=head1 FUNCTIONS 

=head2 getFh

	Arg[1]		: Type of file to open, reading '<', writing '>', appending '>>'
	Arg[2]		: A name for the file

	Example		: my $fh = getFh('<', $infile);


   	DESCRIPTION	: This will return a filehandle to the file passed in.  This function can be used to open, write, and append, and get the File Handle.

   	Returntype	: A filehandle

   	Status		: Stable

=cut
  sub getFh{
  	my $filledUsage = join(' ', 'Usage:', (caller(0))[3]) . '($type, $file)';
	#test number of arguments passed in were correct
	@_ == 2 or confess getErrorString4WrongNumberArguments() , $filledUsage;
	my ($type, $file) = @_;
	my $fh; 
	if ($type !~ /<|>|>>/){
		confess "Can't use this symbol for opening '", $type , "'"; #check symbol is correct
	} 
	if (-d $file){
		confess "Dying... The file provided is actually a directory!"; #check file isn't a directory
	}
	unless (open($fh, $type , $file) ){
		confess join(" ", "Can't open", $file, "for reading/writing/appening:", $!);
	}
	return ($fh);

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

