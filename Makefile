ISO_DIR = iso/boot
BUILD = build
SRC = src

all: build/eris_kernel eris.iso

build/boot.o: src/boot.s
	x86_64-elf-as $< -o $@

build/kernel.o: src/kernel.c
	x86_64-elf-gcc -ffreestanding -O2 -Wall -Wextra -m64 -c $< -o $@

build/eris_kernel: build/boot.o build/kernel.o
	x86_64-elf-ld -T linker.ld -o $@ build/boot.o build/kernel.o

eris.iso: build/eris_kernel
	mkdir -p iso/boot/grub
	mv build/eris_kernel iso/boot/
	cp grub.cfg iso/boot/grub/
	grub-mkrescue -o eris.iso iso

run: eris.iso
	qemu-system-x86_64 -cdrom eris.iso

clean:
	rm -rf build/*.o build/eris_kernel iso/boot/eris_kernel eris.iso
