CROSS_CCOPTS += -I../../dev/

CSRCS = devtty.c
CSRCS += devices.c main.c xpfe_disk.c xpfe_rtc.c

DISCSRCS = discard.c xpfe_disk_discard.c

ASRCS = lunaxp.S crt0.S
ASRCS += tricks.S commonmem.S boot.S xpfe_tty.S xpfe_disk_asm.S

DISCARD_DSRCS = ../../dev/tinydisk_discard.c
DSRCS = ../../dev/blkdev.c ../../dev/mbr.c ../../dev/tinydisk.c

COBJS = $(CSRCS:.c=.o)
AOBJS = $(ASRCS:.S=.o)
DISCOBJS = $(DISCSRCS:.c=.o)
DISCARD_DOBJS = $(patsubst ../../dev/%.c,%.o, $(DISCARD_DSRCS))
DOBJS = $(patsubst ../../dev/%.c,%.o, $(DSRCS))
DAOBJS = $(patsubst ../../dev/%.S,%.o, $(DASRCS))

OBJS  = $(COBJS) $(AOBJS) $(NOBJS) $(DISCOBJS) $(DOBJS) $(DISCARD_DOBJS) $(DAOBJS)

JUNK =  *.lst *.asm *.Sym *.rst *.lst

all:	$(OBJS)

$(COBJS): %.o: %.c
	$(CROSS_CC) $(CROSS_CCOPTS) -c $<

$(DISCOBJS): %.o: %.c
	$(CROSS_CC) $(CROSS_CCOPTS) $(CROSS_CC_SEGDISC) -c $<

$(DOBJS): %.o: ../../dev/%.c
	$(CROSS_CC) $(CROSS_CCOPTS) -c $<

$(DISCARD_DOBJS): %.o: ../../dev/%.c
	$(CROSS_CC) $(CROSS_CCOPTS) $(CROSS_CC_SEGDISC) -c $<

$(NOBJS): %.o: ../../dev/net/%.c
	$(CROSS_CC) $(CROSS_CCOPTS) -c $<

$(AOBJS): %.o: %.S
	$(CROSS_AS) $(ASOPTS) $<

$(DAOBJS): %.o: ../../dev/%.S
	$(CROSS_AS) $(ASOPTS) $<

clean:
	rm -f $(OBJS) $(JUNK)  core *~ *.s *.# *.% *.@ *.^ .symtmp*

#
#	Build the kernel
#	Note that we use option -C 0x0000, not 0x0100 for now.
#
image:
	$(CROSS_LD) -b -C 0x0000 -S 0xF200 -f CLDBbXSs -o fuzix.bin \
	-m fuzix.tmpmap \
	boot.o crt0.o commonmem.o lunaxp.o ../../start.o \
	../../version.o ../../cpu-z80u/lowlevel-z80u.o \
	../../usermem.o tricks.o main.o discard.o \
	../../timer.o ../../kdata.o devices.o ../../devio.o \
	../../filesys.o ../../blk512.o ../../process.o \
	../../inode.o ../../syscall_exec.o ../../syscall_exec16.o \
	../../syscall_fs.o ../../syscall_fs2.o ../../syscall_fs3.o \
	../../syscall_proc.o ../../syscall_other.o ../../syscall_net.o \
	../../network.o ../../tty.o ../../mm.o ../../mm/memalloc_none.o \
	../../swap.o ../../mm/bankfixed.o ../../devsys.o ../../dev/mbr.o \
	../../dev/blkdev.o ../../dev/tinydisk.o ../../dev/tinydisk_discard.o \
	devtty.o xpfe_tty.o xpfe_rtc.o \
	xpfe_disk.o xpfe_disk_asm.o xpfe_disk_discard.o \
	../../../Library/libs/libcz80.a /opt/fcc/lib/z80/libz80.a
	perl -lpe '$$_=hex' fuzix.tmpmap | paste -d" " - fuzix.tmpmap  |  sort -n |  cut -d" " -f 2- >../../fuzix.map
	../../tools/pack85 <../../fuzix.map fuzix.bin ../../fuzix.bin

IMAGES = $(FUZIX_ROOT)/Images/$(TARGET)

diskimage:
	# Make a blank disk image with partition
	dd if=$(FUZIX_ROOT)/Standalone/filesystem-src/parttab.20M of=$(IMAGES)/disk.img bs=20152320 conv=sync
	# Add the file system
	dd if=$(IMAGES)/filesys8.img of=$(IMAGES)/disk.img bs=512 seek=2048 conv=notrunc
