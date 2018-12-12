package BioIO::MyIO 1.01;
use strict;
use warnings;
use File::Path qw(make_path);
use BioIO::Config qw(getErrorString4WrongNumberArguments);
use Carp qw( confess );
use Exporter 'import';
our @EXPORT_OK = qw( getFh makeOutputDir );

=head1 NAME

BioIO::MyIO - package to handle opening of files and passing filehandles

=head1 SYNOPSIS

Creation:

	use BioIO::MyIO qw(getFh makeOutputDir);
	my $infile = 'test.txt';
   	# get a filehandle for reading
   	my $fh = getFh('<', $infile);
   	makeOutputDir('OUTPUT');


=head1 DESCRIPTION	

 This module was designed for use by the Assignment 7 programs, and shows how to create a Perl a Perl package for file IO


=head2 Default behavior

nothing by default

use BioIO::MyIO qw( getFh);


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

=head2 makeOutputDir

 	Arg [1]		:An output directory to make

	Example		:makeOutputDir('OUTPUT');

	Description :This will test if there is a need to make a an output directory, and if there is it 
 			 will attempt to make to the directory if it has the privileges

 	Returntype	: undef

 	Status		: Stable

=cut
sub makeOutputDir{
	my ($nameDir) = @_;
	my $filledUsage = join(' ', 'Usage:', (caller(0))[3]) . '($nameDir)';
	#test number of arguments passed in were correct
	@_ == 1 or confess getErrorString4WrongNumberArguments() , $filledUsage;
	
	unless (-e $nameDir){ #do nothing if it already exists
		eval {
			make_path($nameDir);
	};
		if($@){
		confess join(" ", "Cannot make directory", $nameDir . "\n", $@);
		}	
	}
	return;
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

PERL5LIB=/Users/jeremysports7/Fall_2018/programming6200/assignment7
export PERL5LIB

then must use 

use lib '/Users/jeremysports7/Fall_2018/programming6200/assignment7';

=cut
1;

