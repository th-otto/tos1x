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

RSHDR *gemptr;		/* GEM's rsc pointer        */
RSHDR *deskptr;		/* DESKTOP'S rsc pointer    */
char *infptr;
uint16_t infsize;
uint16_t gemsize;
uint16_t desksize;
VOIDPTR gl_pglue;
BOOLEAN nodesk;		/* desk.rsc already read in ? */
BOOLEAN nogem;		/* gem.rsc already read in ? */

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


/*
 * do this whenever the Gem or desktop is ready
 */
/* 206de: 00e1c7de */
/* 306de: 00e20244 */
/* 104de: 00fe76de */
/* 106de: 00e29fd0 */
int16_t rom_ram(P(int) which, P(intptr_t) pointer)
PP(int which;)
PP(register intptr_t pointer;)
{
	int16_t size;
	register BOOLEAN doit;

	if (which == 3)						/* read in desktop.inf      */
	{
		LBCOPY((VOIDPTR)pointer, infptr, infsize);
		return infsize;
	}

	rs_global = pointer;
	doit = TRUE;

	if (!which)
	{
		/* read in gem rsc */
		if (nogem)
			doit = FALSE;
		else
			nogem = TRUE;				/* already read in      */

		rs_hdr = gemptr;
		size = gemsize;
	} else
	{
		/* read in desktop rsc */
		if (nodesk)
			doit = FALSE;
		else
			nodesk = TRUE;

		rs_hdr = deskptr;
		size = desksize;
	}


	LLSET(pointer + 14, rs_hdr);
	LWSET(pointer + 18, size);

	if (doit)
	{
		do_rsfix((intptr_t)rs_hdr, size);
		rs_fixit(pointer);
	}
#if !BINEXACT
	/* BUG: no return here */
	return size;
#endif
}


/* 306de: 00e20316 */
/* 104de: 00fe779c */
/* 106de: 00e2a0a2 */
VOID rsc_free(NOTHING)
{
	dos_free(gl_pglue);
	gemptr = NULL;
	deskptr = NULL;
	/* infptr should also be nullified, just in case... */
}


/*
 * Read in the resource file
 */
/* 206de: 00e1c8d0 */
/* 306de: 00e20336 */
/* 104de: 00fe77b6 */
/* 106de: 00e2a0c2 */
BOOLEAN rsc_read(NOTHING)
{
	register const uint16_t *intptr;
	uint16_t size;
	const char *a;
	char *b;
	int32_t value;
	int16_t code;
	short unused;
	
	/* copy rsc to ram */
	intptr = tosrsc;

	gl_pglue = dos_alloc((int32_t) intptr[2]);
	if (!gl_pglue)
	{
		Cconws("Unable to install resource !");
		while (!Bconstat(2))
			;
#if BINEXACT
		/* BUG: no return value here */
		return;
#else
		return FALSE;
#endif
	}

	LBCOPY(gl_pglue, tosrsc, intptr[2]);

	UNUSED(size);
	UNUSED(a);
	UNUSED(b);
	UNUSED(value);
	UNUSED(code);
	UNUSED(unused);
	
	intptr = (const uint16_t *)gl_pglue;
	gemptr = (RSHDR *) ((char *)gl_pglue + 10);	/* now fix the resource   */
	deskptr = (RSHDR *) ((char *)gl_pglue + (intptr_t)intptr[0]);
	infptr = (char *) ((char *)gl_pglue + (intptr_t)intptr[1]);
	gemsize = intptr[0];    /* BUG: that includes the size of the GLUE header */
	desksize = intptr[1] - intptr[0];
	infsize = intptr[2] - intptr[1];

	nodesk = FALSE;
	nogem = FALSE;

#if !BINEXACT
	/* BUG: no return value here */
	return TRUE;
#endif
}
