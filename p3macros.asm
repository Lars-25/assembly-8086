macro draw8 clr, x, y

mov si, 0 ;X
mov di, 0 ;Y
    
    resSI:
        mov si,0
    
    drawlp:
        mov ax, si
        add ax, x
        mov bx, di
        add bx, y
        draw1 clr, ax, bx
        cmp si, 08h
        je goDown
        inc si
        jmp drawlp
        
    goDown:
        inc di
        cmp di, 08h
        jne resSI
endm

macro draw1 clr, x, y

mov cx, x
mov dx, y
mov al, clr
mov ah, 0ch
int 10h    
    
endm 