top_srcdir=..
subdir=glue

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

IMG = tos$(TOSVERSION)$(COUNTRY).img

all::

include $(top_srcdir)/config.mak
-include $(top_srcdir)/common/sections.mak
include ../bios/SRCFILES
include ../vdi/SRCFILES
include ../bdos/SRCFILES

#
# unlike later TOS versions, aes & desktop sources are mixed,
# and we have to reorder the objects
#include ../aes/SRCFILES
#include ../desk/SRCFILES

AESDESK_OBJS = \
	../aes/gemjstrt.o \
	../aes/geminit.o \
	../aes/apgrlib.o \
	../aes/apgsxif.o \
	../desk/deskinf.o \
	../desk/deskif.o \
	../aes/gemaints.o \
	../aes/gemaplib.o \
	../aes/gemasync.o \
	../aes/gembase.o \
	../aes/gembind.o \
	../aes/gemcli.o \
	../aes/gemctrl.o \
	../aes/gemdisp.o \
	../aes/gemevlib.o \
	../aes/gemflag.o \
	../aes/gemfmalt.o \
	../aes/gemfmlib.o \
	../aes/gemfslib.o \
	../aes/gemglobe.o \
	../aes/linefhdl.o \
	../aes/geminput.o \
	../aes/gemmnlib.o \
	../aes/gemobed.o \
	../aes/gemobjop.o \
	../aes/gempd.o \
	../aes/gemqueue.o \
	../aes/gemrom.o \
	../aes/gemrslib.o \
	../aes/gemsclib.o \
	../aes/gemshlib.o \
	../aes/gemwmlib.o \
	../aes/gemwrect.o \
	../aes/romcart.o \
	../aes/gemoblib.o \
	../aes/gemgrlib.o \
	../aes/gemgsxif.o \
	../aes/gsx2.o \
	../aes/jbind.o \
	../aes/jdispa.o \
	../aes/jdos.o \
	../aes/large.o \
	../aes/function.o \
	../aes/optimize.o \
	../aes/ratrbp.o \
	../aes/trap14.o \
	../desk/deskmisc.o \
	../desk/deskwin.o \
	../desk/deskstor.o \
	../desk/deskact.o \
	../desk/deskapp.o \
	../desk/deskbind.o \
	../desk/deskbutt.o \
	../desk/deskdir.o \
	../desk/deskdisk.o \
	../desk/deskfile.o \
	../desk/deskins.o \
	../desk/deskmem.o \
	../desk/deskmenu.o \
	../desk/deskopen.o \
	../desk/deskpref.o \
	../desk/desksear.o \
	../desk/desksele.o \
	../desk/deskshel.o \
	../desk/deskshow.o \
	../desk/deskrsc.o \
	../desk/desktop.o \
	../desk/deskupda.o \
	../desk/osbind.o \
	$(empty)

all:: $(IMG)

include SRCFILES

STARTUP = startup.o

OBJS = $(STARTUP) vars.o tosvars.o $(addprefix ../bios/,$(BIOS_OBJS)) $(addprefix ../vdi/,$(VDI_OBJS)) $(addprefix ../bdos/,$(BDOS_OBJS)) $(AESDESK_OBJS)

LINK_OBJS := $(shell echo $(OBJS) | tr ' ' ',')

ROMSIZE = 192k

ifeq ($(USE_CROSS_ALCYON),1)
tos.img: $(STARTUP) $(OBJS) tosrsc$(COUNTRY).o
	$(AM_V_LD)$(LINK68) '[abs,symbols,locals,text[$(rombase)],bss[0]]' $@=$(LINK_OBJS),tosrsc$(COUNTRY).o

tos.rel: $(STARTUP) $(OBJS) tosrsc$(COUNTRY).o ../vdi/vdivar.o ../aes/gembase.o sbss.o ebss.o
	$(AM_V_at)$(CP) ../vdi/cbssdefs.o .
	$(AM_V_at)$(CP) ../aes/gembase.o .
	$(AM_V_LD)$(LINK68) '[abs,relocs=td,text[$(rombase)],bss[0]]' tosrel.tmp=$(LINK_OBJS),tosrsc$(COUNTRY).o > $@
	$(AM_V_at)$(RM) tosrel.tmp

else

CCLIBS := `$(CC) -print-file-name=libgcc.a`
LDFLAGS := -nostdlib -nostartfiles -Wl,--script=../common/rom.ld,--entry=_os_entry,-Ttext=0x$(rombase),-Tbss=0

tos.img: $(STARTUP) $(LIBS) tosrsc$(COUNTRY).o vars.o tosvars.o ebss.o
	$(AM_V_LD)$(LD) $(LDFLAGS) -o $@ $(STARTUP) vars.o tosvars.o ../bios/bios.a ../vdi/vdi.a ../bdos/bdos.a ../vdi/vdi.a ../aes/aes.a ../desk/desk.a tosrsc$(COUNTRY).o $(CCLIBS)

endif

$(IMG): tos.img $(MKROM)
	$(MKROM) pad $(ROMSIZE) $< $@

vdivar.o: ../vdi/vdivar.S
	$(AM_V_AS)$(AS) $(ASFLAGS) $(CPPFLAGS) -c -o $@ $<
	
vars.o: ../common/vars.S $(top_srcdir)/common/config.h
	$(AM_V_AS)$(AS) $(ASFLAGS) $(CPPFLAGS) -c -o $@ $<

tosvars.o: ../common/tosvars.S $(top_srcdir)/common/config.h
	$(AM_V_AS)$(AS) $(ASFLAGS) $(CPPFLAGS) -c -o $@ $<

include gluer.mak

check:: $(IMG)
	$(CMP) $(CMPL) -x --ignore-initial=0x0:0x0 --offsets=0x$(rombase):0 $(top_srcdir)/roms/tos$(TOSVERSION)$(COUNTRY).img $(IMG)

clean:
	$(RM) *.o *.a *.i $(IMG) tos.img tosimg.tmp cartridg.tmp cartridg.img tostmp.map $(PROGRAMS) tosrsc*.c glue.* tosrel.tmp tos.rel $(top_srcdir)/common/config.h

distclean: clean
	$(RM) $(top_srcdir)/common/sections.mak *.img