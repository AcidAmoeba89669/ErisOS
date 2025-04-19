ASM=nasm
CC=gcc

SRC_DIR=src
TOOLS_DIR=tools
BUILD_DIR=build

.PHONY: all floppy_image kernel bootloader clean always tools_fat

all: floppy_image tools_fat

#
# Floppy image
#
floppy_image: $(BUILD_DIR)/main.img

$(BUILD_DIR)/main.img: bootloader kernel
	dd if=/dev/zero of=$(BUILD_DIR)/main.img bs=512 count=2880
	mkfs.fat -F 12 -n "ERIS" $(BUILD_DIR)/main.img
	dd if=$(BUILD_DIR)/stage_1.bin of=$(BUILD_DIR)/main.img conv=notrunc
	mcopy -i $(BUILD_DIR)/main.img $(BUILD_DIR)/stage_2.bin "::stage_2.bin"
	mcopy -i $(BUILD_DIR)/main.img $(BUILD_DIR)/kernel.bin "::kernel.bin"
	mcopy -i $(BUILD_DIR)/main.img test.txt "::test.txt"

#
# Bootloader
#
bootloader: stage_1 stage_2

stage_1: $(BUILD_DIR)/stage_1.bin

$(BUILD_DIR)/stage_1.bin: always
	$(MAKE) -C $(SRC_DIR)/bootloader/stage_1 BUILD_DIR=%(abspath $(BUILD_DIR))


stage_2: $(BUILD_DIR)/stage_2.bin

$(BUILD_DIR)/stage_2.bin: always
	$(MAKE) -C $(SRC_DIR)/bootloader/stage_2 BUILD_DIR=%(abspath $(BUILD_DIR))

#
# Kernel
#
kernel: $(BUILD_DIR)/kernel.bin

$(BUILD_DIR)/kernel.bin: always
	$(MAKE) -C $(SRC_DIR)/kernel BUILD_DIR=%(abspath $(BUILD_DIR))

#
# Tools
#
tools_fat: $(BUILD_DIR)/tools/fat
$(BUILD_DIR)/tools/fat: always $(TOOLS_DIR)/fat/fat.c
	mkdir -p $(BUILD_DIR)/tools
	$(CC) -g -o $(BUILD_DIR)/tools/fat $(TOOLS_DIR)/fat/fat.c

#
# Always
#
always:
	mkdir -p $(BUILD_DIR)

#
# Clean
#
clean:
	rm -rf $(BUILD_DIR)/*

#
# Run
#
run:
	qemu-system-x86_64 -drive file=$(BUILD_DIR)/main.img,format=raw -nographic
