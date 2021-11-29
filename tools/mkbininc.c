#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdint.h>

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
#define NOTHING void                /* no parameters */
#define PROTO(p) p
#define P(t) t
#define PP(v)
#endif
#endif

#define _(x) x

#undef MIN
#define MIN(a, b) ((a)<=(b) ? (a) : (b))
#define BUFFER_SIZE (16*1024)


#define	 TRUE	1
#define	 FALSE  0


/* Read a stream into memory */
static int read_file(P(int) infile, P(const char *) infilename, P(char *) buffer, P(long) count)
PP(int infile;)
PP(const char *infilename;)
PP(char *buffer;)
PP(long count;)
{
	size_t toread; /* Number of bytes to read this time */
	size_t towrite; /* Number of bytes to write this time */
	
	for (;;)
	{
		toread = MIN(BUFFER_SIZE, count);
		if (toread == 0)
			break;

		towrite = read(infile, buffer, toread);
		if (towrite != toread)
		{
			fprintf(stderr, "%s: %s\n", infilename, strerror(errno));
			return FALSE;
		}
		count -= towrite;
		buffer += towrite;
	}

	return TRUE;
}


int main(P(int) argc, P(char **) argv)
PP(int argc;)
PP(char **argv;)
{
	const char *infile;
	const char *outfile;
	const char *symname;
	int handle;
	long filesize, i, j, count;
	char *buffer;
	FILE *fp;
	char *p;
	int ret;
	
#ifdef __ALCYON__
	/* symbols etoa and ftoa are unresolved */
	asm("xdef _etoa");
	asm("_etoa equ 0");
	asm("xdef _ftoa");
	asm("_ftoa equ 0");
#endif

	if (argc < 2)
	{
		fprintf(stderr, _("usage: mkbininc <infile> [<symname> [<outfile>]]\n"));
		return EXIT_FAILURE;
	}
	infile = argv[1];
	if (argc > 2)
		symname = argv[2];
	else
		symname = "tosrsc";
	if (argc > 3)
		outfile = argv[3];
	else
		outfile = "-";
	
	handle = open(infile, O_RDONLY | O_BINARY);	/* open source file */
	if (handle < 0)
	{
		fprintf(stderr, _("%s not found\n"), infile);
		return EXIT_FAILURE;
	}
	filesize = lseek(handle, 0L, SEEK_END);
	lseek(handle, 0L, SEEK_SET);
	
	buffer = lmalloc(filesize);
	if (!buffer)
	{
		fprintf(stderr, _("No memory !\n"));
		return EXIT_FAILURE;
	}
	ret = read_file(handle, infile, buffer, filesize);
	close(handle);
	if (ret == FALSE)
		return EXIT_FAILURE;
	
	if (strcmp(outfile, "-") == 0)
	{
		fp = stdout;
	} else
	{
		fp = fopen(outfile, "wb");
		if (fp == NULL)
		{
			fprintf(stderr, _("can't create %s: %s\n"), outfile, strerror(errno));
			return EXIT_FAILURE;
		}
	}
	
	fprintf(fp, "/*\n");
	fprintf(fp, " * automatically generated from %s - DO NOT EDIT\n", infile);
	fprintf(fp, " */\n");
	fprintf(fp, "#include \"config.h\"\n");
	fprintf(fp, "#include <compiler.h>\n\n");

	fprintf(fp, "\n\n");
	/*
	 * PAK-trick to boot up the PAK ROMS with TOS 1.x on the mainboard.
	 * For this to work, we have to move the resource after
	 * the OSHEADER of the 2nd half of the ROM:
	 *
	 * - after reset, CPU loads $00FC0030 as initial PC (from TOS 1.xx on the mainboard)
	 * - when accessing $00FC0030, the PAK-TOS will be accessed if enabled
	 * - addresses as seen by PAK-ROMs: 
	 *   F    C    0    0    3    0      ; this address is on the bus (hex)
	 *   1111 1100 0000 0000 0011 0000   ; (bin)
	 *   xxxx x100 0000 0000 0011 0000   ; this address will be seen by ROM (512 kBytes, bin)
	 *   x    4    0    0    3    0      ; (hex)
	 *
	 * The constant RSCGAP is computed from the Makefile,
	 * by linking the image without a resource first.
	 */
	fprintf(fp, "#if (TOSVERSION >= 0x200)\n");
	fprintf(fp, "#if TP_50 & TP_53\n");
	fprintf(fp, "#include \"rscend.h\"\n");
	fprintf(fp, "#ifndef RSCGAP\n");
	fprintf(fp, "error\n");
	fprintf(fp, "#endif\n");
	fprintf(fp, "#if RSCGAP != 0\n");
	fprintf(fp, "#if RSCGAP < 0\n");
	fprintf(fp, "error\n");
	fprintf(fp, "#endif\n");
	fprintf(fp, "static char const fillup[RSCGAP] = { 0 };\n");
	fprintf(fp, "static char const bootjmp[] = { 0x4E,0xF9,0,0xE0,0,0 };\n");
	fprintf(fp, "#endif\n");
	fprintf(fp, "#endif\n\n");
	fprintf(fp, "#endif\n\n");

	fprintf(fp, "char const %s[] = {\n", symname);

	p = buffer;
	
	for (i = 0; i < filesize; )
	{
		count = filesize - i;
		if (count > 16)
			count = 16;
		i += count;
		
		fprintf(fp, "\t");
		for (j = 0; j < count; )
		{
			if (j != 0)
				fputc(' ', fp);
			fprintf(fp, "0x%02x", p[j] & 0xff);
			j++;
			if (j != count || i != filesize)
				putc(',', fp);
		}
		fprintf(fp, "\n");
		
		p += count;
	}
	
	fprintf(fp, "};\n");
	
	fprintf(fp, "char const edata[2] = { 0xff, 0xff };\n");

	return EXIT_SUCCESS;
}
