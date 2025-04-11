.section .multiboot2_header, "a", @progbits
.align 8

.long 0xE85250D6
.long 0
.long 32
.long -(0xE85250D6 + 0 + 32)

.align 8
.short 2
.short 0
.long 12
.long _start
.align 8
.short 0x8
.short 0
.long 8

.section .text
.global _start
_start:
	cli
	jmp .hang

.hang:
	hlt
	jmp .hang
