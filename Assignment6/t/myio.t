#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 9;

use Test::Exception;

#require_ok 'Assignment6/MyIO.pm';

BEGIN { use_ok('Assignment6::MyIO', qw (getFh)) };


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

#Death dests
dies_ok{getFh("<", $goodFile, 1)} 'dies ok with too many arguments';
dies_ok{getFh("<")} 'dies ok with not enough arguments';
dies_ok{getFh("<", "")} 'dies ok with no given file';
dies_ok{getFh("", "$goodFile")} 'dies ok with no given read/write/append symbol';
dies_ok{getFh(">", "/Users/jeremysports7/")} 'dies ok when directory is given';





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