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

unsigned short idx_tarea_libre;

unsigned short idx_tarea_actual;

int dormida;

// devuelve el offset de la gdt (selector que se usa en el jmp) de la proxima tarea a ejecutar
unsigned short proximo_indice() {	
	idx_tarea_actual++;

	// Si me pase de la ultima tarea, vuelvo a la primera
	if (idx_tarea_actual > 3)
		idx_tarea_actual = 0;

	// Si esta dormida la de control (la 3) no la tengo que ejecutar. Vuelvo a la primera
	if (idx_tarea_actual == 3 && dormida == 1)
		idx_tarea_actual = 0;

	return tareas[idx_tarea_actual];
}

unsigned short tarea_actual()
{
	return idx_tarea_actual;
}

void dormir_tarea_control()
{
	dormida = 1;
}

void despertar_tarea_control()
{
	dormida = 0;
}

void inicializar_sched()
{
	// Pedimos compartida por todas las tareas
	pag_shared = pagina_libre_usuario();

	// Mapeo temporal para acceder a la pagina y ponerla en 0
	// El 0 NO se usa, asique piso lo que habia y no dejo nada
	mapear_pagina(0, rcr3(), pag_shared);
	char *buf = (char *) 0;
	unsigned int i;
	for (i = 0; i < TAMANO_PAGINA; i++) {
		buf[i] = 0x00;
	}
	unmapear_pagina(0, rcr3());

	// El primer elemento del arreglo esta libre
	idx_tarea_libre = 0;

	// La tarea actual es 0
	idx_tarea_actual = 0;

	// No hay ninguna tarea dormida
	dormida = 0;
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
	//Obtener una pagina para el codigo y otra para la pila.
	unsigned int pagina_codigo = pagina_libre_usuario();
	unsigned int esp = pagina_libre_usuario();
	esp = esp + 4092;

	//Obtener una entrada libre en el arreglo de TSS.
	tss *tarea = obtener_entrada_tss();
	
	//Crear un directorio de paginas.
	// Creamos un directorio nuevo con Identity Mapping para la nueva tarea
	unsigned int pd = inicializar_dir_usuario();

	// Mapeo temporal para acceder a pagina_codigo.
	// Lo mapeo en la 0 virtual que no hay nada
	mapear_pagina(0, rcr3(), pagina_codigo);

	//Copiar el codigo a la direccion fisica correspondiendte.
	memcpy2((void *) 0, (void *)cargar_desde, TAMANO_PAGINA);

	// Deshago el mapeo temporal
	unmapear_pagina(0, rcr3());

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

	// El selector en la gdt lo pongo a lo macho. Los primeros 7 ya estan
	// usados. Y lo multiplico por 8 para que sea un selector valido (y no
	// un indice "normal")
	tareas[idx_tarea_libre] = (idx_tarea_libre + 7) * 8;
	idx_tarea_libre++;

	return 0;
}
