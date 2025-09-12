# Makefile universal (Linux: GCC / mac: Zig)
TARGET ?= change_memory_test
SRC    ?= main.c

GCC_ARM := $(shell command -v arm-linux-gnueabihf-gcc 2>/dev/null)
ZIG     := $(shell command -v zig 2>/dev/null)

ifeq ($(GCC_ARM),)
  ifeq ($(ZIG),)
    $(error Nenhum cross-compiler encontrado. Instale zig (brew install zig))
  else
    # Zig -> ARM Linux (musl) estático
    ZIG_TARGET := arm-linux-musleabihf
    CC      := zig cc
    CFLAGS  := -target $(ZIG_TARGET) -O2 -g -std=gnu99 -Wall
    LDFLAGS := -target $(ZIG_TARGET) -static -s
    TOOL    := zig (arm-linux-musleabihf, static)
  endif
else
  # Linux -> GCC ARM (glibc) estático
  CC      := arm-linux-gnueabihf-gcc
  CFLAGS  := -O2 -g -std=gnu99 -Wall
  LDFLAGS := -static -s
  TOOL    := arm-linux-gnueabihf-gcc (static)
endif

all: $(TARGET)
$(TARGET): $(SRC)
	@echo ">> Toolchain: $(TOOL)"
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

clean:
	rm -f $(TARGET)

.PHONY: all clean

