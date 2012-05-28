module Debouncer (noisy, clk, debounced);

input clk;
input noisy;
output reg debounced;

reg [7:0] button_reg;

always @ (posedge clk) 
begin
	
	button_reg[7:0] <= {button_reg[6:0],noisy}; //shift register
	
	if(button_reg[7:0] == 8'b00000000)
		debounced <= 1'b0;
	else if(button_reg[7:0] == 8'b11111111)
		debounced <= 1'b1;
	else 
		debounced <= debounced;
end

endmodule
