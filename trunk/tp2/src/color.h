#ifndef __COLOR_H__
#define __COLOR_H__

void gris_epsilon_uno_c(unsigned char *src, unsigned char *dst, int h, int w, int src_row_size, int dst_row_size);
void gris_epsilon_inf_c(unsigned char *src, unsigned char *dst, int h, int w, int src_row_size, int dst_row_size);

void gris_epsilon_uno_asm(unsigned char *src, unsigned char *dst, int h, int w, int src_row_size, int dst_row_size);
void gris_epsilon_inf_asm(unsigned char *src, unsigned char *dst, int h, int w, int src_row_size, int dst_row_size);
	
#endif /* !__COLOR_H__ */
