extern malloc
extern sleep
extern wakeup
extern create_dir_entry

section .rodata
; Acá se pueden poner todas las máscaras y datos que necesiten para el ejercicio
sleep_name: DB "sleep", 0
wakeup_name: DB "wakeup", 0

section .text
; Marca un ejercicio como aún no completado (esto hace que no corran sus tests)
FALSE EQU 0
; Marca un ejercicio como hecho
TRUE  EQU 1

; Marca el ejercicio 1A como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - init_fantastruco_dir
global EJERCICIO_1A_HECHO
EJERCICIO_1A_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Marca el ejercicio 1B como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - summon_fantastruco
global EJERCICIO_1B_HECHO
EJERCICIO_1B_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

;########### ESTOS SON LOS OFFSETS Y TAMAÑO DE LOS STRUCTS
; Completar las definiciones (serán revisadas por ABI enforcer):
DIRENTRY_NAME_OFFSET EQU 0
DIRENTRY_PTR_OFFSET EQU 16
DIRENTRY_SIZE EQU 24

FANTASTRUCO_DIR_OFFSET EQU 0
FANTASTRUCO_ENTRIES_OFFSET EQU 8
FANTASTRUCO_ARCHETYPE_OFFSET EQU 16
FANTASTRUCO_FACEUP_OFFSET EQU 24
FANTASTRUCO_SIZE EQU 28


; void init_fantastruco_dir(fantastruco_t* card);
global init_fantastruco_dir
init_fantastruco_dir:
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits o 8 bits.
	;
	; rdi/m64 = fantastruco_t*     card
	push rbp
	mov rbp, rsp

	push r15
	push r14
	push r13
	push r12

	mov r15, rdi


	; habilidad_sleep
	mov rdi, sleep_name
	mov rsi, sleep 
	call create_dir_entry
	mov r12, rax

	;habilidad_wakeup
	mov rdi, wakeup_name
	mov rsi, wakeup
	call create_dir_entry
	mov r13, rax


	; RAX = __dir
	mov rdi, 8*2
	call malloc

	
	mov [rax], r12;__dir[0]
	mov [rax + 8], r13;__dir[1]

	; card->__dir
	mov [r15 + FANTASTRUCO_DIR_OFFSET], rax
	; card -> __dir_entries
	mov word [r15 + FANTASTRUCO_ENTRIES_OFFSET], 2


	pop r12
	pop r13
	pop r14
	pop r15


	pop rbp
	ret ;No te olvides el ret!

; fantastruco_t* summon_fantastruco();
global summon_fantastruco
summon_fantastruco:
	; Esta función no recibe parámetros

	push rbp
	mov rbp, rsp

	push r15
	push r14

	mov rdi, FANTASTRUCO_SIZE
	call malloc
	mov r15, rax

	mov rdi, r15
	call init_fantastruco_dir

	mov qword [r15 +  FANTASTRUCO_ARCHETYPE_OFFSET], 0
	mov byte [r15 + FANTASTRUCO_FACEUP_OFFSET], 1

	mov rax, r15

	pop r15
	pop r14
	pop rbp
	ret ;No te olvides el ret!
