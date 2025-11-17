#include "../ejs.h"

void resolver_automaticamente(funcionCierraCasos_t* funcion, caso_t* arreglo_casos, caso_t* casos_a_revisar, int largo){
    
    int j = 0;
    for (size_t i = 0; i < largo; i++){
        caso_t caso = arreglo_casos[i];
        int nivel = caso.usuario->nivel;
        char* categoria = caso.categoria;
        uint16_t funcionCierraCasos = funcion(&caso);
        if(nivel == 0){
            casos_a_revisar[j++] = caso;
            continue;
        }
        if(funcionCierraCasos == 1){
            caso.estado = 1;
        }else{
            // funcionCierraCasos == 0
            if(strcmp(categoria,"CLT") == 0 || 
               strcmp(categoria,"RBO") == 0){
                caso.estado = 2;
            }else{
                casos_a_revisar[j++] = caso;
            }
        }
    }
    
}

