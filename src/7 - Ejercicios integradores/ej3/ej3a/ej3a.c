#include "../ejs.h"

// Función auxiliar para contar casos por nivel
void contar_casos_por_nivel(caso_t* arreglo_casos, int largo, int* contadores) {
    for (int i = 0; i < largo; i++){
        caso_t caso = arreglo_casos[i];
        contadores[caso.usuario->nivel]++;
        }
}





segmentacion_t* segmentar_casos(caso_t* arreglo_casos, int largo) {


    int contadores[3] = {0,0,0};
    contar_casos_por_nivel(arreglo_casos, largo, contadores);


    caso_t* casos_nivel_0 = NULL;
    caso_t* casos_nivel_1 = NULL;
    caso_t* casos_nivel_2 = NULL;

    if(contadores[0]) casos_nivel_0 = (caso_t*)malloc(sizeof(caso_t) * contadores[0]);
    if(contadores[1]) casos_nivel_0 = (caso_t*)malloc(sizeof(caso_t) * contadores[0]);
    if(contadores[2]) casos_nivel_0 = (caso_t*)malloc(sizeof(caso_t) * contadores[0]);


    int a = 0;
    int b = 0;
    int c = 0;

    for (int i = 0; i < largo; i++){

        caso_t caso = arreglo_casos[i];
        switch (caso.usuario->nivel){
           case 0: if(casos_nivel_0) casos_nivel_0[a++] = caso; break; 
           case 1: if(casos_nivel_1) casos_nivel_1[b++] = caso; break;
           case 2: if(casos_nivel_2) casos_nivel_2[c++] = caso; break;
        }
    }

    segmentacion_t* casos_por_segmento = (segmentacion_t*)malloc(sizeof(segmentacion_t));

    *casos_por_segmento = (segmentacion_t){
        .casos_nivel_0 = casos_nivel_0, 
        .casos_nivel_1 = casos_nivel_1, 
        .casos_nivel_2 = casos_nivel_2
    };

    return casos_por_segmento;
}



