extern calloc
extern strcmp
;########### SECCION DE DATOS
section .data

CLT db "CLT", 0
RBO db "RBO", 0
KSC db "KSC", 0
KDT db "KDT", 0

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

global calcular_estadisticas

;void calcular_estadisticas(caso_t* arreglo_casos, int largo, uint32_t usuario_id)
calcular_estadisticas:
    ; RDI = caso_t* arreglo_casos
    ; RSI = int largo
    ; RDX = uint32_t usuario_id
    push rbp
    mov rbp, rsp

    push r12
    push r13
    push r14
    push r15

    mov r15, RDI; R15 = arreglo_caso
    mov r14, RSI; R14 = largo
    mov r13, RDX; R13 = usuario_id

    mov rdi, ESTADISTICAS_SIZE
    mov rsi, 1
    call calloc
    mov r12, rax

    xor rbx, rbx; i=0

    .while:
       cmp rbx, r14; i == largo?
       je .done
       ; i * CASO_SIZE
       mov r8, rbx
       shl r8, 4

    .caso1:
       cmp r13, 0; usuario_id == 0
       je .caso2
   
       lea r10, [r15 + r8]; &arreglo_caso[i]
       mov r10, [r10 + CASO_USUARIO_OFFSET];caso->usuario
       xor r9, r9
       mov r9d, DWORD [r10 + USUARIO_ID_OFFSET]; usuario->id 
       cmp r9, r13; id == usuario_id
       jne .continue

    .resolverCaso:
       mov rdi, r12       ;@param estadistica_t* estadistica
       lea rsi,[r15 + r8] ;@param caso_t* caso
       ;cantidad_por_caso(estadisticas, caso)
        call cantidad_por_caso 
       ;@return void
       jmp .continue

    .caso2:
        jmp .resolverCaso
    .continue:
    inc rbx
    jmp .while
    
    .done:
    mov rax, r12

    pop r15
    pop r14
    pop r13
    pop r12

    pop rbp
    ret



cantidad_por_caso:
    ;RDI = estadistica_t* estadistica
    ;RSI = caso_t* caso
    push rbp
    mov rbp, rsp

    push r12
    push r13
    push r14
    push r15

    mov r15, rdi; r15 = estadistica_t* estadisticas
    mov r14, rsi; r14 = caso_t* caso
    lea r13, [rsi + CASO_CATEGORIA_OFFSET]

    mov rdi, r13
    mov rsi, CLT
    call strcmp
    cmp rax, 0
    je .caso_CLT

    mov rdi, r13
    mov rsi, RBO
    call strcmp
    cmp rax, 0
    je .caso_RB0

    mov rdi, r13
    mov rsi, KSC
    call strcmp
    cmp rax, 0
    je .caso_KSC

    mov rdi, r13
    mov rsi, KDT
    call strcmp
    cmp rax, 0
    je .caso_KDT
   
   .caso_CLT:
      inc BYTE [r15 + ESTADISTICAS_CLT_OFFSET]
      jmp .continue
   .caso_KDT:
      inc BYTE [r15 + ESTADISTICAS_KDT_OFFSET]
      jmp .continue
   .caso_KSC:
      inc BYTE [r15 + ESTADISTICAS_KSC_OFFSET]
      jmp .continue
   .caso_RB0:
      inc BYTE [r15 + ESTADISTICAS_RBO_OFFSET]

    .continue:
    cmp WORD [r14 + CASO_ESTADO_OFFSET], 0
    je .caso0
    cmp WORD [r14 + CASO_ESTADO_OFFSET], 1
    je .caso1
    cmp WORD [r14 + CASO_ESTADO_OFFSET], 2
    je .caso2

    .caso0:
      inc BYTE [r15 + ESTADISTICAS_ESTADO0_OFFSET]
      jmp .done
    .caso1:
      inc BYTE [r15 + ESTADISTICAS_ESTADO1_OFFSET]
      jmp .done
    .caso2:
      inc BYTE [r15 + ESTADISTICAS_ESTADO2_OFFSET]

    .done:
    pop r15
    pop r14
    pop r13
    pop r12

    pop rbp
    ret