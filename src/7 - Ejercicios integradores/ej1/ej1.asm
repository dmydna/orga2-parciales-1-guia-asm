extern malloc

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
;   - es_indice_ordenado
global EJERCICIO_1A_HECHO
EJERCICIO_1A_HECHO: db FALSE ; Cambiar por `TRUE` para correr los tests.

; Marca el ejercicio 1B como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - indice_a_inventario
global EJERCICIO_1B_HECHO
EJERCICIO_1B_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

;########### ESTOS SON LOS OFFSETS Y TAMAÑO DE LOS STRUCTS
; Completar las definiciones (serán revisadas por ABI enforcer):
ITEM_NOMBRE EQU 0
ITEM_FUERZA EQU 20
ITEM_DURABILIDAD EQU 24
ITEM_SIZE EQU 28

;; La funcion debe verificar si una vista del inventario está correctamente 
;; ordenada de acuerdo a un criterio (comparador)

;; bool es_indice_ordenado(item_t** inventario, uint16_t* indice, uint16_t tamanio, comparador_t comparador);

;; Dónde:
;; - `inventario`: Un array de punteros a ítems que representa el inventario a
;;   procesar.
;; - `indice`: El arreglo de índices en el inventario que representa la vista.
;; - `tamanio`: El tamaño del inventario (y de la vista).
;; - `comparador`: La función de comparación que a utilizar para verificar el
;;   orden.
;; 
;; Tenga en consideración:
;; - `tamanio` es un valor de 16 bits. La parte alta del registro en dónde viene
;;   como parámetro podría tener basura.
;; - `comparador` es una dirección de memoria a la que se debe saltar (vía `jmp` o
;;   `call`) para comenzar la ejecución de la subrutina en cuestión.
;; - Los tamaños de los arrays `inventario` e `indice` son ambos `tamanio`.
;; - `false` es el valor `0` y `true` es todo valor distinto de `0`.
;; - Importa que los ítems estén ordenados según el comparador. No hay necesidad
;;   de verificar que el orden sea estable.

global es_indice_ordenado
es_indice_ordenado:
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits o 8 bits.
	;
	; rdi/m64 = item_t**     inventario
	; rsi/m64 = uint16_t*    indice
	; rdx/m16 = uint16_t     tamanio
	; rcx/m64 = comparador_t comparador

		push rbp
		mov rbp, rsp

		push r12
		push r13
		push r14
		push r15

		push rbx
		push rbx
	
		mov r12, rdi ; R12 = inventario
		mov r13, rsi ; R13 = indice
		mov r14, rdx ; R14 = tamanio
		mov r15, rcx ; R15 = comparador

		mov rbx, 1   ; i

		.for: 
		cmp bx, r14w
		je .end

		mov rcx, [r13 + rbx * 2 - 2]; indice[i-1]
		mov rdx, [r13 + rbx * 2]; indice[i]


		movzx rdx, dx
		movzx rcx, cx
	
		mov rdi, [r12 + rcx * 8] ;  inventario[indice]
		mov rsi, [r12 + rdx * 8] ;  inventario[indice-1]

		call r15 

		cmp rax, 0
		je .end

		.continue:

		inc rbx
		jmp .for

		.end:

		pop rbx
		pop rbx

		pop r15
		pop r14
		pop r13
		pop r12

		pop rbp
		ret

;; Dado un inventario y una vista, crear un nuevo inventario que mantenga el
;; orden descrito por la misma.

;; La memoria a solicitar para el nuevo inventario debe poder ser liberada
;; utilizando `free(ptr)`.

;; item_t** indice_a_inventario(item_t** inventario, uint16_t* indice, uint16_t tamanio);

;; Donde:
;; - `inventario` un array de punteros a ítems que representa el inventario a
;;   procesar.
;; - `indice` es el arreglo de índices en el inventario que representa la vista
;;   que vamos a usar para reorganizar el inventario.
;; - `tamanio` es el tamaño del inventario.
;; 
;; Tenga en consideración:
;; - Tanto los elementos de `inventario` como los del resultado son punteros a
;;   `ítems`. Se pide *copiar* estos punteros, **no se deben crear ni clonar
;;   ítems**

global indice_a_inventario
indice_a_inventario:
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits o 8 bits.
	;
	; rdi/m64 = item_t**  inventario
	; rsi/m64 = uint16_t* indice
	; rdx/m16 = uint16_t  tamanio

	push rbp
	mov rbp, rsp

	push r15
	push r14
	push r13
	push rbx


	mov r15, rdi ; R15 = item_t**  inventario
	mov r14, rsi ; R14 = uint16_t* indice
	mov r13, rdx ; R13 = uint16_t  tamanio

	movzx rdx, dx
	shl rdx, 3

	mov rdi, rdx
	call malloc ; RAX = item_t** resultado
	
	xor rbx, rbx ; RBX = int i
	.for:
	cmp rbx, r13
	je .end

	movzx rdi , word [r14 + rbx * 2]; indice[i]
	mov rsi , [r15 + rdi * 8]; inventario[indice]
	mov [rax + rbx * 8 ], rsi ; resultado[i] = *item

	.continue:
	inc rbx
	jmp .for
	.end:

	pop rbx
	pop r13
	pop r14
	pop r15

	pop rbp
	ret
