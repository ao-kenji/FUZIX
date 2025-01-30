/*
 * XPFE disk service (xpd, in short) I/F
 * (with reference to Kernel/dev/tinyide.c)
 */

#include <kernel.h>
#include <kdata.h>
#include <printf.h>
#include <tinyide.h>
#include <blkdev.h>

#ifdef CONFIG_XPFE_DISK

#include "xpfe_disk.h"

/* #define XPFE_DISK_DEBUG */

extern void xpd_xfer_go(void);	/* in xpfe_disk_asm.S */

int xpd_xfer(uint_fast8_t dev, bool is_read, uint32_t lba, uint8_t *dptr)
{
#ifdef XPFE_DISK_DEBUG
	extern uint8_t td_raw;
	extern uint8_t td_page;
#endif
	/* FIXME: wait !BUSY */
	/* select drive, start loading LBA */
	xpd_lba_3 = (uint8_t)((lba >> 24) & 0xF);
	xpd_lba_2 = (uint8_t)(lba >> 16);
	xpd_lba_1 = (uint8_t)(lba >> 8);
	xpd_lba_0 = (uint8_t)lba;
	/* address */
	xpd_addr = dptr;
	/* direction */
	xpd_dir = (is_read ? 0 : 0xff);

#ifdef XPFE_DISK_DEBUG
	kprintf("%lx %c %d %d %x\n",
	    lba, is_read ? '>' : '<' , td_raw, td_page, dptr);
#endif

	xpd_xfer_go();

	/* FIXME: error check */
	return 1;
}

int xpd_ioctl(uint_fast8_t dev, uarg_t request, char *unused)
{
	if (request != BLKFLSBUF)
		return -1;
	/* no need to flush */
	return 0;
}

int xpd_flush_cache(uint_fast8_t dev, uarg_t request, char *unused)
{
	/* no need to flush */
	return 0;
}

/* Assembler part is in xpfe_disk_asm.S */
#endif
