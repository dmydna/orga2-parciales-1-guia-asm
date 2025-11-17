extern malloc
extern free
extern fprintf

section .data

section .text

global strCmp
global strClone
global strDelete
global strPrint
global strLen

; ** String **

; int32_t strCmp(char* a, char* b)
strCmp:
	;prologo
	push rbp
	mov rbp,rsp ;
	xor rax, rax
	.while:
		;carga el char (byte) en la parte de rdi y rsi
		mov dl, [rdi] ;*a
		mov cl, [rsi] ;*b
		cmp dl, cl
		jne .noSonIguales
		cmp dl, cl
		; sonIguales y son "/0"
		test dl, dl
		jz .sonIguales
		;si termina antes que la otra
		test dl, dl ; a
		jz .esMenor   ; (a == 0?) -> (a < b)
		test cl, cl ; b
		jz .esMayor ;   (b == 0?) -> (a > b)
		inc rdi; *a++
		inc rsi; *b++
		jmp .while

	.sonIguales: ; a == b
	xor rax, rax
	jmp .end
	.esMenor: ;(a < b) -> 1
	mov rax, 1
	jmp .end
	.esMayor: ;(a < b) -> -1
	mov rax, -1
	jmp .end
	.noSonIguales:
	cmp dl, cl
	jb .esMenor ; a < b
	jmp .esMayor; a > b
	.end:
   	;epilogo
	pop rbp
	ret

; char* strClone(char* a)
strClone:
;rsi -> *a
	push rbp ; alineada
	mov rbp, rsp ;
	sub rsp, 8
	push rdi  ;alineada	

	call strLen
	;malloc(len * sizeof(char) + 1)
	inc rax       ;
	mov rdi,rax  ;

	call malloc
	mov rsi, rax
	pop rdi; 
	add rsp, 8

	;dl char actual
	;rsi fin de string nuevo
	;rax inicio de string nuevo
	;rdi incio string original
	.while:
	mov  dl, [rdi] ;
	test dl, dl
	jz .end
	mov [rsi], dl
	inc rsi
	inc rdi
	jmp .while

	.end:
	mov byte [rsi], 0
	mov rsp, rbp
	pop rbp
	ret


; void strDelete(char* a)
strDelete:
	push rbp
	mov rbp, rsp

	call free
	;pila alineada
	
	pop rbp
	ret

; void strPrint(char* a, FILE* pFile)
strPrint:
	;a[rdi], pFile[rsi]
	push rbp
	mov rbp,rsp
	push rdi ; padding
	push rsi ; pila alideada

	.if: ;a es null
		test rsi, rsi
		jz .else
		mov rdx, rsi; string = a
		jmp .print	
	.else: ;a no es null
		lea rdx, [str_null]; string = "NULL"	
	.print:
		mov rdi, rsi
		lea rsi, [formato]
		call fprintf	
	
	pop rsi
	pop rdi
	pop rbp
	ret

; uint32_t strLen(char* a)
strLen:
	push rbp ;alineada
	mov rbp,rsp ;
	
	xor rax, rax ; contador
	.while:
		mov  dl, [rdi]
		test dl, dl
		jz  .end
		inc rax
		inc rdi
		jmp .while
	.end:
	pop rbp
	ret


