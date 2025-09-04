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

## Compilar (Makefile)
Na pasta `toolchain/`:
```bash
make CROSS=${CROSS}               # compila tudo em examples/ → bin/
make deploy IP=${BOARD_IP} USER=${BOARD_USER} DEST=${DEST}   # envia via scp
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
