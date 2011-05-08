; void gris_epsilon_inf_c(unsigned char *src, unsigned char *dst, int h, int w, int src_row_size, int dst_row_size)

global gris_epsilon_inf_asm

section .rodata
pshuf: dq 0x0000000C09060300, 0x0000000000000000

section .text

gris_epsilon_inf_asm:
	push ebp
	mov ebp, esp
	push edi
	push esi
	push ebx
	
	%define .src [ebp + 8]
	%define .dst [ebp + 12]
	%define .h [ebp + 16]
	%define .w [ebp + 20]
	%define .src_row_size [ebp + 24]
	%define .dst_row_size [ebp + 28]
	mov esi, .src		;ebx <- *src
	mov edi, .dst		;esi <- *dst
	mov eax, .h	        ;eax <- height
	mov ecx, .w		;ecx <- width
	mov edx, .src_row_size	;edx <- src_row_size

	.loop_h:
		cmp eax, 0
		je .fin
		
		.loop_w:
			cmp ecx, 0
			je .loop_w_fin

			; Me fijo si quedan 6 * 3 bytes
			cmp ecx, 6
			jge .cargo_elementos

			; 1 <=ecx < 6
			jl .loop_w_last_iter
		
			.cargo_elementos:
				;cargo 8 elementos
				;genero 2 pixels de imagen destino	
				
				movdqu xmm6, [esi]

			.stuff:
				; copio a registros para shiftear
				movdqa xmm0, xmm6
				movdqa xmm1, xmm6
				movdqa xmm2, xmm6

				; shifteo para comparar max(R_1, G_1, B_1) en la primer posicion
				psrldq xmm1, 1
				psrldq xmm2, 2

				; max(R_1, G_1)
				pmaxub xmm0, xmm1

				; max(R_1, G_1, B_1)
				pmaxub xmm0, xmm2

				; Tengo los 5 bytes que quiero en las posiciones 3k del registro, asique dejo los 5 que me ineresan en las primeros 5 bytes
				movdqu xmm3, [pshuf]
				pshufb xmm0, xmm3
				
				; bajo los 32 bits mas bajos
				movd edx, xmm0
				mov [edi], edx

				; bajo el quinto byte que me faltaba
				psrldq xmm0, 4
				movd edx, xmm0
				mov [edi + 4], dl

				
				; Me faltan 5 elementos de esta fila menos
				; Es decir, 5*3 = 15 pixeles de la imagen src (por ser color)
				; Y 2 de la imagen destino (por ser BN)
				sub ecx, 5
				add edi, 5
				add esi, 15
				jmp .loop_w
			
			.loop_w_last_iter:

				; Quedaban ecx filas. Ahora voy a procesar los
				; ultimos 15 bytes y debo ajustar edi tambien (porque quizas ya habia calculado
				; alguno de estos 15bytes y los voy a recalcular, por lo que debo pisarlo)
				mov edx, 5
				sub edx, ecx
				sub edi, edx

				; Cargo los ultimos 16 bytes
				lea ecx, [ecx * 3]
				mov edx, 16
				sub edx, ecx
				sub esi, edx
				movdqu xmm6, [esi]

				; Dejo esi apuntando al siguiente porque el primer byte lo voy a descartar 
				add esi, 1

				; Tiro el primero (me interesan los ultimos 15)
				psrldq xmm6, 1

				; en ecx dejo 5 (los 15 bytes que me faltan procesar)
				mov ecx, 5

				; dejo en xmm6 (como asume .stuff) los bytes a procesar
				jmp .stuff

			.loop_w_fin:
				; No me falta procesar ningun elemento de esta fila. Asique voy a la fila siguiente
				; Me fijo la diferencia entre row_size y w. Eso es lo
				; que debo avanzar porque es basura

				; En esi (source) debo fijarme la cantidad de
				; bytes a avanzar. Pero como w es la cantidad
				; de pixeles, w * 3 es la cantidad de bytes
				mov ecx, .w
				lea ecx, [ecx * 3]
				mov edx, .src_row_size
				sub edx, ecx
				add esi, edx

				; En edi es mas directo. Es solo la diferencia entre w y row_size
				mov ecx, .w
				mov edx, .dst_row_size
				sub edx, ecx
				add edi, edx

				; Nos falta una fila menos
				; En ecx dejo .w, que es lo que queremos para comenzar una nueva iteracion
				dec eax
				jmp .loop_h
	.fin:
		pop ebx
		pop esi
		pop edi
		pop ebp
		ret
