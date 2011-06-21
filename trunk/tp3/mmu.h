#ifndef __MMU_H__
#define __MMU_H__

#define INICIO_PAGINAS_KERNEL 	0x00100000
#define INICIO_PAGINAS_USUARIO	0x00200000
#define TAMANO_PAGINA 			0x1000


void inicializar_mmu(void);
unsigned int pagina_libre_usuario(void);
unsigned int pagina_libre_kernel(void);
unsigned int inicializar_dir_usuario(void);
void mapear_pagina(unsigned int virtual, unsigned int cr3, unsigned int fisica);
void unmapear_pagina(unsigned int virtual, unsigned int cr3);

#endif
