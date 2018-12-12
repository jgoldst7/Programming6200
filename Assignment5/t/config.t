#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 5;

use Test::Exception;

require_ok 'Assignment5/Config.pm';

#test for getUnigeneDirectory()
dies_ok{getUnigeneDirectory("string")} 'getUnigeneDirectory() dies ok with wrong number of arguments';

#test for getUnigeneExtension()
dies_ok{getUnigeneExtension("string")} 'getUnigeneExtension() dies ok with wrong number of arguments';

#test for getHostKeywords()
dies_ok{getHostKeywords("string")} 'getHostKeywords() dies ok with wrong number of arguments';

#test for getErrorString4WrongNumberArguments()
dies_ok{getErrorString4WrongNumberArguments("string")} 'getErrorString4WrongNumberArguments() dies ok with wrong number of arguments';