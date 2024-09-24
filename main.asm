#Jake Fulton jkf31
.include "macros.asm"
.globl main
.text
main:
	li	a0, 5
	li	a1, 5
	lstr	a2, "press any" 
	jal	display_draw_text #print the text
	li	a0, 5
	li	a1, 12
	lstr	a2, "button to" 
	jal	display_draw_text #print the text
	li a0, 16
	li a1, 19
	lstr	a2, "Start!" 
	jal	display_draw_text #print the text
	jal handle_input
	li t1, 1
	lw t0, up_pressed       #Check any buttons were pressed in order to start the game
	beq t0, t1, start_game
	lw t0, down_pressed
	beq t0, t1, start_game
	lw t0, left_pressed
	beq t0, t1, start_game
	lw t0, right_pressed
	beq t0, t1, start_game
	lw t0, b_pressed
	beq t0, t1, start_game
	lw t0, z_pressed
	beq t0, t1, start_game
	lw t0, x_pressed
	beq t0, t1, start_game
	lw t0, c_pressed
	beq t0, t1, start_game
	jal	display_update_and_clear
	jal	wait_for_next_frame
	j main
	
	start_game: #enter the game :D
		jal	game


	li	v0, 10
	syscall
