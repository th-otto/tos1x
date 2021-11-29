/*	NEWGLUE.C	12/21/87		Derek Mui	*/

#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdint.h>
#include "../common/ctrycode.h"

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

#define _(x) x

typedef struct _glue_header {
	uint16_t off_deskrsc;
	uint16_t off_deskinf;
	uint16_t totalsize;
	uint16_t filler[2];
} glue_header;
#define SIZEOF_GLUE_HEADER 10

typedef struct _rs_header {
/* 0x00 */	uint16_t  rsh_vrsn;			/* version number (should be 1) */
/* 0x02 */	uint16_t  rsh_object;		/* offset to first object */
/* 0x04 */	uint16_t  rsh_tedinfo;		/* offset to TEDINFO structures */
/* 0x06 */	uint16_t  rsh_iconblk;		/* offset to ICONBLK structures */
/* 0x08 */	uint16_t  rsh_bitblk;		/* offset to BITBLK structures */
/* 0x0a */	uint16_t  rsh_frstr;		/* offset to free string (alert box texts) */
/* 0x0c */	uint16_t  rsh_string;		/* offset to string pool */
/* 0x0e */	uint16_t  rsh_imdata;		/* offset to image data */
/* 0x10 */	uint16_t  rsh_frimg;		/* offset to free images */
/* 0x12 */	uint16_t  rsh_trindex;		/* offset to tree addresses */
/* 0x14 */	uint16_t  rsh_nobs;			/* number of objects */
/* 0x16 */	uint16_t  rsh_ntree;		/* number of trees */
/* 0x18 */	uint16_t  rsh_nted;			/* number of TEDINFOs */
/* 0x1a */	uint16_t  rsh_nib;			/* number of ICONBLKs */
/* 0x1c */	uint16_t  rsh_nbb;			/* number of BITBLKs */
/* 0x1e */	uint16_t  rsh_nstring;		/* number of free strings */
/* 0x20 */	uint16_t  rsh_nimages;		/* number of free images */
/* 0x22 */	uint16_t  rsh_rssize;		/* total resource size */
} RS_HEADER;
#define SIZEOF_RS_HEADER ((size_t)(0x24))


#define	 TRUE	1
#define	 FALSE  0


static uint16_t getbeshort(const char *ptr)
{
	return ((ptr[0] << 8) & 0xff00) | (ptr[1] & 0x00ff);
}


static uint32_t getbelong(const char *ptr)
{
	return ((uint32_t)getbeshort(ptr) << 16) | ((uint32_t)getbeshort(ptr + 2));
}


static void putbeshort(char *ptr, uint16_t val)
{
	ptr[0] = (val >> 8) & 0xff;
	ptr[1] = val & 0xff;
}


#if 0
static void putbelong(char *ptr, uint32_t val)
{
	putbeshort(ptr, val >> 16);
	putbeshort(ptr + 2, val);
}
#endif



static void get_rsc_header(const char *ptr, RS_HEADER *hdr)
{
	hdr->rsh_vrsn = getbeshort(ptr + 0);
	hdr->rsh_object = getbeshort(ptr + 2);
	hdr->rsh_tedinfo = getbeshort(ptr + 4);
	hdr->rsh_iconblk = getbeshort(ptr + 6);
	hdr->rsh_bitblk = getbeshort(ptr + 8);
	hdr->rsh_frstr = getbeshort(ptr + 10);
	hdr->rsh_string = getbeshort(ptr + 12);
	hdr->rsh_imdata = getbeshort(ptr + 14);
	hdr->rsh_frimg = getbeshort(ptr + 16);
	hdr->rsh_trindex = getbeshort(ptr + 18);
	hdr->rsh_nobs = getbeshort(ptr + 20);
	hdr->rsh_ntree = getbeshort(ptr + 22);
	hdr->rsh_nted = getbeshort(ptr + 24);
	hdr->rsh_nib = getbeshort(ptr + 26);
	hdr->rsh_nbb = getbeshort(ptr + 28);
	hdr->rsh_nstring = getbeshort(ptr + 30);
	hdr->rsh_nimages = getbeshort(ptr + 32);
	hdr->rsh_rssize = getbeshort(ptr + 34);
}

static void get_glue_header(const char *ptr, glue_header *glue)
{
	glue->off_deskrsc = getbeshort(ptr + 0);
	glue->off_deskinf = getbeshort(ptr + 2);
	glue->totalsize = getbeshort(ptr + 4);
	glue->filler[0] = getbeshort(ptr + 6);
	glue->filler[1] = getbeshort(ptr + 8);
}

/*** ---------------------------------------------------------------------- ***/

static int test_header(RS_HEADER *header, long filesize)
{
	uint16_t vrsn;

	vrsn = header->rsh_vrsn;
	if (vrsn != 0)
		return FALSE;
	if (header->rsh_rssize > filesize)
		return FALSE;
#if 0
	if (header->rsh_rssize < (filesize - sizeof(*header)))
		return FALSE;
#endif
	if (header->rsh_object > header->rsh_rssize)
		return FALSE;
	if (header->rsh_object < SIZEOF_RS_HEADER && header->rsh_nobs != 0)
		return FALSE;
	if (header->rsh_tedinfo > header->rsh_rssize)
		return FALSE;
	if (header->rsh_tedinfo < SIZEOF_RS_HEADER && header->rsh_nted != 0)
		return FALSE;
	if (header->rsh_iconblk > header->rsh_rssize)
		return FALSE;
	if (header->rsh_iconblk < SIZEOF_RS_HEADER && header->rsh_nib != 0)
		return FALSE;
	if (header->rsh_bitblk > header->rsh_rssize)
		return FALSE;
	if (header->rsh_bitblk < SIZEOF_RS_HEADER && header->rsh_nbb != 0)
		return FALSE;
	if (header->rsh_frstr > header->rsh_rssize)
		return FALSE;
	if (header->rsh_string > header->rsh_rssize)
		return FALSE;
	/*
	 * There seems to be at least one resource editor out there
	 * that puts bogus values into rsh_imdata
	 */
	if (header->rsh_imdata > filesize && (header->rsh_nbb != 0 || header->rsh_nib != 0))
		return FALSE;
	if (header->rsh_frimg > header->rsh_rssize)
		return FALSE;
	if (header->rsh_trindex > header->rsh_rssize)
		return FALSE;
	if (header->rsh_nobs == 0)
		return FALSE;
	if (header->rsh_frstr == 0)
		return FALSE;
	if (header->rsh_nobs > 2729) /* (65536 - sizeof(RS_HEADER) - sizeof(OBJECT *)) / (sizeof(OBJECT)) */
		return FALSE;
	if (header->rsh_ntree > 2339) /* (65536 - sizeof(RS_HEADER)) / (sizeof(OBJECT) + sizeof(OBJECT *)) */
		return FALSE;
	return TRUE;
}

/*** ---------------------------------------------------------------------- ***/

static void print_header(const RS_HEADER *header)
{
	printf("rsh_vrsn:     $%04x\n", header->rsh_vrsn);
	printf("rsh_object:   $%04x\n", header->rsh_object);
	printf("rsh_tedinfo:  $%04x\n", header->rsh_tedinfo);
	printf("rsh_iconblk:  $%04x\n", header->rsh_iconblk);
	printf("rsh_bitblk:   $%04x\n", header->rsh_bitblk);
	printf("rsh_frstr:    $%04x\n", header->rsh_frstr);
	printf("rsh_string:   $%04x\n", header->rsh_string);
	printf("rsh_imdata:   $%04x\n", header->rsh_imdata);
	printf("rsh_frimg:    $%04x\n", header->rsh_frimg);
	printf("rsh_trindex:  $%04x\n", header->rsh_trindex);
	printf("rsh_nobs:     $%04x\n", header->rsh_nobs);
	printf("rsh_ntree:    $%04x\n", header->rsh_ntree);
	printf("rsh_nted:     $%04x\n", header->rsh_nted);
	printf("rsh_nib:      $%04x\n", header->rsh_nib);
	printf("rsh_nbb:      $%04x\n", header->rsh_nbb);
	printf("rsh_nstring:  $%04x\n", header->rsh_nstring);
	printf("rsh_nimages:  $%04x\n", header->rsh_nimages);
	printf("rsh_rssize:   $%04x\n", header->rsh_rssize);
}

/*** ---------------------------------------------------------------------- ***/

static void write_file(const char *filename, const char *address, long size)
{
	int fd;
	long written;
	
	fd = open(filename, O_CREAT|O_TRUNC|O_BINARY|O_WRONLY, 0644);
	if (fd < 0)
	{
		fprintf(stderr, _("can't create %s: %s\n"), filename, strerror(errno));
		exit(EXIT_FAILURE);
	}
	written = write(fd, address, (size_t)size);
	close(fd);
	if (written != size)
	{
		fprintf(stderr, _("error writing %s: %s\n"), filename, strerror(errno));
		exit(EXIT_FAILURE);
	}
	printf(_("wrote %s size %ld\n"), filename, size);
}

/*** ---------------------------------------------------------------------- ***/

int main(int argc, char **argv)
{
	int handle;
	const char *filename;
	long size;
	char *buffer;
	char *address;
	const char *end;
	RS_HEADER gemhdr;
	RS_HEADER deskhdr;
	glue_header glue;
	int found;
	unsigned long osentry;
	
	if (argc != 2)
	{
		fprintf(stderr, _("usage: findrsc tos.img\n"));
		return EXIT_FAILURE;
	}
	filename = argv[1];
	handle = open(filename, O_RDONLY | O_BINARY);	/* open source file */
	if (handle < 0)
	{
		fprintf(stderr, _("%s not found\n"), filename);
		return EXIT_FAILURE;
	}
	size = lseek(handle, 0L, SEEK_END);
	lseek(handle, 0L, SEEK_SET);
	
	if (size < (SIZEOF_RS_HEADER + SIZEOF_GLUE_HEADER))
	{
		fprintf(stderr, _("%s file too short\n"), filename);
		return EXIT_FAILURE;
	}
	buffer = lmalloc(size);
	if (!buffer)
	{
		fprintf(stderr, _("No memory !\n"));
		return EXIT_FAILURE;
	}
	read(handle, buffer, size);
	close(handle);

	address = buffer + SIZEOF_GLUE_HEADER;
	end = buffer + size - SIZEOF_RS_HEADER;
	
	if (getbeshort(buffer) == 0x602e)
		osentry = getbelong(buffer + 8);
	else
		osentry = 0;
	
	found = FALSE;
	while (address < end)
	{
		unsigned long offset;
		
		offset = (unsigned long)(address - buffer);
		get_glue_header(address, &glue);
		/*
		 * search for 3 consecutive zero words,
		 * 2 from glue header, 3rd from version field of resource header
		 */
		if (glue.filler[0] == 0 &&
			glue.filler[1] == 0 &&
			glue.off_deskrsc > SIZEOF_GLUE_HEADER &&
			glue.off_deskrsc + offset < size &&
			glue.off_deskinf + offset < size &&
			glue.totalsize + offset < size &&
			glue.off_deskrsc < glue.off_deskinf &&
			glue.off_deskinf < glue.totalsize)
		{
			get_rsc_header(address + SIZEOF_GLUE_HEADER, &gemhdr);
			if (test_header(&gemhdr, size - offset))
			{
				uint16_t ccode;
				const char *country;
				uint16_t version;
				char gemrsc[128];
				char deskrsc[128];
				char deskinf[128];
				
				found = TRUE;
				printf(_("found resource at $%08lx: glue header $%08lx, gem.rsc $%08lx($%04x), desk.rsc $%08lx($%04x), desktop.inf $%08lx($%04x)\n"),
					offset,
					offset + osentry,
					offset + SIZEOF_GLUE_HEADER + osentry, glue.off_deskrsc - SIZEOF_GLUE_HEADER,
					offset + glue.off_deskrsc + osentry, glue.off_deskinf - glue.off_deskrsc,
					offset + glue.off_deskinf + osentry, glue.totalsize - glue.off_deskinf);
					
				printf("GEM:\n");
				print_header(&gemhdr);
				printf("DESKTOP:\n");
				get_rsc_header(address + glue.off_deskrsc, &deskhdr);
				print_header(&deskhdr);
				ccode = (getbeshort(buffer + 28) >> 1) & 0x7f;
				version = getbeshort(buffer + 2);
				if (version == 0x306 && ccode == CTRY_UK && getbelong(buffer + 8) == 0x380000)
					ccode = CTRY_PL;
				switch (ccode)
				{
					case CTRY_US: country = "us"; break;
					case CTRY_DE: country = "de"; break;
					case CTRY_FR: country = "fr"; break;
					case CTRY_UK: country = "uk"; break;
					case CTRY_ES: country = "es"; break;
					case CTRY_IT: country = "it"; break;
					case CTRY_SE: country = "se"; break;
					case CTRY_SF: country = "sf"; break;
					case CTRY_SG: country = "sg"; break;
					case CTRY_TR: country = "tr"; break;
					case CTRY_FI: country = "fi"; break;
					case CTRY_NO: country = "no"; break;
					case CTRY_DK: country = "dk"; break;
					case CTRY_SA: country = "sa"; break;
					case CTRY_NL: country = "nl"; break;
					case CTRY_CZ: country = "cz"; break;
					case CTRY_HU: country = "hu"; break;
					case CTRY_PL: country = "pl"; break;
					case CTRY_LT: country = "lt"; break;
					case CTRY_RU: country = "ru"; break;
					case CTRY_EE: country = "ee"; break;
					case CTRY_BY: country = "by"; break;
					case CTRY_UA: country = "ua"; break;
					case CTRY_SK: country = "sk"; break;
					case CTRY_RO: country = "ro"; break;
					case CTRY_BG: country = "bg"; break;
					case CTRY_SI: country = "si"; break;
					case CTRY_HR: country = "hr"; break;
					case CTRY_RS: country = "rs"; break;
					case CTRY_ME: country = "me"; break;
					case CTRY_MK: country = "mk"; break;
					case CTRY_GR: country = "gr"; break;
					case CTRY_LV: country = "lv"; break;
					case CTRY_IL: country = "il"; break;
					case CTRY_ZA: country = "za"; break;
					case CTRY_PT: country = "pt"; break;
					case CTRY_BE: country = "be"; break;
					case CTRY_JP: country = "jp"; break;
					case CTRY_CN: country = "cn"; break;
					case CTRY_KR: country = "kr"; break;
					case CTRY_VN: country = "vn"; break;
					case CTRY_IN: country = "in"; break;
					case CTRY_IR: country = "ir"; break;
					case CTRY_MN: country = "mn"; break;
					case CTRY_NP: country = "np"; break;
					case CTRY_LA: country = "la"; break;
					case CTRY_KH: country = "kh"; break;
					case CTRY_ID: country = "id"; break;
					case CTRY_BD: country = "bd"; break;
					case 127: country = "any"; break;
					default: country = "xx"; break;
				}
				
#if 0
				sprintf(gemrsc, "gem%03x%s.rsc", version, country);
				sprintf(deskrsc, "desk%03x%s.rsc", version, country);
				sprintf(deskinf, "desk%03x%s.inf", version, country);
#else
				sprintf(gemrsc, "gem%s.rsc", country);
				sprintf(deskrsc, "desk%s.rsc", country);
				sprintf(deskinf, "desk%s.inf", country);
#endif
				size = glue.off_deskrsc - SIZEOF_GLUE_HEADER - 4;
				write_file(gemrsc, address + SIZEOF_GLUE_HEADER, size);

				size = glue.off_deskinf - glue.off_deskrsc - 4;
				/*
				 * fix wrong rsh_rssize field in PL resource
				 */
				if (ccode == CTRY_PL && deskhdr.rsh_rssize == 0x620c)
				{
					putbeshort(address + glue.off_deskrsc + 34, 0x6208);
				}
				write_file(deskrsc, address + glue.off_deskrsc, size);

				size = glue.totalsize - glue.off_deskinf - 6; /* -6 because of bug in newglue.c */
				write_file(deskinf, address + glue.off_deskinf, size);

				printf(_("total size %u $%x\n"), glue.totalsize, glue.totalsize);

				break;
			}
		}
		address += 2;
	}
	
	if (!found)
	{
		fprintf(stderr, _("%s: no resource found\n"), filename);
		return EXIT_FAILURE;
	}
	
	return EXIT_SUCCESS;
}
