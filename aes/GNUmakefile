top_srcdir=..
subdir=aes

# 
# cross compiling
#
EVAL_CROSS := case `uname -s` in *MiNT*|*TOS*) echo no;; *) echo yes; esac
CROSS := $(shell $(EVAL_CROSS))

include $(top_srcdir)/GNUmakefile.cmn
include $(top_srcdir)/Makefile.sil
include optimize.mak

LIBS =

CPPFLAGS = -I$(top_srcdir)/common -I$(INC)
CFLAGS = $(OPTS) $(WARN)

all:: aes.a

include $(top_srcdir)/config.mak
-include $(top_srcdir)/common/sections.mak

ifeq ($(USE_CROSS_ALCYON),1)
ifeq ($(TOSVERSION),104)
LINEF_FLAGS = -A
CPPFLAGS += $(LINEF_FLAGS)
endif
ifeq ($(TOSVERSION),100)
LINEF_FLAGS = -A
CPPFLAGS += $(LINEF_FLAGS)
endif
endif

include SRCFILES

STARTUP =	gemjstrt.o

aes.a: $(STARTUP) $(AES_OBJS) ${MAKEFILE}
	$(AR) $(ARFLAGS) $@ $(STARTUP) $(AES_OBJS)

ifeq ($(USE_CROSS_ALCYON),1)
# sections.mak might have just been generated, make sure it is reread
aes.o: $(VARS_OBJS) $(STARTUP) $(AES_OBJS) aesext.o $(top_srcdir)/common/sections.mak ${MAKEFILE}
	$(MAKE) TOSVERSION=$(TOSVERSION) COUNTRY=$(COUNTRY) single

#
# ugly hack for even more ugly assembly in gembind.c
#
ASMHACK_104 = $(SED) -e 's/bra L2/bra L9999/' $*.s > $*.i; $(MV) $*.i $*.s
ASMHACK_106 = $(SED) -e 's/bra L2/bra L9999/' $*.s > $*.i; $(MV) $*.i $*.s
ASMHACK_162 = $(SED) -e 's/bra L2/bra L9999/' $*.s > $*.i; $(MV) $*.i $*.s
ASMHACK = $(ASMHACK_$(TOSVERSION))

gembind.o: gembind.c
	$(AM_V_CC)$(CC) $(CFLAGS) $(CPPFLAGS) ${RUN_OPTIMIZE_${$*_OPTIMIZE}} -c -S -o $*.s $<
	$(AM_V_at)$(ASMHACK)
	$(AM_V_at)$(SED) -n '{$$!N; /clr R0\nmove [0-9]*(R8),R0/{D;p}; {P;D}}' $*.s > $*.1; mv $*.1 $*.s
	$(AM_V_at)$(SED) -n '{$$!N; /clr R1\nmove [0-9]*(R9),R1/{D;p}; {P;D}}' $*.s > $*.1; mv $*.1 $*.s
	$(AM_V_at)$(SED) -n '{$$!N; /clr R2\nmove [0-9]*(R10),R2/{D;p}; {P;D}}' $*.s > $*.1; mv $*.1 $*.s
	$(AM_V_at)$(SED) -n '{$$!N; /clr R0\nmove [-0-9]*(R14),R0/{D;p}; {P;D}}' $*.s > $*.1; mv $*.1 $*.s
	$(AM_V_at)$(CC) $(CFLAGS) $(CPPFLAGS) -c -o $@ $*.s
	$(AM_V_at)$(RM) $*.s

# remove some superflous clr.w D0 that for some reason
# don't appear in the final ROM
apgrlib.o: apgrlib.c
	$(AM_V_CC)$(CC) $(CFLAGS) $(CPPFLAGS) -c -S -o $*.s $<
	$(AM_V_at)$(SED) -n '{$$!N; /clr R0\nmove R7,R0/{D;p}; {P;D}}' $*.s > $*.1; mv $*.1 $*.s
	$(AM_V_at)$(CC) $(CFLAGS) $(CPPFLAGS) -c -o $@ $*.s
	$(AM_V_at)$(RM) $*.s

apgsxif.o: apgsxif.c
	$(AM_V_CC)$(CC) $(CFLAGS) $(CPPFLAGS) -c -S -o $*.s $<
	$(AM_V_at)$(SED) -n '{$$!N; /clr R0\nmove R7,R0/{D;p}; {P;D}}' $*.s > $*.1; mv $*.1 $*.s
	$(AM_V_at)$(SED) -n '{$$!N; /clr R0\nmove R6,R0/{D;p}; {P;D}}' $*.s > $*.1; mv $*.1 $*.s
	$(AM_V_at)$(SED) -n '{$$!N; /clr R0\nmove R4,R0/{D;p}; {P;D}}' $*.s > $*.1; mv $*.1 $*.s
	$(AM_V_at)$(SED) -n '{$$!N; /clr R0\nmove R3,R0/{D;p}; {P;D}}' $*.s > $*.1; mv $*.1 $*.s
	$(AM_V_at)$(CC) $(CFLAGS) $(CPPFLAGS) -c -o $@ $*.s
	$(AM_V_at)$(RM) $*.s

gemaints.o: gemaints.c
	$(AM_V_CC)$(CC) $(CFLAGS) $(CPPFLAGS) -c -S -o $*.s $<
	$(AM_V_at)$(SED) -n '{$$!N; /clr R0\nmove [0-9]*(R13),R0/{D;p}; {P;D}}' $*.s > $*.1; mv $*.1 $*.s
	$(AM_V_at)$(CC) $(CFLAGS) $(CPPFLAGS) -c -o $@ $*.s
	$(AM_V_at)$(RM) $*.s

gemasync.o: gemasync.c
	$(AM_V_CC)$(CC) $(CFLAGS) $(CPPFLAGS) -c -S -o $*.s $<
	$(AM_V_at)$(SED) -n '{$$!N; /clr R0\nmove [0-9]*(R8),R0/{D;p}; {P;D}}' $*.s > $*.1; mv $*.1 $*.s
	$(AM_V_at)$(SED) -n '{$$!N; /clr R0\nmove [0-9]*(R13),R0/{D;p}; {P;D}}' $*.s > $*.1; mv $*.1 $*.s
	$(AM_V_at)$(SED) -n '{$$!N; /clr R0\nmove R7,R0/{D;p}; {P;D}}' $*.s > $*.1; mv $*.1 $*.s
	$(AM_V_at)$(SED) -n '{$$!N; /clr R0\nmove [-0-9]*(R14),R0/{D;p}; {P;D}}' $*.s > $*.1; mv $*.1 $*.s
	$(AM_V_at)$(CC) $(CFLAGS) $(CPPFLAGS) -c -o $@ $*.s
	$(AM_V_at)$(RM) $*.s

gemdisp.o: gemdisp.c
	$(AM_V_CC)$(CC) $(CFLAGS) $(CPPFLAGS) -c -S -o $*.s $<
	$(AM_V_at)$(SED) -n '{$$!N; /clr R0\nmove [0-9]*(R13),R0/{D;p}; {P;D}}' $*.s > $*.1; mv $*.1 $*.s
	$(AM_V_at)$(SED) -n '{$$!N; /clr R0\nmove 0(R8,R9.l),R0/{D;p}; {P;D}}' $*.s > $*.1; mv $*.1 $*.s
	$(AM_V_at)$(CC) $(CFLAGS) $(CPPFLAGS) -c -o $@ $*.s
	$(AM_V_at)$(RM) $*.s

gemevlib.o: gemevlib.c
	$(AM_V_CC)$(CC) $(CFLAGS) $(CPPFLAGS) -c -S -o $*.s $<
	$(AM_V_at)$(SED) -n '{$$!N; /clr R1\nmove [-0-9]*(R14),R1/{D;p}; {P;D}}' $*.s > $*.1; mv $*.1 $*.s
	$(AM_V_at)$(SED) -n '{$$!N; /clr R0\nmove R6,R0/{D;p}; {P;D}}' $*.s > $*.1; mv $*.1 $*.s
	$(AM_V_at)$(CC) $(CFLAGS) $(CPPFLAGS) -c -o $@ $*.s
	$(AM_V_at)$(RM) $*.s

gemrslib.o: gemrslib.c
	$(AM_V_CC)$(CC) $(CFLAGS) $(CPPFLAGS) -c -S -o $*.s $<
	$(AM_V_at)$(SED) -n '{$$!N; /clr R0\nmove R7,R0/{D;p}; {P;D}}' $*.s > $*.1; mv $*.1 $*.s
	$(AM_V_at)$(SED) -n '{$$!N; /clr R0\nmove R6,R0/{D;p}; {P;D}}' $*.s > $*.1; mv $*.1 $*.s
	$(AM_V_at)$(CC) $(CFLAGS) $(CPPFLAGS) -c -o $@ $*.s
	$(AM_V_at)$(RM) $*.s

single::

endif

tosvars.o: $(top_srcdir)/common/tosvars.S $(top_srcdir)/common/config.h
	$(AM_V_AS)$(AS) $(ASFLAGS) $(CPPFLAGS) -c -o $@ $<

vars.o: $(top_srcdir)/common/vars.S $(top_srcdir)/common/config.h
	$(AM_V_AS)$(AS) $(ASFLAGS) $(CPPFLAGS) -c -o $@ $<

aesext.o: aesext.S $(top_srcdir)/common/sections.inc $(top_srcdir)/common/config.h
	$(AM_V_AS)$(AS) $(ASFLAGS) $(CPPFLAGS) -c -o $@ $<

# no check here; has to be done in desktop
check:: aes.a

clean:
	$(RM) $(AES_OBJS)
	$(RM) *.o *.a *.ndx $(PROGRAMS) $(top_srcdir)/common/config.h

distclean: clean
	$(RM) $(top_srcdir)/common/sections.mak
