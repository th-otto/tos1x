#
# TOS version
# This must be the hexadecimal (bcd-encoded) number, but without any prefix.
# Currently only 1.04 and 1.06 are supported.
# Note that there is a different archive to build the 2.x/3.x versions.
#
TOSVERSION=104

#
# Country definition
# valid countries are:
# us - USA
# de - Germany
# fr - France
# uk - United Kingdom
# es - Spain
# it - Italy
# se - Sweden
# sf - Switzerland (French)
# sg - Switzerland (German)
#
# sf and sg only affect the country code in ROM header
# uk uses uk keyboard, and us resources
# sg uses de keyboard and resources
# sf uses fr keyboard and resources
#
COUNTRY=de

#
# Set this 1 to build an exact binary image of an official
# ROM version. The Alcyon compiler must be used for that.
#
BINEXACT=1

#
# Set this to 1 to build a RAM version relocated to 0x380000.
#
RAMVERSION=0

-include $(top_srcdir)/localcnf.mak

#
# Rules to recreate some files from definitions above
#
$(top_srcdir)/common/config.h: $(top_srcdir)/config.mak ${MAKEFILE}
	$(AM_V_GEN)echo '/* automatically generated - DO NOT EDIT */' > $@
	$(AM_V_at)echo '#ifndef __CONFIG_H__' >> $@
	$(AM_V_at)echo '#define __CONFIG_H__ 1' >> $@
	$(AM_V_at)echo '#define TOSVERSION 0x$(TOSVERSION)' >> $@
	$(AM_V_at)echo '#define ATOSVERSION $$$(TOSVERSION)' >> $@
	$(AM_V_at)echo '#define OS_COUNTRY CTRY_$(COUNTRY)' >> $@
	$(AM_V_at)echo '#ifdef __GNUC__' >> $@
	$(AM_V_at)echo '# define BINEXACT 0' >> $@
	$(AM_V_at)echo '#else' >> $@
	$(AM_V_at)echo '# define BINEXACT $(BINEXACT)' >> $@
	$(AM_V_at)echo '#endif' >> $@
	$(AM_V_at)echo '#define RAMVERSION $(RAMVERSION)' >> $@
	$(AM_V_at)echo '#include "ctrycode.h"' >> $@
	$(AM_V_at)echo '#if !BINEXACT' >> $@
	$(AM_V_at)echo '#include "localcnf.h"' >> $@
	$(AM_V_at)echo '#endif' >> $@
	$(AM_V_at)echo '#include "patchdef.h"' >> $@
	$(AM_V_at)echo '#include "nopatch.h"' >> $@
	$(AM_V_at)echo '#endif' >> $@

$(top_srcdir)/common/sections.mak: $(top_srcdir)/common/sections.inc $(top_srcdir)/common/config.h
	$(AM_V_GEN)$(CPP) -D__MAKEFILE__ $(top_srcdir)${BS}common${BS}sections.inc $(CPPOUT) sections.i
	$(AM_V_at)$(SED) -e 's/$(QBS)$$//g' -e '//d' sections.i > sections.1
	$(AM_V_at)$(BC) -q < sections.1 > $@
	$(AM_V_at)$(RM) sections.i sections.1
	$(AM_V_at)-touch $(top_srcdir)/common/localcnf.h

# check that TOSVERSION and COUNTRY are valid
all:: tosversion_$(TOSVERSION) country_$(COUNTRY)
	@:

country_us country_de country_fr country_uk country_es country_it country_se country_sf country_sg country_cz country_nl:
tosversion_104:
tosversion_106:

VARS_162_OBJS=vars.o
VARS_106_OBJS=vars.o
VARS_104_OBJS=vars.o

VARS_OBJS=$(VARS_$(TOSVERSION)_OBJS)
