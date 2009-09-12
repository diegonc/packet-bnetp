########################################################################
#
# bigdef is free software; you can redistribute it and/or modify
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
#  Project      :  File Preprocessor - bigdef module
#  Filename     :  $RCSfile: bigdef.pm,v $
#  Author       :  $Author: darren $
#  Maintainer   :  Darren Miller: darren@cabaret.demon.co.uk
#  File version :  $Revision: 1.5 $
#  Last changed :  $Date: 2003/07/02 22:23:15 $
#  Description  :  Allows easy definition of multi-line macros
#  Licence      :  GNU copyleft
#
########################################################################
# THIS IS A FILEPP MODULE, YOU NEED FILEPP TO USE IT!!!
# usage: filepp -m bigdef.pm <files>
########################################################################

package Bigdef;

use strict;

# version number of module
my $VERSION = '1.0.1';

# current big definition
my $currentdef = "";

##############################################################################
# bigdef processor, when in a big define this eats all input (after processing
# for other keywords)
##############################################################################
sub Processor
{
    my $input = shift;
    $currentdef = $currentdef.$input;
    return "";
}


##############################################################################
# bigdef keyword - starts a bigdef
# same syntax as #define, only does not terminate until a #endbigdef is found
##############################################################################
sub Bigdef
{
    my $input = shift;
    # check not already in a bigdef
    if($currentdef ne "") {
      Filepp::Error("Nested bigdef's are not allowed");
    }
    # start macro definition
    $currentdef = $input."\n";
    # add processor - make it first in the list so all other processors are
    # ignored, this prevents any macro's in the bigdef being processed twice
    Filepp::AddProcessorAfter("Bigdef::Processor", "ParseKeywords", 1);
}

##############################################################################
# add bigdef keyword
##############################################################################
Filepp::AddKeyword("bigdef", "Bigdef::Bigdef");


##############################################################################
# endbigdef keyword
# no input, used to finish bigdef
##############################################################################
sub Endbigdef
{
    # check in bigdef
    if($currentdef eq "") {
      Filepp::Error("endbigdef found without preceding bigdef");
    }
    # remove processor
    Filepp::RemoveProcessor("Bigdef::Processor");
    # define macro
    Filepp::Define($currentdef);
    $currentdef = "";
}

##############################################################################
# add bigdef keyword
##############################################################################
Filepp::AddKeyword("endbigdef", "Bigdef::Endbigdef");

return 1;

########################################################################
# End of file
########################################################################
