# linux_image

Essa pasta contém a imagem Linux para a HPS (DE10-Nano) já com os programas e scripts necessários.

## Passo a passo rápido (TL;DR)
1. **Crie** um cartão SD inicializável **(mín. 2 GB)** com a imagem compartilhada.  
2. **Insira** o SD na **DE10-Nano**.  
3. **MSEL**: deixe **todos os switches na posição “ON”**.  
4. **Conecte** um **cabo Ethernet** à placa.  
5. **Ligue** a placa.  
6. O **Linux inicia** e **programa automaticamente a FPGA**.  
7. **Descubra o IP** da placa (via **IP Scanner** ou pelo **console serial/COM**).  
8. **Conecte por SSH** para comunicar com a placa.  
9. **Login**: `root`  |  **Senha**: `simhits`.

---

## Gravar a imagem no microSD

> **Atenção:** substitua os dispositivos/arquivos pelos do seu ambiente. O cartão será **APAGADO**.  
> **Requisito:** microSD de **2 GB (mínimo)**.

### Linux
```bash
# Ver o dispositivo do cartão (antes/depois de inserir)
lsblk

# (Se a imagem estiver compactada .img.gz)
gzip -dc linux_image.img.gz | sudo dd of=/dev/sdX bs=4M status=progress conv=fsync

# (Se a imagem for .img)
sudo dd if=linux_image.img of=/dev/sdX bs=4M status=progress conv=fsync

sync
```

### macOS
```bash
diskutil list
diskutil unmountDisk /dev/diskN
# (Imagem .img)
sudo dd if=linux_image.img of=/dev/rdiskN bs=4m
sync
diskutil eject /dev/diskN
```

### Windows
- Use **balenaEtcher** ou **Rufus** → selecione a imagem `.img` → selecione o cartão → **Flash**.

---

## Console serial (boot log, descobrir IP e login)

Parâmetros: **115200 8N1**, sem fluxo de controle.

1. Conecte o **USB-UART** da DE10-Nano ao PC.  
2. Descubra a porta:
   - Linux: `ls /dev/ttyUSB* /dev/ttyACM*`
   - macOS: `ls /dev/tty.usb*`
   - Windows: **Gerenciador de Dispositivos** → **COMx**
3. Abra o terminal serial:
   - Linux/macOS (screen): `screen /dev/ttyUSB0 115200`
   - Linux (minicom): `sudo minicom -D /dev/ttyUSB0 -b 115200`
   - Windows: **PuTTY** → Serial → COMx @ 115200
4. **Ligue** a placa e acompanhe o boot. A imagem está configurada para **programar automaticamente a FPGA**.
5. Faça **login**:
   - **Usuário:** `root`
   - **Senha:** `simhits`
6. Para **descobrir o IP** pela serial:
   ```bash
   ip addr        # ou
   hostname -I    # ou
   connmanctl services
   ```

> Dica: para sair do `screen`, use `Ctrl+A`, depois `K` e confirme.

---

## Conexão por SSH (rede)

1. **Conecte** a DE10-Nano à **rede via Ethernet**.  
2. **Descubra o IP** (via **IP Scanner** na sua rede ou pelo **console serial**, como acima).  
3. No seu computador, conecte por **SSH**:
   ```bash
   ssh root@<IP_DA_PLACA>
   # exemplo:
   ssh root@192.168.0.120
   ```
4. Credenciais:
   - **Usuário:** `root`
   - **Senha:** `simhits`

5. (Opcional) **Copiar arquivos** para a placa:
   ```bash
   scp arquivo.bin root@<IP_DA_PLACA>:/<PASTA_DESTINO>
   ```

---

## Pós-boot (opcional)
```bash
# Habilitar bridges HPS↔FPGA (se necessário)
for b in fpga2hps hps2fpga lwhps2fpga; do echo 1 | sudo tee /sys/class/fpga_bridge/$b/enable; done
```


