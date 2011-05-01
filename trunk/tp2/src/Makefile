CC = gcc
ASM = nasm
DBG = gdb
CFLAGS = -ggdb -Wall -std=c99 -pedantic
ASMFLAGS = -felf32 -g -F dwarf
OPENCV_LIB = `pkg-config --cflags --libs opencv` -lm

BIN = tpcopados
BIN_DIR = ../bin

OBJS = tpcopados.o utils.o \
	roberts_c.o prewitt_c.o sobel_c.o freichen_c.o \
	roberts_asm.o prewitt_asm.o sobel_asm.o freichen_asm.o \
	gris_epsilon_uno_c.o gris_epsilon_inf_c.o \
	gris_epsilon_uno_asm.o gris_epsilon_inf_asm.o

.PHONY: all debug test clean

$(BIN): $(OBJS)
	$(CC) $(CFLAGS) $(OBJS) -o $@ $(OPENCV_LIB)
	cp $(BIN) $(BIN_DIR)/$(BIN)

tpcopados.o: tpcopados.c
	$(CC) $(CFLAGS) -c -o $@ $< $(OPENCV_LIB)

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<
	
%.o: %.asm
	$(ASM) $(ASMFLAGS) -o $@ $<
		
all: $(BIN)
		
debug: $(BIN)
	$(DBG) -x gdbscript ./$(BIN)

test: $(BIN)
	../tests/test.sh

clean:
	rm -f $(OBJS)
	rm -f ./$(BIN)
	rm -f $(BIN_DIR)/$(BIN)
