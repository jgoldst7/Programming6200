#!/usr/bin/perl
return 1 if ( caller() ); #for testing
use strict;
use warnings;
use Getopt::Long;
use Pod::Usage;
use feature qw(say);
use Carp qw( confess );
use Assignment6::MyIO qw (getFh);
use Data::Dumper;
use Assignment6::Config qw(	getErrorString4WrongNumberArguments						
);

########################################################################
# 
# File   :  snpScan.pl
# History:  17-Nov-2018 (Jeremy) Created workign script with all subs
#		: 	19-Nov-2018 (Jeremy) refactored code to remove formatting and print sub, 
#			Also changed sorting method and finding closest position method
#		 : 23-Nov-2018 (Jeremy) added condition to skip a chr is there is no position given in getQuerySites
#		           
########################################################################
# This program takes 3 arguments, a query file, an eQQTL data file, and an outfile. 
# It compares site positions given in the query file to the closest eQTL and
#  returns information about the cloest sites to the user in the outfile
# 
########################################################################

my ($query, $eqtl, $outfile);  #query file, eqtl file, and outfile

my $usage = "\n$0 [options] \n

Options:

	-query	query file with site positions
	-eqtl 	eqtl file 
	-outfile outfile with info about closest site matches 
	-help	Show this message
";

#check the options
GetOptions(
	'query=s'	=>\$query,
	'eqtl=s'	=>\$eqtl,
	'outfile=s' =>\$outfile,
	help		=>sub{pod2usage($usage);},
	)or pod2usage($usage);

#get query chromosome and positions in ref HoA
my ($refHoAQuery) = getQuerySites($query);


#get eqtl chromosome and positions in ref HoA and positions and descirptions for chromosome in HoH
 my ($refHoAeQTL, $refHoHeQTLDescriptions) = getEqtlSites($eqtl);


#main sub, finds closest position match to query positions in the same chromosome and print info about the matches to outfile
 compareInputSitesWithQtlSites({query => $refHoAQuery,
										eQTLPosition => $refHoAeQTL,
										eQTLDescription => $refHoHeQTLDescriptions,
										outfile => $outfile,});




#############################Subroutines#######################################
#--------------------------------------------------------------------------------------
#scalar context $refHoA = getQuerySites($query);
#--------------------------------------------------------------------------------------
#Opens the query filehandle and returns a HoA ref, with keys as chr and values as arrays of all chr positions
#--------------------------------------------------------------------------------------
sub getQuerySites{
	my $filledUsage = join(' ' , 'Usage:', (caller(0))[3]) . '()';
	#test number of arguments passed in were correct
	@_ == 1 or confess getErrorString4WrongNumberArguments() , $filledUsage;
	
	#get Fh from query file passed into sub and initialize HoA ref
	my ($query) = @_; 
	my $Fh = getFh('<', $query);
	my $refHoAQuery;

	#loop through file to populate HoA ref
	my $header = <$Fh>; #ignore header
	while(<$Fh>){
		chomp;
		#split line by tab into an array where [0] is key and [2] is value
		my (@line) = split /\t/; 
		#if the chr doesn't contain an ending position don't use it
		if (! defined $line[2]){
			next;
		}
		#if the chromosome key is already created, push the position value to the array value,
		if ( exists $refHoAQuery->{$line[0]}){
			push @{$refHoAQuery->{$line[0]}}, $line[2];
			
		} #create chromose key with anonymous array filled with position as value
		else{
			@{$refHoAQuery->{$line[0]}} = $line[2];	
		}
	
	}	
return $refHoAQuery;
}
#--------------------------------------------------------------------------------------




#--------------------------------------------------------------------------------------
#scalar context my ($refHoAEqtl, refHoHEqtl) = getEqtlSites($queryFh);
#--------------------------------------------------------------------------------------
#Opens the Eqtl file and returns a HoA ref, with keys as chr and value as arrays of all chr positions
#also returns HoH ref, with keys as chr and value as hash ref with keys for positions and values as position descriptions
#--------------------------------------------------------------------------------------
sub getEqtlSites{
	my $filledUsage = join(' ' , 'Usage:', (caller(0))[3]) . '()';
	#test number of arguments passed in were correct
	@_ == 1 or confess getErrorString4WrongNumberArguments() , $filledUsage;
	
	#get Fh from query file passed into sub and initialize HoA and HoH ref
	my ($eqtl) = @_; 
	my $Fh = getFh('<', $eqtl);
	my ($refHoAeQTL, $refHoHeQTLDescriptions);
	

	#loop through file to populate HoA ref and HoH ref
	my $header = <$Fh>; #ignore header
	while(<$Fh>){
		chomp;

		#split line by tab into an array where [1] has the chr and position info and [3] is description
		my (@line) = split /\t/; 
		#split [1] by colon where [2] is chromosome and [3] is position
		my @chr = split /:/, $line[1];

		#population HoH with 	
		$refHoHeQTLDescriptions->{$chr[2]}{$chr[3]} = $line[3];
		
		#for HoA, if the chromosome key is already created, push the position value to the array value
		 if ( exists $refHoAeQTL->{$chr[2]}){
	  		push @{$refHoAeQTL->{$chr[2]}}, $chr[3];
	  	} #create chromosome key with anonymous array filled with position as value
	  	else{
	  		@{$refHoAeQTL->{$chr[2]}} = $chr[3];	
	  	}
	  }	
return ($refHoAeQTL, $refHoHeQTLDescriptions);
}
#--------------------------------------------------------------------------------------




#--------------------------------------------------------------------------------------
#void context compareInputSitesWithQtlSites({query => $refHoAQuery,
# 											eQTLPosition => $refHoAeQTL,
# 											eQTLDescription => $refHoHeQTLDescriptions,
# 											outfile => $outfile,})
#--------------------------------------------------------------------------------------
#receives four arguments: 1) A HoA ref of chromosomes and positions in the query file
#						  2) A HoA ref of chromosomes and positions in the eQTL file
#						  3) A HoH ref of chromosomes with positions and their descriptions as the value
#						  4) An outfile
#Iterates over each site in the query hash and finds the nearest site in the same chr in the eQTL file
# prints original query site, distance to nearest eQTL site, eQTL, and decription in tab dilneated outfile
#--------------------------------------------------------------------------------------
sub compareInputSitesWithQtlSites{
	my ($refArgs) = @_; #bring in hash ref of args
	my $filledUsage = join(' ' , 'Usage:', (caller(0))[3]) . '()';	
	#test number of arguments passed in were correct
	keys %$refArgs == 4 or confess getErrorString4WrongNumberArguments() , $filledUsage;

	#open outfile and print the header line
	my $FhOut =  getFh('>', $refArgs->{outfile});
	say $FhOut join("\t", "#Site", "Distance", "eQTL", "[Gene:P-val:Population]");

	
	#foreach position at each chr of query file, find the nearest position at same chr of eQTL file and print output
	#if no match found warn the user
	foreach my $chr ( sort {$a <=> $b} keys  (%{$refArgs->{query}}) ){
		foreach my $pos (sort {$a <=> $b} @{$refArgs->{query}{$chr}} ){
			if (my $nearestPosition = _findNearest({chromosome 	=> $chr,
													position 	=> $pos,
													eQTLPosition=> $refArgs->{eQTLPosition},
												})){
				#site is chr. and position of query joined by :
				my $site 		= join(":", $chr, $pos);

				#distance is sitance between closest position in eQTL  and query 
				my $distance 	= abs($pos - $nearestPosition);

				#eQTL is chr and position of eQTL match (chr is same as query or it wouldnt have matched)
				my $eQTL 		= join(":", $chr, $nearestPosition);

				#Description for that chr and position is Gene:P-val:population as found in descrption HoH ref 
				my $description = $refArgs->{eQTLDescription}{$chr}{$nearestPosition};
	
				#print all variables to outfile as a tab dilineated line 
				say $FhOut join("\t", $site, $distance, $eQTL, $description);
			}
			else{ #if same chromosome isn't found
			warn "Cannot find requested chromosome position in data " , "chr = ",
							$chr , " position = " , $pos;
			}
		}
	}
}
#--------------------------------------------------------------------------------------



#--------------------------------------------------------------------------------------
#scalar context my $nearestPosition = _findNearest({chromosome => $chr,
#													position => $pos,
#													eqtlPosition => $refArgs->{eQTLPosition},
#													})
#--------------------------------------------------------------------------------------
#receives three arguments: 1) A chromosome
#						  2) A position on the chromosome
#						  3) A HoA ref of chromosomes and positions in the eQTL file
#helper function that finds the closest position on the same chr number to the queried position and returns it
#returns void if no position found
#--------------------------------------------------------------------------------------
sub _findNearest{
	my ($refArgs) = @_; #bring in hash ref of args
	my $filledUsage = join(' ' , 'Usage:', (caller(0))[3]) . '()';	
	#test number of arguments passed in were correct
	keys %$refArgs == 3 or confess getErrorString4WrongNumberArguments() , $filledUsage;
	
	#bring in chromosome, position, and eQTL positions as scalar variables derefence eQTL positions
	my $chr = $refArgs->{chromosome};
	my $pos = $refArgs->{position};
	my $eQTLPositionsRef =  $refArgs->{eQTLPosition};
	my %eQTLPositions = %$eQTLPositionsRef;

	#if chromosome is found in eQTL find closest position match
	 if (exists $eQTLPositions{$chr}){
		
		#create an array of the distances between the list of eQTL positions and query positions
		my @eQTLDistances= map( abs($_ - $pos), @{$eQTLPositions{$chr}} );
		
		#push an array slice of the positions (keys) and distances (values) to a hash
		my %eQTLPositionDistance;
		@eQTLPositionDistance{@{$eQTLPositions{$chr}}} = @eQTLDistances; 
		
		#sort keys based on their value (distance to query position) 
		my @sortedeQTLPositions = sort {$eQTLPositionDistance{$a} <=> $eQTLPositionDistance{$b} } keys (%eQTLPositionDistance);
	 	return $sortedeQTLPositions[0]; #return closest position outside for loop
	 }
	 else{ 
		return; #if match isn't found then return void
	 }
}
#--------------------------------------------------------------------------------------
