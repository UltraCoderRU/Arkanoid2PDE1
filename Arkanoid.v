module Arkanoid

#(
	// Parameters
	parameter SCREEN_WIDTH = 640,       // Horizontal screen resolution (in pixels)
	parameter SCREEN_HEIGHT = 480,      // Vertical screen resolution (in pixels)
	
	parameter CELL_SIZE = 20,           // 1 cell has size of 20x20 pixels.
	
	parameter BALL_SIZE = 1,            // Game ball is a square of side 1 cell
	parameter BALL_SPEED = 2,           // Number of cells per second
	
	parameter PLATFORM_WIDTH = 8,       // Game platform width
	parameter PLATFORM_SPEED = 1,       // Number of cells per second
	
	parameter [3:0] BK_COLOR_R = 4'b1111,       // Red background
	parameter [3:0] BK_COLOR_G = 4'b0000,
	parameter [3:0] BK_COLOR_B = 4'b0000,
	
	parameter [3:0] STABLE_COLOR_R = 4'b0011,  // ??? color :)
	parameter [3:0] STABLE_COLOR_G = 4'b1100,
	parameter [3:0] STABLE_COLOR_B = 4'b0110,
	
	parameter [3:0] BALL_COLOR_R = 4'b0000,     // Blue ball
	parameter [3:0] BALL_COLOR_G = 4'b0000,
	parameter [3:0] BALL_COLOR_B = 4'b1111,
	
	parameter [3:0] PLATFORM_COLOR_R = 4'b1111, // Red platforms
	parameter [3:0] PLATFORM_COLOR_G = 4'b0000,
	parameter [3:0] PLATFORM_COLOR_B = 4'b0000
)

(
	// Input Ports
	input clk50MHz, // 50 MHz clock on DE1
	input button1, button2, button3, button4, // 4 buttons on DE1 (left<->right for 2 players)

	// Output Ports
	output h_sync,
	output v_sync,
	output [3:0] red, green, blue, // Current pixel color (4096 colors = 12 bit)
	output [6:0] num1, num2, num3, num4, // Digital LED's on DE1
	output [7:0] led
);
	
	//////////////////////////////////////
	// **** BEGIN OF MODULE HEADER **** //
	//////////////////////////////////////
	
	// Output registers
	reg [3:0] red_, green_, blue_;
	reg [6:0] num1_, num2_, num3_, num4_;
	reg [7:0] led_;
	
	localparam FIELD_WIDTH = SCREEN_WIDTH/CELL_SIZE;   // Horizontal screen resolution (in cells)
	localparam FIELD_HEIGHT = SCREEN_HEIGHT/CELL_SIZE; // Vertical screen resolution (in cells)
	
	// VGA Module
	localparam line = 799;
	localparam frame = 524;
	
	// 25 MHz clock
	reg clk25MHz_;
	wire clk25MHz;
	
	// 2D array of cells, stores game field state
	reg [1:0] field[0:FIELD_HEIGHT-1][0:FIELD_WIDTH-1];
	
	// Possible cell values: (no comments)
	localparam [1:0] EMPTY_CELL    = 2'b00;
	localparam [1:0] STABLE_CELL   = 2'b11;
	localparam [1:0] BALL_CELL     = 2'b01;
	localparam [1:0] PLATFORM_CELL = 2'b10;
	
	// ATTENTION!!!
	// All definitions below are in cells only.
	//
	
	// Informaton about game ball
	integer   ball_position_x; // Current coordinates
	integer   ball_position_y; 
	reg 	  ball_state;      // Current state (0 - stopped, 1 - moving)
	reg [1:0] ball_direction;  // Current moving direction
	
	// Possible ball directions:
	localparam [1:0] LEFT_UP    = 2'b00;
	localparam [1:0] RIGHT_UP   = 2'b01;
	localparam [1:0] LEFT_DOWN  = 2'b10;
	localparam [1:0] RIGHT_DOWN = 2'b11;
	
	// Information about game platforms
	integer platform1_position; // Current position (X axis, left border coordinate)
	integer platform2_position; 
	
	// VGA variables
	integer h_counter; // Horizontal pixel counter
	integer v_counter; // Vertical pixel counter
	integer h_cell;    // Horizontal cell counter
	integer v_cell;    // Vertical cell counter
	reg [1:0] current_cell; // Current cell value
	
	// Loops variables
	integer i, j;
		
	// Last buttons state
	reg button1_state;
	reg button2_state;
	reg button3_state;
	reg button4_state;
	
	
	////////////////////////////////////
	// **** END OF MODULE HEADER **** //
	////////////////////////////////////

	// Initialization of all module variables
	initial
	begin
		
		// Place ball to the center of the screen
		ball_position_x = FIELD_WIDTH/2;
		ball_position_y = FIELD_HEIGHT/2;
		ball_state = 0;
		
		// Place platforms at the center of the borders
		platform1_position = (FIELD_WIDTH-PLATFORM_WIDTH)/2; // central position
		platform2_position = platform1_position;
		
		button1_state = 1'b0;
		button2_state = 1'b0;
		button3_state = 1'b0;
		button4_state = 1'b0;
		
		h_counter = 0;
		v_counter = 0;
		
		for (i = 0; i < FIELD_HEIGHT; i = i + 1)
			for (j = 0; j< FIELD_WIDTH; j = j + 1)
				field[i][j] = EMPTY_CELL;
		
		field[ball_position_y][ball_position_x] = BALL_CELL;
			
		num1_ = 7'b0000000;
		num2_ = 7'b0000000;
		num3_ = 7'b0000000;
		num4_ = 7'b0000000;
	
	end
	
	// Frequency divider (50 MHz to 25 MHz, needed for VGA)
	always @ (posedge clk50MHz)
	begin
		clk25MHz_ = ~clk25MHz_;
	end
	
	// VGA sync
	always @ (posedge clk25MHz)
	begin
		if(h_counter == line)
			h_counter <= 0;
		else
			h_counter <= (h_counter + 1);
	end
			
	always @ (posedge clk25MHz)
	begin
		if (v_counter == frame)
			v_counter <= 0;
		else if (h_counter == line)
			v_counter <= (v_counter + 1);
	end
		

	
	always @ (posedge clk25MHz)
	begin
				
		if (button1 != button1_state)
		begin
			if (button1 == 1'b1)
			begin
				led_[7] = 1'b1;
				led_[6] = 1'b1;
				if (platform1_position > 0)
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
				if (platform1_position < FIELD_WIDTH-PLATFORM_WIDTH-1)
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
				if (platform2_position > 0)
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
				if (platform2_position < FIELD_WIDTH-PLATFORM_WIDTH-1)
					platform2_position = platform2_position + 1;
			end
			else
			begin
				led_[1] = 1'b0;
				led_[0] = 1'b0;
			end 
			button4_state = button4;
		end		
		
		
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

	assign clk25MHz = clk25MHz_;
	
	assign h_sync = ~((h_counter > 0) && (h_counter < 95));
	assign v_sync = ~((v_counter == 0) || (v_counter == 1));
	
	assign red = red_;
	assign green = green_;
	assign blue = blue_;
	
	assign led = led_;
	assign num1 = num1_;
	assign num2 = num2_;
	assign num3 = num3_;
	assign num4 = num4_;
	
endmodule
