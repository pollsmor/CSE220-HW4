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
	lw $t0, 8($a0)		# Should be 12 bytes, use this to be modular anyway
	addi $v0, $a0, 36	# Return value is address of node, and set of nodes begins at byte 36
	mult $t1, $t0		# Multiply current nodes by 12 as each node takes up that much space
	mflo $t0		# Now contains offset for set of nodes
	add $v0, $v0, $t0
	addi $t1, $t1, 1	# Increment current nodes
	sw $t1, 16($a0)
	
	return_create_person:
	jr $ra
	
is_person_exists:
	li $v0, 0		# Assume no person exists in the Network
	lw $t0, 16($a0)		# curr_num_of_nodes
	lw $t1, 8($a0)		# Person nodes occur in multiples of 12
	mult $t0, $t1
	mflo $t0		# Address of person must be less than $t0. i.e. 1 curr_nodes, must be < byte 12.
	# Set Network address to start at its set of nodes, then subtract it from the person's address
	addi $a0, $a0, 36	
	sub $t2, $a1, $a0
	blt $t2, $0, return_is_person_exists
	bge $t2, $t0, return_is_person_exists	# As explained above for $t0
	div $t2, $t1
	mfhi $t0				# Remainder
	bne $t0, $0, return_is_person_exists	# Address of person must be a multiple of 12
	li $v0, 1
	
	return_is_person_exists:
	jr $ra
	
is_person_name_exists:
	addi $sp, $sp, -20
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	move $s0, $a0		# Store Network
	move $s1, $a1		# Store name
	lw $s2, 8($s0)		# Store size of node (default 12 bytes)
	lw $s3, 16($s0)		# Store current amount of nodes
	
	addi $s0, $s0, 36	# Move pointer to array of nodes
	bgt $s3, $0, check_person_name_loop
	# 0 nodes in array, so the name can't exist.
	li $v0, 0
	j return_is_person_name_exists
	check_person_name_loop:
		# Call str_equals
		move $a0, $s1
		move $a1, $s0
		jal str_equals
		beq $v0, $0, advance_check_name_loop
		# The strings equal, return 1
		li $v0, 1
		j return_is_person_name_exists
		
		advance_check_name_loop:
		add $s0, $s0, $s2	# Increment Network by size of node
		addi $s3, $s3, -1	# Decrement amount of nodes remaining to loop through
		bne $s3, $0, check_person_name_loop
	
	return_is_person_name_exists:
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	addi $sp, $sp, 20
	jr $ra
	
add_person_property:
	addi $sp, $sp, -16
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	move $s0, $a0		# Store Network
	move $s1, $a1		# Store person
	move $s2, $a3		# Store prop_val (name of person)

	# Call str_equal to make sure prop_name is "NAME"c
	check_condition_1:
	la $a0, Name_prop
	move $a1, $a2		# prop_name (should be "NAME")
	jal str_equals
	bne $v0, $0, check_condition_2
	li $v0, 0
	j return_add_person_property
	
	# Call is_person_exists
	check_condition_2:
	move $a0, $s0
	move $a1, $s2
	jal is_person_exists
	bne $v0, $0, check_condition_3
	li $v0, -1
	j return_add_person_property
	
	# Call str_len to make sure prop_val is less than size of node
	check_condition_3:
	move $a0, $s2
	jal str_len
	lw $t0, 8($s0)		# Size of node from Network struct
	blt $v0, $t0, check_condition_4
	li $v0, -2
	j return_add_person_property
	
	# Loop through nodes array and use str_equals to make sure prop_val is unique
	check_condition_4:
	
	return_add_person_property:
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	addi $sp, $sp, 16
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
