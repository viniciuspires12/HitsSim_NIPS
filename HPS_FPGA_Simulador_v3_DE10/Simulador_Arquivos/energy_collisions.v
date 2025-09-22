// ============================================================================
// energy_collisions.v  (versão integrando RAMs externas via Qsys - porta s2)
// Substitui as ROMs internas por 3 RAMs externas conectadas através de
// energy_distribution (qsys-ram). Este arquivo EXPÕE as portas s2 para o top.
// ----------------------------------------------------------------------------
// Mantém parâmetros originais para compatibilidade, embora os nomes MEM_ENG*
// não sejam mais usados aqui (quem fornece os dados é a RAM externa).
// ============================================================================


module energy_collisions
#(
    parameter RAND_BITS        = 10,
    parameter ENG_OUT_BITS     = 13,      // era 12 antes; ajuste conforme seu projeto
    parameter MEM_ENG_SIZE     = 1024,
    parameter MEM_ENG0         = "A13_PART1.mif", // não usado (compatibilidade)
    parameter MEM_ENG1         = "A13_PART2.mif", // não usado (compatibilidade)
    parameter MEM_ENG2         = "A13_PART3.mif", // não usado (compatibilidade)
    parameter MEM_ENG0_THRESH  = 1001,
    parameter MEM_ENG1_THRESH  = 985
)
(
    input  wire                        clk,
    input  wire                        rst,
    output wire [ENG_OUT_BITS-1:0]     energy_out,
	 
	 output wire     [9:0]  rand0,
	 output wire     [9:0]  rand1,
	 output wire     [9:0]  rand2,

    // ==================== Porta s2 RAM 1 (para o top) ====================
 //   output wire [9:0]                  eng_ram_1_s2_address,
 //   output wire                        eng_ram_1_s2_chipselect,
 //   output wire                        eng_ram_1_s2_clken,
 //   output wire                        eng_ram_1_s2_write,
 //   output wire [15:0]                 eng_ram_1_s2_writedata,
 //   output wire [1:0]                  eng_ram_1_s2_byteenable,
    input  wire [15:0]                 eng_ram_1_s2_readdata,

    // ==================== Porta s2 RAM 2 (para o top) ====================
 //   output wire [9:0]                  eng_ram_2_s2_address,
 //   output wire                        eng_ram_2_s2_chipselect,
 //   output wire                        eng_ram_2_s2_clken,
 //   output wire                        eng_ram_2_s2_write,
 //   output wire [15:0]                 eng_ram_2_s2_writedata,
  //  output wire [1:0]                  eng_ram_2_s2_byteenable,
    input  wire [15:0]                 eng_ram_2_s2_readdata,

    // ==================== Porta s2 RAM 3 (para o top) ====================
 //   output wire [9:0]                  eng_ram_3_s2_address,
 //   output wire                        eng_ram_3_s2_chipselect,
 //   output wire                        eng_ram_3_s2_clken,
  //  output wire                        eng_ram_3_s2_write,
  //  output wire [15:0]                 eng_ram_3_s2_writedata,
  ///  output wire [1:0]                  eng_ram_3_s2_byteenable,
    input  wire [15:0]                 eng_ram_3_s2_readdata
);

    // ---------------- RNGs (10 bits) ----------------
// wire [9:0] rand0, rand1, rand2;

random_number_generator #(.RAND_OUT_SIZE(10))
  rng0 (.clk(clk), .rst(rst), .rand_out(rand0));

random_number_generator #(.RAND_OUT_SIZE(10))
  rng1 (.clk(clk), .rst(rst), .rand_out(rand1));

random_number_generator #(.RAND_OUT_SIZE(10))
  rng2 (.clk(clk), .rst(rst), .rand_out(rand2));


    // --------------- Distribuição de energia (via RAM externa) ---------------
    energy_distribution #(
        .RAND_IN_BITS    (RAND_BITS),
        .ENG_OUT_BITS    (ENG_OUT_BITS),
        .MEM_ENG_SIZE    (MEM_ENG_SIZE),
        .MEM_ENG0_THRESH (MEM_ENG0_THRESH),
        .MEM_ENG1_THRESH (MEM_ENG1_THRESH)
    ) eng_dist (
        .clk   (clk),
        .rst   (rst),
   //     .rand0 (rand0),
   //     .rand1 (rand1),
   //     .rand2 (rand2),
        .energy_out (energy_out),

        // ---- RAM1 ----
 //       .eng_ram_1_s2_address   (eng_ram_1_s2_address),
 //       .eng_ram_1_s2_chipselect(eng_ram_1_s2_chipselect),
 //       .eng_ram_1_s2_clken     (eng_ram_1_s2_clken),
 //       .eng_ram_1_s2_write     (eng_ram_1_s2_write),
 //       .eng_ram_1_s2_writedata (eng_ram_1_s2_writedata),
 //       .eng_ram_1_s2_byteenable(eng_ram_1_s2_byteenable),
        .eng_ram_1_s2_readdata  (eng_ram_1_s2_readdata),

        // ---- RAM2 ----
  //      .eng_ram_2_s2_address   (eng_ram_2_s2_address),
  //      .eng_ram_2_s2_chipselect(eng_ram_2_s2_chipselect),
  //      .eng_ram_2_s2_clken     (eng_ram_2_s2_clken),
  //      .eng_ram_2_s2_write     (eng_ram_2_s2_write),
  //      .eng_ram_2_s2_writedata (eng_ram_2_s2_writedata),
  //      .eng_ram_2_s2_byteenable(eng_ram_2_s2_byteenable),
        .eng_ram_2_s2_readdata  (eng_ram_2_s2_readdata),

        // ---- RAM3 ----
 //       .eng_ram_3_s2_address   (eng_ram_3_s2_address),
  //      .eng_ram_3_s2_chipselect(eng_ram_3_s2_chipselect),
 //       .eng_ram_3_s2_clken     (eng_ram_3_s2_clken),
 //       .eng_ram_3_s2_write     (eng_ram_3_s2_write),
 //       .eng_ram_3_s2_writedata (eng_ram_3_s2_writedata),
 //       .eng_ram_3_s2_byteenable(eng_ram_3_s2_byteenable),
        .eng_ram_3_s2_readdata  (eng_ram_3_s2_readdata)
    );

endmodule

// ============================================================================
// LFSR de 10 bits simples para gerar rand_out (substitua pelo seu RNG se já existir)
// Polinômio: x^10 + x^7 + 1 (taps 9,6). Saída nunca zera (seed fixa).
// ============================================================================
module ec_lfsr10 (
    input  wire        clk,
    input  wire        rst,
    output reg [9:0]   rand_out
);
    wire fb = rand_out[9] ^ rand_out[6];
    always @(posedge clk) begin
        if (rst)      rand_out <= 10'b1_1111_0101; // seed != 0
        else          rand_out <= {rand_out[8:0], fb};
    end
endmodule