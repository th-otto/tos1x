/*  umem.c - user memory management interface routines			*/
/*  xmalloc, xsetblk						*/


#include "tos.h"
#include "fs.h"
#include "bios.h"
#include "mem.h"
#include <toserrno.h>

/*
 *  STATIUMEM - cond comp; set to true to count calls to these routines
 */

#define	STATIUMEM	FALSE

#ifndef	DBGIUMEM
#define	DBGIUMEM	0
#endif


#if GEMDOS >= 0x15
/*
 * xminit - initialize memory descriptors.
 */

/* 306de: 00e1800c */
/* 306us: 00e17fb2 */
/* 104de: 00fc8972 */
/* 106de: 00e08b42 */
VOID xminit(NOTHING)
{
	Getmpb(&pmd);

#if ALTRAM_SUPPORT
	{
		register MD *q;
		register MD *unused;
		register intptr_t start;
		register intptr_t am;
		
		UNUSED(unused);
		for (q = pmd.mp_mfl; q != NULL; q = q->m_link)
		{
			start = q->m_start;
			if ((start &= 0x0)) /* ??? */
			{
				am = 2;
				am -= start;
				q->m_start += am;
				q->m_length -= am;
			}
			q->m_length = q->m_length & ~1L;
			if (q->m_length < 0)
				q->m_length = 0;
		}
	}
#endif
}
#endif


/* 306de: 00e183fe */
/* 306us: 00e183a4 */
/* 104de: 00fc8cac */
#if GEMDOS >= 0x15
VOID xmakeres(P(PD *) p)
PP(PD *p;)
{
	register MD *m, **q;

	for (m = *(q = &pmd.mp_mal); m; )
	{
		if (m->m_own == p)
		{
			m = m->m_link;
			*q = m;
		} else
		{
			q = &m->m_link;
			m = *q;
		}
	}
}
#endif


/*
 *   for each item in the allocated list that is owned by 'r', 
 *  free it
 */

#if GEMDOS >= 0x18
/* 306de: 00e1847c */
/* 306us: 00e18422 */
VOID xmfreall(P(PD *) r)
PP(PD *r;)
{
	register MD *m, **q;

	for (m = *(q = &pmd.mp_mal); m; )
	{
		if (m->m_own == r)
		{
			*q = m->m_link;
			freeit(m, &pmd);
			m = *q;
		} else
		{
			q = &m->m_link;
			m = *q;
		}
	}
}
#endif


#if GEMDOS >= 0x15
/* 306de: 00e184be */
/* 306us: 00e18464 */
/* 104de: 00fc8ce0 */
VOID xmsetown(P(VOIDPTR) paddr, P(PD *) own)
PP(VOIDPTR paddr;)
PP(PD *own;)
{
	register MD *q;
	register VOIDPTR addr;
	
	addr = paddr;
	for (q = pmd.mp_mal; q != NULL; q = q->m_link)
	{
		if ((intptr_t)addr == (q->m_start
#if ALTRAM_SUPPORT
			& ~M_ALTFLAG
#endif
			))
		{
			q->m_own = own;
			return;
		}
	}
}
#endif


/* 306de: 00e18570 */
/* 306us: 00e18516 */
/* 104de: 00fc8d12 */
/* 106de: 00e08ee2 */
#if GEMDOS >= 0x15
static VOID printstr PROTO((const char *str));

VOID foldermsg(NOTHING)
{
	printstr("\033H*** OUT OF INTERNAL MEMORY:\033K\r\n*** USE FOLDR100.PRG TO GET MORE.\033K\r\n\033K\n\033K\n*** SYSTEM HALTED ***\033K");
	for (;;) ;
}


static VOID printstr(P(const char *) str)
PP(const char *str;)
{
	while (*str)
	{
#if BINEXACT
		trap13(0x00030002L, *str);
#else
		Bconout(2, *str);
#endif
		str++;
	}
}
#endif
