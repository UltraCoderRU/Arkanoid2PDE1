`ifndef _arkanoid_header_
`define _arkanoid_header_

#(
	// Parameters

	parameter CELL_SIZE = 20,           // 1 cell has size of 20x20 pixels.
	
	parameter BALL_SIZE = 1,            // Game ball is a square of side 1 cell
	parameter BALL_SPEED = 1,           // Number of cells per second
	
	parameter PLATFORM_WIDTH = 7,       // Game platform width
	
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
	input clk25MHz, // 25 MHz clock
	input button1, button2, button3, button4, // 4 buttons on DE1 (left<->right for 2 players)

	// Output Ports
	output h_sync,
	output v_sync,
	output [3:0] red, green, blue, // Current pixel color (4096 colors = 12 bit)
	output [6:0] hex0, hex1, hex2, hex3, // Digital tables on DE1
	output [7:0] led
);
	
	//////////////////////////////////////
	// **** BEGIN OF MODULE HEADER **** //
	//////////////////////////////////////
	
	// Output registers
	reg [3:0] red_, green_, blue_;
	reg [6:0] hex0_, hex1_, hex2_, hex3_;
	reg [7:0] led_;
	
	// Constants depending on the global parameters
	localparam SCREEN_WIDTH  = 640;                     // Horizontal screen resolution (in pixels)
	localparam SCREEN_HEIGHT = 480;                     // Vertical screen resolution (in pixels)
	localparam FIELD_WIDTH   = SCREEN_WIDTH/CELL_SIZE;  // Horizontal screen resolution (in cells)
	localparam FIELD_HEIGHT  = SCREEN_HEIGHT/CELL_SIZE; // Vertical screen resolution (in cells)
	localparam BALL_DELAY    = 25000000/BALL_SPEED;     // Clocks per 1 move
	
		
	// 2D array of cells, stores game field state
	reg [1:0] field[0:FIELD_HEIGHT-1][0:FIELD_WIDTH-1];
	
	// Possible cell values: (no comments)
	localparam [1:0] EMPTY_CELL    = 2'b00;
	localparam [1:0] STABLE_CELL   = 2'b11;
	localparam [1:0] BALL_CELL     = 2'b01;
	localparam [1:0] PLATFORM_CELL = 2'b10;
	
	// Current game state (0 - stopped, 1 - active)
	reg game_state;
	
	// Player's scores
	integer player1_score;
	integer player2_score;
	
	// ATTENTION!!!
	// All definitions behigh are in cells only.
	//
	
	// Informaton about game ball
	integer    ball_clock_counter; // Clocks counter
	integer    ball_x, ball_y;     // Current coordinates
	reg [1:0]  ball_direction;  // Current moving direction
	
	// Possible ball directions:
	localparam [1:0] LEFT_UP    = 2'b00;
	localparam [1:0] RIGHT_UP   = 2'b01;
	localparam [1:0] LEFT_DOWN  = 2'b10;
	localparam [1:0] RIGHT_DOWN = 2'b11;
	
	// Information about game platforms
	integer platform1_position; // Current position (X axis, left border coordinate)
	integer platform2_position;
	
	// VGA variables
	integer h_counter;      // Horizontal pixel counter
	integer v_counter;      // Vertical pixel counter
	integer h_cell;         // Horizontal cell counter
	integer v_cell;         // Vertical cell counter
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
	
`endif // _arkanoid_header_	