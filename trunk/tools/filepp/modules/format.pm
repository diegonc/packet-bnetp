########################################################################
#
# format is free software; you can redistribute it and/or modify
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
#  Project      :  File Preprocessor - format module
#  Filename     :  $RCSfile: format.pm,v $
#  Author       :  $Author: darren $
#  Maintainer   :  Darren Miller: darren@cabaret.demon.co.uk
#  File version :  $Revision: 1.6 $
#  Last changed :  $Date: 2002/01/06 21:23:12 $
#  Description  :  This implements text formatting routines
#  Licence      :  GNU copyleft
#
########################################################################
# THIS IS A FILEPP MODULE, YOU NEED FILEPP TO USE IT!!!
# usage: filepp -m format.pm <files>
########################################################################
package Format;

use strict;

# version number of module
my $VERSION = '1.0.0';

require "function.pm";


##############################################################################
# CleanStartEnd($sline) - strip leading whitespace from start and end of
# $sline
##############################################################################
sub CleanStartEnd
{
    my $sline = shift;
    for($sline) {
	# '^' = start of line, '\s+' means all whitespace, replace with nothing
	s/^\s+//;
	# '$' = end of line, '\s+' means all whitespace, replace with nothing
	s/\s+$//m;
    }
    return $sline;
}

########################################################################
# Similar to C and Perl printf statement
# usage: printf(format, items...)
########################################################################
sub Printf
{
    my @Args = reverse(@_);
    my $arg;
    # remove double quotes from input args if there
    foreach $arg (@Args) { # remove "" from start/end of strings
	if($arg =~ /\A\s*\"/ && $arg =~ /\"\s*\Z/) {
	    $arg = CleanStartEnd($arg);
	    $arg = Filepp::Strip($arg, "\"", 1);
	}
    }
    my $format = pop(@Args);
    # replace \n, \t etc with newline, tab, etc.
    # HELP: there must be a better way than this, I've tried qq/$foramt/, 
    # regexps $format =~ s/\\(.)/"\\$1"/eg etc.
    # and this only working solution I have found.
    $format =~ s/\\t/"\t"/ge; # tab
    $format =~ s/\\n/"\n"/ge; # newline
    $format =~ s/\\r/"\r"/ge; # return
    $format =~ s/\\f/"\f"/ge; # formfeed
    $format =~ s/\\b/"\b"/ge; # backspace
    $format =~ s/\\a/"\a"/ge; # alarm
    $format =~ s/\\e/"\e"/ge; # escape
    return sprintf($format, reverse(@Args));
}
Function::AddFunction("printf", "Format::Printf");


########################################################################
# converts input to upper case
# usage: toupper(string)
########################################################################
sub ToUpper
{
    my $string = shift;
    return uc($string);
}
Function::AddFunction("toupper", "Format::ToUpper");

########################################################################
# converts first char of input to upper case
# usage: toupper(string)
########################################################################
sub ToUpperFirst
{
    my $string = shift;
    return ucfirst($string);
}
Function::AddFunction("toupperfirst", "Format::ToUpperFirst");

########################################################################
# converts input to lower case
# usage: tolower(string)
########################################################################
sub ToLower
{
    my $string = shift;
    return lc($string);
}
Function::AddFunction("tolower", "Format::ToLower");

########################################################################
# converts first char of input to lower case
# usage: tolower(string)
########################################################################
sub ToLowerFirst
{
    my $string = shift;
    return lcfirst($string);
}
Function::AddFunction("tolowerfirst", "Format::ToLowerFirst");

########################################################################
# extract a substring out of input
# usage: substr(string, offset, len)
########################################################################
sub Substr
{
    my $string = shift;
    my $offset = shift;
    if($#_ >= 0) { # also got length arg
	my $length = shift;
	return substr($string, $offset, $length);
    }
    return substr($string, $offset);
}
Function::AddFunction("substr", "Format::Substr");

return 1;
########################################################################
# End of file
########################################################################
