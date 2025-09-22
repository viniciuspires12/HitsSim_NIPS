// change_memory_plus_energy.c
// 1) Grava 3 RAMs de energia (1024x16) a partir de TXT ou fallback (valor=endereço)
// 2) Implementa a OCC RAM (8-bit, 128 bytes) como no exemplo: escreve idx em 0x7F e mostra valor.
//
// Compilar: gcc -O2 -Wall -Wextra -o change_memory_plus_energy change_memory_plus_energy.c
// Rodar:    sudo ./change_memory_plus_energy
//
// Ajuste os OFF_ abaixo conforme seu Qsys (LW bridge):
//  - OCC RAM s1:   OFFSET e SPAN de 128 bytes (0x80)
//  - Energia RAMs: offsets usados antes (1k/2k/4k). Se diferentes, altere #defines.

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <ctype.h>
#include <errno.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/mman.h>
#include <sys/stat.h>

#define LW_BASE        0xFF200000UL

// --- OCC RAM (8-bit), 128 bytes (0x80) ---
#define OCC_RAM_OFFSET 0x00000000UL   // ajuste se diferente no seu Qsys
#define OCC_RAM_SPAN   0x00000080UL   // 128 bytes
#define IDX_ADDR       0x7F           // célula reservada ao índice

// --- Energy RAMs (16-bit), 1024 words (2KB cada) ---
#define ENG1_OFF       0x00001000UL
#define ENG2_OFF       0x00002000UL
#define ENG3_OFF       0x00004000UL
#define ENG_DEPTH      1024
#define PGSZ           4096UL

static int trim(char *s){
    size_t n=strlen(s);
    while(n && (s[n-1]=='\n'||s[n-1]=='\r'||isspace((unsigned char)s[n-1]))) s[--n]=0;
    size_t i=0; while(s[i]&&isspace((unsigned char)s[i])) i++;
    if(i) memmove(s,s+i,n-i+1);
    char *p=strstr(s,"//"); if(p) *p=0;
    p=strchr(s,'#'); if(p) *p=0;
    n=strlen(s); while(n && isspace((unsigned char)s[n-1])) s[--n]=0;
    return (int)n;
}

// Lê TXT: aceita binário puro (0001..), decimal, hex (0x....)
static int load_txt16(const char* path, uint16_t *dst){
    FILE *f=fopen(path,"r");
    if(!f) return -1; // deixa o caller decidir fallback
    char line[256]; size_t idx=0;
    while(fgets(line,sizeof(line),f)){
        if(!trim(line)) continue;
        char *s=line; int base=0;
        if(s[0]=='0'&&(s[1]=='b'||s[1]=='B')){ s+=2; base=2; }
        else{
            int bin=1; for(char *p=s; *p; ++p){ if(*p!='0'&&*p!='1'){bin=0;break;} }
            if(bin) base=2;
        }
        char *endp=NULL; unsigned long v=strtoul(s,&endp,base);
        if(endp==s || v>0xFFFFUL){ fclose(f); return -1; }
        if(idx>=ENG_DEPTH){ fclose(f); return -1; }
        dst[idx++]=(uint16_t)v;
    }
    fclose(f);
    return (idx==ENG_DEPTH) ? 0 : -1;
}

static void clear_stdin(void){ int c; while ((c=getchar())!='\n' && c!=EOF){} }

// mapeia uma janela (página) do LW
static void* map_phys(off_t phys, size_t span){
    int fd=open("/dev/mem",O_RDWR|O_SYNC);
    if(fd<0){ perror("open(/dev/mem)"); return NULL; }
    long pagesz = sysconf(_SC_PAGESIZE);
    off_t page = phys & ~(pagesz - 1);
    off_t off  = phys - page;
    size_t mapsz = ((off + span + pagesz-1)/pagesz)*pagesz;
    void *m=mmap(NULL,mapsz,PROT_READ|PROT_WRITE,MAP_SHARED,fd,page);
    if(m==MAP_FAILED){ perror("mmap"); close(fd); return NULL; }
    close(fd);
    return (uint8_t*)m + off;
}

int main(void){
    // ===== 1) Gravar memórias de energia =====
    uint16_t e1[ENG_DEPTH], e2[ENG_DEPTH], e3[ENG_DEPTH];

    int ok1 = (load_txt16("valores_energia1.txt", e1)==0);
    int ok2 = (load_txt16("valores_energia2.txt", e2)==0);
    int ok3 = (load_txt16("valores_energia3.txt", e3)==0);

    if(!ok1 || !ok2 || !ok3){
        // fallback: valor = endereço
        for(int i=0;i<ENG_DEPTH;i++){ e1[i]=i; e2[i]=i; e3[i]=i; }
        printf("TXT não encontrados/invalidos -> usando fallback valor=endereco.\n");
    } else {
        printf("Carregados TXT valores_energia{1,2,3}.txt.\n");
    }

    volatile uint16_t *ram1 = (volatile uint16_t*) map_phys(LW_BASE+ENG1_OFF, ENG_DEPTH*2);
    volatile uint16_t *ram2 = (volatile uint16_t*) map_phys(LW_BASE+ENG2_OFF, ENG_DEPTH*2);
    volatile uint16_t *ram3 = (volatile uint16_t*) map_phys(LW_BASE+ENG3_OFF, ENG_DEPTH*2);
    if(!ram1||!ram2||!ram3){ fprintf(stderr,"Falha ao mapear RAMs de energia\n"); return 1; }

    for(int i=0;i<ENG_DEPTH;i++){ ram1[i]=e1[i]; ram2[i]=e2[i]; ram3[i]=e3[i]; }
    __sync_synchronize();
    printf("OK: gravadas %d palavras em cada RAM de energia.\n", ENG_DEPTH);

    // ===== 2) OCC RAM como no exemplo =====
    volatile uint8_t *occ = (volatile uint8_t*) map_phys(LW_BASE+OCC_RAM_OFFSET, OCC_RAM_SPAN);
    if(!occ){ fprintf(stderr,"Falha ao mapear OCC RAM\n"); return 1; }

    // (2.1) inicializa 0..126
    for (int i=0; i<0x7F; i++) occ[i]=(uint8_t)i;

    // (2.2) loop interativo: escreve índice em 0x7F e mostra ocupação daquele índice
    while (1) {
        int idx;
        printf("Escolha o indice (0..126) ou -1 para sair: ");
        if (scanf("%d", &idx) != 1) { clear_stdin(); puts("Entrada invalida."); continue; }
        if (idx == -1) break;
        if (idx < 0 || idx > 126) { puts("Fora do intervalo."); continue; }

        occ[IDX_ADDR] = (uint8_t)idx;      // armazena índice em 0x7F
        uint8_t occv  = occ[idx];          // valor que o simulador deve ler
        printf("Indice=%d gravado em 0x%08lX; OCC[%d]=%u (0x%02X)\n",
               idx,
               (unsigned long)(LW_BASE+OCC_RAM_OFFSET+IDX_ADDR),
               idx, occv, occv);
    }

    printf("Finalizado.\n");
    return 0;
}
