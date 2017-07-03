data	segment
	data1	dw 	0011h
	data2	dw	0001h
	result	db  00h
data	ends
ssg	segment para stack
	dw	20h	dup(?)
ssg	ends
code	segment
	assume	cs:code,ds:data,ss:ssg
start:	mov	ax,data
		mov	ds,ax
		mov	ax,data1
		mov bx,data2
		mov	cx,0
circle2:	sub	ax,bx
		jb	circle1
		add	bx,2
		add	cx,1
		jmp circle2
circle1: mov result,cx
        add result,30h
        mov ah,02h
		mov	dl,result
		int	21h
		mov	ax,4c00h
		int	21h
code	ends
end		start
	