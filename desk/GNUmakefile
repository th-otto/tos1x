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

CPPFLAGS = -I$(top_srcdir)/common -I$(INC)
CFLAGS = $(OPTS) $(WARN)

all:: desk.a

include $(top_srcdir)/config.mak
-include $(top_srcdir)/common/sections.mak

include SRCFILES

desk.a: $(DESK_OBJS) ${MAKEFILE}
	$(AR) $(ARFLAGS) $@ $(DESK_OBJS)

ifeq ($(USE_CROSS_ALCYON),1)
# sections.mak might have just been generated, make sure it is reread
desk.o: $(VARS_OBJS) $(DESK_OBJS) deskext.o $(top_srcdir)/common/sections.mak ${MAKEFILE}
	$(MAKE) TOSVERSION=$(TOSVERSION) COUNTRY=$(COUNTRY) single

single: $(VARS_OBJS) $(DESK_OBJS) deskext.o
	$(LD) -u -s -l -o desk.o -a $(desk_tbase) $(desk_dbase) 0 $(VARS_OBJS) $(DESK_OBJS) deskext.o
endif


tosvars.o: $(top_srcdir)/common/tosvars.S $(top_srcdir)/common/config.h
	$(AM_V_AS)$(AS) $(ASFLAGS) $(CPPFLAGS) -c -o $@ $<

vars.o: $(top_srcdir)/common/vars.S $(top_srcdir)/common/config.h
	$(AM_V_AS)$(AS) $(ASFLAGS) $(CPPFLAGS) -c -o $@ $<

check:: desk.o $(top_srcdir)/common/sections.mak
	$(AM_V_at)$(CMP) $(CMPL) -x --ignore-initial=0x$(desk_toff):0x24 --offsets=0x$(desk_tbase):0 --bytes=0x$(desk_tlen) $(top_srcdir)/roms/tos$(TOSVERSION)$(COUNTRY).img desk.o
	$(AM_V_at)$(CMP) $(CMPL) -x --ignore-initial=0x$(desk_doff):0x$(desk_tleno) --offsets=0x$(desk_dbase):0x$(desk_tlen) --bytes=0x$(desk_dlen) $(top_srcdir)/roms/tos$(TOSVERSION)$(COUNTRY).img desk.o

dist::
	$(CP) -a $(SRCS) $(EXTRA_DIST1) $(EXTRA_DIST2) $(top_srcdir)/$(DISTDIR1)/$(subdir)
	$(CP) -a $(EXTRA_DIST2) $(top_srcdir)/$(DISTDIR2)/$(subdir)

dosdir::
	$(CP) -a $(SRCS) $(EXTRA_DIST1) $(DOSDIR)/$(subdir)

clean:
	$(RM) *.o *.a *.ndx $(PROGRAMS) $(top_srcdir)/common/config.h

distclean: clean
	$(RM) $(top_srcdir)/common/sections.mak
