top_srcdir=../..
subdir=timefix

# 
# cross compiling
#
EVAL_CROSS := case `uname -s` in *MiNT*|*TOS*) echo no;; *) echo yes; esac
CROSS := $(shell $(EVAL_CROSS))

include $(top_srcdir)/GNUmakefile.cmn
include $(top_srcdir)/Makefile.sil

LIBS =

CPPFLAGS = -I$(top_srcdir)/common -I$(INC)
CFLAGS = $(OPTS) $(WARN)

PROGRAMS = timefix.prg tfixunin.prg

timefix_ASFLAGS = -n
tfixunin_ASFLAGS = -n

all:: $(PROGRAMS)

timefix.prg: timefix.o ${MAKEFILE}
ifeq ($(USE_CROSS_ALCYON),1)
	$(AM_V_LD)${LINK68} '[PRGFLAGS[0]]' timefix.rel=timefix.o
	$(AM_V_at)${RELMOD} timefix.rel $@
else
	$(AM_V_LD)${LD} ${LDFLAGS} -nostdlib -nostartfiles -s -o $@ timefix.o
endif

tfixunin.prg: tfixunin.o ${MAKEFILE}
ifeq ($(USE_CROSS_ALCYON),1)
	$(AM_V_LD)${LINK68} '[PRGFLAGS[0]]' tfixunin.rel=tfixunin.o
	$(AM_V_at)${RELMOD} tfixunin.rel $@
else
	$(AM_V_LD)${LD} ${LDFLAGS} -nostdlib -nostartfiles -s -o $@ tfixunin.o
endif

check::
	@:

clean::
	$(RM) *.o *.a *.i *.1 *.2 *.rel $(PROGRAMS)

distclean:: clean
