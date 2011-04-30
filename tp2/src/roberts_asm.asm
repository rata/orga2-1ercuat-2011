; void roberts_asm (unsigned char *src, unsigned char *dst, int h, int w, int row_size)

global roberts_asm

roberts_asm:
	;unsigned char *src, [ebp + 8] 
	;unsigned char *dst, [ebp + 12]
	;int h, 			 [ebp + 16]
	;int w, 			 [ebp + 20]
	;int row_size		 [ebp + 24]
	
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
	mov edi, .src		;ebx <- *src
	mov esi, .dst		;esi <- *dst
	mov eax, .h	        ;eax <- height
	mov ecx, .w		    ;ecx <- width
	mov edx, .row_size	;edx <- row_size
		
	.loop_h:
		cmp eax, 0
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
				
				
				movdqu xmm6, [edi]
				movdqu xmm7, [edi + edx]
				xor xmm2, xmm2
				PUNPCKLBW xmm6, xmm2 	;Unpack high data
				PUNPCKHBW xmm7, xmm2
				PUNPCKLBW xmm6, xmm2 	;Unpack high data
				PUNPCKHBW xmm7, xmm2
				
				;Filtro en x
				movdqu xmm0, xmm6
				movdqu xmm1, xmm7
				
				pslldq xmm1, 2 			;shift a la izquierda 2byte
				psubw xmm0, xmm1
				
				;tengo cada resultado, saco el modulo
				xor xmm4, xmm4
				pcmpgtw xmm4, xmm0		;1s donde hay negativos
				movdqu xmm3, xmm0
				pneg xmm3
				
				
				
				
				
				; Me faltan 7 elementos de esta fila menos
				sub ecx, 7
				add edi, 7
				add esi, 7
				jmp .loop_w
			
			.loop_w_last_iter:
				; Si me quedan menos de 16 elementos, proceso los ultimos 16
				; (aunque algunos ya los procese, no me interesa)
				; ebx = 16 - ecx
				mov ebx, 8
				sub ebx, ecx
				sub edi, ebx
				sub esi, ebx
				mov ecx, 8
				jmp .loop_w
			
			.copiar_el_ultimo:
				; copiar el byte
				mov bx, [edi]
				mov [esi], bx
				
				dec ecx
				inc edi
				inc esi
				jmp .loop_w

			.loop_w_fin:
				; que debo avanzar porque es basura
				; Me fijo la diferencia entre row_size y w. Eso es lo
				mov ecx, .w
				mov edx, .row_size
				sub edx, ecx
				add edi, edx
				add esi, edx
				dec eax
				jmp .loop_h
	
	.fin:
		pop ebx
		pop esi
		pop edi
		pop ebp
		ret
