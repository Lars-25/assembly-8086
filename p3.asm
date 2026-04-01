include p3macros.asm
.model medium
.stack 100h


.data
;       0   1   2   3   4   5   6   7
ln1 db  00 ,12 ,12 ,12 ,'@'
ln2 db  12 ,12 ,11 ,11 ,'@'
ln3 db  12 ,12 ,12 ,12 ,'@'
ln4 db  12 ,12 ,12 ,12 ,'@'
ln5 db  00 ,12 ,00 ,12 ,'@', 'x',' '

;       0   1   2   3   4   5   6   7
;ln1 db  15 ,15 ,14 ,14 ,14 ,14 ,15 ,15 ,'@' ;@ o 40h es fin de linea
;ln2 db  15 ,14 ,14 ,14 ,14 ,14 ,14 ,15 ,'@'
;ln3 db  14 ,14 ,12 ,14 ,14 ,12 ,14 ,14 ,'@'
;ln4 db  14 ,14 ,14 ,14 ,14 ,14 ,14 ,14 ,'@'
;ln5 db  14 ,14 ,14 ,14 ,14 ,14 ,14 ,14 ,'@'
;ln6 db  14 ,14 ,11 ,14 ,14 ,11 ,14 ,14 ,'@'
;ln7 db  15 ,14 ,14 ,11 ,11 ,14 ,14 ,15 ,'@'
;ln8 db  15 ,15 ,14 ,14 ,14 ,14 ,15 ,15 ,'x',' '

;Punto de referencia donde se pintara el 1er pixel.
;Este ira cambiando a la hora de moverse por la pantalla
crd dw  0001h, 'y ', 0001h, 'i '    
its dw  0000h, 'j ', 0000h, 'x '    ;i y j del ciclo for

;Sirve para indicar las coordendas de 1 pixel, este cambia al ir dibujando la figura.
pxl dw  0000h, 'y ', 0000h, 'c '    

;Variable para guardar el color del pixel, este ira cambiando cuando se dibuje un pixel y siga el siguiente
clr db  0ch     

;Variable que funge como indicador del arreglo de colores que es ln
tx1 dw 'id','x '
idx dw  0000h

; Variables de direccion del sprite.
tx2 dw 'x '
drx db 01h      ; Variable del eje x
tx3 dw 'y '
dry db 01h      ; Variable del eje y


w       equ 4           ;WIDTH
h       equ 5           ;HEIGHT
px      equ 1           ;PIXEL SIZE (TAMAÑO DE CADA CUADRADITO)
scw     equ 6           ;SCREEN WIDTH
sch     equ 7           ;SCREEN HEIGHT
mw      equ scw-w*px    ;LIMITE DE X
mh      equ sch-h*px    ;LIMITE DE Y
frzcx   equ 00003h
frzdx   equ 0d090h

.code

mov ax, 0A000h
mov es, ax
                          
mov ax, @data
mov ds, ax
               
call sprite
           
.exit

proc sprite
    ; Piensa que todo esto es un ciclo infinito con
    ; un ciclo for i con un ciclo for j dentro.
    start:
    ;call waitSc              
    ; Sirve para iniciar y reiniciar.
    mov si, 0                   ; Empezar de 0           
    mov di, 0
    mov its[0], si              ; Contador i=0
    mov its[4], di              ; Contador j=0
    mov pxl[0], si              ; x=0 
    mov pxl[4], di              ; y=0
    mov idx, si                 ; index=0
    mov ax, 0013h       
    int 10h                     ; Modo de video de graficos. Reinicia la pantalla
    mov ax, 0100h
    int 16h                     ; Interrumpcion que lee si hay una tecla en el buffer. No elimina
    cmp al, 00h                 ; Checa si se presiono una tecla
    jne key                     
    jmp lp                      ; PINTADO
       
    lp:
    cmp si, w                   ; Si i = 8
    je nxtLn            
        
    mov cx, px                  ; Enviar multiplicador, este sirve para el colocamiento de los subsequentes pixels
    mov ax, its[0]              ; Obtener valor de i
    mov bx, its[4]              ; Obtener valor de j
    
    ; PROCESO:
    ; i * 8 + x 
    mul cx                  
    add ax, crd[0]
    mov pxl[0], ax
    
    ; j * 8 + y 
    mov ax, bx
    mul cx
    add ax, crd[4]
    mov pxl[4], ax       
    
    mov si, idx                 ; Obtener el valor del indicador
       
    mov cl, ln1[si]             ; Obtener el color del pixel del arreglo
    mov clr, cl                 
    
    drawN clr, pxl[0], pxl[4], px  
    
    mov si, idx                 
    inc si                      ; Incerementar el indicador para el siguiente pixel
    mov idx, si                 ; Guardar el valor
    mov si, its[0]              
    inc si                      ; Incrementar a i, i++
    mov its[0], si
    jmp lp
    
    
    nxtLn:
    mov si, idx                 ; Obtiene el valor del indicador
    inc si                      ; Le suma 1 al indicador para saltarse el @
    mov idx, si                 ; Guarda el valor en el indicador.
    mov si, 0h
    mov its[0], si              ; Reinicia a i, i=0
    mov di, its[4]              ; Obtiene el valor de j
    inc di                      ; Siguiente renglon, j++
    mov its[4], di              ; Guarda el valor de j.
    cmp di, h
    je restart                  ; Si j=h reiniciar.
    jmp lp
    
    restart:
    call dvd
    jmp start
    
    key:
    cmp al, 'w'
    je goU
    
    cmp al, 's'
    je goD
    
    cmp al, 'a'
    je goL
    
    cmp al, 'd'
    je goR
    
    cmp al, 'e'
    je leave
    
    jmp lp
    
    
    goU:
    call mov1up
    call ClearBuffKB
    jmp lp
    
    
    goD:
    call mov1dn
    call ClearBuffKB
    jmp lp
    
    goL:
    call mov1lf
    call ClearBuffKB
    jmp lp
    
    goR:
    call mov1rt
    call ClearBuffKB
    jmp lp      
    
    leave:
    mov si, 0h
    mov di, 0h
    mov its[0], si
    mov its[4], di   
    ret    
sprite endp

proc dvd
    getX: 
    mov ax, crd[0]          ;X
    jmp chkX
    
    getY:
    mov ax, crd[4]          ;Y
    jmp chkY
    
    chkX:
    ;Revisar que x no sobrepase el borde izquierdo      
    cmp ax, 0
    jle goToLeft
    
    ;Revisar que x no sobrepase el borde derecho
    ;Proceso: w * px + x
    mov ax, w
    mov cx, px
    mul cx
    add ax, crd[0]
    
    cmp ax, mw
    jae goToRight
    jmp getY
    
    chkY:
    ;Revisar que y no sobrepase el borde superior
    cmp ax, 0
    jle goToDown
    
    
    ;Revisar que y no sobrepase el borde inferior
    ;Proceso: h * px + y
    mov ax, h
    mov cx, px
    mul cx
    add ax, crd[4]
    cmp ax, mh
    jae goToUp                                    
    jmp chgXCrds
    
    goToUp:
    mov dry, 00h
    jmp getY
    
    goToDown:
    mov dry, 01h
    jmp getY
    
    goToLeft:
    mov drx, 00h
    jmp chgXCrds
    
    goToRight:
    mov drx, 01h
    jmp chgXCrds
    
    chgXCrds:
    mov al, drx
    cmp al, 01h
    jmp DOWN 
    
    jmp UP
    
    UP:
    call mov1up
    jmp chgYCrds
    
    DOWN:
    call mov1dn
 
    
    chgYCrds:
    mov al, dry
    cmp al, 01h
    jmp RIGHT
    
    jmp LEFT
    
    LEFT:
    call mov1lf
    jmp rtSprite
    
    RIGHT:
    call mov1rt
    
    
    rtSprite:
    ret
endp dvd

proc mov1up
    mov ax, crd[4]       
    sub ax, px
    mov crd[4], ax              ; Offset de 8px hacia arriba
    ret
endp mov1up

proc mov1dn
    mov ax, crd[4]
    add ax, px
    mov crd[4], ax              ; Offset de 8px hacia abajo
    ret
endp mov1dn

proc mov1lf
    mov ax, crd[0]
    sub ax, px
    mov crd[0], ax              ; Offset de 8px hacia la izquierda
    ret
endp mov1lf

proc mov1rt
    mov ax, crd[0]
    add ax, px
    mov crd[0], ax              ; Offset de 8px hacia la derecha
    ret
endp mov1rt


proc ClearBuffKB
      push ax                   ; Guarda el valor de AX en la pila.
@@CheckBuffer:
      mov ah ,1     
      int 16h                   ; Verificar si hay una tecla en el buffer pero no la elimina
      jz @@return               ; Si no hay nada en el bufer regresa
      mov ah ,0     
      int 16h                   ; Verifica si hay una tecla en el buffer y la elimina
      jmp @@CheckBuffer
@@return:
      pop ax
      ret
endp ClearBuffKB

proc waitSc
    ; Interrupcion de espera
    ; CX:DX = intervalo en microsegundos. 1 sec = 1,000,000 microsec
    mov ax, 8600h
    mov cx, frzcx               
    mov dx, frzdx
    int 15h       
    ret
endp waitSc