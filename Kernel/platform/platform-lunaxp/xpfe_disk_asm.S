/*
 * XPFE disk service (xpd, in short) I/F assembler part
 * (with reference to Kernel/dev/tinyide.c)
 */

#define _XPFE_DISK_PRIVATE

#include "kernel.def"
#include "z180.def"
#include "../../cpu-z80u/kernel-z80.def"

#ifdef CONFIG_XPFE_DISK

	.z180
	.common
	.export	_xpd_xfer_go

uaddr_save:
	.ds	2

_xpd_xfer_go:
	push bc
	ld a, (_td_raw)			; 0:kernel / 1:user / 2:swap
	or a				; test is_kernel
	jr z, kernel_xfer

#ifdef CONFIG_SWAP
	cp 2				; test is_swap
	jr nz, user_xfer
	ld a, (_td_page)		; swap page to map
	call map_for_swap
	jr pre_xfer
#endif
user_xfer:
	call map_proc_always		; map user memory first if required
pre_xfer:
	ld hl, (_xpd_addr)		; and save user address
	ld (uaddr_save), hl
	ld hl, relay_buf		; then set relay_buf
	ld (_xpd_addr), hl

	ld a, (_xpd_dir)		; which direction?
	or a
	jr z, do_xfer			; if read, no need to pre-transfer

	;;; if ((is_user || is_swap) && is_write)
	;;;     pre-transfer: from user memory to relay_buf
	ld bc, 512			; transfer to the real target addr.
	ld de, relay_buf
	ld hl, (uaddr_save)
	ldir
	jr do_xfer
kernel_xfer:
	call map_buffers

do_xfer:
	ld hl, _xpd_go
wait_for_go:
	ld a, (hl)
	or a
	jr nz, wait_for_go		; FIXME: needs timeout !?
	ld (hl), 0xff			; transfer start 

	inc hl				; now HL is _xpd_finish
wait_for_finish:
	ld a, (hl)			; is that flag set?
	or a
	jr z, wait_for_finish		; FIXME: needs timeout !?
	xor a
	ld (hl), a			; clear _xpd_finish flag

	ld a, (_xpd_dir)		; 0:read / other:write
	or a
	jr nz, wrap_up			; if write, no need to post-trans.

	ld a, (_td_raw)			; test is_kernel
	or a
	jr z, wrap_up

	;;; if ((is_user || is_swap) && is_read)
	;;;     post-transfer: from relay_buf to user memory
	ld bc, 512
	ld de, (uaddr_save)
	ld hl, relay_buf
	ldir

wrap_up:
	pop bc
	jp map_kernel_restore		; else map kernel then return

#endif	/* of CONFIG_XPFE_DISK */
