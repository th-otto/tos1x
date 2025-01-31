top_srcdir=..
subdir=desk

include $(top_srcdir)/Makefile.cmn
include $(top_srcdir)/Makefile.sil
include optimize.mak

all:: $(top_srcdir)/common/config.h desk.a

include $(top_srcdir)/config.mak
-include $(top_srcdir)/common/sections.mak

include SRCFILES

CPPFLAGS += -I$(top_srcdir)/aes

# only TOS versions <= 1.04 have the linef hack
LINEF_CFLAGS_104 = -A
LINEF_AFLAGS_104 = -A${BIN}lineftab.txt
LINEF_CFLAGS_100 = -A
LINEF_AFLAGS_100 = -A${BIN}lineftab.txt
LINEF_CFLAGS_102 = -A
LINEF_AFLAGS_102 = -A${BIN}lineftab.txt
CFLAGS += $(LINEF_CFLAGS_$(TOSVERSION))
ASFLAGS += $(LINEF_AFLAGS_$(TOSVERSION))

desk.a: tosvars.o $(top_srcdir)/common/config.h $(DESK_OBJS) ${MAKEFILE}
	$(AM_V_at)$(RM) $@
	$(AM_V_AR)$(AR) $(ARFLAGS) $@ $(DESK_OBJS)

#
# need to repeat the default suffix rule here,
# because on a FAT filesystem, .S cannot be
# distinguished from .s
#
vars.o: $(top_srcdir)/common/vars.S $(top_srcdir)/common/config.h
	$(AM_V_AS)${BIN}cp68${EXEEXT} ${CPPFLAGS} -P $< $*.i
	$(AM_V_at)${BIN}as68${EXEEXT} ${ASFLAGS} ${$*_ASFLAGS} $*.i $@
	$(AM_V_at)${RM} $*.i

tosvars.o: $(top_srcdir)/common/tosvars.S $(top_srcdir)/common/config.h
	$(AM_V_AS)${BIN}cp68${EXEEXT} ${CPPFLAGS} -P $< $*.i
	$(AM_V_at)${BIN}as68${EXEEXT} ${ASFLAGS} ${$*_ASFLAGS} $*.i $@
	$(AM_V_at)${RM} $*.i

rainbow.o: rainbow.S
	$(AM_V_AS)${BIN}cp68${EXEEXT} ${CPPFLAGS} -P $< $*.i
	$(AM_V_at)${BIN}as68${EXEEXT} ${ASFLAGS} ${$*_ASFLAGS} $*.i $@
	$(AM_V_at)${RM} $*.i

deskext.o: deskext.S $(top_srcdir)/common/config.h $(top_srcdir)/common/sections.inc
	$(AM_V_AS)${BIN}cp68${EXEEXT} ${CPPFLAGS} -P $*.S $*.i
	$(AM_V_at)${BIN}as68${EXEEXT} ${ASFLAGS} ${$*_ASFLAGS} $*.i
	$(AM_V_at)${RM} $*.i

# remove some superflous clr.w D0 that for some reason
# don't appear in the final ROM

deskapp1.o: deskapp1.c
	$(AM_V_CC)${BIN}cp68${EXEEXT} ${CPPFLAGS} $< $*.i
	$(AM_V_at)${BIN}c068${EXEEXT} $*.i $*.1 $*.2 $*.3 ${CFLAGS}
	$(AM_V_at)${BIN}c168${EXEEXT} $*.1 $*.2 $*.s
	$(AM_V_at)${RUN_OPTIMIZE_${$*_OPTIMIZE}}
	$(AM_V_at)$(SED) -n '{$$!N; /clr R0\nmove [0-9]*(R14),R0/{D;p}; {P;D}}' $*.s > $*.1; mv $*.1 $*.s
	$(AM_V_at)${BIN}as68${EXEEXT} ${ASFLAGS} ${$*_ASFLAGS} -o $@ $*.s
	$(AM_V_at)$(RM) $*.s $*.i $*.1 $*.2 $*.3

deskapp3.o: deskapp3.c
	$(AM_V_CC)${BIN}cp68${EXEEXT} ${CPPFLAGS} $< $*.i
	$(AM_V_at)${BIN}c068${EXEEXT} $*.i $*.1 $*.2 $*.3 ${CFLAGS}
	$(AM_V_at)${BIN}c168${EXEEXT} $*.1 $*.2 $*.s
	$(AM_V_at)${RUN_OPTIMIZE_${$*_OPTIMIZE}}
	$(AM_V_at)$(SED) -n '{$$!N; /clr R0\nmove #-[0-9]*,R0/{D;p}; {P;D}}' $*.s > $*.1; mv $*.1 $*.s
	$(AM_V_at)${BIN}as68${EXEEXT} ${ASFLAGS} ${$*_ASFLAGS} -o $@ $*.s
	$(AM_V_at)$(RM) $*.s $*.i $*.1 $*.2 $*.3

deskif.o: deskif.c
	$(AM_V_CC)${BIN}cp68${EXEEXT} ${CPPFLAGS} $< $*.i
	$(AM_V_at)${BIN}c068${EXEEXT} $*.i $*.1 $*.2 $*.3 ${CFLAGS}
	$(AM_V_at)${BIN}c168${EXEEXT} $*.1 $*.2 $*.s
	$(AM_V_at)${RUN_OPTIMIZE_${$*_OPTIMIZE}}
	$(AM_V_at)$(SED) -n '{$$!N; /clr R0\nmove [0-9]*(R14),R0/{D;p}; {P;D}}' $*.s > $*.1; mv $*.1 $*.s
	$(AM_V_at)${BIN}as68${EXEEXT} ${ASFLAGS} ${$*_ASFLAGS} -o $@ $*.s
	$(AM_V_at)$(RM) $*.s $*.i $*.1 $*.2 $*.3

deskinf.o: deskinf.c
	$(AM_V_CC)${BIN}cp68${EXEEXT} ${CPPFLAGS} $< $*.i
	$(AM_V_at)${BIN}c068${EXEEXT} $*.i $*.1 $*.2 $*.3 ${CFLAGS}
	$(AM_V_at)${BIN}c168${EXEEXT} $*.1 $*.2 $*.s
	$(AM_V_at)${RUN_OPTIMIZE_${$*_OPTIMIZE}}
	$(AM_V_at)$(SED) -n '{$$!N; /clr R0\nmove R7,R0/{D;p}; {P;D}}' $*.s > $*.1; mv $*.1 $*.s
	$(AM_V_at)$(SED) -n '{$$!N; /clr R0\nmove [0-9]*(R14),R0/{D;p}; {P;D}}' $*.s > $*.1; mv $*.1 $*.s
	$(AM_V_at)$(SED) -n '{$$!N; /clr R1\nmove [0-9]*(R14),R1/{D;p}; {P;D}}' $*.s > $*.1; mv $*.1 $*.s
	$(AM_V_at)${BIN}as68${EXEEXT} ${ASFLAGS} ${$*_ASFLAGS} -o $@ $*.s
	$(AM_V_at)$(RM) $*.s $*.i $*.1 $*.2 $*.3

deskfpd.o: deskfpd.c
	$(AM_V_CC)${BIN}cp68${EXEEXT} ${CPPFLAGS} $< $*.i
	$(AM_V_at)${BIN}c068${EXEEXT} $*.i $*.1 $*.2 $*.3 ${CFLAGS}
	$(AM_V_at)${BIN}c168${EXEEXT} $*.1 $*.2 $*.s
	$(AM_V_at)${RUN_OPTIMIZE_${$*_OPTIMIZE}}
	$(AM_V_at)$(SED) -n '{$$!N; /clr R0\nmove [0-9]*(R12),R0/{D;p}; {P;D}}' $*.s > $*.1; mv $*.1 $*.s
	$(AM_V_at)$(SED) -n '{$$!N; /clr R1\nmove [0-9]*(R13),R1/{D;p}; {P;D}}' $*.s > $*.1; mv $*.1 $*.s
	$(AM_V_at)${BIN}as68${EXEEXT} ${ASFLAGS} ${$*_ASFLAGS} -o $@ $*.s
	$(AM_V_at)$(RM) $*.s $*.i $*.1 $*.2 $*.3

desksupp.o: desksupp.c desksup3.c
deskinf.o: deskinf.c deskinf2.c deskpref.c
desksupp.o deskshow.o deskdisk.o: deskstr.h

# no check here; to much hassle to get all the external dependencies
check:: desk.a
	@:

clean:
	$(RM) *.o *.a *.ndx *.i *.1 *.2 *.rel *.mod $(DESK_CSRCS:.c=.s) $(PROGRAMS) $(top_srcdir)/common/config.h

distclean: clean
	$(RM) $(top_srcdir)/common/sections.mak
