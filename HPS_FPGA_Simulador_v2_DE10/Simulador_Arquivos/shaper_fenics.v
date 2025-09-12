module shaper_fenics
#( 
	parameter BITS_IN = 34,
	parameter G_ENTRADA = 2**32,
	parameter G_SAIDA_LOG = 10
)
(
	input  clock, 
	input  signed [BITS_IN-1:0] in,
	output signed [BITS_IN+16:0] out
);


wire signed [BITS_IN+16:0] out1, out2, out3, out4, out5, out6;

/////////////////////////////
iir_ordem1
#( 
	.BITS_IN(BITS_IN),
	.G_ENTRADA(G_ENTRADA),
	.G_SAIDA_LOG(10),
	.b0(-3),  
	.a1(-1022)
) iir1
(
	.clock(clock), 
	.in(in),
	.out(out1)
);

/////////////////////////////
iir_ordem2
#( 
	.BITS_IN(BITS_IN),
	.G_ENTRADA(G_ENTRADA),
	.G_SAIDA_LOG(10),
	.b0(746),
	.b1(444),	
	.a1(1074),
	.a2(296)
) iir2
(
	.clock(clock), 
	.in(in),
	.out(out2)
);

/////////////////////////////
iir_ordem2
#( 
	.BITS_IN(BITS_IN),
	.G_ENTRADA(G_ENTRADA),
	.G_SAIDA_LOG(10),
	.b0(-3362),
	.b1(-361),	
	.a1(-29),
	.a2(167)
) iir3
(
	.clock(clock), 
	.in(in),
	.out(out3)
);


/////////////////////////////
iir_ordem1
#( 
	.BITS_IN(BITS_IN),
	.G_ENTRADA(G_ENTRADA),
	.G_SAIDA_LOG(10),
	.b0(2644),  
	.a1(-373)
) iir4
(
	.clock(clock), 
	.in(in),
	.out(out4)
);

/////////////////////////////

iir_ordem2
#( 
	.BITS_IN(BITS_IN),
	.G_ENTRADA(G_ENTRADA),
	.G_SAIDA_LOG(10),
	.b0(-24),
	.b1(-0),	
	.a1(0),
	.a2(0)
) iir5
(
	.clock(clock), 
	.in(in),
	.out(out5)
);


/////////////////////////////

iir_ordem1
#( 
	.BITS_IN(BITS_IN),
	.G_ENTRADA(G_ENTRADA),
	.G_SAIDA_LOG(10),
	.b0(0),  
	.a1(0)
) iir6
(
	.clock(clock), 
	.in(in),
	.out(out6)
);

assign out = out1 + out2 + out3 + out4 + out5 + out6;


endmodule
