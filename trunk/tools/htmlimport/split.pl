#!/bin/perl

use strict;
use HTML::TreeBuilder;
use XML::XPath;
use XML::XPath::XMLParser;
use HTML::FormatText;

undef $/;

my $htmldb = <>;
my $htmltree = HTML::TreeBuilder->new;
my $formatter = HTML::FormatText->new();

open(my $CNST, ">", "constants.lua")
	or die("Couldn't open constants.lua");
open(my $SRVR, ">", "spackets.lua")
	or die("Couldn't open spackets.lua");
open(my $CLNT, ">", "cpackets.lua")
	or die("Couldn't open cpackets.lua");

my $current_name = "";
my $current_id = "";
my $current_source = "";
my $current_raw = "";

my %typemap = (
  "BYTE"      => "uint8",
  "WORD"      => "uint16",
  "DWORD"     => "uint32",
  "BOOLEAN"   => "uint32",
  "BOOL"      => "uint32",
  "ULONGLONG" => "uint64",
  "FILETIME"  => "wintime",
  "SOCKADDR"  => "sockaddr",
  "STRING"    => "stringz",
);

my %prefixes = (
	"SID"    => 0xFF,
	"W3GS"   => 0xF7, # ???, prefix is not real
	"BNLS"   => 0x70, # fake, theres no header id byte
	"D2GS"   => 0x71, # fake, theres no header id byte
	"MCP"    => 0x72, # fake, theres no header id byte
	"PACKET" => 0x73, # fake, theres no header id byte (may be 0x01)
	"PKT"    => 0x74, # fake, theres no header id byte
);

sub finish_current {
	if ($current_name ne "") {
		if ($current_source eq "S") {
			print $SRVR "},\n";
		}
		else {
			print $CLNT "},\n";
		}
	}
}

sub do_label {
	my $label = $_[0];
	my $value = $_[1];
	my $text = $value->as_text();

	if ($label =~ /Message ID/) {
		finish_current();
		$current_id = $text;
	}
	if ($label =~ /Message Name/) {
		$current_name = $text;
		$current_name =~ /[[:space:]]*([A-Z0-9]+)_.*/;
		
		my $numid = $prefixes{$1};
		print STDERR "Unknown prefix: $1\n" if ($numid == 0);
		$numid = $numid * 0x100 + hex($current_id);
		print $CNST sprintf("local $current_name = 0x%04X\n", $numid);
	}
	if ($label =~ /Direction/) {
		if ($text =~ /Server[ ]*->[ ]*Client/) {
			$current_source = "S";
			print $SRVR "--[[\n${current_raw}\n]]\n";
			print $SRVR "[$current_name] = {\n";
		}
		elsif ($text =~ /Client[ ]*->[ ]*Server/) {
			$current_source = "C";
			print $CLNT "--[[\n${current_raw}\n]]";
			print $CLNT "[$current_name] = {\n";
		} else {
			print $STDERR "Unknown direction: $text\n",
		}
	}
	if ($label =~ /Format/) {
		my $formatted = $formatter->format($value);

		$formatted =~ s/^\n+//; # remove all leading \n
		$formatted =~ s/\n+$//; # remove all trailing \n 
		$formatted =~ s/\n\n/\n/g; # collapse multi \n to single \n 
		$formatted =~ s/\[blank\]//; # remove blank annotation

		# Match each field
		while ($formatted =~ /\(([^\)]*)\)[ ]*(.*?)(?m:[ ]*$)/g) {
			my $type = $1;
			my $name = $2;
			$name =~ s/\\/\\\\/g;
			$name =~ s/"/\\"/g;
			my $method = $typemap{$type};
			if ($method) {
				if ($current_source eq "S") {
					print $SRVR "\t${method}{label=\"${2}\"},\n";	
				} elsif ($current_source eq "C") {
					print $CLNT "\t${method}{label=\"${2}\"},\n";
				} else { die "Unknown source: $current_source.\n"; }
			} else {die "Unknown type: $type.\n"; }
		}
	}

	#print "Label: $label\n";
	#print "Data: " . $value->as_text() . "\n";
	#print $formatter->format($value) . "\n";
}

$htmltree->parse($htmldb);
$htmltree->eof();

my @tables = $htmltree->look_down("_tag", "table", "id", "code");

foreach my $table (@tables) {
	$current_raw = $formatter->format($table);
	my @rows = $table->look_down("_tag", "tr");
	foreach my $row (@rows) {
		my @cells = $row->look_down("_tag", "td");
		my $label = $cells[0]->as_text();
		my $data = $cells[1];
			
		# &nbsp; translates into 0xA0 :S
		$label =~ tr/\240/ /;
		
		if ($label !~ m/^[[:space:]]*$/) {
			do_label $label, $data
		}
	}
}

finish_current();

close ($CNST);
close ($SRVR);
close ($CLNT);
