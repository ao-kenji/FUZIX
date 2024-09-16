;
;	LUNA XP raw tty
;
	.z180

	.common

	; exported symbols
	.export _xpfe_putc
	.export _xpfe_getc

_xpfe_putc:
	push hl
	push af			; push the output char in A
	ld hl, _xpfe_tx_flag
__putc0:
	ld a, (hl)		; is the flag cleared?
	or a
	jr nz, __putc0		; if no, try again until cleared
	dec hl			; now HL points _xpfe_tx_data
	pop af			; pop the output char
	ld (hl), a		; write the output char in _xpfe_tx_data
	inc hl			; now HL points _xpfe_tx_flag
	ld (hl), 0ffh		; set the flag
	pop hl
	ret

_xpfe_getc:
	push hl
	ld hl, _xpfe_rx_flag
	ld a, (hl)		; is the flag set?
	or a
	jr nz, __getc0
	xor a			; if no, set the input char 0
	jr __getc1
__getc0:
	dec hl			; now HL points _xpfe_rx_data
	ld a, (hl)		; A has the input char
	ld (hl), 0		; clear _xpfe_rx_data, in case
	inc hl			; now HL points _xpfe_rx_flag
	ld (hl), 0		; reset the flag
__getc1:
	ld (_xpfe_getc_result), a	; save the input char
	pop hl
	ret
