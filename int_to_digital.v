`ifndef _int_to_digital_
`define _int_to_digital_

	task IntToDigital
	(
		input integer n,
		output [7:0] high,
		output [7:0] low
	);
	integer n1, n0;
	begin
		if (n > 99)
		begin
			high = 7'b1101111; high = 7'b1101111; // 99 any way
		end
		else
		begin
			n1 = n / 10;
			n0 = n % 10;
			
			case (n1)
				0: high = 7'b0111111; // 0x
				1: high = 7'b0000110; // 1x
				2: high = 7'b1011011; // 2x
				3: high = 7'b1001111; // 3x
				4: high = 7'b1100110; // 4x
				5: high = 7'b1101101; // 5x
				6: high = 7'b1111101; // 6x
				7: high = 7'b0000111; // 7x
				8: high = 7'b1111111; // 8x
				9: high = 7'b1101111; // 9x
				default: high = 7'b0000000;
			endcase
			case (n0)
				0: low = 7'b0111111; // x0
				1: low = 7'b0000110; // x1
				2: low = 7'b1011011; // x2
				3: low = 7'b1001111; // x3
				4: low = 7'b1100110; // x4
				5: low = 7'b1101101; // x5
				6: low = 7'b1111101; // x6
				7: low = 7'b0000111; // x7
				8: low = 7'b1111111; // x8
				9: low = 7'b1101111; // x9
				default: low = 7'b0000000;
			endcase
		end
	end
	endtask

`endif // _int_to_digital_