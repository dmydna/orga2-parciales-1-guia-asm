#include "../ejs.h"

estadisticas_t* calcular_estadisticas(caso_t* arreglo_casos, int largo, uint32_t usuario_id){

      estadisticas_t* estadisticas = calloc(1, sizeof(estadisticas_t));

      for(int i=0; i<largo;i++){
        if(usuario_id != 0 && arreglo_casos[i].usuario->id == usuario_id){
            cantidad_por_casos(estadisticas, &arreglo_casos[i]);
        }
        if(usuario_id == 0){
            cantidad_por_casos(estadisticas, &arreglo_casos[i]);
        }
      }

    return estadisticas;
}

void cantidad_por_casos(estadisticas_t* estadisticas, caso_t* caso){
    
    if(strcmp(caso->categoria, "CLT") == 0){
        estadisticas->cantidad_CLT ++;
    };
    if(strcmp(caso->categoria, "RBO") == 0){
        estadisticas->cantidad_RBO ++;
    };
    if(strcmp(caso->categoria, "KSC") == 0){
        estadisticas->cantidad_KSC ++;
    };
    if(strcmp(caso->categoria, "KDT") == 0){
        estadisticas->cantidad_KDT ++;
    }

    if(caso->estado == 0){
        estadisticas->cantidad_estado_0++;
    }
    if(caso->estado == 1){
        estadisticas->cantidad_estado_1++;
    }
    if(caso->estado == 2){
        estadisticas->cantidad_estado_2++;
    }
}

