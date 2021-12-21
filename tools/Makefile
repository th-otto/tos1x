top_srcdir=..
subdir=tools

include $(top_srcdir)/Makefile.cmn
include $(top_srcdir)/Makefile.sil

LIBS = $(LIBC)
INC := ..${BS}include${BS}

PROGRAMS = newglue$(BUILD_EXEEXT) mkbininc$(BUILD_EXEEXT) mkrom$(BUILD_EXEEXT)
PROGRAMS += cmprom$(BUILD_EXEEXT)
# didnt bother to port these to alcyon
#PROGRAMS += findrsc$(BUILD_EXEEXT)

all:: $(PROGRAMS)

include $(top_srcdir)/config.mak
-include $(top_srcdir)/common/sections.mak

include SRCFILES

cmprom$(BUILD_EXEEXT): cmprom.o
	$(LD) -s -o $@ $(CRT0) $< $(LIBS)

newglue$(BUILD_EXEEXT): newglue.o
	$(LD) -o $@ $(CRT0) $< $(LIBS)

findrsc$(BUILD_EXEEXT): findrsc.o
	$(LD) -o $@ $(CRT0) $< $(LIBS)

mkbininc$(BUILD_EXEEXT): mkbininc.o
	$(LD) -o $@ $(CRT0) $< $(LIBS)

mkrom$(BUILD_EXEEXT): mkrom.o
	$(LD) -o $@ $(CRT0) $< $(LIBS)

check: $(PROGRAMS)

dist::

clean:
	$(RM) *.o *.a $(PROGRAMS)

distclean: clean
