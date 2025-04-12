#include <stdint.h>

struct IDTEntry {
    uint16_t base_low;
    uint16_t selector;
    uint8_t  zero;
    uint8_t  type_attr;
    uint16_t base_high;
} __attribute__((packed));

struct IDTPointer {
    uint16_t limit;
    uint32_t base;
} __attribute__((packed));

struct IDTEntry idt[IDT_ENTRIES];
struct IDTPointer idt_ptr;

void set_idt_entry(int n, uint32_t handler) {
    idt[n].base_low = handler & 0xFFFF;
    idt[n].selector = 0x08; // Kernel code segment selector (usually 0x08)
    idt[n].zero = 0;
    idt[n].type_attr = 0x8E; // Present, ring 0, 32-bit interrupt gate
    idt[n].base_high = (handler >> 16) & 0xFFFF;
}

void init_idt() {
    for (int i = 0; i < 256; i++) {
        uintptr_t handler_addr = (uintptr_t) dummy_handler;
        idt[i].offset_low = handler_addr & 0xFFFF;
        idt[i].selector = 0x08; // kernel code segment
        idt[i].zero = 0;
        idt[i].type_attr = 0x8E; // present, ring 0, 32-bit interrupt gate
        idt[i].offset_high = (handler_addr >> 16) & 0xFFFF;
    }

    idt_ptr.limit = sizeof(idt) - 1;
    idt_ptr.base = (uintptr_t) &idt;

    asm volatile("lidtl (%0)" : : "r" (&idt_ptr));
    asm volatile("sti");
}










void dummy_handler() {
	asm volatile("iret");
}








void kernel_main() {
	init_idt();

	const char *message = "Eris Booting...";
	volatile char *video = (volatile char *) 0xB8000;

	for (int i = 0; message[i] != '\0'; i++) {
		video[i * 2] = message[i];
		video[i * 2 + 1] = 0x07;
	}

	while(1) {
		asm volatile("hlt");
	}
}
