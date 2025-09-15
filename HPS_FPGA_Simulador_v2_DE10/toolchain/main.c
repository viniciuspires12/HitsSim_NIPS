// change_memory.c — preenche 0..126 (=indice) e pergunta qual indice será lido (armazenado em 0x7F)
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>

#define LW_BRIDGE_BASE  0xFF200000UL   // Base do LW bridge (HPS→FPGA)
#define OCC_RAM_OFFSET  0x00000000UL   // Offset da On-Chip RAM s1
#define OCC_RAM_SPAN    0x00000080UL   // 128 bytes
#define IDX_ADDR        0x7F           // célula reservada para o índice

static void clear_stdin(void){
    int c; while ((c = getchar()) != '\n' && c != EOF) {}
}

int main(void) {
    int fd = open("/dev/mem", O_RDWR | O_SYNC);
    if (fd < 0) { perror("open(/dev/mem)"); return 1; }

    long pagesz = sysconf(_SC_PAGESIZE);
    off_t phys  = (off_t)(LW_BRIDGE_BASE + OCC_RAM_OFFSET);
    off_t page  = phys & ~(pagesz - 1);
    off_t off   = phys - page;

    void *map = mmap(NULL, pagesz, PROT_READ | PROT_WRITE, MAP_SHARED, fd, page);
    if (map == MAP_FAILED) { perror("mmap"); close(fd); return 1; }

    volatile uint8_t *ram = (volatile uint8_t *)((uint8_t*)map + off);

    // 1) Inicializa tabela: addr i (0..126) recebe valor i
    for (int i = 0; i < 0x7F; i++) ram[i] = (uint8_t)i;

    // 2) Loop: usuário escolhe o índice (0..126) que o simulador deve ler
    while (1) {
        int idx;
        printf("Escolha o indice a ser lido (0..126) ou -1 para sair: ");
        if (scanf("%d", &idx) != 1) { clear_stdin(); puts("Entrada inválida."); continue; }
        if (idx == -1) break;
        if (idx < 0 || idx > 126) { puts("Indice fora do intervalo."); continue; }

        ram[IDX_ADDR] = (uint8_t)idx;          // grava índice em 0x7F
        uint8_t occ   = ram[idx];              // valor que o simulador lerá
        printf("Setado indice=%d em 0x%08lX; ocupacao=%u (0x%02X) no addr 0x%08lX\n",
               idx,
               (unsigned long)(LW_BRIDGE_BASE + OCC_RAM_OFFSET + IDX_ADDR),
               occ, occ,
               (unsigned long)(LW_BRIDGE_BASE + OCC_RAM_OFFSET + idx));
    }

    munmap(map, pagesz);
    close(fd);
    return 0;
}

