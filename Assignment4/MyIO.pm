package Assignment4::MyIO 1.01;
use strict;
use warnings;
use Exporter 'import';
our @EXPORT_OK = qw( getFh );
return 1 if (caller());
=head1 NAME

Assignment4::MyIO - package to handle opening of files and passing filehandles

=head1 SYNOPSIS

Creation:

	use Assignment4::MyIO qw(getFh);
	my $infile = 'test.txt'
   	# get a filehandle for reading
   	my $fh = getFh('<', $infile);


 =head1 DESCRIPTION	

 This module was designed for use by the Assignment 4 programs, and shows how to create a Perl a Perl package for file IO


=head2 Default behavior

nothing by default

use Assignment4::MyIO qw( getGh);
=head2 function2

=head1 FUNCTIONS 

=head2 getFh

	Arg[1]		: Type of file to open, reading '<', writing '>', appending '>>'
	Arg[2]		: A name for the file

	Example		: my $fh = getFh('<', $infile);


   	DESCRIPTION	: This will return a filehandle to the file passed in.  This function can be used to open, write, and append, and get the File Handle.

   	Returntype	: A filehandle

   	Status		: Stable

=cut

  sub getFh{
	my ($type, $file) = @_;
	my $fh; 
	if ($type !~ /<|>|>>/){
		die "Can't use this symbol for opening '", $type , "'"; #check symbol is correct
	} 
	if (-d $file){
		die "Dying... The file provided is actually a directory!"; #check file isn't a directory
	}
	unless (open($fh, $type , $file) ){
		die join(" ", "Can't open", $file, "for reading/writing/appening:", $!);
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

PERL5LIB=/Users/jeremysports7/Fall_2018/programming6200/assignment4
export PERL5LIB

then must use 

use lib '/Users/jeremysports7/Fall_2018/programming6200/assignment4';

=cut
1;

