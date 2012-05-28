module ClockDivider (clk50MHz, clk25MHz);
input clk50MHz;
output clk25MHz;

reg clk25MHz_;

always @ (posedge clk50MHz)
begin
	clk25MHz_ = ~clk25MHz_;
end

assign clk25MHz = clk25MHz_;

endmodule
