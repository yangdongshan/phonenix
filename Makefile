

ifeq ($(V),)
	Q = @
else
	Q :=
endif
export Q


ROOTDIR = $(shell pwd)
export ROOTDIR

SCRIPTSDIR = $(ROOTDIR)/scripts
export SCRIPTSDIR

# include system .config which is generated by make menuconfig
#-include .config

# include config
-include $(SCRIPTSDIR)/config.mk

KCONFIGDIR = $(ROOTDIR)/kconfig
KCONFIGFILE = $(ROOTDIR)/Kconfig


#CFLAGS += -include $(ROOTDIR)/include/generated/autoconf.h

ARFLAGS +=

LDFLAGS +=

ARCH_CHIP_DIR := arch/chip
ARCH_BOARD_DIR := arch/board
ARCH_BOOT_DIR := arch/boot

# library directory
LIBDIR := arch/chip \
          arch/board \
		  init \
		  libc
#LIBDIR += kernel

LIBS = $(addprefix $(ROOTDIR)/,$(foreach dir, $(LIBDIR), $(dir)/lib$(dir).a))
export LIBS

LDDIR += $(addprefix -L$(ROOTDIR)/,$(LIBDIR))
LDLIB += $(addprefix -l,$(foreach dir, $(LIBDIR), $(shell basename $(dir))))

CFLAGS += -I$(ROOTDIR)/$(ARCH_CHIP_DIR)/include \
		  -I$(ROOTDIR)/$(ARCH_CHIP_DIR)/peripherals/include \
		  -I$(ROOTDIR)/$(ARCH_BOOT_DIR)/include \
          -I$(ROOTDIR)/include \
          -I$(ROOTDIR)/libc/include

export LDDIR
export LDLIB

export CFLAGS
export ARFLAGS
export LDFLAGS

ELF=$(ROOTDIR)/$(ARCH_BOOT_DIR)/$(PROJNAME).elf
HEX=$(ROOTDIR)/$(ARCH_BOOT_DIR)/$(PROJNAME).hex
BIN=$(ROOTDIR)/$(ARCH_BOOT_DIR)/$(PROJNAME).bin
SREC=$(ROOTDIR)/$(ARCH_BOOT_DIR)/$(PROJNAME).srec
MAP=$(ROOTDIR)/$(ARCH_BOOT_DIR)/$(PROJNAME).map

all: $(ELF)

$(ELF): flink lib
	$(Q) $(MAKE) -C $(ARCH_BOOT_DIR) exe elf=$@ linker_file=$(LINKER_FILE)
	$(Q) echo "OBJCOPY $(HEX)"
	$(Q) $(OBJCOPY) -O ihex $@ $(HEX)
	$(Q) echo "OBJCOPY $(BIN)"
	$(Q) $(OBJCOPY) -O binary $@ $(BIN)
	$(Q) echo "OBJCOPY $(SREC)"
	$(Q) $(OBJCOPY) -O srec $@ $(SREC)
	$(Q) echo "NM $(MAP)"
	$(Q) $(NM) -s -S $(ELF) > $(MAP)
	$(Q) echo "================================================"
	$(Q) $(SIZE) -t $(ELF)
	$(Q) echo "================================================"

flink:
	$(Q) if [ ! -d $(ARCH_CHIP_DIR) ]; then \
			cd arch; ln -s $(ARCH)/$(CHIP)/chip chip; cd ../; \
		 fi
	$(Q) if [ ! -d $(ARCH_BOARD_DIR) ]; then \
			cd arch; ln -s $(ARCH)/$(CHIP)/$(BOARD) board; cd ../; \
		 fi
	$(Q) if [ ! -d $(ARCH_BOOT_DIR) ]; then \
		    cd arch; ln -s $(ARCH)/$(CHIP)/boot boot; cd ../; \
		 fi

lib: $(LIBDIR)
	$(Q) $(foreach dir, $(LIBDIR), \
		$(MAKE) -C $(dir) obj || exit "$$?";\
		$(MAKE) -C $(dir) lib libname=lib$(shell basename $(dir)).a || exit "$$?";)


.PHONY: menuconfig distclean silentoldconfig clean launch_qemu download

menuconfig: $(KCONFIGDIR)/mconf $(KCONFIGDIR)/conf
	$(Q) $< -s $(KCONFIGFILE)
	$(Q) $(MAKE) silentoldconfig

$(KCONFIGDIR)/mconf:
	$(Q) $(MAKE) -C $(KCONFIGDIR)

silentoldconfig: $(KCONFIGDIR)/conf
	$(Q) mkdir -p include/generated include/config
	$(Q) $< -s --silentoldconfig $(KCONFIGFILE)

clean:
	$(Q) $(foreach dir, $(ARCH_BOOT_DIR) $(LIBDIR), $(MAKE) -C $(dir) clean;)
	$(Q) -rm -f $(ELF) $(HEX) $(BIN) $(SREC) $(MAP)

distclean: clean
	#$(Q) $(MAKE) -C $(KCONFIGDIR) clean
	$(Q) -rm -rf $(ARCH_CHIP_DIR) $(ARCH_BOARD_DIR) $(ARCH_BOOT_DIR)
	$(Q) -rm -rf include/generated include/config .config

launch_qemu: $(ISO)
	$(Q) $(QEMU) -cdrom $(ISO) -nographic #-enable-kvm

download:
	$(Q) st-flash --reset write arch/boot/iotos.bin 0x8000000
