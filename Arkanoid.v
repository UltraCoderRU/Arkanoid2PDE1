module Arkanoid

	`include "arkanoid_header.v"
	`include "int_to_digital.v"
	`include "vga_sync.v"

	task GameRestart;
	begin
		ball_x = FIELD_WIDTH/2;
		ball_y = FIELD_HEIGHT-1;
		ball_direction = RIGHT_UP;
		platform1_position = (FIELD_WIDTH-PLATFORM_WIDTH)/2; // central position
		platform2_position = platform1_position;
		game_state = 1'b1;
	end
	endtask

	// Main logic
	always @ (posedge clk25MHz)
	begin
				
		// Processing button presses

		if (button1 != button1_state)
		begin
			if (button1 == 1'b1)
			begin
				led_[7] = 1'b1;
				led_[6] = 1'b1;
				
				if (game_state == 1'b0)
					GameRestart;
				else if (platform1_position > 0)
					platform1_position = platform1_position - 1;
			end
			else
			begin
				led_[7] = 1'b0;
				led_[6] = 1'b0;
			end
			button1_state = button1;
		end
		
		if (button2 != button2_state)
		begin
			if (button2 == 1'b1)
			begin
				led_[5] = 1'b1;
				led_[4] = 1'b1;
				
				if (game_state == 1'b0)
					GameRestart;
				else if (platform1_position < FIELD_WIDTH-PLATFORM_WIDTH-1)
					platform1_position = platform1_position + 1;
			end
			else
			begin
				led_[5] = 1'b0;
				led_[4] = 1'b0;
			end
			button2_state = button2;
		end
		
		if (button3 != button3_state)
		begin
			if (button3 == 1'b1)
			begin
				led_[3] = 1'b1;
				led_[2] = 1'b1;
				
				if (game_state == 1'b0)
					GameRestart;
				else if (platform2_position > 0)
					platform2_position = platform2_position - 1;
			end
			else
			begin
				led_[3] = 1'b0;
				led_[2] = 1'b0;
			end
			button3_state = button3;
		end		
		
		if (button4 != button4_state)
		begin
			if (button4 == 1'b1)
			begin
				led_[1] = 1'b1;
				led_[0] = 1'b1;
				
				if (game_state == 1'b0)
					GameRestart;
				else if (platform2_position < FIELD_WIDTH-PLATFORM_WIDTH-1)
					platform2_position = platform2_position + 1;
			end
			else
			begin
				led_[1] = 1'b0;
				led_[0] = 1'b0;
			end 
			button4_state = button4;
		end
		
		
		// Update field (move platforms)
		for (i = 0; i < FIELD_WIDTH; i = i + 1)
		begin
			if ((i >= platform2_position) && (i <= platform2_position+PLATFORM_WIDTH))
				field[0][i] = PLATFORM_CELL;
			else
				field[0][i] = EMPTY_CELL;
			
			if ((i >= platform1_position) && (i <= platform1_position+PLATFORM_WIDTH))
				field[FIELD_HEIGHT-1][i] = PLATFORM_CELL;
			else
				field[FIELD_HEIGHT-1][i] = EMPTY_CELL;
		end	
		
		
		//Update field (move ball)
		if (game_state)
			if (ball_clock_counter < BALL_DELAY)
				ball_clock_counter = ball_clock_counter + 1;
			else
			begin
				ball_clock_counter = 0;
				
				field[ball_y][ball_x] = EMPTY_CELL;
				
				case (ball_direction)
					
					LEFT_UP:
					begin
					
						if ((ball_x > 0) && (ball_y > 1))
						begin
							ball_x = ball_x - 1;
							ball_y = ball_y - 1;
						end
						else if ((ball_x > 0) && (ball_y == 1))
							if ((ball_x >= platform2_position) && (ball_x <= platform2_position + PLATFORM_WIDTH))
							begin
								ball_direction = LEFT_DOWN;
								ball_x = ball_x - 1;
								ball_y = ball_y + 1;
							end
							else
							begin
								// Goal
								player1_score = player1_score + 1;
								game_state = 1'b0;
							end
											
						else if ((ball_x == 0) && (ball_y > 1))
						begin
							ball_direction = RIGHT_UP;
							ball_x = ball_x + 1;
							ball_y = ball_y - 1;
						end
						
						else
						begin
							ball_direction = RIGHT_DOWN;
							ball_x = ball_x + 1;
							ball_y = ball_y + 1;
						end

					end
					
					RIGHT_UP:
					begin
					
						if ((ball_x < FIELD_WIDTH-1) && (ball_y > 1))
						begin
							ball_x = ball_x + 1;
							ball_y = ball_y - 1;
						end
						else if ((ball_x < FIELD_WIDTH-1) && (ball_y == 1))
							if ((ball_x >= platform2_position) && (ball_x <= platform2_position + PLATFORM_WIDTH))
							begin
								ball_direction = RIGHT_DOWN;
								ball_x = ball_x + 1;
								ball_y = ball_y + 1;
							end
							else
							begin
								// Goal
								player1_score = player1_score + 1;
								game_state = 1'b0;
							end
											
						else if ((ball_x == FIELD_WIDTH-1) && (ball_y > 1))
						begin
							ball_direction = LEFT_UP;
							ball_x = ball_x - 1;
							ball_y = ball_y - 1;
						end
						
						else
						begin
							ball_direction = LEFT_DOWN;
							ball_x = ball_x - 1;
							ball_y = ball_y + 1;
						end
						
					end
					
					LEFT_DOWN:
					begin
					
						if ((ball_x > 0) && (ball_y < FIELD_HEIGHT-2))
						begin
							ball_x = ball_x - 1;
							ball_y = ball_y + 1;
						end
						else if ((ball_x > 0) && (ball_y == FIELD_HEIGHT-2))
							if ((ball_x >= platform1_position) && (ball_x <= platform1_position + PLATFORM_WIDTH))
							begin
								ball_direction = LEFT_UP;
								ball_x = ball_x - 1;
								ball_y = ball_y - 1;
							end
							else
							begin
								// Goal
								player2_score = player2_score + 1;
								game_state = 1'b0;
							end
											
						else if ((ball_x == 0) && (ball_y < FIELD_HEIGHT-2))
						begin
							ball_direction = RIGHT_DOWN;
							ball_x = ball_x + 1;
							ball_y = ball_y + 1;
						end
						
						else
						begin
							ball_direction = RIGHT_UP;
							ball_x = ball_x + 1;
							ball_y = ball_y - 1;
						end
									
					end
					
					RIGHT_DOWN:
					begin
					
						if ((ball_x < FIELD_WIDTH-1) && (ball_y < FIELD_HEIGHT-2))
						begin
							ball_x = ball_x + 1;
							ball_y = ball_y + 1;
						end
						else if ((ball_x < FIELD_WIDTH-1) && (ball_y == FIELD_HEIGHT-2))
							if ((ball_x >= platform1_position) && (ball_x <= platform1_position + PLATFORM_WIDTH))
							begin
								ball_direction = RIGHT_UP;
								ball_x = ball_x + 1;
								ball_y = ball_y - 1;
							end
							else
							begin
								// Goal
								player2_score = player2_score + 1;
								game_state = 1'b0;
							end
											
						else if ((ball_x == FIELD_WIDTH-1) && (ball_y < FIELD_HEIGHT-2))
						begin
							ball_direction = LEFT_DOWN;
							ball_x = ball_x - 1;
							ball_y = ball_y + 1;
						end
						
						else
						begin
							ball_direction = LEFT_UP;
							ball_x = ball_x - 1;
							ball_y = ball_y - 1;
						end
						
					end
					
				endcase
				
				if (game_state)
					field[ball_y][ball_x] = BALL_CELL;
				
			end
		
		
		// Update scores
		IntToDigital(player1_score, hex3_, hex2_);
		IntToDigital(player2_score, hex1_, hex0_);
		
		
		// VGA output
		h_cell = (h_counter-143)/CELL_SIZE;
		v_cell = (v_counter-34)/CELL_SIZE;
		if ((v_counter > 34) && (v_counter < 514) && (h_counter > 143) && (h_counter < 783))
		begin
			
			current_cell = field[v_cell][h_cell];
		
			case(current_cell)
				
				EMPTY_CELL: 
				begin
					red_ = BK_COLOR_R;
					green_ = BK_COLOR_G;
					blue_ = BK_COLOR_B;
				end
				
				STABLE_CELL:
				begin
					red_ = STABLE_COLOR_R;
					green_ = STABLE_COLOR_G;
					blue_ = STABLE_COLOR_B;
				end
				
				BALL_CELL:
				begin
					red_ = BALL_COLOR_R;
					green_ = BALL_COLOR_G;
					blue_ = BALL_COLOR_B;
				end
				
				PLATFORM_CELL:
				begin
					red_ = PLATFORM_COLOR_R;
					green_ = PLATFORM_COLOR_G;
					blue_ = PLATFORM_COLOR_B;
				end
				
			endcase
						
		end
		else
		begin
			red_ = 4'b0000;
			green_ = 4'b0000;
			blue_ = 4'b0000;
		end
		
	end
	
	
	// Initialization of all module variables
	initial
	begin
		
		game_state = 1'b0;
		
		// Reset scores
		player1_score = 0;
		player2_score = 0;
		
		// Place ball to the center of the screen
		ball_clock_counter = 0;
		ball_x = FIELD_WIDTH/2;
		ball_y = FIELD_HEIGHT-1;
		ball_direction = RIGHT_UP;
		
		// Place platforms at the center of the borders
		platform1_position = (FIELD_WIDTH-PLATFORM_WIDTH)/2; // central position
		platform2_position = platform1_position;
		
		// Clear field
		for (i = 0; i < FIELD_HEIGHT; i = i + 1)
			for (j = 0; j< FIELD_WIDTH; j = j + 1)
				field[i][j] = EMPTY_CELL;
		
		// Reset buttons state
		button1_state = 1'b0;
		button2_state = 1'b0;
		button3_state = 1'b0;
		button4_state = 1'b0;
				
		// Reset VGA counters
		h_counter = 0;
		v_counter = 0;

	end

	assign h_sync = ~((h_counter > 0) && (h_counter < 95));
	assign v_sync = ~((v_counter == 0) || (v_counter == 1));
	
	assign red = red_;
	assign green = green_;
	assign blue = blue_;
	
	assign hex0 = ~hex0_;
	assign hex1 = ~hex1_;
	assign hex2 = ~hex2_;
	assign hex3 = ~hex3_;
	
	assign led = ~led_;	
	
endmodule
