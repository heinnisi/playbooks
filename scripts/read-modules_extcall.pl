#!/usr/bin/perl
use warnings;
use strict;

my ($filename, $number) = @ARGV;
my $FH;
my $FH2;
my $title;
my $line;
my $lineplay;
my $fromfile;
my $purefilename;
my $target;
my $rolesdir;
my $changeplan;
my $int;
my $ret;
my $cmd;
my $exitcode;
my @splits;

my $script_content;
my $script_content1 = "- name: ";
my $script_content2 = "\n hosts: \$tc_device_hostname\$\n   connection: network_cli\n   gather_facts: no\n vars:\n   ansible_user: \$tc_device_username\$\n   ansible_password: \$tc_device_password\$\n   ansible_network_os: ios\n roles:\n   ";
 
$int = 1;

print "Got this input dir/filename: ", $filename, "\n";

$purefilename = $filename;
$purefilename =~ s/.*\///;
#print "Got this input filename: ", $purefilename, "\n";

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
        #print "Play: ", $title, "\n";

	# build the roles structure 
	$rolesdir =  "/root/.ansible/roles/" . $title ;
	if ( ! -d $rolesdir ) {
	  $cmd = '/usr/bin/ansible-galaxy role init --init-path /root/.ansible/roles --offline ' . $title;
	  #print "Galaxy create : ", $cmd, "\n";
	  $exitcode = system($cmd);
	  #print "Command create role successful for ", $filename, "\n";
	
	}
	$target = "/root/.ansible/roles/" . ${title} . '/tasks/main.yml';
        #print "Here we have the target name : ", $target, "\n";

	unless(open FH2, '+>',  $target) {
           # Die with error message if we can't open it.
           die "\nUnable to open $target\n";
	}
	$fromfile = "# From file: " . $purefilename . "\n";
	#print $purefilename;
	printf FH2 "---\n";
	printf FH2 "# tasks file for" . $purefilename . "\n";

	#print $fromfile;
	printf FH2 $fromfile;

	#print $int, " : ", length($line), " : line goes to file", $line, "\n"; 
	printf FH2 $line . "\n";

	# construct changeplan script
	$script_content = $script_content1 . $title . $script_content2 . $title ;
	#print "***Here we have the script content: ", $script_content, "\n";
	
	#  combine script with the other parameters for creating the changeplan 
	$changeplan = "perl add_change_plan.pl --sitename \"MyTest\" --changescript \"" . $script_content . "\" --changeplanname " . $title . " --changemode \"Cisco IOS enable\" --changedescription \"Automated changeplan created from Ansible collection " . $filename . "\" --changetype advanced --description \"Automate changescript from Ansible collection\" --parameters \"Here are the params\" --tag \"Ansible Change plans\" ";

	print "***Here we call add change plan with the whole changeplan: ", $changeplan, "\n";
	$exitcode = system($changeplan);
	if ( $exitcode != 0) {
		print "Return value form add change plan: ", $exitcode, "\n";
	}

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
	print "Done\n";
        exit; 
      }        
  }
}

close(FH);

