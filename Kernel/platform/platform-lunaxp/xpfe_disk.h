/*
 * XPFE disk service (xpd, in short) I/F
 * (with reference to Kernel/dev/tinyide.h)
 */

#ifndef XPFEDISK_H
#define XPFEDISK_H

#define	TD_XPFE_DISK_NUM	1	/* for now */

int xpd_xfer(uint_fast8_t unit, bool is_read, uint32_t lba, uint8_t * dptr);
int xpd_ioctl(uint_fast8_t dev, uarg_t request, char *unused);
void xpd_probe(void);

/* Assembler glue */
extern void xpd_xfer_go(void);

extern uint8_t xpd_lba_0;
extern uint8_t xpd_lba_1;
extern uint8_t xpd_lba_2;
extern uint8_t xpd_lba_3;
extern uint16_t *xpd_addr;
extern uint8_t xpd_dir;
extern uint8_t xpd_go;
extern uint8_t xpd_finish;
extern uint8_t xpd_status;
extern uint8_t xpd_blknum_0;
extern uint8_t xpd_blknum_1;
extern uint8_t xpd_blknum_2;
extern uint8_t xpd_blknum_3;

#endif
