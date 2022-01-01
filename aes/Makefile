top_srcdir=..

include $(top_srcdir)/Makefile.cmn
include $(top_srcdir)/Makefile.sil
include optimize.mak

all:: $(top_srcdir)/common/config.h aes.a

include $(top_srcdir)/config.mak
-include $(top_srcdir)/common/sections.mak

include SRCFILES

#.s.o:
#	$(AM_V_AS)oldmas -U -S $*.s

CPPFLAGS +=

# only 1.04 has the linef hack
LINEF_CFLAGS_104 = -A
LINEF_AFLAGS_104 = -A${BIN}lineftab.txt
CFLAGS += $(LINEF_CFLAGS_$(TOSVERSION))
ASFLAGS += $(LINEF_AFLAGS_$(TOSVERSION))

STARTUP =	gemjstrt.o

aes.a: $(STARTUP) $(AES_OBJS) ${MAKEFILE}
	$(RM) $@
	$(AR) $(ARFLAGS) $@ $(STARTUP) $(AES_OBJS)

# sections.mak might have just been generated, make sure it is reread
aes.o: $(VARS_OBJS) $(STARTUP) $(AES_OBJS) aesext.o $(top_srcdir)/common/sections.mak ${MAKEFILE}
	$(MAKE) TOSVERSION=$(TOSVERSION) COUNTRY=$(COUNTRY) single

single::

#
# need to repeat the default suffix rule here,
# because on a FAT filesystem, .S cannot be
# distinguished from .s
#
gemjstrt.o: gemjstrt.S
	$(AM_V_AS)${CPP} $< $*.i
	$(AM_V_at)${BIN}as68${EXEEXT} ${ASFLAGS} ${$*_ASFLAGS} $*.i $@
	$(AM_V_at)${RM} $*.i

apgrlib.o: apgrlib.S
	$(AM_V_AS)${CPP} $< $*.i
	$(AM_V_at)${BIN}as68${EXEEXT} ${ASFLAGS} ${$*_ASFLAGS} $*.i $@
	$(AM_V_at)${RM} $*.i

apgsxif.o: apgsxif.S
	$(AM_V_AS)${CPP} $< $*.i
	$(AM_V_at)${BIN}as68${EXEEXT} ${ASFLAGS} ${$*_ASFLAGS} $*.i $@
	$(AM_V_at)${RM} $*.i

gemgrlib.o: gemgrlib.S
	$(AM_V_AS)${CPP} $< $*.i
	$(AM_V_at)${BIN}as68${EXEEXT} ${ASFLAGS} ${$*_ASFLAGS} $*.i $@
	$(AM_V_at)${RM} $*.i

gemgsxif.o: gemgsxif.S
	$(AM_V_AS)${CPP} $< $*.i
	$(AM_V_at)${BIN}as68${EXEEXT} ${ASFLAGS} ${$*_ASFLAGS} $*.i $@
	$(AM_V_at)${RM} $*.i

gsx2.o: gsx2.S
	$(AM_V_AS)${CPP} $< $*.i
	$(AM_V_at)${BIN}as68${EXEEXT} ${ASFLAGS} ${$*_ASFLAGS} $*.i $@
	$(AM_V_at)${RM} $*.i

jbind.o: jbind.S
	$(AM_V_AS)${CPP} $< $*.i
	$(AM_V_at)${BIN}as68${EXEEXT} ${ASFLAGS} ${$*_ASFLAGS} $*.i $@
	$(AM_V_at)${RM} $*.i

jdispa.o: jdispa.S
	$(AM_V_AS)${CPP} $< $*.i
	$(AM_V_at)${BIN}as68${EXEEXT} ${ASFLAGS} ${$*_ASFLAGS} $*.i $@
	$(AM_V_at)${RM} $*.i

jdos.o: jdos.S
	$(AM_V_AS)${CPP} $< $*.i
	$(AM_V_at)${BIN}as68${EXEEXT} ${ASFLAGS} ${$*_ASFLAGS} $*.i $@
	$(AM_V_at)${RM} $*.i

large.o: large.S
	$(AM_V_AS)${CPP} $< $*.i
	$(AM_V_at)${BIN}as68${EXEEXT} ${ASFLAGS} ${$*_ASFLAGS} $*.i $@
	$(AM_V_at)${RM} $*.i

optimize.o: optimize.S
	$(AM_V_AS)${CPP} $< $*.i
	$(AM_V_at)${BIN}as68${EXEEXT} ${ASFLAGS} ${$*_ASFLAGS} $*.i $@
	$(AM_V_at)${RM} $*.i

ratrbp.o: ratrbp.S
	$(AM_V_AS)${CPP} $< $*.i
	$(AM_V_at)${BIN}as68${EXEEXT} ${ASFLAGS} ${$*_ASFLAGS} $*.i $@
	$(AM_V_at)${RM} $*.i

trap14.o: trap14.S
	$(AM_V_AS)${CPP} $< $*.i
	$(AM_V_at)${BIN}as68${EXEEXT} ${ASFLAGS} ${$*_ASFLAGS} $*.i $@
	$(AM_V_at)${RM} $*.i

linefhdl.o: linefhdl.S
	$(AM_V_AS)${CPP} $< $*.i
	$(AM_V_at)${BIN}as68${EXEEXT} ${ASFLAGS} ${$*_ASFLAGS} $*.i $@
	$(AM_V_at)${RM} $*.i


#
# ugly hack for even more ugly assembly in gembind.c
#
ASMHACK_104 = $(SED) -e 's/bra L2/bra L9999/' $*.s > $*.i; $(MV) $*.i $*.s
ASMHACK_106 = $(SED) -e 's/bra L2/bra L9999/' $*.s > $*.i; $(MV) $*.i $*.s
ASMHACK_162 = $(SED) -e 's/bra L2/bra L9999/' $*.s > $*.i; $(MV) $*.i $*.s
ASMHACK = $(ASMHACK_$(TOSVERSION))

gembind.o: gembind.c
	$(AM_V_CC)${BIN}cp68${EXEEXT} ${CPPFLAGS} $< $*.i
	$(AM_V_at)${BIN}c068${EXEEXT} $*.i $*.1 $*.2 $*.3 ${CFLAGS}
	$(AM_V_at)${BIN}c168${EXEEXT} $*.1 $*.2 $*.s
	$(AM_V_at)${RUN_OPTIMIZE_${$*_OPTIMIZE}}
	$(AM_V_at)$(ASMHACK)
	$(AM_V_at)${BIN}as68${EXEEXT} ${ASFLAGS} ${$*_ASFLAGS} -o $@ $*.s
	$(AM_V_at)${RM} $*.s $*.i $*.1 $*.2 $*.3

vars.o: $(top_srcdir)/common/vars.S $(top_srcdir)/common/config.h
	$(AM_V_AS)${BIN}cp68${EXEEXT} ${CPPFLAGS} -P $< $*.i
	$(AM_V_at)${BIN}as68${EXEEXT} ${ASFLAGS} ${$*_ASFLAGS} $*.i $@
	$(AM_V_at)${RM} $*.i

tosvars.o: $(top_srcdir)/common/tosvars.S $(top_srcdir)/common/config.h
	$(AM_V_AS)${BIN}cp68${EXEEXT} ${CPPFLAGS} -P $< $*.i
	$(AM_V_at)${BIN}as68${EXEEXT} ${ASFLAGS} ${$*_ASFLAGS} $*.i $@
	$(AM_V_at)${RM} $*.i

aesext.o: aesext.S $(top_srcdir)/common/sections.inc $(top_srcdir)/common/config.h
	$(AM_V_AS)${BIN}cp68${EXEEXT} ${CPPFLAGS} -P $< $*.i
	$(AM_V_at)${BIN}as68${EXEEXT} ${ASFLAGS} ${$*_ASFLAGS} $*.i
	$(AM_V_at)${RM} $*.i

# no check here; has to be done in desktop
check:: aes.a

clean:
	$(RM) $(AES_OBJS)
	$(RM) *.o *.a *.ndx *.i *.1 *.2 *.rel *.mod $(AES_CSRCS:.c=.s) $(PROGRAMS) $(top_srcdir)/common/config.h

distclean: clean
	$(RM) $(top_srcdir)/common/sections.mak
