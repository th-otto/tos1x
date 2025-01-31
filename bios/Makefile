top_srcdir=..

include $(top_srcdir)/Makefile.cmn
include $(top_srcdir)/Makefile.sil
include optimize.mak

all:: $(top_srcdir)/common/config.h bios.a

include $(top_srcdir)/config.mak
-include $(top_srcdir)/common/sections.mak

include SRCFILES

CPPFLAGS +=

bios.a: tosvars.o $(BIOS_OBJS) ${MAKEFILE}
	$(AR) $(ARFLAGS) $@ tosvars.o $(BIOS_OBJS)

#
# need to repeat the default suffix rule here,
# because on a FAT filesystem, .S cannot be
# distinguished from .s
#
startup.o: startup.S $(top_srcdir)/common/config.h header.h scrdmp.inc
	$(AM_V_AS)${CPP} $*.S $*.i
	$(AM_V_at)${BIN}as68${EXEEXT} ${ASFLAGS} ${$*_ASFLAGS} $*.i
	$(AM_V_at)${RM} $*.i

vars.o: $(top_srcdir)/common/vars.S $(top_srcdir)/common/config.h
	$(AM_V_AS)${CPP} $< $*.i
	$(AM_V_at)${BIN}as68${EXEEXT} ${ASFLAGS} ${$*_ASFLAGS} $*.i $@
	$(AM_V_at)${RM} $*.i

tosvars.o: $(top_srcdir)/common/tosvars.S $(top_srcdir)/common/config.h
	$(AM_V_AS)${CPP} $< $*.i
	$(AM_V_at)${BIN}as68${EXEEXT} ${ASFLAGS} ${$*_ASFLAGS} $*.i $@
	$(AM_V_at)${RM} $*.i

prt.o: prt.S
	$(AM_V_AS)${CPP} $< $*.i
	$(AM_V_at)${BIN}as68${EXEEXT} ${ASFLAGS} ${$*_ASFLAGS} $*.i
	$(AM_V_at)${RM} $*.i

memtest.o: memtest.S
	$(AM_V_AS)${CPP} $< $*.i
	$(AM_V_at)${BIN}as68${EXEEXT} ${ASFLAGS} ${$*_ASFLAGS} $*.i
	$(AM_V_at)${RM} $*.i

nvram.o: nvram.S
	$(AM_V_AS)$(CPP) $< $*.i
	$(AM_V_at)${BIN}as68${EXEEXT} ${ASFLAGS} ${$*_ASFLAGS} $*.i
	$(AM_V_at)${RM} $*.i

ikbdclk.o: ikbdclk.S
	$(AM_V_AS)$(CPP) $< $*.i
	$(AM_V_at)${BIN}as68${EXEEXT} ${ASFLAGS} ${$*_ASFLAGS} $*.i
	$(AM_V_at)${RM} $*.i

chardev.o: chardev.S
	$(AM_V_AS)$(CPP) $< $*.i
	$(AM_V_at)${BIN}as68${EXEEXT} ${ASFLAGS} ${$*_ASFLAGS} $*.i
	$(AM_V_at)${RM} $*.i

floppy.o: floppy.S
	$(AM_V_AS)$(CPP) $< $*.i
	$(AM_V_at)${BIN}as68${EXEEXT} ${ASFLAGS} ${$*_ASFLAGS} $*.i
	$(AM_V_at)${RM} $*.i

zeromem.o: zeromem.S
	$(AM_V_AS)$(CPP) $< $*.i
	$(AM_V_at)${BIN}as68${EXEEXT} ${ASFLAGS} ${$*_ASFLAGS} $*.i
	$(AM_V_at)${RM} $*.i

blkdev.o: blkdev.c
	$(AM_V_CC)${BIN}cp68${EXEEXT} ${CPPFLAGS} $*.c $*.i
	$(AM_V_at)${BIN}c068${EXEEXT} $*.i $*.1 $*.2 $*.3 ${CFLAGS}
	$(AM_V_at)${BIN}c168${EXEEXT} $*.1 $*.2 $*.s
	$(AM_V_at)${RUN_OPTIMIZE_${$*_OPTIMIZE}}
	$(AM_V_at)$(SUBSTLMUL)
	$(AM_V_at)${BIN}as68${EXEEXT} ${ASFLAGS} ${$*_ASFLAGS} $*.s
	$(AM_V_at)${RM} $*.s $*.i $*.1 $*.2 $*.3



biosext.o: biosext.S $(top_srcdir)/common/config.h $(top_srcdir)/common/sections.inc
	$(AM_V_AS)${BIN}cp68${EXEEXT} ${CPPFLAGS} -P $*.S $*.i
	$(AM_V_at)${BIN}as68${EXEEXT} ${ASFLAGS} ${$*_ASFLAGS} $*.i
	$(AM_V_at)${RM} $*.i

keytbl.o: $(top_srcdir)/common/config.h

prtkeys$(EXEEXT): prtkeys.o
	$(AM_V_LD)${LD} ${LDFLAGS} -o $@ prtkeys.o

# no check here; to much hassle to get all the external dependencies
check:: bios.a
	@:

clean:
	$(RM) *.o *.a *.ndx *.i *.1 *.2 *.rel *.mod $(BIOS_CSRCS:.c=.s) $(PROGRAMS) $(top_srcdir)/common/config.h

distclean: clean
	$(RM) $(top_srcdir)/common/sections.mak
