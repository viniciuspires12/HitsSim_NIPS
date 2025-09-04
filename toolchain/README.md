# toolchain

Ferramentas e exemplos para **compilar no host**, **enviar para a DE10-Nano** e **executar**.

## Requisitos
- Host Linux/macOS/WSL.
- **Cross-compiler ARM** (ex.: `arm-linux-gnueabihf-gcc`).  
  > Ajuste o caminho do seu toolchain (Linaro/SoC EDS).  
- Placa na rede (SSH ativo). Padrão desta imagem: **login** `root` | **senha** `simhits`.

## Estrutura (sugerida)
```
toolchain/
├─ examples/        # códigos de exemplo (C)
├─ bin/             # saídas (.elf)
└─ Makefile         # alvos: build / deploy / clean
```

## Variáveis úteis (no terminal do host)
```bash
export BOARD_IP=192.168.0.120     # IP da sua placa
export BOARD_USER=root
export DEST=/usr/local/bin        # destino na placa
export CROSS=arm-linux-gnueabihf- # prefixo do cross-compiler
```

## Compilar (opção A — Makefile)
Na pasta `toolchain/`:
```bash
make CROSS=${CROSS}               # compila tudo em examples/ → bin/
make deploy IP=${BOARD_IP} USER=${BOARD_USER} DEST=${DEST}   # envia via scp
```

### Exemplo de Makefile mínimo
```make
# Use: make CROSS=arm-linux-gnueabihf-  (ou ajuste abaixo)
CROSS ?=
CC := $(CROSS)gcc
CFLAGS := -O2 -Wall
SRC := $(wildcard examples/*.c)
BIN := $(patsubst examples/%.c,bin/%,$(SRC))

all: $(BIN)

bin/%: examples/%.c | bin
	$(CC) $(CFLAGS) -o $@ $<

bin:
	mkdir -p bin

deploy: all
	@[ -n "$(IP)" ] && [ -n "$(USER)" ] && [ -n "$(DEST)" ] || \
	 (echo "Use: make deploy IP=... USER=... DEST=..."; exit 1)
	scp -q bin/* $(USER)@$(IP):$(DEST)/

clean:
	rm -rf bin
```

## Compilar (opção B — comando direto)
```bash
${CROSS}gcc -O2 -Wall -o bin/capture_samples examples/capture_samples.c
scp bin/capture_samples ${BOARD_USER}@${BOARD_IP}:${DEST}/
```

> Verifique a arquitetura do binário: `file bin/capture_samples` → deve mostrar **ARM**/**EABI**.

## Alternativa: compilar **na placa**
```bash
scp examples/capture_samples.c ${BOARD_USER}@${BOARD_IP}:/root/
ssh ${BOARD_USER}@${BOARD_IP} 'gcc -O2 -Wall -o /usr/local/bin/capture_samples /root/capture_samples.c'
```

## Executar na placa (SSH)
```bash
ssh ${BOARD_USER}@${BOARD_IP}
chmod +x ${DEST}/capture_samples
${DEST}/capture_samples   # rode o programa
```

## Dicas / Troubleshooting
- **“Exec format error”**: compilou para x86. Use o **cross** correto (`arm-linux-gnueabihf-`).
- **“Permission denied”**: adicione `chmod +x` no destino; evite montar `/` com `noexec`.
- **Acesso a registradores**: se usar `/dev/mem`, rode como **root** e garanta **bridges** habilitadas:
  ```bash
  for b in fpga2hps hps2fpga lwhps2fpga; do echo 1 | tee /sys/class/fpga_bridge/$b/enable; done
  ```
- **Transferir várias vezes**: use `rsync -avP bin/ ${BOARD_USER}@${BOARD_IP}:${DEST}/`.

> Veja `linux_image/README.md` para criar o SD, achar o IP e credenciais de acesso.
