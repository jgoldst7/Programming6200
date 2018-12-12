#!/usr/bin/perl
use warnings;
use strict;
use feature qw(say);
use Test::More tests => 4;
use Test::Exception;


require_ok  'nucleotideStatisticsFromFasta.pl';

my $fileName = 'ss_designed2Fail.txt';
my $fhInBad;
open ($fhInBad, "<", $fileName);

my @refArrSeqs = ("AGCTAGCTAGCTNNNNGGGTTT");


dies_ok{ getHeaderAndSequenceArrayRefs($fhInBad) } 'Dies ok when the bad file is sent in';

dies_ok{ _getNtOccurence('Z', \$refArrSeqs[0]) } "dies on unknown Z character";

dies_ok{ _getNtOccurence('R', \$refArrSeqs[0]) } "dies on unknown R character";


