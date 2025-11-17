extern sumar_c
extern restar_c
;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

;########### LISTA DE FUNCIONES EXPORTADAS

global alternate_sum_4
global alternate_sum_4_using_c
global alternate_sum_4_using_c_alternative
global alternate_sum_8
global product_2_f
global product_9_f

;########### DEFINICION DE FUNCIONES
; uint32_t alternate_sum_4(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);
; parametros: 
; x1 --> EDI
; x2 --> ESI
; x3 --> EDX
; x4 --> ECX
alternate_sum_4:

  sub EDI, ESI
  add EDI, EDX
  sub EDI, ECX

	mov eax, edi
  ret

; uint32_t alternate_sum_4_using_c(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);
; parametros: 
; x1 --> EDI
; x2 --> ESI
; x3 --> EDX
; x4 --> ECX
alternate_sum_4_using_c:
  ;prologo
  push RBP ;pila alineada
  mov RBP, RSP ;strack frame armado
  push R12
  push R13	; preservo no volatiles, al ser 2 la pila queda alineada

  mov R12D, EDX ; guardo los parámetros x3 y x4 ya que están en registros volátiles
  mov R13D, ECX ; y tienen que sobrevivir al llamado a función

  call restar_c 
  ;recibe los parámetros por EDI y ESI, de acuerdo a la convención, y resulta que ya tenemos los valores en esos registros
  
  mov EDI, EAX ;tomamos el resultado del llamado anterior y lo pasamos como primer parámetro
  mov ESI, R12D
  call sumar_c

  mov EDI, EAX
  mov ESI, R13D
  call restar_c

  ;el resultado final ya está en EAX, así que no hay que hacer más nada

  ;epilogo
  pop R13 ;restauramos los registros no volátiles
  pop R12
  pop RBP ;pila desalineada, RBP restaurado, RSP apuntando a la dirección de retorno
  ret


alternate_sum_4_using_c_alternative:
  ;prologo
  push RBP ;pila alineada
  mov RBP, RSP ;strack frame armado
  sub RSP, 16 ; muevo el tope de la pila 8 bytes para guardar x4, y 8 bytes para que quede alineada

  mov [RBP-8], RCX ; guardo x4 en la pila

  push RDX  ;preservo x3 en la pila, desalineandola
  sub RSP, 8 ;alineo
  call restar_c 
  add RSP, 8 ;restauro tope
  pop RDX ;recupero x3
  
  mov EDI, EAX
  mov ESI, EDX
  call sumar_c

  mov EDI, EAX
  mov ESI, [RBP - 8] ;leo x4 de la pila
  call restar_c

  ;el resultado final ya está en EAX, así que no hay que hacer más nada

  ;epilogo
  add RSP, 16 ;restauro tope de pila
  pop RBP ;pila desalineada, RBP restaurado, RSP apuntando a la dirección de retorno
  ret


; uint32_t alternate_sum_8(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4, uint32_t x5, uint32_t x6, uint32_t x7, uint32_t x8);
; registros y pila: x1[rdi], x2[rsi], x3[rdx], x4[rcx], x5[r8], x6[r9], x7[rbp+16], x8[rbp+24]
alternate_sum_8:
	; x1 - x2 + x3 - x4 + x5 - x6 + x7 - x8
  
  ;prologo
	push rbp
	mov rsp, rbp

	mov eax, edi
	sub eax, esi
	add eax, edx
	sub eax, ecx
	add eax, r8d
	sub eax, r9d
	add eax, dword [rbp+16]
	sub eax, dword [rbp+24]
	
	;epilogo
	pop rbp
	ret


; SUGERENCIA: investigar uso de instrucciones para convertir enteros a floats y viceversa
;void product_2_f(uint32_t * destination, uint32_t x1, float f1);
;registros: destination[rdi], x1[rsi], f1[xmm1]
product_2_f:
	;cvtsi2ss  :  int -> float
	;roundss   :  float -> int (redondea)
	;cvttss2si :  float -> int (trunca)
	cvtsi2ss xmm1, rsi
	mulss xmm0, xmm1
	cvttss2si esi, xmm0 
	mov [rdi] , esi
	
	ret



;extern void product_9_f(double * destination
;, uint32_t x1, float f1, uint32_t x2, float f2, uint32_t x3, float f3, uint32_t x4, float f4
;, uint32_t x5, float f5, uint32_t x6, float f6, uint32_t x7, float f7, uint32_t x8, float f8
;, uint32_t x9, float f9);
;registros y pila: 
; destination[rdi], 
; x1[rsi]   , f1[xmm0], 
; x2[rdx]   , f2[xmm1], 
; x3[rcx]   , f3[xmm2],
; x4[r8]    , f4[xmm3], 
; x5[r9]    , f5[xmm4], 
; x6[rbp+16], f6[xmm5], 
; x7[rbp+24], f7[xmm6], 
; x8[rbp+32], f8[xmm7], 
; x9[rbp+40], f9[rbp+48]
product_9_f:
	
	;prologo
	push rbp
	mov rbp, rsp
   
	;convertimos los flotantes de cada registro xmm en doubles
	cvtss2sd xmm0, xmm0  ; f1 -> double
	cvtss2sd xmm1, xmm1  ; f2 -> double
	cvtss2sd xmm2, xmm2  ; f3 -> double
	cvtss2sd xmm3, xmm3  ; f3 -> double
	cvtss2sd xmm4, xmm4  ; f4 -> double
	cvtss2sd xmm5, xmm5  ; f5 -> double
	cvtss2sd xmm6, xmm6  ; f6 -> double
	cvtss2sd xmm7, xmm7  ; f7 -> double
	movss xmm8, [rbp+48] ; f9 -> xmm8        
	cvtss2sd xmm8, xmm8  ; f8 -> double
	
	;multiplicamos los doubles en xmm0 <- xmm0 * xmm1, xmmo * xmm2 , ...
	
	mulsd xmm0, xmm1
	mulsd xmm0, xmm2
	mulsd xmm0, xmm3
	mulsd xmm0, xmm4
	mulsd xmm0, xmm5
	mulsd xmm0, xmm6 
	mulsd xmm0, xmm7
	mulsd xmm0, xmm8
	; multiplico los enteros uno por uno! 	 
	
	cvtsi2sd xmm10, rsi
	mulsd xmm0, xmm10
	
	cvtsi2sd xmm10, rdx
	mulsd xmm0, xmm10
	
	cvtsi2sd xmm10, rcx
	mulsd xmm0, xmm10
	
	cvtsi2sd xmm10, r8
	mulsd xmm0, xmm10
	
	cvtsi2sd xmm10, r9
	mulsd xmm0, xmm10
	
	cvtsi2sd xmm10, [rbp+16]
	mulsd xmm0, xmm10

	cvtsi2sd xmm10, [rbp+24]
	mulsd xmm0, xmm10

	cvtsi2sd xmm10, [rbp+32]
	mulsd xmm0, xmm10

	cvtsi2sd xmm10, [rbp+40]
	mulsd xmm0, xmm10
   
	movsd [rdi], xmm0
	
	; epilogo
	pop rbp
	ret

