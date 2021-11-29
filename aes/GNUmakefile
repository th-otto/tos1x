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
CPPFLAGS += -A
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

single: $(VARS_OBJS) $(STARTUP) $(AES_OBJS) aesext.o
	$(LD) -l -s -o aes.o -a $(aes_tbase) $(aes_dbase) 0 $(VARS_OBJS) $(STARTUP) $(AES_OBJS) aesext.o

endif

tosvars.o: $(top_srcdir)/common/tosvars.S $(top_srcdir)/common/config.h
	$(AM_V_AS)$(AS) $(ASFLAGS) $(CPPFLAGS) -c -o $@ $<

vars.o: $(top_srcdir)/common/vars.S $(top_srcdir)/common/config.h
	$(AM_V_AS)$(AS) $(ASFLAGS) $(CPPFLAGS) -c -o $@ $<

aesext.o: aesext.S $(top_srcdir)/common/sections.inc $(top_srcdir)/common/config.h
	$(AM_V_AS)$(AS) $(ASFLAGS) $(CPPFLAGS) -c -o $@ $<

check:: aes.o $(top_srcdir)/common/sections.mak
	$(AM_V_at)$(CMP) $(CMPL) -x --ignore-initial=0x$(aes_toff):0x24 --offsets=0x$(aes_tbase):0 --bytes=0x$(aes_tlen) $(top_srcdir)/roms/tos$(TOSVERSION)$(COUNTRY).img aes.o
	$(AM_V_at)$(CMP) $(CMPL) -x --ignore-initial=0x$(aes_doff):0x$(aes_tleno) --offsets=0x$(aes_dbase):0x$(aes_tlen) --bytes=0x$(aes_dlen) $(top_srcdir)/roms/tos$(TOSVERSION)$(COUNTRY).img aes.o

dist::
	$(CP) -a $(SRCS) $(EXTRA_DIST1) $(EXTRA_DIST2) $(top_srcdir)/$(DISTDIR1)/$(subdir)
	$(CP) -a $(EXTRA_DIST2) $(top_srcdir)/$(DISTDIR2)/$(subdir)

dosdir::
	$(CP) -a $(SRCS) $(EXTRA_DIST1) $(DOSDIR)/$(subdir)

clean:
	$(RM) $(AES_OBJS)
	$(RM) *.o *.a *.ndx $(PROGRAMS) $(top_srcdir)/common/config.h

distclean: clean
	$(RM) $(top_srcdir)/common/sections.mak
