BIOSVDI_100_OBJS = \
	../bios/startup.o \
	../bios/blkdev.o \
	../bios/floppy.o \
	../bios/ikbdclk.o \
	../bios/chardev.o \
	../bios/prtblk.o \
	../bios/prt.o \
	\
	../vdi/escape.o \
	\
	../bdos/bdosmain.o \
	../bdos/lmul.o \
	../bdos/osinit.o \
	../bdos/fshand.o \
	../bdos/osmem.o \
	../bdos/console.o \
	../bdos/proc.o \
	../bdos/fsopnclo.o \
	../bdos/fsfat.o \
	../bdos/fsglob.o \
	../bdos/fsdir.o \
	../bdos/fsmain.o \
	../bdos/fssupp.o \
	../bdos/umem.o \
	../bdos/sup.o \
	../bdos/time.o \
	\
	../vdi/line1010.o \
	../vdi/tables.o \
	../vdi/font6x6.o \
	../vdi/font8x8.o \
	../vdi/font8x16.o \
	../vdi/entry.o \
	../vdi/gsxasm1.o \
	../vdi/allgem.o \
	../vdi/jmptbl.o \
	../vdi/blitinit.o \
	../vdi/routines.o \
	../vdi/isin.o \
	../vdi/monobj.o \
	../vdi/opnwk.o \
	../vdi/monout.o \
	../vdi/text.o \
	../vdi/textblt.o \
	../vdi/hbtxtblt.o \
	../vdi/sbtxtblt.o \
	../vdi/mono.o \
	../vdi/hbmono.o \
	../vdi/gsxasm2.o \
	../vdi/hbrect.o \
	../vdi/mouse.o \
	../vdi/copyrfm.o \
	../vdi/blastman.o \
	../vdi/sbfrag.o \
	../vdi/hbbitblt.o \
	../vdi/blaster.o \
	../vdi/seedfill.o \
	../vdi/xfrmform.o \
	../vdi/stcolor.o \
	../vdi/cbssdefs.o \
	$(empty)

BIOSVDI_OBJS = ${BIOSVDI_${TOSVERSION}_OBJS}
