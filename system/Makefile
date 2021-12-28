include ../Makefile.cmn
include ../Makefile.sil

TOS14FIX_ASFLAGS = -n

LIBS = ${LIBC}

PROGRAMS = tos14fix.prg

all:: $(PROGRAMS)

include SRCFILES

tos14fix.prg: $(TOS14FIX_OBJS) ${MAKEFILE}
	$(AM_V_LD)${LD} ${LDFLAGS} -h 7 -o $@ ${TOS14FIX_OBJS}

check::

clean::
	$(RM) *.o *.a *.i *.1 *.2 *.rel *.mod $(PROGRAMS)

distclean:: clean
