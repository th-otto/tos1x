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

# only TOS versions <= 1.04 have the linef hack
LINEF_CFLAGS_104 = -A
LINEF_AFLAGS_104 = -A${BIN}lineftab.txt
LINEF_CFLAGS_100 = -A
LINEF_AFLAGS_100 = -A${BIN}lineftab.txt
LINEF_CFLAGS_102 = -A
LINEF_AFLAGS_102 = -A${BIN}lineftab.txt
CFLAGS += $(LINEF_CFLAGS_$(TOSVERSION))
ASFLAGS += $(LINEF_AFLAGS_$(TOSVERSION))

STARTUP =	gemjstrt.o

aes.a: $(STARTUP) $(AES_OBJS) ${MAKEFILE}
	$(AM_V_at)$(RM) $@
	$(AM_V_AR)$(AR) $(ARFLAGS) $@ $(STARTUP) $(AES_OBJS)

#
# need to repeat the default suffix rule here,
# because on a FAT filesystem, .S cannot be
# distinguished from .s
#
gemjstrt.o: gemjstrt.S
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

gsx2.o: gsx2.S
	$(AM_V_AS)${CPP} $< $*.i
	$(AM_V_at)${BIN}as68${EXEEXT} ${ASFLAGS} ${$*_ASFLAGS} $*.i $@
	$(AM_V_at)${RM} $*.i

optimize.o: optimize.S
	$(AM_V_AS)${CPP} $< $*.i
	$(AM_V_at)${BIN}as68${EXEEXT} ${ASFLAGS} ${$*_ASFLAGS} $*.i $@
	$(AM_V_at)${RM} $*.i

large.o: large.S
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

ui_mupb.o: ui_mupb.S
	$(AM_V_AS)${CPP} $< $*.i
	$(AM_V_at)${BIN}as68${EXEEXT} ${ASFLAGS} ${$*_ASFLAGS} $*.i $@
	$(AM_V_at)${RM} $*.i

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

# remove some superflous clr.w D0 that for some reason
# don't appear in the final ROM
gembind.o: gembind.c
	$(AM_V_CC)${BIN}cp68${EXEEXT} ${CPPFLAGS} $< $*.i
	$(AM_V_at)${BIN}c068${EXEEXT} $*.i $*.1 $*.2 $*.3 ${CFLAGS}
	$(AM_V_at)${BIN}c168${EXEEXT} $*.1 $*.2 $*.s
	$(AM_V_at)${RUN_OPTIMIZE_${$*_OPTIMIZE}}
	$(AM_V_at)$(SED) -n '{$$!N; /clr R0\nmove [0-9]*(R8),R0/{D;p}; {P;D}}' $*.s > $*.1; mv $*.1 $*.s
	$(AM_V_at)$(SED) -n '{$$!N; /clr R1\nmove [0-9]*(R9),R1/{D;p}; {P;D}}' $*.s > $*.1; mv $*.1 $*.s
	$(AM_V_at)$(SED) -n '{$$!N; /clr R2\nmove [0-9]*(R10),R2/{D;p}; {P;D}}' $*.s > $*.1; mv $*.1 $*.s
	$(AM_V_at)$(SED) -n '{$$!N; /clr R0\nmove [-0-9]*(R14),R0/{D;p}; {P;D}}' $*.s > $*.1; mv $*.1 $*.s
	$(AM_V_at)${BIN}as68${EXEEXT} ${ASFLAGS} ${$*_ASFLAGS} -o $@ $*.s
	$(AM_V_at)$(RM) $*.s $*.i $*.1 $*.2 $*.3

apgrlib.o: apgrlib.c
	$(AM_V_CC)${BIN}cp68${EXEEXT} ${CPPFLAGS} $< $*.i
	$(AM_V_at)${BIN}c068${EXEEXT} $*.i $*.1 $*.2 $*.3 ${CFLAGS}
	$(AM_V_at)${BIN}c168${EXEEXT} $*.1 $*.2 $*.s
	$(AM_V_at)${RUN_OPTIMIZE_${$*_OPTIMIZE}}
	$(AM_V_at)$(SED) -n '{$$!N; /clr R0\nmove R7,R0/{D;p}; {P;D}}' $*.s > $*.1; mv $*.1 $*.s
	$(AM_V_at)${BIN}as68${EXEEXT} ${ASFLAGS} ${$*_ASFLAGS} -o $@ $*.s
	$(AM_V_at)${RM} $*.s $*.i $*.1 $*.2 $*.3

apgsxif.o: apgsxif.c
	$(AM_V_CC)${BIN}cp68${EXEEXT} ${CPPFLAGS} $< $*.i
	$(AM_V_at)${BIN}c068${EXEEXT} $*.i $*.1 $*.2 $*.3 ${CFLAGS}
	$(AM_V_at)${BIN}c168${EXEEXT} $*.1 $*.2 $*.s
	$(AM_V_at)${RUN_OPTIMIZE_${$*_OPTIMIZE}}
	$(AM_V_at)$(SED) -n '{$$!N; /clr R0\nmove R7,R0/{D;p}; {P;D}}' $*.s > $*.1; mv $*.1 $*.s
	$(AM_V_at)$(SED) -n '{$$!N; /clr R0\nmove R6,R0/{D;p}; {P;D}}' $*.s > $*.1; mv $*.1 $*.s
	$(AM_V_at)$(SED) -n '{$$!N; /clr R0\nmove R4,R0/{D;p}; {P;D}}' $*.s > $*.1; mv $*.1 $*.s
	$(AM_V_at)$(SED) -n '{$$!N; /clr R0\nmove R3,R0/{D;p}; {P;D}}' $*.s > $*.1; mv $*.1 $*.s
	$(AM_V_at)${BIN}as68${EXEEXT} ${ASFLAGS} ${$*_ASFLAGS} -o $@ $*.s
	$(AM_V_at)${RM} $*.s $*.i $*.1 $*.2 $*.3

gemaints.o: gemaints.c
	$(AM_V_CC)${BIN}cp68${EXEEXT} ${CPPFLAGS} $< $*.i
	$(AM_V_at)${BIN}c068${EXEEXT} $*.i $*.1 $*.2 $*.3 ${CFLAGS}
	$(AM_V_at)${BIN}c168${EXEEXT} $*.1 $*.2 $*.s
	$(AM_V_at)${RUN_OPTIMIZE_${$*_OPTIMIZE}}
	$(AM_V_at)$(SED) -n '{$$!N; /clr R0\nmove [0-9]*(R13),R0/{D;p}; {P;D}}' $*.s > $*.1; mv $*.1 $*.s
	$(AM_V_at)${BIN}as68${EXEEXT} ${ASFLAGS} ${$*_ASFLAGS} -o $@ $*.s
	$(AM_V_at)${RM} $*.s $*.i $*.1 $*.2 $*.3

gemasync.o: gemasync.c
	$(AM_V_CC)${BIN}cp68${EXEEXT} ${CPPFLAGS} $< $*.i
	$(AM_V_at)${BIN}c068${EXEEXT} $*.i $*.1 $*.2 $*.3 ${CFLAGS}
	$(AM_V_at)${BIN}c168${EXEEXT} $*.1 $*.2 $*.s
	$(AM_V_at)${RUN_OPTIMIZE_${$*_OPTIMIZE}}
	$(AM_V_at)$(SED) -n '{$$!N; /clr R0\nmove [0-9]*(R8),R0/{D;p}; {P;D}}' $*.s > $*.1; mv $*.1 $*.s
	$(AM_V_at)$(SED) -n '{$$!N; /clr R0\nmove [0-9]*(R13),R0/{D;p}; {P;D}}' $*.s > $*.1; mv $*.1 $*.s
	$(AM_V_at)$(SED) -n '{$$!N; /clr R0\nmove R7,R0/{D;p}; {P;D}}' $*.s > $*.1; mv $*.1 $*.s
	$(AM_V_at)$(SED) -n '{$$!N; /clr R0\nmove [-0-9]*(R14),R0/{D;p}; {P;D}}' $*.s > $*.1; mv $*.1 $*.s
	$(AM_V_at)${BIN}as68${EXEEXT} ${ASFLAGS} ${$*_ASFLAGS} -o $@ $*.s
	$(AM_V_at)${RM} $*.s $*.i $*.1 $*.2 $*.3

gemdisp.o: gemdisp.c
	$(AM_V_CC)${BIN}cp68${EXEEXT} ${CPPFLAGS} $< $*.i
	$(AM_V_at)${BIN}c068${EXEEXT} $*.i $*.1 $*.2 $*.3 ${CFLAGS}
	$(AM_V_at)${BIN}c168${EXEEXT} $*.1 $*.2 $*.s
	$(AM_V_at)${RUN_OPTIMIZE_${$*_OPTIMIZE}}
	$(AM_V_at)$(SED) -n '{$$!N; /clr R0\nmove [0-9]*(R13),R0/{D;p}; {P;D}}' $*.s > $*.1; mv $*.1 $*.s
	$(AM_V_at)$(SED) -n '{$$!N; /clr R0\nmove 0(R8,R9.l),R0/{D;p}; {P;D}}' $*.s > $*.1; mv $*.1 $*.s
	$(AM_V_at)${BIN}as68${EXEEXT} ${ASFLAGS} ${$*_ASFLAGS} -o $@ $*.s
	$(AM_V_at)${RM} $*.s $*.i $*.1 $*.2 $*.3

gemevlib.o: gemevlib.c
	$(AM_V_CC)${BIN}cp68${EXEEXT} ${CPPFLAGS} $< $*.i
	$(AM_V_at)${BIN}c068${EXEEXT} $*.i $*.1 $*.2 $*.3 ${CFLAGS}
	$(AM_V_at)${BIN}c168${EXEEXT} $*.1 $*.2 $*.s
	$(AM_V_at)${RUN_OPTIMIZE_${$*_OPTIMIZE}}
	$(AM_V_at)$(SED) -n '{$$!N; /clr R1\nmove [-0-9]*(R14),R1/{D;p}; {P;D}}' $*.s > $*.1; mv $*.1 $*.s
	$(AM_V_at)$(SED) -n '{$$!N; /clr R0\nmove R6,R0/{D;p}; {P;D}}' $*.s > $*.1; mv $*.1 $*.s
	$(AM_V_at)${BIN}as68${EXEEXT} ${ASFLAGS} ${$*_ASFLAGS} -o $@ $*.s
	$(AM_V_at)${RM} $*.s $*.i $*.1 $*.2 $*.3

gemrslib.o: gemrslib.c
	$(AM_V_CC)${BIN}cp68${EXEEXT} ${CPPFLAGS} $< $*.i
	$(AM_V_at)${BIN}c068${EXEEXT} $*.i $*.1 $*.2 $*.3 ${CFLAGS}
	$(AM_V_at)${BIN}c168${EXEEXT} $*.1 $*.2 $*.s
	$(AM_V_at)${RUN_OPTIMIZE_${$*_OPTIMIZE}}
	$(AM_V_at)$(SED) -n '{$$!N; /clr R0\nmove R7,R0/{D;p}; {P;D}}' $*.s > $*.1; mv $*.1 $*.s
	$(AM_V_at)$(SED) -n '{$$!N; /clr R0\nmove R6,R0/{D;p}; {P;D}}' $*.s > $*.1; mv $*.1 $*.s
	$(AM_V_at)${BIN}as68${EXEEXT} ${ASFLAGS} ${$*_ASFLAGS} -o $@ $*.s
	$(AM_V_at)${RM} $*.s $*.i $*.1 $*.2 $*.3

gemshlib.o: ../desk/deskstr.h

gemrom.o: gemrom.c ../glue/tosrsc.h

../glue/tosrsc.h:
	$(MAKE) -C ../glue tosrsc.h


# no check here; to much hassle to get all the external dependencies
check:: aes.a
	@:

clean:
	$(RM) $(AES_OBJS)
	$(RM) *.o *.a *.ndx *.i *.1 *.2 *.rel *.mod $(AES_CSRCS:.c=.s) $(PROGRAMS) $(top_srcdir)/common/config.h

distclean: clean
	$(RM) $(top_srcdir)/common/sections.mak
