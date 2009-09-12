########################################################################
#
# grab is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; see the file COPYING.  If not, write to
# the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.
#
########################################################################
#
#  Project      :  File Preprocessor - grab module
#  Filename     :  $RCSfile: grab.pm,v $
#  Author       :  $Author: darren $
#  Maintainer   :  Darren Miller: darren@cabaret.demon.co.uk
#  File version :  $Revision: 1.6 $
#  Last changed :  $Date: 2007/02/17 17:40:05 $
#  Description  :  Grabs all input and stores it for later use
#  Licence      :  GNU copyleft
#
########################################################################
# THIS IS A FILEPP MODULE, YOU NEED FILEPP TO USE IT!!!
# usage: filepp -m grab.pm <files>
########################################################################

package Grab;

use strict;

# version number of module
my $VERSION = '1.0.0';

# list of keywords which signify start of input grabbing - entry in
# hash is corresponding stop keyword:  start->stop
my %StartKeywords = ( 'grab' => 'endgrab' );
# list of keywords which signify end of input grabbing - entry in
# hash is corresponding start keyword:  stop->start
my %EndKeywords  = ( 'endgrab' => 'grab' );
# stack of nested keywords which start and stop input grabbing
my @KeywordStack = ();

# grabbed input
my @Input = ();
# line number grabbing started at
my $line = -1;

########################################################################
# Processor which grabs all input
########################################################################
sub GrabInput
{
    my $input = shift;
    # check for start/end grabbing keywords
    my $thisline = Filepp::CleanStart($input);
    my $keywordchar = Filepp::GetKeywordchar();
    my $keyword = "";

    if($thisline && $thisline =~ /^$keywordchar/) {
	# remove "#" and any following whitespace
	$thisline =~ s/^$keywordchar\s*//g;
	# check for start keyword
	if($thisline && $thisline =~ /^\w+\b/) {
	    $keyword = $&;
	    if(exists($StartKeywords{$keyword})) {
		push(@KeywordStack, $StartKeywords{$keyword});
		Filepp::Debug("Grab: found start keyword ".$keyword.
			      " in grabbed input - adding ".
			      $StartKeywords{$keyword}." to stack at level ".
			      $#KeywordStack);
	    }
	    elsif(exists($EndKeywords{$keyword})) {
		if($keyword eq $KeywordStack[$#KeywordStack]) {
		    Filepp::Debug("Grab: found end keyword ".$keyword.
				  " in grabbed input at stack level ".
				  $#KeywordStack);
		    pop(@KeywordStack);
		}
		else {
		    Filepp::Warning("Found unexpected end keyword ".$keyword.
				    " in grabbed input at stack level".
				    $#KeywordStack);
		}
	    }
	}
    }
    
    # check if input grabbing should stop - stops when KeywordStack empty
    if($#KeywordStack <= -1) {
	Filepp::RemoveProcessor("Grab::GrabInput");
	Filepp::Debug("Grab: ended grabbing input at keyword: ".$keyword);
	# return keyword - will cause keyword function to run
	return $input;
    }
    else {
	# grab input
	push(@Input, $input);
    }
    
    return "";
}

########################################################################
# Start grabbing input
########################################################################
sub StartGrab
{
    my $start = shift;  # start keyword
    my $end = shift;    # end keyword
    $StartKeywords{$start} = $end;
    $EndKeywords{$end} = $start;

    # make a note of line number
    $line = -1;
    if(Filepp::Ifdef("__LINE__")) {
	$line = Filepp::ReplaceDefines("__LINE__");
    }

    # reset KeywordStack and Input - stops all existing grabbing
    @KeywordStack = ( $StartKeywords{$start} );
    @Input = ();
    # put GrabInput processor at start of processing chain
    Filepp::AddProcessor("Grab::GrabInput", 1, 1);
    Filepp::Debug("Grab: started grabbing input from keyword: ".$start.
		  " at line ".$line);
}

########################################################################
# GetInput - returns last input grabbed
########################################################################
sub GetInput
{
    return @Input;
}

########################################################################
# GetInputLine - returns line input grab started at
########################################################################
sub GetInputLine
{
    return $line;
}

########################################################################
# Start grabbing input
########################################################################
sub Grab
{
    StartGrab("grab", "endgrab");
}
Filepp::AddKeyword("grab", "Grab::Grab");


########################################################################
# End grabbing of input - mainly for testing
########################################################################
sub EndGrab
{
    my $output = "";

    my @ThisInput = GetInput();
    my $this_line = GetInputLine() + 1;
    my $real_line = Filepp::ReplaceDefines("__LINE__");

    my $input;
    foreach $input (@ThisInput) {
	Filepp::Redefine("__LINE__", $this_line++);
	Filepp::ProcessLine($input);
    }
    Filepp::Redefine("__LINE__", $real_line);
}
Filepp::AddKeyword("endgrab", "Grab::EndGrab");


return 1;

########################################################################
# End of file
########################################################################
