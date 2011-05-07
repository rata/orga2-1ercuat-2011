; void gris_epsilon_uno_asm(unsigned char *src, unsigned char *dst, int h, int w, int src_row_size, int dst_row_size)

global gris_epsilon_uno_asm

gris_epsilon_uno_asm:
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
			cmp ecx, 2
			jg .cargo_elementos
			je .loop_w_last_iter
			
			; Si me quedan menos de dos, como avanzo de a 2, me
			; quedan 0. Asique termine con esta fila
			jl .loop_w_fin
		
			.cargo_elementos:
				;cargo 8 elementos
				;genero 2 pixels de imagen destino	
				
				movq xmm6, [esi]

				; los pongo como entero de 16 bits
				pxor xmm0, xmm0
				punpcklbw xmm6, xmm0 
				
			.stuff:
				; copio a registros para shiftear
				movdqa xmm0, xmm6
				movdqa xmm1, xmm6
				movdqa xmm2, xmm6

				; shifteo para sumar R_1 + G_1 + B_1 en la primer posicion
				psrldq xmm1, 2
				psrldq xmm2, 4

				; R_1 + G_1
				paddw xmm0, xmm1

				; R_1 + 2 G_1
				paddw xmm0, xmm1
				
				; R_1 + 2 G_1 + B_1
				paddw xmm0, xmm2

				; divido por 4 cada numero
				; XXX: esta bien shiftear asi ?
				psrlw xmm0, 4

				; En en primer y cuarto elemento tengo las dos words que quiero
				; XXX: estoy agarrando lo que quiero asi ?
				pshuflw  xmm0, xmm0, 0x30

				; empaqueto los enteros a 8 bits
				packuswb xmm0, xmm0
				
				; bajo los 32 bits mas bajos
				movd edx, xmm0
				; escribo los 16 bits aun mas bajos, los que quiero (?)
				mov [edi], dx
				;movd [edi], xmm0

				
				; Me faltan 2 elementos de esta fila menos
				; Es decir, 2*3 = 6 pixeles de la imagen src (por ser color)
				; Y 2 de la imagen destino (por ser BN)
				sub ecx, 2
				add edi, 2
				add esi, 6
				jmp .loop_w
			
			.loop_w_last_iter:
				; Me quedan 2 pixeles de la imagen original (6 bytes).
				; Asique me paro 2bytes mas atras (asi me quedan 8 bytes), los cargo, 
				; los shifteo (asi me quedo con los ultimos 6, que son los que
				; quiero procesar) y los proceso como siempre


				; Cargo los ultimos 8 bytes y dejo esi como estaba
				sub esi, 2
				movq xmm6, [esi]
				add esi, 2

				; los pongo como entero de 16 bits
				pxor xmm0, xmm0
				punpcklbw xmm6, xmm0 
			
				; Tiro los primeros dos (me interesan los ultimos 6)
				psrldq xmm6, 4

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
