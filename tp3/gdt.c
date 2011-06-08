#include "gdt.h"
#include "tss.h"

gdt_entry gdt[GDT_COUNT] = {
	/* Descriptor nulo*/
	(gdt_entry){(unsigned int) 0x00000000, (unsigned int) 0x00000000 },

	(gdt_entry){(unsigned int) 0x00000000, (unsigned int) 0x00000000 },

	/* Segmento de codigo */
	(gdt_entry){
		(unsigned short) 0xFFFF,  //limit_0_15
		(unsigned short) 0x0000,  //base_0_15
		(unsigned char)  0x00,    //base_23_16
		(unsigned char) 0xA,      //type:4, 0xA = Execute/Read
		(unsigned char) 0x1,      //s:1;
		(unsigned char) 0x00,      //dpl:2;
		(unsigned char) 0x1,      //p:1;
		(unsigned char) 0xF,      //limit_16_19:4;
		(unsigned char) 0x0,      //avl:1;
		(unsigned char) 0x0,      //l:1;
		(unsigned char) 0x1,      //db:1;
		(unsigned char) 0x1,      //g:1;
		(unsigned char) 0x00      //base_31_24;
	},

	// Segmento de datos
	(gdt_entry){
		(unsigned short) 0xFFFF,  //limit_0_15
		(unsigned short) 0x0000,  //base_0_15
		(unsigned char)  0x00,    //base_23_16
		(unsigned char) 0x2,      //type:4, 0x2 = Read/Write
		(unsigned char) 0x1,      //s:1;
		(unsigned char) 0x00,      //dpl:2;
		(unsigned char) 0x1,      //p:1;
		(unsigned char) 0xF,      //limit_16_19:4;
		(unsigned char) 0x0,      //avl:1;
		(unsigned char) 0x0,      //l:1;
		(unsigned char) 0x1,      //db:1;
		(unsigned char) 0x1,      //g:1;
		(unsigned char) 0x00      //base_31_24;
	},

	// Segmento de video
	(gdt_entry){
		(unsigned short) 80*25*2,   //limit_0_15: 80*25 = 0x7D0 
 		(unsigned short) 0x8000,   //base_0_15
		(unsigned char)  0x0b,     //base_23_16
		(unsigned char)  0x2,      //type:4, 0x2 = Read/Write
		(unsigned char)  0x1,      //s:1;
		(unsigned char)  0x00,      //dpl:2;
		(unsigned char)  0x1,      //p:1;
		(unsigned char)  0x0,      //limit_16_19:4;
		(unsigned char)  0x0,      //avl:1;
		(unsigned char)  0x0,      //l:1;
		(unsigned char)  0x1,      //db:1;
		(unsigned char)  0x0,      //g:1;
		(unsigned char)  0x00      //base_31_24;
	}

};

gdt_descriptor GDT_DESC = {sizeof(gdt)-1, (unsigned int)&gdt};
