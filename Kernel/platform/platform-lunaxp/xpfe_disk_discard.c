/*
 * XPFE disk service (xpd, in short) I/F discarding part
 * (with reference to Kernel/dev/tinyide_discard.c)
 */

#define _XPFE_DISK_PRIVATE

#include <kernel.h>
#include <kdata.h>
#include <printf.h>
#include <tinydisk.h>

#ifdef CONFIG_XPFE_DISK
#include "xpfe_disk.h"

static int xpd_identify(int dev)
{
	uint32_t blknum;

	kprintf("%x : ", dev);

	if ((uint8_t)xpd_status == 0) {
		kputs(" - absent\n");
		return 0;	/* not exist or not ready */
	}

	blknum =  ((uint8_t)xpd_blknum_3 << 24);
	blknum |= ((uint8_t)xpd_blknum_2 << 16);
	blknum |= ((uint8_t)xpd_blknum_1 << 8);
	blknum |= (uint8_t)xpd_blknum_0;

	kprintf(" - OK (%u blocks)\n", blknum);

	return 1;
}

static void xpd_register(uint_fast8_t unit)
{
	td_register(unit, xpd_xfer, xpd_ioctl, 1);
}

void xpd_probe(void)
{
	register uint_fast8_t n;
	for (n = 0 ; n < TD_XPFE_DISK_NUM; n++) {
		if (xpd_identify(n))
			xpd_register(n);
	}
}

#endif
