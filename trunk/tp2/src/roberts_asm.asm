; void roberts_asm (unsigned char *src, unsigned char *src, int h, int w, int row_size)

global roberts_asm

roberts_asm:
	;unsigned char *src, [ebp + 8] 
	;unsigned char *src, [ebp + 12]
	;int h, 			 [ebp + 16]
	;int w, 			 [ebp + 20]
	;int row_size		 [ebp + 24]
	
	push ebp
	mov ebp, esp
	push edi
	push esi
	push ebx
	
	
	
	jmp fin

fin:
	pop ebx
	pop esi
	pop edi
	pop ebp
	ret
