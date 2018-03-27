	.text

# slide ($a0. $a1, $a2)
#	return ($v0, $v1, $k0)
slide:
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s6, 12($sp)
	lw $s7, 16($sp)
	lw $s4, 20($sp)
	addi $sp, $sp, 24

	addi $s0, $a0, 0 # read registers
	addi $s1, $a1, 0

	addi $s6, $s6, 0 # rotations before slide
	addi $s7, $s7, 0 # rotations after slide

	addi $s4, $s4, 0 # win flag

	beq  $a2, 0, slide_right
	beq  $a2, 1, slide_left
	beq  $a2, 2, slide_up
	beq  $a2, 3, slide_down

slide_right:
	addi $s6, $s6, 0
	addi $s7, $s7, 0
	j slide_before

slide_left:
	addi $s6, $s6, 2
	addi $s7, $s7, 2
	j slide_before

slide_up:
	addi $s6, $s6, 1
	addi $s7, $s7, 3
	j slide_before

slide_down:
	addi $s6, $s6, 3
	addi $s7, $s7, 1
	j slide_before

slide_before:
	beq $s6, 0, slide_doslide
	addi $s6, $s6, -1
	jal rotate
	addi $a0, $v0, 0
	addi $a1, $v1, 0
	j slide_before

slide_doslide:
	jal slideRightTable
	addi $a0, $v0, 0
	addi $a1, $v1, 0
	addi $s4, $k0, 0

slide_after:
	beq $s7, 0, slide_r
	addi $s7, $s7, -1
	jal rotate
	addi $a0, $v0, 0
	addi $a1, $v1, 0
	j slide_after

slide_r:
	addi $k0, $s4, 0
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s6, 12($sp)
	lw $s7, 16($sp)
	lw $s4, 20($sp)
	addi $sp, $sp, 24

	jr   $ra


# Take a 4x4 array as input and rotates it clockwise
# rotate ($a0, $a1):
#	return ($v0, $v1)
rotate:
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	addi $sp, $sp, 20

	add  $s0, $a0, $zero  # write registers
	add  $s1, $a1, $zero
	add  $s2, $a0, $zero  # read registers
	add  $s3, $a1, $zero

        andi $a0, $s2, 0xff
        andi $a1, $s2, 0xff0000
        jal rotateRight4
        andi $s1, $s1, 0xff00ff00
        or   $a0, $a0, $a1
        or   $s1, $s1, $a0

        andi $a0, $s3, 0xff
        andi $a1, $s3, 0xff0000
        jal rotateRight4
        andi $s1, $s1, 0x00ff00ff
        or   $a0, $a0, $a1
        or   $s1, $s1, $a0


        andi $a0, $s3, 0xff00
        andi $a1, $s3, 0xff000000
        jal rotateRight4
        andi $s0, $s0, 0x00ff00ff
        or   $a0, $a0, $a1
        or   $s0, $s0, $a0

        andi $a0, $s2, 0xff00
        andi $a1, $s2, 0xff000000
        jal rotateRight4
        andi $s0, $s0, 0xff00ff00
        or   $a0, $a0, $a1
        or   $s0, $s0, $a0

        lw $, 0($sp)
        addi $sp, $sp, 4

	jr $ra


# Takes a 2x2 array as an input and rotates right (clock-wise).
# rotateRight4 ($a0, $a1):
#	return ($v0, $v1)
rotateRight4:
	andi $t0, $a0, 0xf
	srl  $a0, $a0, 4
	andi $t1, $a1, 0xf0
	sll  $a1, $a1, 4

	andi $a1, $a1, 0xff
	add  $a1, $a1, $t0

	sll  $t1, $t1, 4
	add  $a0, $a0, $t1
	addi $v0, $a0, 0
	addi $v1, $a1, 0
	jr $ra


# Takes an array as input and slides it right
# slideRightTable ($a0, $a1):
#	return ($v0, $v1, $k0)
# !! $k0 must change and its content should be pushed to stack instead !!
slideRightTable:
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	lw $s5, 20($sp)
	lw $s4, 24($sp)
	addi $sp, $sp, 28

	addi $s0, $a0, 0   # write
	addi $s1, $a1, 0
	addi $s2, $a0, 0   # read
	addi $s3, $a1, 0

	addi $s5, $zero, 0   # win flag

	addi $s4, $zero, 2   # loop counter
slideRightTable_s2:
	beq  $s4, -1, slideRightTable_s3
	addi $s4, $s4, -1
	addi $a0, $s2, 0
	addi $a1, $s4, 0
	jal slideRightRow
	sll  $s0, $s0, 16
	or   $s0, $s0, $v0
	add  $s5, $s5, $v1
	j slideRightTable_s2

	addi $s4, $zero, 2
slideRightTable_s3:
	beq  $s4, -1, slideRightTable_r
	addi $s4, $s4, -1
	addi $a0, $s3, 0
	addi $a1, $s4, 0
	jal slideRightRow
	sll  $s1, $s1, 16
	or   $s1, $s1, $v0
	add  $s5, $s5, $v1
	j slideRightTable_s3

slideRightTable_r:
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	lw $s5, 20($sp)
	lw $s4, 24($sp)
	addi $sp, $sp, 28

	addi $v0, $s0, 0
	addi $v1, $s1, 0
	addi $k0, $s5, 0


# Takes a line and slides it right.
# slideRight ($a0, $a1):
#	$a0: the row
#	$a1:	1 if no shift needed
#		0 if 16-bit shift needed
#	return ($v0, $v1)
#		$v0 : the line slided right
#               $v1 : if there is a winner
slideRightRow:
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	lw $s4, 20($sp)
	addi $sp, $sp, 24

	jal removeBlankRight

	bne  $a1, 1, slideRightRow_noshift
	srl  $a0, $a0, 16

slideRightRow_noshift:
	andi $a0, $a0, 0xffff # apply mask to the line
	addi $s0, $v0,   0    # $s0 = line with non blank cells
	addi $s1, $v1,  -1    # loop counter, number of comparisons
	addi $s2, $zero, 0    # the under-construction line
	addi $s3, $zero, 0    # the line-shift merge counter
	addi $s4, $zero, 0

slideRightRow_l1:
	beq  $s1, 0, slideRightRow_r
	addi $s1, $s1, -1

	srl  $t3, $s0, 0
	srl  $t4, $s0, 4
	srl  $s0, $s0, 4
	andi $t3, $t3, 15
	andi $t4, $t4, 15

	addi $a0, $t4, 0
	addi $a1, $t3, 0
	jal addCells

	beq  $v1, 1, slideRightRow_merge
	j slideRightRow_l1

slideRightRow_merge:
	sllv $v0, $v0, $s3
	addi $s3, $s3, 4
	bge  $v0, 11, slideRightRow_win
	add  $s2, $s2, $v0
	j slideRightRow_l1

slideRightRow_win:
	addi $s4, $zero, 1
	j slideRightRow_l1

slideRightRow_r:
	lw $ra, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	addi $sp, $sp, 20

	addi $v0, $s2, 0
	addi $v1, $s4, 0
	jr $ra


# Checks if the given cells are equal and if they are it returns the sum.
# addCells ($a0, $a1):
#	return ($v0, $v1)
#		$v0 : the sum ($v1 should be checked first)
#		$v1 : if cells where equal
addCells:
	sub  $t0, $a0, $a1
	beq  $t0, 0, addCells_equal
	addi $v0, $zero, 0
	addi $v1, $zero, 0
	jr $ra

addCells_equal:
	add  $v0, $a0, $a1
	addi $v1, $zero, 1
	jr $ra


# Removes blank cells if exist and slides to the line to the right
# removeBlankCellsRight ($a0):
#	return ($v0, $v1)
#		$v0 : $a0 without blank cells, idented right
#		$v1 : number of non blank cells in the line
removeBlankRight:
	addi $t1, $zero, 4      # the loop counter (we have 4 cells)
	addi $t2, $a0, 0        # t3 = a0
	addi $t4, $zero, 0      # merge shift left counter
	addi $v1, $zero, 0      # format $v1

removeBlankRight_l1:
	beq  $t1, 0, removeBlankRight_r
	subi $t1, $t1, 1

	addi $t3, $t2, 0
	srl  $t2, $t2, 4
	andi $t3, $t3, 15       # Masks all 32-bits except for the first 4
	bne  $t3, $zero, removeBlankRight_merge
	j removeBlankRight_l1

removeBlankRight_merge:
	sllv $t3, $t3, $t4
	addi $t4, $t4, 4
	add  $v0, $v0, $t3
	j removeBlankRight_l1

removeBlankRight_r:
	beq  $t4, 0, removeBlankRight_r1
	sra  $v1, $t4, 2
removeBlankRight_r1:
	jr $ra
