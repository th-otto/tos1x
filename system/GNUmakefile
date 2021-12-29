top_srcdir=..
subdir=system

# 
# cross compiling
#
EVAL_CROSS := case `uname -s` in *MiNT*|*TOS*) echo no;; *) echo yes; esac
CROSS := $(shell $(EVAL_CROSS))

include $(top_srcdir)/GNUmakefile.cmn
include $(top_srcdir)/Makefile.sil

poolfix3_ASFLAGS = -n
poolfix4_ASFLAGS = -n

LIBS =

CPPFLAGS = -I../common -I$(INC)
CFLAGS = $(OPTS) $(WARN)

PROGRAMS = tos14fix.prg tos14fx2.prg tos14fx5.prg poolfix3.prg poolfix4.prg

all:: $(PROGRAMS)

include SRCFILES

tos14fix.prg: $(TOS14FIX_OBJS) ${MAKEFILE}
ifeq ($(USE_CROSS_ALCYON),1)
	$(AM_V_LD)${LINK68} '[PRGFLAGS[1]]' tos14fix.rel=${TOS14FIX_OBJS}
	$(AM_V_at)${RELMOD} tos14fix.rel $@
else
	$(AM_V_LD)${LD} ${LDFLAGS} -nostdlib -nostartfiles -s -o $@ ${TOS14FIX_OBJS}
endif

tos14fx2.prg: $(TOS14FX2_OBJS) ${MAKEFILE}
ifeq ($(USE_CROSS_ALCYON),1)
	$(AM_V_LD)${LINK68} '[PRGFLAGS[1]]' tos14fx2.rel=${TOS14FX2_OBJS}
	$(AM_V_at)${RELMOD} tos14fx2.rel $@
else
	$(AM_V_LD)${LD} ${LDFLAGS} -nostdlib -nostartfiles -s -o $@ ${TOS14FX2_OBJS}
endif

tos14fx5.prg: $(TOS14FX5_OBJS) ${MAKEFILE}
ifeq ($(USE_CROSS_ALCYON),1)
	$(AM_V_LD)${LINK68} '[PRGFLAGS[1]]' tos14fx5.rel=${TOS14FX5_OBJS}
	$(AM_V_at)${RELMOD} tos14fx5.rel $@
else
	$(AM_V_LD)${LD} ${LDFLAGS} -nostdlib -nostartfiles -s -o $@ ${TOS14FX5_OBJS}
endif

poolfix3.prg: $(POOLFIX3_OBJS) ${MAKEFILE}
ifeq ($(USE_CROSS_ALCYON),1)
	$(AM_V_LD)${LINK68} '[PRGFLAGS[1]]' poolfix3.rel=${POOLFIX3_OBJS}
	$(AM_V_at)${RELMOD} poolfix3.rel $@
else
	$(AM_V_LD)${LD} ${LDFLAGS} -nostdlib -nostartfiles -s -o $@ ${POOLFIX3_OBJS}
endif

poolfix4.prg: $(POOLFIX4_OBJS) ${MAKEFILE}
ifeq ($(USE_CROSS_ALCYON),1)
	$(AM_V_LD)${LINK68} '[PRGFLAGS[1]]' poolfix4.rel=${POOLFIX4_OBJS}
	$(AM_V_at)${RELMOD} poolfix4.rel $@
else
	$(AM_V_LD)${LD} ${LDFLAGS} -nostdlib -nostartfiles -s -o $@ ${POOLFIX4_OBJS}
endif

check::
	@:

clean::
	$(RM) *.o *.a *.i *.1 *.2 *.rel $(PROGRAMS)

distclean:: clean
