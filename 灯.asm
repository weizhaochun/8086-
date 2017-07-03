io_address equ 230h
code segment
assume cs:code
start:
	mov dx,io_address+3
	mov al,10000010b
	out dx,al
loop1:mov dx,io_address+1
	in al,dx
	inc dx
	not al
	out dx,al
	jmp loop1
code ends
	end start