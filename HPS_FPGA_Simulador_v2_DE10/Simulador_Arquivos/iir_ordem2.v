module iir_ordem2

#(
	parameter BITS_IN = 33,
	parameter G_ENTRADA = 2**32,
	parameter G_SAIDA_LOG = 10,
	parameter signed b0 =  -788, //-788 
	parameter signed b1 =  -399, //-399
	parameter signed a1 =  -618,
	parameter signed a2 =   1362
)

(

	

	input  clock, 
	input  signed [BITS_IN-1:0] in,
	output signed [BITS_IN+16:0] out
	);
	
	reg signed  [BITS_IN:0] rx1 = 0;
	reg signed  [BITS_IN+16:0] ry1 = 0, ry2 = 0;
	wire signed [BITS_IN+16:0] yz;
	wire signed [BITS_IN+G_SAIDA_LOG+16:0] yp;
		
	
	
	assign yz =   b0*in + b1*rx1;
	assign yp = - a1*ry1 - a2*ry2;
	assign out =   yz + (yp >>> G_SAIDA_LOG);
	
	always @(posedge clock)
	begin
	rx1 <= in;
	ry2 <= ry1;
   ry1 <= out;
	end
	
	
endmodule
