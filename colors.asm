include p3macros.asm
.model medium
.stack 100h


.data
;       0   1   2   3   4   5   6   7
ln1 db  00 ,01 ,02 ,03 ,04 ,05 ,06 ,07, 08, 09, 10, 11, 12, 13 ,14, 15 ;@ o 40h es fin de linea
crd dw  0000h, 'y:', 0000h, 'i:'
its dw  0000h, 'j:', 0000h, 'x:'
pxl dw  0000h, 'y:', 0000h, 'cl'
clr db  0ch 
idx dw  0000h

w   equ 15
h   equ 7
px  equ 8

.code

mov ax, 0A000h
mov es, ax
                          
mov ax, @data
mov ds, ax
               
mov ax, 0013h
int 10h

call sprite
           
;draw8 11, 10, 12

.exit

proc sprite
    
    lp:
    mov cx, px   
    mov ax, crd[0]
    mov bx, crd[4]
       
    mov si, its[0]
    mov di, its[4]
    
    add ax, si
    add bx, di
    
    mul cx
    mov pxl[0], ax
    
    mov ax, bx
    mul cx
    mov pxl[4], ax
    
    mov si, idx
    
    mov cl, ln1[si]
    mov clr, cl
    
    draw8 clr, pxl[0], pxl[4]    
    
    mov si, idx
    inc si
    mov idx, si
    mov si, its[0]
    cmp si, w
    je nxtLn
    inc si
    mov its[0], si
    jmp lp
    
    
    nxtLn:
    mov si, idx
    mov si, 0
    mov idx, si
    mov ah,00
    int 16h
    mov si, 0h
    mov its[0], si
    mov di, its[4]
    cmp di, h
    je leave
    inc di
    mov its[4], di
    
    mov cx, 15
    mov bx, 0
    fill:
    mov al, ln1[bx]
    add al, 16
    mov ln1[bx], al
    inc bx
    loop fill
    jmp lp
           
    
    leave:
    mov si, 0h
    mov di, 0h
    mov its[0], si
    mov its[4], di   
    ret    
sprite endp

