BITS 32
%include "macrosmodoprotegido.mac"

extern fin_intr_pic1

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


section .rodata
test_0: db '0!'
test_1: db '1!'
test_2: db '2!'
test_3: db '3!'
test_4: db '4!'
test_5: db '5!'
test_6: db '6!'
test_7: db '7!'
test_8: db '8!'
test_9: db '9!'
test_10: db '10!'
test_11: db '11!'
test_12: db '12!'
test_13: db '13!'
test_14: db '14!'
test_15: db '15!'
test_16: db '16!'
test_17: db '17!'
test_18: db '18!'
test_19: db '19!'



; voy a pasar cada registro a imprimir aca
treg: dq 0x00
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
tstack: db 'stack'
tbtrace: db 'backtrace'


section .text

; imprime todos los registos
print_registers:
	; ojo con el eflags

	; imprimo EFLAGS
	push eax
	pushf
	pop eax;
	IMPRIMIR_TEXTO teflags, 8, 0x1A, 18, 0x01
	DWORD_TO_HEX eax, treg
	IMPRIMIR_TEXTO treg, 8, 0x1A, 18, 0x09
	pop eax

	; imprimo EAX
	IMPRIMIR_TEXTO teax, 5, 0x1A, 4, 0x01
	DWORD_TO_HEX eax, treg
	IMPRIMIR_TEXTO treg, 8, 0x1A, 4, 0x06
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
	IMPRIMIR_TEXTO tds, 4, 0x1A, 6, 0x16
	DWORD_TO_HEX ds, treg
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
	IMPRIMIR_TEXTO tstack, 5, 0x1A, 11, 0x16
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
	
	mov eax, [esp]
	DWORD_TO_HEX eax, treg
	IMPRIMIR_TEXTO treg, 8, 0x1A, 12, 0x16
	mov eax, [esp + 4]
	DWORD_TO_HEX eax, treg
	IMPRIMIR_TEXTO treg, 8, 0x1A, 13, 0x16
	mov eax, [esp + 8]
	DWORD_TO_HEX eax, treg
	IMPRIMIR_TEXTO treg, 8, 0x1A, 14, 0x16
	mov eax, [esp + 12]
	DWORD_TO_HEX eax, treg
	IMPRIMIR_TEXTO treg, 8, 0x1A, 15, 0x16
	mov eax, [esp + 16]
	DWORD_TO_HEX eax, treg
	IMPRIMIR_TEXTO treg, 8, 0x1A, 16, 0x16
	mov eax, [esp + 20]
	DWORD_TO_HEX eax, treg
	IMPRIMIR_TEXTO treg, 8, 0x1A, 17, 0x16
	

	; imprimo el backtrace
	;mov eax, [ebp + 4]
	;DWORD_TO_HEX eax, treg
	;IMPRIMIR_TEXTO treg, 8, 0x1A, 12, 0x22
	;mov eax, [eax]
	;mov eax, [ebp + 4]
	;DWORD_TO_HEX eax, treg
	;IMPRIMIR_TEXTO treg, 8, 0x1A, 12, 0x22

	jmp $

_isr13:		
		mov edx, test_13
		IMPRIMIR_TEXTO edx, 3, 0x0A, 13, 73
		
		jmp print_registers

_isr0:

ret

_isr1:		
		mov edx, test_1
		IMPRIMIR_TEXTO edx, 2, 0x0A, 1, 73
		
		; nos colgamos
		jmp $
_isr2:
		mov edx, test_2
		IMPRIMIR_TEXTO edx, 2, 0x0A, 2, 73
		

		; nos colgamos
		jmp $
_isr3:
		mov edx, test_3
		IMPRIMIR_TEXTO edx, 2, 0x0A, 3, 73
		
		; nos colgamos
		jmp $
_isr4:
		mov edx, test_4
		IMPRIMIR_TEXTO edx, 2, 0x0A, 4, 73

		; nos colgamos
		jmp $
_isr5:
		mov edx, test_5
		IMPRIMIR_TEXTO edx, 2, 0x0A, 5, 73
		; nos colgamos
		jmp $
_isr6:
		mov edx, test_6
		IMPRIMIR_TEXTO edx, 2, 0x0A, 6, 73
		; nos colgamos
		jmp $
_isr7:
		mov edx, test_7
		IMPRIMIR_TEXTO edx, 2, 0x0A, 7, 73
		; nos colgamos
		jmp $
_isr8:
		mov edx, test_8
		IMPRIMIR_TEXTO edx, 2, 0x0A, 8, 73
		; nos colgamos
		jmp $
_isr9:
		mov edx, test_9
		IMPRIMIR_TEXTO edx, 2, 0x0A, 9, 73
		; nos colgamos
		jmp $
_isr10:
		mov edx, test_10
		IMPRIMIR_TEXTO edx, 3, 0x0A, 10, 73
		; nos colgamos
		jmp $
_isr11:
		mov edx, test_11
		IMPRIMIR_TEXTO edx, 3, 0x0A, 11, 73
		; nos colgamos
		jmp $
_isr12:
		mov edx, test_12
		IMPRIMIR_TEXTO edx, 3, 0x0A, 12, 73
		; nos colgamos
		jmp $
_isr14:
		mov edx, test_14
		IMPRIMIR_TEXTO edx, 3, 0x0A, 14, 73
		; nos colgamos
		jmp $
_isr15:
		mov edx, test_15
		IMPRIMIR_TEXTO edx, 3, 0x0A, 15, 73
		; nos colgamos
		jmp $
_isr16:
		mov edx, test_16
		IMPRIMIR_TEXTO edx, 3, 0x0A, 16, 73
		; nos colgamos
		jmp $
_isr17:
		mov edx, test_17
		IMPRIMIR_TEXTO edx, 3, 0x0A, 17, 73
		; nos colgamos
		jmp $
_isr18:
		mov edx, test_18
		IMPRIMIR_TEXTO edx, 3, 0x0A, 18, 73
		; nos colgamos
		jmp $
_isr19:
		mov edx, test_19
		IMPRIMIR_TEXTO edx, 3, 0x0A, 19, 73
		; nos colgamos
		jmp $



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


