#ifndef __GDT_H__
#define __GDT_H__

#include "tss.h"

typedef struct str_gdt_descriptor {
	unsigned short gdt_length;
	unsigned int gdt_addr;
} __attribute__((__packed__)) gdt_descriptor;


typedef struct str_gdt_entry {
	unsigned short limit_0_15;
	unsigned short base_0_15;
	unsigned char base_23_16;
	unsigned char type:4;
	unsigned char s:1;
	unsigned char dpl:2;
	unsigned char p:1;
	unsigned char limit_16_19:4;
	unsigned char avl:1;
	unsigned char l:1;
	unsigned char db:1;
	unsigned char g:1;
	unsigned char base_31_24;
} __attribute__((__packed__, aligned (8))) gdt_entry;

/** Tabla GDT **/
extern gdt_entry gdt[];
extern gdt_descriptor GDT_DESC;

void inicializar_gdt();
gdt_entry *entrada_libre_gdt();
void cargar_tarea_gdt(tss *tarea);


#define GDT_COUNT 128
#endif //__GDT_H__
