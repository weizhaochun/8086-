main proc far	          		
  push ds		    	
  xor ax, ax	          
  push ax		    
  mov ax,  data      	
  mov	ds, ax	          
  mov cx, count–1        
main1:                 	
  lea bx, buffer				
  push cx
main2:
  mov ax, [bx]
  inc	 bx
  inc  bx
cmp ax, [bx]
jle next
xchg ax,[bx];交换数据
mov [bx-2],ax
next:loop main2 ;内循环
pop cx
loop main1    ;外循环
main endp
