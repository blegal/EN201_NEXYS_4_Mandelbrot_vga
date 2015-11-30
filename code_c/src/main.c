/*
	Copyright @ Bertrand LE GAL (2012), ENSEIRB-MATMECA School, Talence, France

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>. 1
*/

#include <stdio.h>
#include <stdlib.h>
#include "Mandelbrot.h"

int main (int argc, char * argv [])
{
	return image(-2.0, 1.0, -1.0, 1.0);
//    return image( -0.1528 - 0.020, 1.0397 - 0.020, -0.1528 + 0.020, 1.0397  + 0.020);
}
