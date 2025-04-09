void kernel_main() {
	const char *message = "Eris Booting...";
	char *video = (char *) 0xB8000;				// VGA BUFFER START
	for (int i = 0; message[i] != '\0'; i++) {
		video[i * 2] = message[i];			// CHARACTER
		video[i * 2 + 1] = 0x07;			// ATTRIBUTE (WHITE TEXT ON BLACK BACKGROUND)
	}
	while(1) {
		
	}
}
