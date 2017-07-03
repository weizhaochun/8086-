data segment
	portc1	db	0ch,14h,21h,22h,24h	;�����ͨ�ź�
	jishu	dw	800,600,400		;��ͬ��ʱʱ�䳤��
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
	call	ini8253				;��ʼ��
	
	mov	dx,io8255
	add	dx,1
	mov	al,01h
	out	dx,al				;clk1��ʱ�������ſ�


	in al,21h
	and al,11011011b
     	out 21h,al  
	in al,0A1h
	and al,11111110b
     	out 0A1h,al  				;�����ж�����


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
	mov	ds:[si+2],ax			;����35H�ж�����



	mov	ax,offset n_s
	mov	si,70h
	add	si,si
	add	si,si
	mov	ds:[si],ax
	push	cs
	pop	ax
	mov	ds:[si+2],ax			;����70H�ж�����
	pop	ds


	sti
re_on:	mov	dx,io8255
	add	dx,2
	lea	bx,portc1
	mov	al,[bx]
	out	dx,al				;���״̬һ
	lea	si,jishu			;��ʱʱ������ͬ	
	call	time				;д���ֵ����ʼ��ʱ


	inc	bx
	mov	dx,io8255
	add	dx,2
	mov	al,[bx]
	out	dx,al				;���״̬��
	mov	ch,al
	mov	cl,00000100b
	lea	si,jishu
	add	si,4
	call	time2

	inc	bx
	mov	al,[bx]
	mov	dx,io8255
	add	dx,2
	out	dx,al				;���״̬��
	lea	si,jishu
	add	si,2
	call	time


	inc	bx
	mov	dx,io8255
	add	dx,2
	mov	al,[bx]
	out	dx,al				;���״̬��
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
	out	dx,al				;д��clk1������ֵ

	mov	dx,io8255
l1:	in	al,dx
	and	al,01h
	jnz	l1				;��ⶨʱ����
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
	out	dx,al				;д��clk1������ֵ

lt2:	mov	dx,io8255
	in	al,dx
	mov	ah,al
	and	al,01h
	jz	lt1				;clk1��ʱ�Ƿ����
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
	out	dx,al				;���ӻƵ���˸
	jmp	lt2
lt1:	ret
time2	endp


ini8255	proc
	mov	dx,io8255
	add	dx,03
	mov	al,10010000b			;PA���룬PB��PC���
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
	out	dx,al				;clk0��Ƶ���100HZ
	mov	dx,io8253
	add	dx,03
	mov	al,10010110b
	out	dx,al
	mov	dx,io8253
	inc	dx
	inc	dx
	mov	al,100
	out	dx,al				;clk2����1s����������������˸
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
	out	dx,al				;��ͣclk1����

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
	out	dx,al				;���ݽ���ʱ��״̬�������Ӧ״̬

	mov	cx,4000
de1:	mov	di,1000
de0:	dec	di
	jnz	de0
	loop	de1				;�����ʱ


	pop	bx
	mov	dx,io8255
	add	dx,2
	mov	al,[bx]
	out	dx,al				;�ָ�ԭ�ȵ����״̬

	mov	dx,io8255
	add	dx,1
	mov	al,01h
	out	dx,al				;����clk1����

	mov	al,20h
	out	20h,al				;����Ƭ������ͨEOI����
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
	out	0A0h,al				;����Ƭ������ͨEOI����
	out	20h,al				;����Ƭ������ͨEOI����
	pop	dx
	pop	ax
	pop	di
	pop	cx
	sti
	iret
n_s	endp

cade	ends
	end	start