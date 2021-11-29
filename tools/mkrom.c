#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdint.h>

#ifndef O_BINARY
#  ifdef _O_BINARY
#	 define O_BINARY _O_BINARY
#  else
#	 define O_BINARY 0
#  endif
#endif 

#ifndef __ALCYON__
 #	define lmalloc(size) malloc(size)
 #	define lrealloc(ptr, size) realloc(ptr, size)
 #	define lfree(ptr) free(ptr)
#endif

#ifndef PROTO
#ifdef __ALCYON__
#define VOID int					/* Void function return    */
#define VOIDPTR char *
#define NOTHING 					/* no parameters */
#define PROTO(p) ()
#define P(t)
#define PP(v) v
#define volatile
#define const
#define signed
#else
#define NOTHING void				/* no parameters */
#define VOID void
#define PROTO(p) p
#define P(t) t
#define PP(v)
#endif
#endif

#define _(x) x

#define  TRUE	1
#define  FALSE	0


#define SIZE_ERROR ((size_t)-1)
#undef MIN
#define MIN(a, b) ((a)<=(b) ? (a) : (b))
#define BUFFER_SIZE (16*1024)

/* Command-line commands */
#define CMD_NONE 0
#define CMD_PAD 1
#define CMD_STC 2
#define CMD_AMIGA 3
#define CMD_KICKDISK 4

struct hdr2
{
	unsigned short ch_magic;			/* c.out magic number = 601B hex */
	long ch_tsize;						/* # bytes in program text segment */
	long ch_dsize;						/* # bytes in program data segment */
	long ch_bsize;						/* # bytes in program bss  segment */
	long ch_ssize;						/* # bytes in symbol table */
	long ch_stksize;					/* initial stack size */
	long ch_entry;						/* entry point--address of text segment */
	unsigned short ch_rlbflg;			/* relocation bits suppressed flag, must be signed */
	long ch_dstart;						/* address of data segment */
	long ch_bstart;						/* address of bss segment */
};
#define HDSIZ2		36		/* sizeof(hdr2) on disk */

#define MAGIC		(unsigned short) 0x601a	/*  bra .+26 instruction */
#define MAGIC1		(unsigned short) 0x601b	/* data & bss base defined */
#define MAGIC2		(unsigned short) 0x602e	/*  bra .+46 instruction */


static char const program_name[] = "mkrom";



/* Read a big endian long */
static uint32_t rdbelong(P(const uint8_t *) p)
PP(const uint8_t *p;)
{
	return ((uint32_t)(p[0] & 0xff)) << 24
		 | ((uint32_t)(p[1] & 0xff)) << 16
		 | ((uint32_t)(p[2] & 0xff)) << 8
		 |	(uint32_t)(p[3] & 0xff);
}

/* Read a big endian short */
static uint16_t rdbeshort(P(const uint8_t *) p)
PP(const uint8_t *p;)
{
	return ((uint16_t)(p[0] & 0xff)) << 8
		 |	(uint16_t)(p[1] & 0xff);
}


#if 0
/* Write a big endian long */
static void wrbelong(P(uint8_t *) p, P(uint32_t) value)
PP(uint8_t *p;)
PP(uint32_t value;)
{
	p[0] = (value >> 24);
	p[1] = (value >> 16);
	p[2] = (value >> 8);
	p[3] = value;
}

/* Write a big endian short */
static void wrbeshort(P(uint8_t *) p, P(uint16_t) value)
PP(uint8_t *p;)
PP(uint16_t value;)
{
	p[0] = (value >> 8);
	p[1] = value;
}
#endif


/* Get an integer value from an integer string with a k, m, or g suffix */
static long get_size_value(P(const char *) strsize)
PP(const char *strsize;)
{
	long val;
	char *end;

	val = strtol(strsize, &end, 0);
	if (*end == '\0') /* No suffix */
		; /* val is already a number of bytes */
	else if (*end == 'k' || *end == 'K')
		val *= 1024;
	else if (*end == 'm' || *end == 'M')
		val *= 1024L * 1024L;
	else if (*end == 'g' || *end == 'G')
		val *= 1024L * 1024L * 1024L;
	else
	{
		fprintf(stderr, "%s: %s: invalid size.\n", program_name, strsize);
		return SIZE_ERROR;
	}

	return val;
}


/* Get the size of an open file */
static long get_file_size(P(FILE *) file, P(const char *) filename)
PP(FILE *file;)
PP(const char *filename;)
{
	long initial_pos; /* Initial file position */
	int err; /* Seek error */
	long end_pos; /* End file position */

	/* Remember the initial position */
	initial_pos = ftell(file);
	if (initial_pos == -1)
	{
		fprintf(stderr, "%s: %s: %s\n", program_name, filename, strerror(errno));
		return SIZE_ERROR;
	}

	/* Seek to end of file */
	err = fseek(file, 0L, SEEK_END);
	if (err != 0)
	{
		fprintf(stderr, "%s: %s: %s\n", program_name, filename, strerror(errno));
		return SIZE_ERROR;
	}

	/* Get the end file position */
	end_pos = ftell(file);
	if (end_pos == -1)
	{
		fprintf(stderr, "%s: %s: %s\n", program_name, filename, strerror(errno));
		return SIZE_ERROR;
	}

	/* Restore the initial file position */
	err = fseek(file, initial_pos, SEEK_SET);
	if (err != 0)
	{
		fprintf(stderr, "%s: %s: %s\n", program_name, filename, strerror(errno));
		return SIZE_ERROR;
	}

	/* The end position is the file size */
	return end_pos - initial_pos;
}


/*
 * Write a block of identical bytes to a memory.
 * This could just use memset, if size_t > 16bit,
 * so this function is mainly for poor old
 * compilers like Alcyon.
 */
static VOID lmemset(P(uint8_t *) buffer, P(uint8_t) value, P(long) count)
PP(uint8_t *buffer;)
PP(uint8_t value;)
PP(long count;)
{
	if (sizeof(size_t) >= 4)
	{
		memset(buffer, value, (size_t)count);
	} else
	{
		size_t towrite; /* Number of bytes to write this time */
	
		while (count > 0)
		{
			towrite = MIN(BUFFER_SIZE, count);
			memset(buffer, value, towrite);
			count -= towrite;
			buffer += towrite;
		}
	}
}


/* Read a stream into memory */
static int read_file(P(FILE *) infile, P(const char *) infilename, P(uint8_t *) buffer, P(long) count)
PP(FILE *infile;)
PP(const char *infilename;)
PP(uint8_t *buffer;)
PP(long count;)
{
	size_t toread; /* Number of bytes to read this time */
	size_t towrite; /* Number of bytes to write this time */
	
	for (;;)
	{
		toread = MIN(BUFFER_SIZE, count);
		if (toread == 0)
			break;

		towrite = fread(buffer, 1, toread, infile);
		if (towrite == 0)
		{
			if (ferror(infile))
			{
				fprintf(stderr, "%s: %s: %s\n", program_name, infilename, strerror(errno));
				return FALSE;
			} else
			{
				fprintf(stderr, "%s: %s: premature end of file.\n", program_name, infilename);
				return FALSE;
			}
		}
		count -= towrite;
		buffer += towrite;
	}

	return TRUE;
}


/* write the output file */
static int write_file(P(FILE *) outfile, P(const char *) outfilename, P(uint8_t *) buffer, P(long) count)
PP(FILE *outfile;)
PP(const char *outfilename;)
PP(uint8_t *buffer;)
PP(long count;)
{
	size_t towrite; /* Number of bytes to write this time */
	size_t written; /* Number of bytes written this time */

	for (;;)
	{
		towrite = MIN(BUFFER_SIZE, count);
		if (towrite == 0)
			break;

		written = fwrite(buffer, 1, towrite, outfile);
		if (written != towrite)
		{
			fprintf(stderr, "%s: %s: %s\n", program_name, outfilename, strerror(errno));
			return FALSE;
		}

		count -= written;
		buffer += written;
	}

	return TRUE;
}


static int read_header(P(FILE *) infile, P(const char *) infilename, P(struct hdr2 *) hdr)
PP(FILE *infile;)
PP(const char *infilename;)
PP(struct hdr2 *hdr;)
{
	uint8_t buffer[HDSIZ2];
	
	if (fread(buffer, 1, HDSIZ2, infile) != HDSIZ2)
	{
		fprintf(stderr, "%s: %s: %s\n", program_name, infilename, strerror(errno));
		return FALSE;
	}
	hdr->ch_magic = rdbeshort(buffer);
	hdr->ch_tsize = rdbelong(buffer + 2);
	hdr->ch_dsize = rdbelong(buffer + 6);
	hdr->ch_bsize = rdbelong(buffer + 10);
	hdr->ch_ssize = rdbelong(buffer + 14);
	hdr->ch_stksize = rdbelong(buffer + 18);
	hdr->ch_entry = rdbelong(buffer + 22);
	hdr->ch_rlbflg = rdbelong(buffer + 24);
	hdr->ch_dstart = rdbelong(buffer + 28);
	hdr->ch_bstart = rdbelong(buffer + 32);
	if (hdr->ch_magic == MAGIC2 || /* Atari ROM header */
		hdr->ch_magic == 0xfa52 || /* first word of cartridge magic */
		hdr->ch_magic == 0x1111)   /* Amiga ROM header */
	{
		/* ROM header only; seek back to file start */
		fseek(infile, -HDSIZ2, SEEK_CUR);
		return TRUE;
	}
	if (hdr->ch_magic == MAGIC1)
	{
		if (hdr->ch_rlbflg == 0)
		{
			fprintf(stderr, "%s: %s: not absolutely linked\n", program_name, infilename);
			return FALSE;
		}
		return TRUE;
	}
	fprintf(stderr, "%s: %s: wrong magic $%04x\n", program_name, infilename, hdr->ch_magic);
	return FALSE;
}


static int16_t const crc_tab[256] = {
	0x0000, 0x1021, 0x2042, 0x3063, 0x4084, 0x50a5, 0x60c6, 0x70e7, 0x8108, 0x9129, 0xa14a, 0xb16b, 0xc18c, 0xd1ad, 0xe1ce, 0xf1ef,
	0x1231, 0x0210, 0x3273, 0x2252, 0x52b5, 0x4294, 0x72f7, 0x62d6, 0x9339, 0x8318, 0xb37b, 0xa35a, 0xd3bd, 0xc39c, 0xf3ff, 0xe3de,
	0x2462, 0x3443, 0x0420, 0x1401, 0x64e6, 0x74c7, 0x44a4, 0x5485, 0xa56a, 0xb54b, 0x8528, 0x9509, 0xe5ee, 0xf5cf, 0xc5ac, 0xd58d,
	0x3653, 0x2672, 0x1611, 0x0630, 0x76d7, 0x66f6, 0x5695, 0x46b4, 0xb75b, 0xa77a, 0x9719, 0x8738, 0xf7df, 0xe7fe, 0xd79d, 0xc7bc,
	0x48c4, 0x58e5, 0x6886, 0x78a7, 0x0840, 0x1861, 0x2802, 0x3823, 0xc9cc, 0xd9ed, 0xe98e, 0xf9af, 0x8948, 0x9969, 0xa90a, 0xb92b,
	0x5af5, 0x4ad4, 0x7ab7, 0x6a96, 0x1a71, 0x0a50, 0x3a33, 0x2a12, 0xdbfd, 0xcbdc, 0xfbbf, 0xeb9e, 0x9b79, 0x8b58, 0xbb3b, 0xab1a,
	0x6ca6, 0x7c87, 0x4ce4, 0x5cc5, 0x2c22, 0x3c03, 0x0c60, 0x1c41, 0xedae, 0xfd8f, 0xcdec, 0xddcd, 0xad2a, 0xbd0b, 0x8d68, 0x9d49,
	0x7e97, 0x6eb6, 0x5ed5, 0x4ef4, 0x3e13, 0x2e32, 0x1e51, 0x0e70, 0xff9f, 0xefbe, 0xdfdd, 0xcffc, 0xbf1b, 0xaf3a, 0x9f59, 0x8f78,
	0x9188, 0x81a9, 0xb1ca, 0xa1eb, 0xd10c, 0xc12d, 0xf14e, 0xe16f, 0x1080, 0x00a1, 0x30c2, 0x20e3, 0x5004, 0x4025, 0x7046, 0x6067,
	0x83b9, 0x9398, 0xa3fb, 0xb3da, 0xc33d, 0xd31c, 0xe37f, 0xf35e, 0x02b1, 0x1290, 0x22f3, 0x32d2, 0x4235, 0x5214, 0x6277, 0x7256,
	0xb5ea, 0xa5cb, 0x95a8, 0x8589, 0xf56e, 0xe54f, 0xd52c, 0xc50d, 0x34e2, 0x24c3, 0x14a0, 0x0481, 0x7466, 0x6447, 0x5424, 0x4405,
	0xa7db, 0xb7fa, 0x8799, 0x97b8, 0xe75f, 0xf77e, 0xc71d, 0xd73c, 0x26d3, 0x36f2, 0x0691, 0x16b0, 0x6657, 0x7676, 0x4615, 0x5634,
	0xd94c, 0xc96d, 0xf90e, 0xe92f, 0x99c8, 0x89e9, 0xb98a, 0xa9ab, 0x5844, 0x4865, 0x7806, 0x6827, 0x18c0, 0x08e1, 0x3882, 0x28a3,
	0xcb7d, 0xdb5c, 0xeb3f, 0xfb1e, 0x8bf9, 0x9bd8, 0xabbb, 0xbb9a, 0x4a75, 0x5a54, 0x6a37, 0x7a16, 0x0af1, 0x1ad0, 0x2ab3, 0x3a92,
	0xfd2e, 0xed0f, 0xdd6c, 0xcd4d, 0xbdaa, 0xad8b, 0x9de8, 0x8dc9, 0x7c26, 0x6c07, 0x5c64, 0x4c45, 0x3ca2, 0x2c83, 0x1ce0, 0x0cc1,
	0xef1f, 0xff3e, 0xcf5d, 0xdf7c, 0xaf9b, 0xbfba, 0x8fd9, 0x9ff8, 0x6e17, 0x7e36, 0x4e55, 0x5e74, 0x2e93, 0x3eb2, 0x0ed1, 0x1ef0
};


static uint16_t calc_crc(P(uint8_t *) p, P(long) size, P(unsigned int) inc)
PP(uint8_t *p;)
PP(long size;)
PP(unsigned int inc;)
{
	uint16_t sum;
	uint16_t run;
	
	sum = run = 0;
	do {
		run = sum;
		sum <<= 8;
		run >>= 8;
		run ^= *p & 0xff;
		sum ^= crc_tab[run];
		p += inc;
	} while (--size != 0);
	return sum;
}


/* Copy and pad with zeros up to target_size */
static int cmd_pad(P(FILE *) infile, P(const char *) infilename, P(FILE *) outfile, P(const char *) outfilename, P(long) target_size)
PP(FILE *infile;)
PP(const char *infilename;)
PP(FILE *outfile;)
PP(const char *outfilename;)
PP(long target_size;)
{
	long source_size;
	long free_size;
	int ret; /* boolean return value: 0 == error, 1 == OK */
	struct hdr2 hdr;
	uint8_t *buffer;
	uint8_t *crcpos;
	uint16_t tos_version;
	int i, banks;
	long banksize;
	uint16_t crc;
	
	printf("# Padding %s to %ld KB image into %s\n", infilename, target_size / 1024, outfilename);

	/* Get the input file size */
	source_size = get_file_size(infile, infilename);
	if (source_size == SIZE_ERROR)
		return 0;
	
	/*
	 * check if the file has a header
	 */
	if (read_header(infile, infilename, &hdr) == FALSE)
		return FALSE;
	if (hdr.ch_magic == MAGIC1)
	{
		/* only copy text+data, ignore potential symbol info */
		source_size = hdr.ch_tsize + hdr.ch_dsize;
	}
	
	buffer = lmalloc(target_size);
	if (buffer == NULL)
	{
		fprintf(stderr, "%s: %s\n", program_name, strerror(errno));
		return FALSE;
	}
	
	/* read the input file */
	ret = read_file(infile, infilename, buffer, source_size > target_size ? target_size : source_size);
	if (!ret)
		return ret;

	if (rdbeshort(buffer) == MAGIC2)
		tos_version = rdbeshort(buffer + 2);
	else
		tos_version = 0;
		
	if ((tos_version >= 0x400 && tos_version < 0x500) && target_size == 512L * 1024L)
	{
		/*
		 * Falcon TOS 4.x: a single 512KB ROM
		 */
		banks = 1;
		banksize = 0x7fffeL;
	} else if ((tos_version == 0x206 || tos_version == 0x207 || tos_version == 0x208) && target_size == 257L * 1024L)
	{
		/*
		 * ST-Book TOS 2.x: a single 256KB ROM
		 * The second half of the image contains a cartridge ROM
		 */
		banks = 1;
		banksize = 0x3fffeL;
		/*
		 * Makefile passes 257 here to distinguish it from ordinary ROMS;
		 * adjust that
		 */
		target_size = 256L * 1024L;
	} else if (tos_version != 0 && target_size == 512L * 1024L)
	{
		/*
		 * TT TOS 3.x: 4 128KB ROMs
		 */
		banks = 4;
		banksize = 0x1fffeL;
	} else if (tos_version != 0 && target_size == 256L * 1024L)
	{
		/*
		 * STE TOS 2.x: 2 128KB ROMs
		 */
		banks = 2;
		banksize = 0x1fffeL;
	} else
	{
		/*
		 * TOS 1.x: 6 32KB ROMs, without CRC
		 */
		banks = 0;
		banksize = 0;
	}

	/* Check if the input file size is not too big */
	if (source_size > (target_size - 2 * banks))
	{
		lfree(buffer);
		fprintf(stderr, "%s: %s is too big: %lu extra bytes\n", program_name, infilename, source_size - target_size);
		return FALSE;
	}

	/* Pad with FF */
	free_size = target_size - source_size;
	lmemset(buffer + source_size, 0xff, free_size);
	
	if (banks != 0)
	{
		for (i = 0; i < banks; i++)
		{
			crc = calc_crc(buffer + i, banksize, banks);
			crcpos = buffer + banksize * banks + i;
			/* write high byte of crc */
			crcpos[0] = crc >> 8;
			/* write low byte of crc */
			crcpos[banks] = crc;
		}
	} 
	/* write the output file */
	ret = write_file(outfile, outfilename, buffer, target_size);
	if (!ret)
		return ret;
	
	printf("# %s done (%lu bytes free)\n", outfilename, free_size);

	lfree(buffer);
	return TRUE;
}


int main(P(int) argc, P(char **) argv)
PP(int argc;)
PP(char **argv;)
{
	const char *infilename;
	FILE *infile;
	const char *outfilename;
	FILE *outfile;
	long target_size = 0;
	int err; /* stdio error: 0 == OK, EOF == error */
	int ret; /* boolean return value: 0 == error, 1 == OK */
	int op = CMD_NONE;
	
#ifdef __ALCYON__
	/* symbols etoa and ftoa are unresolved */
	asm("xdef _etoa");
	asm("_etoa equ 0");
	asm("xdef _ftoa");
	asm("_ftoa equ 0");
#endif

	if (argc == 5 && !strcmp(argv[1], "pad"))
	{
		op = CMD_PAD;

		target_size = get_size_value(argv[2]);
		if (target_size == SIZE_ERROR)
			return EXIT_FAILURE;

		infilename = argv[3];
		outfilename = argv[4];
	} else if (argc == 4 && !strcmp(argv[1], "stc"))
	{
		op = CMD_STC;
		infilename = argv[2];
		outfilename = argv[3];
	} else if (argc == 4 && !strcmp(argv[1], "amiga"))
	{
		op = CMD_AMIGA;
		infilename = argv[2];
		outfilename = argv[3];
	} else if (argc == 4 && !strcmp(argv[1], "amiga-kickdisk"))
	{
		op = CMD_KICKDISK;
		infilename = argv[2];
		outfilename = argv[3];
	} else
	{
		fprintf(stderr, "usage:\n");
		fprintf(stderr, "  # Generic zero padding\n");
		fprintf(stderr, "  %s pad <size> <source> <destination>\n", program_name);
#if 0
		fprintf(stderr, "\n");
		fprintf(stderr, "  # Steem Engine cartridge image\n");
		fprintf(stderr, "  %s stc <source> <destination>\n", program_name);
		fprintf(stderr, "\n");
		fprintf(stderr, "  # Amiga ROM image\n");
		fprintf(stderr, "  %s amiga <source> <destination>\n", program_name);
		fprintf(stderr, "\n");
		fprintf(stderr, "  # Amiga 1000 Kickstart disk\n");
		fprintf(stderr, "  %s amiga-kickdisk <sourcerom> <destination>\n", program_name);
#endif
		return EXIT_FAILURE;
	}

	/* Open the source file */
	infile = fopen(infilename, "rb");
	if (infile == NULL)
	{
		fprintf(stderr, "%s: %s: %s\n", program_name, infilename, strerror(errno));
		return EXIT_FAILURE;
	}

	/* Open the destination file */
	outfile = fopen(outfilename, "wb");
	if (outfile == NULL)
	{
		fprintf(stderr, "%s: %s: %s\n", program_name, outfilename, strerror(errno));
		return EXIT_FAILURE;
	}

	switch (op)
	{
	case CMD_PAD:
		ret = cmd_pad(infile, infilename, outfile, outfilename, target_size);
		break;

#if 0
	case CMD_STC:
		ret = cmd_stc(infile, infilename, outfile, outfilename);
		break;

	case CMD_AMIGA:
		ret = cmd_amiga(infile, infilename, outfile, outfilename);
		break;

	case CMD_AMIGA_KICKDISK:
		ret = cmd_amiga_kickdisk(infile, infilename, outfile, outfilename);
		break;
#endif

	default:
		abort(); /* Should not happen */
		break;
	}

	if (!ret)
	{
		/* Error message already written */
		fclose(outfile);
		unlink(outfilename);
		return EXIT_FAILURE;
	}

	/* Close the output file */
	err = fclose(outfile);
	if (err != 0)
	{
		unlink(outfilename);
		fprintf(stderr, "%s: %s: %s\n", program_name, outfilename, strerror(errno));
		return EXIT_FAILURE;
	}

	/* Close the input file */
	err = fclose(infile);
	if (err != 0)
	{
		fprintf(stderr, "%s: %s: %s\n", program_name, infilename, strerror(errno));
		return EXIT_FAILURE;
	}

	return EXIT_SUCCESS;
}
