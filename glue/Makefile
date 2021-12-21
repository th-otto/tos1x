top_srcdir=..
subdir=glue

include $(top_srcdir)/Makefile.cmn
include $(top_srcdir)/Makefile.sil

IMG = tos$(TOSVERSION)$(COUNTRY).img

all:: $(IMG)

include $(top_srcdir)/config.mak
-include $(top_srcdir)/common/sections.mak
include aesdesk.mak

include SRCFILES

STARTUP = startup.o

LIBS = ../bios/bios.a ../bdos/bdos.a ../vdi/vdi.a ../aes/aes.a ../desk/desk.a
LIBSNDX = ../bios/bios.ndx ../bdos/bdos.ndx ../vdi/vdi.ndx ../aes/aes.ndx ../desk/desk.ndx

ROMSIZE_104 = 192k
ROMSIZE_106 = 256k
ROMSIZE_162 = 256k
ROMSIZE = $(ROMSIZE_$(TOSVERSION))

$(IMG): tos.img $(MKROM)
	$(MKROM) pad $(ROMSIZE) $< $@

tos.img: $(STARTUP) $(LIBS) tosrsc$(COUNTRY).o vars.o
	$(LD) -o $@ $(SYMBOLS) -a $(rombase) x 0 $(STARTUP) -x ..$(BS)bios$(BS)bios.a -x ..$(BS)bdos$(BS)bdos.a -x ..$(BS)vdi$(BS)vdi.a $(AESDESK_OBJS) tosrsc$(COUNTRY).o vars.o

../bios/bios.ndx: ../bios/bios.a
	$(RANLIB) $<

../vdi/vdi.ndx: ../vdi/vdi.a
	$(RANLIB) $<

../bdos/bdos.ndx: ../bdos/bdos.a
	$(RANLIB) $<

../aes/aes.ndx: ../aes/aes.a
	$(RANLIB) $<

../desk/desk.ndx: ../desk/desk.a
	$(RANLIB) $<

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

include gluer.mak

check: $(IMG)
	$(CMP) $(CMPL) -x --ignore-initial=0x0:0x0 --offsets=0x$(rombase):0 $(top_srcdir)/roms/tos$(TOSVERSION)$(COUNTRY).img $(IMG)

clean:
	$(RM) *.o *.a *.i $(IMG) tos.img tosimg.tmp $(PROGRAMS) tosrsc*.c glue.* tosrel.tmp tos.rel $(top_srcdir)/common/config.h

distclean: clean
	$(RM) $(top_srcdir)/common/sections.mak *.img
