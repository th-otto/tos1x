tosrsc$(COUNTRY).o: tosrsc$(COUNTRY).c $(top_srcdir)/common/config.h

tosrsc$(COUNTRY).c: $(MKBININC) glue.$(COUNTRY)
	$(AM_V_GEN)$(MKBININC) glue.$(COUNTRY) tosrsc $@

GEM_RSC = ../aes/rsc/$(TOSVERSION)/gem$(COUNTRY).rsc
DESK_RSC = ../desk/rsc/$(TOSVERSION)/desk$(COUNTRY).rsc
DESK_INF = ../desk/rsc/$(TOSVERSION)/desk$(COUNTRY).inf

-include localrsc.mak

glue.$(COUNTRY): $(MKGLUE) $(GEM_RSC) $(DESK_RSC) $(DESK_INF)
	$(AM_V_GEN)$(MKGLUE) $(COUNTRY) $(TOSVERSION)

rscend.o: rscend.S
