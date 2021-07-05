#!/usr/bin/perl
use warnings;
use strict;
use lib qw(blib lib);
use Getopt::Long;
use Pod::Usage;

my ($filename, $number) = @ARGV;
my $FH;
my $FH2;
my $line;
my $exitcode;

my $Hdebug = 0;

my $newfile;



print "Got this input filename: ", $filename, "\n";

if ( not defined $filename ) {
  die "Need filename\n";
}

open(FH, '<', $filename) or die $!;

$filename =~ s/.yml//;
$newfile = $filename . "-new.yml";

print "Writing to new filename: ", $newfile, "\n"; 
open(FH2, '>', $newfile) or die $!;


while($line = <FH>){
   $line =~ s/\$tc_device_hostname\$/sydney/;
   $line =~ s/\$tc_device_username\$/admin/;
   $line =~ s/\$tc_device_password\$/aoii/;
   printf FH2 $line;
}

close(FH);
close(FH2);

