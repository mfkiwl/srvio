#!/usr/bin/perl

use strict;
use YAML ();
use Getopt::Long;
use Verilog::Netlist;
use Verilog::Getopt;
use Verilog::Preproc;
use Verilog::SigParser;
use Data::Dumper ();
use Cwd;
use Clone ();

# default argument
my $opt_target= '.';
my $opt_conf = 'conf.yml';
my $opt_design = 'design.v';
my $opt_include = 'incdir.yml';

# option parse
# target: output target directory
GetOptions(
	'target=s' => \$opt_target,
	'design=s' => \$opt_design,
	'include=s' => \$opt_include
);



# Load include file list
open(IN, $opt_include) or die ("cannot open file: ", $opt_include, "\n");
read(IN, my $inc_file, (-s $opt_include));
my $inc = YAML::Load($inc_file);
#print Data::Dumper::Dumper($inc);

# top directory
my $top_dir = Cwd::abs_path("..");

# construct include directory argument
my @inc_keys = keys %$inc;
my @inc_arg;
#my @incdir = &construct_tree($top_dir, $inc);
foreach my $incdir ( &construct_tree($top_dir, $inc) ) {
	#print $incdir . "\n";
	push(@inc_arg, "+incdir+" . $incdir);
}

# verilog parsing
my $preproc = &verilog_preproc($opt_design, @inc_arg);

open(out_file, "> tmp.v") or die("Error:$!");
print out_file $preproc->getall();


##### directory tree construction
sub construct_tree {
	my ($path, $dir) = @_;
	my @incdir;

	if ($dir eq "." ) {
		push(@incdir, $path);
	} else {
		my @inc_keys = keys %$dir;
		foreach my $key_elm (@inc_keys) {
			my $child = $path . "/" . $key_elm;
			push(@incdir, &construct_tree($child, $dir->{$key_elm}));
		}
	}

	return @incdir;
}



##### Verilog parsing
sub verilog_preproc {
	my ($in_file, @inc_arg) = @_;
	my $opt = new Verilog::Getopt;
	$opt->parameter(@inc_arg);

	my $vp = Verilog::Preproc->new(options=>$opt);
	$vp->open(filename=>$in_file);

	return $vp;
}
