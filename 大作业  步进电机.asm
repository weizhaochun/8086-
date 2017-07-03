data segment
	io8255	equ	200h
	io8253	equ	210h
	io0809	equ	220h
	led	db	00000001b,00000010b,00000100b,00001000b,00010000b,00100000b,01000000b,10000000b
	order	db	01h,03h,02h,06h,04h,0ch,08h,09h
	flag	db	01h
	speed	db	30
	speedk	db	00h
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
								;初始化8255和8253
	
	in	al,21h
	and	al,11011111b
	out	21h,al
	push	ds
	mov	ax,0
	mov	ds,ax
	mov	ax,offset INT_PROC		;获取中断向量
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
	cmp	bl,01h					;判断是正向还是反向转
	lea	si,order
	lea	bx,led
	mov	cx,8
	jnz	l1						;反向则跳到l1处
	jmp	l2						;正向则跳到l2处
	std
l1:	add	si,7
	add	bx,7	
l3:	mov	dx,io8255				
	mov	al,[si]
	out	dx,al					;将相序输出到步进电机
	call	delay				;延时
	mov	al,[bx]
	add	dx,2
	out	dx,al					;将与相序对应的led等状态输出到led
	dec	si
	dec	bx
	call	delay
	loop	l3					;循环进行旋转
	jmp	l4
l2:	std
	mov	dx,io8255
	mov	al,[si]
	out	dx,al
	call	delay
	mov	al,[bx]
	add	dx,2
	out	dx,al
	inc	si
	inc	bx
	call	delay
	loop	l2
	jmp	l4
main	endp


ini8255	proc					;初始化8255，PA,PC输出，PB输入
	mov	dx,io8255
	add	dx,03
	mov	al,10000010b
	out	dx,al
	ret
ini8255 endp


ini8253	proc					;初始化8253，计数器0输出100HZ
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
	mov	al,20
	out	dx,al
	ret
ini8253	endp



INT_PROC	proc	far			;中断服务程序，负责进行AD转换，改变speedk的值来改变步进电机的转速
	push	ax
	push	dx
	mov	dx,io8255
	inc	dx
	in	al,dx
	and	al,01h
	mov	flag,al
	mov	dx,io0809
	out	dx,al
	add	dx,2
lp1:	in	al,dx
	test	al,01h
	jz	lp1
	dec	dx
	in	al,dx
	mov	speedk,al
	mov	al,20h					;发送EOI命令，允许下次中断进入
	out	20h,al
	pop	dx
	pop	ax
	sti
	iret
INT_PROC	endp
	

delay	proc					;延时函数
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

code	ends
	end	start