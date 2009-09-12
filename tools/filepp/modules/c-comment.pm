########################################################################
#
# c-comment is free software; you can redistribute it and/or modify
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
#  Project      :  File Preprocessor - c-comment module
#  Filename     :  $RCSfile: c-comment.pm,v $
#  Author       :  $Author: darren $
#  Maintainer   :  Darren Miller: darren@cabaret.demon.co.uk
#  File version :  $Revision: 1.7 $
#  Last changed :  $Date: 2003/07/02 22:23:15 $
#  Description  :  This module removes all C and C++ style comments from
#                  a file.
#  Licence      :  GNU copyleft
#
########################################################################
# THIS IS A FILEPP MODULE, YOU NEED FILEPP TO USE IT!!!
# usage: filepp -m c-comment.pm <files>
########################################################################

package CComment;

use strict;

# version number of module
my $VERSION = '1.2.0';

require "comment.pm";

# remove all comments from string
sub RemoveComments
{
    my $string = shift;

    # remove all C++ style comments
    $string = Comment::RemoveComments("//", $string);
    
    # remove all C comments
    my $newstring = Comment::RemoveComments("/\\*", $string);
    while($string =~ /\S/ && $newstring ne $string) {
	# remove newline that may have been added by RemoveComments
	if($newstring =~ /\n$/) { chomp($newstring); }
	# start of comment has been removed - find closing */
	# get rest of string and check for end of comment in this line
	$string = Comment::GetLineEnd();
	
	if($string =~ /\*\//) {
	    # get rest of line
	    my $line = $'; # one more quote for emacs '
	    $string = $newstring.$line;
	}
	# multi-line comment
	else {
	    # find line with end of comment
	    $string = Filepp::GetNextLine();
	    my $newlines = 1;
	    while($string && $string !~ /\*\//) {
		$string = Filepp::GetNextLine();
		$newlines++;
	    }	    
	    if($string) {
		# get rest of line following end of comment
		$string = $newstring.substr($string, index($string, "*/")+2);
	    }
	    else {
		$string = $newstring;
	    }
	    # make number of lines in output equal to number of lines in input
	    while($newlines-- > 0) {
		if($newstring =~ /\S/) { $string = $string."\n"; }
		else { $string = "\n".$string; }
	    }
	}
	# check for more comments on this line
	$newstring = Comment::RemoveComments("/\\*", $string);
    }
    
    return $string;
}
if(Filepp::Ifdef("REMOVE_C_COMMENTS_FIRST")) {
    Filepp::Undef("REMOVE_C_COMMENTS_FIRST");
    Filepp::AddProcessor("CComment::RemoveComments", 1);
}
else {
    Filepp::AddProcessor("CComment::RemoveComments");
}
    
return 1;

########################################################################
# End of file
########################################################################
