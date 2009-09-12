########################################################################
#
# defplus is free software; you can redistribute it and/or modify
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
#  Project      :  File Preprocessor - defplus module
#  Filename     :  $RCSfile: defplus.pm,v $
#  Author       :  $Author: darren $
#  Maintainer   :  Darren Miller: darren@cabaret.demon.co.uk
#  File version :  $Revision: 1.2 $
#  Last changed :  $Date: 2002/08/11 13:18:22 $
#  Description  :  Allows easy definition of multi-line macros
#  Licence      :  GNU copyleft
#
########################################################################
# THIS IS A FILEPP MODULE, YOU NEED FILEPP TO USE IT!!!
# usage: filepp -m defplus.pm <files>
########################################################################

package Defplus;

use strict;

# version number of module
my $VERSION = '1.0.0';

##############################################################################
# defplus keyword - starts a defplus
# same syntax as #define, only does not terminate until a #enddefplus is found
##############################################################################
sub Defplus
{
    my $macrodefn = shift;
    my $macro;
    my $defn;
    my $i;
    
    # find end of macroword - assume separated by space or tab
    $i = Filepp::GetNextWordEnd($macrodefn);
    
    # separate macro and defn (can't use split, doesn't work with '0')
    $macro = substr($macrodefn, 0, $i);
    $defn  = substr($macrodefn, $i);

    # check if macro is already defined
    if(Filepp::Ifdef($macro)) {
	# append definition to current definition
	$defn = Filepp::GetDefine($macro).$defn;
    }
    Filepp::Define($macro." ".$defn);
}

##############################################################################
# add defplus keyword
##############################################################################
Filepp::AddKeyword("defplus", "Defplus::Defplus");

return 1;

########################################################################
# End of file
########################################################################
