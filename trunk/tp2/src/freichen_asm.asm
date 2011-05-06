; void freichen_asm (unsigned char *src, unsigned char *dst, int h, int w, int row_size)

global freichen_asm
extern memcpy2

section .rodata
unos16b: 		dq 0x0001000100010001, 0x0001000100010001
dos32b: 		dq 0x0000000200000002, 0x0000000200000002

section .text

freichen_asm:
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
	mov ecx, .w             ;ecx <- width
	mov edx, .row_size	;edx <- row_size
		
	; la primer fila no la procesamos (no le podemos aplicar filtros)
	; Asique la copiamox tal como esta
	push dword .w ; longitud
	push esi ; source
	push edi ; dst
	call memcpy2
	add esp, 12

	; avanzo a la segunda fila
	add esi, edx
	add edi, edx
	dec eax

	.loop_h:
		; la ultima fila no la procesamos (no se le puede aplicar los filtros)
		cmp eax, 1
		je .fin
		
		; me salteo la primer columna (no le puedo aplicar filtros)
		; Asique copio el elemento tal como esta
		; NO incremento esi/edi porque los necesito para la cuenta del pixel siguiente
		mov bx, [esi]
		mov [edi], bx

		.loop_w:
			cmp ecx, 8
			jge .cargo_elementos

			cmp ecx, 2
			je .copiar_ultimos
			jg .loop_w_last_iter

			; ya termine con esta fila
			cmp ecx, 0
			je .loop_w_fin

			.cargo_elementos:
				;cargo 8 elementos
				;genero 6 pixels de imagen destino	
				
				; Cargo la fila anterior, actual y la siguiente fila
				mov edx, .row_size
				mov ebx, esi
				sub ebx, edx
				
				; FILTRO X
				
					movq xmm5, [ebx]
					movq xmm6, [esi]
					movq xmm7, [esi + edx]

					; los pongo como entero de 16 bits
					pxor xmm0, xmm0
					punpcklbw xmm5, xmm0 
					punpcklbw xmm6, xmm0
					punpcklbw xmm7, xmm0

					; xmm1 hay que transformarlo en floats, multiplicarlos por sqrt(2)
					movdqa xmm1, xmm6
					movdqa xmm2, xmm6
					punpcklwd xmm1, xmm0
					punpckhwd xmm2, xmm0 ; desempaqueto extendiendo con 0s
					movdqu xmm0, [dos32b]
					CVTDQ2PS xmm1, xmm1
					CVTDQ2PS xmm2, xmm2 ; convierto a float
					CVTDQ2PS xmm0, xmm0
					sqrtps xmm0, xmm0 ; saco la raiz cuadrada de 2
					mulps xmm1, xmm0
					mulps xmm2, xmm0 ; multiplico por valor por raiz de 2
					cvtps2dq xmm1, xmm1 
					cvtps2dq xmm2, xmm2 ; convierto a entero de 32
					packssdw xmm1, xmm2 ; empaqueto en enteros de 16
					
					paddw xmm5, xmm1
					paddw xmm5, xmm7
					
					;hago una copia de la suma, shifteo para alinear 1era col con 3ra.
					movdqa xmm1, xmm5
					psrldq xmm1, 4
					psubw xmm1, xmm5 ; xmm1 <- resultado

					movdqa xmm5, xmm1  ; xmm5 <- resultado de FX
				
				; FILTRO Y
					
					;xmm5 = resultado fx
					
					movq xmm6, [ebx]
					movq xmm7, [esi + edx]

					; los pongo como entero de 16 bits
					pxor xmm0, xmm0 		;xmm0 = todos 0
					punpcklbw xmm6, xmm0
					punpcklbw xmm7, xmm0 
					
					; fila3 + fila3_shift2 - fila1 - fila1_shift2
					movdqa xmm1, xmm6 		;xmm1 = fila1
					movdqa xmm2, xmm6
					psrldq xmm2, 4			;xmm2 = fila1_shift2
					movdqa xmm3, xmm7		;xmm3 = fila3
					movdqa xmm4, xmm7
					psrldq xmm4, 4			;xmm4 = fila3_shift2
					
					paddw xmm3, xmm4
					psubw xmm3, xmm1
					psubw xmm3, xmm2 
					movdqa xmm1, xmm3 		;XMM1 = fila3 + fila3_shift2 - fila1 - fila1_shift2
					
					movdqa xmm2, xmm6
					psrldq xmm2, 2
					movdqa xmm6, xmm2
					punpcklwd xmm2, xmm0 	; xmm2 = parte baja de fila1_shift1
					punpckhwd xmm6, xmm0 	; xmm6 = parte alta de fila1_shift1
					movdqa xmm3, xmm7
					psrldq xmm3, 2
					movdqa xmm7, xmm3 
					punpcklwd xmm3, xmm0 	; xmm3 = parte baja de fila3_shift1
					punpckhwd xmm7, xmm0 	; xmm7 = parte alta de fila3_shift1
					movdqu xmm0, [dos32b]	; xmm0 = dos en enteros de 32b
					CVTDQ2PS xmm0, xmm0		; convierto a float
					CVTDQ2PS xmm2, xmm2
					CVTDQ2PS xmm6, xmm6 
					CVTDQ2PS xmm3, xmm3
					CVTDQ2PS xmm7, xmm7
					sqrtps xmm0, xmm0 ; saco la raiz cuadrada de 2					
					mulps xmm2, xmm0 ; multiplico por valor por raiz de 2
					mulps xmm6, xmm0
					mulps xmm3, xmm0
					mulps xmm7, xmm0
					subps xmm3, xmm2
					subps xmm7, xmm6
					cvtps2dq xmm3, xmm3 
					cvtps2dq xmm7, xmm7 ; convierto a entero de 32
					packssdw xmm3, xmm7 ; empaqueto en enteros de 16
										; XMM3 = (fila1_shift1 - fila3_shift1) * sqrt(2)
					
					paddw xmm1, xmm3 ; XMM1 = resultado fy
									
				
								; valor absoluto
				;tengo cada resultado, pero necesito el modulo
				pxor xmm4, xmm4
				pcmpgtw xmm4, xmm5		;1s donde hay negativo en 4
				movdqu xmm3, xmm5
				pand xmm3, xmm4 		; me deja solo negativos en 5
				pcmpeqb xmm6, xmm6 		
				pxor xmm3, xmm6 		; niego xmm5
				movdqu xmm7, [unos16b]
				paddw xmm3, xmm7 		; tengo el inverso en complemento a 2
				pxor xmm4, xmm6			; niego mascara
				pand xmm5, xmm4			; saco los negativos de 0
				paddw xmm5, xmm3		; sumo los valores absolutos que tenia en 5

				;tengo cada resultado, pero necesito el modulo
				pxor xmm4, xmm4
				pcmpgtw xmm4, xmm1		;1s donde hay negativo en 4
				movdqu xmm3, xmm1
				pand xmm3, xmm4 		; me deja solo negativos en 5
				pcmpeqb xmm6, xmm6 		
				pxor xmm3, xmm6 		; niego xmm5
				movdqu xmm7, [unos16b]
				paddw xmm3, xmm7 		; tengo el inverso en complemento a 2
				pxor xmm4, xmm6			; niego mascara
				pand xmm1, xmm4			; saco los negativos de 0
				paddw xmm1	, xmm3		; sumo los valores absolutos que tenia en 5
				
				; No tenemos SSE3 para usar pabs :(
				;pabsw xmm1, xmm1
				;pabsw xmm5, xmm5
				
				
				; Empaqueto ambos filtros a enteros de byte sin signo
				packuswb xmm5, xmm5
				packuswb xmm1, xmm1

				; Suma empaquetada a byte con saturacion
				paddusb xmm1, xmm5

				; Escribimos en edi + 1 porque: edi y esi
				; apuntan un byte antes del que quiero escribir
				; (porque necesito la info del pixel anterior para hacer la cuenta)
				; Pero lo que calcule es para el pixel
				; siguienta al que apunta (y los sucesivos), asique escribo apartir de ahi
				movq [edi + 1], xmm1


				; Me faltan 6 elementos de esta fila menos
				sub ecx, 6
				add edi, 6
				add esi, 6
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
			
			.copiar_ultimos:
				; El actual ya fue escrito
				; en la iteracion anterior, pero el puntero no
				; se avanzo porque para calcular el pixel
				; siguiente necesito el pixel anterior. Asique el actual
				; lo dejo como esta(pues ya fue procesado), y copio solo el siguiente
				; (porque no se le puede aplicar el filtro porque el ultimo no tiene siguiente)
				dec ecx
				inc edi
				inc esi

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
	; Copiamos la ultima fila (que no se le puede aplicar filtros)
	push dword .w ; longitud
	push esi ; source
	push edi ; dst
	call memcpy2
	add esp, 12

	pop ebx
	pop esi
	pop edi
	pop ebp

	ret
