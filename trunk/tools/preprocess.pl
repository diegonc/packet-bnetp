#!/bin/perl

use File::Basename;
use File::Spec;
use Getopt::Std;

%opts = {};
getopts('i:o:', \%opts);

$infile = $opts{"i"};
$outfile = $opts{"o"};
($name, $directory, $suffix) = fileparse($infile);

if ($infile) {
	open(STDIN, "<", $infile);
}

if ($outfile) {
	open(STDOUT, ">", $outfile);
}

while (<>) {
	if (/^[[:space:]]*%[[:space:]]*include[[:space:]]+"([^"]+)"/) {
		$incfile = $1;
		if (not File::Spec->file_name_is_absolute( $1 )) {
			$incfile = $directory . $incfile;
		}
		open (INC, "<", $incfile);
		while (<INC>) { print; }
		close (INC)
	} else {
		print;
	}
}
