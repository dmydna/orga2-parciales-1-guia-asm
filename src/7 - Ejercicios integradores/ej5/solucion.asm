; Definiciones comunes
TRUE  EQU 1
FALSE EQU 0

; Identificador del jugador rojo
JUGADOR_ROJO EQU 1
; Identificador del jugador azul
JUGADOR_AZUL EQU 2

; Ancho y alto del tablero de juego
tablero.ANCHO EQU 10
tablero.ALTO  EQU 5

; Marca un OFFSET o SIZE como no completado
; Esto no lo chequea el ABI enforcer, sirve para saber a simple vista qué cosas
; quedaron sin completar :)
NO_COMPLETADO EQU -1

extern strcmp

;########### ESTOS SON LOS OFFSETS Y TAMAÑO DE LOS STRUCTS
; Completar las definiciones (serán revisadas por ABI enforcer):
carta.en_juego EQU 0
carta.nombre   EQU 1
carta.vida     EQU 14
carta.jugador  EQU 16
carta.SIZE     EQU 18

tablero.mano_jugador_rojo EQU 0
tablero.mano_jugador_azul EQU 8
tablero.campo             EQU 16
tablero.SIZE              EQU 72

accion.invocar   EQU 0
accion.destino   EQU 8
accion.siguiente EQU 16
accion.SIZE      EQU 24

; Variables globales de sólo lectura
section .rodata

; Marca el ejercicio 1 como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - hay_accion_que_toque
global EJERCICIO_1_HECHO
EJERCICIO_1_HECHO: db FALSE

; Marca el ejercicio 2 como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - invocar_acciones
global EJERCICIO_2_HECHO
EJERCICIO_2_HECHO: db FALSE

; Marca el ejercicio 3 como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - contar_cartas
global EJERCICIO_3_HECHO
EJERCICIO_3_HECHO: db TRUE

section .text

; Dada una secuencia de acciones determinar si hay alguna cuya carta tenga un
; nombre idéntico (mismos contenidos, no mismo puntero) al pasado por
; parámetro.
;
; El resultado es un valor booleano, la representación de los booleanos de C es
; la siguiente:
;   - El valor `0` es `false`
;   - Cualquier otro valor es `true`
;
; ```c
; bool hay_accion_que_toque(accion_t* accion, char* nombre);
; ```
global hay_accion_que_toque
hay_accion_que_toque:
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits o 8 bits.
	;
	; rdi/m64 = accion_t*  accion
	; rsi/m64 = char*      nombre

	push rbp
	mov rbp, rsp

	push r15
	push r14
	push r13
	push rbx

	mov r15, rdi
	mov r13, rsi


	.while:
	cmp r15, 0
	je .ret_false


	mov r14, [r15 + accion.destino]	; carta
	cmp r14, 0
	je .continue


	mov rdi, r13
	lea rsi, [r14 + carta.nombre]
	call strcmp

	cmp rax, 0
	je .ret_true

	.continue:
	mov r15, [r15 + accion.siguiente]
	jmp .while

	.ret_true:
	mov rax, 1
	jmp .exit

	.ret_false:
	xor rax, rax

	.exit:
	pop rbx
	pop r13
	pop r14
	pop r15

	pop rbp
	ret

; Invoca las acciones que fueron encoladas en la secuencia proporcionada en el
; primer parámetro.
;
; A la hora de procesar una acción esta sólo se invoca si la carta destino
; sigue en juego.
;
; Luego de invocar una acción, si la carta destino tiene cero puntos de vida,
; se debe marcar ésta como fuera de juego.
;
; Las funciones que implementan acciones de juego tienen la siguiente firma:
; ```c
; void mi_accion(tablero_t* tablero, carta_t* carta);
; ```
; - El tablero a utilizar es el pasado como parámetro
; - La carta a utilizar es la carta destino de la acción (`accion->destino`)
;
; Las acciones se deben invocar en el orden natural de la secuencia (primero la
; primera acción, segundo la segunda acción, etc). Las acciones asumen este
; orden de ejecución.
;
; ```c
; void invocar_acciones(accion_t* accion, tablero_t* tablero);
; ```
global invocar_acciones
invocar_acciones:
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits o 8 bits.
	;
	; rdi/m64 = accion_t*  accion
	; rsi/m64 = tablero_t* tablero
	push rbp
	mov rbp, rsp
	
	push r13
	push r14
	push r15
	push rbx

	mov r13, rdi; R13 = accion
	mov r14, rsi; R14 = tablero

	.while:
	cmp r13, 0
	je .end

	mov r15, [r13 + accion.destino]; R15 = carta
	
	cmp byte [r15 + carta.en_juego], 0 ; carta->en_juego
	je .continue

	mov rdi, r14
	mov rsi, r15
	call [r13 + accion.invocar]

	cmp word [r15 + carta.vida], 0
	jne .continue

	mov byte [r15 + carta.en_juego], 0
	.continue:
	mov r13, [r13 + accion.siguiente]
	jmp .while

	.end:
	pop rbx
	pop r15
	pop r14
	pop r13

	pop rbp
	ret

; Cuenta la cantidad de cartas rojas y azules en el tablero.
;
; Dado un tablero revisa el campo de juego y cuenta la cantidad de cartas
; correspondientes al jugador rojo y al jugador azul. Este conteo incluye tanto
; a las cartas en juego cómo a las fuera de juego (siempre que estén visibles
; en el campo).
;
; Se debe considerar el caso de que el campo contenga cartas que no pertenecen
; a ninguno de los dos jugadores.
;
; Las posiciones libres del campo tienen punteros nulos en lugar de apuntar a
; una carta.
;
; El resultado debe ser escrito en las posiciones de memoria proporcionadas
; como parámetro.
;
; ```c
; void contar_cartas(tablero_t* tablero, uint32_t* cant_rojas, uint32_t* cant_azules);
; ```
global contar_cartas
contar_cartas:
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits o 8 bits.
	;
	; rdi/m64 = tablero_t* tablero
	; rsi/m64 = uint32_t*  cant_rojas
	; rdx/m64 = uint32_t*  cant_azules
	push rbp
	mov rbp, rsp
	
	push r12
	push rbx

	mov dword [rsi],0
	mov dword [rdx],0

	xor rbx, rbx ; i = 0

	.for:
	cmp rbx, tablero.ANCHO * tablero.ALTO
	je .end

	lea r10, [rdi + tablero.campo]
	mov r10, [r10 + rbx * 8]; campo[i][j] = carta | null 

	cmp r10, 0
	je .continue

	cmp byte [r10 + carta.jugador], JUGADOR_AZUL
	je .cant_azules

	cmp byte [r10 + carta.jugador], JUGADOR_ROJO
	je .cant_rojas
	
	jmp .continue

	.cant_rojas:
	add dword [rsi], 1
	jmp .continue

	.cant_azules:
	add dword [rdx], 1

	.continue:
	inc rbx
	jmp .for

	.end:

	pop rbx
	pop r12
	
	pop rbp
	ret
