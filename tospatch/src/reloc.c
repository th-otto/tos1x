#include "tospatch.h"
#include "s_endian.h"

uint32_t reloc_exceptions[MAX_RELOC_EXECPTIONS + 1];
struct reloc_range reloc_range_exceptions[MAX_RELOC_RANGES + 1];
uint32_t forced_table[MAX_FORCED_RELOCS + 1];

/******************************************************************************/
/*** ---------------------------------------------------------------------- ***/
/******************************************************************************/

void lognl(void)
{
	do_addr = false;
	if (lastaddr != 0)
		print_str(lf_text);
}

/*** ---------------------------------------------------------------------- ***/

void clraddr(void)
{
	if (addrflag)
	{
		do_addr = true;
		lastaddr = 0;
	}
}

/*** ---------------------------------------------------------------------- ***/

static void logaddr(memaddr addr)
{
	if (do_addr)
	{
		if (lastaddr == 0)
		{
			print_line(log_reloc);
		} else
		{
			print_str(comma_text);
		}
		print_str("$%08lx", (long)addr);
		lastaddr = (lastaddr + 1) & 7;
		if (lastaddr == 0)
			print_str(lf_text);
	}
}

/*** ---------------------------------------------------------------------- ***/

/* sort the reloc tables */
static void optimize(void)
{
	uint32_t *reloc_ptr;
	uint32_t addr;
	struct reloc_range *range_ptr;
	
	/*
	 * sort the reloc_exceptions
	 */
	reloc_ptr = reloc_exceptions;
	if (*reloc_ptr++ != 0)
	{
		uint32_t *ptr;
		uint32_t addr2;
		
		for (;;)
		{
			if ((addr = *reloc_ptr) == 0)
				break;
			ptr = reloc_ptr;
			for (;;)
			{
				if (ptr == reloc_exceptions)
					break;
				addr2 = *--ptr;
				ptr[1] = addr2;
				if (addr >= addr2)
					break;
			}
			ptr[1] = addr;
			reloc_ptr++;
		}
	}
	
	/*
	 * sort the reloc_range_exceptions
	 */
	range_ptr = reloc_range_exceptions;
	if (range_ptr->lo != 0)
	{
		struct reloc_range *ptr;
		struct reloc_range *ptr2;
		uint32_t hi;
		uint32_t lo2, hi2;
		
		range_ptr++;
		for (;;)
		{
			if ((addr = range_ptr->lo) == 0)
				break;
			hi = range_ptr->hi;
			ptr = range_ptr;
			for (;;)
			{
				if (ptr == reloc_range_exceptions)
					break;
				--ptr;
				lo2 = ptr->lo;
				hi2 = ptr->hi;
				ptr[1].lo = lo2;
				ptr[1].hi = hi2;
				if (lo2 > hi)
					continue;
				if (addr >= hi2)
					break;
				/* delete entry */
				ptr2 = range_ptr;
				do
				{
					ptr2->lo = ptr2[1].lo;
					ptr2->hi = ptr2[1].hi;
					ptr2++;
				} while (ptr2->lo != 0);
				if (lo2 >= addr)
				{
					if (hi2 > hi)
						hi = hi2;
				} else if (hi2 >= hi)
				{
					addr = lo2;
					hi = hi2;
				} else
				{
					addr = lo2;
				}
			}
			ptr[1].lo = addr;
			ptr[1].hi = hi;
			range_ptr++;
		}
	}
}

/*** ---------------------------------------------------------------------- ***/

/* relocate the TOS */
static void reloc(void)
{
	uint32_t base;
	uint32_t baseend;
	memaddr length;
	char *buffer;
	uint16_t *ptr;
	uint16_t *end;
	uint16_t val;
	uint32_t *reloc_ptr;
	uint32_t reloc_exc;
	struct reloc_range *range_ptr;
	uint32_t range_exc;
	
	base = get_base();
	length = get_length();
	baseend = base + length;
	buffer = tos_buffer;
	ptr = (uint16_t *)buffer;
	end = (uint16_t *)(buffer + length);
	reloc_ptr = reloc_exceptions;
	reloc_exc = *reloc_ptr++;
	range_ptr = reloc_range_exceptions;
	range_exc = range_ptr->lo;
	
	for (;;)
	{
	nextval:
		val = be16_to_cpu(*ptr);
		ptr++;
		if (ptr >= end)
			break;
		if ((((char *)ptr - buffer) & 0xffffl) == 0)
		{
			if (!do_addr)
				print_point();
		}
		/* check for bsr, bra and dbcc */
		if ((val & 0xf0ff) != 0x6000 &&
			(val & 0xf0f8) != 0x50c8)
		{
			uint32_t addr;
			uint32_t offset;
			uint32_t *pp;
			
			addr = val;
			addr <<= 16;
			addr |= be16_to_cpu(*ptr);
			if (addr < base || addr >= baseend)
				continue;
			offset = ((char *)ptr - 2 - buffer);
			
			for (;;)
			{
				if (reloc_exc > offset)
					break;
				if (reloc_exc == offset)
					goto nextval;
				reloc_exc = *reloc_ptr++;
				if (reloc_exc == 0)
				{
					reloc_exc = 0xfffffffful;
					break;
				}
			}
			for (;;)
			{
				if (range_exc > offset)
					break;
				if (offset < range_ptr->hi)
					goto nextval;
				range_ptr++;
				range_exc = range_ptr->lo;
				if (range_exc == 0)
				{
					range_exc = 0xfffffffful;
					break;
				}
			}
			addr -= base;
			addr += get_reloc_addr();
			pp = (uint32_t *)(ptr - 1);
			*pp = cpu_to_be32(addr);
			logaddr((char *)pp - buffer);
		}
		ptr++;
		if (ptr >= end)
			break;
		if ((((char *)ptr - buffer) & 0xffffl) == 0)
		{
			if (!do_addr)
				print_point();
		}
	}
}

/*** ---------------------------------------------------------------------- ***/

/* relocate single addresses */
static void forced_reloc(void)
{
	uint32_t *reloc_ptr;
	uint32_t diff;
	uint32_t offset;
	uint32_t *pp;
	char *buffer;
	
	diff = get_base() - get_reloc_addr();
	reloc_ptr = forced_table;
	buffer = tos_buffer;
	while ((offset = *reloc_ptr++) != 0)
	{
		logaddr(offset);
		pp = (uint32_t *)(buffer + offset);
		*pp = cpu_to_be32(be32_to_cpu(*pp) - diff);
	}
}

/*** ---------------------------------------------------------------------- ***/

void reloc_it(void)
{
	long reloc_addr;
	
	if (get_base() != (reloc_addr = get_reloc_addr()))
	{
		print_line(reloc_text, reloc_addr);
		clraddr();
		if (do_addr)
			print_str(lf_text);
		optimize();
		reloc();
		forced_reloc();
		if (do_addr)
			print_str(lf_text);
		lognl();
	}
}
