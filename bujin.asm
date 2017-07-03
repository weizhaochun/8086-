io_adress	equ	200h
data 		segment
		count db 0
		speed	db	10

		turn 	db 	01h,03h,02h,06h,04h,0ch,08h,09h
data 	ends
code		segment
		assume	cs:code,ds:data
start:	mov	ax,data
		mov	ds,ax
		mov	dx,io_adress
		add	dx,03h
		mov	al,80h
		out	dx,al
		
		mov	dx,io_adress
circle1:	lea	bx,turn
		mov	count,0
circle2:	mov	al,[bx]
		out	dx,al
		call	delay
		inc	bx
		add	count,1
		cmp	count,8
		je	circle1
		jmp	circle2
		
delay	proc
		push	ax
		push	cx
		push	dx
		push	bx
		mov	dh,speed
x1:		mov	cx,0080h
x2:		loop	x2
		dec	dh
		jnz	x1
		pop		bx
		pop		dx
		pop		cx
		pop		ax
		ret
delay	endp
code	ends
		end start