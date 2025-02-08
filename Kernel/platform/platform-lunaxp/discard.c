#include <kernel.h>
#include <timer.h>
#include <kdata.h>
#include <printf.h>
#include <devtty.h>
#include <tinyide.h>

#if 0	/* not used for now */
extern int strcmp(const char *, const char *);
#endif

/*
 *	Everything in this file ends up in discard which means the moment
 *	we try and execute init it gets blown away. That includes any
 *	variables declared here so beware!
 */

/*
 *	We get passed each kernel command line argument. if we return 1 then
 *	we claim it, if not it gets passed to init. It's perfectly acceptable
 *	to act on a match and return to also pass it to init if you need to.
 */
uint_fast8_t plt_param(unsigned char *p)
{
	return 0;
}

/*
 *	Set up our memory mappings. This is not needed for simple banked memory
 *	only more complex setups such as 16K paging.
 */
void map_init(void)
{
}

/*
 *	Add all the available pages to the list of pages we an use. If this
 *	is runtime dynamic check to make sure you don't add more than MAX_MAPS
 *	of them. On some machines with a lot of RAM the implementation turns
 *	the excess into a RAM disc
 *
 *	The mapping can be logical numbers 1-n, or can be physical values to
 *	write into registers. Whatever works best. The 0 value is however
 *	reserved throughout to indicate kernel mode in calls, and also
 *	to mean swapped out for processes. If your bank 0 is user space you
 *	might need to just dec/inc before using it in an I/O port or similar
 *	to avoid confusion.
 *
 *	We would like to use LUNA XP memory as:
 *
 *	 area#0: 0x00000-0x07fff ->  kernel low  BBR=0x00, CBR=any,  CABR=0x80
 *	 area#1: 0x08000-0x0ffff ->  kernel high BBR=any,  CBR=0x80, CABR=0x80
 *	 area#2: 0x10000-0x17fff ->  (Left memory for LANCE, shrunken to 32KB)
 *	 area#3: 0x18000-0x1ffff ->  user low#2  BBR=0x18, CBR=any,  CABR=0x80
 *	 area#4: 0x20000-0x27fff ->  (XP diag ROM, can not use)
 *	 area#5: 0x28000-0x2ffff ->  user low#1  BBR=0x28, CBR=any,  CABR=0x80
 *
 *	Kernel low 32K uses area#0, high 32K uses area#1.
 *	User spaces are area#5, and area#3 is also mandatory.
 *	If we disable LUNA's LANCE(network interface), we can add area#2 as an
 *	additional user low#3.
 *
 *	We use BBR value as page index.
 */
void pagemap_init(void)
{
	pagemap_add(0x28);	/* area #5 */
#ifdef LUNAXP_USE_LANCE_MEM
	pagemap_add(0x18);	/* area #3 */
#endif
}

/*
 *	Called after interrupts are enabled in order to enumerate and set up
 *	any devices. In our case we set up pseudo disk I/F.
 */

void device_init(void)
{
	xpd_probe();
}
