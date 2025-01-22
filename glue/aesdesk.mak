#
# unlike later TOS versions, aes & desktop sources are mixed,
# and we have to reorder the objects
#include ../aes/SRCFILES
#include ../desk/SRCFILES

AESDESK_OBJS = \
	../aes/gemjstrt.o \
	../aes/geminit.o \
	../aes/apgrlib.o \
	../aes/apgsxif.o \
	../desk/deskapp1.o \
	../desk/deskapp3.o \
	../desk/deskact.o \
	../desk/deskdir.o \
	../desk/deskif.o \
	../desk/deskinf.o \
	../desk/deskinf2.o \
	../desk/deskins.o \
	../desk/deskfpd.o \
	../desk/deskfun.o \
	../desk/deskobj.o \
	../desk/desksupp.o \
	../desk/desksup2.o \
	../desk/rainbow.o \
	../desk/desktop.o \
	../desk/deskwin.o \
	../aes/jdispa.o \
	../aes/jdos.o \
	../aes/jbind.o \
	../aes/gemaints.o \
	../aes/gemasync.o \
	../aes/gemcli.o \
	../aes/gemctrl.o \
	../aes/gemdisp.o \
	../aes/gemflag.o \
	../aes/geminput.o \
	../aes/gempd.o \
	../aes/gemqueue.o \
	../aes/gemwrect.o \
	../aes/gembind.o \
	../aes/gemaplib.o \
	../aes/gemevlib.o \
	../aes/gemfmalt.o \
	../aes/gemfmlib.o \
	../aes/gemfslib.o \
	../aes/gemgrlib.o \
	../aes/gemgsxif.o \
	../aes/gemmnlib.o \
	../aes/gemobed.o \
	../aes/gemoblib.o \
	../aes/gemrslib.o \
	../aes/gemsclib.o \
	../aes/gemshlib.o \
	../aes/gemwmlib.o \
	../aes/gsx2.o \
	../aes/large.o \
	../aes/optimize.o \
	../aes/function.o \
	../aes/gemobjop.o \
	../aes/ratrbp.o \
	../aes/romcart.o \
	../desk/deskshow.o \
	../desk/deskdisk.o \
	../aes/trap14.o \
	../aes/gemrom.o \
	../aes/gemglobe.o \
	../aes/linefhdl.o \
	../aes/gembase.o \
	../aes/ui_mupb.o \
	\
	$(empty)

