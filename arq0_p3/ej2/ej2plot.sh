echo "Generating plot..."
# llamar a gnuplot para generar el gráfico y pasarle directamente por la entrada
# estándar el script que está entre "<< END_GNUPLOT" y "END_GNUPLOT"
gnuplot << END_GNUPLOT
set title "Data Cache Read Misses"
set ylabel "Misses"
set xlabel "Matrix Size"
set key right bottom
set grid
set term png
set output "cache_lectura.png"
plot "cache_1024.dat" using 1:2 with lines lw 2 title "slow 1024", \
     "cache_1024.dat" using 1:4 with lines lw 2 title "fast 1024", \
     "cache_2048.dat" using 1:2 with lines lw 2 title "slow 2048", \
     "cache_2048.dat" using 1:4 with lines lw 2 title "fast 2048", \
     "cache_4096.dat" using 1:2 with lines lw 2 title "slow 4096", \
     "cache_4096.dat" using 1:4 with lines lw 2 title "fast 4096", \
     "cache_8192.dat" using 1:2 with lines lw 2 title "slow 8192", \
     "cache_8192.dat" using 1:4 with lines lw 2 title "fast 8192"
replot
set title "Data Cache Write Misses"
set output "cache_escritura.png"
plot "cache_1024.dat" using 1:3 with lines lw 2 title "slow 1024", \
     "cache_1024.dat" using 1:5 with lines lw 2 title "fast 1024", \
     "cache_2048.dat" using 1:3 with lines lw 2 title "slow 2048", \
     "cache_2048.dat" using 1:5 with lines lw 2 title "fast 2048", \
     "cache_4096.dat" using 1:3 with lines lw 2 title "slow 4096", \
     "cache_4096.dat" using 1:5 with lines lw 2 title "fast 4096", \
     "cache_8192.dat" using 1:3 with lines lw 2 title "slow 8192", \
     "cache_8192.dat" using 1:5 with lines lw 2 title "fast 8192"
replot
quit
END_GNUPLOT
