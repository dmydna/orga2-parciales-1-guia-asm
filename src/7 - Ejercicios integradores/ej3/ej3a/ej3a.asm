extern free
extern malloc

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


; void contar_casos_por_nivel(caso_t* arreglo_casos, int largo, int* contadores)
contar_casos_por_nivel:
; RDI = caso_t* arreglo_casos  
; RSI = int largo
; RDX = int* contadores

push rbp
mov rbp, rsp

push r15
push r14
push r13
push r12
push rbx
push rbx

xor rbx, rbx
xor r8, r8
.for:
cmp rbx, rsi 

lea rcx, [rdi + r8]; caso_t*
mov rcx, [rcx + CASO_USUARIO_OFFSET] ; caos->usuario
mov rcx, [rcx + USUARIO_NIVEL_OFFSET]



.continue:
inc rbx
imul r8, rbx, 16

jmp .for

.end:

pop rbx
pop rbx
pop r12
pop r13
pop r14
pop r15



pop rbp
ret

;segmentacion_t* segmentar_casos(caso_t* arreglo_casos, int largo)
global segmentar_casos
segmentar_casos:

; rdi = arreglo_casos
; rsi = largo

push rbp
mov rbp, rsp



sub rsp, 24
push r15
push r14
push r13
push r12
push rbx


mov r15, rdi; R15 = arreglo_casos
mov r14, rsi; R14 = largo


; int contadores[3] = {0,0,0};
mov rsi, 24
call malloc

mov [rax ], 0
mov [rax + 8], 0
mov [rax + 16], 0 

mov rdi, rax
mov rsi, r14
;contar_casos_por_nivel(arreglo_casos, largo, contadores);
call contar_por_nivel
mov r13, rax ; R13 = int contadores[3]


mov rdi, SEGMENTACION_SIZE
call malloc

mov r12, rax

mov [r12 + SEGMENTACION_CASOS0_OFFSET], 0
mov [r12 + SEGMENTACION_CASOS1_OFFSET], 0
mov [r12 + SEGMENTACION_CASOS2_OFFSET], 0

;if contadores[0]
cmp qword [r13],  0
jz .continue0

mov  rdi, CASO_SIZE
imul rdi, [r13 + 8]
call malloc
mov [r12 + SEGMENTACION_CASOS2_OFFSET], rax

.continue0:
;if contadores[0]
cmp qword [r13 + 16],  0
jz .continue1

mov  rdi, CASO_SIZE
imul rdi, [r13 + 8]
call malloc
mov [r12 + SEGMENTACION_CASOS2_OFFSET], rax


.continue1:

;if contadores[0]
cmp qword [r13 + 24], 0
jz .continue2

mov  rdi, CASO_SIZE
imul rdi, [r13 + 8]
call malloc
mov [r12 + SEGMENTACION_CASOS2_OFFSET], rax

.continue2:

xor rdi, rdi; a = 0
xor rsi, rdi; b = 0
xor rdx, rdx; c = 0

xor rbx, rbx; i = 0
.while:
cmp rbx, r14
je .end

lea r10, [r15 + rbx * 8]
.switch:

.case0:
cmp [r10 +  USUARIO_NIVEL_OFFSET], 0
jne .case1

cmp [r12 + SEGMENTACION_CASOS0_OFFSET],0
je .continue
mov [r12 + SEGMENTACION_CASOS0_OFFSET], r10

jmp .continue

·case1:
cmp [r10 +  USUARIO_NIVEL_OFFSET], 0
jne .case2
cmp [r12 + SEGMENTACION_CASOS1_OFFSET],0
je .continue
mov [r12 + SEGMENTACION_CASOS1_OFFSET], r10



jmp .continue
.case2:
cmp [r10 +  USUARIO_NIVEL_OFFSET], 0
jne .continue

cmp [r12 + SEGMENTACION_CASOS2_OFFSET],0
je .continue
mov [r12 + SEGMENTACION_CASOS2_OFFSET], r10

.continue:
inc rbx
jmp .while
.end


pop rbx
pop rbx
pop r12
pop r13
pop r14
pop r15


pop rbp
ret
