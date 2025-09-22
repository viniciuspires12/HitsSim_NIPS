module pzc_media_fixa
#(
	// parametros para serem configurados externamente -------------------------

	parameter NBITS_IN  = 12,          // Numero de bits de dados
	parameter NBITS_OUT = 28,          // Numero de bits de dados de saida
	parameter M_FACTOR  = 454,         // Fator M do PZC
	parameter K_CORR = 2**4				  // Quando vai corrigir a saida
)
(
	input                              clk, rst,
	input   signed    [NBITS_IN  -1:0] in,
	output signed    [NBITS_OUT -1:0] io_out
);

reg signed [NBITS_OUT -1:0] out_delay = 0;//, p;

reg [$clog2(K_CORR):0] cont1 = 0;// numero amostras negativas;


reg signed [NBITS_OUT - 1:0] soma = 0;// soma das amostras negativas;
reg signed [NBITS_OUT -1:0] m_out = 0;// salva saida anterior;


always @(posedge clk or posedge rst) 
begin
	if(rst) begin
		out_delay <= 0;
		cont1 <= 0;
	end
	else
	begin		
		out_delay <= in + out_delay - m_out;
		
		if (io_out < 0) begin
			cont1 = cont1 + 1'd1;
			soma <= soma + io_out;
		end
		
		if (cont1 == K_CORR) begin
			m_out <= soma >>> $clog2(K_CORR);
			cont1 <= 0;
			soma <= 0;
		end
		else begin
			m_out <= 0;
		end
		
	end
end


assign io_out = in + out_delay + M_FACTOR * in - m_out;


endmodule