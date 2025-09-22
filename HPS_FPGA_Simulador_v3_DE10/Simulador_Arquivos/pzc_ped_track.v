module pzc_ped_track
#(
	// parametros para serem configurados externamente -------------------------

	parameter NBITS_IN  = 12,          // Numero de bits de dados
	parameter NBITS_OUT = 28,          // Numero de bits de dados de saida
	parameter M_FACTOR  = 454,         // Fator M do PZC
	parameter K_CORR = 2**4,			  // Quando vai corrigir a saida
	parameter PED_CORR = 13,			  // Quando vai corrigir a saida
	//parameter PED_CORR = 2**4,			  // Quando vai corrigir a saida
	parameter BT_NUM = 16              // Numero de amostras para identificar o long gap
)
(
	input                              clk, rst,
	input					bt_mask_out,                  // saber a mascara do bunch train e zero
	input   signed    [NBITS_IN  -1:0] in,
	output reg signed [NBITS_IN  -1:0] pedestal = 0,
	output signed    [NBITS_OUT -1:0] io_out
);

reg enable_acc_corr = 1'd1;
reg enable_ped = 1'd1;
reg enable_diverge = 1'd1;

reg signed [NBITS_OUT -1:0] out_delay = 0;//, p;

//reg [$clog2(K_CORR):0] cont1 = 0;// numero amostras negativas;
//reg [$clog2(PED_CORR)+1:0] cont2 = 0;// numero amostras positivas;
reg [20:0] cont1 = 0;// numero amostras negativas;
reg [20:0] cont2 = 0;// numero amostras positivas;
reg [20:0] cont_bt = 0;// numero de amostras zeradas pela mascara;


reg signed [NBITS_OUT+K_CORR - 1:0] soma = 0;// soma das amostras negativas;
reg signed [NBITS_OUT+PED_CORR- 1:0] soma2 = 0;// soma das amostras negativas;
reg signed [NBITS_OUT -1:0] m_out = 0;// salva saida anterior;
reg signed [NBITS_OUT -1:0] ped_reg_out = 0;// salva saida anterior;
reg signed [NBITS_OUT -1:0] ped_reg_out_corr = 0;// salva saida anterior;
reg signed [NBITS_OUT -1:0] io_out_delay = 0;
reg signed [NBITS_OUT -1:0] first_sample = 0;
reg signed [NBITS_OUT+6 -1:0] diff_last = 0;

wire [NBITS_OUT-1:0] diff;

assign diff = (cont_bt > BT_NUM) ? io_out - io_out_delay : 0;


always @(posedge clk or posedge rst) 
begin
	if(rst) begin
		out_delay <= 0;
		cont1 <= 0;
		cont2 <= 0;
		cont_bt <= 0;
		pedestal <= 0;
		ped_reg_out <= 0;
		ped_reg_out_corr <= 0;
		enable_acc_corr <= 1'd1;
		io_out_delay <= 0;
		soma2 <= 0;
		enable_ped <= 1;
		first_sample <= 0;
		diff_last <= 0;
		enable_diverge <= 1'd1;
	end
	else
	begin		
		out_delay <= (in-pedestal) + out_delay - m_out - ped_reg_out_corr;
		
		if (bt_mask_out == 0) begin         // esta no periodo de gap
			cont_bt <= cont_bt + 1'd1;       // incrementa o contador
		end
		else begin
			cont_bt <= 0;
		end
		
		
		if(cont_bt >= BT_NUM) begin              //se chegar em um limite determinado do gap, incrementa o reg para corrigir o acc
			if(cont_bt == BT_NUM + K_CORR + 6) begin
			//if(cont_bt == 150) begin
				io_out_delay <= io_out;
				
				if (enable_diverge && (io_out - io_out_delay) > 1000) begin
					ped_reg_out <= in + out_delay - m_out;
					out_delay <= -(in-pedestal)*M_FACTOR;
					enable_diverge <= 1'd0;
				end
				else begin
					ped_reg_out <= 0;
					enable_diverge <= 1'd1;
				end
				
			end
			
			
			if(cont2 == 0) begin
				first_sample <= io_out;
			end
			
			
			if (io_out < 0) begin
				cont1 <= cont1 + 1'd1;
				soma <= soma + io_out;
			end
	
			if (enable_ped) begin
				cont2 <= cont2 + 1'd1;
				soma2 <= soma2 + io_out;
			end
			else begin
				soma2 <= 0;
				cont2 <= 0;
			end
			
			
			if (enable_acc_corr) begin
				if (cont1 == K_CORR) begin           //Se chegar no limite de correcao
					m_out <= soma >>> $clog2(K_CORR); // corrige o acc
					cont1 <= 0;
					soma <= 0;
					enable_ped <= 0;
					enable_diverge <= 0;
				end
				else begin
					m_out <= 0;
					enable_diverge <= 1'd1;
				end
			end
			else begin
				m_out <= 0;
			end
			
			if (cont2 == PED_CORR) begin
				diff_last <= io_out - first_sample;
			end
			else begin
				diff_last <= 0;
			end
			
			if (diff_last > PED_CORR*5 && soma2 > 0) begin
				enable_acc_corr <= 0;
				enable_ped <= 0;
				pedestal <= pedestal + 1'd1;
				diff_last <= 0;
				first_sample <= 0;
				ped_reg_out_corr <= soma2 >>> $clog2(K_CORR);
				enable_diverge <= 0;
			end
			else begin
			
				if (diff_last < -PED_CORR*5 && soma2 < 0) begin
					enable_acc_corr <= 0;
					enable_ped <= 0;
					pedestal <= pedestal - 1'd1;
					diff_last <= 0;
					first_sample <= 0;
					ped_reg_out_corr <= soma2 >>> $clog2(K_CORR);
					enable_diverge <= 0;
				end
				else begin
					ped_reg_out_corr <= 0;
					enable_diverge <= 1'd1;
				end

			end
			
			

		end
		else begin
			cont1 <= 0;
			cont2 <= 0;
			soma <= 0;
			m_out <= 0;
			ped_reg_out <= 0;
			enable_acc_corr <= 1'd1;
			ped_reg_out_corr <= 0;
			soma2 <= 0;
			enable_ped <= 1'd1;
			first_sample <= 0;
			diff_last <= 0;
			enable_diverge <= 1'd1;
		end
		
	end
end


assign io_out = (in - pedestal) + out_delay + M_FACTOR * (in - pedestal);  //saida do PZC


endmodule