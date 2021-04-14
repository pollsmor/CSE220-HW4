# add test cases to data section
.data
Network:
  .word 5   #total_nodes (bytes 0 - 3)
  .word 10  #total_edges (bytes 4- 7)
  .word 12  #size_of_node (bytes 8 - 11)
  .word 12  #size_of_edge (bytes 12 - 15)
  .word 0   #curr_num_of_nodes (bytes 16 - 19)
  .word 0   #curr_num_of_edges (bytes 20 - 23)
  .asciiz "NAME" # Name property (bytes 24 - 28)
  .asciiz "FRIEND" # FRIEND property (bytes 29 - 35)
   # set of nodes (bytes 36 - 95)	
  .byte 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0	
   # set of edges (bytes 96 - 215)
  .word 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0

.text:
main:
	# See what is the initial address of network, compare with returned address of node
	la $a0, Network	
	li $v0, 1
	syscall
	li $a0, '\n'
	li $v0, 11
	syscall

	la $a0, Network
	jal create_person
	#write test code
	move $a0, $v0		# $v0 return value
	li $v0, 1
	syscall
	li $a0, '\n'
	li $v0, 11
	syscall

	la $a0, Network		# Checking curr_num_of_nodes
	lw $a0, 16($a0)
	li $v0, 1
	syscall
	
	li $v0, 10
	syscall
	
.include "hw4.asm"
