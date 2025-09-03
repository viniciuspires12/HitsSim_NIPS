# HitsSim_NIPS

Repositório do **Simulador de Pulsos TileCal** para a **DE10-Nano (Cyclone V SoC)**. Objetivo: permitir que qualquer novo membro rode o simulador em minutos, entenda a arquitetura e modifique parâmetros (ex.: **ocupação por canal**).

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
- 
