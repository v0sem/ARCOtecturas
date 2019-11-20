#!/bin/bash

#Variables generales
P=$((3%7+4))

#Variables ej 1
N1=$((10000 + 1024 * P))
N2=$((10000 + 1024 * (P+1)))
Nstep=64
Ndata=time_slow_fast.dat
Nplot=time_slow_fast.png

rm -f $Ndata $Nplot
touch $Ndata

for ((N = N1 ; N <= N2 ; N += Nstep)); do

	slowTime=0

    slowTime1=$(./slow $N | grep 'time' | awk '{print $3}')
	slowTime2=$(./slow $N | grep 'time' | awk '{print $3}')
	fastTime1=$(./fast $N | grep 'time' | awk '{print $3}')
	fastTime2=$(./fast $N | grep 'time' | awk '{print $3}')

	slowTime3=$(./slow $N | grep 'time' | awk '{print $3}')
	slowTime4=$(./slow $N | grep 'time' | awk '{print $3}')
	fastTime3=$(./fast $N | grep 'time' | awk '{print $3}')
	fastTime4=$(./fast $N | grep 'time' | awk '{print $3}')

	slowTime+=$(echo $slowTime1 $slowTime2 $slowTime3 $slowTime4 | awk '{print $1 + $2 + $3 + $4}')
	slowTime=$(echo $slowTime | awk '{print $1 / 4}')
	fastTime+=$(echo $fastTime1 $fastTime2 $fastTime3 $fastTime4 | awk '{print $1 + $2 + $3 + $4}')
	fastTime=$(echo $fastTime | awk '{print $1 / 4}')

	echo "$N $slowTime $fastTime" >> $Ndata
	
done

echo "Generating plot..."
# llamar a gnuplot para generar el gráfico y pasarle directamente por la entrada
# estándar el script que está entre "<< END_GNUPLOT" y "END_GNUPLOT"
gnuplot << END_GNUPLOT
set title "Slow-Fast Execution Time"
set ylabel "Execution time (s)"
set xlabel "Matrix Size"
set key right bottom
set grid
set term png
set output "$Nplot"
plot "$Ndata" using 1:2 with lines lw 2 title "slow", \
     "$Ndata" using 1:3 with lines lw 2 title "fast"
replot
quit
END_GNUPLOT
