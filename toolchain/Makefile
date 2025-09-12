# ===== Config =====
TARGET  := change_memory
CSRCS   := main.c

# Toolchain ARM hard-float
ARCH    ?= arm-linux-gnueabihf
CC      := $(ARCH)-gcc
LD      := $(ARCH)-gcc
SIZE    := $(ARCH)-size

# Sysroot (copiado da placa: /lib, /usr/lib, /usr/include)
SYSROOT ?= $(HOME)/de10-sysroot
DYNLD   ?= /lib/ld-linux-armhf.so.3

# Flags
CFLAGS  := -O2 -g -std=gnu99 -Wall --sysroot=$(SYSROOT)
LDFLAGS := -O2 -g -Wall --sysroot=$(SYSROOT) \
           -Wl,-rpath-link,$(SYSROOT)/lib -Wl,-rpath-link,$(SYSROOT)/usr/lib \
           -L$(SYSROOT)/lib -L$(SYSROOT)/usr/lib \
           -Wl,--dynamic-linker=$(DYNLD)

# (Opcional) Se usar hwlib/hps_0.h, habilite e ajuste caminho:
# ALT_DEVICE_FAMILY := soc_cv_av
# HWLIBS_ROOT      ?= $(SOCEDS_DEST_ROOT)/ip/altera/hps/altera_hps/hwlib
# CFLAGS           += -I$(HWLIBS_ROOT)/include -I$(HWLIBS_ROOT)/include/$(ALT_DEVICE_FAMILY) -D$(ALT_DEVICE_FAMILY)

# ===== Build dirs =====
BUILDDIR := build
OBJDIR   := $(BUILDDIR)/obj
OBJS     := $(addprefix $(OBJDIR)/,$(CSRCS:.c=.o))

# ===== Targets =====
all: build size

build: builddirs $(BUILDDIR)/$(TARGET)

builddirs:
	@mkdir -p $(BUILDDIR) $(OBJDIR)

$(BUILDDIR)/$(TARGET): $(OBJS)
	@echo Linking $@
	@$(LD) $(LDFLAGS) -o $@ $(OBJS)

$(OBJDIR)/%.o: %.c
	@mkdir -p $(dir $@)
	@echo Compiling $<
	@$(CC) $(CFLAGS) -c -o $@ $<

size: $(BUILDDIR)/$(TARGET)
	@echo; $(SIZE) $^

clean:
	@rm -rf $(BUILDDIR) *.o *~ $(TARGET) $(TARGET).*

.PHONY: all build clean size builddirs
