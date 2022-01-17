#include "tospatch.h"
#include <time.h>
#ifdef __PUREC__
#include <ext.h> /* for chdir */
#else
#include <unistd.h>
#endif
#include "s_endian.h"

#define COND_IF       0x4946 /* 'IF' */
#define COND_ELSE     0x454c /* 'EL' */
#define COND_SWITCH   0x5357 /* 'SW' */
#define COND_CASE     0x4341 /* 'CA' */
#define COND_DEFAULT  0x4445 /* 'DE' */

memaddr lastaddr;
bool do_addr;

static memaddr rangelo;
static memaddr rangehi;
static long nest_count;
static long variable;

static int cond_flag;

#define MAX_SEL 128
static long sel_stack[MAX_SEL];
static int sel_count;

#define MAX_IF 128
static int if_stack[MAX_IF];
static int if_count;

#define MAX_SW 128
static struct {
	int cond_flag;
	long value;
} sw_stack[MAX_SW];
static int sw_count;

static struct {
	char name[4];
	short value;
} const countries[] = {
	{ "USA", COUNTRY_US },
	{ "FRG", COUNTRY_DE },
	{ "FRA", COUNTRY_FR },
	{ "UK",  COUNTRY_UK },
	{ "SPA", COUNTRY_ES },
	{ "ITA", COUNTRY_IT },
	{ "SWE", COUNTRY_SE },
	{ "SWF", COUNTRY_SF },
	{ "SWG", COUNTRY_SG },
	{ "TUR", COUNTRY_TR },
	{ "FIN", COUNTRY_FI },
	{ "NOR", COUNTRY_NO },
	{ "DEN", COUNTRY_DK },
	{ "SAU", COUNTRY_SA },
	{ "HOL", COUNTRY_NL },
	{ "CZE", COUNTRY_CZ },
	{ "HUN", COUNTRY_HU }
};

#define CR 0x0d
#define LF 0x0a
#define CMT ';'
#define MAX_FILENAME 128

/******************************************************************************/
/*** ---------------------------------------------------------------------- ***/
/******************************************************************************/

static void clrrange(void)
{
	if (addrflag)
	{
		rangelo = rangehi = 0;
		do_addr = true;
	}
}

/*** ---------------------------------------------------------------------- ***/

static void logrange(memaddr lo, memaddr hi)
{
	print_line(log_patch, (long)lo);
	if (hi != lo + 1)
		print_str(" - $%08lx", (long)hi);
	print_str(lf_text);
}

/*** ---------------------------------------------------------------------- ***/

static void prrange(void)
{
	do_addr = false;
	if (rangehi != 0)
		logrange(rangelo, rangehi);
}

/*** ---------------------------------------------------------------------- ***/

static void prcrange(void)
{
	if (do_addr && rangehi != 0)
	{
		logrange(rangelo, rangehi);
		rangelo = rangehi = 0;
	}
}

/*** ---------------------------------------------------------------------- ***/

static void ckrange(memaddr addr, memaddr len)
{
	memaddr end;
	memaddr lo;
	memaddr hi;

	if (do_addr)
	{
		end = addr + len;
		lo = rangelo;
		hi = rangehi;
		if (hi != 0)
		{
			if (addr > hi || end < lo)
			{
				rangelo = addr;
				rangehi = end;
				logrange(lo, hi);
			} else
			{
				if (addr < lo)
					rangelo = addr;
				if (end > hi)
					rangehi = end;
			}
		} else
		{
			rangelo = addr;
			rangehi = end;
		}
	}
}

/******************************************************************************/
/*** ---------------------------------------------------------------------- ***/
/******************************************************************************/

void parse_init(void)
{
	time_t t;
	struct tm tm;
	int i;
	
	clrrange();
	t = time(0);
	tm = *localtime(&t);
	/* write date as GEMDOS value */
	write_var(var_date, ((tm.tm_year + 80) << 9) + ((tm.tm_mon + 1) << 5) + tm.tm_mday);
	/* write single values */
	write_var(var_day, tm.tm_mday);
	write_var(var_month, tm.tm_mon + 1);
	write_var(var_year, tm.tm_year + 1900);
	
	/* create CRC and set to zero */
	write_var(var_crc, 0);
	for (i = 0; i < (int)ARRAY_SIZE(countries); i++)
		write_var(countries[i].name, countries[i].value);
}

/*** ---------------------------------------------------------------------- ***/

int skip_space(char **batchptr)
{
	unsigned char c;
	
	for (;;)
	{
		c = *(*batchptr)++;
		if (c == 0 || c == CMT || c == CR || c == LF)
		{
			--(*batchptr);
			c = 0;
			break;
		}
		if (c != ' ' && c != '\t')
		{
			--(*batchptr);
			break;
		}
	}
	return c;
}

/*** ---------------------------------------------------------------------- ***/

static int getfilename(char *filename, char **batchptr)
{
	char *ptr = *batchptr;
	unsigned char c;
	int len;
	
	len = 0;
	for (;;)
	{
		c = *ptr++;
		if (c == 0 || c == CMT || c == CR || c == LF || c == ' ' || c == '\t')
		{
			--ptr;
			break;
		}
		if (len < MAX_FILENAME - 1)
		{
			++len;
			*filename++ = c;
		}
	}
	*filename = '\0';
	*batchptr = ptr;
	if (len == 0)
		c = 0;
	return c;
}

/*** ---------------------------------------------------------------------- ***/

/* read a list of simple patches */
static memaddr read_patches(char **batchptr, char *buffer, memaddr length)
{
	int c;
	memaddr size;
	long extsize;
	int delim;
	unsigned long value;
	char *ptr;
	char filename[MAX_FILENAME];

	size = 0;
	if ((c = skip_space(batchptr)) == 0)
	{
		unexpected_eof();
		return 0;
	}
	
	if (c == '$')
		++(*batchptr);
	for (;;)
	{
		switch (c)
		{
		case '$':
		case '\'':
		case '"':
			if ((c = skip_space(batchptr)) == 0)
			{
				unexpected_eof();
				return size;
			}
			if (c == '\'' || c == '"')
			{
				delim = *(*batchptr)++;
				for (;;)
				{
					c = *(*batchptr)++;
					if (c == 0 || c == CR || c == LF)
					{
						unexpected_eof();
						return size;
					}
					if (c == delim)
						break;
					if (size >= length)
						return -1;
					*buffer++ = c;
					size++;
					/* also updated by caller */
					current_addr++;
				}
			} else if (c == '#')
			{
				value = variable;
				(*batchptr)++;
				c = *(*batchptr)++;
				if (ISLOWER(c))
					c = ISUPPER(c);
				switch (c)
				{
				case 'B':
					extsize = 1;
					break;
				case 'W':
					extsize = 2;
					break;
				case 'L':
					extsize = 4;
					break;
				default:
					error_handler(0, bad_variable_extension_err);
					return size;
				}
				goto putvalue;
			} else
			{
				value = get_term(batchptr);
				extsize = get_extension(batchptr);
			putvalue:
				size += extsize;
				buffer += extsize;
				if (size > length)
					return -1;
				/* also updated by caller */
				current_addr += extsize;
				ptr = buffer;
				do
				{
					*--ptr = (char)value;
					value >>= 8;
				} while (--extsize != 0);
			}
			if ((c = skip_space(batchptr)) == 0)
				return size;
			if (*(*batchptr)++ != ',')
			{
				illegal_delimiter();
				return size;
			}
			c = '$';
			break;
		
		default:
			if (getfilename(filename, batchptr) == 0)
			{
				unexpected_eof();
				return size;
			}
			extsize = read_length(filename);
			size += extsize;
			if (size > length)
				return -1;
			read_file(filename, buffer, extsize);
			return size;
		}
	}
}

/*** ---------------------------------------------------------------------- ***/

static bool handle_patch(char **batchptr)
{
	memaddr addr;
	memaddr len;
	memaddr base;
	int c;
	bool noupdate;
	memaddr save_current_addr;
	
	addr = get_term(batchptr);
	if (addr >= max_length)
	{
		base = get_base();
		if (addr < base || addr >= base + max_length)
		{
			illegal_offset();
			return false;
		}
		addr -= base;
	}
	if ((c = skip_space(batchptr)) == 0)
	{
		current_addr = addr;
		return false;
	}
	if (c == ':')
	{
		(*batchptr)++;
		current_addr = addr;
		error_handler(ERR_CONTINUE, undocumented_use_of_colon_err);
		return true;
	}
	noupdate = c == '|';
	if (noupdate)
		(*batchptr)++;
	save_current_addr = current_addr;
	current_addr = addr;
	if (skip_space(batchptr) == 0)
	{
		unexpected_eof();
		return false;
	}
	if (tos_buffer == NULL)
	{
		error_handler(0, tos_not_loaded_err);
		return false;
	}
	len = max_length - addr;
	if ((len = read_patches(batchptr, tos_buffer + addr, len)) < 0)
	{
		error_handler(0, patches_too_large_err);
		return false;
	}
	ckrange(addr, len);
	current_addr = addr + len;
	if (noupdate)
		current_addr = save_current_addr;
	return false;
}

/*** ---------------------------------------------------------------------- ***/

/* evaluate lines starting with '.' */
static bool handle_dot(char **batchptr)
{
	char *start;
	int c;
	long sel;
	long value;

	start = *batchptr + 1;
	if (start[0] >= '0' && start[0] <= '9')
	{
		return handle_patch(batchptr);
	} else
	{
		get_vname(batchptr);
		if ((c = skip_space(batchptr)) == 0 || (c != '=' && c != ':'))
		{
			/* .VARIABLE is Patchoffset */
			*batchptr = start - 1;
			return handle_patch(batchptr);
		} else
		{
			++(*batchptr);
			if (c == ':')
			{
				/* set .VARIABLE to ~ */
				write_var(start, current_addr);
				return true;
			} else
			{
				if ((c = skip_space(batchptr)) == 0)
				{
					unexpected_eof();
					return false;
				}
				if (sel_count == 0)
				{
					write_var(start, get_term(batchptr));
					if ((c = skip_space(batchptr)) == 0)
						return false;
					switch (c)
					{
					case ',':
					case ':':
						error_handler(0, multiple_assign_err);
						break;
					default:
						error_handler(0, garbage_err);
						break;
					}
				} else
				{
					sel = sel_stack[sel_count - 1];
					for (;;)
					{
						if ((c = skip_space(batchptr)) == 0)
							error_handler(0, selector_too_large_err);
						if (c == ',')
						{
							if (sel == 0)
								error_handler(0, no_argument_err);
							++(*batchptr);
							--sel;
						} else
						{
							value = get_term(batchptr);
							if (sel == 0)
							{
								write_var(start, value);
								if ((c = skip_space(batchptr)) != 0 && c != ',' && c != ':')
									error_handler(0, garbage_err);
								break;
							}
							if ((c = skip_space(batchptr)) == 0)
							{
								if (sel_stack[sel_count - 1] != 0)
									error_handler(0, selector_too_large_err);
								write_var(start, value);
								if (skip_space(batchptr) != 0)
									error_handler(0, garbage_err);
								break;
							} else
							{
								if (*(*batchptr)++ == ':')
								{
									value = get_term(batchptr);
									write_var(start, value);
									if (skip_space(batchptr) != 0)
										error_handler(0, garbage_err);
									break;
								}
								--sel;
								if (c != ',')
									error_handler(0, selector_too_large_err);
							}
						}
					}
				}
			}
		}
	}
	return false;
}

/*** ---------------------------------------------------------------------- ***/

/* change current directory */
static void handle_chdir(char **batchptr)
{
	char filename[MAX_FILENAME];
	
	++(*batchptr);
	prcrange();
	if (getfilename(filename, batchptr) == 0)
	{
		unexpected_eof();
		return;
	}
	print_line(path_text, filename);
	chdir(filename);
}

/*** ---------------------------------------------------------------------- ***/

/* process new batch file */
static void handle_batch(char **batchptr)
{
	char filename[MAX_FILENAME];
	size_t size;
	char *ptr;
	long save_lineno;
	int save_if_count;
	int save_sw_count;
	int save_sel_count;
	
	++(*batchptr);
	if (filenr > 256)
		error_handler(0, toomany_batch_err);
	print_line(read_2nd_text);
	if (getfilename(filename, batchptr) == 0)
	{
		unexpected_eof();
		return;
	}
	size = read_length(filename);
	ptr = xmalloc(size + 1);
	read_file(filename, ptr, size);
	ptr[size] = '\0';
	/*
	 * save lineno and counters
	 */
	save_lineno = lineno;
	save_if_count = if_count;
	save_sw_count = sw_count;
	save_sel_count = sel_count;
	++filenr;
	parse_buffer(ptr);
	xfree(ptr);
	/* end of batch file */
	prcrange();
	print_line(batch_end_text);
	--filenr;
	/* restore lineno and counters */
	lineno = save_lineno;
	if_count = save_if_count;
	sw_count = save_sw_count;
	sel_count = save_sel_count;
}

/*** ---------------------------------------------------------------------- ***/

/* process reloc exceptions */
static void handle_relocs(char **batchptr)
{
	size_t exc;
	size_t range;
	memaddr lo, hi;
	int c;
	
	++(*batchptr);
	/* search for end of table */
	for (exc = 0; exc < MAX_RELOC_EXECPTIONS; exc++)
		if (reloc_exceptions[exc] == 0)
			break;
	for (range = 0; range < MAX_RELOC_RANGES; range++)
		if (reloc_range_exceptions[range].lo == 0)
			break;
	for (;;)
	{
		if (skip_space(batchptr) == 0)
		{
			illegal_delimiter();
			return;
		}
		lo = get_term(batchptr);
		c = skip_space(batchptr);
		/* another value? */
		if (c == 0 || c == ',')
		{
			if (exc >= MAX_RELOC_EXECPTIONS)
			{
				error_handler(0, table_exceeded_err);
				return;
			}
			reloc_exceptions[exc++] = lo;
			if (c == 0)
				return;
			(*batchptr)++;
			continue;
		}
		c = *(*batchptr)++;
		if (c != '.')
		{
			illegal_delimiter();
			return;
		}
		c = *(*batchptr)++;
		if (c != '.')
		{
			illegal_delimiter();
			return;
		}
		c = skip_space(batchptr);
		if (c == 0)
		{
			unexpected_eof();
			return;
		}
		hi = get_term(batchptr);
		if (hi < lo)
		{
			error_handler(0, range_err);
			return;
		}
		if (lo == hi)
		{
			if (exc >= MAX_RELOC_EXECPTIONS)
			{
				error_handler(0, table_exceeded_err);
				return;
			}
			reloc_exceptions[exc++] = lo;
		} else
		{
			if (range >= MAX_RELOC_RANGES)
			{
				error_handler(0, table_exceeded_err);
				return;
			}
			reloc_range_exceptions[range].lo = lo;
			reloc_range_exceptions[range].hi = hi;
			range++;
		}
		if (skip_space(batchptr) == 0)
			return;
		c = *(*batchptr)++;
		if (c != ',')
		{
			illegal_delimiter();
			return;
		}
	}
}

/*** ---------------------------------------------------------------------- ***/

/* process simple variable */
static void handle_variable(char **batchptr)
{
	++(*batchptr);
	variable = get_term(batchptr);
}

/*** ---------------------------------------------------------------------- ***/

/* PRINT command (/) */
static void handle_print(char **batchptr)
{
	int flag;
	int c;
	int c2;
	char *start;
	unsigned long value;
	char buf[40];
	char *ptr;
	
	++(*batchptr);
	prcrange();
	for (;;)
	{
		flag = 0;
		if ((c = skip_space(batchptr)) == 0)
		{
			illegal_delimiter();
			return;
		}
		switch (c)
		{
		case '\'':
		case '"':
			++(*batchptr);
			start = *batchptr;
			do
			{
				c2 = *(*batchptr)++;
				if (c2 == 0 || c2 == CR || c2 == LF)
				{
					illegal_delimiter();
					return;
				}
			} while (c2 != c);
			*--(*batchptr) = '\0';
			print_str(start);
			*(*batchptr)++ = c;
			break;
		case '$':
		case '&':
		case '%':
			flag = *(*batchptr)++;
			/* fall through */
		default:
			value = get_term(batchptr);
			switch (flag)
			{
			case '&':
			case '%':
				ptr = buf + sizeof(buf);
				*--ptr = '\0';
				if (value == 0)
				{
					*--ptr = '0';
				} else
				{
					while (value != 0)
					{
						*--ptr = value & 1 ? '1' : '0';
						value >>= 1;
					}
				}
				*--ptr = '%';
				print_str(ptr);
				break;
			case '$':
				print_str("$%08lx", value);
				break;
			default:
				print_str(".%ld", value);
				break;
			}
			break;
		}
		if (skip_space(batchptr) == 0)
			break;
		if (*(*batchptr)++ != ',')
		{
			illegal_delimiter();
			break;
		}
	}
	print_str(lf_text);
}

/*** ---------------------------------------------------------------------- ***/

/* specify output format */
static void handle_format(char **batchptr)
{
	int c;
	memaddr reloc;
	char *start;
	
	++(*batchptr);
	output_format = get_term(batchptr);
	
	if ((c = skip_space(batchptr)) != 0 && c != ',')
	{
		/* relocation address was specified */
		reloc = get_term(batchptr);
	} else
	{
		reloc = get_base();
	}
	write_var(var_reloc, reloc);
	machine_type = 0;
	if (skip_space(batchptr) == 0)
		return;
	if (*(*batchptr)++ != ',')
	{
		illegal_delimiter();
		return;
	}
	if (skip_space(batchptr) == 0)
	{
		unexpected_eof();
		return;
	}
	start = *batchptr;
	for (;;)
	{
		c = *(*batchptr)++;
		if (c == 0)
		{
			unexpected_eof();
			return;
		}
		if (ISLOWER(c))
			c = TOUPPER(c);
		if (!(c == '_' || ISUPPER(c) || (c >= '0' && c <= '9')))
			break;
	}
	*--(*batchptr) = 0;
	if (strcmp(start, "PAK3") == 0)
	{
		machine_type = 1;
		**batchptr = c;
		return;
	}
	**batchptr = c;
	error_handler(0, unknown_machine_err);
}

/*** ---------------------------------------------------------------------- ***/

/* read TOS */
static void handle_tos(char **batchptr)
{
	size_t length;
	size_t size;
	char filename[MAX_FILENAME];
	
	++(*batchptr);
	if (**batchptr == '*')
	{
		/* read TOS from ROM */
		prcrange();
		print_line(read_rom_text);
#ifndef __atarist__
		error_handler(0, no_read_rom_text);
#else
		{
			memaddr base;
			
			base = get_base();
			length = get_length();
			tos_buffer = xmalloc(length);
			max_length = length;
			memcpy(tos_buffer, (void *)base, length);
		}
#endif
	} else
	{
		/* read ROM from disk */
		prcrange();
		print_line(read_tos);
		length = get_length();
		tos_buffer = xmalloc(length);
		max_length = length;
		memset(tos_buffer, -1, length);
		if (getfilename(filename, batchptr) == 0)
		{
			unexpected_eof();
			return;
		}
		size = read_length(filename);
		if (size > length)
		{
			error_handler(0, tos_too_long_err);
			return;
		}
		read_file(filename, tos_buffer, size);
		if (size != length)
		{
			error_handler(ERR_QUEST|ERR_CONTINUE, tos_too_short_err);
		}
	}
}

/*** ---------------------------------------------------------------------- ***/

static unsigned long getbcd(unsigned long val, char **batchptr)
{
	unsigned char c;
	
	c = *(*batchptr)++;
	c -= '0';
	if (c > '9')
	{
		error_handler(0, wrong_date_err);
	} else
	{
		val <<= 4;
		val |= c;
	}
	return val;
}

/* compare TOS date */
static void handle_date(char **batchptr)
{
	unsigned long date;
	uint32_t *ptr;
	uint16_t country;
	uint16_t *ptr2;
	
	++(*batchptr);
	if (skip_space(batchptr) == 0)
	{
		unexpected_eof();
		return;
	}
	date = 0;
	/* parse day */
	date = getbcd(date, batchptr);
	date = getbcd(date, batchptr);
	if (skip_space(batchptr) == 0)
	{
		unexpected_eof();
		return;
	}
	if (*(*batchptr)++ != '.')
	{
		error_handler(0, wrong_date_err);
		return;
	}
	if (skip_space(batchptr) == 0)
	{
		unexpected_eof();
		return;
	}
	/* parse month */
	date = getbcd(date, batchptr);
	date = getbcd(date, batchptr);
	/* swap day & month (US format) */
	date = (date >> 8) | ((date & 0xff) << 8);
	if (skip_space(batchptr) == 0)
	{
		unexpected_eof();
		return;
	}
	if (*(*batchptr)++ != '.')
	{
		error_handler(0, wrong_date_err);
		return;
	}
	if (skip_space(batchptr) == 0)
	{
		unexpected_eof();
		return;
	}
	/* parse year */
	date = getbcd(date, batchptr);
	date = getbcd(date, batchptr);
	date = getbcd(date, batchptr);
	date = getbcd(date, batchptr);
	if (tos_buffer == NULL)
	{
		error_handler(0, tos_not_loaded_err);
		return;
	}
	ptr = (uint32_t *)(tos_buffer + 24);
	if (be32_to_cpu(*ptr) != date)
	{
		error_handler(ERR_QUEST|ERR_CONTINUE, wrong_tos_err);
	}
	/* country following? */
	if (skip_space(batchptr) == 0)
		return;
	if (*(*batchptr)++ != ',')
	{
		illegal_delimiter();
		return;
	}
	country = get_term(batchptr);
	ptr2 = (uint16_t *)(tos_buffer + 28);
	if ((((signed char)(be16_to_cpu(*ptr2) & 0xff)) >> 1) != country)
	{
		error_handler(ERR_QUEST|ERR_CONTINUE, wrong_country_err);
	}
}

/*** ---------------------------------------------------------------------- ***/

/* activate CRC calculation */
static void handle_crc(char **batchptr)
{
	++(*batchptr);
	write_var(var_crc, 1);
}

/*** ---------------------------------------------------------------------- ***/

/* process forced relocs */
static void handle_forced(char **batchptr)
{
	size_t i;
	memaddr value;
	
	++(*batchptr);
	/* search for end of table */
	for (i = 0; i < MAX_FORCED_RELOCS; i++)
		if (forced_table[i] == 0)
			break;
	for (;;)
	{
		if (skip_space(batchptr) == 0)
		{
			unexpected_eof();
			return;
		}
		value = get_term(batchptr);
		if (i >= MAX_FORCED_RELOCS)
		{
			error_handler(0, table_exceeded_err);
			return;
		}
		forced_table[i++] = value;
		if (skip_space(batchptr) == 0)
			return;
		if (*(*batchptr)++ != ',')
		{
			illegal_delimiter();
			return;
		}
	}
}

/******************************************************************************/
/*** ---------------------------------------------------------------------- ***/
/******************************************************************************/

/* _IFDEF/_IFNDEF command */
static bool do_ifdef(char **batchptr, bool flag)
{
	char *start;
	VAR *var;
	
	if (cond_flag != 0)
	{
		++nest_count;
	} else
	{
		if (skip_space(batchptr) == 0)
		{
			unexpected_eof();
		} else
		{
			start = *batchptr + 1;
			get_vname(batchptr);
			var = search_var(start);
			if (if_count >= MAX_IF)
			{
				error_handler(0, too_many_if_err);
			} else
			{
				if ((var != NULL) == flag)
				{
					if_stack[if_count++] = COND_IF;
				} else
				{
					if_stack[if_count++] = COND_ELSE;
					cond_flag = COND_IF;
				}
			}
		}
	}
	return false;
}

/*** ---------------------------------------------------------------------- ***/

/* _IFDEF command */
static bool cmd_ifdef(char **batchptr)
{
	return do_ifdef(batchptr, true);
}

/*** ---------------------------------------------------------------------- ***/

/* _IFNDEF command */
static bool cmd_ifndef(char **batchptr)
{
	return do_ifdef(batchptr, false);
}

/*** ---------------------------------------------------------------------- ***/

/* _IF command */
static bool cmd_if(char **batchptr)
{
	long val;
	
	if (cond_flag != 0)
	{
		++nest_count;
	} else
	{
		val = get_term(batchptr);
		if (val == 0)
		{
			if (if_count >= MAX_IF)
			{
				error_handler(0, too_many_if_err);
			} else
			{
				if_stack[if_count++] = COND_ELSE;
				cond_flag = COND_IF;
			}
		} else
		{
			if (val != 1)
			{
				error_handler(0, no_bool_err);
			} else
			{
				if (if_count >= MAX_IF)
				{
					error_handler(0, too_many_if_err);
				} else
				{
					if_stack[if_count++] = COND_IF;
				}
			}
		}
	}
	return false;
}

/*** ---------------------------------------------------------------------- ***/

/* _ELSE command */
static bool cmd_else(char **batchptr)
{
	UNUSED(batchptr);
	if (cond_flag != 0)
	{
		if (nest_count == 0)
		{
			if (if_count == 0 || if_stack[if_count - 1] != COND_ELSE)
			{
				error_handler(0, else_without_if_err);
			} else
			{
				cond_flag = 0;
			}
		}
	} else
	{
		if (if_count == 0 || if_stack[if_count - 1] != COND_IF)
		{
			error_handler(0, else_without_if_err);
		} else
		{
			cond_flag = COND_IF;
		}
	}
	return false;
}

/*** ---------------------------------------------------------------------- ***/

/* _ENDIF command */
static bool cmd_endif(char **batchptr)
{
	UNUSED(batchptr);
	if (cond_flag != 0)
	{
		if (nest_count != 0)
		{
			--nest_count;
			return false;
		}
		cond_flag = 0;
	}
	if (if_count == 0)
	{
		error_handler(0, endif_without_if_err);
	} else
	{
		--if_count;
		if (if_stack[if_count] != COND_IF && if_stack[if_count] != COND_ELSE)
			error_handler(0, endif_without_if_err);
	}
	return false;
}

/*** ---------------------------------------------------------------------- ***/

/* _SWITCH command */
static bool cmd_switch(char **batchptr)
{
	long value;
	
	if (cond_flag != 0)
	{
		++nest_count;
	} else
	{
		if (sw_count >= MAX_SW)
		{
			error_handler(0, too_many_sw_err);
		} else
		{
			value = get_term(batchptr);
			sw_stack[sw_count].cond_flag = COND_SWITCH;
			sw_stack[sw_count].value = value;
			sw_count++;
			cond_flag = COND_SWITCH;
		}
	}
	return false;
}

/*** ---------------------------------------------------------------------- ***/

/* _CASE command */
static bool cmd_case(char **batchptr)
{
	long swvalue;
	long value;
	bool found;
	bool match;
	int c;
	
	if (cond_flag == 0 || nest_count == 0)
	{
		if (sw_count == 0)
		{
			error_handler(0, case_without_switch_err);
			return false;
		}
		if (sw_stack[sw_count - 1].cond_flag == COND_DEFAULT)
		{
			error_handler(0, case_after_default_err);
			return false;
		}
		if (sw_stack[sw_count - 1].cond_flag != COND_CASE &&
			sw_stack[sw_count - 1].cond_flag != COND_SWITCH)
		{
			error_handler(0, case_without_switch_err);
			return false;
		}
		swvalue = sw_stack[sw_count - 1].value;
		found = false;
		do
		{
			value = get_term(batchptr);
			match = value == swvalue;
			found |= match;
		} while ((c = skip_space(batchptr)) != 0 && *(*batchptr)++ == ',');
		if (c != ':')
		{
			error_handler(0, no_colon_after_case_err);
			return false;
		}
		if (found)
		{
			sw_stack[sw_count - 1].cond_flag = COND_CASE;
			cond_flag = 0;
			return true;
		} else
		{
			cond_flag = COND_SWITCH;
		}
	}
	return false;
}

/*** ---------------------------------------------------------------------- ***/

/* _DEFAULT command */
static bool cmd_default(char **batchptr)
{
	if (cond_flag == 0 || nest_count == 0)
	{
		if (sw_count == 0)
		{
			error_handler(0, default_without_switch_err);
			return false;
		}
		if (*(*batchptr)++ != ':')
		{
			error_handler(0, no_colon_after_default_err);
			return false;
		}
		if (sw_stack[sw_count - 1].cond_flag == COND_DEFAULT)
		{
			error_handler(0, duplicate_default_err);
			return false;
		}
		if (sw_stack[sw_count - 1].cond_flag != COND_CASE)
		{
			if (sw_stack[sw_count - 1].cond_flag != COND_SWITCH)
			{
				error_handler(0, default_without_switch_err);
				return false;
			}
			sw_stack[sw_count - 1].cond_flag = COND_DEFAULT;
			cond_flag = 0;
			return true;
		} else
		{
			cond_flag = COND_SWITCH;
		}
	}
	return false;
}

/*** ---------------------------------------------------------------------- ***/

/* _ENDSWITCH command */
static bool cmd_endswitch(char **batchptr)
{
	UNUSED(batchptr);
	if (cond_flag != 0)
	{
		if (nest_count != 0)
		{
			--nest_count;
			return false;
		}
		cond_flag = 0;
	}
	if (sw_count == 0)
	{
		error_handler(0, endswitch_without_switch_err);
		return false;
	}
	--sw_count;
	if (sw_stack[sw_count].cond_flag != COND_CASE &&
		sw_stack[sw_count].cond_flag != COND_DEFAULT &&
		sw_stack[sw_count].cond_flag != COND_SWITCH)
	{
		error_handler(0, endswitch_without_switch_err);
		return false;
	}
	return false;
}

/*** ---------------------------------------------------------------------- ***/

/* _SELECT command */
static bool cmd_select(char **batchptr)
{
	if (skip_space(batchptr) == 0)
	{
		unexpected_eof();
		return false;
	}
	if (sel_count >= MAX_SEL)
	{
		error_handler(0, too_many_sel_err);
		return false;
	}
	sel_stack[sel_count++] = get_term(batchptr);
	return false;
}

/*** ---------------------------------------------------------------------- ***/

/* _ENDSELECT command */
static bool cmd_endselect(char **batchptr)
{
	UNUSED(batchptr);
	if (sel_count == 0)
	{
		error_handler(0, endselect_without_select_err);
		return false;
	}
	sel_count--;
	return false;
}

/*** ---------------------------------------------------------------------- ***/

/* _DEFINE command */
static bool cmd_define(char **batchptr)
{
	char *start;
	
	if (skip_space(batchptr) == 0)
	{
		unexpected_eof();
	} else
	{
		start = *batchptr + 1;
		get_vname(batchptr);
		write_var(start, 0);
	}
	return false;
}

/*** ---------------------------------------------------------------------- ***/

/* _UNDEF command */
static bool cmd_undef(char **batchptr)
{
	char *start;
	VAR *var;
	
	if (skip_space(batchptr) == 0)
	{
		unexpected_eof();
	} else
	{
		start = *batchptr + 1;
		get_vname(batchptr);
		var = search_var(start);
		if (var != NULL)
		{
			del_var(start);
		}
	}
	return false;
}

/*** ---------------------------------------------------------------------- ***/

/* _EVEN command */
static bool cmd_even(char **batchptr)
{
	bool fill;
	long value;
	int c;
	
	fill = false;
	value = 0;
	if ((c = skip_space(batchptr)) != 0)
	{
		if (c == '$')
			++(*batchptr);
		fill = true;
		value = get_term(batchptr);
	}
	if (current_addr & 1)
	{
		if (current_addr + 1 > max_length)
		{
			illegal_offset();
			return false;
		}
		current_addr++;
		if (fill)
		{
			if (tos_buffer == NULL)
			{
				error_handler(0, tos_not_loaded_err);
				return false;
			}
			tos_buffer[current_addr - 1] = (char)value;
			ckrange(current_addr - 1, 1);
		}
	}
	return false;
}

/*** ---------------------------------------------------------------------- ***/

/* _FILL command */
static bool cmd_fill(char **batchptr)
{
	int c;
	memaddr lo;
	memaddr hi;
	memaddr base;
	memaddr len;
	bool noupdate;
	memaddr save_current_addr;
	memaddr filllen;
	char patches[32];
	char *ptr;
	char *src;
	memaddr i;
	
	if ((c = skip_space(batchptr)) == 0)
	{
		unexpected_eof();
		return false;
	}
	lo = get_term(batchptr);
	if (lo >= max_length)
	{
		base = get_base();
		if (lo < base || lo >= base + max_length)
		{
			illegal_offset();
			return false;
		}
		lo -= base;
	}
	if ((c = skip_space(batchptr)) == 0)
	{
		unexpected_eof();
		return false;
	}
	c = *(*batchptr)++;
	if (c != ',')
	{
		illegal_delimiter();
		return false;
	}
	if ((c = skip_space(batchptr)) == 0)
	{
		unexpected_eof();
		return false;
	}
	hi = get_term(batchptr);
	if (hi >= max_length)
	{
		base = get_base();
		if (hi < base || hi >= base + max_length)
		{
			illegal_offset();
			return false;
		}
		hi -= base;
	}
	if ((c = skip_space(batchptr)) == 0)
	{
		unexpected_eof();
		return false;
	}
	c = *(*batchptr)++;
	if (c != ',')
	{
		illegal_delimiter();
		return false;
	}
	if ((c = skip_space(batchptr)) == 0)
	{
		unexpected_eof();
		return false;
	}
	if (lo > hi)
	{
		error_handler(0, range_err);
		return false;
	}
	len = hi - lo;
	if (len == 0)
		return false;
	
	noupdate = c == '|';
	if (noupdate)
		(*batchptr)++;
	save_current_addr = current_addr;
	if ((c = skip_space(batchptr)) == 0)
	{
		unexpected_eof();
		return false;
	}
	if ((filllen = read_patches(batchptr, patches, sizeof(patches))) <= 0)
	{
		error_handler(0, too_many_fill_err);
		return false;
	}
	if (noupdate)
		current_addr = save_current_addr;
	ckrange(lo, len);
	if (tos_buffer == NULL)
	{
		error_handler(0, tos_not_loaded_err);
		return false;
	}
	ptr = tos_buffer + lo;
	while (len != 0)
	{
		src = patches;
		i = filllen;
		for (i = filllen; --i >= 0 && len != 0; )
		{
			*ptr++ = *src++;
			len--;
		}
	}
	return false;
}

/*** ---------------------------------------------------------------------- ***/

/* _ERROR command */
static bool cmd_error(char **batchptr)
{
	char c;
	char delim;
	char *start;
	
	prcrange();
	if (skip_space(batchptr) == 0)
	{
		/* ERROR message without additional text */
		error_handler(0, error_cmd_err);
	} else
	{
		c = *(*batchptr)++;
		if (c != '\'' && c != '"')
		{
			illegal_delimiter();
		} else
		{
			print_line(error_txt);
			start = *batchptr;
			delim = c;
			do
			{
				c = *(*batchptr)++;
				if (c == 0 || c == CR || c == LF)
				{
					unexpected_eof();
					return false;
				}
			} while (c != delim);
			*--(*batchptr) = '\0';
			user_error(start);
			**batchptr = c;
		}
	}
	return false;
}

/*** ---------------------------------------------------------------------- ***/

static struct {
	const char *name;
	int cond_flag;
	bool (*handler)(char **batchptr);
} const com_tab[] = {
	{ "IFDEF", COND_IF, cmd_ifdef },
	{ "IFNDEF", COND_IF, cmd_ifndef },
	{ "IF", COND_IF, cmd_if },
	{ "ELSE", COND_IF, cmd_else },
	{ "ENDIF", COND_IF, cmd_endif },
	{ "SWITCH", COND_SWITCH, cmd_switch },
	{ "CASE", COND_SWITCH, cmd_case },
	{ "DEFAULT", COND_SWITCH, cmd_default },
	{ "ENDSWITCH", COND_SWITCH, cmd_endswitch },
	{ "SELECT", 0, cmd_select },
	{ "ENDSELECT", 0, cmd_endselect },
	{ "DEFINE", 0, cmd_define },
	{ "UNDEF", 0, cmd_undef },
	{ "EVEN", 0, cmd_even },
	{ "FILL", 0, cmd_fill },
	{ "ERROR", 0, cmd_error },
};

/* parse directives starting with '_' */
static bool parse_directive(char **batchptr)
{
	char cmd[16];
	int i;
	int c;
	
	(*batchptr)++;
	i = 0;
	for (;;)
	{
		c = *(*batchptr)++;
		if (c == 0)
		{
			unexpected_eof();
			return false;
		}
		if (ISLOWER(c))
			c = TOUPPER(c);
		if (!(c == '_' || ISUPPER(c) || (c >= '0' && c <= '9')))
			break;
		if (i < 15)
		{
			cmd[i++] = c;
		}
	}
	(*batchptr)--;
	cmd[i] = '\0';
	
	for (i = 0; i < (int)ARRAY_SIZE(com_tab); i++)
	{
		if (strcmp(cmd, com_tab[i].name) == 0)
		{
			if (cond_flag != 0 && com_tab[i].cond_flag != cond_flag)
				return false;
			return com_tab[i].handler(batchptr);
		}
	}
	error_handler(0, illegal_cmd_err);
	return false;
}

/******************************************************************************/
/*** ---------------------------------------------------------------------- ***/
/******************************************************************************/

void parse_buffer(char *batchptr)
{
	int c;
	
	lineno = 1;
	cond_flag = 0;
	nest_count = 0;
	if_count = 0;
	sw_count = 0;
	sel_count = 0;
	
	for (;;)
	{
	nextline:
		if ((c = skip_space(&batchptr)) != 0)
		{
			if (c == '_')
			{
				if (parse_directive(&batchptr))
					goto nextline;
			} else if (cond_flag == 0)
			{
				goto handle_cmd;
			}
		}
		
		/* find next start of line */
		for (;;)
		{
			do
			{
				c = (unsigned char)*batchptr++;
				if (c == 0)
				{
					/* end of batch file */
					if (if_count != 0)
						error_handler(ERR_NOLINENO, missing_endif_err);
					if (sw_count != 0)
						error_handler(ERR_NOLINENO, missing_endswitch_err);
					if (sel_count != 0)
						error_handler(ERR_NOLINENO, missing_endselect_err);
					if (filenr == 0)
						prrange();
					return;
				}
			} while (c != LF);
			++lineno;
			break;
		handle_cmd:
			
			switch (c)
			{
			case '.':
				/* evaluate lines starting with '.' */
				if (handle_dot(&batchptr))
					goto nextline;
				break;
			case '-':
				handle_chdir(&batchptr);
				break;
			case '+':
				handle_batch(&batchptr);
				break;
			case '!':
				handle_relocs(&batchptr);
				break;
			case '#':
				handle_variable(&batchptr);
				break;
			case '/':
				handle_print(&batchptr);
				break;
			case '>':
				handle_format(&batchptr);
				break;
			case '<':
				handle_tos(&batchptr);
				break;
			case '=':
				handle_date(&batchptr);
				break;
			case 0xdd: /* Atari paragraph sign */
				handle_crc(&batchptr);
				break;
			case 0xc2:
				if ((unsigned char)batchptr[1] == 0xa7)
				{
					/* utf8 sequence of paragraph sign */
					++batchptr;
					handle_crc(&batchptr);
				} else
				{
					if (handle_patch(&batchptr))
						goto nextline;
				}
				break;
			case '?':
				handle_forced(&batchptr);
				break;
			default:
				if (handle_patch(&batchptr))
					goto nextline;
				break;
			}
		}
	}
}
