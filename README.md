# HitsSim_NIPS

Repositório do **Simulador de Pulsos TileCal** para a **DE10-Nano (Cyclone V SoC)**. Objetivo: permitir que qualquer novo membro rode o simulador em minutos, entenda a arquitetura e modifique parâmetros (ex.: **ocupação por canal**).

> Testado com **Quartus Prime Lite 23.1std** (host) e **Linux na HPS** (Angstrom/Yocto). Adapte versões conforme seu ambiente.

---

## Sumário
- [Visão rápida](#visão-rápida)
- [Arquitetura (alto nível)](#arquitetura-alto-nível)
- [Pré-requisitos](#pré-requisitos)
- [Hello Run (10 minutos)](#hello-run-10-minutos)
- [Estrutura do repositório](#estrutura-do-repositório)
- [Mapa de registradores (resumo)](#mapa-de-registradores-resumo)
- [Fluxos comuns](#fluxos-comuns)
- [Dúvidas frequentes](#dúvidas-frequentes)
- [Contribuindo](#contribuindo)
- [Citação](#citação)
- [Licença](#licença)

---

## Visão rápida
- **Entrada**: parâmetros (ex.: ocupação ρ por canal, sementes RNG).  
- **Processamento**: geração de hits → forma de pulso (shaper) → amostras.  
- **Saída/Observação**: leitura por user-space na HPS (mmap/devmem) ou captura via script e envio ao host.

---

## Arquitetura (alto nível)

```mermaid
flowchart LR
  subgraph HPS [HPS (ARM/Linux)]
    UI[User-space CLI / Scripts] --> RW[mmap/devmem]
  end

  subgraph FPGA [FPGA (Cyclone V)]
    RNG[RNG / Seeds]
    OCC[Ocupação por canal]
    GEN[Gerador de hits]
    SHAPER[Shaper (FIR/IIR)]
    BUF[Buffers / Registradores]
  end

  RW <--> BUF
  RNG --> GEN
  OCC --> GEN
  GEN --> SHAPER --> BUF
