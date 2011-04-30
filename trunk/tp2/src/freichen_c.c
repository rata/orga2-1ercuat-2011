#include <stdlib.h>
#include "utils.h"
#include <math.h>

void freichen_c (unsigned char *src, unsigned char *dst, int h, int w, int row_size) {
	int y, x;
	float sqrt_2 = sqrt(2);
	
	for (y = 1; y < h-1; y++) {		  
		for (x = 1; x < w-1; x++) {		
			int curpixel = (row_size*y) + x;
			
			int filtro_x = 0;
			filtro_x -= src[curpixel-row_size-1];
			filtro_x -= sqrt_2*src[curpixel-1];
			filtro_x -= src[curpixel+row_size-1];
			filtro_x += src[curpixel-row_size+1];
			filtro_x += sqrt_2*src[curpixel+1];
			filtro_x += src[curpixel+row_size+1];			
			
			int filtro_y = 0;			
			filtro_y -= src[curpixel-row_size-1];
			filtro_y -= sqrt_2*src[curpixel-row_size];
			filtro_y -= src[curpixel-row_size+1];
			filtro_y += src[curpixel+row_size-1];
			filtro_y += sqrt_2*src[curpixel+row_size];
			filtro_y += src[curpixel+row_size+1];
			
			dst[curpixel] = saturar(abs(filtro_x) + abs(filtro_y));
		}
	}	
}
