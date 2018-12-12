#!/usr/bin/perl
use strict;
use warnings;
use feature qw(say);
use Test::More tests => 50; # change to the number of test you are going to do
use BioIO::MooseKinases;
use Data::Dumper;
use feature qw(say);
use Test::Exception; 	# need this to get dies_ok to work with croak & confess inside and object
use Test::Moose::More;  # you need to install this

my $class       = 'BioIO::MooseKinases';
my $fileInName  = './INPUT/kinases_map_test';     # default input
my $fileOutName = './OUTPUT/test_output.txt';     # default output

BEGIN { use_ok('BioIO::MooseKinases') };

#say join(" " , getSortedListMooseAttributesFromClass($class));
my @attributes = qw( filename _aoh _numberOfKinases );
#say join(" " , getSortedListMooseMethodsFromClass($class));
my @methods = qw(_readKinases _writer_aoh _writer_numberOfKinases filename filterKinases 
				 getAoh getElementInArray getNumberOfKinases printKinases
);


# object creation, showing you that you can use a scalar to store the value of the class
ok my $kinaseObj = $class->new(filename => $fileInName), 	'....and the constructor should succeed';               
isa_ok $kinaseObj, $class, 									'... and the object it returns';

# validate some class specific data
validate_class $kinaseObj =>(
        isa             => [$class],
        does            => [ ],
        attributes      => [ @attributes ],
        methods         => [ @methods  ],
    	immutable   => 1,
);
# Test the attributes
validate_attribute $class => _aoh  =>(
	is  		=> 'ro',
	writer		=> '_writer_aoh',
	reader		=> 'getAoh', 
	isa			=> 'ArrayRef',   # isa is not tested yet, but should be in the future
);
validate_attribute $class => _numberOfKinases =>(
	is  		=> 'ro',
	writer		=> '_writer_numberOfKinases',
	reader		=> 'getNumberOfKinases', 
	isa      	=> 'Int',        # isa is not tested yet, but should be in the future
);


# test private method, since this is not going to be called the OOP way (meaning $self is not passed)
# we must do it this way
my $arrRef = $kinaseObj->_readKinases();
is ref($arrRef), "ARRAY", 																'Got back a reference to an array';
dies_ok {$kinaseObj->_readKinases(1)} 													'... dies ok when wrong number of attributes are passed in';

# test the getter method
is ref($kinaseObj->getAoh), 		"ARRAY", 	'Got back a reference to an array from getAoh';
dies_ok {$kinaseObj->getAoh(1)} 				'... dies ok when wrong number of attributes are passed in';
is $kinaseObj->getNumberOfKinases, 	2, 			'Got back the correct number of Kinases';
dies_ok {$kinaseObj->getNumberOfKinases(1)} 	'... dies ok when wrong number of attributes are passed in';

dies_ok { $kinaseObj->printKinases('', ['symbol', 'name', 'location']) } 				'dies ok when no filename is provided';
lives_ok { $kinaseObj->printKinases($fileOutName, ['symbol', 'name', 'location']) } 	'lives ok when a filename is provided';
ok -e $fileOutName, 'file created';
dies_ok {$kinaseObj->printKinases(1)} 													'... dies ok when wrong number of attributes are passed in';

my $kinaseObj2 = $kinaseObj->filterKinases( { 
											 name			=>'kinase', 
											 symbol			=>'PRKACB',
											 omim_accession => 176892,
											 date			=> '21-8-91',
											 location 		=> '1p36.1',
} );
											  
is $kinaseObj2->getNumberOfKinases, 		1, 			"Got back the correct number of Kinases";
is ref($kinaseObj2->getElementInArray(0)), 	"HASH", 	"Got back a Hash"; 
is ref($kinaseObj2->getElementInArray(1)), 	'', 		"Got back undef"; 
dies_ok {$kinaseObj->getElementInArray()} 				'... dies ok when wrong number of attributes are passed in';


my $hashRef = $kinaseObj2->getElementInArray(0);
is $hashRef->{omim_accession}	, 176892, 											 'Got back the right omim_accession = 176892';
is $hashRef->{location}			, '1p36.1', 										 'Got back the right location = 1p36.1';
is $hashRef->{symbol}			, 'PRKACB', 										 'Got back the right symbol = PRKACB';
is $hashRef->{name}				, 'Protein kinase, cAMP-dependent, catalytic, beta', 'Got back the right name = "Protein kinase, cAMP-dependent, catalytic, beta"';


# test if filter doesn't do anything, clone an object
my $kinaseObj3 = $kinaseObj->filterKinases( {} );
is $kinaseObj3->getNumberOfKinases, 		2, 			"Got back the correct number of Kinases for the clone";

#say Dumper $kinaseObj;
#say Dumper $kinaseObj3;

# use the MOP to get data
sub getSortedListMooseAttributesFromClass{
	my ($class) = @_;
	return sort (map{$_->name }  $class->meta->get_all_attributes);
}
sub getSortedListMooseMethodsFromClass{
	my ($class) = @_;
	return sort (map{$_->name }  $class->meta->get_all_methods);
}
