#include <kernel.h>
#include <kdata.h>
#include <rtc.h>

extern uint8_t *xpfe_rtc;

uint_fast8_t plt_rtc_secs(void)
{
	return xpfe_rtc[6];
}

int plt_rtc_read(void)
{
	uint16_t len = sizeof(struct cmos_rtc);
	struct cmos_rtc cmos;
	uint8_t *p = cmos.data.bytes;
	uint8_t *q = xpfe_rtc;
	uint8_t i;
	irqflags_t irq;

	if (udata.u_count < len)
		len = udata.u_count;

	irq = di();		/* need this? */
	for (i = 0; i < 8; i++)
		*p++ = *q++;
	irqrestore(irq);	/* need this? */

	cmos.type = CMOS_RTC_DEC;
	if (uput(&cmos, udata.u_base, len) == -1)
		return -1;
	return len;
}

int plt_rtc_write(void)
{
	udata.u_error = EOPNOTSUPP;
	return -1;
}
