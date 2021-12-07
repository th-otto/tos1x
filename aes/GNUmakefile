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
gembind.o: gembind.c
	$(AM_V_CC)$(CC) $(CFLAGS) $(CPPFLAGS) ${RUN_OPTIMIZE_${$*_OPTIMIZE}} -c -S -o $*.s $<
	$(AM_V_at)$(SED) -e 's/bra L2/bra L9999/' $*.s > $*.i; $(MV) $*.i $*.s
	$(AM_V_at)$(AS) $(ASFLAGS) -c $(LINEF_FLAGS) $*.s
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
check::

clean:
	$(RM) $(AES_OBJS)
	$(RM) *.o *.a *.ndx $(PROGRAMS) $(top_srcdir)/common/config.h

distclean: clean
	$(RM) $(top_srcdir)/common/sections.mak
