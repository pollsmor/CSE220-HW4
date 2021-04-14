############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
.text:

str_len:
	li $v0, 0	# Not gonna modify $v0 so may as well increment and return it directly
	len_loop:
		lbu $t0, 0($a0)
		beq $t0, $0, return_str_len
		
		addi $v0, $v0, 1
		addi $a0, $a0, 1
		j len_loop

	return_str_len:
	jr $ra
	
str_equals:
	li $v0, 1	# Assume string is equal at first
	equals_loop:
		lbu $t0, 0($a0)
		lbu $t1, 0($a1)
		# Need a separate case for checking both strings end at the same spot
		bne $t0, $0, not_end		# Check if str1 is at the end
		bne $t1, $0, not_equal		# Since str1 is at the end, str2 must be too to be equal
		j return_str_equals
		not_end:
		bne $t0, $t1, not_equal		# Check that the characters in question are actually equal
		addi $a0, $a0, 1
		addi $a1, $a1, 1
		j equals_loop
		
	not_equal:
	li $v0, 0
	return_str_equals:
	jr $ra
	
str_cpy:
	li $v0, 0
	cpy_loop:
		lbu $t0, 0($a0)
		beq $t0, $0, return_str_cpy
		sb $t0, 0($a1)
		
		addi $v0, $v0, 1
		addi $a0, $a0, 1	# Increment address of src
		addi $a1, $a1, 1	# Increment address of dest
		j cpy_loop
	
	return_str_cpy:
	sb $0, 0($a1)		# Store null terminator into destination
	jr $ra
	
create_person:
	lw $t0, 0($a0)		# Total nodes
	lw $t1, 16($a0)		# Current nodes	
	blt $t1, $t0, nodeAvailable
	# No nodes available
	li $v0, -1
	j return_create_person
	
	nodeAvailable:
	addi $v0, $a0, 36	# Return value is address of node, and set of nodes begins at byte 36
	li $t0, 12
	mult $t1, $t0		# Multiply current nodes by 12 as each node takes up that much space
	mflo $t0		# Now contains offset for set of nodes
	add $v0, $v0, $t0
	addi $t1, $t1, 1	# Increment current nodes
	sw $t1, 16($a0)
	
	return_create_person:
	jr $ra
	
is_person_exists:
	jr $ra
	
is_person_name_exists:
	jr $ra
	
add_person_property:
	jr $ra
	
get_person:
	jr $ra
	
is_relation_exists:
	jr $ra
	
add_relation:
	jr $ra
	
add_relation_property:
	jr $ra
	
is_friend_of_friend:
	jr $ra
