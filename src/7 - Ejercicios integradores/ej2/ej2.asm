extern malloc
extern strcpy

section .rodata
; Acá se pueden poner todas las máscaras y datos que necesiten para el ejercicio

section .text
; Marca un ejercicio como aún no completado (esto hace que no corran sus tests)
FALSE EQU 0
; Marca un ejercicio como hecho
TRUE  EQU 1

; Marca el ejercicio 1A como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - optimizar
global EJERCICIO_2A_HECHO
EJERCICIO_2A_HECHO: db FALSE ; Cambiar por `TRUE` para correr los tests.

; Marca el ejercicio 1B como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - contarCombustibleAsignado
global EJERCICIO_2B_HECHO
EJERCICIO_2B_HECHO: db FALSE ; Cambiar por `TRUE` para correr los tests.

; Marca el ejercicio 1C como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - modificarUnidad
global EJERCICIO_2C_HECHO
EJERCICIO_2C_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

;########### ESTOS SON LOS OFFSETS Y TAMAÑO DE LOS STRUCTS
; Completar las definiciones (serán revisadas por ABI enforcer):
ATTACKUNIT_CLASE EQU 0
ATTACKUNIT_COMBUSTIBLE EQU 12
ATTACKUNIT_REFERENCES EQU 14
ATTACKUNIT_SIZE EQU 16

global optimizar
optimizar:
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits o 8 bits.
	;
	; rdi/m64 = mapa_t           mapa
	; rsi/m64 = attackunit_t*    compartida
	; rdx/m64 = uint32_t*        fun_hash(attackunit_t*)

	push rbp
	mov rbp, rsp

	sub rsp, 8  ; aux extra
	push r15
	push r14
	push r13
	push r12
	push rbx 

	mov r15, rdi; R15 = mapa
	mov r14, rsi; R14 = compartida
	mov r13, rdx; R13 = fun_hash

	xor rbx, rbx

	.while:
	cmp rbx, 255*255
	je .end

	mov r12, [r15 + rbx * 8]; R12 = unidad actual
	cmp r12, 0
	jz .continue

	; fun_hash(unidad)
	mov rdi, r12
	call r13

	mov dword [rbp-8] , eax

	; fun_hash(compartida)
	mov rdi, r14
	call r13

	cmp eax, dword [rbp-8]
	jne .continue

	inc byte [r14 + ATTACKUNIT_REFERENCES]; compartida
	dec byte [r12 + ATTACKUNIT_REFERENCES]; unidad

	mov [r15 + rbx * 8] , r14

	.continue:
	inc rbx
	jmp .while

	.end:
	pop rbx
	pop r12
	pop r13
	pop r14
	pop r15
	add rsp, 8

	pop rbp
	ret

global contarCombustibleAsignado
contarCombustibleAsignado:
	; rdi/m64 = mapa_t           mapa
	; rsi/m64 = uint16_t*        fun_combustible(char*)

	push rbp
	mov rbp, rsp

	push r12
	push r13
	push r14
	push r15
	push rbx
	push rbx

	mov r12, rdi; R12 = mapa
	mov r13, rsi; R13 = fun_combustible

	xor rbx, rbx; RBX = i 
	xor r14, r14; R14 = combustible_disponible
	xor r15, r15; R15 = combustible_asignado


	.while:
	cmp rbx, 255*255
	je .end

	mov r10, [r12 + rbx * 8] ; R1O = unidad_actual
	cmp r10, 0
	je .continue

	;combustible_disponible++
	add r14w, word [r10 + ATTACKUNIT_COMBUSTIBLE]
	
	lea r9,  [r10 + ATTACKUNIT_CLASE]

	mov rdi, r9
	call r13

	;combustible_asignado++
	add r15w, ax

	.continue:
	inc rbx
	jmp .while
	
	.end:


	mov ax, r14w
	sub ax, r15w
	movzx rax, ax

	; RAX = combustible_disponible - combustible_asignado
	pop rbx
	pop rbx
	pop r15
	pop r14
	pop r13
	pop r12


	pop rbp
	ret

global modificarUnidad
modificarUnidad:
	; rdi/m64 = mapa_t           mapa
	; rsi/m8  = uint8_t          x
	; rdx/m8  = uint8_t          y
	; rcx/m64 = void*            fun_modificar(attackunit_t*)

	push rbp
	mov rbp, rsp

	push r15; R15 = mapa
	push r14; R14 = fun_modificar
	push r13; R13 = unidad
	push r12; R12 = unidad_offset
	push rbx
	push rbx

	mov r15, rdi
	mov r14, rcx

	; R12 = [base + (x*COLS + y) * size] 

	movzx rsi, sil ; x
	movzx rdx, dil ; y

	; R12 = unidad_offset 
	imul rsi, 255
	add  rdx, rsi
	mov r12, rdx
	mov r13, [r15 + r12 * 8]

	;R13 = unidad
	cmp r13, 0
	je .end

    ; es unidad compartida
	cmp byte [r13 + ATTACKUNIT_REFERENCES], 0 
	jne .else

	mov rdi, ATTACKUNIT_SIZE
	call malloc
	; RBX = nueva_unidad
	mov rbx, rax

	; R13 = unidad
	; RBX = nueva_unidad
	lea rdi, [rbx + ATTACKUNIT_CLASE]
	lea rsi, [r13 + ATTACKUNIT_CLASE]
	call strcpy

	mov byte [rbx + ATTACKUNIT_REFERENCES ], 1
	mov r9w,  word [r13 + ATTACKUNIT_COMBUSTIBLE]
	mov word [rbx + ATTACKUNIT_COMBUSTIBLE], r9w
	dec byte [r13 + ATTACKUNIT_REFERENCES]

	;fun_modificar(nueva_unidad)
	mov rdi, rbx
	call r14

	;mapa[x][y] = nueva_unidad
	mov [r15 + r12 * 8], rbx

	jmp .end
	.else:
	; fun_modificar(unidad)
	mov rdi, r13
	call r14

	.end:

	pop rbx
	pop rbx
	pop r12
	pop r13
	pop r14
	pop r15

	pop rbp
	ret
