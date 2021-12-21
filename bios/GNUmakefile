top_srcdir=..
subdir=bios

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

all:: bios.a

include $(top_srcdir)/config.mak
-include $(top_srcdir)/common/sections.mak

include SRCFILES

ifeq ($(USE_CROSS_ALCYON),1)
NO_BRANCH_OPT = -n
endif

bios.a: $(BIOS_OBJS) ${MAKEFILE}
	$(AM_V_AR)$(AR) $(ARFLAGS) $@ $(BIOS_OBJS)

startup.o: startup.S $(top_srcdir)/common/config.h header.h scrdmp.inc
	$(AM_V_AS)$(AS) $(ASFLAGS) $(NO_BRANCH_OPT) $(CPPFLAGS) -c -o $@ $<

floppy.o: floppy.S $(top_srcdir)/common/config.h
	$(AM_V_AS)$(AS) $(ASFLAGS) $(NO_BRANCH_OPT) $(CPPFLAGS) -c -o $@ $<

vars.o: $(top_srcdir)/common/vars.S $(top_srcdir)/common/config.h
	$(AM_V_AS)$(AS) $(ASFLAGS) $(CPPFLAGS) -c -o $@ $<

tosvars.o: $(top_srcdir)/common/tosvars.S $(top_srcdir)/common/config.h
	$(AM_V_AS)$(AS) $(ASFLAGS) $(CPPFLAGS) -c -o $@ $<

keytbl.o: $(top_srcdir)/common/config.h

prtkeys$(EXEEXT): prtkeys.o
	$(AM_V_LD)${LD} ${LDFLAGS} -o $@ prtkeys.o

ifeq ($(USE_CROSS_ALCYON),1)
# sections.mak might have just been generated, make sure it is reread
bios.o: tosvars.o $(VARS_OBJS) $(BIOS_OBJS) biosext.o $(top_srcdir)/common/sections.mak ${MAKEFILE}
	$(MAKE) TOSVERSION=$(TOSVERSION) COUNTRY=$(COUNTRY) single

blkdev.o: blkdev.c
	$(AM_V_CC)$(CC) $(CFLAGS) $(CPPFLAGS) ${RUN_OPTIMIZE_${$*_OPTIMIZE}} -c -S -o $*.s $<
	$(AM_V_at)$(SUBSTLMUL)
	$(AM_V_at)$(AS) $(ASFLAGS) -c $*.s
	$(AM_V_at)$(RM) $*.s

single: tosvars.o $(VARS_OBJS) biosext.o $(BIOS_OBJS) ${MAKEFILE}
	$(LD) -u -s -l -o bios.o -a $(bios_tbase) $(bios_dbase) 0 tosvars.o $(VARS_OBJS) $(BIOS_OBJS) biosext.o
endif

check:: bios.o $(top_srcdir)/common/sections.mak
	$(AM_V_at)$(CMP) $(CMPL) -x --ignore-initial=0x$(bios_toff):0x24 --offsets=0x$(bios_tbase):0 --bytes=0x$(bios_tlen) $(top_srcdir)/roms/tos$(TOSVERSION)$(COUNTRY).img $<
	$(AM_V_at)$(CMP) $(CMPL) -x --ignore-initial=0x$(bios_doff):0x$(bios_tleno) --offsets=0x$(bios_dbase):0x$(bios_tlen) --bytes=0x$(bios_dlen) $(top_srcdir)/roms/tos$(TOSVERSION)$(COUNTRY).img $<

dist::
	$(CP) -a $(SRCS) $(EXTRA_DIST1) $(EXTRA_DIST2) $(top_srcdir)/$(DISTDIR1)/$(subdir)
	$(CP) -a $(EXTRA_DIST2) $(top_srcdir)/$(DISTDIR2)/$(subdir)

dosdir::
	$(CP) -a $(SRCS) $(EXTRA_DIST1) $(DOSDIR)/$(subdir)

clean:
	$(RM) *.o *.a *.ndx $(PROGRAMS) $(top_srcdir)/common/config.h

distclean: clean
	$(RM) $(top_srcdir)/common/sections.mak
