extern strcmp
global invocar_habilidad

; Completar las definiciones o borrarlas (en este ejercicio NO serán revisadas por el ABI enforcer)
DIRENTRY_NAME_OFFSET EQU 0
DIRENTRY_PTR_OFFSET EQU 16
DIRENTRY_SIZE EQU 24

FANTASTRUCO_DIR_OFFSET EQU 0
FANTASTRUCO_ENTRIES_OFFSET EQU 8
FANTASTRUCO_ARCHETYPE_OFFSET EQU 16
FANTASTRUCO_FACEUP_OFFSET EQU 24
FANTASTRUCO_SIZE EQU 28

section .rodata
; Acá se pueden poner todas las máscaras y datos que necesiten para el ejercicio

section .text

; void invocar_habilidad(void* carta, char* habilidad);
invocar_habilidad:
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits o 8 bits.
	;
	; rdi/m64 = void*    card ; Vale asumir que card siempre es al menos un card_t*
	; rsi/m64 = char*    habilidad

	push rbp
	mov rbp, rsp

	push r15
	push r14
	push r13
	push r12
	push rbx
	push rbx

	mov r15, rdi; R15 = carta
	mov r14, rsi; R14 = habilidad

	.while:
	cmp r15, 0
	je .end

	; reinicia i en cada iteracion de while
	xor rbx, rbx ;RBX = i
	.for:

	movzx r8, word [r15 + FANTASTRUCO_ENTRIES_OFFSET]
	cmp rbx, r8
	je .continue

	mov r13, [r15 + FANTASTRUCO_DIR_OFFSET]
	mov r13, [r13 + r8 * 8] ; R13 = carta->__dir[i]
	
	; strcmp(carta->__dir[i]->ability_name, habilidad)
	lea rdi, [r13 + DIRENTRY_NAME_OFFSET]
	mov rsi, r14
	call strcmp

	; cmp rax, 0
	; je .forcontinue

	; ; carta->__dir[i]->ability_ptr(carta)
	; mov rdi, r15
	; call [r13 + DIRENTRY_PTR_OFFSET]


	.forcontinue:
	inc rbx
	jmp .for


	.continue:
	mov r15, [r15 + FANTASTRUCO_ARCHETYPE_OFFSET]
	jmp .while
	.end:

	pop rbx
	pop rbx
	pop r12
	pop r13
	pop r14
	pop r15

	pop rbp
	ret ;No te olvides el ret!
