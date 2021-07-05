#!/usr/bin/perl

use lib qw(blib lib);
use strict;
use warnings;
use Getopt::Long;
use Pod::Usage;

use Opsware::NAS::Client;

my $Hdebug = 0;

my $sitename =  "Default Site";
my $changescript;
my $description="";
my $changemode = "Cisco IOS enable",
my $changeplanname;
my $changedescription = "";
my $tag = "Ansible Change plans";
my $family ;
my $changetype = "advanced";
my $parameters="";
my $language = "Ansible",

my($user,$pass,$host) = ('admin', 'HPS0ftware!', 'swvm084.hpeswlab.net');
my $help = 0;

unless( GetOptions("changescript=s" => \$changescript,
                   "sitename:s" => \$sitename,
                   "changeplanname=s" => \$changeplanname,
                   "changemode:s" => \$changemode,
                   "changedescription:s" => \$changedescription,
                   "family:s" => \$family,
                   "changetype=s" => \$changetype,
                   "description:s" => \$description,
                   "parameters:s" => \$parameters,
                   "tag:s" => \$tag,
                   "help|h|?" => $help) ) {
  pod2usage(2);
}

pod2usage(1) if $help;

my $nas = Opsware::NAS::Client->new({-debug => "true"});
my $res = $nas->login(-user => $user, -pass => $pass, -host => $host, -debug => 'true');

unless ($res->ok()) {
  printf STDERR ("*** error: %s\n", $res->error_message());
  printf STDERR ("re-run this script with '--help' for assistance.\n");
  exit(1);
}

if ($Hdebug == 1) {
	printf STDOUT ("Here is what we do:\n");
	printf STDOUT ("  sitename = %s\n", $sitename);
	printf STDOUT ("  changeplanname = %s\n", $changeplanname);
	printf STDOUT ("  description = %s\n", $description);
	printf STDOUT ("  tag = %s\n", $tag);
	printf STDOUT ("  name = %s\n", $changeplanname);
	printf STDOUT ("  language = %s\n", "Ansible");
	printf STDOUT ("  changemode = %s\n", $changemode);
	printf STDOUT ("  parameters = %s\n", $parameters);
	printf STDOUT ("  family = %s\n", $family);
	printf STDOUT ("  changedescription = %s\n", $changedescription);
	printf STDOUT ("  changescript = %s\n", $changescript);
	printf STDOUT ("  changetype = %s\n\n", $changetype);
}


$res = $nas->add_change_plan( 
  sitename => $sitename,
  name => $changeplanname,
  desc => $description,
  tag => $tag,
  family => $family,
  changescript => $changescript,
  changedescription => $changedescription,
  language => $language,
  parameters => $parameters,
  changemode => $changemode,
  rollbackscript => "this is the Rollback Script",
  changetype => $changetype
  );

unless ($res->ok()) {
  printf STDERR ("*** error: %s\n", $res->error_message());
  printf STDERR ("Did you supply valid CHANGE/SCRIPT/TYPE/etc/ arguments?\n");
  exit(1);
}

$nas->logout();
undef $nas;

__END__

=head1 NAME

scripts/add-changeplan3.pl -- add a changeplan  of the Opsware::NAS::Client API

=head1 SYNOPSIS

scripts/add-changeplan3.pl [options]

 Options:

    --help                 This help message
    --changeplanname	   Name of Change Plan
    --description	   Description for the Change plan being added
    --tag 		   Change Plan Tag (General purpose or user defined subcategory)
    --family		   Device family for the new change plan
    --sitename		   Site Name of the site the change plan belongs to
    --changename	   Name of Change Script
    --changedescription	   Change Script Description
    --changemode	   Change Script mode (Cisco CUE exec, Cisco IOS configuration, Cisco IOS enable, ...)
    --changetype	   Type of the desired change script - may be command, advanced
    --host=IP|Name         The NAS Server HOST (default: localhost)
    --user=Name            A user on the NAS server (default: admin)
    --pass="secret"        The password for the user (no default)

=head1 DESCRIPTION

A special use case of the Opsware::NAS::Client API

=cut

