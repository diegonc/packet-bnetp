########################################################################
#
# regexp is free software; you can redistribute it and/or modify
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
#  Project      :  File Preprocessor - regexp module
#  Filename     :  $RCSfile: regexp.pm,v $
#  Author       :  $Author: darren $
#  Maintainer   :  Darren Miller: darren@cabaret.demon.co.uk
#  File version :  $Revision: 1.8 $
#  Last changed :  $Date: 2007/02/16 07:04:33 $
#  Description  :  This implements regular expression replacement routines
#  Licence      :  GNU copyleft
#
########################################################################
# THIS IS A FILEPP MODULE, YOU NEED FILEPP TO USE IT!!!
# usage: filepp -m regexp.pm <files>
########################################################################
package Regexp;

use strict;

# version number of module
my $VERSION = '1.0.2';

my @Regexp;  # list of regular expressions
my @Replace; # list of replacements for regular expressions

########################################################################
# Function to read regular expression
########################################################################
sub ParseRegexp
{
    my $input = shift;
    my @Args= split(/((?<!\\)\/)/, $input);
    if($#Args == 5 && $Args[1] eq "/" && $Args[3] eq "/" && $Args[5] eq "/") {
	return (1, $Args[2], $Args[4]);
    }    
    Filepp::Warning("Regexp: could not parse <$input>");
    return 0;
}

########################################################################
# Regular expression keyword
########################################################################
sub AddRegexp
{
    my $input = shift;
    my ($parseok, $regexp, $replace) = ParseRegexp($input);
    if($parseok) {
	Filepp::Debug("Regexp: Adding regexp /$regexp/$replace/");
	push(@Regexp, $regexp);
	push(@Replace, $replace);
    }
}
Filepp::AddKeyword("regexp", "Regexp::AddRegexp");

########################################################################
# Removes a regular expression
########################################################################
sub RmRegexp
{
    # Note: this only removes the first occurence of the regular expression
    # if the regular expression is multiply defined.
    my $input = shift;
    my ($parseok, $regexp, $replace) = ParseRegexp($input);
    if($parseok) {
	my $i = 0;
	# find regexp
	while($i<=$#Regexp &&
	      !($Regexp[$i] eq $regexp && $Replace[$i] eq $replace)) { $i++; }
	# remove regexp if found
	if($i<=$#Regexp) {
	    for(; $i<$#Regexp; $i++) {
		$Regexp[$i] = $Regexp[$i+1];
		$Replace[$i] = $Replace[$i+1];
	    }
	    Filepp::Debug("Regexp: Removed regexp /$regexp/$replace/");
	    pop(@Regexp);
	    pop(@Replace);
	}
    }
}
Filepp::AddKeyword("rmregexp", "Regexp::RmRegexp");

########################################################################
# Show current regexp list - only works in debug mode
########################################################################
sub ShowRegexp
{
    Filepp::Debug("Regexp: current regular expressions:");
    my $i;    
    for($i = 0; $i <= $#Regexp; $i++) {
	Filepp::Debug("Regexp ".$i.":\t/".$Regexp[$i]."/".$Replace[$i]."/");
    }    
}

########################################################################
# Regular expression replacement routine
########################################################################
sub ReplaceRegexp
{
    my $string = shift;
    my $i;
    
    for($i = 0; $i <= $#Regexp; $i++) {
	my $regexp = Filepp::RunProcessors($Regexp[$i], 2);
	my $replace = Filepp::RunProcessors($Replace[$i], 2);
	# eval is used to make sure all \1 etc. are converted correctly
 	my $evalstring = sprintf "\$string =~ s/$regexp/$replace/g";
	Filepp::Debug("Regexp: <$evalstring> with string = <$string>", 2);
 	eval $evalstring;
	Filepp::Debug("Regexp output: <$string>", 2);
    }
    
    return $string;
}
Filepp::AddProcessor("Regexp::ReplaceRegexp");

########################################################################
# Check for command line specifiled regexp (only one allowed)
########################################################################
if(Filepp::Ifdef("REGEXP")) {
    my $input = Filepp::ReplaceDefines("REGEXP");
    my ($parseok, $regexp, $replace) = ParseRegexp($input);
    if($parseok) {
	AddRegexp($input);
	Filepp::Undef("REGEXP");
    }
}

return 1;
########################################################################
# End of file
########################################################################
