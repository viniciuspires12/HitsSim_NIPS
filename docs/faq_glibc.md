## Erro `GLIBC_2.34 not found` na DE10-Nano (Angström)

**Problema:** o binário foi compilado no PC e linkado contra uma GLIBC mais nova que a da placa.  
**Solução (sem compilar na placa):** gerar **binário estático** no PC com **musl**.

### Passo a passo (musl, recomendado)

```bash
# 1) Baixe o toolchain musl (ARMv7 hard-float)
mkdir -p ~/toolchains && cd ~/toolchains
wget https://musl.cc/arm-linux-musleabihf-cross.tgz || curl -LO https://musl.cc/arm-linux-musleabihf-cross.tgz
tar xf arm-linux-musleabihf-cross.tgz
export PATH="$PWD/arm-linux-musleabihf-cross/bin:$PATH"

# 2) Compile estaticamente seu programa (ex.: main.c)
cd /caminho/do/projeto
arm-linux-musleabihf-gcc -static -O2 -s -o change_memory main.c

# 3) Verifique que não depende de GLIBC do sistema
file change_memory
arm-linux-gnueabihf-objdump -p change_memory | grep GLIBC_ || echo "OK: sem dependências GLIBC"

# 4) Envie e rode na DE10
scp change_memory root@socfpga:/root/
ssh root@socfpga ./change_memory
```
### Makefile mínimo

```bash

TARGET := change_memory
SRC    := main.c

ARCH   ?= arm-linux-musleabihf
CC     := $(ARCH)-gcc

CFLAGS := -O2 -g -std=gnu99 -Wall
LDFLAGS:= -static -s

all: $(TARGET)

$(TARGET): $(SRC)
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

clean:
	rm -f $(TARGET)

.PHONY: all clean
```
### Diagnóstico Rápido

```bash
# Se na placa aparecer '.../libc.so.6: version GLIBC_2.34 not found', seu binário está dinâmico.
# Confira no PC:
arm-linux-gnueabihf-objdump -p change_memory | grep GLIBC_
readelf -l change_memory | grep interpreter   # binário estático NÃO mostra 'interpreter'
```
