; void sobel_asm (unsigned char *src, unsigned char *dst, int h, int w, int row_size)

global sobel_asm
extern memcpy2

section .rodata
unos16b: dq 0x0001000100010001, 0x0001000100010001

section .text

sobel_asm:
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
	; asique la copiamos como esta
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
			je .copiar_el_ultimo
			jg .loop_w_last_iter

			cmp ecx, 0
			je .loop_w_fin
		
			.cargo_elementos:
				;cargo 8 elementos
				;genero 6 pixels de imagen destino	
				
				; Cargo la fila anterior, actual y la siguiente fila
				mov edx, .row_size
				mov ebx, esi
				sub ebx, edx
				movq xmm5, [ebx]
				movq xmm6, [esi]
				movq xmm7, [esi + edx]

				; los pongo como entero de 16 bits
				pxor xmm0, xmm0
				punpcklbw xmm5, xmm0 
				punpcklbw xmm6, xmm0
				punpcklbw xmm7, xmm0

				movdqa xmm0, xmm5
				movdqa xmm1, xmm6
				movdqa xmm2, xmm7
				
				; Filtro X
				
				; suma empaquetada de columnas
				paddw xmm0, xmm1
				paddw xmm0, xmm2
				paddw xmm0, xmm1 ; la columna del medio la sumo dos veces (*2)
				
				;hago una copia de la suma, shifteo para alinear 1era col con 3ra.
				movdqa xmm1, xmm0
				psrldq xmm1, 4
				psubw xmm1, xmm0 ; xmm1 <- resultado

				movdqa xmm2, xmm1 ; xmm2 <- resultado en x
				
				; Filtro Y
				
				;resto primera y ultima fila
				psubw xmm7, xmm5
			
				; 4 copias, y las alineo (la del medio 2 veces por el *2)
				movdqa xmm0, xmm7
				psrldq xmm0, 2
				movdqa xmm3, xmm7
				psrldq xmm3, 2
				movdqa xmm1, xmm7
				psrldq xmm1, 4
				
				
				paddw xmm0, xmm7
				paddw xmm0, xmm1
				paddw xmm0, xmm3
				
				; xmm0 <- Res filtro x
				
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
				
				; valor absoluto
				;tengo cada resultado, pero necesito el modulo
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

				
				; Empaqueto ambos filtros a enteros de byte sin signo
				packuswb xmm0, xmm0		
				packuswb xmm2, xmm2

				; Suma empaquetada a byte con saturacion
				paddusb xmm0, xmm2

				; Escribimos en edi + 1 porque: edi y esi
				; apuntan un byte antes del que quiero escribir
				; (porque necesito la info del pixel anterior para hacer la cuenta)
				; Pero lo que calcule es para el pixel
				; siguienta al que apunta (y los sucesivos), asique escribo apartir de ahi
				movq [edi + 1], xmm0

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
			
			.copiar_el_ultimo:
				; El actual ya fue escrito
				; en la iteracion anterior, pero el puntero no
				; se avanzo porque para calcular el pixel
				; siguiente necesito el pixel anterior. Asique el actual
				; lo dejo como esta(pues ya fue procesado), y copio solo el siguiente
				; (porque no se le puede aplicar el filtro porque el ultimo no tiene siguiente)
				dec ecx
				inc edi
				inc esi

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
