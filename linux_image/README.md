# linux_image

Essa pasta contém a imagem Linux para a HPS (DE10-Nano) já com os programas e scripts necessários.
Grave a imagem em um cartão SD, e insira o cartão na placa. 

## Gravar a imagem no microSD

> **Atenção:** substitua os dispositivos/arquivos pelos do seu ambiente. O cartão será APAGADO.

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

## Console serial (boot log e login)

Método para acessar o sistema Linux via conexão serial.

Parâmetros: **115200 8N1**, sem fluxo de controle.

1. Conecte o cabo **USB-UART** da DE10-Nano ao PC (ou um conversor USB-TTL nos pinos UART, se for o seu caso).
2. Descubra a porta:
   - Linux: `ls /dev/ttyUSB* /dev/ttyACM*`
   - macOS: `ls /dev/tty.usb*`
   - Windows: **Gerenciador de Dispositivos** → **COMx**
3. Abra o terminal serial:
   - Linux/macOS (screen): `screen /dev/ttyUSB0 115200`
   - Linux (minicom): `sudo minicom -D /dev/ttyUSB0 -b 115200`
   - Windows: **PuTTY** → Serial → COMx @ 115200
4. Alimente a placa e acompanhe o boot. Faça login (usuário/senha da sua imagem): 
   - Usuário: root
   - Senha: simhits

> Dica: para sair do `screen`, use `Ctrl+A` depois `K` e confirme.

---

## Conexão por SSH (rede)

Método para conectar ao sistema Linux via SSH.

1. Conecte a DE10-Nano à rede via **Ethernet**.
2. Obtenha o IP:
   - Pelo serial, rode:  
     ```bash
     ip addr        # ou
     hostname -I    # ou
     connmanctl services
     ```
3. No seu computador:
   ```bash
   ssh root@<IP_DA_PLACA>
   # exemplo: ssh root@192.168.0.120
   ```
4. (Opcional) Copie arquivos:
   ```bash
   scp arquivo.bin root@<IP_DA_PLACA>:/<LOCAL_DE_DESTINO_NA_PLACA>
   ```


