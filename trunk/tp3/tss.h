#ifndef __TSS_H__
#define __TSS_H__
#define TASK1INIT 0x12000

typedef struct str_tss {
	unsigned short ptl;
	unsigned short  unused0;
	unsigned int esp0;
	unsigned short  ss0;
	unsigned short  unused1;
	unsigned int esp1;
	unsigned short  ss1;
	unsigned short  unused2;
	unsigned int esp2;
	unsigned short  ss2;
	unsigned short  unused3;
	unsigned int cr3;
	unsigned int eip;
	unsigned int eflags;
	unsigned int eax;
	unsigned int ecx;
	unsigned int edx;
	unsigned int ebx;
	unsigned int esp;
	unsigned int ebp;
	unsigned int esi;
	unsigned int edi;
	unsigned short  es;
	unsigned short  unused4;
	unsigned short  cs;
	unsigned short  unused5;
	unsigned short  ss;
	unsigned short  unused6;
	unsigned short  ds;
	unsigned short  unused7;
	unsigned short  fs;
	unsigned short  unused8;
	unsigned short  gs;
	unsigned short  unused9;
	unsigned short  ldt;
	unsigned short  unused10;
	unsigned short  dtrap;
	unsigned short  iomap;
} __attribute__((__packed__, aligned (8))) tss;

/** Tabla de TSSs **/
extern tss tsss[];
extern tss tarea_inicial;
tss* obtener_tss_inicial();
tss* obtener_tss_idle();
tss* obtener_entrada_tss();

#define TSS_COUNT 18
#endif //__TSS_H__
