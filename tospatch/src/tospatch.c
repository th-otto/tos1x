/********************************************************************************
 * TosPatch V2.9.8:                                                             *
 * Dieses Programm dient zum Patchen des TOS mit einem einfachen ASCII-File.    *
 *                                                                              *
 * (C)1990    Sigma-soft, Markus Fritze                                         *
 * (C)1992-99 Markus Heiden                                          11.07.1999 *
 * Converted to C by Thorsten Otto                                              *
 ********************************************************************************/

#include "tospatch.h"
#ifndef __atarist__
#include <locale.h>
#endif

bool quiet;
bool allyes;
bool addrflag;
bool soundflg;
const char *patchfile;
int filenr;
long lineno;
long output_format;
memaddr max_length;
long machine_type;
memaddr current_addr;
char *tos_buffer; /* TOS image buffer */
bool wait_key_at_end;

static char *btchbuf; /* batch file buffer */

char const output_filename[] = "tos.img";

/******************************************************************************/
/*** ---------------------------------------------------------------------- ***/
/******************************************************************************/

#if __atarist__
#include <mint/sysvars.h>
static long get_jar(void)
{
	return *((long *)0x5a0);
}

/*** ---------------------------------------------------------------------- ***/

static long get_syshdr(void)
{
	return *((long *)0x4f2);
}

/*** ---------------------------------------------------------------------- ***/

static bool getcookie(long id, long *value)
{
	long *jar;
	
	*value = 0;
	jar = (long *)Supexec(get_jar);
	if (jar)
	{
		while (*jar != 0)
		{
			if (*jar == id)
			{
				*value = jar[1];
				return true;
			}
			jar += 2;
		}
	}
	return false;
}
#endif

/*** ---------------------------------------------------------------------- ***/

/*
 * determine length of file
 */
size_t read_length(const char *filename)
{
	FILE *fp;
	ssize_t size = 0;
	
	fp = fopen(filename, "rb");
	if (fp != NULL)
	{
		if (fseek(fp, 0, SEEK_END) == 0)
		{
			size = ftell(fp);
			if (size >= 0)
			{
				fclose(fp);
				return size;
			}
		}
		fclose(fp);
	}
	/* error */
	print_str(space_text);
	print_str(filename);
	print_line(error_text);
	mainexit(10);
	return size;
}

/*** ---------------------------------------------------------------------- ***/

static void rw_error(void)
{
	print_line(error_text);
	mainexit(10);
}

/*** ---------------------------------------------------------------------- ***/

/*
 * read a file into buffer
 */
void read_file(const char *filename, char *buffer, size_t size)
{
	FILE *fp;
	size_t len;

	print_str(space_text);
	print_str(filename);
	fp = fopen(filename, "rb");
	if (fp == NULL)
		rw_error();
	len = fread(buffer, 1, size, fp);
	if (len != size)
		rw_error();
	if (fclose(fp) != 0)
		rw_error();
	print_line(ok_text);
}

/*** ---------------------------------------------------------------------- ***/

/*
 * write a file to disk
 */
void write_file(const char *filename, const char *buffer, size_t size)
{
	FILE *fp;
	size_t len;
	
	print_str(space_text);
	print_str(filename);
	fp = fopen(filename, "wb");
	if (fp == NULL)
		rw_error();
	len = fwrite(buffer, 1, size, fp);
	if (len != size)
		rw_error();
	if (fclose(fp) != 0)
		rw_error();
	print_line(ok_text);
}

/*** ---------------------------------------------------------------------- ***/

static char const w8_ext[][4] = { "im" };
static char const w16_ext[][4] = { "hi", "lo" };
static char const w32_ext[][4] = { "ee", "oe", "eo", "oo" };
static char const w32_ext1[][4] = { "u10", "u11", "u12", "u13" };
static char const w64_ext[][4] = { "0_", "1_", "2_", "3_", "4_", "5_", "6_", "7_" };
static const char (*const w0_tab[])[4] = { w8_ext, w16_ext, w32_ext, w64_ext };
static const char (*const w1_tab[])[4] = { w8_ext, w16_ext, w32_ext1, w64_ext };
static const char (*const *const wx_tab[])[4] = { w0_tab, w1_tab };

/*
 * Save the TOS image file(s)
 */
static void save_tos(void)
{
	memaddr width;
	memaddr length;
	memaddr srclen;
	char *img_buffer;
	int log2_width; /* log2(WIDTH / 8) */
	const char (*tab)[4];
	char filec;
	memaddr offset;
	int fileno;
	int num_files;
	char fname[12];
	char *src;
	char *dst;
	memaddr i;
	
	if (output_format == 0)
		return;
	print_line(write_tos);
	if (output_format > 32)
		error_handler(ERR_NOLINENO, toomany_files_err);
	if (output_format == 1)
	{
		/* write a single image */
		write_file(output_filename, tos_buffer, get_length());
		return;
	}
	width = get_width();
	/* more than 16 banks? */
	if (output_format > width * 2)
		error_handler(ERR_NOLINENO, toomany_files_err);
	/* do width and output format match? */
	width >>= 3;
	if (((width - 1) & output_format) != 0)
		error_handler(ERR_NOLINENO, width_mismatch_err);
	/* compute length of single file (LENGTH/OUTPUT_FORMAT) */
	length = get_length();
	if ((length % output_format) != 0)
		error_handler(ERR_NOLINENO, length_mismatch_err);
	
	length /= output_format;
	img_buffer = xmalloc(length);
	switch ((int) width)
	{
		case 1: log2_width = 0; break;
		case 2: log2_width = 1; break;
		case 4: log2_width = 2; break;
		case 8: log2_width = 3; break;
		default: return;
	}
	if (machine_type >= (int)ARRAY_SIZE(wx_tab))
		error_handler(ERR_NOLINENO, machine_err);
	
	tab = wx_tab[machine_type][log2_width];
	
	filec = '0';
	offset = 0;
	srclen = 0;
	for (num_files = (int)output_format; num_files > 0; num_files -= (int)width)
	{
		for (fileno = 0; fileno < (int)width; fileno++)
		{
			strcpy(fname, output_filename);
			fname[4] = tab[fileno][0];
			fname[5] = tab[fileno][1];
			fname[6] = tab[fileno][2];
			if (output_format != width)
			{
				if (tab[fileno][2] != '\0')
					error_handler(ERR_NOLINENO, machine_bank_err);
				fname[6] = filec;
			}
			src = tos_buffer + srclen + fileno;
			dst = img_buffer;
			print_str(" $%08lx:", (long)(src - tos_buffer) + get_reloc_addr());
			for (i = length; --i >= 0; )
			{
				*dst++ = *src;
				dst += width;
			}
			offset += length;
			write_file(fname, img_buffer, length);
		}
		srclen = offset;
		filec++;
		if (filec == '9' + 1)
			filec = 'a';
	}
		
	xfree(img_buffer);
}

/*** ---------------------------------------------------------------------- ***/

void *xmalloc(size_t size)
{
	void *p;
	
	p = malloc(size);
	if (p == NULL)
		error_handler(ERR_NOLINENO, enomem_text);
	return p;
}

/*** ---------------------------------------------------------------------- ***/

void xfree(void *ptr)
{
	free(ptr);
}

/*** ---------------------------------------------------------------------- ***/

static void usage(void)
{
	error_handler(ERR_NOLINENO, usage_error);
}

/*** ---------------------------------------------------------------------- ***/

int main(int argc, char **argv)
{
	int i;
	size_t size;
	
#if __atarist__
	{
		long akp;
		/* set up country code */
		if (getcookie(0x5f414b50L, &akp))
		{
			ctry_code = ((int)akp >> 8) & 0xff;
		} else
		{
			if (Ssystem(-1, 0, 0) == 0)
			{
				short val = Ssystem(3, 26, 0); /* S_OSHEADER */
				ctry_code = (short)(val >> 1) & 0x7f;
			} else
			{
				OSHEADER *sys;
				
				sys = (OSHEADER *)Supexec(get_syshdr);
				ctry_code = (sys->os_conf >> 1) & 0x7f;
			}
		}
	}
	/*
	 * assumes that decent shells use ARGV.
	 * When run from desktop, this will be empty.
	 */
	wait_key_at_end = argv[0] == NULL || argv[0][0] == '\0';
#else

	setlocale(LC_ALL, "");
	{
		const char *lang;
		
		lang = getenv("LC_MESSAGES");
		if (lang == NULL)
			lang = getenv("LANG");
		if (lang == NULL)
			lang = "C";
		if (strncmp(lang, "en_US", 5) == 0)
			ctry_code = COUNTRY_US;
		else if (strncmp(lang, "en_UK", 5) == 0)
			ctry_code = COUNTRY_UK;
		else if (strncmp(lang, "fr_CH", 5) == 0)
			ctry_code = COUNTRY_SF;
		else if (strncmp(lang, "de_CH", 5) == 0)
			ctry_code = COUNTRY_SG;
		else if (strncmp(lang, "de", 2) == 0)
			ctry_code = COUNTRY_DE;
		else if (strncmp(lang, "fr", 2) == 0)
			ctry_code = COUNTRY_FR;
		else if (strncmp(lang, "es", 2) == 0)
			ctry_code = COUNTRY_ES;
		else if (strncmp(lang, "it", 2) == 0)
			ctry_code = COUNTRY_IT;
		else if (strncmp(lang, "se", 2) == 0)
			ctry_code = COUNTRY_SE;
		else if (strncmp(lang, "tr", 2) == 0)
			ctry_code = COUNTRY_TR;
		else if (strncmp(lang, "fi", 2) == 0)
			ctry_code = COUNTRY_FI;
		else if (strncmp(lang, "nb", 2) == 0)
			ctry_code = COUNTRY_NO;
		else if (strncmp(lang, "da", 2) == 0)
			ctry_code = COUNTRY_DK;
		else if (strncmp(lang, "ar", 2) == 0)
			ctry_code = COUNTRY_SA;
		else if (strncmp(lang, "nl_BE", 5) == 0)
			ctry_code = COUNTRY_BE;
		else if (strncmp(lang, "nl", 2) == 0)
			ctry_code = COUNTRY_NL;
		else if (strncmp(lang, "cs", 2) == 0)
			ctry_code = COUNTRY_CZ;
		else if (strncmp(lang, "hu", 2) == 0)
			ctry_code = COUNTRY_HU;
		else if (strncmp(lang, "pl", 2) == 0)
			ctry_code = COUNTRY_PL;
		else if (strncmp(lang, "lt", 2) == 0)
			ctry_code = COUNTRY_LT;
		else if (strncmp(lang, "ru", 2) == 0)
			ctry_code = COUNTRY_RU;
		else if (strncmp(lang, "et", 2) == 0)
			ctry_code = COUNTRY_EE;
		else if (strncmp(lang, "be", 2) == 0)
			ctry_code = COUNTRY_BY;
		else if (strncmp(lang, "uk", 2) == 0)
			ctry_code = COUNTRY_UA;
		else if (strncmp(lang, "sk", 2) == 0)
			ctry_code = COUNTRY_SK;
		else if (strncmp(lang, "ro", 2) == 0)
			ctry_code = COUNTRY_RO;
		else if (strncmp(lang, "bg", 2) == 0)
			ctry_code = COUNTRY_BG;
		else if (strncmp(lang, "sl", 2) == 0)
			ctry_code = COUNTRY_SI;
		else if (strncmp(lang, "hr", 2) == 0)
			ctry_code = COUNTRY_HR;
		else if (strncmp(lang, "sr_ME", 5) == 0)
			ctry_code = COUNTRY_ME;
		else if (strncmp(lang, "sr", 2) == 0)
			ctry_code = COUNTRY_RS;
		else if (strncmp(lang, "mk", 2) == 0)
			ctry_code = COUNTRY_MK;
		else if (strncmp(lang, "el", 2) == 0)
			ctry_code = COUNTRY_GR;
		else if (strncmp(lang, "lv", 2) == 0)
			ctry_code = COUNTRY_LV;
		else if (strncmp(lang, "he", 2) == 0)
			ctry_code = COUNTRY_IL;
		else if (strncmp(lang, "af_ZA", 5) == 0)
			ctry_code = COUNTRY_ZA;
		else if (strncmp(lang, "pt", 2) == 0)
			ctry_code = COUNTRY_PT;
		else if (strncmp(lang, "ja", 2) == 0)
			ctry_code = COUNTRY_JP;
		else if (strncmp(lang, "zh", 2) == 0)
			ctry_code = COUNTRY_CN;
		else if (strncmp(lang, "ko", 2) == 0)
			ctry_code = COUNTRY_KR;
		else if (strncmp(lang, "vi", 2) == 0)
			ctry_code = COUNTRY_VN;
		else if (strncmp(lang, "hi", 2) == 0)
			ctry_code = COUNTRY_IN;
		else if (strncmp(lang, "fa", 2) == 0)
			ctry_code = COUNTRY_IR;
		else if (strncmp(lang, "mn", 2) == 0)
			ctry_code = COUNTRY_MN;
		else if (strncmp(lang, "ne", 2) == 0)
			ctry_code = COUNTRY_NP;
		else if (strncmp(lang, "lo", 2) == 0)
			ctry_code = COUNTRY_LA;
		else if (strncmp(lang, "km", 2) == 0)
			ctry_code = COUNTRY_KH;
		else if (strncmp(lang, "id", 2) == 0)
			ctry_code = COUNTRY_ID;
		else if (strncmp(lang, "bn_BD", 5) == 0)
			ctry_code = COUNTRY_BD;
		else
			ctry_code = 0;
	}
	
#endif
	
	for (i = 1; i < argc; i++)
	{
		const char *arg = *++argv;
		
		if (*arg == '-')
		{
			while (*++arg)
			{
				switch (*arg)
				{
				case 'q':
					quiet = true;
					break;
				case 'm':
					allyes = true;
					break;
				case 'l':
					logflg = true;
					break;
				case 'a':
					addrflag = true;
					break;
				case 'K':
					soundflg = true;
					break;
				default:
					usage();
					break;
				}
			}
		} else
		{
			patchfile = arg;
		}
	}
	
	if (patchfile == NULL)
		patchfile = "patch.fil";

	print_line(init_text);

	openlog();
	setlog();
	
	print_line(read_1st_text);
	
	/* get size of file */
	size = read_length(patchfile);
	/* read main batchfile */
	btchbuf = xmalloc(size + 1);
	read_file(patchfile, btchbuf, size);
	btchbuf[size] = '\0';

	/* process it */
	parse_init();
	parse_buffer(btchbuf);
	xfree(btchbuf);
	btchbuf = NULL;

	if (tos_buffer != NULL)
	{
		reloc_it();
		crc_checksum();
		save_tos();
	}
	
	mainexit(0);

	return 0;
}
