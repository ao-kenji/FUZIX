;
;	The common memory area traditionally starts with the udata and the
;	interrupt stacks. As this is standard in almost all cases you can
;	just include the standard implementation.
;
	.z180

	.common

#include "../../cpu-z80u/std-commonmem.S"

	.export relay_buf
relay_buf:
	.ds	512

	.export _xpfe_tx_data
	.export _xpfe_tx_flag
	.export _xpfe_rx_data
	.export _xpfe_rx_flag
	.export _xpfe_rtc
	.export _xpd_lba_0
	.export _xpd_lba_1
	.export _xpd_lba_2
	.export _xpd_lba_3
	.export _xpd_addr
	.export _xpd_dir
	.export _xpd_go
	.export _xpd_finish
	.export _xpd_status
	.export _xpd_blknum_0
	.export _xpd_blknum_1
	.export _xpd_blknum_2
	.export _xpd_blknum_3
	.export _irqvector
	.export hw_irqvector
	.export _interrupt_table

_xpfe_if:
_xpfe_magic:			; +00
	.byte 'X', 'P', 'F', 'E'

_xpfe_tx_data:			; +04
	.byte 0
_xpfe_tx_flag:
	.byte 0
	.byte 0, 0		; padding

_xpfe_rx_data:
	.byte 0			; +08
_xpfe_rx_flag:
	.byte 0
	.byte 0, 0		; padding

_xpfe_rtc:
	.byte 0, 0, 0, 0	; +0c
	.byte 0, 0, 0, 0	; +10

_xpd_lba:
_xpd_lba_3:
	.byte 0			; +14
_xpd_lba_2:
	.byte 0
_xpd_lba_1:
	.byte 0
_xpd_lba_0:
	.byte 0
_xpd_dir:
	.byte 0			; +18   0:read / other:write
	.byte 0			; padding
_xpd_addr:			; Caution: value is stored in little-endian
	.byte 0, 0
_xpd_go:
	.byte 0			; +1c
_xpd_finish:
	.byte 0
	.byte 0			; padding
_xpd_status:
	.byte 0			; 0: not connected / 1: alive
_xpd_blknum:
_xpd_blknum_3:
	.byte 0			; +20
_xpd_blknum_2:
	.byte 0
_xpd_blknum_1:
	.byte 0
_xpd_blknum_0:
	.byte 0
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ; +30
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ; +40
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ; +60
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ; +80
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ; +a0
_irqvector:
	.byte 0
hw_irqvector:
	.byte 0
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ; +c0

_interrupt_table:
	.word z180_irq_unused	; +e0 : #1  INT1 external interrupt
	.word z180_irq_unused	; +e2 : #2  INT2 external interrupt
	.word z180_irq3		; +e4 : #3  Timer 0
	.word z180_irq_unused	; +e6 : #4  Timer 1
	.word z180_irq_unused	; +e8 : #5  DMA 0
	.word z180_irq_unused	; +ea : #6  DMA 1
	.word z180_irq_unused	; +ec : #7  CSI/O
	.word z180_irq_unused	; +ee : #8  ASCI 0
	.word z180_irq_unused	; +f0 : #9  ASCI 1
	.word z180_irq_unused	; +f2 :#10
	.word z180_irq_unused	; +f4 :#11
	.word z180_irq_unused	; +f6 :#12
	.word z180_irq_unused	; +f8 :#13
	.word z180_irq_unused	; +fa :#14
	.word z180_irq_unused	; +fc :#15
	.word z180_irq_unused	; +fe :#16
