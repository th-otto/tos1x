top_srcdir=..
subdir=vdi

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

all:: $(top_srcdir)/common/config.h vdi.a vdivar.o

include $(top_srcdir)/config.mak
-include $(top_srcdir)/common/sections.mak

include SRCFILES

vdi.a: $(VDI_$(TOSVERSION)_OBJS) ${MAKEFILE}
	$(AR) $(ARFLAGS) $@ $(VDI_$(TOSVERSION)_OBJS)

ifeq ($(USE_CROSS_ALCYON),1)
# sections.mak might have just been generated, make sure it is reread
vdi.o: tosvars.o $(VARS_OBJS) vdiext.o $(top_srcdir)/common/config.h $(top_srcdir)/common/sections.mak $(VDI_OBJS) ${MAKEFILE}
	$(MAKE) TOSVERSION=$(TOSVERSION) COUNTRY=$(COUNTRY) single

single: tosvars.o $(VARS_OBJS) vdiext.o $(VDI_OBJS) ${MAKEFILE}
	$(LD) -s -l -o vdi.o -a $(vdi_tbase) $(vdi_dbase) 0 tosvars.o $(VARS_OBJS) vdiext.o $(VDI_OBJS)

#
# sed: optimizer seems to have missed an add.l #4,(sp) in make_header()
#
text_306_sed=$(SED) -e 's/add.l \#4,(sp)/dc.w 22679/' $*.s > $*.1; mv $*.1 $*.s

ifeq ($(TOSVERSION),306)
text.o: text.c
	$(AM_V_CC)$(CC) $(CFLAGS) $(CPPFLAGS) -c -S -o $*.s $<
	$(AM_V_at)$(text_$(TOSVERSION)_sed)
	$(AM_V_at)$(BIN)optimize -q $*.s
	$(AM_V_at)$(CC) $(CFLAGS) $(CPPFLAGS) -c -o $@ $*.s
	$(AM_V_at)$(RM) $*.s
endif

endif

mono.o: mono.S sbmono.S
blastman.o: blastman.S sbblit.S

tosvars.o: $(top_srcdir)/common/tosvars.S $(top_srcdir)/common/config.h
	$(AM_V_AS)$(AS) $(ASFLAGS) $(CPPFLAGS) -c -o $@ $<

vars.o: $(top_srcdir)/common/vars.S $(top_srcdir)/common/config.h
	$(AM_V_AS)$(AS) $(ASFLAGS) $(CPPFLAGS) -c -o $@ $<

vdiext.o: vdiext.S $(top_srcdir)/common/sections.inc
	$(AM_V_AS)$(AS) $(ASFLAGS) $(CPPFLAGS) -c -o $@ $<

# no check here; to much hassle to get all the external dependencies
check:: vdi.a
	@:

dist::
	$(CP) -a $(SRCS) $(EXTRA_DIST1) $(EXTRA_DIST2) $(top_srcdir)/$(DISTDIR1)/$(subdir)
	$(CP) -a $(EXTRA_DIST2) $(top_srcdir)/$(DISTDIR2)/$(subdir)

dosdir::
	$(CP) -a $(SRCS) $(EXTRA_DIST1) $(DOSDIR)/$(subdir)

clean:
	$(RM) *.o *.a *.ndx $(PROGRAMS) $(top_srcdir)/common/config.h

distclean: clean
	$(RM) $(top_srcdir)/common/sections.mak
