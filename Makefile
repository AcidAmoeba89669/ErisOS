ASM=nasm

SRC_DIR=src
BUILD_DIR=build

$(BUILD_DIR)/main.img: $(BUILD_DIR)/main.bin
	cp $(BUILD_DIR)/main.bin $(BUILD_DIR)/main.img
	truncate -s 1440k $(BUILD_DIR)/main.img

$(BUILD_DIR)/main.bin: $(SRC_DIR)/main.asm
	$(ASM) $(SRC_DIR)/main.asm -f bin -o $(BUILD_DIR)/main.bin

run: $(BUILD_DIR)/main.img
	qemu-system-x86_64 -drive file=$(BUILD_DIR)/main.img,format=raw -nographic

clean:
	rm -rf build/*
