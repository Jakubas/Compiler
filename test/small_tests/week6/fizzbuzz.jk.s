.LC0:
.string	"%d\n"
.text
.globl	print
.type	print, @function
print:
.LFB2:
.cfi_startproc
pushq	%rbp
.cfi_def_cfa_offset 16
.cfi_offset 6, -16
movq	%rsp, %rbp
.cfi_def_cfa_register 6
subq	$16, %rsp
movl	%edi, -4(%rbp)
movl	-4(%rbp), %eax
movl	%eax, %esi
movl	$.LC0, %edi
movl	$0, %eax
call	printf
movl	$0, %edi
call	exit
.cfi_endproc

divisibleByThree:
//stackframe
pushq %rbp
movq  %rsp, %rbp
addq  $8, %rbp
pushq $1
pushq $3
whilestart113:
//offset 1 mutable lookup
movq  $-24, %rax
pushq %rax
popq  %rax
movq  %rbp, %rbx
addq  %rax, %rbx
movq  -0(%rbx), %rax
pushq %rax
//offset -3 mutable lookup
movq  $8, %rax
pushq %rax
popq  %rax
movq  %rbp, %rbx
addq  %rax, %rbx
movq  -0(%rbx), %rax
pushq %rax
popq  %rax
popq  %rbx
cmpq  %rax, %rbx
jle   lbltrue114
pushq $0
jmp   end114
lbltrue114:
pushq $1
end114:
popq  %rax
movq  $0, %rbx
cmpq  %rax, %rbx
je   whileend113
//offset 1 mutable lookup
movq  $-24, %rax
pushq %rax
popq  %rax
movq  %rbp, %rbx
addq  %rax, %rbx
movq  -0(%rbx), %rax
pushq %rax
//offset -4 mutable lookup
movq  $16, %rax
pushq %rax
popq  %rax
movq  %rbp, %rbx
addq  %rax, %rbx
movq  -0(%rbx), %rax
pushq %rax
popq  %rax
popq  %rbx
cmpq  %rax, %rbx
je    lbltrue115
pushq $0
jmp   end115
lbltrue115:
pushq $1
end115:
popq  %rax
movq  $0, %rbx
cmpq  %rax, %rbx
jne   label116
//offset 1 mutable lookup
movq  $-24, %rax
pushq %rax
popq  %rax
movq  %rbp, %rbx
addq  %rax, %rbx
movq  -0(%rbx), %rax
pushq %rax
pushq $3
popq  %rax
popq  %rbx
addq  %rax, %rbx
pushq %rbx
//offset 1 mutable lookup
movq  $-24, %rax
pushq %rax
//asg
popq  %rax
movq  %rbp, %rbx
addq  %rax, %rbx
popq  %rax
movq  %rax, -0(%rbx)
jmp   endlabel116
label116:
pushq $0
//offset 0 mutable lookup
movq  $-16, %rax
pushq %rax
//asg
popq  %rax
movq  %rbp, %rbx
addq  %rax, %rbx
popq  %rax
movq  %rax, -0(%rbx)
//offset -3 mutable lookup
movq  $8, %rax
pushq %rax
popq  %rax
movq  %rbp, %rbx
addq  %rax, %rbx
movq  -0(%rbx), %rax
pushq %rax
pushq $1
popq  %rax
popq  %rbx
addq  %rax, %rbx
pushq %rbx
//offset 1 mutable lookup
movq  $-24, %rax
pushq %rax
//asg
popq  %rax
movq  %rbp, %rbx
addq  %rax, %rbx
popq  %rax
movq  %rax, -0(%rbx)
endlabel116:
jmp   whilestart113
whileend113:
//offset 0 mutable lookup
movq  $-16, %rax
pushq %rax
popq  %rax
movq  %rbp, %rbx
addq  %rax, %rbx
movq  -0(%rbx), %rax
pushq %rax
popq  %rax
popq  %rbx
pushq %rax
popq  %rax
popq  %rbx
pushq %rax
popq  %rax
//stackframe_end
subq  $8, %rbp
movq  %rbp, %rsp
popq  %rbp
ret

divisibleByFive:
//stackframe
pushq %rbp
movq  %rsp, %rbp
addq  $8, %rbp
pushq $1
pushq $5
whilestart117:
//offset 1 mutable lookup
movq  $-24, %rax
pushq %rax
popq  %rax
movq  %rbp, %rbx
addq  %rax, %rbx
movq  -0(%rbx), %rax
pushq %rax
//offset -3 mutable lookup
movq  $8, %rax
pushq %rax
popq  %rax
movq  %rbp, %rbx
addq  %rax, %rbx
movq  -0(%rbx), %rax
pushq %rax
popq  %rax
popq  %rbx
cmpq  %rax, %rbx
jle   lbltrue118
pushq $0
jmp   end118
lbltrue118:
pushq $1
end118:
popq  %rax
movq  $0, %rbx
cmpq  %rax, %rbx
je   whileend117
//offset 1 mutable lookup
movq  $-24, %rax
pushq %rax
popq  %rax
movq  %rbp, %rbx
addq  %rax, %rbx
movq  -0(%rbx), %rax
pushq %rax
//offset -4 mutable lookup
movq  $16, %rax
pushq %rax
popq  %rax
movq  %rbp, %rbx
addq  %rax, %rbx
movq  -0(%rbx), %rax
pushq %rax
popq  %rax
popq  %rbx
cmpq  %rax, %rbx
je    lbltrue119
pushq $0
jmp   end119
lbltrue119:
pushq $1
end119:
popq  %rax
movq  $0, %rbx
cmpq  %rax, %rbx
jne   label120
//offset 1 mutable lookup
movq  $-24, %rax
pushq %rax
popq  %rax
movq  %rbp, %rbx
addq  %rax, %rbx
movq  -0(%rbx), %rax
pushq %rax
pushq $5
popq  %rax
popq  %rbx
addq  %rax, %rbx
pushq %rbx
//offset 1 mutable lookup
movq  $-24, %rax
pushq %rax
//asg
popq  %rax
movq  %rbp, %rbx
addq  %rax, %rbx
popq  %rax
movq  %rax, -0(%rbx)
jmp   endlabel120
label120:
pushq $0
//offset 0 mutable lookup
movq  $-16, %rax
pushq %rax
//asg
popq  %rax
movq  %rbp, %rbx
addq  %rax, %rbx
popq  %rax
movq  %rax, -0(%rbx)
//offset -3 mutable lookup
movq  $8, %rax
pushq %rax
popq  %rax
movq  %rbp, %rbx
addq  %rax, %rbx
movq  -0(%rbx), %rax
pushq %rax
pushq $1
popq  %rax
popq  %rbx
addq  %rax, %rbx
pushq %rbx
//offset 1 mutable lookup
movq  $-24, %rax
pushq %rax
//asg
popq  %rax
movq  %rbp, %rbx
addq  %rax, %rbx
popq  %rax
movq  %rax, -0(%rbx)
endlabel120:
jmp   whilestart117
whileend117:
//offset 0 mutable lookup
movq  $-16, %rax
pushq %rax
popq  %rax
movq  %rbp, %rbx
addq  %rax, %rbx
movq  -0(%rbx), %rax
pushq %rax
popq  %rax
popq  %rbx
pushq %rax
popq  %rax
popq  %rbx
pushq %rax
popq  %rax
//stackframe_end
subq  $8, %rbp
movq  %rbp, %rsp
popq  %rbp
ret

.LFE2:
.size	print, .-print
.globl	main
.type	main, @function

main:
.LFB3:
.cfi_startproc
pushq	%rbp
.cfi_def_cfa_offset 16
.cfi_offset 6, -16
movq	%rsp, %rbp
.cfi_def_cfa_register 6
subq	$16, %rsp
movl	$260, -4(%rbp)
movl	-4(%rbp), %eax
movl	%eax, %edi
pushq $1
pushq $100
whilestart121:
//offset 1 mutable lookup
movq  $-24, %rax
pushq %rax
popq  %rax
movq  %rbp, %rbx
addq  %rax, %rbx
movq  -0(%rbx), %rax
pushq %rax
//offset 2 mutable lookup
movq  $-32, %rax
pushq %rax
popq  %rax
movq  %rbp, %rbx
addq  %rax, %rbx
movq  -0(%rbx), %rax
pushq %rax
popq  %rax
popq  %rbx
cmpq  %rax, %rbx
jle   lbltrue122
pushq $0
jmp   end122
lbltrue122:
pushq $1
end122:
popq  %rax
movq  $0, %rbx
cmpq  %rax, %rbx
je   whileend121
//offset 1 mutable lookup
movq  $-24, %rax
pushq %rax
popq  %rax
movq  %rbp, %rbx
addq  %rax, %rbx
movq  -0(%rbx), %rax
pushq %rax
//offset 2 mutable lookup
movq  $-32, %rax
pushq %rax
popq  %rax
movq  %rbp, %rbx
addq  %rax, %rbx
movq  -0(%rbx), %rax
pushq %rax
call  divisibleByThree
pushq %rax
//offset 1 mutable lookup
movq  $-24, %rax
pushq %rax
popq  %rax
movq  %rbp, %rbx
addq  %rax, %rbx
movq  -0(%rbx), %rax
pushq %rax
//offset 2 mutable lookup
movq  $-32, %rax
pushq %rax
popq  %rax
movq  %rbp, %rbx
addq  %rax, %rbx
movq  -0(%rbx), %rax
pushq %rax
call  divisibleByFive
pushq %rax
popq  %rax
popq  %rbx
and   %rax, %rbx
cmpq  $0, %rbx
jne   lbltrue123
pushq $0
jmp   end123
lbltrue123:
pushq $1
end123:
popq  %rax
movq  $0, %rbx
cmpq  %rax, %rbx
jne   label124
//offset 1 mutable lookup
movq  $-24, %rax
pushq %rax
popq  %rax
movq  %rbp, %rbx
addq  %rax, %rbx
movq  -0(%rbx), %rax
pushq %rax
//offset 2 mutable lookup
movq  $-32, %rax
pushq %rax
popq  %rax
movq  %rbp, %rbx
addq  %rax, %rbx
movq  -0(%rbx), %rax
pushq %rax
call  divisibleByThree
pushq %rax
popq  %rax
movq  $0, %rbx
cmpq  %rax, %rbx
jne   label125
//offset 1 mutable lookup
movq  $-24, %rax
pushq %rax
popq  %rax
movq  %rbp, %rbx
addq  %rax, %rbx
movq  -0(%rbx), %rax
pushq %rax
//offset 2 mutable lookup
movq  $-32, %rax
pushq %rax
popq  %rax
movq  %rbp, %rbx
addq  %rax, %rbx
movq  -0(%rbx), %rax
pushq %rax
call  divisibleByFive
pushq %rax
popq  %rax
movq  $0, %rbx
cmpq  %rax, %rbx
jne   label126
jmp   endlabel126
label126:
endlabel126:
jmp   endlabel125
label125:
endlabel125:
jmp   endlabel124
label124:
endlabel124:
//offset 1 mutable lookup
movq  $-24, %rax
pushq %rax
popq  %rax
movq  %rbp, %rbx
addq  %rax, %rbx
movq  -0(%rbx), %rax
pushq %rax
pushq $1
popq  %rax
popq  %rbx
addq  %rax, %rbx
pushq %rbx
//offset 1 mutable lookup
movq  $-24, %rax
pushq %rax
//asg
popq  %rax
movq  %rbp, %rbx
addq  %rax, %rbx
popq  %rax
movq  %rax, -0(%rbx)
jmp   whilestart121
whileend121:
//offset 1 mutable lookup
movq  $-24, %rax
pushq %rax
popq  %rax
movq  %rbp, %rbx
addq  %rax, %rbx
movq  -0(%rbx), %rax
pushq %rax
popq  %rax
popq  %rbx
pushq %rax
popq  %rax
popq  %rbx
pushq %rax
popq  %rdi
call	print
movl	$1, %eax
leave
.cfi_def_cfa 7, 8
ret
.cfi_endproc
.LFE3:
.size	main, .-main
.ident	"GCC: (Ubuntu 5.4.0-6ubuntu1~16.04.4) 5.4.0 20160609"
.section	.note.GNU-stack,"",@progbits
