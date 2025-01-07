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
include aesdesk.mak

all:: $(IMG)

include SRCFILES

STARTUP = startup.o

OBJS = $(STARTUP) vars.o tosvars.o $(addprefix ../bios/,$(BIOS_OBJS)) $(addprefix ../bdos/,$(BDOS_OBJS)) $(addprefix ../vdi/,$(VDI_OBJS)) $(AESDESK_OBJS)

LINK_OBJS := $(shell echo $(OBJS) | tr ' ' ',')

ROMSIZE_100 = 256k
ROMSIZE_104 = 192k
ROMSIZE_106 = 256k
ROMSIZE_162 = 256k
ROMSIZE = $(ROMSIZE_$(TOSVERSION))

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
LDFLAGS := -nostdlib -nostartfiles -Wl,--script=../common/rom.ld,--entry=_os_entry,-Ttext=0x$(rombase),-Tbss=0 -Wl,-Map,tos.map

tos.img: $(STARTUP) $(LIBS) tosrsc$(COUNTRY).o vars.o tosvars.o ebss.o
	$(AM_V_LD)$(LD) $(LDFLAGS) -o $@ $(STARTUP) vars.o tosvars.o ../bios/bios.a ../vdi/vdi.a ../bdos/bdos.a ../vdi/vdi.a ../bios/bios.a ../aes/aes.a ../desk/desk.a tosrsc$(COUNTRY).o $(CCLIBS)

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
	$(RM) *.o *.a *.i $(IMG) tos.img tosimg.tmp tostmp.map $(PROGRAMS) tosrsc*.c glue.* tosrel.tmp tos.rel $(top_srcdir)/common/config.h

distclean: clean
	$(RM) $(top_srcdir)/common/sections.mak *.img
