########################################################################
#
# cpp is free software; you can redistribute it and/or modify
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
#  Project      :  File Preprocessor - cpp module
#  Filename     :  $RCSfile: cpp.pm,v $
#  Author       :  $Author: darren $
#  Maintainer   :  Darren Miller: darren@cabaret.demon.co.uk
#  File version :  $Revision: 1.5 $
#  Last changed :  $Date: 2003/08/10 22:27:23 $
#  Description  :  Makes filepp behave similar to cpp
#  Licence      :  GNU copyleft
#
########################################################################
# THIS IS A FILEPP MODULE, YOU NEED FILEPP TO USE IT!!!
# usage: filepp -m cpp.pm <files>
########################################################################

package Cpp;

use strict;

# version number of module
my $VERSION = '0.3.0';

my $last_file    = "";
my $last_line    = "";
my $last_include = -1;

my @SystemIncludes = ("/usr/include");
{
    my $include;
    foreach $include (@SystemIncludes) {
	Filepp::AddIncludePath($include);
    }
}

# This will remove all C and C++ comments (done after AddFileInfo)
Filepp::Define("REMOVE_C_COMMENTS_FIRST");
require "c-comment.pm";

########################################################################
# This function adds cpp style information whenever the current file
# being processed changes
########################################################################
sub AddFileInfo
{
    # take in next line
    my $input = shift;
    # get name of current file
    my $current_file    = Filepp::ReplaceDefines("__FILE__");
    my $current_line    = Filepp::ReplaceDefines("__LINE__");
    my $current_include = Filepp::ReplaceDefines("__INCLUDE_LEVEL__");
    # check if file has changed
    if($current_file ne $last_file) {
	# gcc cpp flags:
	# `1' This indicates the start of a new file.
	# `2' This indicates returning to a file (after having included
	# another file).
	# `3' This indicates that the following text comes from a system
	# header file, so certain warnings should be suppressed.
	# `4' This indicates that the following text should be treated as C. ?
	my $flags = "";
	my $last_flags = "";
	if($last_file ne "") {
	    # check for start of new file
	    if($current_include > $last_include) {
		$flags = " 1";
	    }
	    else { # returning
		$flags = " 2";
	    }
	}
	my $inc;
	foreach $inc (@SystemIncludes) {
	    if($current_file =~ /\A\"$inc/) { $flags = $flags." 3"; }
	    if($last_file =~ /\A\"$inc/)    { $last_flags = " 3"; }
	}
	
	if($last_file ne "") {
	    Filepp::Write("# ".$last_line." ".$last_file.$last_flags."\n");
	}	  
	Filepp::Write("# ".$current_line." ".$current_file.$flags."\n");
	$last_file = $current_file;
    }
    # updated number of lines processed
    $last_line = $current_line;
    $last_include = $current_include;
    # return the unmodified line
    return $input;
}
Filepp::AddProcessor("Cpp::AddFileInfo", 1);
Filepp::AddCloseInputFunc("Cpp::AddFileInfo");

# This will quote macros such as __FILE__
require "cmacros.pm";

# This will allow macros with args to be spread over several lines
require "blc.pm";

# This will make macro replacement more cpp line
Filepp::SetWordBoundaries(1);

return 1;

########################################################################
# End of file
########################################################################
