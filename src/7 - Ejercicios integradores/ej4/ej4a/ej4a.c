#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "ej4a.h"

/**
 * Marca el ejercicio 1A como hecho (`true`) o pendiente (`false`).
 *
 * Funciones a implementar:
 *   - init_fantastruco_dir
 */
bool EJERCICIO_1A_HECHO = true;

// OPCIONAL: implementar en C
void init_fantastruco_dir(fantastruco_t* card) {

    directory_entry_t* dormir =  create_dir_entry("sleep", sleep);
    directory_entry_t* despertar = create_dir_entry("wakeup", wakeup);

    card->__dir = (directory_entry_t**)malloc(sizeof(directory_entry_t*)*2);
    card->__dir_entries = 2;
    card->__dir[0] = dormir;
    card->__dir[1] = despertar;

}

/**
 * Marca el ejercicio 1A como hecho (`true`) o pendiente (`false`).
 *
 * Funciones a implementar:
 *   - summon_fantastruco
 */
bool EJERCICIO_1B_HECHO = true;

// OPCIONAL: implementar en C
fantastruco_t* summon_fantastruco() {

    fantastruco_t* card = (fantastruco_t*) malloc(sizeof(fantastruco_t));
    init_fantastruco_dir(card);
    card->__archetype = NULL;
    card->face_up = true;

    return card;
}
