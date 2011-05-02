; void roberts_asm (unsigned char *src, unsigned char *dst, int h, int w, int row_size)

global roberts_asm, memcpy2

section .rodata
unos16b: dq 0x0001000100010001, 0x0001000100010001

section .text

roberts_asm:
	push ebp
	mov ebp, esp
	push edi
	push esi
	push ebx
	
	%define .src [ebp + 8]
	%define .dst [ebp + 12]
	%define .h [ebp + 16]
	%define .w [ebp + 20]
	%define .row_size [ebp + 24]
	mov esi, .src		;ebx <- *src
	mov edi, .dst		;esi <- *dst
	mov eax, .h	        ;eax <- height
	mov ecx, .w		    ;ecx <- width
	mov edx, .row_size	;edx <- row_size
		
	.loop_h:
		; la ultima fila no la procesamos (no se le puede aplicar los filtros)
		cmp eax, 1
		je .fin
		
		.loop_w:
			cmp ecx, 8
			jge .cargo_elementos
			cmp ecx, 1
			jl .loop_w_fin
			je .copiar_el_ultimo
			jg .loop_w_last_iter
		
			.cargo_elementos:
				;cargo 8 elementos
				;genero 7 pixels de imagen destino	
				
				; Cargo la fila actual y la siguiente fila
				mov edx, .row_size
				movq xmm6, [esi]
				movq xmm7, [esi + edx]
				; los pongo como entero de 16 bits
				pxor xmm0, xmm0
				punpcklbw xmm6, xmm0 
				punpcklbw xmm7, xmm0
				
				; xmm6 <- fila actual
				; xmm7 <- fila siguiente

				;Filtro en X e Y
					
				; copio ambas filas en registros 0 y 1
				movdqa xmm0, xmm6
				movdqa xmm1, xmm7
				movdqa xmm2, xmm6
				movdqa xmm3, xmm7

				; alineamos para operar en paralelo las diagonales
				psrldq xmm1, 2
				psrldq xmm2, 2
				
				;restamos ambas filas
				psubw xmm0, xmm1		
				psubw xmm2, xmm3
				
				; valor absoluto
				;tengo cada resultado, pero necesito el modulo
				pxor xmm4, xmm4
				pcmpgtw xmm4, xmm0		;1s donde hay negativo en 4
				movdqu xmm5, xmm0
				pand xmm5, xmm4 		; me deja solo negativos en 5
				pcmpeqb xmm6, xmm6 		
				pxor xmm5, xmm6 		; niego xmm5
				movdqu xmm7, [unos16b]
				paddw xmm5, xmm7 		; tengo el inverso en complemento a 2
				pxor xmm4, xmm6			; niego mascara
				pand xmm0, xmm4			; saco los negativos de 0
				paddw xmm0, xmm5		; sumo los valores absolutos que tenia en 5
	
				; le saco el modulo a xmm2
				pxor xmm4, xmm4
				pcmpgtw xmm4, xmm2		;1s donde hay negativo en 4
				movdqu xmm5, xmm2
				pand xmm5, xmm4 		; me deja solo negativos en 5
				pcmpeqb xmm6, xmm6 		
				pxor xmm5, xmm6 		; niego xmm5
				movdqu xmm7, [unos16b]
				paddw xmm5, xmm7 		; tengo el inverso en complemento a 2
				pxor xmm4, xmm6			; niego mascara
				pand xmm2, xmm4			; saco los negativos de 0
				paddw xmm2, xmm5		; sumo los valores absolutos que tenia en 5

				
				; no todos tenemos SSE3, asique no usamos pabs
				;pabsw xmm0, xmm0
				;pabsw xmm2, xmm2
				
				; empaqueta los enteros a 8 bits
				packuswb xmm0, xmm0		
				packuswb xmm2, xmm2
				
				paddusb xmm0, xmm2
				movq [edi], xmm0
				
				
				; Me faltan 7 elementos de esta fila menos
				sub ecx, 7
				add edi, 7
				add esi, 7
				jmp .loop_w
			
			.loop_w_last_iter:
				; Si me quedan menos de 8 elementos, proceso los ultimos 8
				; (aunque algunos ya los procese, no me interesa)
				; ebx = 8 - ecx
				mov ebx, 8
				sub ebx, ecx
				; acomodo los punteros para procesar los ultimos 8
				sub edi, ebx
				sub esi, ebx
				mov ecx, 8
				jmp .loop_w
			
			.copiar_el_ultimo:
				; copiar el byte
				mov bx, [esi]
				mov [edi], bx
				
				dec ecx
				inc edi
				inc esi
				jmp .loop_w

			.loop_w_fin:
				; Me fijo la diferencia entre row_size y w. Eso es lo
				; que debo avanzar porque es basura
				mov ecx, .w
				mov edx, .row_size
				sub edx, ecx

				add edi, edx
				add esi, edx
				dec eax
				jmp .loop_h
	
	.fin:
		push dword .w
		push esi
		push edi
		call memcpy2
		add esp, 12

		pop ebx
		pop esi
		pop edi
		pop ebp
		ret


; void *memcpy2(void *dest, const void *src, size_t n);
; protege TODOS los registros
memcpy2:
	push ebp
	mov ebp, esp
	push edi
	push esi
	push ebx
	push edx

	mov edi, [ebp + 8]
	mov esi, [ebp + 12]
	mov ebx, [ebp + 16]

	; ebx: longitud
	; esi: src 
	; edi: dst
	.copy:
		cmp ebx, 0
		je .fin

		mov dl, [esi]
		mov byte [edi], dl

		inc esi
		inc edi
		dec ebx
		jmp .copy

	.fin:
		pop edx
		pop ebx
		pop esi
		pop edi
		pop ebp
		ret
