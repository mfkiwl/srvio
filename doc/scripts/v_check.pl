#!/usr/bin/perl

use strict;
use YAML ();
use Getopt::Long;
use Verilog::Netlist;
use Verilog::Getopt;
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
my $v_info = &init_v_parse($opt_design, @inc_arg);

# make files by module
my @modules = $v_info->top_modules_sorted;
foreach my $mod (@modules) {
	&dump_yaml($mod, $opt_target);
}



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
sub init_v_parse {
	my ($in_file, @inc_arg) = @_;
	my $opt = new Verilog::Getopt;
	$opt->parameter(@inc_arg);

	my $nl = new Verilog::Netlist(options => $opt);
	$nl->read_file(filename=>$in_file);
	return $nl;
}



##### Convert into hash and dump yaml file
sub dump_yaml {
	my ($module, $target) = @_;

	# cell instance lists to hash
	#	"instance name : object"
	my %hash;
	my $modname = $module->name;
	if ( $modname eq '$root' ) {
		return;
	}

	foreach my $cell ($module->cells_sorted) {
		my $cell_name = $cell->name;
		my $cell_submodule = $cell->submodname;
		$hash{$cell_name} = $cell_submodule;
	}

	# open files
	my $file = $target . "/" . $modname . ".yml";
	open(OUT, ">", $file) or die("cannot ope file: ", $file, "\n");

	# dump yaml
	print OUT YAML::Dump(\%hash);

	# close file
	close(OUT);

	# dump cell names
	#foreach my $cell ($module->cells_sorted) {
	#	printf("module: %s (%s)\n", $cell->name, $cell->submodname);
	#}
}
