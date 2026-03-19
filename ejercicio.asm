.model medium
.stack 100h
.data                                           
divisor1 db '================'
datosPacientes db 114 dup('$')
divisor2 db '================'
txtIni db 'BIENVENIDO A AGENDA MEDICA$'
txtIniOpt db '1. Consultar 2. Agregar/Editar 3. Eliminar 0. Salir$'
txtCon db 'CONSULTAS$'
txtAdd db 'EDICIONES$'
txtDel db 'REMOCIONES$'
txtInp db 'Elija una opcion: $'
br db 0dh, 0ah, '$'                 ; 0dh o 13 es para regresar al inicio de la linea y 0ah o 10 es para nueva linea.

; ====================================== TEXTOS PARA CAPTURA ======================================
txtPedirNombre db 0dh, 0ah, 'Nombre: $'
txtPedirEdad   db 0dh, 0ah, 'Edad: $'
txtPedirPeso   db 0dh, 0ah, 'Peso (kg): $'
txtPedirAltura db 0dh, 0ah, 'Altura (cm): $'
txtPedirID db 0dh, 0ah, 'ID del paciente (1, 2 o 3 & 0. Salir): $'
txtEliminado db 0dh, 0ah, 'Se elimino con exito $'
txtIMC db 0dh, 0ah, 'IMC: $'
txtErrorIMC db ' N/A (Faltan datos)$'
pesoAux dw 0

; ====================================== MEMORIA DE PACIENTES ======================================
; Matriz plana de 114 bytes inicializada con el caracter '$' para evitar basura en memoria.
; Paciente 1: offset 0   (0 al 37)
; Paciente 2: offset 38  (38 al 75)
; Paciente 3: offset 76  (76 al 113)



.code

; MENU: Usar comparaciones y saltos.
; 1. Consultar 2. Agregar/Editar 3. Eliminar 0. Salir
 
; PACIENTES: 
; Por paciente: Nombre, Edad, Peso y Alturo. 

; CONCEPTOS DEL CODIGO:
; CALL: 
; LA FUNCION CALL HACE UN SALTO A UNA INSTRUCCION Y SI HAY UN RET RETORNA A LA LINEA DE DONDE HABIA HECHO EL SALTO

; JE:
; JUMP if EQUAL: Realiza un salto corto si el resultado de la comparacion ambos operandos son iguales

mov AX, @data
mov DS, AX

; ============================================= MENU DE INICIO ================================================
inicio:
    call clScr
    ; MENSAJE DE BIENVENIDA
    mov DX, offset txtIni
    call print

    call lnBr

    mov DX, offset txtIniOpt
    call print

    ; MENSAJE DE INPUT
    call lnBr

    mov DX, offset txtInp
    call print

    ; PEDIR INPUT
    call input

    cmp BL, '0'
    je exit

    cmp BL, '1'
    je consultar

    cmp BL, '2'
    je editar

    cmp BL, '3'
    je eliminar
                        
    jmp inicio


; ====================================== CONSULTA ======================================
consultar:
    call clScr
    
    mov DX, offset txtCon
    call print

    call lnBr

    mov DX, offset txtPedirID
    call print

    call input
    
    mov AL, BL
       
    cmp AL, '0'
    je inicio
    
    mov BX, 0
    cmp AL, '1'
    je verDatos
    
    mov BX, 38
    cmp AL, '2'
    je verDatos
    
    mov BX, 76
    cmp AL, '3'
    je verDatos
 
    jmp consultar


; ======================================= EDITAR =======================================
editar:
    call clScr
    mov DX, offset txtAdd
    call print
    
    mov DX, offset txtPedirID
    call print

    call input
    
    mov AL, BL
       
    cmp AL, '0'
    je inicio
    
    mov BX, 0
    cmp AL, '1'
    je editarDatos
    
    mov BX, 38
    cmp AL, '2'
    je editarDatos
    
    mov BX, 76
    cmp AL, '3'
    je editarDatos
    
    jmp editar

; ====================================== ELIMINAR =====================================
eliminar:
    call clScr
    mov DX, offset txtDel
    call print
    
    mov DX, offset txtPedirID
    call print

    call input
    
    mov AL, BL
       
    cmp AL, '0'
    je inicio
    
    mov BX, 0
    cmp AL, '1'
    je eliminarDatos
    
    mov BX, 38
    cmp AL, '2'
    je eliminarDatos
    
    mov BX, 76
    cmp AL, '3'
    je eliminarDatos
    
    jmp eliminar


.exit


verDatos proc
    mov DX, offset txtPedirNombre
    call print
    lea DX, datosPacientes[BX]
    call print
    
    mov DX, offset txtPedirEdad
    call print
    lea DX, datosPacientes[BX+26]
    call print
    
    mov DX, offset txtPedirPeso
    call print
    lea DX,  datosPacientes[BX+30]
    call print
    
    mov DX, offset txtPedirAltura
    call print
    lea DX, datosPacientes[BX+34]
    call print
    
    call lnBr
    call input
    
    jmp consultar
    
    ret
verDatos endp


editarDatos proc
    mov DX, offset txtPedirNombre
    call print
    
    mov CX, 25
    mov SI, BX
    
    escNom:
        mov AH, 01h
        int 21h
        cmp AL, 0Dh
        je iniEdad
        mov datosPacientes[SI], AL
        inc SI
        loop escNom
    
    iniEdad:
        mov DX, offset txtPedirEdad
        call print
        
        mov CX, 3
        mov SI, BX
        add SI, 26
        
    escEdad:
        mov AH, 01h
        int 21h
        cmp AL, 0Dh
        je iniPeso
        mov datosPacientes[SI], AL
        inc SI
        loop escEdad
    
    iniPeso:
        mov DX, offset txtPedirPeso
        call print
        
        mov CX, 3
        mov SI, BX
        add SI, 30
        
    escPeso:
        mov AH, 01h
        int 21h
        cmp AL, 0Dh
        je iniAlt
        mov datosPacientes[SI], AL
        inc SI
        loop escPeso       
        
    iniAlt:
        mov DX, offset txtPedirAltura
        call print
        
        mov CX, 3
        mov SI, BX
        add SI, 34
        
     escAlt:
        mov AH, 01h
        int 21h
        cmp AL, 0Dh
        je editar
        mov datosPacientes[SI], AL
        inc SI
        loop escAlt
                   
    jmp editar
    
    ret    
editarDatos endp


eliminarDatos proc
    mov CX, 38
    mov SI, BX
    
    borrar:
    mov datosPacientes[SI], '$'
    inc SI
    loop borrar
    
    mov DX, offset txtEliminado
    call print
    
    call lnBr
    call input   
       
    jmp eliminar
    
    ret           
eliminarDatos endp   
    

lnBr proc
    mov DX, offset br
    mov AH, 09
    int 21h

    mov DX, offset br
    mov AH, 09
    int 21h
    ret
lnBr endp

clScr proc
    mov AX, 0600h           ; AH, AL = Interrupcion para scroll up de la pantalla, cantidad de lineas a scrollear, en este caso 0 es para limpiar.
    mov BH, 07h             ; Este atributo sirve para especificar el color de la fuente.
    mov CX, 0000h           ; CH, CL = fila, columna de la esquina superior izquierda de la ventana.
    mov DX, 184fh           ; DH, DL = fila, columna de la esquina inferior derecha de la ventana.
    int 10h

    mov AH, 02h             ; Interrupcion para reposicionar el cursor
    mov BH, 00h             ; Numero de pagina
    mov DX, 0000h           ; DH, DL: fila y columna
    int 10h

    ret
clScr endp

input proc
    mov AH, 1               
    int 21h
    mov BL, AL
    ret
input endp

print proc                  ; Antes de ser llamada, se manda el offset de la cadena a imprimir para simplificar la funcion.
    mov AH, 09
    int 21h
    ret
print endp

exit proc
.exit
exit endp

end