#include "mmu.h"
#include "i386.h"

// "puntero" a la prox pag libre de kernel
static unsigned int *k_free_page;

// "puntero" a la prox pag libre de usuario
static unsigned int *u_free_page;

void inicializar_mmu(void)
{
	// Las primeras dos paginas estan ocupadas para PD y PT
	k_free_page = (unsigned int *) INICIO_PAGINAS_KERNEL + 0x2000;

	u_free_page = (unsigned int *) INICIO_PAGINAS_USUARIO;

	return;
}

unsigned int *pagina_libre_usuario(void)
{
	unsigned int *ret = u_free_page;
	u_free_page += TAMANO_PAGINA;

	return ret;
}

unsigned int *pagina_libre_kernel(void)
{
	unsigned int *ret = k_free_page;
	k_free_page += TAMANO_PAGINA;

	return ret;
}

unsigned int *inicializar_dir_usuario(void)
{
	// Mapeamos de la direccion 0 a la 0x200000 (no incluida) con identity mapping
	// Eso implica 1 sola entrada en el PD
	unsigned int *pd = pagina_libre_kernel();
	unsigned int *pt = pagina_libre_kernel();

	// Inicializamos la unica entrada del PD que necesitamos
	// Le ponemos la direccion del pt pero con 3 como atributos
	*pd = ((unsigned int ) pt) | 3;

	/* Y marcamos como no inicializadas el resto de las entradas del pd */
	unsigned int i;
	for (i = 1; i < 1023; i++)
		pd[i] = 0;

	// Inicializamos el PT con identity mapping. Asique va de la 0 fisica a la anterior a 0x200000
	unsigned int fisica;
	for (fisica = 0, i = 0; fisica < 0x200000; fisica += TAMANO_PAGINA, i++)
		pt[i] = fisica | 3;

	return pd;
}

void mapear_pagina(unsigned int virtual, unsigned int cr3, unsigned int fisica)
{
	/* Dada una direccion virtual se define el directorio, tabla y offset como
	 * directorio: bytes 31 a 22
	 * tabla: bytes 21 a 12
	 * offset: bytes 11 a 0
	 */
	unsigned int virt_dir = virtual >> 22;
	unsigned int virt_tab = (virtual >> 12) & 0x3FF;
	//unsigned int virt_off = virtual & 0x3FF;

	// El PD es el cr3 con los ultimos 12 bits en 0
	// XXX: pagina_libre_kernel/usuario ? kernel porque es para pt ?
	unsigned int *pd = (unsigned int *) (cr3 & ~0xFFF);
	if (pd[virt_dir] == 0x00)
		pd[virt_dir] = (unsigned int) (pagina_libre_kernel()) | 3;

	/* Puntero a la base del page table */
	unsigned int *pt_base = (unsigned int *) (pd[virt_dir] >> 12);

	/* La entrada que queremos es el offset virt_tab de pt_base (por la
	 * aritmetica de punteros no hace falta multiplicar por 4, porque
	 * int = 4bytes en x86) */
	unsigned int *pt_entry = pt_base + virt_tab;

	/* En el offset correspondiente de la pt, pongo la fisica y los permisos adecuados */
	*pt_entry = (fisica & ~0xFFF) | 3;

	return;
}

void unmapear_pagina(unsigned int virtual, unsigned int cr3)
{
	unsigned int virt_dir = virtual >> 22;
	unsigned int virt_tab = (virtual >> 12) & 0x3FF;
	//unsigned int virt_off = virtual & 0x3FF;

	// El PD es el cr3 con los ultimos 12 bits en 0
	unsigned int *pd = (unsigned int *) (cr3 & ~0xFFF);
	if (pd[virt_dir] == 0x00) {
		//pd[virt_dir] = (unsigned int) (pagina_libre_kernel()) | 3;
		return;
	}

	/* Puntero a la base del page table */
	unsigned int *pt_base = (unsigned int *) (pd[virt_dir] >> 12);

	/* La entrada que queremos es el offset virt_tab de pt_base (por la
	 * aritmetica de punteros no hace falta multiplicar por 4, porque
	 * int = 4bytes en x86) */
	unsigned int *pt_entry = pt_base + virt_tab;

	/* En el offset correspondiente de la pt ponemos todo en 0 */
	*pt_entry = 0x00;

	/* Invalidamos el cache */
	tlbflush();

	return;
}
