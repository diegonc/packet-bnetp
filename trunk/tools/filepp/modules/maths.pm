########################################################################
#
# maths is free software; you can redistribute it and/or modify
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
#  Project      :  File Preprocessor - maths module
#  Filename     :  $RCSfile: maths.pm,v $
#  Author       :  $Author: darren $
#  Maintainer   :  Darren Miller: darren@cabaret.demon.co.uk
#  File version :  $Revision: 1.3 $
#  Last changed :  $Date: 2001/09/04 22:21:58 $
#  Description  :  This implements simple maths routines
#  Licence      :  GNU copyleft
#
########################################################################
# THIS IS A FILEPP MODULE, YOU NEED FILEPP TO USE IT!!!
# usage: filepp -m maths.pm <files>
########################################################################
package Maths;

use strict;

# version number of module
my $VERSION = '1.0.0';

require "function.pm";

########################################################################
# Define Pi as M_PI
########################################################################
Filepp::Define("M_PI 3.14159265358979323846");
Filepp::Define("M_E 2.7182818284590452354");

########################################################################
# Add all input, usage: - ANY NUMBER OF INPUTS
# Add(a, b, ....)
########################################################################
sub Add
{
    my $sum = 0;
    my $arg;
    foreach $arg (@_) { $sum += $arg; }
    return $sum;
}
Function::AddFunction("add", "Maths::Add");

########################################################################
# Multiply all inputs, usage: - ANY NUMBER OF INPUTS
# Mul(a, b, ....)
########################################################################
sub Mul
{
    my $mul = 1;
    my $arg;
    foreach $arg (@_) { $mul *= $arg; }
    return $mul;
}
Function::AddFunction("mul", "Maths::Mul");

########################################################################
# Subtract b from a, usage: - TWO INPUTS ONLY
# Sub(a, b)
########################################################################
sub Sub
{
    my ($a, $b) = @_;
    return $a - $b;
}
Function::AddFunction("sub", "Maths::Sub");

########################################################################
# Divide a/b, usage: - TWO INPUTS ONLY
# Div(a, b)
########################################################################
sub Div
{
    my ($a, $b) = @_;
    return $a / $b;
}
Function::AddFunction("div", "Maths::Div");

########################################################################
# Abs(a) - returns the absoulte value of a
# Abs(a, b)
########################################################################
sub Abs
{
    my $a = shift;
    return abs($a);
}
Function::AddFunction("abs", "Maths::Abs");

########################################################################
# Atan2 arctangent of a/b, usage: - TWO INPUTS ONLY
# Atan2(a, b)
########################################################################
sub Atan2
{
    my ($a, $b) = @_;
    return atan2($a, $b);
}
Function::AddFunction("atan2", "Maths::Atan2");

########################################################################
# Cos(a) - returns the cosine value of a
# Cos(a)
########################################################################
sub Cos
{
    my $a = shift;
    return cos($a);
}
Function::AddFunction("cos", "Maths::Cos");

########################################################################
# Exp(a) - returns the exponential value of a
# Exp(a)
########################################################################
sub Exp
{
    my $a = shift;
    return exp($a);
}
Function::AddFunction("exp", "Maths::Exp");

########################################################################
# Int(a) - returns the integer value of a
# Int(a)
########################################################################
sub Int
{
    my $a = shift;
    return int($a);
}
Function::AddFunction("int", "Maths::Int");

########################################################################
# Log(a) - returns the logarithm value of a
# Log(a)
########################################################################
sub Log
{
    my $a = shift;
    return log($a);
}
Function::AddFunction("log", "Maths::Log");

########################################################################
# Rand(a) - returns a random fractional number in range 0 to a,
# if a is ommitted, number is in range 0 to 1
# Rand(a)
########################################################################
sub Rand
{
    if($_[0]) { return rand($_[0]); }
    return rand();
}
Function::AddFunction("rand", "Maths::Rand");

########################################################################
# Sin(a) - returns the sine value of a
# Sin(a)
########################################################################
sub Sin
{
    my $a = shift;
    return sin($a);
}
Function::AddFunction("sin", "Maths::Sin");

########################################################################
# Sqrt(a) - returns the square root value of a
# Sqrt(a)
########################################################################
sub Sqrt
{
    my $a = shift;
    return sqrt($a);
}
Function::AddFunction("sqrt", "Maths::Sqrt");

########################################################################
# Srand(a) - seeds random number generator with a
# Srand(a)
########################################################################
sub Srand
{
    if($_[0]) { srand($_[0]); }
    else { srand(); }
    return "";
}
Function::AddFunction("srand", "Maths::Srand");

return 1;
########################################################################
# End of file
########################################################################
