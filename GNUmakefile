top_srcdir=.

include GNUmakefile.cmn
include Makefile.sil

SUBDIRS = common tools bios vdi bdos aes desk system glue

EXTRA_DIST1 = \
	Makefile \
	Makefile.cmn \
	Makefile.sil \
	config.mak \
	$(empty)

EXTRA_DIST2 = \
	GNUmakefile \
	GNUmakefile.cmn \
	$(empty)

all::
	@:

include $(top_srcdir)/config.mak

FLAGSTOPASS = COUNTRY=$(COUNTRY) TOSVERSION=$(TOSVERSION)

dist::
	rm -rf $(DISTDIR1) $(DISTDIR2)
	for i in $(SUBDIRS) lib; do $(MKDIR_P) $(DISTDIR1)/$$i; done
	for i in $(SUBDIRS) $(EXTRA_SUBDIRS) listings; do $(MKDIR_P) $(DISTDIR2)/$$i; done

all dist::
	for i in $(SUBDIRS); do $(MAKE) -C $$i $(FLAGSTOPASS) $@ || exit 1; done

clean distclean::
	for i in $(SUBDIRS); do $(MAKE) -C $$i $(FLAGSTOPASS) $@; done

dist::
	for i in $(EXTRA_SUBDIRS); do $(MAKE) -C $$i $@; done

check::
	for i in $(SUBDIRS); do $(MAKE) --no-print-directory -C $$i $(FLAGSTOPASS) all; done
	for i in $(SUBDIRS); do $(MAKE) --no-print-directory -C $$i $(FLAGSTOPASS) $@; done

checkall:
	for version in 100; do \
		for lang in us de fr uk dk fi sg; do \
			$(MAKE) clean; \
			$(MAKE) TOSVERSION=$${version} COUNTRY=$${lang} || exit 1; \
			$(MAKE) -C glue TOSVERSION=$${version} COUNTRY=$${lang} check || exit 1; \
		done; \
	done
	$(MAKE) clean

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
