// ============================================================================
// energy_distribution.v  (versão RAM via Qsys s2)
// Substitui as 3 ROMs internas por 3 portas de RAM externas (On-Chip Memory)
// exportadas pelo Platform Designer (porta s2). Mantém a mesma função:
// escolher um banco por thresholds, usar randX[9:0] como endereço, e
// registrar a saída de 13 bits com latência efetiva de 1 ciclo.
// ----------------------------------------------------------------------------
// Direções das portas s2 (do ponto de vista DESTE módulo = "master" local):
//   address[9:0]     : output
//   chipselect       : output
//   clken            : output
//   write            : output (sempre 0)
//   writedata[15:0]  : output (não usado, 0)
//   byteenable[1:0]  : output (2'b11)
//   readdata[15:0]   : input
// ============================================================================

`timescale 1ns/1ps

module energy_distribution
#(
    parameter RAND_IN_BITS     = 10,       // largura dos randX
    parameter ENG_OUT_BITS     = 13,       // bits úteis da energia
    parameter MEM_ENG_SIZE     = 1024,     // profundidade
    parameter MEM_ENG0_THRESH  = 1001,     // thresholds de seleção
    parameter MEM_ENG1_THRESH  = 985
)
(
    input  wire                       clk,
    input  wire                       rst,

    input  wire [RAND_IN_BITS-1:0]    rand0,
    input  wire [RAND_IN_BITS-1:0]    rand1,
    input  wire [RAND_IN_BITS-1:0]    rand2,

    output reg  [ENG_OUT_BITS-1:0]    energy_out,

    // === Porta s2 da RAM 1 (externa no Qsys) ===
//    output reg  [9:0]                 eng_ram_1_s2_address,
//    output reg                        eng_ram_1_s2_chipselect,
 //   output reg                        eng_ram_1_s2_clken,
 //   output wire                       eng_ram_1_s2_write,
 //   output wire [15:0]                eng_ram_1_s2_writedata,
 //   output wire [1:0]                 eng_ram_1_s2_byteenable,
    input  wire [15:0]                eng_ram_1_s2_readdata,

    // === Porta s2 da RAM 2 ===
  //  output reg  [9:0]                 eng_ram_2_s2_address,
  //  output reg                        eng_ram_2_s2_chipselect,
  //  output reg                        eng_ram_2_s2_clken,
  ///  output wire                       eng_ram_2_s2_write,
  //  output wire [15:0]                eng_ram_2_s2_writedata,
  //  output wire [1:0]                 eng_ram_2_s2_byteenable,
    input  wire [15:0]                eng_ram_2_s2_readdata,

    // === Porta s2 da RAM 3 ===
   // output reg  [9:0]                 eng_ram_3_s2_address,
  //  output reg                        eng_ram_3_s2_chipselect,
  //  output reg                        eng_ram_3_s2_clken,
  //  output wire                       eng_ram_3_s2_write,
  //  output wire [15:0]                eng_ram_3_s2_writedata,
  //  output wire [1:0]                 eng_ram_3_s2_byteenable,
    input  wire [15:0]                eng_ram_3_s2_readdata
);

    // Escrita desativada; byteenable ativo full
 //   assign eng_ram_1_s2_write      = 1'b0;
 //   assign eng_ram_2_s2_write      = 1'b0;
 //   assign eng_ram_3_s2_write      = 1'b0;
 //   assign eng_ram_1_s2_writedata  = 16'h0000;
 //   assign eng_ram_2_s2_writedata  = 16'h0000;
 //   assign eng_ram_3_s2_writedata  = 16'h0000;
 //   assign eng_ram_1_s2_byteenable = 2'b11;
 //   assign eng_ram_2_s2_byteenable = 2'b11;
 //   assign eng_ram_3_s2_byteenable = 2'b11;

    // Seleção de banco (one-hot) com base em rand2 e thresholds
    wire use_b0 = (rand2 >= MEM_ENG0_THRESH);
    wire use_b1 = (~use_b0) && (rand2 >= MEM_ENG1_THRESH);
    wire use_b2 = (~use_b0) && (~use_b1);

    // Banco selecionado em forma codificada (para pipeline de retorno)
    wire [1:0] bank_sel_now = use_b0 ? 2'd0 :
                              use_b1 ? 2'd1 : 2'd2;

    // Endereços usados por banco (vem dos RNGs)
    wire [9:0] addr_b0 = rand0[9:0];
    wire [9:0] addr_b1 = rand1[9:0];
    wire [9:0] addr_b2 = rand2[9:0];

    // Dirigir a porta s2 no ciclo N (ler um banco por vez)
   // always @(posedge clk) begin
   //     if (rst) begin
    //        eng_ram_1_s2_chipselect <= 1'b0;
   //         eng_ram_2_s2_chipselect <= 1'b0;
   //         eng_ram_3_s2_chipselect <= 1'b0;
   ///         eng_ram_1_s2_clken      <= 1'b0;
   //         eng_ram_2_s2_clken      <= 1'b0;
   //         eng_ram_3_s2_clken      <= 1'b0;
   //         eng_ram_1_s2_address    <= 10'd0;
   //         eng_ram_2_s2_address    <= 10'd0;
   //         eng_ram_3_s2_address    <= 10'd0;
   //     end else begin
            // Um único banco ativo por ciclo
   //         eng_ram_1_s2_chipselect <= use_b0;
    //        eng_ram_2_s2_chipselect <= use_b1;
   //         eng_ram_3_s2_chipselect <= use_b2;

//            eng_ram_1_s2_clken      <= use_b0;
 //           eng_ram_2_s2_clken      <= use_b1;
  //          eng_ram_3_s2_clken      <= use_b2;/

//            eng_ram_1_s2_address    <= addr_b0;
 //           eng_ram_2_s2_address    <= addr_b1;
  //          eng_ram_3_s2_address    <= addr_b2;
    //    end
   // end

    // Pipeline 1 ciclo: mux dos readdata com o banco do ciclo anterior
    reg [1:0]  bank_d1;
    always @(posedge clk) begin
        if (rst) begin
            bank_d1    <= 2'd0;
            energy_out <= {ENG_OUT_BITS{1'b0}};
        end else begin
            bank_d1 <= bank_sel_now;
            case (bank_d1)
                2'd0: energy_out <= eng_ram_1_s2_readdata[ENG_OUT_BITS-1:0];
                2'd1: energy_out <= eng_ram_2_s2_readdata[ENG_OUT_BITS-1:0];
                default: energy_out <= eng_ram_3_s2_readdata[ENG_OUT_BITS-1:0];
            endcase
        end
    end

endmodule
