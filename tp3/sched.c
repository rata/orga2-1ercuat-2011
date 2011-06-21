#include "sched.h"
#include "tss.h"
#include "gdt.h"
#include "mmu.h"
#include "i386.h"

static unsigned int pag_shared;

//Implementado en kernel.asm
void memcpy2(void *dest, const void *src, unsigned int n);
void *memcpy3(void *dest, const void *src, unsigned int n);

unsigned short tareas[CANT_TAREAS];

unsigned short proximo_indice() {	
	return 0;
}

void inicializar_sched()
{
	pag_shared = pagina_libre_usuario();
	char *buf = (char *) pag_shared;
	unsigned int i;
	for (i = 0; i < TAMANO_PAGINA; i++) {
		buf[i] = 0x00;
	}
}


void *memcpy3(void *dest, const void *src, unsigned int n)
{
	char *from = (char *) src;
	char *to = (char *) dest;
	
	unsigned int i;
	for (i = 0; i < n; i++)
		to[i] = from[i];

	return 0;
}

int	crear_proceso(unsigned int cargar_desde)
{	
//	cargar_tarea_gdt(obtener_tss_idle());
//	return 0;
	
	//Obtener una pagina para el codigo y otra para la pila.
	unsigned int pagina_codigo = pagina_libre_usuario();
	pagina_codigo = pagina_codigo;
	unsigned int esp = pagina_libre_usuario();
	esp = esp + 4092;

	//Obtener una entrada libre en el arreglo de TSS.
	tss *tarea = obtener_entrada_tss();
	
	//Crear un directorio de paginas.
	// Creamos un directorio nuevo con Identity Mapping para la nueva tarea
	unsigned int pd = inicializar_dir_usuario();
	pd = pd;

	//Copiar el codigo a la direccion fisica correspondiendte.
	memcpy2((void *) pagina_codigo, (void *)cargar_desde, TAMANO_PAGINA);

	//Mapeamos: codigo -> 00; shared -> 12000; esp -> id map
	mapear_pagina(0x00, pd, pagina_codigo);
	mapear_pagina(0x12000, pd, pag_shared);
	mapear_pagina(esp, pd, esp);
	

	//Inicializar el TSS.
	tarea->ptl = 0;
	tarea->unused0 = 0;
	tarea->esp0 = esp;
	tarea->ss0 = 0;
	tarea->unused1 = 0;
	tarea->esp1 = esp;
	tarea->ss1 = 0;
	tarea->unused2 = 0;
	tarea->esp2 = esp;
	tarea->ss2 = 0;
	tarea->unused3 = 0;
	tarea->cr3 = pd; // XXX: atributos ?
	//tarea->cr3 = rcr3(); // XXX: atributos ?
	//tarea->eip = 0x12000;
	tarea->eip = 0x00;
	tarea->eflags = 0x202;
	tarea->eax = 0;
	tarea->ecx = 0;
	tarea->edx = 0;
	tarea->ebx = 0;
	tarea->esp = esp;
	tarea->ebp = esp;
	tarea->esi = 0;
	tarea->edi = 0;
	tarea->es = 0x18;
	//tarea->es = 0x20;
	tarea->unused4 = 0;
	tarea->cs = 0x10;
	tarea->unused5 = 0;
	tarea->ss = 0x18;
	//tarea->ss = 0x20;
	tarea->unused6 = 0;
	tarea->ds = 0x18;
	//tarea->ds = 0x20;
	tarea->unused7 = 0;
	tarea->fs = 0x18;
	//tarea->fs = 0x20;
	tarea->unused8 = 0;
	tarea->gs = 0x18;
	//tarea->gs = 0x20;
	tarea->unused9 = 0;
	tarea->ldt = 0;
	tarea->unused10 = 0;
	tarea->dtrap = 0;
	tarea->iomap = 0;
	
	//Obtener una entrada en la GDT e inicializarla con los datos del TSS correspondiente.
	cargar_tarea_gdt(tarea);

	return 0;
}
