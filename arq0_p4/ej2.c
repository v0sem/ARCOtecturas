#include <stdio.h>
#include <stdlib.h>
#include <omp.h>
#include "arqo4.h"

int main(int argc, char *argv[])
{
	float *A, *B;
	long long k=0;
	struct timeval fin,ini;
	float sum=0;
    int nproc, i;
	unsigned long long size;

    if(argc != 2){
        printf("Incluye el tamaño del vector\n");
        return -1;
    }

	size = atoll(argv[1]); 

    nproc = omp_get_num_procs();

    for(i = 1; i <= nproc; i++){
        omp_set_num_threads(i);

	    A = generateVector(M*size);
	    B = generateVector(M*size);
	    if ( !A || !B )
	    {
	    	printf("Error when allocationg matrix\n");
	    	freeVector(A);
	    	freeVector(B);
	    	return -1;
	    }
    
	    gettimeofday(&ini,NULL);
	    /* Bloque de computo */
	    sum = 0;
	    #pragma omp parallel for reduction(+:sum)
	    for(k=0;k<M;k++)
	    {
	    	sum = sum + A[k]*B[k];
	    }
	    /* Fin del computo */
	    gettimeofday(&fin,NULL);

	    printf("Resultado: %f\n",sum);
	    printf("Tiempo: %f\n", ((fin.tv_sec*1000000+fin.tv_usec)-(ini.tv_sec*1000000+ini.tv_usec))*1.0/1000000.0);
	    printf("\n");
        
        freeVector(A);
	    freeVector(B);
    }

	return 0;
}
