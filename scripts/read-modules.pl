#!/usr/bin/perl
use warnings;
use strict;
use lib qw(blib lib);
use Getopt::Long;
use Pod::Usage;
use Opsware::NAS::Client;

# These are he main parameters to be set when executing the command
my $sitename =  "Default Site";
my $rolesbasedir =  "/root/.ansible/roles/";
my ($user,$pass,$host) = ('admin', 'HPS0ftware!', 'swvm084.hpeswlab.net');
my $changemode = "Cisco IOS enable",
my $tag = "Troubleshooting Change plans";
my $family = "Any Device Family";
my $changetype = "advanced";
my $language = "Ansible",


my ($filename, $number) = @ARGV;
my $FH;
my $FH2;
my $title;
my $line;
my $lineplay;
my $fromfile;
my $purefilename;
my $stumpfilename;
my $play_title;
my $play_comment_name;
my $target;
my $rolesdir;
my $changeplan;
my $int;
my $ret;
my $cmd;
my $exitcode;
my @splits;

my $Hdebug = 0;

my $changescript;
my $description="";
my $changeplanname;
my $changeplanname_cut;
my $changedescription = "";
my $parameters="";

my $help = 0;

my $nas = Opsware::NAS::Client->new({-debug => "false"});
my $res = $nas->login(-user => $user, -pass => $pass, -host => $host, -debug => 'true');

unless ($res->ok()) {
  printf STDERR ("*** error: %s\n", $res->error_message());
  printf STDERR ("re-run this script with '--help' for assistance.\n");
  exit(1);
}

my $script_content;
my $script_content1 = "- name: ";
my $script_content2 = "\n  hosts: \$tc_device_hostname\$\n  connection: network_cli\n  gather_facts: yes\n  vars:\n    ansible_user: \$tc_device_username\$\n    ansible_password: \$tc_device_password\$\n    ansible_network_os: ios\n  roles:\n  - ";
 
$int = 1;

print "Got this input dir/filename: ", $filename, "\n";

$purefilename = $filename;
$purefilename =~ s/.*\///;
$stumpfilename = $purefilename;
$stumpfilename =~ s/.py//;
#print "Got this input filename: ", $purefilename, "\n";
#print "*** stump filename: ", $stumpfilename, "\n";

if ( not defined $filename ) {
  die "Need filename\n";
}

open(FH, '<', $filename) or die $!;


while($line = <FH>){
   # spool forward until we find EXAMPLES keayword
   if (index($line, "EXAMPLES") == -1) {
     #print "NEXT on ",  $line ; 
     ++$int;
     next;
   }
   while ($line = <FH>) {
      # skip all comments lines
      if ($line =~ m#\*/#){
          ++$int;
          next;
      }
      # skip all comments lines
      if (substr($line, 0, 1) eq "#") {
          ++$int;
          next; 
      }
      # now find "- name" and start recording the playbook until empty line 
      if (substr($line, 0, 7) eq "- name:") {
        ++$int;
        #print "Here we have the filename : ", $filename, "\n";

        #print "Here we have the title : ", $title, "\n";
        $title = substr($line, 8, -1); 
        $title =~ s/\"\'().//g;
        #print "Here we have the title : ", $title, "\n";
	$title =~ s/[\$#@~!&*()\[\]\"\';.,:?^`\\\/]+//g;
        #print "Here we have the title : ", $title, "\n";
	$title =~ tr/ /-/;
	$play_title = $stumpfilename . "-" . $title;
        #print "Play: ", $play_title, "\n";

	# build the roles structure 
	$rolesdir =  $rolesbasedir . $play_title ;
	if ( ! -d $rolesdir ) {
	  $cmd = '/usr/bin/ansible-galaxy role init --init-path /root/.ansible/roles --offline ' . $play_title;
	  #print "Galaxy create : ", $cmd, "\n";
	  $exitcode = system($cmd);
	  #print "Command create role successful for ", $play_title, "\n";
	} else {
	  print "+++ Role already exists \n";
	}

	#  target is the name of the directory in roles and tasks/main.yml file
	$target = "/root/.ansible/roles/" . ${play_title} . '/tasks/main.yml';
        #print "Here we have the target name : ", $target, "\n";

	unless(open FH2, '+>',  $target) {
           # Die with error message if we can't open it.
           die "\nUnable to open $target\n";
	}
	$fromfile = "# From file: " . $purefilename . "\n";
	#print $purefilename;
	printf FH2 "---\n";
	printf FH2 "# tasks file for" . $stumpfilename . "\n";

	#print $fromfile;
	printf FH2 $fromfile;

	#print $int, " : ", length($line), " : line goes to file", $line, "\n"; 
	printf FH2 $line . "\n";

	# construct changeplan script
	$play_comment_name = $play_title;
	$play_comment_name =~ s/-/ /;
	#$play_comment_name =~ s/_/ /;
	$script_content = $script_content1 . $play_title . $script_content2 . $play_title ;
	#print "***Here we have the script content: ", $script_content, "\n";
	
	#  combine script with the other parameters for creating the changeplan 
	$description = "Automate changescript from Ansible collection " . $filename; 
	$tag = "Ansible Change plans";
	$parameters = "";
	$changetype = "advanced"; 
	$changedescription = "Automated changeplan created from Ansible collection";
	$changeplanname =  $purefilename . "-" . $title;
	$changeplanname =~ s/.py//;
	$changeplanname_cut = substr($changeplanname, 0, 99);

	$res = $nas->add_change_plan( 
	  sitename => $sitename,
	  name => $changeplanname_cut,
	  desc => $description,
	  tag => $tag,
	  family => $family,
	  changescript => $script_content,
	  changedescription => $changedescription,
	  language => $language,
	  parameters => $parameters,
	  changemode => $changemode,
	  rollbackscript => "this is the Rollback Script",
	  changetype => $changetype
	  );

	  unless ($res->ok()) {
	  	printf STDERR ("*** NA add change plan error: %s\n", $res->error_message());
		exit(1);
	  }
	print "- Add change plan successfully: ", $changeplanname, "\n";
	#  Read task content for main.py in tasks dir 
	while ($lineplay = <FH>) 
	{
	   if (length($lineplay) == 1) {
	        #print $int, " : inner while - end of play with empty line", $lineplay; 
		close (FH2);
		last;
	   }
           ++$int;
	   # print $int, " : ", length($lineplay), " : line goes to file", $lineplay; 
	   printf FH2 $lineplay;
	}
	close (FH2);
      }
      # end loop when RETURN statement is reached
      if (index($line, "RETURN") != -1) {
        close (FH);
	$nas->logout();
	undef $nas;
	#print "Done\n";
        exit; 
      }        
  }
}

close(FH);
$nas->logout();
undef $nas;

