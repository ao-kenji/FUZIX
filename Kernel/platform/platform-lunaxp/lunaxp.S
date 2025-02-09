;
;	    LUNA XP support
;
;	This first chunk is mostly boilerplate to adjust for each
;	system.
;
	.z180

	; exported symbols
	.export init_early
	.export init_hardware
	.export _program_vectors
	.export map_buffers
	.export map_kernel
	.export map_kernel_di
	.export map_kernel_restore
	.export map_proc
	.export map_proc_a
	.export map_proc_always
	.export map_proc_always_di
	.export map_save_kernel
	.export map_restore
	.export map_for_swap
	.export plt_interrupt_all
	.export _kernel_flag
	.export _int_disabled
	.export z180_irq3
	.export z180_irq8
	.export z180_irq9
	.export z180_irq_unused
	.export _z180_timer_interrupt
	.export _tty_poll_asci0
	.export _tty_out_asci0
	.export _tty_poll_asci1
	.export _tty_out_asci1

	; exported debugging tools
	.export _plt_monitor
	.export _plt_reboot
	.export outchar

#include "kernel.def"
#include "z180.def"
#include "../../cpu-z80u/kernel-z80.def"

;
; Buffers (we use asm to set this up as we need them in a special segment
; so we can recover the discard memory into the buffer pool
;

	.export _bufpool
	.buffers

_bufpool:
	.ds BUFSIZE * NBUFS

; -----------------------------------------------------------------------------
; COMMON MEMORY BANK (kept even when we task switch)
; -----------------------------------------------------------------------------
	.common
;
;	Interrupt flag. This needs to be in common memory for most memory
;	models. It starts as 1 as interrupts start off.
;
_int_disabled:
	.byte 1
;
;	This method is invoked early in interrupt handling before any
;	complex handling is done. It's useful on a few platforms but
;	generally a ret is all that is needed
;
plt_interrupt_all:
	ret

;
;	If you have a ROM monitor you can get back to then do so, if not
;	fall into reboot.
;
_plt_monitor:
;
;	Reboot the system if possible, halt if not. On a system where the
;	ROM promptly wipes the display you may want to delay or wait for
;	a keypress here (just remember you may be interrupts off, no kernel
;	mapped so hit the hardware).
;
_plt_reboot:
	ld hl, msg_halted
	call outstring
	di
	ld a, 1
	ld (_xpfe_halted), a
	halt

msg_halted:
	.ascii "XP halted."
	.byte 13, 10, 0
;
; HD647180(Z180) ASCI[01] in/out
;
; void tty_poll_asci0(void)
;
_tty_poll_asci0:
__tpa0_1:
	in0 a, ASCI_STAT0
	and 0x80
	jr z, __tpa0_2

	in0 l, ASCI_RDR0
	ld h,0
	push hl			; received character (2nd arg)

	ld hl, 0x0002
	push hl			; tty2 (1st arg)

	call _tty_inproc	; tty_inproc(2, char)
	pop hl
	pop hl
	jr __tpa0_1

__tpa0_2:
	in0 a, ASCI_STAT0
	and 0x70
	jr nz, __tpa0_3

	in0 a, ASCI_CNTLA0
	and 0xf7		; clear bit3
	out0 ASCI_CNTLA0, a

__tpa0_3:
	ret
;
; void tty_out_asci0(unsigned char)
;
_tty_out_asci0:
	pop hl
	pop de
	push de		; E has the arg1, i.e. output char.
	push hl
			; we do not use BC, so no need to save BC
__toa0_1:
	in0 a, ASCI_STAT0
	and 0x02
	jr z, __toa0_1

	out0 ASCI_TDR0, e
	ret
;
; void tty_poll_asci1(void)
;
_tty_poll_asci1:
__tpa1_1:
	in0 a, ASCI_STAT1
	and 0x80
	jr z, __tpa1_2

	in0 l, ASCI_RDR1
	ld h,0
	push hl			; received character (2nd arg)

	ld hl, 0x0003
	push hl			; tty3 (1st arg)

	call _tty_inproc	; tty_inproc(3, char)
	pop hl
	pop hl
	jr __tpa1_1

__tpa1_2:
	in0 a, ASCI_STAT1
	and 0x70
	jr nz, __tpa1_3

	in0 a, ASCI_CNTLA1
	and 0xf7		; clear bit3
	out0 ASCI_CNTLA1, a

__tpa1_3:
	ret
;
; void tty_out_asci1(unsigned char)
;
_tty_out_asci1:
	pop hl
	pop de
	push de		; E has the arg1, i.e. output char.
	push hl
			; we do not use BC, so no need to save BC
__toa1_1:
	in0 a, ASCI_STAT1
	and 0x02
	jr z, __toa1_1

	out0 ASCI_TDR1, e
	ret
; -----------------------------------------------------------------------------
; KERNEL MEMORY BANK (may be below 0x8000, only accessible when the kernel is
; mapped)
; -----------------------------------------------------------------------------
	.code

;	This routine is called very early, before the boot code shuffles
;	things into place. We do the ttymap here mostly as an example but
;	even that really ought to be in init_hardware.
;
init_early:
;	I/O control register
;	 - internal I/O address: 0000H - 003FH
	xor a
	out0 IO_ICR, a

;	DMA/WAIT control register
;	 - no memory wait
;	 - 3 external I/O wait
;	 - disable DMA
	ld a, 0x20
	out0 DMA_DCNTL, a

;	refresh control register
;	 - disable refresh controller (HD647180 on LUNA uses SRAM)
;	 - cycle interval 80 states (recommended for 6.144MHz clock)
	ld a, 0x03
	out0 MEM_RCR, a

;	set MMU control registers
;	CBAR(3AH) = 80H
;	 - map 3port RAM first 32k to BANK, next 32k to COMMON1
	ld a, 0x80
	out0 MMU_CBAR, a

;	CBR(38H) = 00H
;	 - common1 area
	xor a
	out0 MMU_CBR, a

;	BBR(39H) = 00H
;	 - bank area
	out0 MMU_BBR, a

	ret

; -----------------------------------------------------------------------------
; DISCARD is memory that will be recycled when we exec init
; -----------------------------------------------------------------------------
	.discard
;
;	After the kernel has shuffled things into place this code is run.
;	It's the best place to breakpoint or trace if you are not sure your
;	kernel is loading and putting itself into place properly.
;
;	It's required jobs are to set up the vectors, ramsize (total RAM),
;	and procmem (total memory free to processs), as well as setting the
;	interrupt mode but *not* enabling interrupts. Many platforms also
;	program up support hardware like PIO and CTC devices here.
;
init_hardware:
#ifdef LUNAXP_USE_LANCE_MEM
	ld hl,128	; 0x00000-0x0ffff, 0x18000-0x1ffff, 0x28000-0x28fff
#else
	ld hl,96	; 0x00000-0x0ffff, 0x28000-0x28fff
#endif
	ld (_ramsize), hl
	ld de,64		; and 64K for kernel
	or a
	sbc hl,de
	ld (_procmem), hl

	; set up interrupt vectors for the kernel
	ld hl, 0
	push hl
	call _program_vectors
	pop hl

	; Compiler helper vectors - in kernel bank only

	ld	hl,rstblock
	ld	de,8
	ld	bc,32
	ldir

;
;	Set up system tick timer
;

;	Disable Timer Ch0
	xor a
	out0 TIME_TCR, a

;	Set RDLR0L and RDLR0H
;	The value is calculated by:
;	  CPU_CLOCK_KHZ * 1000 / Z180_TIMER_SCALE / TICKSPERSEC - 1
;	  = 6144 * 1000 / 20 / 40 - 1 = 7679 = 0x1dff
	ld hl, 0x1dff
	out0 TIME_RLDR0L, l
	out0 TIME_RLDR0H, h

;	Enable Timer Ch0
	ld a, 0x11			; enable downcounting & interrupt
	out0 TIME_TCR, a

;	Set up ASCI Control Register A (channel 0 and 1)
;	  Enable receiver(bit 6) and transmitter(bit 5)
;	  /RTS0 (Request to send) / CKA1D (bit 4)
;	  Clear errors (bit 3)
;	  8bit, no parity, 1 stop bit (bit 2-0)

	ld a, 0x64
	out0 ASCI_CNTLA0, a		; for channel 0
	out0 ASCI_CNTLA1, a		; for channel 1

;	Set up ASCI Control Register B (channel 0 and 1)
;	  PreScale = x10 (bit 5)
;	  Rate = 16 (bit 3)
;	  Baud Rate = 9600 (bit 2-0) with internal clock 6.144MHz

	ld a, 0x02
	out0 ASCI_CNTLB0, a		; for channel 0
	out0 ASCI_CNTLB1, a		; for channel 1

;	Set up ASCI Status Register 0
;	  Receive interrupt enable (bit 3)

	ld a, 0x08
	out0 ASCI_STAT0, a		; for channel 0
	out0 ASCI_STAT1, a		; for channel 1

;	If we enable ITE1, it seems to hang up at "Enabling interrupts ... "
;	in fuzix_main() on the real LUNA XP hardware.

;	set Interrupt/TRAP control reg
;	 - enable interrupt ITE0 (for now)
	ld a, 0x01
	out0 INT_ITC, a

	im 1 ; set CPU interrupt mode for INT0

	ret

;
;	Bank switching unsurprisingly must be in common memory space so it's
;	always available.
;
	.common

mapreg:
	.byte 0	; Our map register is write only so keep a copy
mapsave:
	.byte 0	; Saved copy of the previous map (see map_save)

_kernel_flag:
	.byte 1	; We start in kernel mode

;
;	This is invoked with a NULL argument at boot to set the kernel
;	vectors and then elsewhere in the kernel when the kernel knows
;	a bank may need vectors writing to it.
;
_program_vectors:
	; we are called, with interrupts disabled, by both newproc() and crt0
	; will exit with interrupts off
	di ; just to be sure
	pop de ; temporarily store return address
	pop hl ; function argument -- base page number
	push hl ; put stack back as it was
	push de

	call map_proc

	; now install the interrupt vector at 0x0038
	ld a, 0xC3 ; JP instruction
	ld (0x0038), a
	ld hl, interrupt_handler
	ld (0x0039), hl

	; set restart vector for FUZIX system calls
	ld (0x0030), a   ;  (rst 30h is unix function call vector)
	ld hl, unix_syscall_entry
	ld (0x0031), hl

	ld (0x0000), a
	ld hl, null_handler   ;   to Our Trap Handler
	ld (0x0001), hl

	; program HD647180(Z180) interrupt table registers
	ld hl, _interrupt_table ; note table MUST be 32-byte aligned!
	out0 INT_IL, l
	ld a, h
	ld i, a

	; and fall into map_kernel

;
;	Mapping set up for LUNA XP
;
;	The top 32K bank holds kernel code and pieces of common memory
;	The lower 32K is switched between the various user banks.
;
;	The _di versions of the functions are called when we know interrupts
;	are definitely off. In our case it's not useful information so both
;	symbols end up at the same code.
;
map_buffers:
	; for us no difference. We could potentially use a low 32K bank
	; for buffers but it's not clear it would gain us much value
map_kernel_restore:
map_kernel_di:
map_kernel:
	push af
	xor a
	ld (mapreg),a
	out0 MMU_BBR, a
	pop af
	ret
	; map_proc is called with HL either NULL or pointing to the
	; page mapping. Unlike the other calls it's allowed to trash AF
map_proc:
	ld a, h
	or l
	jr z, map_kernel
map_proc_hl:
	ld a, (hl)			; and fall through
	;
	; With a simple bank switching system you need to provide a
	; method to switch to the bank in A without corrupting any
	; other registers. The stack is safe in common memory.
	; For swap you need to provide what for simple banking is an
	; identical routine.
map_for_swap:
map_proc_a:			; used by bankfork
	ld (mapreg), a	; bank
	out0 MMU_BBR, a
	ret

	;
	; Map the current process into memory. We do this by extracting
	; the bank value from u_page.
	;
map_proc_always_di:
map_proc_always:
	push af
	push hl
	ld hl, _udata + U_DATA__U_PAGE
	call map_proc_hl
	pop hl
	pop af
	ret

	;
	; Save the existing mapping and switch to the kernel.
	; The place you save it to needs to be in common memory as you
	; have no idea what bank is live. Alternatively defer the save
	; until you switch to the kernel mapping
	;
map_save_kernel:
	push af
	ld a, (mapreg)
	ld (mapsave), a
	xor a				; Kernel map
	ld (mapreg),a
	out0 MMU_BBR, a
	pop af
	ret
	;
	; Restore the saved bank. Note that you don't need to deal with
	; stacking of banks (we never recursively use save/restore), and
	; that we may well call save and decide not to call restore.
	;
map_restore:
	push af
	ld a, (mapsave)
	ld (mapreg), a
	out0 MMU_BBR, a
	pop af
	ret

	;
	; Used for low level debug. Output the character in A without
	; corrupting other registers. May block. Interrupts and memory
	; state are undefined
	;

outchar:
	push hl
	push af
	ld hl, _xpfe_tx_flag
__putc0:
	ld a, (hl)
	or a
	jr nz, __putc0
	dec hl		; now HL is _xpfe_tx_data
	pop af
	ld (hl), a
	inc hl		; now HL is _xpfe_tx_flag
	ld (hl), 0ffh	; set written flag
	pop hl
	ret

;
;	z180 interrupt handler
;
z180_irq3:
	push af
	ld a, 3
	; fall through -- timer is likely to be the most common,
	; we'll save it the jr
z180_irqgo:
	ld (hw_irqvector), a
	; quick and dirty way to debug which interrupt is jamming us up ...
	;    add 0x30
	;    call outchar
	pop af
	jp interrupt_handler

z180_irq8:		; ASCI0
	push af
	ld a, 8
	jr z180_irqgo

z180_irq9:		; ASCI1
	push af
	ld a, 9
	jr z180_irqgo

z180_irq_unused:
	push af
	ld a, 0xFF
	jr z180_irqgo

;
; z180 internal timer interrupt routine
;  (mimicking platform-riz180, re-written in assembler)
;
_z180_timer_interrupt:
	in0 a, TIME_TCR		; we have to read both of these registers
	in0 a, TIME_TMDR0L	; in order to reset the timer
	call _timer_interrupt
	ret

;
;	Stub helpers for code compactness: TODO

	.discard
;
;	The first two use an rst as a jump. In the reload sp case we don't
;	have to care. In the pop ix case for the function end we need to
;	drop the spare frame first, but we know that af contents don't
;	matter
;

rstblock:
