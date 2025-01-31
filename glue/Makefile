top_srcdir=..
subdir=glue

include $(top_srcdir)/Makefile.cmn
include $(top_srcdir)/Makefile.sil

IMG = tos$(TOSVERSION)$(COUNTRY).img

all:: $(IMG)

include $(top_srcdir)/config.mak
-include $(top_srcdir)/common/sections.mak
include ../bios/SRCFILES
include ../vdi/SRCFILES
include ../bdos/SRCFILES
include aesdesk.mak
include biosvdi.mak

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

$(IMG): tos1.img tos2.img $(MKROM)
	$(MKROM) pad $(ROMSIZE) tos1.img tos2.img $@

startup.o: startup.S
	$(AM_V_AS)${BIN}cp68${EXEEXT} ${CPPFLAGS} -P $< $*.i
	$(AM_V_at)${BIN}as68${EXEEXT} ${ASFLAGS} ${$*_ASFLAGS} $*.i $@
	$(AM_V_at)${RM} $*.i
	
vdivar.o: ../vdi/vdivar.S
	$(AM_V_AS)${BIN}cp68${EXEEXT} ${CPPFLAGS} -P $< $*.i
	$(AM_V_at)${BIN}as68${EXEEXT} ${ASFLAGS} ${$*_ASFLAGS} $*.i $@
	$(AM_V_at)${RM} $*.i
	
vars.o: ../common/vars.S $(top_srcdir)/common/config.h
	$(AM_V_AS)${BIN}cp68${EXEEXT} ${CPPFLAGS} -P $< $*.i
	$(AM_V_at)${BIN}as68${EXEEXT} ${ASFLAGS} ${$*_ASFLAGS} $*.i $@
	$(AM_V_at)${RM} $*.i

tosvars.o: ../common/tosvars.S $(top_srcdir)/common/config.h
	$(AM_V_AS)${BIN}cp68${EXEEXT} ${CPPFLAGS} -P $< $*.i
	$(AM_V_at)${BIN}as68${EXEEXT} ${ASFLAGS} ${$*_ASFLAGS} $*.i $@
	$(AM_V_at)${RM} $*.i

biosext.o: ../bios/biosext.S $(top_srcdir)/common/config.h
	$(AM_V_AS)${BIN}cp68${EXEEXT} ${CPPFLAGS} -P $< $*.i
	$(AM_V_at)${BIN}as68${EXEEXT} ${ASFLAGS} ${$*_ASFLAGS} $*.i $@
	$(AM_V_at)${RM} $*.i

include gluer.mak

check: $(IMG)
	$(CMP) $(CMPL) -x --ignore-initial=0x0:0x0 --offsets=0x$(rombase):0 $(top_srcdir)/roms/tos$(TOSVERSION)$(COUNTRY).img $(IMG)

clean:
	$(RM) *.o *.a *.i $(IMG) tos.img tosimg.tmp $(PROGRAMS) tosrsc*.c glue.* tosrel.tmp tos.rel $(top_srcdir)/common/config.h

distclean: clean
	$(RM) $(top_srcdir)/common/sections.mak *.img
