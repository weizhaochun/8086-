data		segment
	data1	dB	25,14,-12,45,0,-10,48,72,-20,40
	count	equ	$-data1
	str1    db  'posetive number is '
	zheng	db	00h
	str2    db  ' negetive number is '
	fu		db	00h
	str3    db  ' zero number is '
	ling	db	00h
	data2   db  0ah,0dh,'$'
data		ends

ssg		segment		para	stack
	dw	20h	dup(?)
ssg		ends

code		segment
		assume		cs:code,ds:data,ss:ssg
start:	mov	ax,data
		mov	ds,ax
		mov cx,10
		lea bx,buf
circle3:cmp byte ptr [bx+2],30h
		jg circle1
		jl circle2
		add ling,01h
		jmp end
circle1:add zheng,01h
        jmp end
circle2:add fu,01h
end:	inc bx
        loop circle3
		add zheng,30h
		add fu,30h
		add ling,30h
        mov ah,09h
		lea	dx,str1
		int	21h
		;add zheng,30h
        ;mov ah,02h
		;mov	dl,zheng
		;int	21h
		;add fu,30h
        ;mov ah,02h
		;mov	dl,fu
		;int	21h
		;add ling,30h
        ;mov ah,02h
		;mov	dl,ling
		;int	21h
		mov	ax,4c00h
		int	21h
code		ends
end	start