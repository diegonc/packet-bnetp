########################################################################
#
# bigfunc is free software; you can redistribute it and/or modify
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
#  Project      :  File Preprocessor - bigfunc module
#  Filename     :  $RCSfile: bigfunc.pm,v $
#  Author       :  $Author: darren $
#  Maintainer   :  Darren Miller: darren@cabaret.demon.co.uk
#  File version :  $Revision: 1.16 $
#  Last changed :  $Date: 2007/02/17 18:55:31 $
#  Description  :  This allows last minute processing of stuff
#  Licence      :  GNU copyleft
#
########################################################################
# THIS IS A FILEPP MODULE, YOU NEED FILEPP TO USE IT!!!
# usage: filepp -m bigfunc.pm <files>
########################################################################
package Bigfunc;

use strict;

# version number of module
my $VERSION = '1.0.0';

require "function.pm";
require "grab.pm";

my %Defines;
my %DefineArgs;

my $firstline = "";

########################################################################
# Bigfunc keyword - same as bigdef - only difference is any keywords
# in the macro are evaluated when the macro is called rather than
# when the macro is defined.
########################################################################
sub Bigfunc
{
    $firstline = shift;
    
    # check there are brackets () in the function name
    if($firstline !~ /\(/) {
	Filepp::Error("bigfunc: macro must have brackets [use macro() for 0 arguments]");
      }
    
    # grab all input until endbigfunc
    Grab::StartGrab("bigfunc", "endbigfunc");
}
Filepp::AddKeyword("bigfunc", "Bigfunc::Bigfunc");

########################################################################
# EndBigfunc keyword
########################################################################
sub EndBigfunc
{
    # check endbigfunc is after a bigfunc
    if($firstline eq "") {
	Filepp::Error("endbigfunc found without preceding bigfunc");
    }
    # get input from grab module
    my @Input = Grab::GetInput();
    my $macrodefn = join("", $firstline, "\n", @Input);
    # reset firstline
    $firstline = "";
    
    # define the macro temporarily (gets redefined as a function later)
    Filepp::Define($macrodefn);

    # get the defined macro back
    my ($macro, $junk) = split(/\(/, $macrodefn, 2);
    my ($defn, $args) = Filepp::GetDefine($macro);
    
    # store args if any given
    if(defined($args)) { $DefineArgs{$macro} = $args; }

    # define the macro defn pair
    $Defines{$macro} = $defn;
    
    # add a function which will call this macro
    Function::AddFunction($macro, "Bigfunc::Run");
}
Filepp::AddKeyword("endbigfunc", "Bigfunc::EndBigfunc");


########################################################################
# Function to parse the bigfunc
########################################################################
sub Run
{
    my $macro = Filepp::FunctionMacro();
    my @Argvals = @_;
    my @Argnames = split(/\,/, $DefineArgs{$macro});
    
    my $parseline = Filepp::GetParseLineEnd();
    # split macro into single lines
    my @Input = split(/\n/, $Defines{$macro});
    my $output = "";
    my $i = 0;
    my %Dummy = ();
    
    # process all lines in macro
    while($i <= $#Input)  {
	my $tail = "";
	my $string;
    
	# replace any arguments
	($string, $tail) = Filepp::ArgReplacer(\@Argvals, \@Argnames,
					       $macro, $Input[$i], $tail,
					       %Dummy);
	$Input[$i] = $string.$tail;
	# run processing chain before here to catch up
	$output .= Filepp::RunProcessors($Input[$i++]."\n", 1);
    }
    
    return $output;
}


return 1;
########################################################################
# End of file
########################################################################
