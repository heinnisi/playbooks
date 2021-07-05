#!/usr/bin/perl
use warnings;
use strict;
use lib qw(blib lib);
use Getopt::Long;
use Pod::Usage;

my ($filename, $number) = @ARGV;
my $FH;
my $files_dir = "/root/scripts/files";
my $file;
my $cmd;
my $line;

if ( ! -d $files_dir ) {
  print "Need files dir ", $files_dir,  "\n";
  exit;
}

print "Got this input filename: ", $filename, "\n";

if ( not defined $filename ) {
  die "Need filename\n";
}

$file = $files_dir . "/" . $filename;
open(FH, '<', $file) or die $!;

while($line = <FH>){
  $cmd = '/usr/bin/perl /root/scripts/read-modules.pl ' . $line;
  system($cmd);
  #print "Command: ", $cmd, "\n";
}
close(FH);
exit;
