BITS 32
%include "macrosmodoprotegido.mac"

extern fin_intr_pic1
extern tarea_actual, proximo_indice, dormir_tarea_control, despertar_tarea_control

global _isr0
global _isr1
global _isr2
global _isr3
global _isr4
global _isr5
global _isr6
global _isr7
global _isr8
global _isr9
global _isr10
global _isr11
global _isr12
global _isr13
global _isr14
global _isr15
global _isr16
global _isr17
global _isr18
global _isr19
global _isr32
global _isr33
global _isr66
global _isr88
global _isr89


section .rodata

	int_0: db 'Divide error #0'
	int_0_len equ $ - int_0
	int_1: db 'RESERVED MFcker #1'
	int_1_len equ $ - int_1
	int_2: db 'MNI Interrupt #2'
	int_2_len equ $ - int_2
	int_3: db 'Breakpoint #3'
	int_3_len equ $ - int_3
	int_4: db 'Overflow #4'
	int_4_len equ $ - int_4
	int_5: db 'BOUND Range Exceeded #5'
	int_5_len equ $ - int_5
	int_6: db 'Invalid Opcode #6'
	int_6_len equ $ - int_6
	int_7: db 'Device Not Available #7'
	int_7_len equ $ - int_7
	int_8: db 'Double Fault #8'
	int_8_len equ $ - int_8
	int_9: db 'Coprocessor Segment Overrun (reserved) #9'
	int_9_len equ $ - int_9
	int_10: db 'Invalid TSS (maneja bien las tareas, Daniel san) #10'
	int_10_len equ $ - int_10
	int_11: db 'Segment Not Present (donde te metiste?) #11'
	int_11_len equ $ - int_11
	int_12: db 'Stack-Segment fault #12'
	int_12_len equ $ - int_12
	int_13: db 'General Protection #13'
	int_13_len equ $ - int_13
	int_14: db 'Page Fault #14'
	int_14_len equ $ - int_14
	int_15: db '15 - reserved #15'
	int_15_len equ $ - int_15
	int_16: db 'x87 FPU Floating-Point error (math error) #16'
	int_16_len equ $ - int_16
	int_17: db 'Alignment Check (17) #17'
	int_17_len equ $ - int_17
	int_18: db 'Machine Check #18'
	int_18_len equ $ - int_18
	int_19: db 'SIMD Floating-Point Exception #19'
	int_19_len equ $ - int_19
	int_32: db 'Int #32'
	int_32_len equ $ - int_32
	int_33: db 'Int #33'
	int_33_len equ $ - int_33
	int_66: db 'Int #66'
	int_66_len equ $ - int_66
	int_88: db 'Int #88'
	int_88_len equ $ - int_88
	int_89: db 'Int #89'
	int_89_len equ $ - int_89
	
	tecla_1: db '1'
	tecla_2: db '2'
	tecla_3: db '3'
	tecla_4: db '4'
	tecla_5: db '5'
	tecla_6: db '6'
	tecla_7: db '7'
	tecla_8: db '8'
	tecla_9: db '9'
	tecla_0: db '0'
	


	; voy a pasar cada registro a imprimir aca
	treg: dq 0x00
	; titulitos que voy a imprimir
	teax: db 'EAX: '
	tebx: db 'EBX: '
	tecx: db 'ECX: '
	tedx: db 'EDX: '
	tesi: db 'ESI: '
	tedi: db 'EDI: '
	tebp: db 'EBP: '
	tesp: db 'ESP: '
	tcr0: db 'CR0: '
	tcr2: db 'CR2: '
	tcr3: db 'CR3: '
	tcr4: db 'CR4: '
	teflags: db 'EFLAGS: '
	tcs: db 'CS: '
	tds: db 'DS: '
	tes: db 'ES: '
	tfs: db 'FS: '
	tgs: db 'GS: '
	tss: db 'SS: '
	tstrace: db 'stack'
	tbtrace: db 'backtrace'

	; para el scheduler
	offset: dd 0
	selector: dw 0

section .text


; Asume que antes de jmp a esta funcion se hizo:
; pushfd
; push eax
; Asi imprime los flags correctamente
print_registers:

	; imprimo EAX
	pop eax
	IMPRIMIR_TEXTO teax, 5, 0x1A, 4, 0x01
	DWORD_TO_HEX eax, treg
	IMPRIMIR_TEXTO treg, 8, 0x1A, 4, 0x06

	; imprimo EFLAGS
	pop eax;
	IMPRIMIR_TEXTO teflags, 8, 0x1A, 18, 0x01
	DWORD_TO_HEX eax, treg
	IMPRIMIR_TEXTO treg, 8, 0x1A, 18, 0x09

	; imprimo CS
	IMPRIMIR_TEXTO tcs, 4, 0x1A, 4, 0x16
	DWORD_TO_HEX cs, treg
	IMPRIMIR_TEXTO treg, 8, 0x1A, 0x04, 0x1A

	; imprimo EBX
	IMPRIMIR_TEXTO teax, 5, 0x1A, 5, 0x01
	DWORD_TO_HEX ebx, treg
	IMPRIMIR_TEXTO treg, 8, 0x1A, 5, 0x06
	; imprimo DS
	IMPRIMIR_TEXTO tds, 4, 0x1A, 5, 0x16
	DWORD_TO_HEX cs, treg
	IMPRIMIR_TEXTO treg, 8, 0x1A, 5, 0x1A

	; imprimo ECX
	IMPRIMIR_TEXTO tecx, 5, 0x1A, 6, 0x01
	DWORD_TO_HEX ecx, treg
	IMPRIMIR_TEXTO treg, 8, 0x1A, 6, 0x06
	; imprimo ES
	IMPRIMIR_TEXTO tes, 4, 0x1A, 6, 0x16
	DWORD_TO_HEX es, treg
	IMPRIMIR_TEXTO treg, 8, 0x1A, 6, 0x1A

	; imprimo EDX
	IMPRIMIR_TEXTO tedx, 5, 0x1A, 7, 0x01
	DWORD_TO_HEX edx, treg
	IMPRIMIR_TEXTO treg, 8, 0x1A, 7, 0x06
	; imprimo FS
	IMPRIMIR_TEXTO tfs, 4, 0x1A, 7, 0x16
	DWORD_TO_HEX fs, treg
	IMPRIMIR_TEXTO treg, 8, 0x1A, 7, 0x1A


	; imprimo ESI
	IMPRIMIR_TEXTO tesi, 5, 0x1A, 8, 0x01
	DWORD_TO_HEX esi, treg
	IMPRIMIR_TEXTO treg, 8, 0x1A, 8, 0x06
	; imprimo GS
	IMPRIMIR_TEXTO tgs, 4, 0x1A, 8, 0x16
	DWORD_TO_HEX gs, treg
	IMPRIMIR_TEXTO treg, 8, 0x1A, 8, 0x1A

	; imprimo EDI
	IMPRIMIR_TEXTO tedi, 5, 0x1A, 9, 0x01
	DWORD_TO_HEX edi, treg
	IMPRIMIR_TEXTO treg, 8, 0x1A, 9, 0x06
	; imprimo SS
	IMPRIMIR_TEXTO tss, 4, 0x1A, 9, 0x16
	DWORD_TO_HEX ss, treg
	IMPRIMIR_TEXTO treg, 8, 0x1A, 9, 0x1A

	; imprimo EBP
	IMPRIMIR_TEXTO tebp, 5, 0x1A, 10, 0x01
	DWORD_TO_HEX ebp, treg
	IMPRIMIR_TEXTO treg, 8, 0x1A, 10, 0x06

	; imprimo ESP
	IMPRIMIR_TEXTO tesp, 5, 0x1A, 11, 0x01
	DWORD_TO_HEX esp, treg
	IMPRIMIR_TEXTO treg, 8, 0x1A, 11, 0x06
	; titulos stack y backtrace	
	IMPRIMIR_TEXTO tstrace, 5, 0x1A, 11, 0x16
	IMPRIMIR_TEXTO tbtrace, 9, 0x1A, 11, 0x22

	; imprimo CR0
	IMPRIMIR_TEXTO tcr0, 5, 0x1A, 13, 0x01
	DWORD_TO_HEX cr0, treg
	IMPRIMIR_TEXTO treg, 8, 0x1A, 13, 0x06

	; imprimo CR2
	IMPRIMIR_TEXTO tcr2, 5, 0x1A, 14, 0x01
	DWORD_TO_HEX cr2, treg
	IMPRIMIR_TEXTO treg, 8, 0x1A, 14, 0x06

	; imprimo CR3
	IMPRIMIR_TEXTO tcr3, 5, 0x1A, 15, 0x01
	DWORD_TO_HEX cr3, treg
	IMPRIMIR_TEXTO treg, 8, 0x1A, 15, 0x06

	; imprimo CR4
	IMPRIMIR_TEXTO tcr4, 5, 0x1A, 16, 0x01
	DWORD_TO_HEX cr4, treg
	IMPRIMIR_TEXTO treg, 8, 0x1A, 16, 0x06

	; ultimos 6 elementos del stack
	;push dword 0x1
	;push dword 0x2
	;push dword 0x3
	;push dword 0x4
	;push dword 0x5
	;push dword 0x6
	
	; fila a partir de la que empiezo a imprimr
	mov ecx, 12
	; iteracion
	mov ebx, 0
	.print_strace:
		cmp esp, 0x1C000
		je .strace_end
		cmp ebx, 6
		je .strace_end

		mov eax, [esp + ebx * 4]
		DWORD_TO_HEX eax, treg
		IMPRIMIR_TEXTO treg, 8, 0x1A, ecx, 0x16

		inc ebx
		inc ecx
		jmp .print_strace
	.strace_end:

	; fila a partir de la que empiezo a imprimr
	mov ecx, 12
	; iteracion
	mov ebx, 0
	; imprimo el backtrace
	.print_btrace:
		cmp ebp, 0x1C000
		je .btrace_end
		cmp ebx, 6
		je .btrace_end

		; en ebp + 4 esta el codigo de retorno, lo imprimo
		mov eax, [ebp + 4]
		DWORD_TO_HEX eax, treg
		IMPRIMIR_TEXTO treg, 8, 0x1A, ecx, 0x22

		; cargo el ebp anterior
		mov esp, ebp
		pop ebp

		; incremento la fila a imprimir y el elemento por el que voy
		inc ebx
		inc ecx
		jmp .print_btrace
	.btrace_end:

	jmp $

_isr0:
	pushfd
	push eax
	mov edx, int_0
	IMPRIMIR_TEXTO edx, int_0_len, 0x0A, 2, 0x1	
	jmp print_registers
_isr1:		
	pushfd
	push eax
	mov edx, int_1
	IMPRIMIR_TEXTO edx, int_1_len, 0x0A, 2, 0x1	
	jmp print_registers
_isr2:
	pushfd
	push eax
	mov edx, int_2
	IMPRIMIR_TEXTO edx, int_2_len, 0x0A, 2, 0x1	
	jmp print_registers
_isr3:
	pushfd
	push eax
	mov edx, int_3
	IMPRIMIR_TEXTO edx, int_3_len, 0x0A, 2, 0x1	
	jmp print_registers
_isr4:
	pushfd
	push eax
	mov edx, int_4
	IMPRIMIR_TEXTO edx, int_4_len, 0x0A, 2, 0x1	
	jmp print_registers
_isr5:
	pushfd
	push eax
	mov edx, int_5
	IMPRIMIR_TEXTO edx, int_5_len, 0x0A, 2, 0x1	
	jmp print_registers
_isr6:
	pushfd
	push eax
	mov edx, int_6
	IMPRIMIR_TEXTO edx, int_6_len, 0x0A, 2, 0x1	
	jmp print_registers
_isr7:
	pushfd
	push eax
	mov edx, int_7
	IMPRIMIR_TEXTO edx, int_7_len, 0x0A, 2, 0x1	
	jmp print_registers
_isr8:
	pushfd
	push eax
	mov edx, int_8
	IMPRIMIR_TEXTO edx, int_8_len, 0x0A, 2, 0x1	
	jmp print_registers
_isr9:
	pushfd
	push eax
	mov edx, int_9
	IMPRIMIR_TEXTO edx, int_9_len, 0x0A, 2, 0x1	
	jmp print_registers
_isr10:
	pushfd
	push eax
	mov edx, int_10
	IMPRIMIR_TEXTO edx, int_10_len, 0x0A, 2, 0x1	
	jmp print_registers
_isr11:
	pushfd
	push eax
	mov edx, int_11
	IMPRIMIR_TEXTO edx, int_11_len, 0x0A, 2, 0x1
	jmp print_registers
_isr12:
	pushfd
	push eax
	mov edx, int_12
	IMPRIMIR_TEXTO edx, int_12_len, 0x0A, 2, 0x1	
	jmp print_registers
_isr13:		
	pushfd
	push eax
	mov edx, int_13
	IMPRIMIR_TEXTO edx, int_13_len, 0x0A, 2, 0x1	
	jmp print_registers
_isr14:
	pushfd
	push eax
	mov edx, int_14
	IMPRIMIR_TEXTO edx, int_14_len, 0x0A, 2, 0x1	
	jmp print_registers
_isr15:
	pushfd
	push eax
	mov edx, int_15
	IMPRIMIR_TEXTO edx, int_15_len, 0x0A, 2, 0x1	
	jmp print_registers
_isr16:
	pushfd
	push eax
	mov edx, int_16
	IMPRIMIR_TEXTO edx, int_16_len, 0x0A, 2, 0x1	
	jmp print_registers
_isr17:
	pushfd
	push eax
	mov edx, int_17
	IMPRIMIR_TEXTO edx, int_17_len, 0x0A, 2, 0x1	
	jmp print_registers
_isr18:
	pushfd
	push eax
	mov edx, int_18
	IMPRIMIR_TEXTO edx, int_18_len, 0x0A, 2, 0x1	
	jmp print_registers
_isr19:
	pushfd
	push eax
	mov edx, int_19
	IMPRIMIR_TEXTO edx, int_19_len, 0x0A, 2, 0x1
	jmp print_registers
_isr32:
	; protejo todos los registros por fin_intr_pic1
	pushad
	call fin_intr_pic1
	call proximo_reloj

	call proximo_indice
	mov [selector], eax
	jmp far [offset]
	popad
	iret

_isr33:
	pushad
	call fin_intr_pic1

	xor eax, eax
	in al, 0x60
	
	cmp al, 0x02
	je .print_1
	cmp al, 0x03
	je .print_2
	cmp al, 0x04
	je .print_3
	cmp al, 0x05
	je .print_4
	cmp al, 0x06
	je .print_5
	cmp al, 0x07
	je .print_6
	cmp al, 0x08
	je .print_7
	cmp al, 0x09
	je .print_8
	cmp al, 0x0a
	je .print_9
	cmp al, 0x0b
	je .print_0
	cmp al, 0x14
	je .presiono_tecla_t

	; si no es ninguna de estas, la ignoramos
	jmp .end
	
	.print_1:
		IMPRIMIR_TEXTO tecla_1, 1, 0x0A, 0, 79
		jmp .end
	.print_2:
		IMPRIMIR_TEXTO tecla_2, 1, 0x0A, 0, 79
		jmp .end
	.print_3:
		IMPRIMIR_TEXTO tecla_3, 1, 0x0A, 0, 79
		jmp .end
	.print_4:
		IMPRIMIR_TEXTO tecla_4, 1, 0x0A, 0, 79
		jmp .end
	.print_5:
		IMPRIMIR_TEXTO tecla_5, 1, 0x0A, 0, 79
		jmp .end
	.print_6:
		IMPRIMIR_TEXTO tecla_6, 1, 0x0A, 0, 79
		jmp .end
	.print_7:
		IMPRIMIR_TEXTO tecla_7, 1, 0x0A, 0, 79
		jmp .end
	.print_8:
		IMPRIMIR_TEXTO tecla_8, 1, 0x0A, 0, 79
		jmp .end
	.print_9:
		IMPRIMIR_TEXTO tecla_9, 1, 0x0A, 0, 79
		jmp .end
	.print_0:
		IMPRIMIR_TEXTO tecla_0, 1, 0x0A, 0, 79
		jmp .end
	.presiono_tecla_t:
		call despertar_tarea_control
		jmp .end
	.end:
		popad
		iret
_isr66:
	;mov eax, 666
	pushad
	call dormir_tarea_control
	; cambio de proceso a ejecutar
	call proximo_indice
	mov [selector], eax
	jmp far [offset]

	popad
	iret
_isr88:
	;mov eax, 42
	call tarea_actual
	iret
_isr89:
	mov eax, 'L'
	iret

proximo_reloj:
	pushad
	inc DWORD [isrnumero]
	mov ebx, [isrnumero]
	cmp ebx, 0x4
	jl .ok
		mov DWORD [isrnumero], 0x0
		mov ebx, 0
	.ok:
		add ebx, isrmensaje1
		mov edx, isrmensaje
		IMPRIMIR_TEXTO edx, 6, 0x0A, 24, 73
		IMPRIMIR_TEXTO ebx, 1, 0x0A, 24, 79
	popad
	ret
	
isrmensaje: db 'Clock:'
isrnumero: dd 0x00000000
isrmensaje1: db '|'
isrmensaje2: db '/'
isrmensaje3: db '-'
isrmensaje4: db '\'


