#!/usr/bin/perl
use warnings;
use strict;
use File::Find;

my $dir;
my @files;
my @DIRLIST;
my $file;


@ARGV = qw(.) unless @ARGV;


find sub { 
  $file = $File::Find::name;
  if (index($file, ".py") != -1) 
  {
    print $file, -d && '/', "\n";
    $file = $_;
    #print $file, -d && '/', "\n";
  }
}, @ARGV;

print "Echo";
# Display all the C source files in /tmp directory.
# $dir = "/tmp/* /home/*";

$dir = "/root/.ansible/collections/ansible_collections/cisco/ios/plugins/modules/*.py";

@files = glob( $dir );

foreach (@files ) {
   print $_ . "\n";
}

