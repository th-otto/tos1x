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
	../bdos/console.o \
	../bdos/fsfat.o \
	../bdos/fsglob.o \
	../bdos/fsdir.o \
	../bdos/fsopnclo.o \
	../bdos/fshand.o \
	../bdos/fsmain.o \
	../bdos/fssupp.o \
	../bdos/proc.o \
	../bdos/umem.o \
	../bdos/osmem.o \
	../bdos/osinit.o \
	../bdos/lmul.o \
	../bdos/ldiv.o \
	../bdos/xfer.o \
	../bdos/sup.o \
	../bdos/time.o \
	\
	../bios/zeromem.o \
	\
	../vdi/font6x6.o \
	../vdi/font8x8.o \
	../vdi/font8x16.o \
	../vdi/entry.o \
	../vdi/tables.o \
	../vdi/line1010.o \
	../vdi/gsxasm1.o \
	../vdi/allgem.o \
	../vdi/blitinit.o \
	../vdi/routines.o \
	../vdi/jmptbl.o \
	../vdi/isin.o \
	../vdi/monobj.o \
	../vdi/opnwk.o \
	../vdi/monout.o \
	../vdi/text.o \
	../vdi/textblt.o \
	../vdi/hbtxtblt.o \
	../vdi/mono.o \
	../vdi/hbmono.o \
	../vdi/gsxasm2.o \
	../vdi/hbrect.o \
	../vdi/mouse.o \
	../vdi/copyrfm.o \
	../vdi/blastman.o \
	../vdi/hbbitblt.o \
	../vdi/blaster.o \
	../vdi/seedfill.o \
	../vdi/xfrmform.o \
	../vdi/stcolor.o \
	../vdi/sbblit.o \
	../vdi/sbfrag.o \
	../vdi/sbhline.o \
	../vdi/sbvline.o \
	../vdi/sbmono.o \
	../vdi/sbtxtblt.o \
	../vdi/cbssdefs.o \
	$(empty)

BIOSVDI_OBJS = ${BIOSVDI_${TOSVERSION}_OBJS}
