org 0x7C00
bits 16


%define ENDL 0x0D, 0x0A

;
; FAT12 header
;
jmp short start									; Line 10
nop

bdb_oem:			db 'MSWIN4.1'		; 8 bytes
bdb_bytes_per_sector:		dw 512
bdb_sectors_per_cluster:	db 1
bdb_reserved_sectors:		dw 1
bdb_fat_count:			db 2
bdb_dir_entries_count:		dw 0E0h
bdb_total_sectors:		dw 2880			; 2880 * 512 = 1.44MB
bdb_media_descriptor_type:	db 0F0h			; F0 = 3.5" floppy disk		Line 20
bdb_sectors_per_fat:		dw 9			; 9 sectors/fat
bdb_sectors_per_track:		dw 18
bdb_heads:			dw 2
bdb_hidden_sectors:		dd 0
bdb_large_sectors:		dd 0

; Extended boot record
ebr_drive_number:		db 0			; 0x00 floppy, 0x80 hdd, useless
				db 0			; Reserved
ebr_signature:			db 29h						; Line 30
ebr_volume_id:			db 12h, 34h, 56h, 78h	; Serial number, value doesn't matter
ebr_volume_label:		db 'ERIS       '	; 11 byte string padded with spaces
ebr_system_id:			db 'FAT12   '		; 8 byte string padded with spaces


;
; Code goes here
;

										; Line 40
start:
	jmp main




;	Prints a string to the screen.
;	Params:
;	  -  ds:si points to string
										; Line 50
puts:
	; Save registers to modify
	push si
	push ax



.loop:
	lodsb					; Loads next character in al
	or al, al				; Verify if next character is null	Line 60
	jz .done

	mov ah, 0x0e				; Call BIOS interrupt
	mov bh, 0
	int 0x10

	jmp .loop


.done:										; Line 70
	pop ax
	pop si
	ret


main:
	; setup data segments
	mov ax, 0				; Can't write to ds/es directly
	mov ds, ax
	mov es, ax								; Line 80

	; Setup stack
	mov ss, ax
	mov sp, 0x7C00				; Stack grows downwards from where we are loaded in memory

	; BIOS should set DL to drive number
	mov [ebr_drive_number], dl

	mov ax, 1				; LBA = 1, second sector from disc
	mov cl, 1				; 1 sector to read		Line 90
	mov bx, 0x7E00				; Data should be afer the bootloader
	call disk_read

	; Print message
	mov si, msg_hello
	call puts

	hlt

										;Line 100
floppy_error:
	mov si, msg_read_failed
	call puts
	jmp wait_key_and_reboot


wait_key_and_reboot:
	mov ah, 0
	int 16h					; Waits for keypress
	jmp 0FFFFh:0				; jump to beggining of BIOS, should reboot	Line 110
	

.halt:
	cli					; Disables interrupts
	hlt


;
; Disk routines
;										Line 120


;
; Converts an LBA address to a CHS address
; Params:
;    -  ax: LBA address
; Returns:
;    -  cx [bits 0-5]: sector number
;    -  cx [bits 6-15]: cylinder
;    dh: head									Line 130
;

lba_to_chs:

	push ax
	push dx

	xor dx, dx				; dx = 0
	div word [bdb_sectors_per_track]	; ax = LBA / SectorsPerTrack
						; dx = LBA % SectorsPerTrack	Line 140
	
	inc dx					; dx = (LBA % SectorsPerTrack + 1) = sector
	mov cx, dx				; cx = sector

	xor dx, dx				; dx = 0
	div word [bdb_heads]			; ax = (LBA / SectorsPerTrack) / Heads = cylinder
						; dx = (LBA / SectorsPerTrack) % Heads = head
	mov dh, dl				; dx = head
	mov ch, al				; cch = cylinder (lower 8 bits)
	shl ah, 6								; Line 150
	or cl, ah				; Put upper 2 bits of cylinder in CL

	pop ax
	mov dl, al				; Restore DL
	pop ax
	ret



;										Line 160
; Reads sectors from disk
; Params:
;    -  ax: LBA address
;    -  cl: Number of sectors to read (up to 128)
;    -  es:bx: memory address where to store read data
;
disk_read:
	push ax					; Save registers to modify
	push bx
	push cx									; Line 170
	push dx
	push di

	push cx					; Temporarily saves CL (number of sectors to read)
	call lba_to_chs				; Compute CHS
	pop ax					; AL = Number of sectors to read

	mov ah, 02h
	mov di, 3				; Retry count
										; Line 180
.retry:
	pusha					; Save all registers, BIOS will modify randomly
	stc					; Set carry flag, some BIOS'es don't set it
	int 13h					; Carry flag cleared = success
	jnc .done				; Jump if carry not set

	; Read failed
	popa
	call disk_reset
										; Line 190
	dec di
	test di, di
	jnz .retry

.fail:
	; All attempts failed
	jmp floppy_error

.done:
	popa									; Line 200
	
	push di					; Restore registers modified
	push dx
	push cx
	push bx
	push ax
	ret

;
; Resets disk controller							Line 210
; Params
;    dl: drive number
;
disk_reset:
	pusha
	mov ah, 0
	stc
	int 13h
	jc floppy_error
	popa									; Line 220
	ret

msg_hello:				db 'Eris Booting...', ENDL,  0
msg_read_failed:			db 'All Attempts Exhausted. Exiting and Retrying...', ENDL, 0

times 510-($-$$) db 0
dw 0AA55h
