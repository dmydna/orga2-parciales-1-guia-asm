#include "ej4b.h"

#include <string.h>

// OPCIONAL: implementar en C
void invocar_habilidad(void* carta_generica, char* habilidad) {
	card_t* carta = carta_generica;
	void (*ability)(card_t*);
	while (carta){
		for (int i = 0; i < carta->__dir_entries; i++){
			if(strcmp(carta->__dir[i]->ability_name, habilidad) == 0){
			    ability =  carta->__dir[i]->ability_ptr;
				ability(carta);
			}
		}
	   carta = carta->__archetype;
	}
}


