ASM=nasm

SRC_DIR=src
BUILD_DIR=build


.PHONY: all floppy_image kernel bootloader clean always


#
# FLOPPY IMAGE
#
floppy_image: $(BUILD_DIR)/main.img

$(BUILD_DIR)/main.img: bootloader kernel
	dd if=/dev/zero of=$(BUILD_DIR)/main.img bs=512 count=2880
	mkfs.fat -F 12 -n "NBOS" $(BUILD_DIR)/main.img
	dd if=$(BUILD_DIR)/bootloader.bin of=$(BUILD_DIR)/main.img conv=notrunc
	mcopy -i $(BUILD_DIR)/main.img $(BUILD_DIR)/kernel.bin "::kernel.bin"




#
# BOOTLOADER
#
bootloader: $(BUILD_DIR)/bootloader.bin

$(BUILD_DIR)/bootloader.bin: always
	$(ASM) $(SRC_DIR)/bootloader/boot.asm -f bin -o $(BUILD_DIR)/bootloader.bin




#
# KERNEL
#
kernel: $(BUILD_DIR)/kernel.bin

$(BUILD_DIR)/kernel.bin: always
	$(ASM) $(SRC_DIR)/main.asm -f bin -o $(BUILD_DIR)/kernel.bin



$(BUILD_DIR)/main.bin: $(SRC_DIR)/main.asm
	$(ASM) $(SRC_DIR)/main.asm -f bin -o $(BUILD_DIR)/main.bin

always:
	mkdir -p $(BUILD_DIR)

run: $(BUILD_DIR)/main.img
	qemu-system-x86_64 -drive file=$(BUILD_DIR)/main.img,format=raw -nographic

clean:
	rm -rf $(BUILD_DIR)/*
