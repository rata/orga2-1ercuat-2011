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

nombre_grupo: db 'Los Marrones'
nombre_grupo_len equ $ - nombre_grupo


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

	mov ax, 0x20	;video
	mov es, ax 	
	mov ax, 0x18	;datos
	mov ds, ax 
	mov gs, ax
	mov fs, ax
	mov ss, ax

	; pongo todo en negro
	mov 	cx, 80 * 25
	mov 	ax, 0x0000
	xor 	di, di

	ciclo_negro:	
		mov 	[es:di], ax
		add 	di, 2
		loop 	ciclo_negro

		; pongo la primera en blanco
		xor 	di, di
		mov 	cx, 80 ; la primer fila tiene 80 columnas, 
		mov 	ax, 0x7000
	primera_blanco:	
		mov	[es:di], ax
		add 	di, 2
		loop 	primera_blanco

		; pongo la ultima en blanco
		mov 	di, 3840; 3840 = 80*24*2
		mov 	cx, 80 ; 80 columnas 
		mov 	ax, 0x7000
	ultima_blanco:	
		mov	[es:di], ax
		add 	di, 2
		loop 	ultima_blanco


;Habilitar paginacion

	inicializar_kernel_dir:

		%define PD_ADDR		0x00100000
		%define PT_ADDR		0x00101000
		
		;Creamos Page Directory

		mov ecx, 1024
		mov ebx, PD_ADDR
		mov eax, 0x2
		.pd:
			mov dword [ebx+ecx*4], eax
		loop .pd
		mov dword [PD_ADDR], PT_ADDR+0x3
		
		;Creamos Page Table

		mov ecx, 1024
		mov ebx, PT_ADDR
		mov edx, 0x1000 * 1023

		.pt:
			dec ecx
			mov [ebx+ecx*4], edx
			add dword [ebx+ecx*4], 0x00000003
			sub edx, 0x1000
		cmp ecx, 0
		jne .pt
		
		;Habilito paginacion

		mov eax, PD_ADDR
		mov cr3, eax		
		mov eax, cr0
		or eax, 0x80000000
		mov cr0, eax

		; Escribo el nopmbre del grupo
		mov ecx, nombre_grupo_len
		xor 	di, di
		xor	si, si
		.escribo:
			mov byte al, [nombre_grupo+di]
			mov byte [es:si], al
			inc di
			add si, 2
			loop .escribo
	

		; Armo la idt
		call inicializar_idt
		lidt [IDT_DESC]
	;	xchg bx, bx
	
		; genero un #GP
		mov ecx, 4001
		mov byte al, [nombre_grupo]
		mov byte [es:ecx], al
		;int 13
		


;Inicializar el scheduler de tareas
		
		;Construir tareas

		;saltar a la primer tarea

		jmp $		


%include "a20.asm"
;%include "macrosmodoprotegido.mac"
