#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 16;
use Test::Exception;
use Assignment6::MyIO qw (getFh);
require_ok 'snpScan.pl';
use Data::Dumper;
#BEGIN { use_ok('snpScan', qw (getQuerySites getEqtlSites compareInputSitesWithQtlSites _findNearest)) };




#files for testing
my $queryFile = 'testInput.txt';
my $eqtlFile  = 'testAffy.txt';
my $outfile	  = 'testOutfile.txt';
my $badfile  ='fakefile.txt';

#testing getQuerySites
dies_ok{getQuerySites($queryFile, $eqtlFile)} 'getQuerySites() dies ok with multiple files are passed in';
dies_ok{getQuerySites()} 'getQuerySites() dies ok with no files are passed in';
dies_ok{getQuerySites($badfile)} ' getQuerySites() dies ok with bogus file passed in';


my ($refHoAQuery) = getQuerySites($queryFile); 
#print Dumper $refHoAQuery;
is(ref $refHoAQuery, 'HASH', "getQuerySites returns a Hash");



# testing getEqtlSites
dies_ok{getEqtlSites($queryFile, $eqtlFile)} 'getEqtlSites dies ok with multiple files passed in';
dies_ok{getEqtlSites()} 'getEqtlSites dies ok with no files passed in';	
dies_ok{getEqtlSites($badfile)} ' getEqtlSites() dies ok with bogus file passed in';

 my ($refHoAeQTL, $refHoHeQTLDescriptions) = getEqtlSites($eqtlFile);
 #print Dumper $refHoAeQTL;
 #print Dumper $refHoHeQTLDescriptions;

is(ref $refHoAeQTL, 'HASH', "getEqtlSites returns a Hash for its positions");
is(ref $refHoHeQTLDescriptions, "HASH", "getEqtlSites also returns a Hash for its descriptions");



#testing compareInputSitesWithQtlSites
dies_ok{ compareInputSitesWithQtlSites({query => "$refHoAQuery", 
										eQTLPosition => "$refHoAeQTL",
										eQTLDescription => "$refHoHeQTLDescriptions",
 											}) } 'compareInputSitesWithQtlSites() dies ok with wrong number of arguments';

dies_ok{ compareInputSitesWithQtlSites({query => "$refHoAQuery", 
										eQTLPosition => "$refHoAeQTL",
										eQTLDescription => "$refHoHeQTLDescriptions",
										outfile 		=> "/Users/jeremysports7/"
 											}) } 'compareInputSitesWithQtlSites() dies ok given outfile as a directory';

#run sub to make sure it works
lives_ok{ compareInputSitesWithQtlSites({query => $refHoAQuery,
										eQTLPosition => $refHoAeQTL,
										eQTLDescription => $refHoHeQTLDescriptions,
										outfile => $outfile,}) } 'lives ok on compareInputSitesWithQtlSites' ;


#testing _findNearest
dies_ok{_findNearest({chromosome => "1",			
						position => "216055001"})} '_findNearest() dies ok with wrong number of arguments';

#running the script with the test files gives the nearest ppsition as 216055212 so testing it works
my $nearestPosition = _findNearest({chromosome => "1",			
						position => "216055001",
						eQTLPosition => $refHoAeQTL});

is($nearestPosition, 216055212, "correct return from _findNearest");

lives_ok{ _findNearest({chromosome => "1",			
						position => "216055001",
						eQTLPosition => $refHoAeQTL}) } '_findNearest() lives ok with wrong number of arguments';


