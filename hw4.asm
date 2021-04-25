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
	li $v0, 0	# Track amount of characters copied
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
		move $v1, $s0		# Reference to person in Network
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

	# Call str_equal to make sure prop_name is "NAME"
	check_condition_1:
	addi $a0, $s0, 24	# "NAME" in Network instance
	move $a1, $a2		# prop_name (should be "NAME")
	jal str_equals
	bne $v0, $0, check_condition_2
	li $v0, 0
	j return_add_person_property
	
	# Call is_person_exists
	check_condition_2:
	move $a0, $s0
	move $a1, $s1
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
	
	# Check that the person's name doesn't already exist in the network
	check_condition_4:
	move $a0, $s0
	move $a1, $s2
	jal is_person_name_exists
	beq $v0, $0, addNameProperty
	li $v0, -3
	j return_add_person_property
	
	# All conditions have been passed, call str_cpy
	addNameProperty:
	move $a0, $s2		# src
	move $a1, $s1		# dest
	jal str_cpy
	li $v0, 1
	
	return_add_person_property:
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	addi $sp, $sp, 16
	jr $ra
	
# The exact same function as from part 6?
get_person:
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	jal is_person_name_exists
	beq $v0, $0, return_get_person
	move $v0, $v1	# Since $v1 from part 6 returns the address of the Person node

	return_get_person:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
is_relation_exists:
	li $v0, 0		# Assume no relation exists at first
	lw $t0, 12($a0)		# Size of edge
	lw $t1, 20($a0)		# Current amount of edges, use as loop counter
	beq $t1, $0, return_is_relation_exists
	beq $a1, $a2, return_is_relation_exists		# A person can't be related to itself
	
	li $v0, 1		# Now assume relation exists
	# Now find out how large the nodes array is to skip past it	
	lw $t2, 8($a0)		# Size of node
	lw $t3, 0($a0)		# Total amount of nodes
	mult $t2, $t3
	mflo $t2
	addi $a0, $a0, 36	# First increment Network address by 36 to reach nodes array
	add $a0, $a0, $t2
	# Find next multiple of 4 as that is where edges array resides (current location is possible)
	addi $a0, $a0, 3
	li $t2, 4
	div $a0, $t2
	mflo $a0
	mult $a0, $t2
	mflo $a0
	
	check_relation_loop:
		lw $t2, 0($a0)			# Person node 1
		lw $t3, 4($a0)			# Person node 2
		check_person_1:
		beq $a1, $t2, check_person_2
		beq $a1, $t3, check_person_2
		# Input person 1 is equal to neither people in the edge
		j advance_relation_loop
		
		check_person_2:
		beq $a2, $t2, return_is_relation_exists
		beq $a2, $t3, return_is_relation_exists
		# Input person 2 is equal to neither people in the edge, advance loop
		
		advance_relation_loop:
		addi $t1, $t1, -1
		add $a0, $a0, $t0
		move $v1, $a0			# Update the current edge I'm iterating through
		bne $t1, $0, check_relation_loop
		
	li $v0, 0
	return_is_relation_exists:
	jr $ra
	
add_relation:
	addi $sp, $sp, -16
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	move $s0, $a0		# Store Network
	move $s1, $a1		# Store person 1
	move $s2, $a2		# Store person 2
	
	li $v0, 0
	# Call is_person_exists on both person1 and person2
	check_condition_1_rel:
	jal is_person_exists 	# $a0 already contains Network, $a1 already contains person 1
	beq $v0, $0, return_add_relation
	# =====
	move $a0, $s0
	move $a1, $s2
	jal is_person_exists
	beq $v0, $0, return_add_relation
	
	# Check if network is at capacity for edges
	check_condition_2_rel:
	lw $t0, 4($s0)		# Total edges
	lw $t1, 20($s0)		# Current amount of edges
	blt $t1, $t0, check_condition_3_rel
	
	# No edges available
	li $v0, -1
	j return_add_relation
	
	# Call is_relation_exists to make sure all relations are unique
	check_condition_3_rel:
	move $a0, $s0
	move $a1, $s1
	move $a2, $s2
	jal is_relation_exists
	beq $v0, $0, check_condition_4_rel
	li $v0, -2
	j return_add_relation
	
	# Check if person1 == person2
	check_condition_4_rel:
	li $v0, -3		# Assume return value is -3
	beq $s1, $s2, return_add_relation
	
	# =====
	
	# Find amount of bytes needed to skip past nodes array
	lw $t0, 0($s0)		# Load total amount of nodes
	lw $t1, 8($s0)		# Load size of node
	mult $t0, $t1
	mflo $t0
	
	# Find amount of bytes needed to skip to next open spot in edges array
	lw $t1, 20($s0)		# Load current amount of edges
	lw $t2, 12($s0)		# Load size of edge
	mult $t1, $t2
	mflo $t2
	
	# Increment current amount of edges
	addi $t1, $t1, 1
	sw $t1, 20($s0)
	
	addi $s0, $s0, 36
	add $s0, $s0, $t0
	# Find next multiple of 4 as that is where edges array resides (current location is possible)
	addi $s0, $s0, 3
	li $t0, 4
	div $s0, $t0
	mflo $s0
	mult $s0, $t0
	mflo $s0
	
	add $s0, $s0, $t2	# Skip to next open spot in edges array
	sw $s1, 0($s0)
	sw $s2, 4($s0)
	sw $0, 8($s0)
	li $v0, 1

	return_add_relation:
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	addi $sp, $sp, 16
	jr $ra
	
add_relation_property:
	lw $t0, 0($sp)		# Get 5th argument - prop_value

	addi $sp, $sp, -28
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	sw $s4, 20($sp)
	sw $s5, 24($sp)
	move $s0, $a0		# Store Network
	move $s1, $a1		# Store person 1
	move $s2, $a2		# Store person 2
	move $s3, $a3		# Store prop_name (should be "FRIEND")
	move $s4, $t0		# Store prop_value

	# Call is_relation_exists 
	check_condition_1_prop:
	jal is_relation_exists		# $a0, $a1, $a2 already have the required args
	move $s5, $v1			# is_relation_exists returns relevant edge's address
	
	bne $v0, $0, check_condition_2_prop	
	li $v0, 0
	j return_add_relation_property
	
	# Call str_equals to see if the prop_name string is "FRIEND"
	check_condition_2_prop:	
	move $a0, $s3
	addi $a1, $s0, 29
	jal str_equals
	bne $v0, $0, check_condition_3_prop
	li $v0, -1
	j return_add_relation_property
	
	# Make sure prop_value is >= 0
	check_condition_3_prop:
	li $v0, -2		# Assume prop_val < 0 first
	blt $s4, $0, return_add_relation_property
	
	# All conditions passed
	sw $s4, 8($s5)		# Store prop_value into bytes 8-11 of edge
	li $v0, 1

	return_add_relation_property:
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	lw $s4, 20($sp)
	lw $s5, 24($sp)
	addi $sp, $sp, 28
	jr $ra
	
is_friend_of_friend:
	addi $sp, $sp, -32
	sw $ra, 0($sp)
	sw $s0, 4($sp)			# Store Network
	sw $s1, 8($sp)			# Store name2 argument at first, address of person1 later
	sw $s2, 12($sp)			# Store address of person2
	sw $s3, 16($sp)			# Store current amount of edges
	sw $s4, 20($sp)			# Store Network again for method calls without being afraid of changes
	sw $s5, 24($sp)			# Store first person of current edge
	sw $s6, 28($sp)			# Store second person of current edge
	move $s0, $a0			
	move $s1, $a2	
	move $s4, $a0					
	
	# Make sure first person is in the network ($a0 already contains Network, $a1 name1)
	check_first_person:
	jal get_person			# Don't store person 1's address *just yet*
	bne $v0, $0, check_second_person
	li $v0, -1
	j return_is_friend_of_friend

	# Make sure second person is in the network
	check_second_person:
	move $a0, $s0
	move $a1, $s1
	move $s1, $v0			# Now $s1 (name2) is used, I can replace it with address of person1
	jal get_person
	move $s2, $v0			# Store person 2's address (if they exist in the Network)
	bne $v0, $0, isFOF
	li $v0, -1
	j return_is_friend_of_friend
	
	isFOF:
	# Call is_relation_exists to make sure person1 and person2 are not friends directly
	move $a0, $s0
	move $a1, $s1
	move $a2, $s2
	jal is_relation_exists	
	beq $v0, $0, notDirectFriends
	# If friend attribute is 0, that is still valid
	lw $t0, 8($v1)			# is_relation_exists returns relevant edge, get bytes 8-11
	
	beq $t0, $0, notDirectFriends
	li $v0, 0	
	j return_is_friend_of_friend
	
	# 1. Loop through finding each friendship involving Person 1
	     # Note: skip if it's a relationship involving both Person 1 and Person 2
	# 2. Uses is_relation_exists to check if relation (subsequently) friendship
	#    exists between Person 2 and the friend of Person 1
	notDirectFriends:
	lw $s3, 20($s0)			# Store curr_edges, used as loop counter
	# Get to edges array in Network	
	addi $s4, $s4, 36
	lw $t0, 8($s0)			# Size of node
	lw $t1, 0($s0)			# Total nodes
	mult $t0, $t1
	mflo $t0	
	add $s4, $s4, $t0
	# Find next multiple of 4 as that is where edges array resides (current location is possible)
	addi $s4, $s4, 3
	li $t0, 4
	div $s4, $t0
	mflo $s4
	mult $s4, $t0
	mflo $s4
	FOF_loop:
		lw $t0, 8($s4)		# Check if a friendship even exists
		beq $t0, $0, advance_FOF_loop
		lw $s5, 0($s4)		# Load person 1 in edge
		lw $s6, 4($s4)		# Load person 2 in edge
		beq $s5, $s1, person1RelFound
		beq $s6, $s1, person1RelFound
		j advance_FOF_loop
		
		person1RelFound:
		# Make sure person 2 isn't the other
		beq $s5, $s2, advance_FOF_loop
		beq $s6, $s2, advance_FOF_loop		
		
		beq $s5, $s1, friend_of_person_1_is_s6
			# Don't know which of the pair is person 1 and which is the friend of person 1
			friend_of_person_1_is_s5:
			# Call is_relation_exists with friend of person 1 and person 2
			move $a0, $s0
			move $a1, $s2
			move $a2, $s5
			jal is_relation_exists
			beq $v0, $0, advance_FOF_loop
			# Relation does exist, now check if their friendship attribute is 1
			lw $t0, 8($v1)		# Since $v1 from is_relation_exists returns edge address
			beq $t0, $0, advance_FOF_loop
			# Is indeed a friend of friend!
			li $v0, 1
			j return_is_friend_of_friend
			
			friend_of_person_1_is_s6:
			# Call is_relation_exists with friend of person 1 and person 2
			move $a0, $s0
			move $a1, $s2
			move $a2, $s6
			jal is_relation_exists
			beq $v0, $0, advance_FOF_loop
			# Relation does exist, now check if their friendship attribute is 1
			lw $t0, 8($v1)		# Since $v1 from is_relation_exists returns edge address
			beq $t0, $0, advance_FOF_loop
			# Is indeed a friend of friend!
			li $v0, 1
			j return_is_friend_of_friend
			
	
		advance_FOF_loop:
		addi $s3, $s3, -1
		bne $s3, $0, FOF_loop

	li $v0, 0				# Not a friend of friend
	return_is_friend_of_friend:
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	sw $s4, 20($sp)
	sw $s5, 24($sp)
	sw $s6, 28($sp)
	addi $sp, $sp, 32
	jr $ra
