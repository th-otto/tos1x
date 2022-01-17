top_srcdir=..\..
subdir=tospatch/tools

include $(top_srcdir)/Makefile.cmn
include $(top_srcdir)/Makefile.sil

PROGRAMS = loadtos.prg

all:: $(PROGRAMS)

loadtos.prg: loadtos.o ${MAKEFILE}
	$(AM_V_LD)${LD} ${LDFLAGS} -h 7 -o $@ loadtos.o

check::

clean::
	$(RM) *.o *.a *.i *.1 *.2 *.rel

distclean: clean
