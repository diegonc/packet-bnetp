#!/bin/perl

use strict;
use HTML::TreeBuilder;
use XML::XPath;
use XML::XPath::XMLParser;
use HTML::FormatText;
use HTML::FormatText::WithLinks::AndTables;

sub Fix_AndTables;
sub do_label;
sub dump_packets;

Fix_AndTables;

my $htmltree = HTML::TreeBuilder->new;
my $formatter = HTML::FormatText->new();

my $current_name = "";
my $current_id = "";
my $current_source = "";
my $current_raw = "";

my %typemap = (
  "VOID"       => ["bytes", ""],
  "BYTE"       => ["uint8", ""],
  "WORD"       => ["uint16", ""],
  "DWORD"      => ["uint32", ""],
  "QWORD"      => ["uint64", ""],
  "BOOLEAN"    => ["uint32", "desc=Descs.YesNo"],
  "BOOL"       => ["uint32", "desc=Descs.YesNo"],
  "ULONGLONG"  => ["uint64", ""],
  "FILETIME"   => ["wintime", ""],
  "SOCKADDR"   => ["sockaddr", ""],
  "STRING"     => ["stringz", ""],
  "BYTE[20]"   => ["uint8", "num=20"],
  "BYTE[128]"  => ["uint8", "num=128"],
  "DWORD[5]"   => ["uint32", "num=5"],
  "DWORD[8]"   => ["uint32", "num=8"],
  "DWORD[9]"   => ["uint32", "num=9"],
  "DWORD[16]"  => ["uint32", "num=16"],
  "DWORD[21]"  => ["uint32", "num=21"],
  "DWORD[22]"  => ["uint32", "num=22"],
  "DWORD[]"    => ["uint32", 'todo="verify array length"'],
  "STRING[]"   => ["stringz", 'todo="verify array length"'],
  "STRINGLIST" => ["stringz", 'todo="maybe iterator"'],
);

my %prefixes = (
	"S_SID"    => 0xFF,
	"C_SID"    => 0xFF,
	"S_W3GS"   => 0xF7, # ???, prefix is not real
	"C_W3GS"   => 0xF7, # ???, prefix is not real
	"S_BNLS"   => 0x70, # fake, theres no header id byte
	"C_BNLS"   => 0x70, # fake, theres no header id byte
	"S_D2GS"   => 0x80, # fake, theres no header id byte
	"C_D2GS"   => 0x81, # fake, theres no header id byte
	"S_MCP"    => 0x90, # fake, theres no header id byte
	"C_MCP"    => 0x90, # fake, theres no header id byte
	"S_PACKET" => 0xA0, # fake, theres no header id byte (may be 0x01)
	"C_PACKET" => 0xA0, # fake, theres no header id byte (may be 0x01)
	"S_PKT"    => 0xB0, # fake, theres no header id byte
	"C_PKT"    => 0xB0, # fake, theres no header id byte
);

my %C_packets_by_id = ();
my %S_packets_by_id = ();
my %packet_names = ();
my $tmpbuf;
open (my $TMP, ">", \$tmpbuf);

select((select(STDERR), $| = 1)[0]); 

undef $/;

print STDERR "Reading input...";
my $htmldb = <>;
print STDERR "Done\n";
print STDERR "Parsing html...";
$htmltree->parse($htmldb);
$htmltree->eof();
print STDERR "Done\n";
print STDERR "Processing tables...";

my @tables = $htmltree->look_down("_tag", "table", "id", "code");

foreach my $table (@tables) {
	$current_raw = HTML::FormatText::WithLinks::AndTables->convert($table->as_HTML());
	$current_raw =~ s/[ ]*\n/\n/g;
	$current_raw =~ s/\n\n\n/\n/g;
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

close($TMP);

dump_packets;

print STDERR "Done\n";
exit (0);

sub Fix_AndTables {
   	package HTML::FormatText::WithLinks::AndTables;
	our @ISA;

	# No links, please. Make AndTables inherit from WithLinks.
	for (my $i=0; $i < @ISA; $i++) {
		if (${ISA[$i]} eq "HTML::FormatText::WithLinks") {
			${ISA[$i]} = "HTML::FormatText";
		}
	}
	# Provide the missing _parse method.
	sub _parse {
		my ($self, $tree) = @_;
		$self->format($tree);
	}
}

sub finish_current {
	if ($current_name ne "") {
		print $TMP "},\n";
		close ($TMP);
		if ($current_source eq "S") {
			$S_packets_by_id{${current_id}} = $tmpbuf;
		}
		else {
			$C_packets_by_id{${current_id}} = $tmpbuf;
		}
		open ($TMP, ">", \$tmpbuf);
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
	}
	if ($label =~ /Direction/) {
		if ($text =~ /Server[ ]*->[ ]*Client/) {
			$current_source = "S";
		}
		elsif ($text =~ /Client[ ]*->[ ]*Server/) {
			$current_source = "C";
		} else {
			die("Unknown direction: $text\n");
		}

		$current_name =~ /[[:space:]]*([A-Z0-9]+)_.*/;
		my $prefid = $prefixes{"${current_source}_$1"};
		print STDERR "Unknown prefix: ${current_source}_$1\n" unless $prefid;
		$current_id = $prefid * 0x100 + hex($current_id);
		if ($packet_names{$current_id} and
				$packet_names{$current_id} ne $current_name) {
			print STDERR qq"
WARN: $current_name and $packet_names{$current_id} have the same id.
$current_name will get a new random id.
";
			$current_id = int(rand(255)) * 0x100 + ($current_id % 0x100);
		}
		$packet_names{$current_id} = $current_name;

		print $TMP "--[[doc\n${current_raw}\n]]\n";
		my $real_id = $current_id % 0x100;
		print $TMP sprintf("[$current_name] = { -- 0x%02X\n", $real_id);
	}
	if ($label =~ /Format/) {
		my $formatted = $formatter->format($value);

		$formatted =~ s/^\n+//; # remove all leading \n
		$formatted =~ s/\n+$//; # remove all trailing \n 
		$formatted =~ s/\n\n/\n/g; # collapse multi \n to single \n 
		$formatted =~ s/\[blank\]//; # remove blank annotation

		# Match each field
		while ($formatted =~ /\(([A-Z]{2}[A-Z0-9_\[\]]*)\)\s*(.*?)(?m:[ ]*(?=\(|$))/g) {
			my $type = $1;
			my $name = $2;
			$name =~ s/\\/\\\\/g;
			$name =~ s/"/\\"/g;
			if (defined($typemap{$type})) {
				my @method = @{$typemap{$type}};
				if (${method[1]} ne "") {
					print $TMP "\t${method[0]}{label=\"${name}\", ${method[1]}},\n";
				} else {
					print $TMP "\t${method[0]}(\"${name}\"),\n";
				}
			} else {print "Unknown type: $type. In:\n$formatted\n"; }
		}
	}
}

sub dump_packets {
	open(my $CNST, ">", "constants.lua")
		or die("Couldn't open constants.lua");
	open(my $SRVR, ">", "spackets.lua")
		or die("Couldn't open spackets.lua");
	open(my $CLNT, ">", "cpackets.lua")
		or die("Couldn't open cpackets.lua");

	print $CNST q
"packet_names = {
";

	print $CLNT q
"-- Packets from client to server
CPacketDescription = {
";
	print $SRVR q
"-- Packets from server to client
SPacketDescription = {
";
	my @keys =  sort {$a <=> $b} keys %C_packets_by_id;
	
	foreach my $key (@keys) {
		print $CLNT $C_packets_by_id{$key};
	}

	@keys =  sort {$a <=> $b} keys %S_packets_by_id;
	
	foreach my $key (@keys) {
		print $SRVR $S_packets_by_id{$key};
	}

	@keys =  sort {$a <=> $b} keys %packet_names;
	
	foreach my $key (@keys) {
		print $CNST sprintf("#define ${packet_names{$key}}    0x%04X\n", $key);
		print $CNST sprintf("[${packet_names{$key}}] = \"${packet_names{$key}}\",\n", $key);
	}
	
	print $CNST "}\n";
	print $CLNT "}\n";
	print $SRVR "}\n";
	close ($SRVR);
	close ($CLNT);
	close ($CNST);
}