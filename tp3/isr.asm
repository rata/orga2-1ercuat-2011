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

_isr0:
ret

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
test_0: db '0!'

_isr13:		
		mov edx, test_13
		IMPRIMIR_TEXTO edx, 3, 0x0A, 13, 73
		ret
_isr1:		
		mov edx, test_1
		IMPRIMIR_TEXTO edx, 2, 0x0A, 1, 73
		ret
_isr2:
		mov edx, test_2
		IMPRIMIR_TEXTO edx, 2, 0x0A, 2, 73
		ret
_isr3:
		mov edx, test_3
		IMPRIMIR_TEXTO edx, 2, 0x0A, 3, 73
		ret
_isr4:
		mov edx, test_4
		IMPRIMIR_TEXTO edx, 2, 0x0A, 4, 73
		ret
_isr5:
		mov edx, test_5
		IMPRIMIR_TEXTO edx, 2, 0x0A, 5, 73
		ret
_isr6:
		mov edx, test_6
		IMPRIMIR_TEXTO edx, 2, 0x0A, 6, 73
		ret
_isr7:
		mov edx, test_7
		IMPRIMIR_TEXTO edx, 2, 0x0A, 7, 73
		ret
_isr8:
		mov edx, test_8
		IMPRIMIR_TEXTO edx, 2, 0x0A, 8, 73
		ret
_isr9:
		mov edx, test_9
		IMPRIMIR_TEXTO edx, 2, 0x0A, 9, 73
		ret
_isr10:
		mov edx, test_10
		IMPRIMIR_TEXTO edx, 3, 0x0A, 10, 73
		ret
_isr11:
		mov edx, test_11
		IMPRIMIR_TEXTO edx, 3, 0x0A, 11, 73
		ret
_isr12:
		mov edx, test_12
		IMPRIMIR_TEXTO edx, 3, 0x0A, 12, 73
		ret
_isr14:
		mov edx, test_14
		IMPRIMIR_TEXTO edx, 3, 0x0A, 14, 73
		ret
_isr15:
		mov edx, test_15
		IMPRIMIR_TEXTO edx, 3, 0x0A, 15, 73
		ret
_isr16:
		mov edx, test_16
		IMPRIMIR_TEXTO edx, 3, 0x0A, 16, 73
		ret
_isr17:
		mov edx, test_17
		IMPRIMIR_TEXTO edx, 3, 0x0A, 17, 73
		ret
_isr18:
		mov edx, test_18
		IMPRIMIR_TEXTO edx, 3, 0x0A, 18, 73
		ret
_isr19:
		mov edx, test_19
		IMPRIMIR_TEXTO edx, 3, 0x0A, 19, 73
ret



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


