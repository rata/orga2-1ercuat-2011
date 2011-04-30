void gris_epsilon_uno_c(unsigned char *src, unsigned char *dst, int h, int w, int src_row_size, int dst_row_size) {
	int y, x;
	for (y = 0; y < h; y++) {		  
		for (x = 0; x < w; x++) {
			
			int src_p = (src_row_size*y) + x*3;
			int dst_p = (dst_row_size*y) + x;
			
			int red = src[src_p];
			int green = src[src_p + 1];
			int blue = src[src_p + 2];
				  			
			dst[dst_p] = (red+(2*green)+blue)/4;
		}
	}	  
}
