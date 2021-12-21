top_srcdir=.

include $(top_srcdir)/Makefile.cmn
include $(top_srcdir)/Makefile.sil

SUBDIRS = common tools bios bdos vdi aes desk glue

all::

include $(top_srcdir)/config.mak

FLAGSTOPASS = COUNTRY=$(COUNTRY) TOSVERSION=$(TOSVERSION)

all clean distclean dist check::
	$(MAKE) -C common $(FLAGSTOPASS) $@
	$(MAKE) -C tools $(FLAGSTOPASS) $@
	$(MAKE) -C bios $(FLAGSTOPASS) $@
	$(MAKE) -C vdi $(FLAGSTOPASS) $@
	$(MAKE) -C bdos $(FLAGSTOPASS) $@
	$(MAKE) -C aes $(FLAGSTOPASS) $@
	$(MAKE) -C desk $(FLAGSTOPASS) $@
	$(MAKE) -C glue $(FLAGSTOPASS) $@

maps:
	$(MAKE) clean
	$(MAKE) SYMBOLS=-s TOSVERSION=104 COUNTRY=de
	cnm -g glue/tos.img > glue/tos104de.map
	$(MAKE) clean
	$(MAKE) SYMBOLS=-s TOSVERSION=104 COUNTRY=us
	cnm -g glue/tos.img > glue/tos104us.map
	$(MAKE) clean
	$(MAKE) SYMBOLS=-s TOSVERSION=106 COUNTRY=de
	cnm -g glue/tos.img > glue/tos106de.map
	$(MAKE) clean
	$(MAKE) SYMBOLS=-s TOSVERSION=106 COUNTRY=us
	cnm -g glue/tos.img > glue/tos106us.map
	$(MAKE) clean
	$(MAKE) SYMBOLS=-s TOSVERSION=162 COUNTRY=de
	cnm -g glue/tos.img > glue/tos162de.map
	$(MAKE) clean
	$(MAKE) SYMBOLS=-s TOSVERSION=162 COUNTRY=us
	cnm -g glue/tos.img > glue/tos162us.map
	$(MAKE) clean
	$(RM) glue/*.img glue/glue.*

help::
	@echo ""
	@echo "targets:"
	@echo "   all       - build default configuration TOSVERSION=$(TOSVERSION) COUNTRY=$(COUNTRY)"
	@echo "   clean     - remove temporary files"
	@echo "   distclean - remove all generated files"
	@echo ""
	@echo "The resulting output file will be glue/tos$(TOSVERSION)$(COUNTRY).img"
	@echo ""
	@echo "See $(top_srcdir)/config.mak for a list of valid configurations"
