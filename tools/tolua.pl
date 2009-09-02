#!/bin/perl
undef $/;

$s = <>;
$blanks = qr"
	\{
	[^\[\(]*
	\[blank\]
	[^\[\(]*
	\}
"msx;

$fields = qr"
	(\[[A-Z0-9_]*\]\ =\ \{)
	([^\}]*?)
	(\},)
"msx;

$s =~ s/$blanks/{}/g;

%typemap = (
  "BYTE"      => "uint8",
  "WORD"      => "uint16",
  "DWORD"     => "uint32",
  "BOOLEAN"   => "uint32",
  "BOOL"      => "uint32",
  "ULONGLONG" => "uint64",
  "FILETIME"  => "filetime",
  "SOCKADDR"  => "sockaddr",
  "STRING"    => "stringz",
);

while ($s =~ m/$fields/g ) {
	($a, $b, $c) = ($1, $2, $3);

	if (not $b) {
		print "$a$c\n" if not $b;
	} else {
		print "$a\n";
		while ($b =~ /\(([^\)]*)\)[ ]*(.*?)(?m:[ ]*$)/g) {
			$type = $1;
			$name = $2;
			$name =~ s/"/\\"/g;
			$method = $typemap{$type};
			print "\tWProtoField.${method}(\"\",\"${2}\"),\n" if $method;
			die "Unknown type: $type." if not $method;
		}
		print "$c\n";
	}
	$count = $count + 1;
}

print $count;
