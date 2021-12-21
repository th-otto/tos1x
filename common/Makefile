top_srcdir=..
subdir=common

include $(top_srcdir)/Makefile.cmn
include $(top_srcdir)/Makefile.sil

all:: $(top_srcdir)/common/sections.mak

include $(top_srcdir)/config.mak

include SRCFILES

check::

dist::
	$(CP) -a $(SRCS) $(EXTRA_DIST1) $(top_srcdir)/$(DISTDIR1)/$(subdir)
	$(CP) -a $(EXTRA_DIST2) $(top_srcdir)/$(DISTDIR2)/$(subdir)

clean::

distclean: clean
	$(RM) config.h sections.mak
