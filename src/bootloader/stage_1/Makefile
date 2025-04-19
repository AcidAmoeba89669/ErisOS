BUILD_DIR?=build/
ASM?=nasm

.PHONY: all clean

all: stage_1

stage_1: $(BUILD_DIR)/stage_1.bin

$(BUILD_DIR)/stage_1.bin:
	$(ASM) boot.asm -f bin -o $(BUILD_DIR)/stage_1.bin

clean:
	rm -f $(BUILD_DIR)/stage_1.bin
