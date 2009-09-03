#!/bin/perl

while (<>) {
	if (/^[[:space:]]*%[[:space:]]*include[[:space:]]+"([^"]+)"/) {
		open (INC, "<", $1);
		while (<INC>) { print; }
		close (INC)
	} else {
		print;
	}
}
