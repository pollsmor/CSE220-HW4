# add test cases to data section
.data
str1: .asciiz "FRIEND"
str2: .asciiz "FRIEND"
Name_prop: .asciiz "NAME"
Frnd_prop: .asciiz "FRIEND"

str3: .asciiz "Jane Does"
.text:
main:
	la $a0, str1
	la $a1, str2
	jal str_equals
	#write test code
	move $a0, $v0
	li $v0, 1
	syscall
	li $a0, '\n'
	li $v0, 11
	syscall
	
	la $a0, str1
	la $a1, str3
	jal str_equals
	#write test code
	move $a0, $v0
	li $v0, 1
	syscall
	li $a0, '\n'
	li $v0, 11
	syscall
	
	li $v0, 10
	syscall
	
.include "hw4.asm"
