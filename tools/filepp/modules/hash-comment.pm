########################################################################
#
# hash-comment is free software; you can redistribute it and/or modify
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
#  Project      :  File Preprocessor - hash-comment module
#  Filename     :  $RCSfile: hash-comment.pm,v $
#  Author       :  $Author: darren $
#  Maintainer   :  Darren Miller: darren@cabaret.demon.co.uk
#  File version :  $Revision: 1.5 $
#  Last changed :  $Date: 2003/07/02 22:23:15 $
#  Description  :  This module removes all # style comments as used by
#                  Perl, make, sh, csh and lots of other stuff
#  Licence      :  GNU copyleft
#
########################################################################
# THIS IS A FILEPP MODULE, YOU NEED FILEPP TO USE IT!!!
# usage: filepp -m hash-comment.pm <files>
########################################################################

package HashComment;

use strict;

# version number of module
my $VERSION = '1.2.0';

require "comment.pm";

# remove all comments from string
sub RemoveComments
{
    my $string = shift;
    return Comment::RemoveComments("#", $string);
}
if(Filepp::Ifdef("REMOVE_HASH_COMMENTS_FIRST")) {
    Filepp::Undef("REMOVE_HASH_COMMENTS_FIRST");
    Filepp::AddProcessor("HashComment::RemoveComments", 1);
}
else {
    Filepp::AddProcessor("HashComment::RemoveComments");
}

return 1;

########################################################################
# End of file
########################################################################
