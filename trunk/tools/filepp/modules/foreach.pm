########################################################################
#
# foreach is free software; you can redistribute it and/or modify
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
#  Project      :  File Preprocessor - foreach loop module
#  Filename     :  $RCSfile: foreach.pm,v $
#  Author       :  $Author: darren $
#  Maintainer   :  Darren Miller: darren@cabaret.demon.co.uk
#  File version :  $Revision: 1.8 $
#  Last changed :  $Date: 2007/02/17 17:26:30 $
#  Description  :  Implements a simple foreach loop
#  Licence      :  GNU copyleft
#
########################################################################
# THIS IS A FILEPP MODULE, YOU NEED FILEPP TO USE IT!!!
# usage: filepp -m foreach.pm <files>
########################################################################

package Foreach;

use strict;

# version number of module
my $VERSION = '1.1.0';

# uses grab module
require "grab.pm";

# delimiter used to split list
my $delim = "\\s*,\\s*";

# contains foreach structure:
# $line = line foreach loop started
# $macro = macro defined by foreach
# @Values = list of values macro should be defined to
my @Foreachloops = ();

# set when end of foreach loop reached which did not evaluate to true
# foreach first loop, at this point parsing skips to end foreachloop.
# If they are inner loops the inner foreach is skipped, but the inner
# endforeach is not leading to more endforeach's than foreach's.  This
# flag says it is ok to ignore them.
my $ignore_end = 0;


##############################################################################
# foreachdelim keyword, allows user to set list delimiter, input:
# /delimiter/
##############################################################################
sub ForeachDelim
{
    my $newdelim = shift;
    # remove initial /
    $newdelim =~ s/\A\s*\///;
    # remove final /
    $newdelim =~ s/\/\s*\Z//;
    $delim = $newdelim;
    Filepp::Debug("Foreach: set delimiter to <$delim>");
}
Filepp::AddKeyword("foreachdelim", "Foreach::ForeachDelim");

##############################################################################
# foreach keyword, input:
# macro start comparison end increment
# loop of foreachm:
# foreach(macro, @List)
#   ops
# endforeach
##############################################################################
sub Foreach
{
    my $input = shift;
    # split up line
    my $macro;
    my $list;
    my $i;
    
    # find end of macroword - assume separated by space or tab
    $i = Filepp::GetNextWordEnd($input);
    
    # separate macro and defn (can't use split, doesn't work with '0')
    $macro = substr($input, 0, $i);
    $list  = substr($input, $i);
    
    # strip leading whitespace from $val
    if($list) {
	$list =~ s/^[ \t]*//;
    }
    $list = Filepp::RunProcessors($list);
    
    # split up list
    my @List = split(/$delim/, $list);
    
    Filepp::Debug("Foreach: $macro, /$delim/, $list\n");

    my $line = 0;
    if(Filepp::Ifdef("__LINE__")) {
	$line = Filepp::ReplaceDefines("__LINE__");
    }    
    # add data structure to current foreach list
    my @ThisForeach = ($line, $macro, @List);
    push(@Foreachloops, \@ThisForeach);

    # foreach loop ok, set up data structure and go
    if($#List >= 0) {
	Filepp::Debug("Foreach: $macro loop started");
	# in a valid foreach loop, make sure all endforeach's are
	# treated as valid
	$ignore_end = 0;
	# grab all input up to corresponding endforeach keyword
	Grab::StartGrab("foreach", "endforeach");
	# in foreach loop - return 1 to Parse
	return 1;
    }
    # have not entered loop, be ready foreach excess endforeach's
    $ignore_end = 1;
    # foreach loop comparison failed, skip to endforeach - return 0 to Parse
    Filepp::Debug("Foreach: $macro loop not entered");
    return 0;
}

##############################################################################
# add foreach keyword - also an ifword
##############################################################################
Filepp::AddKeyword("foreach", "Foreach::Foreach");
Filepp::AddIfword("foreach");


##############################################################################
# endforeach keyword
# no input, used to terminate foreachloop
##############################################################################
sub EndForeach
{
    # check endforeach is at a valid position - otherwise ignore it
    # (filepp will give an error if it is out of place)
    if($#Foreachloops < 0) { return 1; }
    
    # pop current foreach loop info off top of list
    my @ThisForeach = @{pop(@Foreachloops)};
    my ($line, $macro, @List) = @ThisForeach;

    # get grabbed input from grab moudule
    my @Input = Grab::GetInput();
    # get line number (add 1 coz first_line is for #foreach keyword)
    my $first_line = Grab::GetInputLine() + 1;
    my $real_line = Filepp::ReplaceDefines("__LINE__");

    # run loop for each value in list
    my $val;
    foreach $val (@List) {
	# fix line number
	my $line = $first_line;

	Filepp::Define("$macro $val");
	Filepp::Debug("Foreach: $macro loop continuing with value $val");

	# parse all input between start and end of loop
	my $input;
	foreach $input (@Input) {
	    Filepp::Redefine("__LINE__", $line++);
	    Filepp::ProcessLine($input);
	}
    }

    Filepp::Redefine("__LINE__", $real_line);
    # end of loop, return 1 to Parse so it moves on
    Filepp::Debug("Foreach: $macro loop end");
    return 1;
}

##############################################################################
# add foreach keyword - also an endif word
##############################################################################
Filepp::AddKeyword("endforeach", "Foreach::EndForeach");
Filepp::AddEndifword("endforeach");

return 1;

########################################################################
# End of file
########################################################################
