#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 3;

use Test::Exception;


BEGIN { use_ok('BioIO::Config', qw (getErrorString4WrongNumberArguments)) };

dies_ok{getErrorString4WrongNumberArguments(1)} 'getErrorString4WrongNumberArguments() dies ok with wrong number of arguments';
lives_ok{getErrorString4WrongNumberArguments()} 'getErrorString4WrongNumberArguments() lives with right number of arguments'