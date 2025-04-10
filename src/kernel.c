void kernel_main() {
	const char *message = "Eris Booting...";
	volatile char *video = (volatile char *) 0xB8000;

	for (int i = 0; message[i] != '\0'; i++) {
		video[i * 2] = message[i];
		video[i * 2 + 1] = 0x07;
	}

	while(1) {
		
	}
}
