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

#include "Mandelbrot.h"

int convergence(double xx, double yy, int loop){
    double rx = 0.0;
    double ry = 0.0;
    while( loop != 0 )
    {
        double x = (rx * rx) - (ry * ry) + xx;
        double y = 2.0 * (rx * ry) + yy;
        rx   = x;
        ry   = y;
        if ( ((rx * rx) + (ry * ry)) > 2.0 )
            break;
        loop -= 1;
    }
    return loop;
}

#define SORTIE "Mandelbrot.ppm"

int image(double x_min, double x_max, double y_min, double y_max)
{
    FILE *f_out = fopen(SORTIE,"w");
    if (f_out == NULL){
        fprintf(stderr, "\nErreur: Impossible d'ecrire dans le fichier %s\n", SORTIE);
        return(EXIT_FAILURE);
    }

    FILE *f_bin = fopen("../mandelbrot.bin","w");
    if (f_bin == NULL){
        fprintf(stderr, "\nErreur: Impossible d'ecrire dans le fichier (../mandelbrot.bin)\n");
        return(EXIT_FAILURE);
    }
    
    
    int levels = 4095;
    int resX   =  640;
    int resY   =  480;
    
    double pasX = (x_max - x_min) / (double)(resX-1);
    double pasY = (y_max - y_min) / (double)(resY-1);

    fprintf(f_out, "P3\n");
    fprintf(f_out, "# Ensemble de Mandelbrot sur [%f;%f]x[%f;%f]\n", x_min, x_max, y_min, y_max);
    fprintf(f_out, "%d %d\n", resX, resY);
    fprintf(f_out, "255\n");

    int c_row = 0;
    int c_col = 0;

    double y_value = y_min;
    for(int py=0; py<resY; py++){
        double posY = y_min + (py * pasY);
        
        for(int px=0; px<resX; px++){
            double posX = x_min + (px * pasX);

            int v = convergence(posX, posY, levels);

            fprintf(f_out, "%d %d %d ", 16*(v >> 8)-1 , 16*((v >> 4) & 0x0F)-1, 16*(v & 0x04)-1 );
            
            char buffer[32];
            for(int k=0; k<12; k++)
            {
                buffer[k] = '0' + ( v & 0x01 );
                v         = v / 2;
            } buffer[12] = 0;
            fprintf(f_bin, "%s\n", buffer);
        }
        
        fprintf(f_out, "\n");
    }

    fclose(f_out);
    fclose(f_bin);
    return(EXIT_SUCCESS);
}
