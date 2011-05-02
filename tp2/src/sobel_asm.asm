; void sobel_asm (unsigned char *src, unsigned char *dst, int h, int w, int row_size)

global sobel_asm
extern memcpy2

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
				movq xmm0, [ebx]
				movq xmm1, [esi]
				movq xmm2, [esi + edx]

				; los pongo como entero de 16 bits
				pxor xmm2, xmm2
				punpcklbw xmm0, xmm2 
				punpcklbw xmm1, xmm2
				punpcklbw xmm2, xmm2



				; si la respuesta (empaquetada a 16 bits) esta
				; en xmm1, la ponemos en la parte baja de xmm1
				packuswb xmm1, xmm1

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
