#!/bin/bash
#$ -S /bin/sh

#Variables generales
P=$((3%7+4))

#Variables ej 1
N1=$((10000 + 1024 * P))
N2=$((10000 + 1024 * (P+1)))
N1=3000
N2=$((3000 + (64*10)))
N=0
Nstep=64
Ndata=time_slow_fast.dat
Nplot=time_slow_fast.png

rm -f $Ndata $Nplot
touch $Ndata

for x in {0..11}; do
	echo "$x"
	i=0
	for ((N = N1 ; N <= N2 ; N += Nstep)); do
		if (("$x"=="0")); then
			times_slow[$i]=0
			times_fast[$i]=0
		fi;
		slowTime_t=$(./slow "$N" | grep 'time' | awk '{print $3}')
		fastTime_t=$(./fast "$N" | grep 'time' | awk '{print $3}')
	
		times_slow[$i]=$(echo "${times_slow[$i]}" "$slowTime_t" | awk '{print $1 + $2}')
		times_fast[$i]=$(echo "${times_fast[$i]}" "$fastTime_t" | awk '{print $1 + $2}')
		i=$((i + 1))
	done
done

length=${#times_slow[@]}

for ((N = 0; N < length; N += 1 )); do

	echo "$N"

	slowTime=$(echo "${times_slow[$N]}" | awk '{print $1 / 12}')
	fastTime=$(echo "${times_fast[$N]}" | awk '{print $1 / 12}')

	echo "$N $slowTime $fastTime" >> $Ndata
done
	