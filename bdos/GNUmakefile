top_srcdir=..
subdir=bdos

# 
# cross compiling
#
EVAL_CROSS := case `uname -s` in *MiNT*|*TOS*) echo no;; *) echo yes; esac
CROSS := $(shell $(EVAL_CROSS))

include $(top_srcdir)/GNUmakefile.cmn
include $(top_srcdir)/Makefile.sil
include optimize.mak

CPPFLAGS = -I$(top_srcdir)/common -I$(INC)
CFLAGS = $(OPTS) $(WARN)

all:: $(top_srcdir)/common/config.h bdos.a

include $(top_srcdir)/config.mak
-include $(top_srcdir)/common/sections.mak

include SRCFILES

bdos.a: $(BDOS_OBJS) ${MAKEFILE}
	$(AM_V_AR)$(AR) $(ARFLAGS) $@ $(BDOS_OBJS)

$(BDOS_OBJS) $(VARS_OBJS) vdidsp.o: $(top_srcdir)/common/config.h

ifeq ($(USE_CROSS_ALCYON),1)
# sections.mak might have just been generated, make sure it is reread
bdos.o: $(top_srcdir)/common/config.h tosvars.o $(VARS_OBJS) vdidsp.o $(top_srcdir)/common/sections.mak $(BDOS_OBJS) ${MAKEFILE}
	$(MAKE) TOSVERSION=$(TOSVERSION) COUNTRY=$(COUNTRY) single

osmem.o: osmem.c
	$(AM_V_CC)$(CC) $(CFLAGS) $(CPPFLAGS) ${RUN_OPTIMIZE_${$*_OPTIMIZE}} -c -S -o $*.s $<
	$(AM_V_at)$(SUBSTLMUL)
	$(AM_V_at)$(SUBSTLDIV)
	$(AM_V_at)$(AS) $(ASFLAGS) -c $*.s
	$(AM_V_at)$(RM) $*.s

single: tosvars.o $(VARS_OBJS) vdidsp.o $(BDOS_OBJS) ${MAKEFILE}
	$(LD) -s -l -o bdos.o -a $(bdos_tbase) $(bdos_dbase) 0 tosvars.o $(VARS_OBJS) vdidsp.o $(BDOS_OBJS)
endif

# no check here; to much hassle to get all the external dependencies
check:: bdos.a
	@:

tosvars.o: $(top_srcdir)/common/tosvars.S $(top_srcdir)/common/config.h
	$(AM_V_AS)$(AS) $(ASFLAGS) $(CPPFLAGS) -c -o $@ $<

vars.o: $(top_srcdir)/common/vars.S $(top_srcdir)/common/config.h
	$(AM_V_AS)$(AS) $(ASFLAGS) $(CPPFLAGS) -c -o $@ $<

dist::
	$(CP) -a $(SRCS) $(EXTRA_DIST1) $(EXTRA_DIST2) $(top_srcdir)/$(DISTDIR1)/$(subdir)
	$(CP) -a $(EXTRA_DIST2) $(top_srcdir)/$(DISTDIR2)/$(subdir)

dosdir::
	$(CP) -a $(SRCS) $(EXTRA_DIST1) $(DOSDIR)/$(subdir)

clean:
	$(RM) *.o *.a *.ndx $(PROGRAMS) $(top_srcdir)/common/config.h

distclean: clean
	$(RM) $(top_srcdir)/common/sections.mak
