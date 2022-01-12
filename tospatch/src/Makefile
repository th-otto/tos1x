CFLAGS = -O2 -fomit-frame-pointer
CFLAGS += -Wall -Wstrict-prototypes -Wmissing-prototypes -Wextra -Werror
LDFLAGS =

OBJS = \
	error.o \
	log.o \
	msgs.o \
	parse.o \
	tospatch.o \
	var.o \
	expr.o \
	reloc.o \
	crc.o \
	$(empty)

all: tospatch


tospatch: $(OBJS)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJS)

$(OBJS): tospatch.h

clean::
	$(RM) *.o tospatch
