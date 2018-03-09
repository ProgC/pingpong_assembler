org 100h ; for come

jmp init

; put pixel on the screen
; di : position
; dl : color
putpixel:
	push ax
	push es

	mov ax, 0A000h
	mov es, ax
	mov byte [es:di], dl

	pop es
	pop ax

	ret

; cx, dx are the interval in microseconds
; http://webpages.charter.net/danrollins/techhelp/0221.HTM
delay:
	mov cx, 1
	mov dx, 01h
	mov al, 0 ; have to do this it's a dosbox bug.
	mov ah, 86h ; delay
	int 15h
	ret


; clear out the entire screen
clearscreen:
	pushad

	mov ax, 0A000h
	mov es, ax
	xor di, di

	mov cx, 320*200 / 2

	xor ax, ax ; color
	rep stosw

	popad
	ret

ballx dw 100
bally dw 100
ballvx dw 10
ballvy dw -10

; turn on the 13h mode.
init:

mov ax, 13h
int 10h

mainloop:
	call clearscreen

	; addr = y * 320 + x
	mov ax, [bally]
	imul ax, 320
	add ax, [ballx]

	mov di, ax
	mov dl, 100
	call putpixel



	; move x coordinate
	mov ax, [ballx]
	add ax, [ballvx]

	cmp ax, 0
	jl bounceleft

	cmp ax, 320
	jg bounceright
	jmp nosidebounce

bounceleft:
	mov bx, 10
	mov [ballvx], bx
	mov ax, 1
	mov [ballx], ax
	jmp nosidebounce

bounceright:
	mov bx, -10
	mov [ballvx], bx
	mov ax, 319
	mov [ballx], ax

nosidebounce:
	mov [ballx], ax

	; move y coordinate
	mov ax, [bally]
	add ax, [ballvy]

  cmp ax, 0
	jl bounceA

	cmp ax, 200
	jge bounceB
	jmp nobounce

bounceA: ; adjust y pos
	mov bx, 0
	mov ax, bx
	mov [bally], bx
	mov bx, 10
	mov [ballvy], bx
	jmp bounce

bounceB: ; adjust y pos
	mov ax, 199
	mov [bally], ax
	mov bx, -10
	mov [ballvy], bx

bounce:

nobounce:
	mov [bally], ax	; update bally

	call delay

jmp mainloop

done:
	; back to text mode from 13h
	mov ax, 3
	int 10h
	ret
