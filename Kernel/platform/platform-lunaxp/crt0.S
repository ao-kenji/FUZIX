	.z180

	.code

	; Load at 0x0100
	; On reset, we are on 00000H - 0FFFFH in XP view
	.export start

start:
	di
	ld sp, kstack_top
	; move the common memory where it belongs
	ld hl, __bss
	ld de, __common
	ld bc, __common_size
	ldir
	ld de, __commondata
	ld bc, __commondata_size
	ldir
	; then the discard
	; Discard can just be linked in but is next to the buffers
	ld de, __discard
	ld bc, __discard_size-1
	add hl,bc
	ex de,hl
	add hl,bc
	ex de,hl
	lddr
	ldd

	; then zero the data area
	ld hl, __bss
	ld de, __bss + 1
	ld bc, __bss_size - 1
	ld (hl), 0
	ldir
;		Zero buffers area
	ld hl, __buffers
	ld de, __buffers + 1
	ld bc, __buffers_size - 1
	ld (hl), 0
	ldir
	call init_early
	call init_hardware
	call _fuzix_main
	di
stop:	halt
	jr stop
