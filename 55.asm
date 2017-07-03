  data segment
      ad_io equ 200h
	led_io equ 210h
	i8255_a	equ 230h
	i8255_k	equ 233h
data ends
code segment
	assume cs:code,ds:data
start:
	mov ax,data
	mov ds,ax
	mov es,ax
	mov dx,i8255_k
	mov al,80h
	out dx,al
rpt:
	mov dx,ad_io
	out dx,al
	mov dx,ad_io
	add dx,2
l1:
	in al,dx
	test al,01h
	jz l1
	mov dx,ad_io
	inc dx
	in al,dx
	mov dx,i8255_a
	out dx,al		
	call	delay	
     jmp rpt
		
	

delay proc
	push cx
	mov cx,50h
x1:
	loop x1
	pop cx
	ret
delay endp

code ends
	end start