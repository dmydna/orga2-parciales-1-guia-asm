#include "../ejs.h"

estadisticas_t* calcular_estadisticas(caso_t* arreglo_casos, int largo, uint32_t usuario_id){

    estadisticas_t* estadisticas = malloc(sizeof(estadisticas_t*));

    for (size_t i = 0; i < largo; i++){
        caso_t  caso = arreglo_casos[i];
        int id_actual = caso.usuario->id;
        char* categoria = caso.categoria;
        int estado = caso.estado;

        if(usuario_id != 0 && usuario_id != id_actual ){
          continue;
        }

       // usuario_id == 0
       // usuario_id != 0 && usuario_id == id_actual

        if(strcmp(categoria, "CLT") == 0){
         estadisticas->cantidad_CLT ++;
        }
        if(strcmp(categoria, "RBO") == 0){
         estadisticas->cantidad_RBO ++;
        }
        if(strcmp(categoria, "KSC") == 0){
         estadisticas->cantidad_KSC ++;
        }
        if(strcmp(categoria, "KDT") == 0){
         estadisticas->cantidad_KDT ++;
        }
        switch (estado){
           case 1:  estadisticas->cantidad_estado_1 ++; break;
           case 2:  estadisticas->cantidad_estado_2 ++; break;
           default: estadisticas->cantidad_estado_0 ++; break;
        }
    }
    
    return estadisticas;
}


