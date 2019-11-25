#!/bin/bash
#
#$ -S /bin/bash
#$ -cwd
#$ -o valgrind.out
#$ -j y
# Anadir valgrind al path
export PATH=$PATH:/share/apps/tools/valgrind/bin
# Indicar ruta librerías valgrind
export VALGRIND_LIB=/share/apps/tools/valgrind/lib/valgrind
# Lanzar valgrind
valgrind –-tool=cachegrind –-cachegrind-out-file=out.dat ./fast 100cg_annotate out.dat > salida_fast.txt 