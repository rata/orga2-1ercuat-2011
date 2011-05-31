MCOPY=mcopy

KERNEL_SRC=kernel.asm
KERNEL_OBJ=kernel.o
KERNEL_BIN=kernel.bin

DEPEND=kernel.asm macrosmodoreal.mac macrosmodoprotegido.mac gdt.c pic.c idt.c isr.asm tss.c mmu.c Makefile gdt.h pic.h idt.h isr.h tss.h mmu.h sched.h
OBJ= $(KERNEL_OBJ)  gdt.o pic.o idt.o isr.o mmu.o sched.o tss.o
DISK_IMG=diskette.img

CFLAGS=-m32 -g -ggdb -Wall -Werror -O0 \
  -fno-zero-initialized-in-bss -fno-stack-protector -ffreestanding

TASKS=tareas.tsk
TASKSSIZE=36K

OBJDUMP=objdump
OBJCOPY=objcopy
CC=gcc
NASM=nasm
NASMFLAGS=-felf32
LD=ld               
LDTASKFLAGS=-static -m elf_i386 --oformat binary -b elf32-i386 -e start
LDFLAGS=-static -m elf_i386 --oformat binary -b elf32-i386 -e start -Ttext 0x1200

.PHONY=clean all image tasks

all: image clean

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $^

%.o: %.asm
	$(NASM) $(NASMFLAGS) -o $@ $^

kernel.bin: $(OBJ)
	@echo 'Linkeando el kernel...'
	$(LD) $(LDFLAGS) -o $@ $^
	@echo ''
	mv kernel.bin kernel.bin.tmp
	dd if=/dev/zero bs=1 count=77312 of=kernel.bin status=noxfer
	dd if=kernel.bin.tmp bs=1 count=69120 of=kernel.bin conv=notrunc status=noxfer
	dd if=$(TASKS) bs=1 count=$(TASKSSIZE) seek=69120 conv=notrunc of=kernel.bin status=noxfer


image: kernel.bin $(DEPEND)
	@echo 'Copiando el $(KERNEL_BIN) a la imagen de diskette\n'
	$(MCOPY) -o -i $(DISK_IMG) $(KERNEL_BIN) ::/ 

clean:
	rm -f *.bin *.o *.ctsko *.ctsk *.tsko kernel.bin.tmp
