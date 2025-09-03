# HitsSim_NIPS

Repositório do **Simulador de Pulsos TileCal** para a **DE10-Nano (Cyclone V SoC)**.

> Testado com **Quartus Prime Lite 23.1std** (host) e **Linux na HPS** (Angstrom/Yocto). Adapte versões conforme seu ambiente.

---

## Sumário
- [Visão rápida](#visão-rápida)
- [Pré-requisitos](#pré-requisitos)
- [Estrutura do repositório](#estrutura-do-repositório)
- [Fluxos comuns](#fluxos-comuns)
- [Dúvidas frequentes](#dúvidas-frequentes)
- [Contribuindo](#contribuindo)
- [Citação](#citação)

---

## Visão rápida
- **Entrada**: parâmetros (ex.: ocupação, offset)   
- **Saída/Observação**: leitura através de SignalTap Logic Analyser (ferramenta do Quartus)

---

## Pré-requisitos
- **Hardware**: DE10-Nano (Cyclone V SoC) - Hardware C - placa com SoC FPGA integrando HPS ARM Cortex-A9 dual-core e lógica programável
- **Software**: Quartus Prime Lite Edition — versão testada: 23.1std

---

## Estrutura do repositório

```
/
├─ HPS_FPGA_Simulador_vX_DE10/                # Projeto do simulador em FPGA (Quartus/Qsys), baseado no CD-ROM
│  ├─ Simulador_Arquivos/                     # Arquivos para o Gerador de Pulsos
│  ├─ pll_40mhz/                              # Gerador de Clock de 40MHz
│  ├─ pll_40mhz_sim/                          # Gerador de Clock de 40MHz
│  └─ .../                                    # Demais arquivos gerados na compilação do Quartus
├─ linux_image/                           # Imagem Linux p/ HPS (SD) já com programas/scripts prontos
│  └─ README.md                           # Passo a passo para criar um cartão SD "bootável" e iniciar a placa.
├─ board_cdrom/                       # Conteúdo original do CD-ROM da DE10-Nano (referência)
│  └─ ...                             # Exemplos, guias e utilitários de fábrica
├─ toolchain/                     # Arquivos p/ compilar binários e enviar p/ a placa
│  ├─ examples/                   # Exemplos (mmap, R/W registradores, SCP)
│  ├─ Makefile                    # `make` compila e (opcional) faz deploy via scp
│  └─ README.md                   # Passo a passo de configuração/uso
└─ scripts/                   # Utilitários (habilitar bridges, carregar .rbf, checks)
```



