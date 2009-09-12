########################################################################
#
# cmacros is free software; you can redistribute it and/or modify
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
#  Project      :  File Preprocessor - cmacros module
#  Filename     :  $RCSfile: cmacros.pm,v $
#  Author       :  $Author: darren $
#  Maintainer   :  Darren Miller: darren@cabaret.demon.co.uk
#  File version :  $Revision: 1.2 $
#  Last changed :  $Date: 2002/10/16 21:59:45 $
#  Description  :  Quotes C macros (eg: __FILE__ file.c becomes "file.c")
#  Licence      :  GNU copyleft
#
########################################################################
# THIS IS A FILEPP MODULE, YOU NEED FILEPP TO USE IT!!!
# usage: filepp -m cmacros.pm <files>
########################################################################

package Cmacros;

use strict;

# version number of module
my $VERSION = '1.0.0';

# macros which get defined once when filepp starts
my @StaticMacros = (  "__DATE__",
		      "__TIME__",
		      "__VERSION__");
# macros which change during processing
my @DynamicMacros = ( "__BASE_FILE__",
		      "__FILE__");


########################################################################
# Function which checks all macros in list begin and end with "
########################################################################
sub UpdateMacros
{
    my @Macros = @_;
    my $macro;
    my $defn;
    foreach $macro (@Macros) {
	if(Filepp::Ifdef($macro)) {
	    $defn = Filepp::ReplaceDefines($macro);
	    if($defn !~ /\A\".*\"\Z/) {
		Filepp::Debug("cmacros: quoting macro $macro");
		Filepp::Define($macro." \"".$defn."\"");
	    }
	}
    }
}

########################################################################
# Startup - quote all macros
########################################################################
UpdateMacros(@StaticMacros);
UpdateMacros(@DynamicMacros);

########################################################################
# This function adds cmacros style information whenever the current file
# being processed changes
########################################################################
sub CheckMacros
{
    # take in current line and pass it on unaltered
    my $input = shift;
    UpdateMacros(@DynamicMacros);
    return $input;
}
Filepp::AddProcessor("Cmacros::CheckMacros", 1);

return 1;

########################################################################
# End of file
########################################################################
