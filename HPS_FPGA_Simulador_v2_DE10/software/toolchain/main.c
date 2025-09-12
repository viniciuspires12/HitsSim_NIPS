// set_occ_idx.c — escreve 1 byte em qualquer índice (0..127) da OCC RAM
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>

#define LW_BRIDGE_BASE  0xFF200000UL   // Base do LW bridge
#define OCC_RAM_OFFSET  0x00000000UL   // Base da occ_ram_s1 dentro do LW
#define OCC_RAM_SPAN    0x00000080UL   // 128 bytes

int main(int argc, char **argv) {
    if (argc != 3) {
        fprintf(stderr, "Uso: sudo %s <indice 0..127> <valor 0..255>\n", argv[0]);
        return 1;
    }

    char *e1=NULL, *e2=NULL;
    unsigned long idx = strtoul(argv[1], &e1, 0);
    unsigned long val = strtoul(argv[2], &e2, 0);
    if (*e1 || *e2 || idx > 127 || val > 255) {
        fprintf(stderr, "Parâmetros inválidos.\n");
        return 1;
    }

    int fd = open("/dev/mem", O_RDWR | O_SYNC);
    if (fd < 0) { perror("open(/dev/mem)"); return 1; }

    long pagesz = sysconf(_SC_PAGESIZE);
    off_t phys  = (off_t)(LW_BRIDGE_BASE + OCC_RAM_OFFSET);
    off_t base_page = phys & ~(pagesz - 1);
    off_t page_off  = phys - base_page;

    void *map = mmap(NULL, pagesz, PROT_READ | PROT_WRITE, MAP_SHARED, fd, base_page);
    if (map == MAP_FAILED) { perror("mmap"); close(fd); return 1; }

    volatile uint8_t *ram = (volatile uint8_t *)((uint8_t*)map + page_off);

    ram[idx] = (uint8_t)val;             // escreve
    uint8_t rb = ram[idx];               // lê de volta

    printf("Addr 0x%08lX (idx %lu): escrito %u (0x%02X), lido %u (0x%02X)\n",
           (unsigned long)(LW_BRIDGE_BASE + OCC_RAM_OFFSET + idx), idx,
           (unsigned)val, (unsigned)val, rb, rb);

    munmap(map, pagesz);
    close(fd);
    return 0;
}
