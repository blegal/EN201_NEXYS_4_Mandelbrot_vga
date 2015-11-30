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

#ifndef _MANDELBROT_H_
#define _MANDELBROT_H_

#include <stdio.h>
#include <stdlib.h>

extern int convergence(double xx, double yy, int loop);
extern int image(double x_min, double x_max, double y_min, double y_max);

#endif