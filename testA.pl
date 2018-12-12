#!/usr/bin/perl
use strict;
use warnings;
use feature qw(say);
use Assignment5::MyIO 1.01 qw (getFh);

 my $infile = 'HUGOenes.txt';

 my $file = getFh('yes', $infile);
 say $file;
