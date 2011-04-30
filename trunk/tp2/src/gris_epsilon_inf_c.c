int max(int a, int b, int c) {
	int i_max = a > b ? a : b;
	return i_max > c ? i_max : c;
}

void gris_epsilon_inf_c(unsigned char *src, unsigned char *dst, int h, int w, int src_row_size, int dst_row_size) {
	int y, x;
	for (y = 0; y < h; y++) {		  
		for (x = 0; x < w; x++) {
			
			int src_p = (src_row_size*y) + x*3;
			int dst_p = (dst_row_size*y) + x;
			
			int red = src[src_p];
			int green = src[src_p + 1];
			int blue = src[src_p + 2];
				  			
			dst[dst_p] = max(red, green, blue);
		}
	} 
}
