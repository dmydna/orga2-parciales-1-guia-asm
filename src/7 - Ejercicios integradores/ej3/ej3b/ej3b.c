#include "../ejs.h"

void resolver_automaticamente(funcionCierraCasos_t* funcion, caso_t* arreglo_casos, caso_t* casos_a_revisar, int largo){
   
   int j=0;
   for(int i=0; i < largo; i++){
     caso_t* caso = &arreglo_casos[i];
     separa_por_caso(funcion, caso, casos_a_revisar, &j);
   }
}


void separa_por_caso(funcionCierraCasos_t* funcion, caso_t* caso, caso_t* casos_a_revisar, int* j){
    if(caso->usuario->nivel == 0){
        casos_a_revisar[*j++] = *caso;
        return;
     }
     if( funcion(caso) == 1){
       caso->estado = 1;
     }else{
        if(strcmp ((caso->categoria), "CLT") == 0 || strcmp ( (caso->categoria),  "RBO") == 0){
           caso->estado = 2;
        }else{
           casos_a_revisar[*j++] = *caso;
        }
     }
}



