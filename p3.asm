include p3macros.asm
.model medium
.stack 100h


.data
;       0   1   2   3   4   5   6   7
;ln1 db  00 ,12 ,12 ,12 ,'@'
;ln2 db  12 ,12 ,11 ,11 ,'@'
;ln3 db  12 ,12 ,12 ,12 ,'@'
;ln4 db  12 ,12 ,12 ,12 ,'@'
;ln5 db  00 ,12 ,00 ,12 ,'@'

;       0   1   2   3   4   5   6   7
ln1 db  15 ,15 ,14 ,14 ,14 ,14 ,15 ,15 ,'@' ;@ o 40h es fin de linea
ln2 db  15 ,14 ,14 ,14 ,14 ,14 ,14 ,15 ,'@'
ln3 db  14 ,14 ,12 ,14 ,14 ,12 ,14 ,14 ,'@'
ln4 db  14 ,14 ,14 ,14 ,14 ,14 ,14 ,14 ,'@'
ln5 db  14 ,14 ,14 ,14 ,14 ,14 ,14 ,14 ,'@'
ln6 db  14 ,14 ,11 ,14 ,14 ,11 ,14 ,14 ,'@'
ln7 db  15 ,14 ,14 ,11 ,11 ,14 ,14 ,15 ,'@'
ln8 db  15 ,15 ,14 ,14 ,14 ,14 ,15 ,15 ,'x',':'

;Punto de referencia donde se pintara el 1er pixel.
;Este ira cambiando a la hora de moverse por la pantalla
crd dw  0000h, 'y:', 0000h, 'i:'    
its dw  0000h, 'j:', 0000h, 'x:'    ;i y j del ciclo for

;Sirve para indicar las coordendas de 1 pixel, este cambia al ir dibujando la figura.
pxl dw  0000h, 'y:', 0000h, 'c:'    

;Variable para guardar el color del pixel, este ira cambiando cuando se dibuje un pixel y siga el siguiente
clr db  0ch     

;Variable que funge como indicador del arreglo de colores que es ln
idx dw  0000h


w   equ 8 ;WIDTH
h   equ 8 ;HEIGHT
px  equ 1            

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
    ; 8 * i + x 
    mul cx                  
    add ax, crd[0]
    mov pxl[0], ax
    
    ; 8 * j + y 
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
    je start                    ; Si j=h reiniciar.
    jmp lp
    
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
    mov ax, crd[4]       
    sub ax, px
    mov crd[4], ax              ; Offset de 8px hacia arriba
    call ClearBuffKB
    jmp lp
    
    
    goD:
    mov ax, crd[4]
    add ax, px
    mov crd[4], ax              ; Offset de 8px hacia abajo
    call ClearBuffKB
    jmp lp
    
    goL:
    mov ax, crd[0]
    sub ax, px
    mov crd[0], ax              ; Offset de 8px hacia la izquierda
    call ClearBuffKB
    jmp lp
    
    goR:
    mov ax, crd[0]
    add ax, px
    mov crd[0], ax              ; Offset de 8px hacia la derecha
    call ClearBuffKB
    jmp lp      
    
    leave:
    mov si, 0h
    mov di, 0h
    mov its[0], si
    mov its[4], di   
    ret    
sprite endp

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