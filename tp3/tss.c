
#include "tss.h"
#include "mmu.h"
#include "i386.h"


tss tsss[TSS_COUNT];
tss tarea_inicial;
tss tarea_idle;

tss* obtener_tss_inicial()
{
	tarea_inicial.ptl = 0;
	tarea_inicial.unused0 = 0;
	tarea_inicial.esp0 = 0;
	tarea_inicial.ss0 = 0;
	tarea_inicial.unused1 = 0;
	tarea_inicial.esp1 = 0;
	tarea_inicial.ss1 = 0;
	tarea_inicial.unused2 = 0;
	tarea_inicial.esp2 = 0; 
	tarea_inicial.ss2 = 0;
	tarea_inicial.unused3 = 0;
	tarea_inicial.cr3 = 0;
	tarea_inicial.eip = 0;
	tarea_inicial.eflags = 	0x202;
	tarea_inicial.eax = 0;
	tarea_inicial.ecx = 0;
	tarea_inicial.edx = 0;
	tarea_inicial.ebx = 0;
	tarea_inicial.esp = 0;
	tarea_inicial.ebp = 0;
	tarea_inicial.esi = 0;
	tarea_inicial.edi = 0;
	tarea_inicial.es = 0;
	tarea_inicial.unused4 = 0;
	tarea_inicial.cs = 0;
	tarea_inicial.unused5 = 0;
	tarea_inicial.ss = 0;
	tarea_inicial.unused6 = 0;
	tarea_inicial.ds = 0;
	tarea_inicial.unused7 = 0;
	tarea_inicial.fs = 0;
	tarea_inicial.unused8 = 0;
	tarea_inicial.gs = 0;
	tarea_inicial.unused9 = 0;
	tarea_inicial.ldt = 0;
	tarea_inicial.unused10 = 0;
	tarea_inicial.dtrap = 0;
	tarea_inicial.iomap = 0;
	
	return &tarea_inicial;
}


tss* obtener_tss_idle()
{
	unsigned int esp = (unsigned int) pagina_libre_usuario();

	/* Apunto la pila al final de la pagina */
	esp = esp + 4092;

	tarea_idle.ptl = 0;
	tarea_idle.unused0 = 0;
	tarea_idle.esp0 = esp;
	tarea_idle.ss0 = 0;
	tarea_idle.unused1 = 0;
	tarea_idle.esp1 = esp;
	tarea_idle.ss1 = 0;
	tarea_idle.unused2 = 0;
	tarea_idle.esp2 = esp; 
	tarea_idle.ss2 = 0;
	tarea_idle.unused3 = 0;
	tarea_idle.cr3 = rcr3();
	tarea_idle.eip = 0x00012000;
	tarea_idle.eflags = 	0x202;
	tarea_idle.eax = 0;
	tarea_idle.ecx = 0;
	tarea_idle.edx = 0;
	tarea_idle.ebx = 0;
	tarea_idle.esp = esp;
	tarea_idle.ebp = esp;
	tarea_idle.esi = 0;
	tarea_idle.edi = 0;
	tarea_idle.es = 0x18;
	tarea_idle.unused4 = 0;
	tarea_idle.cs = 0x10;
	tarea_idle.unused5 = 0;
	tarea_idle.ss = 0x18;
	tarea_idle.unused6 = 0;
	tarea_idle.ds = 0x18;
	tarea_idle.unused7 = 0;
	tarea_idle.fs = 0x18;
	tarea_idle.unused8 = 0;
	tarea_idle.gs = 0x18;
	tarea_idle.unused9 = 0;
	tarea_idle.ldt = 0;
	tarea_idle.unused10 = 0;
	tarea_idle.dtrap = 0;
	tarea_idle.iomap = 0;
	
	return &tarea_idle;
}
