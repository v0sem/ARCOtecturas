#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(){
	float ** test = NULL;

	test = (float **)malloc(sizeof(float *)*10000);
	if(!test)
		printf("Oops\n");
	
	return 0; 
}
