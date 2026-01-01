module register_PC(
	input clock;
	input reset;
	input offset_signal;
	input offset;
	output [31:0]PC;
);

	always_ff@(posedge clock or negedge reset)
		begin
			if(!reset)
				PC<=32'd0;
			else if (offset_signal)
				PC<=PC+offset;
			else
				PC<=PC+32'd4;
				
		end

endmodule
