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
set output "time_slow_fast.png"
plot "time_slow_fast.dat" using 1:2 with lines lw 2 title "slow", \
     "time_slow_fast.dat" using 1:3 with lines lw 2 title "fast"
quit
END_GNUPLOT
