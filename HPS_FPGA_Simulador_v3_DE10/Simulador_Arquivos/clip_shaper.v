module clip_shaper
#( 
	parameter BITS_IN = 34,
	parameter BITS_OUT = 12,
	parameter G_SAIDA_LOG = 10
)
(
	input  clk, rst,
	input  signed [BITS_IN-1:0] in,
	input  signed [BITS_IN-1:0] offset,
	output reg [BITS_OUT-1:0] out = 0
);

wire signed [BITS_IN-1:0] in_offset = (in + (offset <<< G_SAIDA_LOG)) >>> 10;




	always@(posedge clk or posedge rst) begin
		if(rst) begin
			out <= 0;
		end
		else begin
			if (in_offset < 0)
				out <= 0;
				//out <= 4095;
			else
				if (in_offset > 4095)
					out <= 4095;
				else
					out <= in_offset;
					//out <= 4095;
		end
	end
	
endmodule
