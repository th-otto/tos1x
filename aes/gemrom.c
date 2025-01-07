/*
 *************************************************************************
 *			Revision Control System
 * =======================================================================
 *  $Author: mui $	$Date: 89/04/26 18:26:27 $
 * =======================================================================
 *
 * Revision 2.2  89/04/26  18:26:27  mui
 * TT
 * 
 * Revision 2.1  89/02/22  05:29:13  kbad
 * *** TOS 1.4  FINAL RELEASE VERSION ***
 * 
 * Revision 1.5  88/11/01  18:02:04  kbad
 * Revamped PRG define
 * 
 * Revision 1.4  88/10/03  12:08:52  kbad
 * New build obsoletes ROM/IMG/PRG changes.
 * 
 * Revision 1.3  88/09/22  04:49:08  kbad
 * Added "tosrsc" label of inline linked resource
 * 
 * Revision 1.2  88/09/08  18:59:25  kbad
 * added <flavor.h> for prg/img/rom flag
 * 
 * Revision 1.1  88/06/02  12:34:59  lozben
 * Initial revision
 * 
 *************************************************************************
 */
/*	NEW	GEMROM.C	01/11/88 - 1/19/88	Derek Mui	*/
/*	Look for TOS.RSC and read in GEM.RSC,DESKTOP.RSC,DESKTOP.INF	*/
/*	Make sure you set the switches right at machine.h		*/
/*	Change at rsc_read do_cdir	1/28/88		D.Mui		*/
/*	Change at rsc_read for TOS and ROM system 3/11/88		*/
/*	Incorporated all the resources together	7/14/92	D.Mui		*/
/*	Chnage the rsc table and time code format 7/16/92	D.Mui	*/

#include "aes.h"
#include "gemlib.h"
#include "taddr.h"

struct rominfo {
	VOIDPTR data;
	uint16_t size;
};

/*
 * info about compiled in data
 * - 0: aes rsc
 * - 1: desktop rsc
 * - 2: 
 * - 3: desktop.inf
 * - 4:
 */
struct rominfo romdata[6];

BOOLEAN havedesk;		/* desk.rsc already read in ? */
BOOLEAN havegem;		/* gem.rsc already read in ? */
BOOLEAN havefmt;		/* fmt.rsc already read in ? */

#if (OS_COUNTRY == CTRY_DE) | (OS_COUNTRY == CTRY_FR) | (OS_COUNTRY == CTRY_IT) | (OS_COUNTRY == CTRY_ES) | (OS_COUNTRY == CTRY_SG) | (OS_COUNTRY == CTRY_SF) | (OS_COUNTRY == CTRY_MX) | (OS_COUNTRY == CTRY_TR) | (OS_COUNTRY == CTRY_DK) | (OS_COUNTRY == CTRY_CZ)
#define EUROTIME 1		/*			European Style       */
#define EURODATE 1		/*			Date/TimeFlag	     */
#endif

#if (OS_COUNTRY == CTRY_UK) | (OS_COUNTRY == CTRY_NL)
#define EUROTIME 0
#define EURODATE 1
#endif

#if (OS_COUNTRY == CTRY_US)
#define EUROTIME 0
#define EURODATE 0
#endif

#if (OS_COUNTRY == CTRY_SE) | (OS_COUNTRY == CTRY_NO) | (OS_COUNTRY == CTRY_FI)
#define EUROTIME 1
#define SWEDDATE 1
#endif

extern uint16_t const tosrsc[];

#define Cconws(a) trap(9, a)
#define Bconstat(a) (int)trp13(1, a)


#if OS_COUNTRY == CTRY_DE
#define TOS_RSSIZE 0x44E0
#endif

#if OS_COUNTRY == CTRY_FR
#define TOS_RSSIZE 0x47FA
#endif

/*
 * Read in the resource data
 */
/* 100us: 00fee800 */
/* 100fr: 00fee79c */
/* 100de: 00fee4b0 */
/*
 * glue header is an array of 5 unsigned shorts.
 * Each is an offset from the filestart.
 *
 * tosrsc[0] = offset to start of desktop resource header
 * tosrsc[1] = offset to start of unknown resource
 * tosrsc[2] = offset to start of desktop.inf
 * tosrsc[3] = offset to start of format resource
 * tosrsc[4] = offset to start of unknown data
 * The gem resource header follows those fields.
 * The total size is not part of the header, and hardcoded above.
 */
VOID rsc_read(NOTHING)
{
	register uint16_t *intptr;
	int i;

	/* copy rsc to ram */
	intptr = dos_alloc((int32_t) TOS_RSSIZE);
	/* BUG: no malloc check */
	/* BUG: leaked on resolution change */

	LBCOPY(intptr, tosrsc, TOS_RSSIZE);

	/* now fix the resource */
	/* first block (aes rsc) starts right after the header */
	romdata[0].data = (RSHDR *) (intptr + 5);
	romdata[0].size = intptr[0] - 5;
	for (i = 1; i < 4; i++)
	{
		/* calculate start address */
		romdata[i].data = intptr + intptr[i - 1] / 2;
		/* size is difference between the 2 offsets */
		romdata[i].size = intptr[i] - intptr[i - 1];
	}
	romdata[4].data = romdata[2].data;
	romdata[4].size = romdata[2].size;
	romdata[5].data = intptr + intptr[3] / 2;
	romdata[5].size = intptr[4] - intptr[3];
	
	havedesk = TRUE;
	havefmt = TRUE;
	havegem = TRUE;

	/* BUG: no return value here */
}


int16_t desk_global[15];
int16_t fmt_global[15];
int16_t gem_global[15];

/*
 * do this whenever the Gem or desktop is ready
 */
/* 206de: 00e1c7de */
/* 306de: 00e20244 */
/* 104de: 00fe76de */
/* 106de: 00e29fd0 */
int16_t rom_ram(P(int) which, P(intptr_t) pointer, P(uint16_t) offset)
PP(register int which;)
PP(register intptr_t pointer;)
PP(register uint16_t offset;)
{
	register intptr_t data;
	register int16_t size;
	int doit;
	
	data = (intptr_t)romdata[which].data;
	size = romdata[which].size;
	
	if (which == 3)						/* read in desktop.inf      */
	{
		LBCOPY((VOIDPTR)pointer, (VOIDPTR)data, size);
		return size;
	} else if (which == 2)
	{
		LBCOPY((VOIDPTR)pointer, (VOIDPTR)data, offset);
		return offset;
	} else if (which == 4)
	{
		LBCOPY((VOIDPTR)pointer, data + offset, size - offset);
		return size - offset;
	} else if (which < 2 || which == 5)
	{
		doit = FALSE;
		if (which == 0 && havegem == TRUE)
		{
			doit = TRUE;
			havegem = FALSE;
		}
		if (which == 1 && havedesk == TRUE)
		{
			doit = TRUE;
			havedesk = FALSE;
		}
		if (which == 5 && havefmt == TRUE)
		{
			doit = TRUE;
			havefmt = FALSE;
		}
		
		if (doit)
		{
			rs_global = pointer;
			rs_hdr = (RSHDR *)data;
			do_rsfix(data, size);
			
			if (which == 1 || which == 5)
			{
				if (which == 1)
					LWCOPY(desk_global, pointer, 15);
				else
					LWCOPY(fmt_global, pointer, 15);
				rs_fixit(pointer);
			} else
			{
				LWCOPY(gem_global, pointer, 15);
			}
		}
		
		if (which == 1)
		{
			LWCOPY(pointer, desk_global, 15);
			/* ZZZ some code todo here */
		} else if (which == 5)
		{
			LWCOPY(pointer, fmt_global, 15);
		} else
		{
			LWCOPY(pointer, gem_global, 15);
		}
	}

#ifndef __ALCYON__
	/* BUG: no return here */
	return size;
#endif
}
