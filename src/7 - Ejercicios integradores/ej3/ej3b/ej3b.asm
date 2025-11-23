extern strcmp
;########### SECCION DE DATOS
section .data

CLT db "CLT", 0
RBO db "RBO", 0

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

global resolver_automaticamente

;void resolver_automaticamente(funcionCierraCasos* funcion, caso_t* arreglo_casos, caso_t* casos_a_revisar, int largo)
resolver_automaticamente:
    ; rdi = *funcion(caso_t* caso)
    ; rsi = caso_t* arreglo_casos
    ; rdx = caso_t* casos_a_revisar
    ; rcx = int largo
    push rbp
    mov rbp, rsp


    push r12; largo
    push r13; casos_a_revisar
    push r14; arreglo_caso
    push r15; *funcion
    push rbx; i
    sub rsp, 8

    mov r15, rdi
    mov r14, rsi
    mov r13, rdx
    mov r12, rcx 
    mov QWORD [rbp-8], 0; indice caso_a_revisar

    xor rbx, rbx; i=0
    .while:
       cmp rbx, r12; i == largo?
       je .done
   
       mov r8, rbx
       shl r8, 4; i * CASO_SIZE
      ; separar_por_casos(funcion, caso, caso_a_revisar, indice)
       mov rdi, r15       ;@param *funcion
       lea rsi, [r14 + r8];@param caso_t* caso
       mov rdx, r13       ;@param casos_a_revisar
       lea rcx, [rbp-8]   ;@param *indice
       call separar_por_casos
       ;@return void

    .continue:
       inc rbx; i++
       jmp .while

    .done:

    add rsp, 8
    pop rbx; i
    pop r15
    pop r14
    pop r13
    pop r12

    pop rbp
    ret


global separar_por_casos
separar_por_casos:
    ; rdi = &funcion(caso_t caso)
    ; rsi = caso_t* caso
    ; rdx = caso_t* casos_a_revisar
    ; rcx = int* indiceARevisar
    push rbp
    mov rbp, rsp

    push r12
    push r13
    push r14
    push r15

    mov r15, rdi; R15 = *funcion
    mov r14, rsi; R14 = *caso
    mov r13, rdx; R13 = caso_a_revisar
    mov r12, rcx; R12 = *indiceARevisar 

    .esDeNivelCero:
        mov r11, [r14 + CASO_USUARIO_OFFSET]
        xor r10, r10
        mov r10d, DWORD [r11 + USUARIO_NIVEL_OFFSET]
        cmp r10, 0
        jne .esCasoUno

    .agregarCasosARevisar:
    mov r9, [r14]
    mov r8, [r12]
    shl r8, 4
    mov [r13 + r8], r9
    inc QWORD [r12]
    jmp .done


    .esCasoUno:

        mov rdi, r14;@param caso_t*
        call R15; funcion(caso)
        ;@return int
        cmp rax, 1
        jne .esCasoDos 
        mov WORD [r14 + CASO_ESTADO_OFFSET], 1
        jmp .done

    .esCasoDos:
        mov rdi, r14;@para caso_t*
        ;esCategoriaParaCerrarCaso(caso)
        call esCategoriaParaCerrarCaso
        ;@return bool
        cmp rax, 1
        jne .agregarCasosARevisar

        mov WORD [r14 + CASO_ESTADO_OFFSET], 2

    .done:
    pop r15
    pop r14
    pop r13
    pop r12
    
    pop rbp
    ret



; bool esCategoriaParaCerrarCaso(caso_t* caso)
esCategoriaParaCerrarCaso:
    ; rdi = caso_t *caso
    push rbp
    mov rbp, rsp
    

    xor rax, rax

    .caso_RB0:
    mov rdi, RBO
    call strcmp
    cmp rax, 0
    jz .true
    
    .caso_CLT:
    mov rdi, CLT
    call strcmp 
    cmp rax, 0
    jz .true

    xor rax, rax
    jmp .done

    .true:
    mov rax, 1

    .done:
    pop rbp
    ret; @return bool