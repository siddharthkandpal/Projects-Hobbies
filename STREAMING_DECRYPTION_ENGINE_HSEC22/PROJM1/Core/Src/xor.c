#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>


void do_xor(uint8_t * input_array, uint8_t * key, uint8_t * output_array){

	for(int i = 0; i < 16; i++){
		output_array[i] = input_array[i] ^ key[i];
	}

}
