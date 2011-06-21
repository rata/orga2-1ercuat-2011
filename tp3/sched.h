#ifndef __SCHED_H__
#define __SCHED_H__

#define CANT_TAREAS 16

extern unsigned short tareas[CANT_TAREAS];

unsigned short proximo_indice();
void inicializar_sched();



#endif
