########################################################################
#
# function is free software; you can redistribute it and/or modify
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
#  Project      :  File Preprocessor - function module
#  Filename     :  $RCSfile: function.pm,v $
#  Author       :  $Author: darren $
#  Maintainer   :  Darren Miller: darren@cabaret.demon.co.uk
#  File version :  $Revision: 1.6 $
#  Last changed :  $Date: 2007/02/16 07:04:32 $
#  Description  :  This module adds the function keyword which allows you
#                  to have macros which call Perl functions
#                  being replaces
#  Licence      :  GNU copyleft
#
########################################################################
# THIS IS A FILEPP MODULE, YOU NEED FILEPP TO USE IT!!!
# usage: filepp -m function.pm <files>
########################################################################

package Function;

use strict;

# version number of module
my $VERSION = '1.1.0';

########################################################################
# AddFunction(macro, function) 
# adds a function to list, inputs:
# macro:    macro which will call function
# function: function to call when macro found
########################################################################
sub AddFunction {
    my ($macro, $function) = @_;
    Filepp::Define($macro."(...)");
    Filepp::SetDefineFuncs($macro, $function);
    Filepp::Debug("Function: added function macro $macro which calls $function");
}

########################################################################
# Function($string)
# keyword frontend to AddFunction
########################################################################
sub Function {
    my $input = shift;
    my ($macro, $function) = split(/\s+/, $input, 2);
    AddFunction($macro, $function);
}
Filepp::AddKeyword("function", "Function::Function");


##############################################################################
# RemoveFunction(macro)
# macro is deleted from list, all occurrences of macro found in
# document are ignored.
##############################################################################
sub RemoveFunction
{
    my $macro = shift;
    Filepp::Undef($macro);
    Filepp::Debug("Function: removed function macro $macro");
}

########################################################################
# Rmunction($string)
# keyword frontend to RemoveFunction
########################################################################
sub Rmfunction {
    my $input = shift;
    my ($macro) = split(/\s+/, $input, 1);
    RemoveFunction($macro);
}
Filepp::AddKeyword("rmfunction", "Function::Rmfunction");

return 1;

########################################################################
# End of file
########################################################################
