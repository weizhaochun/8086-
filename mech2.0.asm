data segment
	io8255	equ	200h
	io8253	equ	210h
	io0809	equ	220h
	order	db	01h,03h,02h,06h,04h,0ch,08h,09h
	flag	db	80h
	speed	db	20
	speedk	db	0ffh
data	ends
code	segment
	assume	cs:code,ds:data
	main	proc	far
start:
	cli
	mov	ax,data
	mov	ds,ax
	call	ini8255
	call	ini8253
								;call	ini8259
	
	in	al,21h
	and	al,11011111b
	out	21h,al
	push	ds
	mov	ax,0
	mov	ds,ax
	mov	ax,offset INT_PROC
	mov	si,35h
	add	si,si
	add	si,si
	mov	ds:[si],ax
	push	cs
	pop	ax
	mov	ds:[si+2],ax
	pop	ds
	
	sti
	mov	dx,io8255
l4:	mov	bl,flag
	cmp	bl,80h
	jnz	l1
	cld
	lea	si,order
	jmp	l2
l1:	std
	lea	si,order
	add	si,7	
l2:	mov	cx,8
l3:	lodsb
	out	dx,al
	call	delay
	loop	l3
	jmp	l4
main	endp


ini8255	proc
	mov	dx,io8255
	add	dx,03
	mov	al,10000010b
	out	dx,al
	ret
ini8255 endp


ini8253	proc
	mov	dx,io8253
	add	dx,03
	mov	al,00110111b
	out	dx,al
	mov	dx,io8253
	mov	al,0
	out	dx,al
	out	dx,al
	add	dx,03
	mov	al,01010110b
	out	dx,al
	mov	dx,io8253
	inc	dx
	mov	al,200
	out	dx,al
	ret
ini8253	endp



INT_PROC	proc	far
	push	ax
	push	dx
	mov	dx,io8255
	inc	dx
	in	al,dx
	mov	ah,al
	and	ah,80h
	mov	flag,ah
	mov	dx,io0809
	out	dx,al
	add	dx,2
lp1:	in	al,dx
	test	al,01h
	jz	lp1
	dec	dx
	in	al,dx
	mov	speedk,al
	mov	al,20h
	out	20h,al
	pop	dx
	pop	ax
	sti
	iret
INT_PROC	endp
	

delay	proc
	push	ax
	push	cx
	push	dx
	xor	cx,cx
	mov	dh,speed
x1:	mov	cl,speedk
x2:	loop	x2
	dec	dh
	jnz	x1
	pop	dx
	pop	cx
	pop	ax
	ret
delay	endp

cade	ends
	end	start