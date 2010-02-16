########################################################################
#
# pb-utils is free software; you can redistribute it and/or modify
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
#  Project      :  File Preprocessor - pb-utils module
#  Filename     :  $RCSfile: pb-utils.pm,v $
#  Author       :  
#  Maintainer   :  
#  File version :  
#  Last changed :  
#  Description  :  This module loads other modules used by packet-bnetp
#                  and holds some useful transformations.
#  Licence      :  GNU copyleft
#
########################################################################
# THIS IS A FILEPP MODULE, YOU NEED FILEPP TO USE IT!!!
# usage: filepp -m pb-utils.pm <files>
# usage: filepp -DREMOVE_LUA_COMMENTS_FIRST -m pb-utils.pm <files>
########################################################################

package PBUtils;

use strict;

# version number of module
my $VERSION = '1.2.0';

require "lua-comment.pm";

# remove all comments from string
sub ReplaceTime
{
	my $string = shift;
	my $newstring = "";
	my $datestr = localtime();

	foreach (split(/\n/, $string)) {
		s/%time%/$datestr/g;
		$newstring .= $_ . "\n";
	}
	return $newstring;
}

Filepp::AddProcessor("PBUtils::ReplaceTime");
    
return 1;

########################################################################
# End of file
########################################################################
