# HitsSim_NIPS

Repositório do **Simulador de Pulsos TileCal** para a **DE10-Nano (Cyclone V SoC)**.

> Testado com **Quartus Prime Lite 23.1std** (host) e **Linux na HPS** (Angstrom/Yocto). Adapte versões conforme seu ambiente.

---

## Sumário
- [Visão rápida](#visão-rápida)
- [Pré-requisitos](#pré-requisitos)
- [Guia de execução (passo a passo)](#guia-de-execução-passo-a-passo)
- [Estrutura do repositório](#estrutura-do-repositório)
- [Fluxos comuns](#fluxos-comuns)
- [Dúvidas frequentes](#dúvidas-frequentes)
- [Contribuindo](#contribuindo)

---

## Visão rápida
- **Entrada**: parâmetros (ex.: ocupação, offset)   
- **Saída/Observação**: leitura através de **SignalTap Logic Analyzer** (Quartus)

---

## Pré-requisitos
- **Hardware**: DE10-Nano (Cyclone V SoC) – Hardware C 
- **Software**: **Quartus Prime Lite 23.1std** (ou compatível)

---

## Guia de execução (passo a passo)

### A. Preparar e iniciar a placa
1. **Crie** um cartão SD inicializável (**mín. 2 GB**) com a **imagem compartilhada**.  
2. **Insira** o cartão SD na **DE10-Nano**.  
3. Coloque os **MSEL** **todos na posição “ON”**.  
4. **Conecte** um **cabo Ethernet** à placa.  
5. **Ligue** a placa.  
6. O **Linux irá iniciar** e **programará automaticamente a FPGA**.

### B. Acessar a placa e ajustar ocupação/offset
7. **Descubra o IP** da placa (via **IP Scanner** ou pela **COM/serial**).  
8. **Conecte via SSH** para se comunicar com a placa.  
9. **Credenciais**: **Login** `root` | **Senha** `simhits`.  
10. No SSH, execute: `./<nome_do_script>`  

### C. Visualizar no Quartus/SignalTap
11. **Abra o projeto no Quartus** no seu computador.  
12. Conecte a placa na porta **USB-Blaster II**.  
13. No Quartus, vá em **Tools** e abra o **Signal Tap Logic Analyser**.  
14. **Configure os sinais a serem analisados**.  
15. Clique em **Autorun Analysis**. Agora é possível **ver os sinais** em tempo real enquanto usa o comando SSH.  

> **Nota:** Mais detalhes e explicações serão adicionados.

---

## Estrutura do repositório

```
/
├─ HPS_FPGA_Simulador_vX_DE10/            # Projeto do simulador em FPGA (Quartus/Qsys), baseado no CD-ROM
│  ├─ Simulador_Arquivos/                 # Arquivos para o Gerador de Pulsos
│  ├─ pll_40mhz/                          # Gerador de Clock de 40MHz
│  ├─ pll_40mhz_sim/                      # Gerador de Clock de 40MHz
|  ├─ toolchain/                          # Arquivos necessários para a compilação do script no Linux                     
│  └─ .../                                # Demais arquivos gerados na compilação do Quartus
├─ linux_image/                           # Imagem Linux p/ HPS (SD) com programas/scripts prontos
│  └─ README.md                           # Passo a passo para criar SD "bootável" e iniciar a placa
├─ board_cdrom/                           # Conteúdo original do CD-ROM da DE10-Nano (referência)
│  └─ ...                                 # Exemplos, guias e utilitários de fábrica
├─ toolchain/                             # Compilar binários e enviar p/ a placa
│  ├─ examples/                           # Exemplos
│  ├─ Makefile                            # `make` compila
└─ └─ README.md                           # Passo a passo de configuração/uso

```

---

## Fluxos comuns


---

## Dúvidas frequentes
- **Sem IP/SSH?** Verifique cabo Ethernet, DHCP da rede ou veja IP pela serial.  
- **Sem dados no SignalTap?** Revise JTAG chain, clock, trigger e se a FPGA foi programada (auto-boot).
- [Erro `GLIBC_2.34 not found` na DE10-Nano (como resolver)](docs/faq_glibc.md)


---

## Contribuindo
Atualize este README sempre que mudar o fluxo.

12/09/2025 - Atualizando v2: Adicionada memória RAM como registrador de ocupação.





