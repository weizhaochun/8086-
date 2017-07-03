data segment
	portc1	db	0ch,14h,21h,22h,24h	;输出交通信号
	jishu	dw	800,600,400		;不同定时时间长度
	io8255	equ	200h
	io8253	equ	210h
data	ends
code	segment
	assume	cs:code,ds:data
	main	proc	far
start:
	cli
	mov	ax,data
	mov	ds,ax
	call	ini8255
	call	ini8253				;初始化
	
	mov	dx,io8255
	add	dx,1
	mov	al,01h
	out	dx,al				;clk1定时器开启门控


	in al,21h
	and al,11011011b
     	out 21h,al  
	in al,0A1h
	and al,11111110b
     	out 0A1h,al  				;开放中断屏蔽


	push	ds
	mov	ax,0
	mov	ds,ax
	mov	ax,offset w_e
	mov	si,35h
	add	si,si
	add	si,si
	mov	ds:[si],ax
	push	cs
	pop	ax
	mov	ds:[si+2],ax			;设置35H中断向量



	mov	ax,offset n_s
	mov	si,70h
	add	si,si
	add	si,si
	mov	ds:[si],ax
	push	cs
	pop	ax
	mov	ds:[si+2],ax			;设置70H中断向量
	pop	ds


	sti
re_on:	mov	dx,io8255
	add	dx,2
	lea	bx,portc1
	mov	al,[bx]
	out	dx,al				;输出状态一
	lea	si,jishu			;定时时长，下同	
	call	time				;写入初值，开始定时


	inc	bx
	mov	dx,io8255
	add	dx,2
	mov	al,[bx]
	out	dx,al				;输出状态二
	mov	ch,al
	mov	cl,00000100b
	lea	si,jishu
	add	si,4
	call	time2

	inc	bx
	mov	al,[bx]
	mov	dx,io8255
	add	dx,2
	out	dx,al				;输出状态三
	lea	si,jishu
	add	si,2
	call	time


	inc	bx
	mov	dx,io8255
	add	dx,2
	mov	al,[bx]
	out	dx,al				;输出状态四
	mov	ch,al
	mov	cl,00100000b
	lea	si,jishu
	add	si,4
	call	time2

	jmp	re_on		

main	endp



time	proc
	mov	dx,io8253
	add	dx,03
	mov	al,01111000b
	out	dx,al
	mov	dx,io8253
	inc	dx
	mov	ax,[si]
	out	dx,al
	mov	al,ah
	out	dx,al				;写入clk1计数初值

	mov	dx,io8255
l1:	in	al,dx
	and	al,01h
	jnz	l1				;检测定时结束
	ret
time	endp

time2	proc
	mov	dx,io8253
	add	dx,03
	mov	al,01111000b
	out	dx,al
	mov	dx,io8253
	inc	dx
	mov	ax,[si]
	out	dx,al
	mov	al,ah
	out	dx,al				;写入clk1计数初值

lt2:	mov	dx,io8255
	in	al,dx
	mov	ah,al
	and	al,01h
	jz	lt1				;clk1定时是否结束
	and	ah,02h
	jz	lt3
	mov	dx,io8255
	add	dx,2
	mov	al,cl
	out	dx,al
	jmp	lt2
lt3:	mov	dx,io8255
	add	dx,2
	mov	al,ch
	out	dx,al				;附加黄灯闪烁
	jmp	lt2
lt1:	ret
time2	endp


ini8255	proc
	mov	dx,io8255
	add	dx,03
	mov	al,10010000b			;PA输入，PB、PC输出
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
	out	dx,al				;clk0分频输出100HZ
	mov	dx,io8253
	add	dx,03
	mov	al,10010110b
	out	dx,al
	mov	dx,io8253
	inc	dx
	inc	dx
	mov	al,100
	out	dx,al				;clk2周期1s方波，用作控制闪烁
	ret
ini8253	endp



w_e	proc	far
	push	cx
	push	di
	push	ax
	push	dx
	push	bx
	mov	dx,io8255
	add	dx,1
	mov	al,00h
	out	dx,al				;暂停clk1计数

	mov	dx,io8255
	add	dx,2
	lea	cx,portc1
	sub	bx,cx
	cmp	bx,1
	ja	li1
	lea	bx,portc1
	jmp	li2
li1:	lea	bx,portc1
	add	bx,4
li2:	mov	al,[bx]
	out	dx,al				;依据进入时的状态，输出相应状态

	mov	cx,4000
de1:	mov	di,1000
de0:	dec	di
	jnz	de0
	loop	de1				;软件定时


	pop	bx
	mov	dx,io8255
	add	dx,2
	mov	al,[bx]
	out	dx,al				;恢复原先的输出状态

	mov	dx,io8255
	add	dx,1
	mov	al,01h
	out	dx,al				;继续clk1计数

	mov	al,20h
	out	20h,al				;给主片发送普通EOI命令
	pop	dx
	pop	ax
	pop	di
	pop	cx
	sti
	iret
w_e	endp



n_s	proc	far
	push	cx
	push	di
	push	ax
	push	dx
	push	bx
	mov	dx,io8255
	add	dx,1
	mov	al,00h
	out	dx,al

	mov	dx,io8255
	add	dx,2
	lea	cx,portc1
	sub	bx,cx
	cmp	bx,1
	ja	lili1
	lea	bx,portc1
	add	bx,4
	jmp	lili2
lili1:	lea	bx,portc1
	add	bx,2
lili2:	mov	al,[bx]
	out	dx,al

	mov	cx,4000
dede1:	mov	di,1000
dede0:	dec	di
	jnz	dede0
	loop	dede1

	pop	bx
	mov	dx,io8255
	add	dx,2
	mov	al,[bx]
	out	dx,al	

	mov	dx,io8255
	add	dx,1
	mov	al,01h
	out	dx,al
	mov	al,20h
	out	0A0h,al				;给从片发送普通EOI命令
	out	20h,al				;给主片发送普通EOI命令
	pop	dx
	pop	ax
	pop	di
	pop	cx
	sti
	iret
n_s	endp

cade	ends
	end	start