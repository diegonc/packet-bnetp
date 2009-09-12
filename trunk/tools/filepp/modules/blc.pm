########################################################################
#
# elc is free software; you can redistribute it and/or modify
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
#  Project      :  File Preprocessor - elc module
#  Filename     :  $RCSfile: blc.pm,v $
#  Author       :  $Author: darren $
#  Maintainer   :  Darren Miller: darren@cabaret.demon.co.uk
#  File version :  $Revision: 1.2 $
#  Last changed :  $Date: 2003/07/30 12:08:01 $
#  Description  :  Allows easy definition of multi-line macros
#  Licence      :  GNU copyleft
#
########################################################################
# THIS IS A FILEPP MODULE, YOU NEED FILEPP TO USE IT!!!
# usage: filepp -m elc.pm <files>
########################################################################

########################################################################
# Thanks to Zousar Shaker for writing the original version of this function
########################################################################

package Blc;

use strict;

# version number of module
my $VERSION = '1.1.0';

##############################################################################
# ParseLineEnd - See ParseLineEnd in filepp for full description of how this
# function works.
# This version differs from normal in that line is continued if line
# continuation character is at end of line or if there are more ('s on
# a line than )'s (not including \( and \) )
##############################################################################
sub ParseLineEnd
{
    my $thisline = shift;
    my $more = 0;

    # check for normal style line continuation
    ($more, $thisline) = Filepp::ParseLineEnd($thisline);

    # if line not being continued already, check to see if it should be
    if($more == 0) {
	# check if end of line has more open brackets than close brackets
 	my @Open  = ($thisline =~ /(?=[^\\]\()/g);
 	my @Close = ($thisline =~ /(?=[^\\]\))/g);
	if($#Open > $#Close) {
	    $more = 1;
	    # remove newline and replace with single space
	    $thisline =~ s/\n\Z/\ /;
	}
	# if line has ended - deal with escaped brackets
	else {
	    # replace '\(' and '\)' with '(' and ')'
	    $thisline =~ s/\\\(/\(/g;
	    $thisline =~ s/\\\)/\)/g;
	}	
    }
    return ($more, $thisline);
}

##############################################################################
# set elc as line contination function
##############################################################################
Filepp::SetParseLineEnd("Blc::ParseLineEnd");

return 1;

########################################################################
# End of file
########################################################################
