`ifndef _vga_sync_
`define _vga_sync_

	// VGA synchronization
	
	localparam VGA_LINES_LIMIT = 799;
	localparam VGA_FRAMES_LIMIT = 524;
	
	always @ (posedge clk25MHz)
	begin
		if(h_counter == VGA_LINES_LIMIT)
			h_counter <= 0;
		else
			h_counter <= (h_counter + 1);
	end
			
	always @ (posedge clk25MHz)
	begin
		if (v_counter == VGA_FRAMES_LIMIT)
			v_counter <= 0;
		else if (h_counter == VGA_LINES_LIMIT)
			v_counter <= (v_counter + 1);
	end
	
`endif // _vga_sync_