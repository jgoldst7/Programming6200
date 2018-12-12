#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 12;

use Test::Exception;


BEGIN { use_ok('BioIO::MyIO', qw (getFh makeOutputDir)) };


#create files for read, write and append tests
my $goodFile = "testGoodFile_" .  $$;
my $outFile1 = "testOutFile_" .  $$;
my $outFile2 = "testAppendFile_" .  $$;
createFastaFile($goodFile);

#check getFh works for read/write/append
my $fhInGood = getFh("<", $goodFile);
my $fhOutGood = getFh(">", $outFile1);
my $fhAppendGood = getFh(">>", $outFile2);

is(ref $fhInGood, 'GLOB', "The input filehandle is a glob");
is(ref $fhOutGood, 'GLOB', "The output filehandle is a glob");
is(ref $fhAppendGood, 'GLOB', "The append filehandle is a glob");




# my $fileName = '/Users/jeremysports7/Fall_2018/programming6200/assignment4/Assignment4/HUGO_genes.txt';
# my $fhIn;
# open ($fhIn, "<", $fileName);

#Death dests for getFH
dies_ok{ getFh("<", $goodFile, 1) } 'dies ok with too many arguments';
dies_ok{ getFh("<") } 'dies ok with not enough arguments';
dies_ok{ getFh("<", "") } 'dies ok with no given file';
dies_ok{ getFh("", "$goodFile") } 'dies ok with no given read/write/append symbol';
dies_ok{ getFh(">", "/Users/jeremysports7/") } 'dies ok when directory is given';

#tests for makeOutputDir
dies_ok {makeOutputDir('/junk')} "makeOutputDir dies ok when unable to create the directory";


my $dir = 'test';
lives_ok{ makeOutputDir($dir) } "makeOutputDir lives ok when a directory that it can create is passed in";
lives_ok{ makeOutputDir($dir) } "makeOutputDir lives ok when a directory that already exists is passed in";

#clean up
`rmdir $dir`;
unlink $goodFile;
unlink $outFile1;
unlink $outFile2;








#-----------------------------------------------------------------------
# void context: createFastaFile($filename);
#-----------------------------------------------------------------------
# Create a fasta file for testing
#-----------------------------------------------------------------------
sub createFastaFile{
    my ($file) = @_;
    my $fhIn;
    unless (open ($fhIn, ">" , $file) ){
        die $!;
    }
    print $fhIn <<'_FILE_';
>101M:A:sequence
MVLSEGEWQLVLHVWAKVEADVAGHGQDILIRLFKSHPETLEKFDRVKHLKTEAEMKASEDLKKHGVTVLTALGA
ILKKKGHHEAELKPLAQSHATKHKIPIKYLEFISEAIIHVLHSRHPGNFGADAQGAMNKALELFRKDIAAKYKEL
GYQG
>101M:A:secstr
    HHHHHHHHHHHHHHGGGHHHHHHHHHHHHHHH GGGGGG TTTTT  SHHHHHH HHHHHHHHHHHHHHHH
HHTTTT  HHHHHHHHHHHHHTS   HHHHHHHHHHHHHHHHHH GGG SHHHHHHHHHHHHHHHHHHHHHHHHT
T   
>102L:A:sequence
MNIFEMLRIDEGLRLKIYKDTEGYYTIGIGHLLTKSPSLNAAAKSELDKAIGRNTNGVITKDEAEKLFNQDVDAA
VRGILRNAKLKPVYDSLDAVRRAALINMVFQMGETGVAGFTNSLRMLQQKRWDEAAVNLAKSRWYNQTPNRAKRV
ITTFRTGTWDAYKNL
>102L:A:secstr
  HHHHHHHHH  EEEEEE TTS EEEETTEEEESSS TTTHHHHHHHHHHTS  TTB  HHHHHHHHHHHHHHH
HHHHHH TTHHHHHHHS HHHHHHHHHHHHHHHHHHHHT HHHHHHHHTT HHHHHHHHHSSHHHHHSHHHHHHH
HHHHHHSSSGGG   
>102M:A:sequence
MVLSEGEWQLVLHVWAKVEADVAGHGQDILIRLFKSHPETLEKFDRFKHLKTEAEMKASEDLKKAGVTVLTALGA
ILKKKGHHEAELKPLAQSHATKHKIPIKYLEFISEAIIHVLHSRHPGNFGADAQGAMNKALELFRKDIAAKYKEL
GYQG
_FILE_
    close $fhIn;
}