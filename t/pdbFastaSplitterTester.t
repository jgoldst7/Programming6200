#!/usr/bin/perl
use warnings;
use strict;
use feature qw(say);
use Test::More tests => 2;
use Test::Exception;

require_ok "pdbFastaSplitter.pl";

my $fileName = 'ss_designed2Fail.txt';
my $fhInBad;
open ($fhInBad, '<', $fileName);





dies_ok { getHeaderAndSequenceArrayRefs($fhInBad) } 'Dies ok when the bad file is sent in';




