# ===== Config =====
TARGET := change_memory_v2
SRC    := main.c   # ajuste se seu arquivo tiver outro nome

# Use MUSL (1=recomendado, 0=glibc estática)
USE_MUSL ?= 0

ifeq ($(USE_MUSL),1)
  # musl toolchain (baixe de https://musl.cc e ajuste o caminho abaixo)
  ARCH        := arm-linux-musleabihf
  TOOLPREFIX  ?= $(HOME)/toolchains/arm-linux-musleabihf-cross/bin
  CC          := $(TOOLPREFIX)/$(ARCH)-gcc
  LD          := $(CC)
else
  # glibc cross (requer: sudo apt install gcc-arm-linux-gnueabihf libc6-dev-armhf-cross)
  ARCH := arm-linux-gnueabihf
  CC   := $(ARCH)-gcc
  LD   := $(ARCH)-gcc
endif

CFLAGS  := -O2 -g -std=gnu99 -Wall
LDFLAGS := -static -s

all: $(TARGET)

$(TARGET): $(SRC)
	@echo "CC = $(CC)"
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

clean:
	rm -f $(TARGET)
.PHONY: all clean
