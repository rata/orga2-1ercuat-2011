#include <stdlib.h>
#include <string.h>
#include "utils.h"
/*
 * Filtro Roberts
 * 
 * filtro_x = src(i,j) - src(i+1, j+1)
 * filtro_y = src(i+1,j) - src(i,j+1)
 */

void roberts_c (unsigned char *src, unsigned char *dst, int h, int w, int row_size) {
	
	int y, x;
	for (y = 0; y < h-1; y++) {		  
		for (x = 0; x < w-1; x++) {		
			int curpixel = (row_size*y) + x;
			
			int filtro_x = (unsigned int)src[curpixel] - (unsigned int)src[curpixel + row_size + 1];
			int filtro_y = (unsigned int)src[curpixel + 1] - (unsigned int)src[curpixel + row_size];
			
			dst[curpixel] = saturar(abs(filtro_x) + abs(filtro_y));
		}
		dst[row_size * y + w -1] = src[row_size * y + w -1];
	}
	memcpy(dst + row_size * h - 1, src + row_size * h - 1, w);
}
