/* Enable to make ^Z dump the inode table for debug */
#undef CONFIG_IDUMP
/* Enable to make ^A drop back into the monitor */
#undef CONFIG_MONITOR
/* Profil syscall support (not yet complete) */
#undef CONFIG_PROFIL
/* Multiple processes in memory at once */
#define CONFIG_MULTI
/* Instead, try to make SINGLETASK first */
/* #define CONFIG_SINGLETASK */

/* Select a banked memory set up */
#define CONFIG_BANK_FIXED

/* If we can use LANCE memory for XP, define this (mandatory now) */
#define LUNAXP_USE_LANCE_MEM
/* This is the number of banks of user memory available (maximum) */
#ifdef LUNAXP_USE_LANCE_MEM
#define MAX_MAPS	2		/* 128 KByte minus the kernel 64KByte */
#else
#define MAX_MAPS	1		/* 96 KByte minus the kernel 64KByte */
#endif

/* How big is each bank - in our case 32K, 48K is actually more common. This
   is hardware dependant */
#define MAP_SIZE	0x8000
/* How many banks do we have in our address space */
#define CONFIG_BANKS	2	/* 64KB = 32KB x 2areas */

/*
 *	Define the program loading area (needs to match kernel.def)
 */
#define PROGBASE    0x0000  /* Base of user  */
#define PROGLOAD    0x0100  /* Load and run here */
#define PROGTOP     0x7E00  /* Top of program, base of U_DATA stash */
#define PROC_SIZE   32 	    /* Memory needed per process including stash */
/*
 *	Definitions for swapping.
 */
#define SWAPDEV     (swap_dev)	/* A variable for dynamic, or a device major/minor */
extern uint16_t swap_dev;
#define SWAP_SIZE   0x40 	/* 32K in 512 byte blocks */
#define SWAPBASE    0x0000	/* We swap the lot in one, include the */
#define SWAPTOP	    0x8000	/* vectors so its a round number of sectors */

#define MAX_SWAPS	16	/* Maximum number of swapped out processes.
                                   As we use the default 15 process max this
                                   is definitely sufficient (14 would do) */
/*
 *	When the kernel swaps something it needs to map the right page into
 *	memory using map_for_swap and then turn the user address into a
 *	physical address. For a simple banked setup there is no conversion
 *	needed so identity map it.
 */
#define swap_map(x)	((uint8_t *)(x))

/* disk service */
#define CONFIG_TD_NUM		1	/* will be 2 */
#define CONFIG_XPFE_DISK		/* use XPFE pseudo disk service */
#define MAX_BLKDEV		2

#define BOOTDEVICENAMES "hd#"		/* No fd */

/* We will resize the buffers available after boot. This is the normal setting */
#define CONFIG_DYNAMIC_BUFPOOL
/* Swap will be set up when a suitably labelled partition is seen */
#define CONFIG_DYNAMIC_SWAP
/* Larger transfers (including process execution) should go directly not via
   the buffer cache. For all small (eg bit) systems this is the right setting
   as it avoids polluting the small cache with data when it needs to be full
   of directory and inode information */
#define CONFIG_LARGE_IO_DIRECT(x)	1

/* Specify this if there is a real time clock capable of reporting seconds. It
   will be used to lock the kernel time better to reality. Other details like
   Y2K support, or even supporting dates as well don't matter */
#define CONFIG_RTC
/* Specify that there is a full real time clock that can supply the date and
   time to the system. */
#define CONFIG_RTC_FULL
/* Set this if the system has no proper real time clock (or has configurations
   where it lacks one). This is not usually needed but for platforms it is also
   see platform-sbcv2/main.c on what is needed */
/* #define CONFIG_NO_CLOCK */
/* Set how often we actually poll this RTC in ticks - 1 means always. */
#define CONFIG_RTC_INTERVAL	1
/*
 * How fast does the clock tick (if present), or how many times a second do
 * we simulate if not. For a machine without video 10 is a good number. If
 * you have video you probably want whatever vertical sync/blank interrupt
 * rate the machine has. For many systems it's whatever the hardware gives
 * you.
 *
 * Note that this needs to be divisible by 10 and at least 10. If your clock
 * is a bit slower you may need to fudge things somewhat so that the kernel
 * gets 10 timer interrupt calls per second. 
 */
#define TICKSPERSEC 40	    /* Ticks per second */

/* Core networking support */
/* #define CONFIG_NET */
/* Or native (eg SLIP) */
/* #define CONFIG_NET_NATIVE */

/*
 *	The device (major/minor) for the console and boot up tty attached to
 *	init at start up. 512 is the major 2, so all the tty devices are
 *	512 + n where n is the tty.
 */
#define BOOT_TTY (512 + 1)      /* Set this to default device for stdio, stderr */
                          /* In this case, the default is the first TTY device */
/*
 *	If you have a mechanism to pass in a root device configuration then
 *	this holds the address of the buffer (eg a CP/M command line or similar).
 *	If the configuration is fixed then this can be a string holding the
 *	configuration. NULL means 'prompt the user'.
 */
#define CMDLINE	NULL	  /* Location of root dev name */

/* Device parameters */
/* If we can use XP's internal ASCI, define this */
#define	LUNAXP_USE_ASCI
#ifdef LUNAXP_USE_ASCI	  /* How many tty devices does the platform support */
#define NUM_DEV_TTY 3	  /* Pseudo tty, ASCI0 and ASCI1 */
#else
#define NUM_DEV_TTY 1	  /* Pseudo tty only */
#endif
#define TTYDEV   BOOT_TTY /* Device used by kernel for messages, panics */
#define NBUFS    5        /* Number of block buffers. Must be 4+ and must match
                             kernel.def */
#define NMOUNTS	 4	  /* Number of mounts at a time */

#define CONFIG_SMALL

#define plt_copyright()
