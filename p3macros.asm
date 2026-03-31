macro drawN clr, x, y, sz

mov si, 0 ;X
mov di, 0 ;Y
    
    resSI:
        mov si,0
    
    drawlp:
        mov ax, si
        add ax, x
        mov bx, di
        add bx, y
        draw clr, ax, bx
        cmp si, sz
        je goDown
        inc si
        jmp drawlp
        
    goDown:
        inc di
        cmp di, sz
        jne resSI
endm

macro draw clr, x, y

mov cx, x
mov dx, y
mov al, clr
mov ah, 0ch
int 10h    
    
endm 