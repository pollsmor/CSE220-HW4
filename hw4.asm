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
