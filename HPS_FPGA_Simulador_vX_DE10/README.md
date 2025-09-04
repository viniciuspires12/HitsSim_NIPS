# HPS_FPGA_Simulador_v1_DE10

Projeto **Quartus/Platform Designer** do simulador de pulsos para **DE10-Nano (Cyclone V SoC)**.

## Conteúdo desta pasta
```
HPS_FPGA_Simulador_v1_DE10/
├─ *.qpf / *.qsf           # Projeto Quartus
├─ output_files/           # Artefatos de build (.sof/.rbf)
└─ ...
```

## Pré-requisitos
- **Quartus Prime Lite 23.1std** (ou compatível com **Cyclone V**).
- **DE10-Nano** (MSEL todos em **ON** para boot pelo SD).

## Como abrir, **editar** e compilar
1. Abra o **Quartus** e carregue o projeto `*.qpf`.
2. Verifique o **device**: `5CSEBA6U23I7`.
3. **Edite o projeto (opcional):**
   - **RTL (Verilog/VHDL)** em `rtl/` — ajuste módulos, parâmetros, registradores, conexões.
   - **Qsys / Platform Designer** em `platform/soc_system.qsys` — adicione/edite IPs, clocks, endereços, interconexões.
4. Se editar no **Platform Designer**, clique **Generate** (*System Generation*) para atualizar o sistema  
   *(isso também atualiza headers como `hps_0.h`/`soc_system.h` usados no software)*.
5. No **Quartus**, clique **Compile** (*Start Compilation*).
6. O bitstream sai em `output_files/*.rbf`. Se alterou Qsys/endereços, use os **headers gerados** no software da HPS.



## Programar a FPGA
**Opção A — USB-Blaster (host):** Quartus **Programmer** → selecione `.rbf` → *Program/Configure*.

**Opção B — Pela HPS (fpga_manager):**
```bash
# na HPS (Linux já iniciado)
echo 0 > /sys/class/fpga_bridge/*/enable
cp /caminho/bitstream.rbf /lib/firmware/sim.rbf
echo sim.rbf > /sys/class/fpga_manager/fpga0/firmware
echo 1 > /sys/class/fpga_bridge/*/enable
```

> A imagem de SD fornecida **programa automaticamente a FPGA** no boot. Veja `linux_image/README.md`.

## Headers / endereços de memória
Após a geração no Platform Designer, os arquivos de endereços (ex.: `hps_0.h`/`soc_system.h`) ficam disponíveis para uso no software da HPS. **Sempre regenere** após alterações no Qsys.

## Teste rápido
- Com a placa ligada e na rede: descubra o **IP** (scanner ou serial) e acesse:
  ```bash
  ssh root@<IP_DA_PLACA>   # senha: simhits
  ```
- Bridges HPS↔FPGA (se necessário):
  ```bash
  for b in fpga2hps hps2fpga lwhps2fpga; do echo 1 | sudo tee /sys/class/fpga_bridge/$b/enable; done
  ```

## Erros comuns
- `.rbf` compila mas nada muda → device errado ou bridges desabilitadas.
- Endereços não batem → faltou **Generate** no Platform Designer antes do build.
- Pinout/timing falhando → revise `constraints/`.

> Para uso do Linux/SSH/serial e gravação do SD, veja `linux_image/README.md`.

