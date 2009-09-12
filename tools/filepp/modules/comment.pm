########################################################################
#
# comment is free software; you can redistribute it and/or modify
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
#  Project      :  File Preprocessor - comment module
#  Filename     :  $RCSfile: comment.pm,v $
#  Author       :  $Author: darren $
#  Maintainer   :  Darren Miller: darren@cabaret.demon.co.uk
#  File version :  $Revision: 1.5 $
#  Last changed :  $Date: 2007/02/16 19:40:00 $
#  Description  :  This module contains a function to remove all
#                  comments where the comment is defined as all
#                  characters on a line following the string $comment
#  Licence      :  GNU copyleft
#
########################################################################
# THIS IS A FILEPP MODULE, YOU NEED FILEPP TO USE IT!!!
# usage: normally called from within another module, see
# hash-comment.pm and c-comment.pm
########################################################################

package Comment;

use strict;

# version number of module
my $VERSION = '1.0.0';

my $string;

# remove all comments from string
# inputs:
#         comment - the comment, a string or char
#         string  - the input string which may contain comments to be removed
# outputs:
#         output  - the string with the comment removed
sub RemoveComments
{
    my $comment = shift;
    $string = shift;
    my $output = "";

    if($string !~ /$comment/m) {
	return $string;
    }
    
    my $line = $string;
    foreach $string (split(/\n/, $line)) {
	my $search = 1;
	
	while($search) {
	    # check for comment in string
	    if($string =~ /$comment/) {
		# keep everything before first comment
		$output = $output.$`;
		# set string to everything after comment
		$string = $';   # one more quote for emacs '	    
		# make note of removed part of string
		my $removed = $&;
		
		# check comment is not enclosed in quotes eg: "#",
		# count number of '"' in string and if odd then comment in quotes
		my @Count = ($output =~ /[^\\]\"/g);
		if($#Count % 2 != 0) { # if true comment is NOT in quotes
		    $search = 0;
		}
		# put comment back onto string
		else { $output = $output.$removed; }
	    }
	    else {
		$output = $output.$string;
		$search = 0;
	    }
	}
	
	# put newline back
	$output = $output."\n";
    }
    
    return $output;
}

# return whatever is left of the last line processed after comment removal
sub GetLineEnd
{
    return $string;
}

return 1;

########################################################################
# End of file
########################################################################
