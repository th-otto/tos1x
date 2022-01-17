top_srcdir=../..
subdir=tospatch/tools

# 
# cross compiling
#
EVAL_CROSS := case `uname -s` in *MiNT*|*TOS*) echo no;; *) echo yes; esac
CROSS := $(shell $(EVAL_CROSS))

include $(top_srcdir)/GNUmakefile.cmn
include $(top_srcdir)/Makefile.sil

CPPFLAGS = -I../common -I$(INC)
CFLAGS = $(OPTS) $(WARN)

BIN2C = $(top_srcdir)/tools/bin2c$(BUILD_EXEEXT)

PROGRAMS = loadtos.prg resettos.prg lt_conf.prg

all:: $(PROGRAMS)

#ASYMBOLS := '[symbols,locals]'

loadtos.prg: loadtos.o ${MAKEFILE}
ifeq ($(USE_CROSS_ALCYON),1)
	$(AM_V_LD)${LINK68} $(ASYMBOLS) loadtos.rel=loadtos.o
	$(AM_V_at)${RELMOD} loadtos.rel $@
	@$(RM) loadtos.rel
else
	$(AM_V_LD)${LD} ${LDFLAGS} -nostdlib -nostartfiles -s -o $@ loadtos.o
endif

loadtos.o: loadtos.S GNUmakefile

resettos.prg: resettos.o ${MAKEFILE}
ifeq ($(USE_CROSS_ALCYON),1)
	$(AM_V_LD)${LINK68} $(ASYMBOLS) '[PRGFLAGS[1]]' resettos.rel=resettos.o
	$(AM_V_at)${RELMOD} resettos.rel $@
	@$(RM) resettos.rel
else
	$(AM_V_LD)${LD} ${LDFLAGS} -nostdlib -nostartfiles -Wl,--mprg-flags,1 -s -o $@ resettos.o
endif

resettos.o: resettos.S GNUmakefile

lt_conf.prg: lt_conf.o ${MAKEFILE}
ifeq ($(USE_CROSS_ALCYON),1)
	$(AM_V_LD)${LINK68} $(ASYMBOLS) '[PRGFLAGS[1]]' lt_conf.rel=lt_conf.o
	$(AM_V_at)${RELMOD} lt_conf.rel $@
	@$(RM) lt_conf.rel
else
	$(AM_V_LD)${LD} ${LDFLAGS} -nostdlib -nostartfiles -Wl,--mprg-flags,1 -s -o $@ lt_conf.o
endif

lt_conf.o: lt_conf.S autoconf.i GNUmakefile

autoconf.i: autoconf.rsc $(BIN2C)
	$(BIN2C) -a $< $@

check::
	@:

clean::
	$(RM) *.o *.a *.i *.1 *.2 *.rel

distclean: clean
	@:
