# Versão 2 do simulador

**Descrição:** Adicionada **On-Chip Memory (RAM 8×128)** para atuar como **registrador de ocupação** acessível pelo Linux (HPS) e lida pelo simulador no FPGA.

## Memória adicionada
- **IP:** On-Chip Memory (RAM), **8 bits × 128 endereços**, **dual-port / dual-clock**  
- **s1 (HPS):** ligada ao **h2f_lw_axi_master** → Linux lê/escreve  
- **s2 (Simulador):** exportada para o simulador → somente leitura no HDL  

## Como funciona
1. **Linux** preenche a tabela nos endereços **0..126** (1 byte cada).  
2. **Linux** escolhe o **índice** escrevendo em **0x7F**.  
3. **Simulador** (FSM 2 passos) lê **0x7F → idx** e em seguida **idx → occupancy_cfg** (repete continuamente).

**Endereços (padrão DE10-Nano):**
- **LW base:** `0xFF200000`  
- **RAM s1 base:** `0xFF200000` (span `0x80`)  
- **Índice:** `0xFF20007F`  

## Alterações no Top-Level (de10_nano_soc_ghrd.v) a partir da v1

```bash
// --- porta s2 da on-chip RAM (somente leitura no HDL)
wire [6:0] occ_addr;
wire       occ_cs;
wire [7:0] occ_rdata;

soc_system u0 (
  .occ_ram_clk2_clk         (clk_40),
  .occ_ram_reset2_reset     (~KEY[0]),
  .occ_ram_reset2_reset_req (1'b0),

  .occ_ram_s2_address       (occ_addr),
  .occ_ram_s2_chipselect    (occ_cs),
  .occ_ram_s2_clken         (1'b1),
  .occ_ram_s2_write         (1'b0),
  .occ_ram_s2_writedata     (8'h00),
  .occ_ram_s2_readdata      (occ_rdata)

  // ...demais conexões...
);

FPGA_Simulator_v1_PZC u_sim (
  .clk       (clk_40),
  .rst       (~KEY[0]),
  .ram_addr  (occ_addr),
  .ram_read  (occ_cs),
  .ram_rdata (occ_rdata)
  // ...demais portas...
);
```
## Alterações no Simulador (FPGA_Simulator_v1_PZC.v) a partir da v1

```bash
// --- porta s2 da on-chip RAM (somente leitura no HDL)
wire [6:0] occ_addr;
wire       occ_cs;
wire [7:0] occ_rdata;

soc_system u0 (
  .occ_ram_clk2_clk         (clk_40),
  .occ_ram_reset2_reset     (~KEY[0]),
  .occ_ram_reset2_reset_req (1'b0),

  .occ_ram_s2_address       (occ_addr),
  .occ_ram_s2_chipselect    (occ_cs),
  .occ_ram_s2_clken         (1'b1),
  .occ_ram_s2_write         (1'b0),
  .occ_ram_s2_writedata     (8'h00),
  .occ_ram_s2_readdata      (occ_rdata)

  // ...demais conexões...
);

FPGA_Simulator_v1_PZC u_sim (
  .clk       (clk_40),
  .rst       (~KEY[0]),
  .ram_addr  (occ_addr),
  .ram_read  (occ_cs),
  .ram_rdata (occ_rdata)
  // ...demais portas...
);

------------[...]------------


localparam [6:0] IDX_ADDR = 7'h7F;

reg [1:0] fsm;
reg [6:0] idx_q;
reg [RAND_BITS_HITS-1:0] occupancy_cfg;

always @(posedge clk or posedge rst) begin
  if (rst) begin
    fsm           <= 2'd0;
    ram_addr      <= 7'd0;
    ram_read      <= 1'b0;
    idx_q         <= 7'd0;
    occupancy_cfg <= {RAND_BITS_HITS{1'b0}};
  end else begin
    ram_read <= 1'b0; // default

    case (fsm)
      2'd0: begin
        // Passo 1: ler índice (0x7F)
        ram_addr <= IDX_ADDR;
        ram_read <= 1'b1;        // dado no próximo ciclo
        fsm      <= 2'd1;
      end

      2'd1: begin
        // Captura idx (evita 127) e dispara leitura do valor
        idx_q    <= (ram_rdata[6:0] == 7'd127) ? 7'd126 : ram_rdata[6:0];
        ram_addr <= (ram_rdata[6:0] == 7'd127) ? 7'd126 : ram_rdata[6:0];
        ram_read <= 1'b1;
        fsm      <= 2'd2;
      end

      2'd2: begin
        // Atualiza ocupação
        occupancy_cfg <= ram_rdata[RAND_BITS_HITS-1:0];
        fsm           <= 2'd0;
      end
    endcase
  end
end

// usar o valor lido no gerador de hits
// Hits_Bunch_train(... .occupancy(occupancy_cfg), ...);

```

