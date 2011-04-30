#include <stdlib.h>
#include "utils.h"
/*
 * Filtro Roberts
 * 
 * filtro_x = src(i,j) - src(i+1, j+1)
 * filtro_y = src(i+1,j) - src(i,j+1)
 */

void roberts_c (unsigned char *src, unsigned char *dst, int h, int w, int row_size) {
	
	int y, x;
	for (y = 1; y < h-1; y++) {		  
		for (x = 1; x < w-1; x++) {		
			int curpixel = (row_size*y) + x;
			
			int filtro_x = src[curpixel] - src[curpixel + row_size + 1];
			int filtro_y = src[curpixel + 1] - src[curpixel + row_size];
			
			dst[curpixel] = saturar(abs(filtro_x) + abs(filtro_y));
		}
	}
}
