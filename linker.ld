ENTRY(_start)

SECTIONS {
	. = 1M;
	
	.multiboot2 : { KEEP(*(.multiboot2_header)) }
	.text : { *(.text*) }
	.rodata : { *(.rodata*) }
	.data : { *(.data*) }
	.bss : { *(.bss COMMON*) }

}
