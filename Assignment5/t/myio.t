#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 4;

use Test::Exception;

require_ok 'Assignment5/MyIO.pm';

#create file

my $file = join('', "fileForTesting_", $$);
createFastaFile($file);
# my $fileName = '/Users/jeremysports7/Fall_2018/programming6200/assignment4/Assignment4/HUGO_genes.txt';
# my $fhIn;
# open ($fhIn, "<", $fileName);

#Dies when no file is given
dies_ok{getFh("<", "")} 'dies ok with no given file';

#Dies when no read/write/append symbol is given
dies_ok{getFh("", "$file")} 'dies ok with no given symbol';

#Dies ok when a directory is passed in
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