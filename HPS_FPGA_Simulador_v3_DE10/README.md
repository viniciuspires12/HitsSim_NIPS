# Simulador de Pulsos — **Versão 3**

> **Resumo:** a v3 substitui as tabelas `.mif` por **3 RAMs on-chip dual-port** (graváveis pelo Linux) para gerar os valores de energia. O RNG agora **endereça** a RAM; não há lookup em tabela fixa, podendo alterar o valor da tabela de forma online.

---

## O que mudou da **v2 → v3**

- **Entraram** 3 memórias **on-chip dual-port** (`altera_onchip_memory2`):
  - **Largura:** 16 bits (word)
  - **Profundidade:** 1024 endereços (0…1023)
  - **Tamanho por RAM:** ~2 KiB
  - **Instâncias:** `energy_ram_1`, `energy_ram_2`, `energy_ram_3`
  - **Mapeamento (HPS → LW bridge):**
    - `energy_ram_1`: offset **0x0000_1000**
    - `energy_ram_2`: offset **0x0000_2000**
    - `energy_ram_3`: offset **0x0000_4000**
    - **Base LW:** `0xFF20_0000` → endereços físicos: `FF20_1000`, `FF20_2000`, `FF20_4000`
- **RNG (RAND):** na v2 o índice sorteado buscava um **valor** na tabela `.mif`.  
  Na v3 o RNG fornece o **endereço** para **ler 1 word (16b)** da RAM de energia (porta A do simulador).

---

## Como ficou a arquitetura

- **Porta A (FPGA):** leitura síncrona pelo simulador (uma amostra por ciclo previsto).
- **Porta B (HPS/LW):** escrita/leitura pelo Linux (user space).  
- **Protocolo de dado:** 16 bits, **mesma escala da v2** (use a mesma convenção numérica que você já usava nas `.mif`).

> ⚠️ Recomendações:
> - Respeite **0 ≤ addr ≤ 1023**.

---

## Escrevendo nas RAMs **pelo driver C (user space)**


### Fluxo (simples, via `/dev/mem`)
- O programa abaixo mapeia o **LW bridge** e grava **1024 words** (16b) a partir de um `.bin` (little-endian).

````c
// tools/load_energy_ram.c — grava 1024 words (16b) em uma das 3 RAMs de energia
// uso: sudo ./load_energy_ram <ram_id:1|2|3> <arquivo.bin>
#define _GNU_SOURCE
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <errno.h>
#include <string.h>

#define LW_BRIDGE_BASE  0xFF200000UL
#define MAP_SPAN        0x00005000UL   // cobre até 0x4000 + margem
#define RAM1_OFF        0x00001000UL
#define RAM2_OFF        0x00002000UL
#define RAM3_OFF        0x00004000UL
#define RAM_DEPTH       1024
#define WORD_BYTES      2

static off_t ram_offset(int id){
    switch(id){
        case 1: return RAM1_OFF;
        case 2: return RAM2_OFF;
        case 3: return RAM3_OFF;
        default: return -1;
    }
}

int main(int argc, char **argv){
    if(argc != 3){ fprintf(stderr,"uso: %s <1|2|3> <arquivo.bin>\n", argv[0]); return 1; }
    int ram_id = atoi(argv[1]);
    off_t off = ram_offset(ram_id);
    if(off < 0){ fprintf(stderr,"ram_id inválido\n"); return 1; }

    // lê arquivo (até 1024 words = 2048 bytes)
    uint16_t buf[RAM_DEPTH] = {0};
    FILE *f = fopen(argv[2], "rb");
    if(!f){ perror("fopen"); return 1; }
    size_t rd = fread(buf, WORD_BYTES, RAM_DEPTH, f);
    fclose(f);
    if(rd != RAM_DEPTH){
        fprintf(stderr,"[aviso] lidos %zu/%d words; restante preenchido com zero\n", rd, RAM_DEPTH);
    }

    // /dev/mem
    int fd = open("/dev/mem", O_RDWR | O_SYNC);
    if(fd < 0){ perror("open(/dev/mem)"); return 1; }

    long pagesz = sysconf(_SC_PAGESIZE);
    off_t phys_base = LW_BRIDGE_BASE;
    off_t page_base = phys_base & ~(pagesz - 1);
    off_t page_off  = phys_base - page_base;

    void *map = mmap(NULL, MAP_SPAN + page_off, PROT_READ|PROT_WRITE, MAP_SHARED, fd, page_base);
    if(map == MAP_FAILED){ perror("mmap"); close(fd); return 1; }

    volatile uint8_t  *base8  = (volatile uint8_t*)map + page_off;
    volatile uint16_t *ram    = (volatile uint16_t*)(base8 + off);

    // gravação (16 bits little-endian)
    for(int i=0;i<RAM_DEPTH;i++){
        ram[i] = buf[i];
    }
    // leitura de verificação de 4 amostras
    fprintf(stderr,"verify: [0]=%u  [1]=%u  [1022]=%u  [1023]=%u\n",
            ram[0], ram[1], ram[1022], ram[1023]);

    munmap((void*)map, MAP_SPAN + page_off);
    close(fd);
    fprintf(stderr,"OK: RAM%d atualizada a partir de %s\n", ram_id, argv[2]);
    return 0;
}

