top_srcdir=..
subdir=desk

# 
# cross compiling
#
EVAL_CROSS := case `uname -s` in *MiNT*|*TOS*) echo no;; *) echo yes; esac
CROSS := $(shell $(EVAL_CROSS))

include $(top_srcdir)/GNUmakefile.cmn
include $(top_srcdir)/Makefile.sil
include optimize.mak

LIBS =

CPPFLAGS = -I$(top_srcdir)/common -I$(top_srcdir)/aes -I$(INC)
CFLAGS = $(OPTS) $(WARN)

all:: desk.a

include $(top_srcdir)/config.mak
-include $(top_srcdir)/common/sections.mak

# only TOS versions <= 1.04 have the linef hack
ifeq ($(USE_CROSS_ALCYON),1)
ifeq ($(TOSVERSION),104)
CPPFLAGS += -A
endif
ifeq ($(TOSVERSION),100)
CPPFLAGS += -A
endif
endif

include SRCFILES

desk.a: $(DESK_OBJS) ${MAKEFILE}
	$(AR) $(ARFLAGS) $@ $(DESK_OBJS)

ifeq ($(USE_CROSS_ALCYON),1)
# sections.mak might have just been generated, make sure it is reread
desk.o: $(VARS_OBJS) $(DESK_OBJS) deskext.o $(top_srcdir)/common/sections.mak ${MAKEFILE}
	$(MAKE) TOSVERSION=$(TOSVERSION) COUNTRY=$(COUNTRY) single

single::

# remove some superflous clr.w D0 that for some reason
# don't appear in the final ROM
deskapp1.o: deskapp1.c
	$(AM_V_CC)$(CC) $(CFLAGS) $(CPPFLAGS) -c -S -o $*.s $<
	$(AM_V_at)$(SED) -n '{$$!N; /clr R0\nmove [0-9]*(R14),R0/{D;p}; {P;D}}' $*.s > $*.1; mv $*.1 $*.s
	$(AM_V_at)$(CC) $(CFLAGS) $(CPPFLAGS) -c -o $@ $*.s
	$(AM_V_at)$(RM) $*.s

deskapp3.o: deskapp3.c
	$(AM_V_CC)$(CC) $(CFLAGS) $(CPPFLAGS) -c -S -o $*.s $<
	$(AM_V_at)$(SED) -n '{$$!N; /clr R0\nmove #-[0-9]*,R0/{D;p}; {P;D}}' $*.s > $*.1; mv $*.1 $*.s
	$(AM_V_at)$(CC) $(CFLAGS) $(CPPFLAGS) -c -o $@ $*.s
	$(AM_V_at)$(RM) $*.s

deskif.o: deskif.c
	$(AM_V_CC)$(CC) $(CFLAGS) $(CPPFLAGS) -c -S -o $*.s $<
	$(AM_V_at)$(SED) -n '{$$!N; /clr R0\nmove [0-9]*(R14),R0/{D;p}; {P;D}}' $*.s > $*.1; mv $*.1 $*.s
	$(AM_V_at)$(CC) $(CFLAGS) $(CPPFLAGS) -c -o $@ $*.s
	$(AM_V_at)$(RM) $*.s

deskinf.o: deskinf.c
	$(AM_V_CC)$(CC) $(CFLAGS) $(CPPFLAGS) -c -S -o $*.s $<
	$(AM_V_at)$(SED) -n '{$$!N; /clr R0\nmove R7,R0/{D;p}; {P;D}}' $*.s > $*.1; mv $*.1 $*.s
	$(AM_V_at)$(SED) -n '{$$!N; /clr R0\nmove [0-9]*(R14),R0/{D;p}; {P;D}}' $*.s > $*.1; mv $*.1 $*.s
	$(AM_V_at)$(SED) -n '{$$!N; /clr R1\nmove [0-9]*(R14),R1/{D;p}; {P;D}}' $*.s > $*.1; mv $*.1 $*.s
	$(AM_V_at)$(CC) $(CFLAGS) $(CPPFLAGS) -c -o $@ $*.s
	$(AM_V_at)$(RM) $*.s

deskfpd.o: deskfpd.c
	$(AM_V_CC)$(CC) $(CFLAGS) $(CPPFLAGS) -c -S -o $*.s $<
	$(AM_V_at)$(SED) -n '{$$!N; /clr R0\nmove [0-9]*(R12),R0/{D;p}; {P;D}}' $*.s > $*.1; mv $*.1 $*.s
	$(AM_V_at)$(SED) -n '{$$!N; /clr R1\nmove [0-9]*(R13),R1/{D;p}; {P;D}}' $*.s > $*.1; mv $*.1 $*.s
	$(AM_V_at)$(CC) $(CFLAGS) $(CPPFLAGS) -c -o $@ $*.s
	$(AM_V_at)$(RM) $*.s

endif

tosvars.o: $(top_srcdir)/common/tosvars.S $(top_srcdir)/common/config.h
	$(AM_V_AS)$(AS) $(ASFLAGS) $(CPPFLAGS) -c -o $@ $<

vars.o: $(top_srcdir)/common/vars.S $(top_srcdir)/common/config.h
	$(AM_V_AS)$(AS) $(ASFLAGS) $(CPPFLAGS) -c -o $@ $<

desksupp.o: desksupp.c desksup3.c
deskinf.o: deskinf.c deskinf2.c deskpref.c
desksupp.o deskshow.o deskdisk.o: deskstr.h

# no check here; to much hassle to get all the external dependencies
check:: desk.a

dist::
	$(CP) -a $(SRCS) $(EXTRA_DIST1) $(EXTRA_DIST2) $(top_srcdir)/$(DISTDIR1)/$(subdir)
	$(CP) -a $(EXTRA_DIST2) $(top_srcdir)/$(DISTDIR2)/$(subdir)

dosdir::
	$(CP) -a $(SRCS) $(EXTRA_DIST1) $(DOSDIR)/$(subdir)

clean:
	$(RM) *.o *.a *.ndx $(PROGRAMS) $(top_srcdir)/common/config.h

distclean: clean
	$(RM) $(top_srcdir)/common/sections.mak
