#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 9;

use Test::Exception;

#require_ok 'Assignment6/Config.pm';

BEGIN { use_ok('Assignment6::Config', qw (getErrorString4WrongNumberArguments getUnigeneDirectory getUnigeneExtension getHostKeywords)) };

#tests for getUnigeneDirectory()
dies_ok{getUnigeneDirectory(1)} 'getUnigeneDirectory() dies ok with wrong number of arguments';
is(getUnigeneDirectory(), '/data/PROGRAMMING/assignment6', "getUnigeneDirectory returns '/data/PROGRAMMING/assignment6'");


#tests for getUnigeneExtension()
dies_ok{getUnigeneExtension(1)} 'getUnigeneExtension() dies ok with wrong number of arguments';
is(getUnigeneExtension(), 'unigene', "getUnigeneExtension returns 'unigene'");

#tests for getHostKeywords()
dies_ok{getHostKeywords(1)} 'getHostKeywords() dies ok with wrong number of arguments';
my $HOST_KEYWORDS = getHostKeywords();
is(ref $HOST_KEYWORDS, 'HASH', "getHostKeywords returns hash reference to $HOST_KEYWORDS" );

#tests for getErrorString4WrongNumberArguments()
dies_ok{getErrorString4WrongNumberArguments(1)} 'getErrorString4WrongNumberArguments() dies ok with wrong number of arguments';
lives_ok{getErrorString4WrongNumberArguments()} 'getErrorString4WrongNumberArguments() lives with right number of arguments'