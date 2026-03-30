include p3macros.asm
.model medium
.stack 100h


.data
;       0   1   2   3   4   5   6   7
ln1 db  15 ,15 ,14 ,14 ,14 ,14 ,15 ,15 ,'@' ;@ o 40h es fin de linea
ln2 db  15 ,14 ,14 ,14 ,14 ,14 ,14 ,15 ,'@'
ln3 db  14 ,14 ,12 ,14 ,14 ,12 ,14 ,14 ,'@'
ln4 db  14 ,14 ,14 ,14 ,14 ,14 ,14 ,14 ,'@'
ln5 db  14 ,14 ,14 ,14 ,14 ,14 ,14 ,14 ,'@'
ln6 db  14 ,14 ,11 ,14 ,14 ,11 ,14 ,14 ,'@'
ln7 db  15 ,14 ,14 ,11 ,11 ,14 ,14 ,15 ,'@'
ln8 db  15 ,15 ,14 ,14 ,14 ,14 ,15 ,15 ,'x',':'
crd dw  0000h, 'y:', 0000h, 'i:'
its dw  0000h, 'j:', 0000h, 'x:'
pxl dw  0000h, 'y:', 0000h, 'cl'
clr db  0ch 
idx dw  0000h

w   equ 8
h   equ 8
px  equ 8            

.code

mov ax, 0A000h
mov es, ax
                          
mov ax, @data
mov ds, ax
               
mov ax, 0013h
int 10h

call sprite
           
.exit

proc sprite
    
    lp:
    cmp si, w
    je nxtLn
    
    mov ax, 0100h
    int 16h
    cmp al, 00h
    jne leave
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
    
    inc si
    mov its[0], si
    jmp lp
    
    
    nxtLn:
    mov si, idx
    inc si
    mov idx, si
    mov si, 0h
    mov its[0], si
    mov di, its[4]
    inc di
    mov its[4], di
    cmp di, h
    je restart
    jmp lp
    
    restart:
    mov si, 0
    mov di, 0
    mov its[0], si
    mov its[4], di
    mov pxl[0], si
    mov pxl[4], di
    mov idx, si   
    jmp lp       
    
    leave:
    mov si, 0h
    mov di, 0h
    mov its[0], si
    mov its[4], di   
    ret    
sprite endp