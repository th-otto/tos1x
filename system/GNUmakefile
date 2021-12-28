top_srcdir=..
subdir=system

# 
# cross compiling
#
EVAL_CROSS := case `uname -s` in *MiNT*|*TOS*) echo no;; *) echo yes; esac
CROSS := $(shell $(EVAL_CROSS))

include $(top_srcdir)/GNUmakefile.cmn
include $(top_srcdir)/Makefile.sil

LIBS =

CPPFLAGS = -I../common -I$(INC)
CFLAGS = $(OPTS) $(WARN)

PROGRAMS = tos14fix.prg tos14fx2.prg tos14fx5.prg

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
	$(AM_V_LD)${LINK68} '[PRGFLAGS[0]]' tos14fx2.rel=${TOS14FX2_OBJS}
	$(AM_V_at)${RELMOD} tos14fx2.rel $@
else
	$(AM_V_LD)${LD} ${LDFLAGS} -nostdlib -nostartfiles -s -o $@ ${TOS14FX2_OBJS}
endif

tos14fx5.prg: $(TOS14FX5_OBJS) ${MAKEFILE}
ifeq ($(USE_CROSS_ALCYON),1)
	$(AM_V_LD)${LINK68} '[PRGFLAGS[0]]' tos14fx5.rel=${TOS14FX5_OBJS}
	$(AM_V_at)${RELMOD} tos14fx5.rel $@
else
	$(AM_V_LD)${LD} ${LDFLAGS} -nostdlib -nostartfiles -s -o $@ ${TOS14FX5_OBJS}
endif

check::
	@:

dist::
	$(CP) -a $(SRCS) $(EXTRA_DIST1) $(EXTRA_DIST2) $(top_srcdir)/$(DISTDIR1)/$(subdir)
	$(CP) -a $(EXTRA_DIST2) $(top_srcdir)/$(DISTDIR2)/$(subdir)

dosdir::
	$(CP) -a $(SRCS) $(EXTRA_DIST1) $(DOSDIR)/$(subdir)

clean::
	$(RM) *.o *.a *.i *.1 *.2 *.rel $(PROGRAMS)

distclean:: clean
