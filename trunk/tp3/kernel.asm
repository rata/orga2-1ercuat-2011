BITS 16

%include "macrosmodoreal.mac"

%define KORG 0x1200

global start
extern tsss
extern gdt
extern GDT_DESC
extern IDT_DESC
extern inicializar_idt

extern resetear_pic
extern habilitar_pic


;Aca arranca todo, en el primer byte.
start:
		cli			;no me interrumpan por ahora
		;xchg	bx, bx
		jmp 	bienvenida

;aca ponemos todos los mensajes		
iniciando: db 'Iniciando el kernel mas inutil del mundo'
iniciando_len equ $ - iniciando
pasando_proteg: db 'pasamo a modo protegido'
pasando_proteg_len equ $ - pasando_proteg


bienvenida:
		;IMPRIMIR_MODO_REAL iniciando, iniciando_len, 0x07, 0, 0
		
		;Habilitar A20
		call habilitar_A20

		;Dehsabilitar las interrupciones
		cli
		
		;Pasar a modo protegido
		lgdt [GDT_DESC]
		mov eax, cr0
		or eax, 1
		mov cr0, eax
			
		jmp 0x10:modo_protegido

BITS 32
modo_protegido:

		mov ax, 0x20
		mov ds, ax
		mov es, ax
		mov gs, ax
		mov fs, ax
		mov ss, ax

		mov 	cx, 80 * 25
		mov 	ax, 0x0000
		xor 	di, di	
	
		; pongo todo en negro
ciclo_negro:	
		mov 	[es:di], ax
		add 	di, 2
		loop 	ciclo_negro

		; pongo la primera en blanco
		xor di, di
		mov cx, 80 ; la primer fila tiene 80 columnas, 
		mov ax, 0x7000
primera_blanco:	
		mov	[es:di], ax
		add 	di, 2
		loop 	primera_blanco

		; pongo la ultima en blanco
		mov di, 3840; 3840 = 80*24*2
		mov cx, 80 ; 80 columnas 
		mov ax, 0x7000
ultima_blanco:	
		mov	[es:di], ax
		add 	di, 2
		loop 	ultima_blanco


		;Habilitar paginacion

		;Inicializar el scheduler de tareas
		
		;Construir tareas

		;saltar a la primer tarea

		jmp $		


%include "a20.asm"
;%include "macrosmodoprotegido.mac"
