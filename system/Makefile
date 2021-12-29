include ../Makefile.cmn
include ../Makefile.sil

poolfix3_ASFLAGS = -n
poolfix4_ASFLAGS = -n

LIBS = ${LIBC}

PROGRAMS = tos14fix.prg tos14fx2.prg tos14fx5.prg poolfix3.prg poolfix4.prg

all:: $(PROGRAMS)

include SRCFILES

tos14fix.prg: $(TOS14FIX_OBJS) ${MAKEFILE}
	$(AM_V_LD)${LD} ${LDFLAGS} -h 1 -o $@ ${TOS14FIX_OBJS}

tos14fx2.prg: $(TOS14FX2_OBJS) ${MAKEFILE}
	$(AM_V_LD)${LD} ${LDFLAGS} -h 1 -o $@ ${TOS14FX2_OBJS}

tos14fx5.prg: $(TOS14FX5_OBJS) ${MAKEFILE}
	$(AM_V_LD)${LD} ${LDFLAGS} -h 1 -o $@ ${TOS14FX5_OBJS}

poolfix3.prg: $(POOLFIX3_OBJS) ${MAKEFILE}
	$(AM_V_LD)${LD} ${LDFLAGS} -h 1 -o $@ ${POOLFIX3_OBJS}

poolfix4.prg: $(POOLFIX4_OBJS) ${MAKEFILE}
	$(AM_V_LD)${LD} ${LDFLAGS} -h 1 -o $@ ${POOLFIX4_OBJS}

check::

clean::
	$(RM) *.o *.a *.i *.1 *.2 *.rel *.mod $(PROGRAMS)

distclean:: clean
