#!/bin/sh

VALGRIND=valgrind
TESTINDIR=../data/test-in
TESTOUTDIR=../data/test-out
BINFILE=../bin/tpcopados

OKVALGRIND=1

echo 'Iniciando test de memoria...' 

for f in $( ls $TESTINDIR );
do
	file=$TESTINDIR/$f
	
	echo 'Procesando archivo: ' $file



	# Filtros: C
	$VALGRIND --leak-check=yes --error-exitcode=1 -q $BINFILE -v -i c -f roberts $file $TESTOUTDIR/$f'.roberts.c.bmp'
	if [ $? != "0" ]; then
		OKVALGRIND=0
	fi
	
	$VALGRIND --leak-check=yes --error-exitcode=1 -q $BINFILE -v -i c -f prewitt $file $TESTOUTDIR/$f'.prewitt.c.bmp'	
	if [ $? != "0" ]; then
		OKVALGRIND=0
	fi
	
	$VALGRIND --leak-check=yes --error-exitcode=1 -q $BINFILE -v -i c -f sobel $file $TESTOUTDIR/$f'.sobel.c.bmp'
	if [ $? != "0" ]; then
		OKVALGRIND=0
	fi
	
	$VALGRIND --leak-check=yes --error-exitcode=1 -q $BINFILE -v -i c -f freichen $file	$TESTOUTDIR/$f'.freichen.c.bmp'
	if [ $? != "0" ]; then
		OKVALGRIND=0
	fi
	
	
	
	# Filtros: ASM
	$VALGRIND --leak-check=yes --error-exitcode=1 -q $BINFILE -v -i asm -f roberts $file $TESTOUTDIR/$f'.roberts.asm.bmp'
	if [ $? != "0" ]; then
		OKVALGRIND=0
	fi
	
	$VALGRIND --leak-check=yes --error-exitcode=1 -q $BINFILE -v -i asm -f prewitt $file $TESTOUTDIR/$f'.prewitt.asm.bmp'
	if [ $? != "0" ]; then
		OKVALGRIND=0
	fi
	
	$VALGRIND --leak-check=yes --error-exitcode=1 -q $BINFILE -v -i asm -f sobel $file $TESTOUTDIR/$f'.sobel.asm.bmp'
	if [ $? != "0" ]; then
		OKVALGRIND=0
	fi
	
	$VALGRIND --leak-check=yes --error-exitcode=1 -q $BINFILE -v -i asm -f freichen $file $TESTOUTDIR/$f'.freichen.asm.bmp'
	if [ $? != "0" ]; then
		OKVALGRIND=0
	fi
	
	
	
	# Monocromatización: C
	$VALGRIND --leak-check=yes --error-exitcode=1 -q $BINFILE -v -i c -g uno $file $TESTOUTDIR/$f'.uno.c.bmp'
	if [ $? != "0" ]; then
		OKVALGRIND=0
	fi
	
	$VALGRIND --leak-check=yes --error-exitcode=1 -q $BINFILE -v -i c -g infinito $file $TESTOUTDIR/$f'.infinito.c.bmp'
	if [ $? != "0" ]; then
		OKVALGRIND=0
	fi


	
	# Monocromatización: ASM	
	$VALGRIND --leak-check=yes --error-exitcode=1 -q $BINFILE -v -i asm -g uno $file $TESTOUTDIR/$f'.uno.asm.bmp'
	if [ $? != "0" ]; then
		OKVALGRIND=0
	fi
		
	$VALGRIND --leak-check=yes --error-exitcode=1 -q $BINFILE -v -i asm -g infinito $file $TESTOUTDIR/$f'.infinito.asm.bmp'	     
	if [ $? != "0" ]; then
		OKVALGRIND=0
	fi	
done

if [ $OKVALGRIND != "0" ]; then
	echo "Tests de memoria finalizados correctamente"
fi
