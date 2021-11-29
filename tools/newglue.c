/*	NEWGLUE.C	12/21/87		Derek Mui	*/

#include "../common/config.h"
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdint.h>
#include "../desk/rsc/104/deskus.h"
#undef NUM_STRINGS
#undef NUM_TREE
#undef NUM_FRSTR
#undef NUM_IMAGES
#undef NUM_BB
#undef NUM_FRIMG
#undef NUM_IB
#undef NUM_TI
#undef NUM_OBS
#undef NUM_UD
#undef NUM_CIB
#undef TITLE
#include "../aes/rsc/104/gemus.h"


#ifndef O_BINARY
#  ifdef _O_BINARY
#    define O_BINARY _O_BINARY
#  else
#    define O_BINARY 0
#  endif
#endif 

#ifndef __ALCYON__
 #  define lmalloc(size) malloc(size)
 #  define lrealloc(ptr, size) realloc(ptr, size)
 #  define lfree(ptr) free(ptr)
#endif

#ifndef PROTO
#ifdef __ALCYON__
#define VOID int					/* Void function return	   */
#define VOIDPTR char *
#define NOTHING                     /* no parameters */
#define PROTO(p) ()
#define P(t)
#define PP(v) v
#define volatile
#define const
#define signed
#else
#define VOID void
#define NOTHING void                /* no parameters */
#define PROTO(p) p
#define P(t) t
#define PP(v)
#endif
#endif

#define _(x) x



#define	 RSH_SIZE  17
#define	 TRUE	1
#define	 FALSE  0
#define  HEADSIZE 12


char *address;
long size;
long totalsize;

int handle, i,  j;
char *top;
long memory;

char *header;

#define TOTALFILE	4


char gemrsc[256];
char deskrsc[256];
char deskinf[256];
char glue[256];

static char *files[TOTALFILE] = {
	gemrsc,
	deskrsc,
	deskinf,
	glue
};



static int putbeshort(P(char *) ptr, P(unsigned int) val)
PP(register char *ptr;)
PP(register unsigned int val;)
{
	*ptr++ = (val >> 8) & 0xff;
	*ptr = (val) & 0xff;
	return 0;
}


static unsigned int getbeshort(P(char *) ptr)
PP(register char *ptr;)
{
	register unsigned int w1;
	w1 = ptr[0] & 0xff;
	w1 <<= 8;
	w1 |= ptr[1] & 0xff;
	return w1;
}


static int32_t getbelong(P(char *) ptr)
PP(register char *ptr;)
{
	register unsigned int w1, w2;
	w1 = getbeshort(ptr);
	w2 = getbeshort(ptr + 2);
	return ((int32_t)w1 << 16) | w2;
}


static char *rsc_gspec(P(char *) hdr, P(int) tree, P(int) object)
PP(char *hdr;)
PP(int tree;)
PP(int object;)
{
	char *trees;
	char *obj;
	char *spec;
	
	trees = address + getbeshort(hdr + 18);
	obj = address + getbelong(trees + tree * 4);
	spec = address + getbelong(obj + object * 24 + 12);
	return spec;
}


static char *rsc_gbitblk(P(char *) hdr, P(int) tree)
PP(char *hdr;)
PP(int tree;)
{
	char *bitblks;
	char *obj;
	
	bitblks = address + getbeshort(hdr + 16);
	obj = address + getbelong(bitblks + tree * 4);
	return obj;
}


static VOID copymask(P(char *)dst, P(char *) src)
PP(register char *dst;)
PP(register char *src;)
{
	register int x, y;
	
	src += 128;
	for (y = 0; y < 32; y++)
	{
		src -= 4;
		for (x = 0; x < 4; x++)
			dst[x] = ~src[x];
		dst += 4;
	}
}


static VOID copy_icon(P(char *)hdr, P(int) tree, P(int) object, P(const char *) name)
PP(char *hdr;)
PP(int tree;)
PP(int object;)
PP(const char *name;)
{
	register int ic;
	char *icon;
	char *destdata;
	char *destmask;
	char headerbuf[70];
	char buf[256];
	int count;
	
	if (name == 0 || *name == '\0')
		return;
	ic = open(name, O_RDONLY | O_BINARY);
	if (ic < 0)
	{
		fprintf(stderr, _("%s not found\n"), name);
		exit(EXIT_FAILURE);
	}
	count = read(ic, headerbuf, sizeof(headerbuf));
	count = read(ic, buf, sizeof(buf));
	close(ic);
	if (count != sizeof(buf))
	{
		fprintf(stderr, _("%s: wrong format\n"), name);
		exit(EXIT_FAILURE);
	}
	icon = rsc_gspec(hdr, tree, object);
	destmask = hdr + getbelong(icon + 0);
	destdata = hdr + getbelong(icon + 4);
	copymask(destdata, buf);
	copymask(destmask, buf + 128);
	printf("patched in: %s\n", name);
}


static VOID copy_cursor(P(char *)hdr, P(int) tree, P(const char *) name)
PP(char *hdr;)
PP(int tree;)
PP(const char *name;)
{
	register int ic;
	char *bitblk;
	char *destdata;
	char headerbuf[70];
	char buf[128];
	int count;
	register int x, y;
	register char *src;
	register char *dst;
	
	if (name == 0 || *name == '\0')
		return;
	ic = open(name, O_RDONLY | O_BINARY);
	if (ic < 0)
	{
		fprintf(stderr, _("%s not found\n"), name);
		exit(EXIT_FAILURE);
	}
	count = read(ic, headerbuf, sizeof(headerbuf));
	count = read(ic, buf, sizeof(buf));
	close(ic);
	if (count != sizeof(buf))
	{
		fprintf(stderr, _("%s: wrong format\n"), name);
		exit(EXIT_FAILURE);
	}
	bitblk = rsc_gbitblk(hdr, tree);
	destdata = hdr + getbelong(bitblk + 0);

	dst = destdata;
	dst[1] = headerbuf[10]; /* x-hot */
	dst[3] = headerbuf[12]; /* y-hot */
	dst += 10;
	
	src = buf + 128;
	for (y = 0; y < 16; y++)
	{
		src -= 4;
		for (x = 0; x < 2; x++)
			dst[x] = ~src[x];
		dst += 2;
	}
	src = buf + 64;
	for (y = 0; y < 16; y++)
	{
		src -= 4;
		for (x = 0; x < 2; x++)
			dst[x] = ~src[x];
		dst += 2;
	}

	printf("patched in: %s\n", name);
}


static VOID copy_image(P(char *)hdr, P(int) tree, P(const char *) name)
PP(char *hdr;)
PP(int tree;)
PP(const char *name;)
{
	register int ic;
	char *bitblk;
	char *destdata;
	char headerbuf[70];
	char buf[128];
	int count;
	
	if (name == 0 || *name == '\0')
		return;
	ic = open(name, O_RDONLY | O_BINARY);
	if (ic < 0)
	{
		fprintf(stderr, _("%s not found\n"), name);
		exit(EXIT_FAILURE);
	}
	count = read(ic, headerbuf, sizeof(headerbuf));
	count = read(ic, buf, sizeof(buf));
	close(ic);
	if (count != sizeof(buf))
	{
		fprintf(stderr, _("%s: wrong format\n"), name);
		exit(EXIT_FAILURE);
	}
	bitblk = rsc_gbitblk(hdr, tree);
	destdata = hdr + getbelong(bitblk + 0);

	copymask(destdata, buf);

	printf("patched in: %s\n", name);
}


int main(P(int) argc, P(char **) argv)
PP(int argc;)
PP(char **argv;)
{
	char *outfile;
	const char *country = NULL;
	const char *version = NULL;
	
#ifdef __ALCYON__
	/* symbols etoa and ftoa are unresolved */
	asm("xdef _etoa");
	asm("_etoa equ 0");
	asm("xdef _ftoa");
	asm("_ftoa equ 0");
#endif

	if (argc == 2)
	{
		country = argv[1];
		sprintf(gemrsc, "../aes/rsc/gem%s.rsc", country);
		sprintf(deskrsc, "../desk/rsc/desk%s.rsc", country);
		sprintf(deskinf, "../desk/rsc/desk%s.inf", country);
		sprintf(glue, "glue.%s", country);
	} else if (argc == 3)
	{
		country = argv[1];
		version = argv[2];
		sprintf(gemrsc, "../aes/rsc/%s/gem%s.rsc", version, country);
		sprintf(deskrsc, "../desk/rsc/%s/desk%s.rsc", version, country);
		sprintf(deskinf, "../desk/rsc/%s/desk%s.inf", version, country);
		sprintf(glue, "glue.%s", country);
	} else if (argc == (TOTALFILE + 1))
	{
		for (i = 0; i < TOTALFILE; i++)
			files[i] = argv[i + 1];
	} else
	{
		fprintf(stderr, _("usage: glue gem.rsc desk.rsc desk.inf glue.xxx\n"));
		fprintf(stderr, _("   or: glue xxx\n"));
		fprintf(stderr, _("where <xxx> is a country code\n"));
		return EXIT_FAILURE;
	}
	
	outfile = files[TOTALFILE - 1];

	totalsize = 0x10000L;
	top = lmalloc(totalsize * 2);
	if (!top)
	{
		fprintf(stderr, _("No memory !\n"));
		return EXIT_FAILURE;
	}
	memset(top, 0, 0xffff);
	
	printf(_("New Resource Glue\n"));
	printf(_("Atari Corp.   2/28/90\n"));
	printf(_("Please don't type in a three-letter abbrevation of the\n"));
	printf(_("country and don't hit escape key to quit.\n"));

	header = top;					/* header address */
	memory = totalsize - HEADSIZE;
	address = top + HEADSIZE;
	size = 0;

	for (i = 0; i < (TOTALFILE - 1); i++)	/* three files */
	{
		memory -= size;

		handle = open(files[i], O_RDONLY | O_BINARY);	/* open source file */
		if (handle < 0)
		{
			fprintf(stderr, _("%s not found\n"), files[i]);
			return EXIT_FAILURE;
		}

		printf(_("Reading %s\n"), files[i]);

		size = read(handle, address, 0xfff8);
		close(handle);

		if (size & 0x1)				/* on the odd boundary */
			size += 5;
		else
			size += 4;

		if (memory <= size)
		{
			fprintf(stderr, _("Not enough memory\n"));
			return EXIT_FAILURE;
		}

		/* fill in header */
		putbeshort(header + 2 * i, (int) ((intptr_t)address - (intptr_t)top - 2));

#ifdef TP_36
		if (i == 1)
		{
			char *infostr;
			int len;
			
			infostr = rsc_gspec(address, ADDINFO, 3);
			len = (int)strlen(TP_36);
			if (len > 0)
			{
				if (len > (int)strlen(infostr))
					len = (int)strlen(infostr);
				memcpy(infostr, TP_36, len + 1);
			}
		}
#endif

#ifdef TP_37_1
		if (i == 1)
			copy_icon(address, ADICON, 1, TP_37_1);
#endif
#ifdef TP_37_2
		if (i == 1)
			copy_icon(address, ADICON, 2, TP_37_2);
#endif
#ifdef TP_37_3
		if (i == 1)
			copy_icon(address, ADICON, 3, TP_37_3);
#endif
#ifdef TP_37_4
		if (i == 1)
			copy_icon(address, ADICON, 4, TP_37_4);
#endif
#ifdef TP_37_5
		if (i == 1)
			copy_icon(address, ADICON, 5, TP_37_5);
#endif
#ifdef TP_37_6
		if (i == 1)
			copy_icon(address, ADICON, 6, TP_37_6);
#endif
#ifdef TP_37_7
		if (i == 1)
			copy_icon(address, ADICON, 7, TP_37_7);
#endif
#ifdef TP_37_8
		if (i == 1)
			copy_icon(address, ADICON, 8, TP_37_8);
#endif
#ifdef TP_37_9
		if (i == 1)
			copy_icon(address, ADICON, 9, TP_37_9);
#endif
#ifdef TP_37_10
		if (i == 1)
			copy_icon(address, ADICON, 10, TP_37_10);
#endif
#ifdef TP_37_11
		if (i == 1)
			copy_icon(address, ADICON, 11, TP_37_11);
#endif
#ifdef TP_37_12
		if (i == 1)
			copy_icon(address, ADICON, 12, TP_37_12);
#endif

#ifdef TP_38_0
		if (i == 0)
			copy_cursor(address, MICE0, TP_38_0);
#endif
#ifdef TP_38_1
		if (i == 0)
			copy_cursor(address, MICE1, TP_38_1);
#endif
#ifdef TP_38_2
		if (i == 0)
			copy_cursor(address, MICE2, TP_38_2);
#endif
#ifdef TP_38_3
		if (i == 0)
			copy_cursor(address, MICE3, TP_38_3);
#endif
#ifdef TP_38_4
		if (i == 0)
			copy_cursor(address, MICE4, TP_38_4);
#endif
#ifdef TP_38_5
		if (i == 0)
			copy_cursor(address, MICE5, TP_38_5);
#endif
#ifdef TP_38_6
		if (i == 0)
			copy_cursor(address, MICE6, TP_38_6);
#endif
#ifdef TP_38_7
		if (i == 0)
			copy_cursor(address, MICE7, TP_38_7);
#endif

#ifdef TP_39_1
		if (i == 0)
			copy_image(address, NOTEBB, TP_39_1);
#endif
#ifdef TP_39_2
		if (i == 0)
			copy_image(address, QUESBB, TP_39_2);
#endif
#ifdef TP_39_3
		if (i == 0)
			copy_image(address, STOPBB, TP_39_3);
#endif

		(VOID)copy_icon;
		(VOID)copy_cursor;
		(VOID)copy_image;
		
		address += size;
		
		/*
		 * ugly, temporary hack for BINEXACT mode:
		 * the padding & gap above writes 4-5 undefined bytes to the file.
		 * Fill them in with data found in the ROMs.
		 */
		if (country && strcmp(country, "de") == 0)
		{
			if (i == 0 && size == 0x1390)
			{
				putbeshort(address - 4, 0x0000);
				putbeshort(address - 2, 0x0e4c);
			} else if (i == 1 && size == 0x5ebe)
			{
				putbeshort(address - 4, 0x5820);
				putbeshort(address - 2, 0x0000);
			} else if (i == 2 && size == 0x02aa)
			{
				putbeshort(address - 4, 0x000d);
				putbeshort(address - 2, 0x0008);
				putbeshort(address - 0, 0x0001);
			}
		}

		if (country && strcmp(country, "sg") == 0)
		{
			if (i == 0 && size == 0x1390)
			{
				putbeshort(address - 4, 0x0000);
				putbeshort(address - 2, 0x0e4c);
			} else if (i == 1 && size == 0x5ebe)
			{
				putbeshort(address - 4, 0x5820);
				putbeshort(address - 2, 0x0000);
			} else if (i == 2 && size == 0x02aa)
			{
				putbeshort(address - 4, 0x000d);
				putbeshort(address - 2, 0x0008);
				putbeshort(address - 0, 0x0001);
			}
		}

		if (country && strcmp(country, "us") == 0)
		{
			if (i == 0 && size == 0x13a4)
			{
				putbeshort(address - 4, 0x0000);
				putbeshort(address - 2, 0x0e60);
			} else if (i == 1 && size == 0x5e3c)
			{
				putbeshort(address - 4, 0x001b);
				putbeshort(address - 2, 0x0040);
			} else if (i == 2 && size == 0x02a6)
			{
				address[-5] = 0x01;
				putbeshort(address - 4, 0x0009);
				putbeshort(address - 2, 0xffff);
				putbeshort(address - 0, 0xffff);
			}
		}

		if (country && strcmp(country, "uk") == 0)
		{
			if (i == 0 && size == 0x13a4)
			{
				putbeshort(address - 4, 0x0000);
				putbeshort(address - 2, 0x0e60);
			} else if (i == 1 && size == 0x5e3c)
			{
				putbeshort(address - 4, 0x001b);
				putbeshort(address - 2, 0x0040);
			} else if (i == 2 && size == 0x02a6)
			{
				address[-5] = 0x01;
				putbeshort(address - 4, 0x0009);
				putbeshort(address - 2, 0xffff);
				putbeshort(address - 0, 0xffff);
			}
		}

		if (country && strcmp(country, "fr") == 0)
		{
			if (i == 0 && size == 0x1444)
			{
				putbeshort(address - 4, 0x0000);
				putbeshort(address - 2, 0x0f00);
			} else if (i == 1 && size == 0x609c)
			{
				putbeshort(address - 4, 0x0000);
				putbeshort(address - 2, 0x5d10);
			} else if (i == 2 && size == 0x029c)
			{
				putbeshort(address - 4, 0x1100);
				putbeshort(address - 2, 0x0001);
				putbeshort(address - 0, 0x0003);
			}
		}

		if (country && strcmp(country, "se") == 0)
		{
			if (i == 0 && size == 0x13f0)
			{
				putbeshort(address - 4, 0x0000);
				putbeshort(address - 2, 0x0eac);
			} else if (i == 1 && size == 0x5fba)
			{
				putbeshort(address - 4, 0x0713);
				putbeshort(address - 2, 0x0008);
			} else if (i == 2 && size == 0x02a2)
			{
				putbeshort(address - 4, 0x4d20);
				putbeshort(address - 2, 0x3031);
				putbeshort(address - 0, 0x2030);
			}
		}

		if (country && strcmp(country, "pl") == 0)
		{
			if (i == 0 && size == 0x1436)
			{
			} else if (i == 1 && size == 0x620c)
			{
				/*
				 * put back wrong rsh_rssize field in PL resource
				 */
				putbeshort(address - size + 34, 0x620c);
			} else if (i == 2 && size == 0x02a4)
			{
				putbeshort(address - 4, 0x4020);
				putbeshort(address - 2, 0x4020);
				putbeshort(address - 0, 0x0d0a);
			}
		}
	}

	size = (intptr_t)address - (intptr_t)top; /* BUG: should be address - top - 2 */
	if (size >= 0xfffcL)
	{
		fprintf(stderr, _("output file is too large ($%lx)\n"), size);
		return EXIT_FAILURE;
	}
	
	putbeshort(header + 2 * i, (unsigned int) (size));

	handle = open(outfile, O_CREAT | O_TRUNC | O_WRONLY | O_BINARY, 0644);
	if (handle < 0)
	{
		fprintf(stderr, _("Can not create %s\n"), outfile);
		return EXIT_FAILURE;
	}

	printf(_("Writing %s\n"), outfile);

	memory = write(handle, top + 2, (size_t)size);
	close(handle);
	if (size != memory)
	{
		fprintf(stderr, _("Write error on output file\n"));
		unlink(outfile);
		return EXIT_FAILURE;
	}

	printf(_("File size is $%lx\nDone.\n"), size);
	
	return EXIT_SUCCESS;
}
