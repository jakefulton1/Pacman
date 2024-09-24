#Jake Fulton jkf31
.include "constants.asm"
.include "macros.asm"
.data
matrix: .byte 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1   #This matrix contains info on where every wall, empty space, and 
		.byte 1, 1, 0, 0, 2, 0, 2, 0, 2, 0, 1, 1	 #macguffin is on the board.
		.byte 1, 2, 0, 1, 0, 1, 1, 2, 1, 2, 0, 1
		.byte 1, 0, 1, 1, 2, 0, 2, 0, 1, 1, 2, 1
		.byte 1, 2, 0, 2, 0, 1, 1, 2, 0, 2, 0, 1
		.byte 1, 0, 1, 1, 2, 1, 1, 0, 1, 1, 2, 1
		.byte 1, 2, 1, 1, 0, 2, 0, 2, 1, 1, 0, 1
		.byte 1, 0, 2, 0, 2, 1, 1, 0, 2, 0, 2, 1
		.byte 1, 2, 1, 2, 1, 1, 1, 1, 0, 1, 0, 1
		.byte 1, 0, 2, 0, 2, 0, 2, 0, 2, 0, 0, 1
		.byte 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
wall:   .byte 8, 9, 8, 10, 9 #This is what a wall looks like
		.byte 9, 11, 8, 8, 9
		.byte 10, 10, 8, 8, 8
		.byte 9, 9, 9, 9, 8
		.byte 8, 8, 8, 11, 10
macguffin1:		.byte 5, 5, 5, 5, 5 #This is what a macguffin looks like every other pixel
				.byte 5, 5, 12, 5, 5
				.byte 5, 12, 4, 12, 5
				.byte 5, 5, 12, 5, 5
				.byte 5, 5, 5, 5, 5
macguffin2:		.byte 5, 5, 5, 5, 5 #This is what a macguffin looks like every other pixel
				.byte 5, 5, 4, 5, 5
				.byte 5, 4, 3, 4, 5
				.byte 5, 5, 4, 5, 5
				.byte 5, 5, 5, 5, 5
player:		.byte	5, 3, 3, 3, 13 #This is what the player looks like
			.byte	3, 3, 3, 13, 13
			.byte	3, 3, 13, 13, 13
			.byte	3, 3, 3, 13, 13
			.byte	5, 3, 3, 3, 13
enemy1:		.byte	5, 1, 1, 1, 5 #This is what enemy1 looks like
			.byte 	1, 0, 1, 0, 1
			.byte	1, 1, 1, 1, 1
			.byte	1, 1, 1, 1, 1
			.byte	1, 5, 1, 5, 1	
enemy2:		.byte	5, 2, 2, 2, 5 #This is what enemy2 looks like
			.byte 	2, 0, 2, 0, 2
			.byte	2, 2, 2, 2, 2
			.byte	2, 2, 2, 2, 2
			.byte	2, 5, 2, 5, 2
enemy3:		.byte	5, 7, 7, 7, 5 #This is what enemy3 looks like
			.byte 	7, 0, 7, 0, 7
			.byte	7, 7, 7, 7, 7
			.byte	7, 7, 7, 7, 7
			.byte	7, 5, 7, 5, 7
life:		.byte   9, 1, 9, 1, 9 #This is what the life symbol looks like
			.byte	1, 1, 1, 1, 1
			.byte	1, 1, 1, 1, 1
			.byte	9, 1, 1, 1, 9
			.byte	9, 9, 1, 9, 9
			
array_of_mobile_blits: .word 5, 45, 10, 5, 50, 10, 50, 45 #This array stores the x and y coords of the blits that move (player + 3 enemies in order)

is_invincible: .byte 0 #When this byte is 1, the player is invincible 

blink: .byte 0	#When this byte is 1, and the player is invincible, empty space will be printed instead of the player					
				#It will then be set to 0. 
				#If ((is_invincible == 1) && (blink == 0)) the player will be printed and blink will be set to 1
				#This process will make the player blink every other frame without using the frame counter from lab 6.

enemy_clock: .byte 0	#This byte is incremented every frame. When it reaches 5, the enemies' positions are updated,
						#and enemy_clock is set to 0. This way the enemies only move every 5 frames, without using the frame counter from lab 6. 	

invincible_timer: .word 200 #While the player is invincible, this byte is decremented every frame. Once it reaches 0,
				#the player stops being invincible. When the player becomes invincible, the clock is set to 200 frames.
				#This keeps track of time without using the frame counter from lab 6.				

points: .byte 0 #This increments when the player gets a macguffin

lives: .byte 3 #When this reaches 0, the game ends

macguffins_remaining: .byte 28 #When the game starts, there are 28 macguffins to get. 
								#When this reaches 0, the game ends
								
.globl game
.text
game:
	enter
	
_game_while:
	jal	handle_input
	# Move stuff
	jal update_blits
	jal check_collisions
	# Draw stuff
	li a0, -5 #These are the initial values for draw_board
	li a1, 0
	la a2, matrix
	sub a2, a2, 1
	jal draw_board
	jal draw_bottom
	# Must update the frame and wait
	jal	display_update_and_clear
	jal	wait_for_next_frame
	
	lw	t0, x_pressed
	bnez	t0, _game_end # Leave if x was pressed
	lb t0, lives
	beqz t0, _game_end 	# Leave if (lives == 0)
	lb t0, macguffins_remaining
	beqz t0, _game_end 	# Leave if (macguffins_remaining == 0)
	j	_game_while

_game_end:
	li a0, 20
	li a1, 25
	lstr a2, "Game"
	jal display_draw_text
	li a0, 21
	add a1, a1, 6
	lstr a2, "over!"
	jal display_draw_text
	jal draw_bottom
	li a0, 29
	li a1, 10
	la a2, player
	jal display_blit_5x5_trans
	jal	display_update
	leave

update_blits:
	enter a0
	jal _move_player #update the player's position
	lb s0, enemy_clock
	bne s0, 5, _skip_enemies #if (enemy_clock != 5) {_skip_enemies; (don't update the enemies' position)}
	sb zero, enemy_clock        #else {enemy_clock = 0}
	li a0, 1
	jal _move_enemy #update enemy1's position
	inc a0
	jal _move_enemy #update enemy2's position
	inc a0
	jal _move_enemy #update enemy3's position
	j _exit_update_blits
	
	_skip_enemies: 
		inc s0
		sb s0, enemy_clock
	
	_exit_update_blits:
		leave a0
	
	_move_player:
		enter a0, a1, s0, s1
		la t0, array_of_mobile_blits
		lw a0, 0(t0) #a0 now stores the x co-ordinate of the player
		lw a1, 4(t0) #a1 now stores the y co-ordinate of the player
		jal xy_to_rowcol #after xy_to rowcol, v0 holds the row number and v1 has the col number of the player in the board matrix
		move s0, a0
		move s1, a1
		move a0, v0
		move a1, v1
		jal calc_elem_addr #after calc_elem_addr, v0 holds the address of the player inside the board matrix
		lw t1, up_pressed				# check if up is being pressed
		beq t1, 1, _movep_up
		_done_up: #done updating the up direction, next check down
		la t0, array_of_mobile_blits #For the player, I call xy_to_rowcol and calc_elem_addr after each direction
		lw a0, 0(t0) 				  #because I want the player to be able to hold multiple keys at the same time and have 
		lw a1, 4(t0) 				  #them both take effect. If I don't update the player's position relative to the matrix
		jal xy_to_rowcol 			  #after each direction, and the player plays multiple keys, the wall collision will fail  
		move s0, a0					  #because it will have an inaccurate idea of where the player is.
		move s1, a1
		move a0, v0
		move a1, v1
		jal calc_elem_addr
		lw t1, down_pressed
		beq t1, 1, _movep_down
		_done_down: #done updating the down direction, next check left
		la t0, array_of_mobile_blits
		lw a0, 0(t0)
		lw a1, 4(t0) 
		jal xy_to_rowcol #updating the player's position again
		move s0, a0
		move s1, a1
		move a0, v0
		move a1, v1
		jal calc_elem_addr 
		lw t1, left_pressed
		beq t1, 1, _movep_left
		_done_left: #done updating the left direction, next check right
		la t0, array_of_mobile_blits
		lw a0, 0(t0) 
		lw a1, 4(t0) 
		jal xy_to_rowcol #updating the player's position again
		move s0, a0
		move s1, a1
		move a0, v0
		move a1, v1
		jal calc_elem_addr
		lw t1, right_pressed
		beq t1, 1, _movep_right
		j _exit_move_player #done updating all directions, exit _move_player
		_movep_up:
			li t5, 5
			div s1, t5 #Since the xy_to_row conversion was based on the top left pixel, the last check in _movep_up
			mfhi t0	   #will stop the player 4 pixels early from hitting a wall. To prevent this, I only stop the player
			bnez t0 _continue_up #if their y coord is a multiple of 5, and there's a wall above it.
			div s0, t5 #The player is centered if the top left corner has an x coord divisible by 5.
			mfhi t0 			 #If the player's x value is not centered in its path, 
			bnez t0, _done_up  #there will always be a wall above it, so it can't move up. My board doesn't have any 10 pixel wide vertical paths
			lb t0, -12(v0)
			beq t0, 1, _done_up #this makes sure the player doesn't move up into a wall if the row above in the matrix holds a wall
			_continue_up:
			dec s1
			la t0, array_of_mobile_blits 
			sw s1, 4(t0) #update the player's y value
			j _done_up
		_movep_down:
			li t5, 5
			div s0, t5 
			mfhi t0 			 #If the player's x value is not centered in its path, 
			bnez t0, _done_down  #there will always be a wall below it, so it can't move down. 
			lb t0, 12(v0)
			beq t0, 1, _done_down #this makes sure the player doesn't move down into a wall if the row below in the matrix holds a wall
			inc s1
			la t0, array_of_mobile_blits
			sw s1, 4(t0) #update the player's y value
			j _done_down 
		_movep_left:
			li t5, 5
			div s0, t5 #Since the xy_to_row conversion was based on the top left pixel, the last check in _movep_left
			mfhi t0	   #will stop the player 4 pixels early from hitting a wall. To prevent this, I only stop the player
			bnez t0 _continue_left #if their x coord is a multiple of 5, and there's a wall to the left of it.
			div s1, t5 #The player is centered if the top left corner has an y coord divisible by 5.
			mfhi t0 			 #If the player's y value is not centered in its path, 
			bnez t0, _done_left  #there will always be a wall to its left, so it can't move left. My board doesn't have any 10 pixel tall horizontal paths
			lb t0, -1(v0)
			beq t0, 1, _done_left #This makes sure the player doesn't move left into a wall if the column to the left in the matrix holds a wall
			_continue_left:
			dec s0
			la t0, array_of_mobile_blits
			sw s0, 0(t0) #update the player's x value
			j _done_left
		_movep_right:
			li t5, 5
			div s1, t5 #The player is centered if the top left corner has an y coord divisible by 5.
			mfhi t0 			 #If the player's y value is not centered in its path, 
			bnez t0, _exit_move_player  #there will always be a wall to its right, so it can't move right. 
			lb t0, 1(v0)
			beq t0, 1, _exit_move_player #This makes sure the player doesn't move right into a wall if the column to the right in the matrix holds a wall
			inc s0
			la t0, array_of_mobile_blits
			sw s0, 0(t0) #update the player's x value
			j _exit_move_player
		_exit_move_player:
			leave a0, a1, s0, s1
			
			
		_move_enemy:
			enter a0, a1, s0, s1, s6, s7
			li s6, 0 #I use s6 as a counter to see how many directions the enemy has tried
			la s0, array_of_mobile_blits
			beq a0, 1, _enemy1 #Depending on which enemy I'm moving, I initialize different values
			beq a0, 2, _enemy2
			beq a0, 3, _enemy3
			_enemy1:
				li s7, 8
				lw a0, 8(s0)
				lw a1, 12(s0)
				j _decide_direction_to_move
			_enemy2:
				li s7, 16
				lw a0, 16(s0)
				lw a1, 20(s0)
				j _decide_direction_to_move
			_enemy3:
				li s7, 24
				lw a0, 24(s0)
				lw a1, 28(s0)
				j _decide_direction_to_move
				
			_decide_direction_to_move:
				lw s1, 4(s0) #Now a0 and a1 hold the x and y co-ordinate of the enemy respectively
				lw s0, 0(s0) #and t0 and t1 hold the x and y co-ordinate of the player respectively
				sub t2, a0, s0
				abs t2, t2
				sub t3, a1, s1
				abs t3, t3						 #if (absolute value(enemyx-playerx) >= absolute value(enemyy-playery)
				bge t2, t3, _move_horizontally 	#move_horizontally();
				j _move_vertically				#else {move_vertically();}
			
				_move_horizontally: #a0, a1, s0, and s1 still have the x and y coords of the enemy and player respectively
				sub t0, a0, s0
				bgtz t0, _set_direction_left #if ((enemyx-playerx) > 0) {enemy is right of player, so move enemy left}
				j _set_direction_right       #else {move enemy right}
				_move_vertically:
				sub t0, a1, s1
				bgtz t0, _set_direction_up #if ((enemyy-playery) > 0) {enemy is below player, so move enemy up}
				j _set_direction_down		  #else {move enemy down}
				
				_set_direction_left:
					li a3, 0
					j _prepare_move
				_set_direction_right:
					li a3, 1
					j _prepare_move
				_set_direction_down:
					li a3, 2
					j _prepare_move
				_set_direction_up:
					li a3, 3
					j _prepare_move
			
			_prepare_move: #a0 and a1 still have the x and y coords of the enemy
				#This finds where the enemy is relative to the board matrix, just like when moving the player
				jal xy_to_rowcol #after xy_to rowcol, v0 holds the row number and v1 has the col number of the enemy in the board matrix
				move s0, a0
				move s1, a1
				move a0, v0
				move a1, v1
				jal calc_elem_addr #after calc_elem_addr, v0 holds the address of the enemy inside the board matrix
				beq a3, 0, _move_e_left	
				beq a3, 1, _move_e_right #Based on what direction was chosen earlier, it'll branch to the relevant subfunction 
				beq	a3, 2, _move_e_down
				beq a3, 3, _move_e_up
			
			_move_e_up: #this and the following 3 subfunctions are the same as the move_direction subfunctions in move_player
					#except that they save their values to a different offset in the array to update each enemy's position
			li t5, 5
			div s1, t5 #Since the xy_to_row conversion was based on the top left pixel, the last check in _move_e_up
			mfhi t0	   #will stop the enemy 4 pixels early from hitting a wall. To prevent this, I only stop the enemy
			bnez t0 _econtinue_up #if their y coord is a multiple of 5, and there's a wall above it.
			div s0, t5 #The enemy is centered if the top left corner has an x coord divisible by 5.
			mfhi t0 				    #If the enemy's x value is not centered in its path, 
			bnez t0, _try_different_direction  #there will always be a wall above it, so it can't move up. My board doesn't have any 10 pixel wide vertical paths
			lb t0, -12(v0)
			beq t0, 1, _try_different_direction #this makes sure the enemy doesn't move up into a wall if the row above in the matrix holds a wall
			_econtinue_up:
			dec s1
			la t0, array_of_mobile_blits 
			add t0, t0, s7
			sw s1, 4(t0) #update the enemy's y value
			j _exit_move_enemy
		_move_e_down:
			li t5, 5
			div s0, t5 
			mfhi t0 			 #If the enemy's x value is not centered in its path, 
			bnez t0, _try_different_direction  #there will always be a wall below it, so it can't move down. 
			lb t0, 12(v0)
			beq t0, 1, _try_different_direction #this makes sure the enemy doesn't move down into a wall if the row below in the matrix holds a wall
			inc s1
			la t0, array_of_mobile_blits
			add t0, t0, s7
			sw s1, 4(t0) #update the enemy's y value
			j _exit_move_enemy
		_move_e_left:
			li t5, 5
			div s0, t5 #Since the xy_to_row conversion was based on the top left pixel, the last check in _movee_left
			mfhi t0	   #will stop the enemy 4 pixels early from hitting a wall. To prevent this, I only stop the enemy
			bnez t0 _econtinue_left #if their x coord is a multiple of 5, and there's a wall to the left of it.
			div s1, t5 #The enemy is centered if the top left corner has an y coord divisible by 5.
			mfhi t0 			 #If the enemy's y value is not centered in its path, 
			bnez t0, _try_different_direction  #there will always be a wall to its left, so it can't move left. My board doesn't have any 10 pixel tall horizontal paths
			lb t0, -1(v0)
			beq t0, 1, _try_different_direction #This makes sure the enemy doesn't move left into a wall if the column to the left in the matrix holds a wall
			_econtinue_left:
			dec s0
			la t0, array_of_mobile_blits
			add t0, t0, s7
			sw s0, 0(t0) #update the enemy's x value
			j _exit_move_enemy
		_move_e_right:
			li t5, 5
			div s1, t5 #The enemy is centered if the top left corner has an y coord divisible by 5.
			mfhi t0 			 #If the enemy's y value is not centered in its path, 
			bnez t0, _try_different_direction  #there will always be a wall to its right, so it can't move right. 
			lb t0, 1(v0)
			beq t0, 1, _try_different_direction #This makes sure the enemy doesn't move right into a wall if the column to the right in the matrix holds a wall
			inc s0
			la t0, array_of_mobile_blits
			add t0, t0, s7
			sw s0, 0(t0) #update the enemy's x value
			j _exit_move_enemy
			
			_try_different_direction:
				la t0, array_of_mobile_blits 
				lw s1, 4(t0) 
				lw s0, 0(t0)
				add t0, s7, t0
				lw a0 0(t0)
				lw a1 4(t0)
				inc s6
				beq s6, 4, _exit_move_enemy #Once the enemy has tried all directions, it stops
				ble a3, 1, _move_vertically
				bge a3, 2, _move_horizontally
			
			_exit_move_enemy:
				leave a0, a1, s0, s1, s6, s7


check_collisions:
	enter
	jal _check_enemy_player_collision
	jal _check_macguffin_collision 
	leave
	
	_check_enemy_player_collision:
		la t0, array_of_mobile_blits
		lw t1, 0(t0) #player's x and y co-ordinates
		lw t2, 4(t0)
		lw t3, 8(t0) #enemy1's x and y co-ordinates
		lw t4, 12(t0)
		sub t6, t1, t3
		abs t6, t6
		li t5, 5
		blt t6, t5, _and1x 
		j _else1x
		_and1x:  #if ((abs(playerx - enemy1x) < 5) && (playery == enemyy)) {They collided}
			beq t2, t4, _hit
		_else1x: #else {keep checking for collisions}
		sub t6, t2, t4
		abs t6, t6
		blt t6, t5, _and1y 
		j _else1y
		_and1y:  #if ((abs(playery - enemy1y) < 5) && (playerx == enemy1x)){They collided}
			beq t1, t3, _hit
		_else1y: #else {keep checking for collisions}
		lw t3, 16(t0) #enemy2's x and y co-ordinates
		lw t4 20(t0) 
		sub t6, t1, t3
		abs t6, t6
	 	blt t6, t5, _and2x 
		j _else2x
		_and2x:  #if [(abs(playerx - enemy2x) && (playery == enemy2y) < 5) {They collided}
			beq t2, t4, _hit
		_else2x: #else {keep checking for collisions}
		sub t6, t2, t4
		abs t6, t6
		blt t6, t5, _and2y
		j _else2y
		_and2y:  #if ((abs(playery - enemy2y) < 5) && (playerx == enemy2x)) {They collided}
			beq t1, t3, _hit
		_else2y: #else {keep checking for collisions}
		lw t3, 24(t0) #enemy3's x and y co-ordinates
		lw t4, 28(t0)
		sub t6, t1, t3
		abs t6, t6
	 	blt t6, t5, _and3x 
		j _else3x
		_and3x:  #if [(abs(playerx - enemy3x) && (playery == enemy3y) < 5) {They collided}
			beq t2, t4, _hit
		_else3x: #else {keep checking for collisions}
		sub t6, t2, t4
		abs t6, t6
		blt t6, t5, _and3y
		j _else3y
		_and3y:  #if ((abs(playery - enemy3y) < 5) && (playerx == enemy3x)) {They collided}
			beq t1, t3, _hit
		_else3y: #else {no collisions found}
		jr ra
		
	_hit:
		lb t0, is_invincible
		bge t0, 1, _ignore_hit #Ignore the hit if the player is invincible
		inc t0
		sb t0, is_invincible #is_invincible = 1
		lb t0, lives
		dec t0
		sb t0, lives #lives = lives - 1;
		li t0, 200
		sb t0, invincible_timer #invincible_timer = 100,000 frames
		
		_ignore_hit:
		jr ra
	
	_check_macguffin_collision:
		enter
		li s0, 0 #I use s0 to keep track of which blit I'm checking for macguffin_collisions
		push s0
		la t0, array_of_mobile_blits
		lw a0, 0(t0) #load x and y co-ordinates of top left pixel of player
		lw a1, 4(t0)
		_check_if_blit_got_macguffin:
			add a0, a0, 2 #add 2 to both to get middle of the blit
			add a1, a1, 2 #(instead of adjusting for having the top left like I did when checking for walls)
			jal xy_to_rowcol #after xy_to_rowcol, v0 has the row number and v1 has the column number
			move a0, v0
			move a1, v1
			jal calc_elem_addr #after calc_elem_addr, v0 has the address where the blit is in the board matrix
			lb t0, 0(v0)
			li t1, 2
			blt t0, t1, _next_blit #if (board[player's address] < 2) {blit didn't get a macguffin, }
			j _blit_got_macguffin	#else {blit_got_macguffin}
		
		_next_blit:
			pop s0
			beq s0, 3, _exit_check_macguffin_collision
			inc s0
			push s0
			la t0, array_of_mobile_blits
			mul t1, s0, 8 #the co-ords have a different offset in array_of_mobile_blits depending on which blit they are
			add t0, t0, t1
			lw a0, 0(t0)
			lw a1, 4(t0)
			j _check_if_blit_got_macguffin
			
		_blit_got_macguffin:
			lb t0, macguffins_remaining
			dec t0
			sb t0, macguffins_remaining #update the number of macguffins remaining
			pop s0
			bnez s0, _remove_macguffin #if (s0 != 0) {the blit that got a macguffin is an enemy} 
			lb t0, points			   #else {the blit that got a macguffin is the player, so inc points}
			inc t0 
			sb t0, points #update the point value
			_remove_macguffin:
				sb zero, 0(v0) #store 0 where the macguffin was in the board matrix
			push s0
			j _next_blit
				
		_exit_check_macguffin_collision:	
		leave				


draw_board:
	enter a0, a1, a2, a3 #gonna store the x position in a0, y position in a1, address of element in a2
	_loop_x:
		bge a0, 55, _inc_y
		add a0, a0, 5
		add a2, a2, 1
		lb t0, 0(a2)
		beqz t0, _draw_empty
		beq t0, 1, _draw_wall
		beq t0, 2, _draw_mac1
		beq t0, 3, _draw_mac2
	_inc_y:
		bge a1, 50, _draw_blits
		add a1, a1, 5
		li a0, -5
		j _loop_x
		
	_draw_empty:
		push a0
		push a1
		push a2
		li a2, 5
		li a3, 5
		li v1, 5
		jal display_fill_rect
		pop a2
		pop a1
		pop a0
		j _loop_x
		
	_draw_wall:
		push a0
		push a1
		push a2
		la a2, wall
		jal display_blit_5x5
		pop a2
		pop a1
		pop a0
		j _loop_x
		
	_draw_mac1: #display_blit_5x5(x coordinate, y coordinate, reference to macguffin1 matrix);
		push a0
		push a1
		push a2
		la a2, macguffin1
		jal display_blit_5x5
		pop a2
		pop a1
		pop a0
		li t0, 3
		sb t0, 0(a2) #currentMacguffinPhase = mac2
		j _loop_x
		
	_draw_mac2: #display_blit_5x5(x coordinate, y coordinate, reference to macguffin1 matrix);
		push a0
		push a1
		push a2
		la a2, macguffin2
		jal display_blit_5x5
		pop a2
		pop a1
		pop a0
		li t0, 2
		sb t0, 0(a2) #currentMacguffinPhase = mac1
		j _loop_x
	_draw_blits: #Draw the player and enemies then exit draw_board
		la s0, array_of_mobile_blits
		lw a0, 0(s0)
		lw a1, 4(s0)
		la a2 player
		lb t0, is_invincible
		bgtz t0, _blink_player #if (is_invincible == true) {_blink_player}
		j _dont_blink_player    #else {_dont_blink_player}
		_blink_player:
			lw t0, invincible_timer
			dec t0						#decrement invincible_timer
			sw t0, invincible_timer 	#update timer value
			beqz t0, _end_invincibility
			lb t0, blink
			bgtz, t0, _disappear
			li t0, 1
			sb t0, blink 
			j _dont_blink_player
		_end_invincibility:
			sb zero, is_invincible
			sb zero, blink
			j _dont_blink_player
			_disappear: #only print empty space over player if ((is_invincible == 1) && (blink == 1))
				li a2, 5
				li a3, 5
				li v1, 5
				jal display_fill_rect
				li t0, 0
				sb t0, blink
				j _done_disappearing
		_dont_blink_player:
		jal display_blit_5x5 #display_blit_5x5(x coord, y coord, ref to player matrix);
		_done_disappearing:
		lw a0, 8(s0)
		lw a1, 12(s0)
		la a2, enemy1
		jal display_blit_5x5 #display_blit_5x5(x coord, y coord, ref to enemy1 matrix);
		lw a0, 16(s0)
		lw a1, 20(s0)
		la a2, enemy2
		jal display_blit_5x5 #display_blit_5x5(x coord, y coord, ref to enemy1 matrix);
		lw a0, 24(s0)
		lw a1, 28(s0)
		la a2, enemy3
		jal display_blit_5x5 #display_blit_5x5(x coord, y coord, ref to enemy1 matrix);
		j _exit_draw_board
		
	_exit_draw_board:	
		leave a0, a1, a2, a3
		
draw_bottom:
	enter
	li a0, 0
	li a1, 55
	li a2, 60
	li a3, 9
	li v1, 9
	jal display_fill_rect #print the background
	li	a0, 3
	li	a1, 57
	lstr	a2, "PTS:" 
	jal	display_draw_text #print the text
	li a0, 25
	li a1, 57
	lb a2, points
	jal display_draw_int #print the number of points
	lb s0, lives
	beqz s0, _done_printing_lives
	push s0
	li a0, 38
	li a1, 57
	la a2, life
	jal display_blit_5x5_trans
	pop s0
	beq s0, 1, _done_printing_lives
	add a0, a0, 6
	push s0
	jal display_blit_5x5_trans
	pop s0
	beq s0, 2, _done_printing_lives
	add a0, a0, 6
	push s0
	jal display_blit_5x5_trans
	pop s0
	_done_printing_lives:
	leave
	

xy_to_rowcol: #a0 contains the x co-ordinate, a1 has the y co-ordinate, 
#v0 will contain the row number, and v1 will have the column number of the x and y relative to the board matrix.
		enter a0, a1
		bge a1, 45, _row9
		bge a1, 40, _row8
		bge a1, 35, _row7
		bge a1, 30, _row6
		bge a1, 25, _row5
		bge a1, 20, _row4
		bge a1, 15, _row3
		bge a1, 10, _row2
		j _row1
			_row1:
				li v0, 1
				j _find_col_number
			_row2:
				li v0, 2
				j _find_col_number
			_row3:
				li v0, 3
				j _find_col_number
			_row4:
				li v0, 4
				j _find_col_number
			_row5:
				li v0, 5
				j _find_col_number
			_row6:
				li v0, 6
				j _find_col_number
			_row7:
				li v0, 7
				j _find_col_number
			_row8:
				li v0, 8
				j _find_col_number
			_row9:
				li v0, 9
				j _find_col_number
		_find_col_number:
			bge a0, 50, _col10
			bge a0, 45, _col9
			bge a0, 40, _col8
			bge a0, 35, _col7
			bge a0, 30, _col6
			bge a0, 25, _col5
			bge a0, 20, _col4
			bge a0, 15, _col3
			bge a0, 10, _col2
			j _col1
				_col1:
					li v1, 1
					j _end_xy_to_rowcol
				_col2:
					li v1, 2
					j _end_xy_to_rowcol
				_col3:
					li v1, 3
					j _end_xy_to_rowcol
				_col4:
					li v1, 4
					j _end_xy_to_rowcol
				_col5:
					li v1, 5
					j _end_xy_to_rowcol
				_col6:
					li v1, 6
					j _end_xy_to_rowcol
				_col7:
					li v1, 7
					j _end_xy_to_rowcol
				_col8:
					li v1, 8
					j _end_xy_to_rowcol
				_col9:
					li v1, 9
					j _end_xy_to_rowcol
				_col10:
					li v1, 10
					j _end_xy_to_rowcol
		_end_xy_to_rowcol:
			leave a0, a1
calc_elem_addr: #This function finds the address of an element given a row number (a0) and a column number (a1)
	enter a0, a1
	move v0, zero
	la t0, matrix
	mul v0, a0, 12 #row address = [(row index) * (size of each row(1 byte * 12 columns = 12 bytes))] + (matrix address)
	add v0, v0, t0
	add v0, v0, a1  #element address = [column index * 1 byte] + row address
	leave a0, a1
