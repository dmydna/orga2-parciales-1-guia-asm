#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "ej2.h"

/**
 * Marca el ejercicio 1A como hecho (`true`) o pendiente (`false`).
 *
 * Funciones a implementar:
 *   - es_indice_ordenado
 */
bool EJERCICIO_2A_HECHO = true;

/**
 * Marca el ejercicio 1B como hecho (`true`) o pendiente (`false`).
 *
 * Funciones a implementar:
 *   - contarCombustibleAsignado
 */
bool EJERCICIO_2B_HECHO = true;

/**
 * Marca el ejercicio 1B como hecho (`true`) o pendiente (`false`).
 *
 * Funciones a implementar:
 *   - modificarUnidad
 */
bool EJERCICIO_2C_HECHO = true;

/**
 * OPCIONAL: implementar en C
 */
void optimizar(mapa_t mapa, attackunit_t* compartida, uint32_t (*fun_hash)(attackunit_t*)) {

   for(int i=0; i< 255; i++){
    for(int j=0; j< 255; j++){

        attackunit_t* unidad_actual = mapa[i][j];
        if(!unidad_actual){
          continue;
        }
        if(fun_hash(unidad_actual) == fun_hash(compartida)){
           compartida->references ++;
           unidad_actual->references --;
           mapa[i][j] = compartida;
        }
    }
  }
}

/**
 * OPCIONAL: implementar en C
 */
uint32_t contarCombustibleAsignado(mapa_t mapa, uint16_t (*fun_combustible)(char*)) {
   
   uint32_t combustible_disponible = 0;
   uint32_t combustible_asignado = 0;
   uint32_t combustible_usado = 0;

   for(int i=0; i< 255; i++){
    for(int j=0; j< 255; j++){
        attackunit_t* unidad_actual = mapa[i][j];
        if(!unidad_actual){
          continue;
        }
        combustible_disponible += unidad_actual->combustible;
        combustible_asignado   += fun_combustible(unidad_actual->clase);
    }
  }

  combustible_usado = combustible_disponible - combustible_asignado;
  return combustible_usado;
}

/**
 * OPCIONAL: implementar en C
 */
void modificarUnidad(mapa_t mapa, uint8_t x, uint8_t y, void (*fun_modificar)(attackunit_t*)) {


   attackunit_t* unidad = mapa[x][y];

   if(!unidad){
      return;
   } 

   // es unidad compartida
   if(unidad->references > 0){
      attackunit_t* nueva_unidad = (attackunit_t*) malloc(sizeof(attackunit_t));
      strcpy( nueva_unidad->clase , unidad->clase);
      nueva_unidad->references = 1;
      nueva_unidad->combustible = unidad->combustible;
      unidad->references--;
      fun_modificar(nueva_unidad);
      mapa[x][y] = nueva_unidad;
   }else{
      fun_modificar(unidad);
   }

  return;

}
