Name: Jake Fulton
Pitt username: jkf31
This project was made in the MIPS assembly simulator MARS. To see and interact with the game display in MARS, select Tools from the top, then Keyboard and LED Display Simulator, then connect.
Macguffins are the pellets that the player collects to earn points.

The only 2 documents I wrote code in were main.asm and game.asm, although the vast majority is in game.asm.
In main.asm, I printed text telling the user to press a button to start the game, and detected if buttons were pressed, causing to jump and link to game.asm.
In the _game_while loop, handle_input is called, then update_blits is called, which updates the position of the player and enemies, without moving them into
walls. Next check_collisions is called. check_collisions first calls _check_enemy_player_collision, which checks if the player and any of the enemies are 
colliding and if necessary, updates the number of the player's lives and whether or not the player is invincible. Next, _check_macguffin_collision detects 
if the player or enemies collect any macguffins, updates the number of points if the player does get a macguffin, and removes the macguffins from the board
if they collide with anything. Next, draw_board loops through a matrix that stores the values of all of the elements in the board, and prints every empty
space and wall, then prints the player and enemies outside of the loop. Since I made the macguffins look different every other frame, draw_board switches 
the macguffins value in the matrix back and forth between 2 and 3. draw_bottom draws the background, score, and lives at the bottom of the screen.
The end of _game_while checks if x has been pressed, or the player ran out of lives, or if there are no more macguffins to collect. If none of these cases
activate, it jumps to the beginning of _game_while. If any of those cases do activate, it branches to _game_end, which does some printing and returns to
main.asm.

To accomplish some of these functions, I also created xy_to_rowcol, which outputs the row and column number in the board matrix of given x and y co-ordinates.
I also made calc_elem_addr, which finds the address of something in the board matrix given a row and column number.

To keep track of how long the player has been invincible (invincible_timer), and how many frames since the last time the enemies were allowed to move 
(enemy_clock), I decrement/increment positions in memory instead of using the frame counter from lab 6. 
This accomplishes the same goal since the counters are updated once every frame.

If you would like to slow down the enemies to make testing easier, on line 130 of game.asm, change 5 to a big number.

I did my best to make commments in main.asm and game.asm of what everything does, I hope they're helpful.
