extern malloc
extern free
extern calloc
extern memset
;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

; Completar las definiciones (serán revisadas por ABI enforcer):
USUARIO_ID_OFFSET EQU 0
USUARIO_NIVEL_OFFSET EQU 4
USUARIO_SIZE EQU 8

CASO_CATEGORIA_OFFSET EQU 0
CASO_ESTADO_OFFSET EQU 4
CASO_USUARIO_OFFSET EQU 8
CASO_SIZE EQU 16

SEGMENTACION_CASOS0_OFFSET EQU 0
SEGMENTACION_CASOS1_OFFSET EQU 8
SEGMENTACION_CASOS2_OFFSET EQU 16
SEGMENTACION_SIZE EQU 24

ESTADISTICAS_CLT_OFFSET EQU 0
ESTADISTICAS_RBO_OFFSET EQU 1
ESTADISTICAS_KSC_OFFSET EQU 2
ESTADISTICAS_KDT_OFFSET EQU 3
ESTADISTICAS_ESTADO0_OFFSET EQU 4
ESTADISTICAS_ESTADO1_OFFSET EQU 5
ESTADISTICAS_ESTADO2_OFFSET EQU 6
ESTADISTICAS_SIZE EQU 7

;segmentacion_t* segmentar_casos(caso_t* arreglo_casos, int largo)
global segmentar_casos
segmentar_casos:
   ; RDI = caso_t* arreglo_casos
   ; RSI = int largo
   push rbp
   mov rbp, rsp
   
   push r12; r12 = arreglo
   push r13; r13 = largo
   push r14; r14 = contadores
   push r15; r15 = segmento
   push rbx; rbx = i
   push rbx
 
   mov r12, rdi
   mov r13, rsi

   ; contadores CASOS
   mov rdi, 3; count
   mov rsi, 4; uint32_t size
   call calloc
   mov r14, rax;@return uint32_t *contadores[3] 
   
   ;contar_casos_por_nivel(caso_t* arreglo_casos, int largo, int* contadores)
   mov rdi, r12; @param  arreglo_casos
   mov rsi, r13; @param  largo
   mov rdx, r14; @param  contadores
   call contar_casos_por_nivel
   ;@return void

   ;init_segmento(uint32_t* contadores)
   mov rdi, r14; @param contadores
   call init_segmento
   mov r15, rax ;@return segmentacion_t* segmento 

   ; contadores INDICES
   mov  rdi, r14; ptr
   mov  rsi, 0; value
   mov  rdx, 12; size
   call memset ;@return void

   xor rbx, rbx; i = 0

   .while:
      cmp rbx, rsi 
      je .done
      ; asignar_segmento( arreglo_casos[i], segmento, indices );
      mov r8, rbx; i
      shl r8, 4; i * CASO_SIZE = caso_offset
      lea rdi, [r12 + r8]; @param &arreglo_casos[i]
      mov rsi, r15;        @param segmento
      mov rdx ,r14;        @param indices
      call asignar_segmento
      ;@return void

   .continue:
   inc rbx

   .done:

   mov rdi, r14
   call free

   mov rax, r15; segmentacion_t* segmento

   pop rbx
   pop rbx
   pop r15
   pop r14
   pop r13
   pop r12
   
   pop rbp
   ret


;void contar_casos_por_nivel(caso_t* arreglo_casos, int largo, uint32_t* contadores) 
global contar_casos_por_nivel
contar_casos_por_nivel:
   ; RDI = caso_t* arreglo_casos
   ; RSI = int largo
   ; RDX = uint32_t* contadores
   cmp rsi, 0
   jz .done

   xor r8, r8; i = 0
   xor r9, r9
   xor r11, r11
   .while:
      cmp r8, rsi
      je .done

      mov r10, r8
      shl r10, 4; contador_offset
      lea r10, [rdi + r10]; caso_t* caso
      mov r9d,  DWORD [r10 + CASO_USUARIO_OFFSET]; caso->usuario
      mov r11d, DWORD[r9 + USUARIO_NIVEL_OFFSET]; usuario->nivel
      inc DWORD [rdx + r11 * 4]; contadores[nivel]++

   .continue:
   inc r8 ; i++
   jmp .while

   .done:
   
   ret


;segmentacion_t* init_segmento(int* contadores)
global init_segmento
init_segmento:
   ; RDI = int* contadores
   push rbp
   mov rbp, rsp

   push r12
   push r13
   push r14
   push r15

   mov r12, rdi

   mov rdi, 1
   mov rsi, SEGMENTACION_SIZE
   call calloc
   mov r15, rax

   caso0:; contadores[0] == 0?
      cmp DWORD [r12 + 0], 0
      jz .caso1
 
      xor rdi, rdi
      mov edi, DWORD[r12 + 0]; contadores[0]
      shl rdi, 4; contadores[0] * CASO_SIZE
      call malloc
      mov [r15 + SEGMENTACION_CASOS0_OFFSET], rax

   .caso1:; contadores[1] == 0?
      cmp DWORD[r12 + 4], 0
      jz .caso2
 
      xor rdi, rdi
      mov edi, DWORD [r12 + 4]; contadores[1]
      shl rdi, 4; contadores[1] * CASO_SIZE
      call malloc
      mov [r15 + SEGMENTACION_CASOS1_OFFSET], rax

   .caso2:; contadores[2] == 0?
      cmp DWORD [r12 + 8], 0
      jz .done

      xor rdi, rdi
      mov edi, DWORD [r12 + 8]; contadores[2]
      shl rdi, 4; contadores[2] * CASO_SIZE
      call malloc
      mov [r15 + SEGMENTACION_CASOS2_OFFSET], rax

   .done: 

   mov rax, r15

   pop r15
   pop r14
   pop r13
   pop r12


   pop rbp
   ret;@return segmentacion_t*

;void asignar_segmento(caso_t* caso, segmentacion_t* segmento,uint32_t* indices);
global asignar_segmento
asignar_segmento:
  ; RDI = caso_t* caso
  ; RSI = segmentacion_t* segmento
  ; RDX = uint32_t* indices
   push rbp
   mov rbp, rsp

   push r12
   push r13
   push r14
   push r15

   xor r14, r14

   mov r11, [rdi] ; caso_t caso
   mov r12, [rdi + CASO_USUARIO_OFFSET] ; caso->usuario

   ;usuario->nivel == 0?
   cmp DWORD [r12 + USUARIO_NIVEL_OFFSET], 0
   je .caso0
   ;usuario->nivel == 1?
   cmp DWORD [r12 + USUARIO_NIVEL_OFFSET], 1
   je .caso1
   ;usuario->nivel == 2?
   cmp DWORD [r12 + USUARIO_NIVEL_OFFSET], 2
   je .caso2

   .caso0:
      ; segmento->caso_nivel_0
      mov r13, [rsi + SEGMENTACION_CASOS0_OFFSET]
      mov r14d, DWORD [rdx + 0] ; indice[0]
      inc DWORD [rdx + 0];  indice[0] ++
      jmp .done
   .caso1:
      ; segmento->caso_nivel_1
      mov r13, [rsi + SEGMENTACION_CASOS1_OFFSET]; 
      mov r14d, DWORD [rdx + 4] ; indice[1]
      inc DWORD [rdx + 4] ; indice[1] ++
      jmp .done
   .caso2:
      ; segmento->caso_nivel_2
      mov r13, [rsi + SEGMENTACION_CASOS2_OFFSET]
      mov r14d, DWORD [rdx + 8] ; indice[2]
      inc DWORD [rdx + 0] ; indice[2] ++

   .done:
   shl r14, 4; indice_n_offset
   mov [r13 + r14], r11 ; casos_nivel_n[indice_n] = caso


   mov rax, rsi; 

   pop r15
   pop r14
   pop r13
   pop r12

   pop rbp
   ret; @return segmentacion_t* 