data segment
	count 	db 00h
	i8255_a	equ 200h
	i8255_k	equ 203h
data ends
code segment
	assume cs:code,ds:data
	start:
		cli
		mov ax,data
		mov	ds,ax
		mov es,ax
		
		mov dx,i8255_k
		mov al,80h
		out dx,al
		mov	al,count
		mov dx,i8255_a
		out dx,al
		
		in al,21h
		and al,11011111b
		out 21h,al
		
		push ds
		mov ax,00h
		mov ds,ax
		lea ax,cs:int_proc
		mov si,35h
		add si,si
		add si,si
		mov ds:[si],ax
		push cs
		pop ax
		mov ds:[si+2],ax
		pop ds
		sti
		
lll:	nop
		jmp lll
		
int_proc proc far
		push ax
		push cx
		inc count
		mov bl,count
		shr bl,1
		mov al,bl
		mov dx,i8255_a
		out dx,al
		mov al,20h
		out 20h,al
		pop ax
		pop cx
		sti
		iret
int_proc endp
code ends
    end start
		
