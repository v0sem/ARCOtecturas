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

#Variables ej 3
N1=$((256 + 256 * P))
N2=$((256 + 256 * (P+1)))
N=0
Nstep=16
Ndata=mult.dat

rm -f $Ndata $Nplot
touch $Ndata

for x in {0..4}; do
	echo "$x"
	i=0
	for ((N = N1 ; N <= N2 ; N += Nstep)); do
		if (("$x"=="0")); then
			times_norm[$i]=0
			times_trans[$i]=0
			normD1mr[$i]=0
			normD1rw[$i]=0
			transD1mr[$i]=0
			transD1rw[$i]=0
		fi;
		normTime_t=$(./mult_matrix "$N" | grep 'time' | awk '{print $3}')
		transTime_t=$(./mult_trans "$N" | grep 'time' | awk '{print $3}')

	
		times_norm[$i]=$(echo "${times_norm[$i]}" "$normTime_t" | awk '{print $1 + $2}')
		times_trans[$i]=$(echo "${times_trans[$i]}" "$transTime_t" | awk '{print $1 + $2}')
		i=$((i + 1))
	done
done

length=${#times_norm[@]}



for ((N = 0; N < length; N += 1 )); do
    Nsize=$((N1 + Nstep * N))
	echo "$N"

	normTime=$(echo "${times_norm[$N]}" | awk '{print $1/5}')
	transTime=$(echo "${times_trans[$N]}" | awk '{print $1/5}')

	valgrind --tool=cachegrind --cachegrind-out-file=norm.out ./mult_matrix $Nsize
	valgrind --tool=cachegrind --cachegrind-out-file=trans.out ./mult_trans $Nsize

	normD1mr=$(cg_annotate norm.out | grep PROGRAM | awk '{print $5}' | tr -d ',')
	normD1rw=$(cg_annotate norm.out | grep PROGRAM | awk '{print $8}' | tr -d ',')
	transD1mr=$(cg_annotate trans.out | grep PROGRAM | awk '{print $5}' | tr -d ',')
	transD1rw=$(cg_annotate trans.out | grep PROGRAM | awk '{print $8}' | tr -d ',')

	echo "$Nsize $normTime $normD1mr $normD1rw $transTime $transD1mr $transD1rw" >> $Ndata
done
	