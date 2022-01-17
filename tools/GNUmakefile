top_srcdir=..
subdir=tools

USE_CROSS_ALCYON=0

include $(top_srcdir)/GNUmakefile.cmn
include $(top_srcdir)/Makefile.sil

CC := $(BUILD_CC)

LIBS =

CPPFLAGS =
CFLAGS = $(OPTS) $(WARN)

PROGRAMS = cmprom$(BUILD_EXEEXT) newglue$(BUILD_EXEEXT) findrsc$(BUILD_EXEEXT) mkbininc$(BUILD_EXEEXT) mkrom$(BUILD_EXEEXT) bin2c$(BUILD_EXEEXT)

all:: $(PROGRAMS)

include $(top_srcdir)/config.mak
-include $(top_srcdir)/common/sections.mak

include SRCFILES

cmprom$(BUILD_EXEEXT): cmprom.o
	$(AM_V_LD)$(BUILD_CC) $(CFLAGS) -o $@ $< $(LIBS)

newglue$(BUILD_EXEEXT): newglue.o
	$(AM_V_LD)$(BUILD_CC) $(CFLAGS) -o $@ $< $(LIBS)

findrsc$(BUILD_EXEEXT): findrsc.o
	$(AM_V_LD)$(BUILD_CC) $(CFLAGS) -o $@ $< $(LIBS)

mkbininc$(BUILD_EXEEXT): mkbininc.o
	$(AM_V_LD)$(BUILD_CC) $(CFLAGS) -o $@ $< $(LIBS)

mkrom$(BUILD_EXEEXT): mkrom.o
	$(AM_V_LD)$(BUILD_CC) $(CFLAGS) -o $@ $< $(LIBS)

bin2c$(BUILD_EXEEXT): bin2c.o
	$(AM_V_LD)$(BUILD_CC) $(CFLAGS) -o $@ $< $(LIBS)

check::
	@:

clean:
	$(RM) *.o *.a $(PROGRAMS)

distclean: clean
