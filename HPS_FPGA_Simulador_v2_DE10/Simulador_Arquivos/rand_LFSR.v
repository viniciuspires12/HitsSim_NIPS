module rand_LFSR
#(
	parameter seed = 64'd12345,
	parameter DATA_OUT_SIZE = 7,
	parameter LFSR_BITS = 64
)
(
	input clk, rst,
	output [DATA_OUT_SIZE-1:0] rand_out
);

//reg [LFSR_BITS-1:0] bitv = 0;
reg bitv = 0;

reg [LFSR_BITS-1:0] lfsr = seed;  // Registrador de deslocamento inicializado com um valor não zero

always @(posedge clk or posedge rst) begin
	if (rst) begin
		lfsr <= seed;  // Reinicializa o LFSR em caso de reset
		bitv <= 1'd0;
	end else begin
	
		// Lógica para o feedback do LFSR (XOR dos bits específicos)
		//LFSR 32BITS
		//bitv = ((lfsr >> 0) ^ (lfsr >> 2) ^ (lfsr >> 24) ^ (lfsr >> 25)) & 32'b1;
		//lfsr = (lfsr >> 1) | (bitv << 31);
		
		// LFSR 64BITS
		//bitv <= ((lfsr >> 0) ^ (lfsr >> 2) ^ (lfsr >> 3) ^ (lfsr >> 63)) & 64'b1;
		//lfsr <= (lfsr >> 1) | (bitv << 63);
		//bitv <= lfsr[0] ^ lfsr [2] ^ lfsr[3] ^ lfsr[63];
		//lfsr <= {bitv,lfsr[LFSR_BITS-1:1]};
		
		// LFSR 42BITS
		//bitv <= ((lfsr >> 0) ^ (lfsr >> 2) ^ (lfsr >> 3) ^ (lfsr >> 63)) & 64'b1;
		//lfsr <= (lfsr >> 1) | (bitv << 63);
		bitv <= lfsr[0] ^ lfsr [1] ^ lfsr[22] ^ lfsr[23];
		//bitv <= lfsr[0] ^ lfsr [7] ^ lfsr[13] ^ lfsr[23] ^ lfsr[26] ^ lfsr[41];
		lfsr <= {bitv,lfsr[LFSR_BITS-1:1]};
		

	end
end

// Saída aleatória de 7 bits
assign rand_out = lfsr[DATA_OUT_SIZE-1:0];

endmodule