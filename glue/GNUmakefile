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
include biosvdi.mak

all:: $(IMG)

include SRCFILES

STARTUP = startup.o

OBJS = $(STARTUP) vars.o tosvars.o ../bios/bios.a ../bdos/bdos.a ../vdi/vdi.a ../aes/aes.a ../desk/desk.a


BIOSLINK_OBJS := $(BIOSVDI_OBJS),tosrsc$(COUNTRY).o
AESLINK_OBJS := $(AESDESK_OBJS)
LINK_OBJS = $(BIOSLINK_OBJS),$(AESLINK_OBJS)

ROMSIZE_100 = 192k
ROMSIZE_104 = 192k
ROMSIZE_106 = 256k
ROMSIZE_162 = 256k
ROMSIZE = $(ROMSIZE_$(TOSVERSION))

ifeq ($(USE_CROSS_ALCYON),1)
tos1.img: $(STARTUP) $(OBJS) tosrsc$(COUNTRY).o biosext.o biosvdi.mak aesdesk.mak
	$(AM_V_LD)$(LINK68) '[abs,symbols,locals,text[$(rombase)],bss[0]]' $@=vars.o,tosvars.o,$(BIOSLINK_OBJS),biosext.o
	$(AM_V_at)$(MAKE) tos1.mak

-include tos1.mak

tos2.img: tos1.img tos1.mak
# tos1.mak might have just been generated, make sure it is reread
	$(AM_V_at)$(MAKE) gen_tos2_img

.PHONY: gen_tos2_img
gen_tos2_img: tos1.mak
	$(AM_V_LD)$(LINK68) '[abs,symbols,locals,text[$(tos2_tbase)],bss[0]]' tos2.img=vars.o,tosvars.o,$(AESLINK_OBJS)

.PHONY: tos1.mak
tos1.mak:
	$(AM_V_at)$(SIZE68) tos1.img > tos1.i
	$(AM_V_at)sed -e 's/a/A/g' -e 's/b/B/g' -e 's/c/C/g' -e 's/d/D/g' -e 's/e/E/g' -e 's/f/F/g' tos1.i > tos1.1
	$(AM_V_at)echo "ibase=16" > tos1.2
	$(AM_V_at)echo "obase=10" >> tos1.2
	$(AM_V_at)echo "rombase=$(rombase)" >> tos1.2
	$(AM_V_at)sed -n 's/^.*tExt lEngth *- *[0-9]* *\([0-9a-fA-F]*\).*$$/tos1_tlen=\1/p' tos1.1 >> tos1.2
	$(AM_V_at)sed -n 's/^.*DAtA lEngth *- *[0-9]* *\([0-9a-fA-F]*\).*$$/tos1_dlen=\1/p' tos1.1 >> tos1.2
	$(AM_V_at)echo 'print "tos2_tbase=", rombase + tos1_tlen + tos1_dlen, "\n"' >> tos1.2
	$(AM_V_GEN)$(BC) -q < tos1.2 > $@
	$(AM_V_at)$(RM) tos1.i tos1.1 tos1.2

tos.rel: $(STARTUP) $(OBJS) tosrsc$(COUNTRY).o ../vdi/vdivar.o ../aes/gembase.o sbss.o ebss.o
	$(AM_V_at)$(CP) ../vdi/cbssdefs.o .
	$(AM_V_at)$(CP) ../aes/gembase.o .
	$(AM_V_LD)$(LINK68) '[abs,relocs=td,text[$(rombase)],bss[0]]' tosrel.tmp=vars.o,tosvars.o,$(LINK_OBJS) > $@
	$(AM_V_at)$(RM) tosrel.tmp

$(IMG): tos1.img tos2.img $(MKROM)
	$(MKROM) pad $(ROMSIZE) tos1.img tos2.img $@

else

CCLIBS := `$(CC) -print-file-name=libgcc.a`
LDFLAGS := -nostdlib -nostartfiles -Wl,--script=../common/rom.ld,--entry=_os_entry,-Ttext=0x$(rombase),-Tbss=0 -Wl,-Map,tos.map

tos.img: $(STARTUP) $(LIBS) tosrsc$(COUNTRY).o vars.o tosvars.o ebss.o
	$(AM_V_LD)$(LD) $(LDFLAGS) -o $@ $(STARTUP) vars.o tosvars.o ../bios/bios.a ../vdi/vdi.a ../bdos/bdos.a ../vdi/vdi.a ../bios/bios.a ../aes/aes.a ../desk/desk.a tosrsc$(COUNTRY).o $(CCLIBS)

$(IMG): tos.img $(MKROM)
	$(MKROM) pad $(ROMSIZE) tos.img $@

endif

$(MKROM)::
	$(MAKE) -C $(top_srcdir)/tools mkrom

vdivar.o: ../vdi/vdivar.S
	$(AM_V_AS)$(AS) $(ASFLAGS) $(CPPFLAGS) -c -o $@ $<
	
vars.o: ../common/vars.S $(top_srcdir)/common/config.h
	$(AM_V_AS)$(AS) $(ASFLAGS) $(CPPFLAGS) -c -o $@ $<

tosvars.o: ../common/tosvars.S $(top_srcdir)/common/config.h
	$(AM_V_AS)$(AS) $(ASFLAGS) $(CPPFLAGS) -c -o $@ $<

biosext.o: ../bios/biosext.S $(top_srcdir)/common/config.h
	$(AM_V_AS)$(AS) $(ASFLAGS) $(CPPFLAGS) -c -o $@ $<

include gluer.mak

check:: $(IMG)
	$(CMP) $(CMPL) -x --ignore-initial=0x0:0x0 --offsets=0x$(rombase):0 $(top_srcdir)/roms/tos$(TOSVERSION)$(COUNTRY).img $(IMG)

clean:
	$(RM) *.o *.a *.i $(IMG) tos.img tos1.img tos2.img tosimg.tmp tostmp.map tos1.mak $(PROGRAMS) tosrsc*.c tosrsc.h glue.* tosrel.tmp tos.rel $(top_srcdir)/common/config.h

distclean: clean
	$(RM) $(top_srcdir)/common/sections.mak *.img
