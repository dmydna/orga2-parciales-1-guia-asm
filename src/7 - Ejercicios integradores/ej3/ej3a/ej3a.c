#include "../ejs.h"

// Función auxiliar para contar casos por nivel


void contar_casos_por_nivel(caso_t* arreglo_casos, int largo, int* contadores) {
    if(largo == 0){
        return;
    }
    for (int i = 0; i < largo; i++){
       contadores[arreglo_casos[i].usuario->nivel] ++;
    }
}



segmentacion_t* init_segmento(int* contadores){
    segmentacion_t* segmento = (segmentacion_t*)malloc(sizeof(segmentacion_t));

    segmento->casos_nivel_0 = NULL;
    segmento->casos_nivel_1 = NULL;
    segmento->casos_nivel_2 = NULL;

    if(contadores[0] != 0)
        segmento->casos_nivel_0 = (caso_t*) malloc(sizeof(caso_t)*contadores[0]);
    if(contadores[1] != 0)
        segmento->casos_nivel_1 = (caso_t*) malloc(sizeof(caso_t)*contadores[1]);
    if(contadores[2] != 0)
        segmento->casos_nivel_2 = (caso_t*) malloc(sizeof(caso_t)*contadores[2]);
    
    return segmento;
}

uint8_t* init_contadores(uint8_t largo){
    int* contadores = (int*) malloc(sizeof(int)*largo);
    for (int i = 0; i < largo; i++){
        contadores[i] = 0;
    }
    return contadores;
}


void asignar_segmento(caso_t* caso, segmentacion_t* segmento, int* indices){
    
    if(caso->usuario->nivel == 0){
       segmento->casos_nivel_0[indices[0]++] = *caso;
    }
    if(caso->usuario->nivel == 1){
       segmento->casos_nivel_1[indices[1]++] = *caso;
    }
    if(caso->usuario->nivel == 2){
      segmento->casos_nivel_2[indices[2]++] = *caso;
    }
}





segmentacion_t* segmentar_casos(caso_t* arreglo_casos, int largo) {
    

    uint8_t* contadores = init_contadores(3);

    contar_casos_por_nivel(arreglo_casos, largo, contadores);

    segmentacion_t* segmento = init_segmento(contadores);
    
    free(contadores);

    uint8_t* indices = init_contadores(3);

    for(int i=0; i<largo; i++){
        asignar_segmento(&arreglo_casos[i], segmento, indices);
    }

    free(indices);
    return segmento;
}



