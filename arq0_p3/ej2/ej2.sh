#!/bin/bash
#$ -S /bin/sh
#$ -cwd
#$ -o valgrind.out
#$ -j y

#Iniciar Valgrind
export PATH=$PATH:/share/apps/tools/valgrind/bin
export VALGRIND_LIB=/share/apps/tools/valgrind/lib/valgrind

#Variables generales
P=$((3%7+4))

#Variables ej 2
N1=$((2000 + 512 * P))
N2=$((2000 + 512 * (P+1)))
N=0
Nstep=64

rm cache_*

for ((N = N1 ; N <= N2 ; N += Nstep)); do
	
	valgrind --tool=cachegrind --cachegrind-out-file=slow.out --I1=1024,1,64 --D1=1024,1,64 --LL=8388608,1,64 ./slow $N
	valgrind --tool=cachegrind --cachegrind-out-file=fast.out --I1=1024,1,64 --D1=1024,1,64 --LL=8388608,1,64 ./fast $N

	slowD1mr=$(cg_annotate slow.out | grep PROGRAM | awk '{print $5}' | tr -d ',')
	slowD1rw=$(cg_annotate slow.out | grep PROGRAM | awk '{print $8}' | tr -d ',')
	fastD1mr=$(cg_annotate fast.out | grep PROGRAM | awk '{print $5}' | tr -d ',')
	fastD1rw=$(cg_annotate fast.out | grep PROGRAM | awk '{print $8}' | tr -d ',')
	
	echo "$N $slowD1mr $slowD1rw $fastD1mr $fastD1rw" >> cache_1024.dat

	valgrind --tool=cachegrind --cachegrind-out-file=slow.out --I1=2048,1,64 --D1=2048,1,64 --LL=8388608,1,64 ./slow $N
	valgrind --tool=cachegrind --cachegrind-out-file=fast.out --I1=2048,1,64 --D1=2048,1,64 --LL=8388608,1,64 ./fast $N

	slowD1mr=$(cg_annotate slow.out | grep PROGRAM | awk '{print $5}' | tr -d ',')
	slowD1rw=$(cg_annotate slow.out | grep PROGRAM | awk '{print $8}' | tr -d ',')
	fastD1mr=$(cg_annotate fast.out | grep PROGRAM | awk '{print $5}' | tr -d ',')
	fastD1rw=$(cg_annotate fast.out | grep PROGRAM | awk '{print $8}' | tr -d ',')
	
	echo "$N $slowD1mr $slowD1rw $fastD1mr $fastD1rw" >> cache_2048.dat

	valgrind --tool=cachegrind --cachegrind-out-file=slow.out --I1=4096,1,64 --D1=4096,1,64 --LL=8388608,1,64 ./slow $N
	valgrind --tool=cachegrind --cachegrind-out-file=fast.out --I1=4096,1,64 --D1=4096,1,64 --LL=8388608,1,64 ./fast $N

	slowD1mr=$(cg_annotate slow.out | grep PROGRAM | awk '{print $5}' | tr -d ',')
	slowD1rw=$(cg_annotate slow.out | grep PROGRAM | awk '{print $8}' | tr -d ',')
	fastD1mr=$(cg_annotate fast.out | grep PROGRAM | awk '{print $5}' | tr -d ',')
	fastD1rw=$(cg_annotate fast.out | grep PROGRAM | awk '{print $8}' | tr -d ',')
	
	echo "$N $slowD1mr $slowD1rw $fastD1mr $fastD1rw" >> cache_4096.dat

	valgrind --tool=cachegrind --cachegrind-out-file=slow.out --I1=8192,1,64 --D1=8192,1,64 --LL=8388608,1,64 ./slow $N
	valgrind --tool=cachegrind --cachegrind-out-file=fast.out --I1=8192,1,64 --D1=8192,1,64 --LL=8388608,1,64 ./fast $N

	slowD1mr=$(cg_annotate slow.out | grep PROGRAM | awk '{print $5}' | tr -d ',')
	slowD1rw=$(cg_annotate slow.out | grep PROGRAM | awk '{print $8}' | tr -d ',')
	fastD1mr=$(cg_annotate fast.out | grep PROGRAM | awk '{print $5}' | tr -d ',')
	fastD1rw=$(cg_annotate fast.out | grep PROGRAM | awk '{print $8}' | tr -d ',')
	
	echo "$N $slowD1mr $slowD1rw $fastD1mr $fastD1rw" >> cache_8192.dat
done

rm *.out
	