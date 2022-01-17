#include <stdio.h>
#include <stddef.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>
#include <stdint.h>


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


static int generate_asm;


static VOID usage(NOTHING)
{
	fprintf(stderr, "usage: bin2c [-b] <infile> [<outfile>]\n");
	exit(EXIT_FAILURE);
}


int main(P(int) argc, P(char **)argv)
PP(int argc;)
PP(char **argv;)
{
	FILE *infile, *outfile;
	const char *infilename;
	const char *outfilename = NULL;
	
#ifdef __ALCYON__
	/* symbols etoa and ftoa are unresolved */
	asm("xdef _etoa");
	asm("_etoa equ 0");
	asm("xdef _ftoa");
	asm("_ftoa equ 0");
#endif

	if (argc > 1 && strcmp(argv[1], "-a") == 0)
	{
		generate_asm++;
		argc--;
		argv++;
	}
	
	if (argc != 2 && argc != 3)
		usage();
	infilename = argv[1];
	if (argc == 3)
		outfilename = argv[2];
	
	if ((infile = fopen(infilename, "rb")) == NULL)
	{
		fprintf(stderr, "%s: %s\n", infilename, strerror(errno));
		return EXIT_FAILURE;
	}
	
	if (outfilename == NULL || strcmp(outfilename, "-") == 0)
	{
		outfile = stdout;
	} else
	{
		outfile = fopen(outfilename, "wb");
		if (outfile == NULL)
		{
			fprintf(stderr, "%s: %s\n", outfilename, strerror(errno));
			return EXIT_FAILURE;
		}
	}
	
	{
		int v;
		int online;
		int perline = 8;
		
		online = 0;
		for (;;)
		{
			v = getc(infile);
			if (v == EOF)
			{
				break;
			}
			if (generate_asm)
			{
				if (online != 0)
					putc(',', outfile);
				else
					fputs("\t.dc.b ", outfile);
				fprintf(outfile, "0x%02x", (v) & 0xff);
			} else
			{
				if (online != 0)
					putc(' ', outfile);
				else
					putc('\t', outfile);
				fprintf(outfile, "0x%02x,", (v) & 0xff);
			}
			++online;
			if (online == perline)
			{
				putc('\n', outfile);
				online = 0;
			}
		}
		if (online != 0)
			putc('\n', outfile);
	}
	
	fclose(infile);
	fflush(outfile);
	if (outfile != stdout)
		fclose(outfile);
	
	return EXIT_SUCCESS;
}
