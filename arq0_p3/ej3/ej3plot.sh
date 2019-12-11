echo "Generating plot..."
# llamar a gnuplot para generar el gráfico y pasarle directamente por la entrada
# estándar el script que está entre "<< END_GNUPLOT" y "END_GNUPLOT"
gnuplot << END_GNUPLOT
set title "Data Cache Misses"
set ylabel "Misses"
set xlabel "Matrix Size"
set key right bottom
set grid
set term png
set output "mult_cache.png"
plot "mult.dat" using 1:3 with lines lw 2 title "read normal", \
     "mult.dat" using 1:6 with lines lw 2 title "read trans", \
     "mult.dat" using 1:4 with lines lw 2 title "write normal", \
     "mult.dat" using 1:7 with lines lw 2 title "write trans"
replot
set title "Matrix Product Times"
set ylabel "Time (s)"
set output "mult_times.png"
plot "mult.dat" using 1:2 with lines lw 2 title "normal", \
     "mult.dat" using 1:5 with lines lw 2 title "trans"
replot
quit
END_GNUPLOT
