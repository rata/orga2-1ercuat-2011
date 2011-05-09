#!/bin/bash

IMP="c asm"
FILTROS="r p s f"
GRISES="uno infinito"
ITERACIONES="10"
DATA_DIR="out/"
PLOT_DIR="plot/"


# Creamos directorios si no existen
mkdir -p $DATA_DIR
mkdir -p $PLOT_DIR

# Borramos la data vieja
rm -f $DATA_DIR/*.data
rm -f $PLOT_DIR/*.png


for imp in $IMP; do

	for g in $GRISES; do
		for img in ../data/graficos/*; do
			img_name=$(basename $img | cut -d 'x' -f1)
			outf="$DATA_DIR/gris-$g-en-$imp.data"

			ciclos=$(./tpcopados -i $imp -g $g $img asd.bmp -t $ITERACIONES | awk '{if (NR == 5) print;}' | cut -d ':' -f 2)
			ciclos=$(bc -l <<< "$ciclos / $ITERACIONES")

			# El nombre de la imagen es el tamaño, asique ponemos el nombre como la dimension :)
			echo $img_name $ciclos >> $outf
		done
	done

	for f in $FILTROS; do
		for img in ../data/graficos/*; do
			img_name=$(basename $img | cut -d 'x' -f1)
			outf="$DATA_DIR/filtro-$f-en-$imp.data"

			ciclos=$(./tpcopados -i $imp -f $f $img asd.bmp -t $ITERACIONES | awk '{if (NR == 5) print;}' | cut -d ':' -f 2)
			ciclos=$(bc -l <<< "$ciclos / $ITERACIONES")

			# El nombre de la imagen es el tamaño, asique ponemos el nombre como la dimension :)
			echo $img_name $ciclos >> $outf

		done
	done

done

#sort
for imp in $IMP; do

	for g in $GRISES; do
		outf="$DATA_DIR/gris-$g-en-$imp.data"
		sort -k1 -n $outf > tmp
		mv tmp $outf

	done

	for f in $FILTROS; do
		outf="$DATA_DIR/filtro-$f-en-$imp.data"
		sort -k1 -n $outf > tmp
		mv tmp $outf
	done

done

# generamos los graficos
gnuplot plot.gpi
