;
; LUNA XP boot 
;
	.z180

	.export xp_start

	.code

; loaded at 0x0000

xp_start:
	jp 0x0100

	.ds	256 - 3
