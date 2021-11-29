top_srcdir=..
subdir=common

include $(top_srcdir)/GNUmakefile.cmn
include $(top_srcdir)/Makefile.sil

all:: $(top_srcdir)/common/sections.mak

include $(top_srcdir)/config.mak

include SRCFILES

check::
	@:

dist::
	$(CP) -a $(SRCS) $(EXTRA_DIST1) $(EXTRA_DIST2) $(top_srcdir)/$(DISTDIR1)/$(subdir)
	$(CP) -a $(EXTRA_DIST2) $(top_srcdir)/$(DISTDIR2)/$(subdir)

dosdir::
	$(CP) -a $(SRCS) $(EXTRA_DIST1) $(DOSDIR)/$(subdir)

clean::

distclean: clean
	$(RM) config.h sections.mak
