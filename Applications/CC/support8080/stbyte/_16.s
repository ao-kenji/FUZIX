
	.export __stbyte16

	.setcpu 8080
	.code
__stbyte16:
	mov a,l
	lxi h,16

	mov m,a
	mov l,a
	ret