#!/bin/perl
undef $/;

$s = <>;
$p = qr{
	((?:S\ >\ C)|(?:C\ >\ S))
	[ ]\[0x[0-9A-F]{2}\][ ]([A-Z_0-9]*)
	(?:.*?^Format:)
	(?:(.*?)^Remarks:)
	(?:[^~]*~+)
}msx;

$count = 0;

open (SERV, ">", "server.txt");
open (CLIE, ">", "client.txt");

while ($s =~ m/$p/g ) {
	($a, $b, $c) = ($1, $2, $3);
	(print SERV "[$b] = {$c},\n") if ($a =~ /^S/);
	(print CLIE "[$b] = {$c},\n") if ($a =~ /^C/);
	$count = $count + 1;
}

close (SERV);
close (CLIE);

print $count;
