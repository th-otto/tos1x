/*  umem.c - user memory management interface routines			*/
/*  xmalloc, xsetblk						*/


#ifndef	DBGUMEM
#define	DBGUMEM	0
#endif

#include "tos.h"
#include "fs.h"
#include "bios.h"
#include "mem.h"
#include <toserrno.h>

#if ALTRAM_SUPPORT
/*
 * value ORed to the start address for blocks
 * allocated from alt mem
 */
#define M_ALTFLAG 1L
#endif


/*
 *  STATIUMEM - cond comp; set to true to count calls to these routines
 */

#define	STATIUMEM	FALSE

#ifndef	DBGIUMEM
#define	DBGIUMEM	0
#endif


#if	STATIUMEM

long ccffit = 0;

long ccfreeit = 0;

#endif

static VOID printstr PROTO((const char *str));


/*
 * xminit - initialize memory descriptors.
 */

/* 306de: 00e1800c */
/* 306us: 00e17fb2 */
/* 104de: 00fc8972 */
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


#if ALTRAM_SUPPORT
/* 306de: 00e1806c */
/* 306us: 00e18012 */
static int32_t xmfsize(P(MPB *) mp, P(int16_t) mode)
PP(MPB *mp;)
PP(int16_t mode;)
{
	register int32_t maxval;
	register MD *q;
	
	maxval = 0;
	q = mp->mp_mfl;
	while (q != NULL)
	{
		if ((mode == MX_STRAM) && (q->m_start & M_ALTFLAG))
			break;
		if ((mode != MX_TTRAM) || (q->m_start & M_ALTFLAG))
		{
			if (q->m_length > maxval)
				maxval = q->m_length;
		}
		q = q->m_link;
	}
	return maxval;
}
#endif


/* 306de: 00e180b8 */
/* 306us: 00e1805e */
/* 104de: 00fc898a */
#if ALTRAM_SUPPORT
MD *ffit(P(long) amount, P(MPB *) mp, P(int16_t) mode)
PP(long amount;)
PP(MPB *mp;)
PP(int16_t mode;)
{
	register MD *q;
	register MD *p;
	register MD *p1;
	MD *q1;
	register BOOLEAN altflag;

#if	STATIUMEM
	++ccffit;
#endif

	p = (MD *)mp;
	if ((q = ((MPB *)p)->mp_mfl) == NULL)		/* get free list pointer */
	{
#if	DBGIUMEM
		kprintf("ffit: null rover\n");
#endif
		return NULL;
	}

	if (amount <= 0)
		return NULL;
	amount = (amount + 1) & ~1;
	
	altflag = TRUE;
	switch (mode)
	{
	case MX_STRAM:
		altflag = FALSE;
	case MX_TTRAM:
		while (q != NULL && (q->m_length < amount || (q->m_start & M_ALTFLAG) != altflag))
		{
			p = q;
			q = p->m_link;
		}
		if (q == NULL)
			return NULL;
		break;
	case MX_PSTRAM:
	case MX_PTTRAM:
		while (q != NULL && q->m_length < amount)
		{
			p = q;
			q = p->m_link;
		}
		if (q == NULL)
			return NULL;
		if ((q->m_start & M_ALTFLAG) || mode == MX_PSTRAM)
			break;
		q1 = q;
		p1 = p;
		while (q != NULL && !(q->m_start & M_ALTFLAG))
		{
			p = q;
			q = p->m_link;
		}
		while (q != NULL && q->m_length < amount)
		{
			p = q;
			q = p->m_link;
		}
		if (q == NULL)
		{
			q = q1;
			p = p1;
		}
		break;
	}

	if (q->m_length == amount)
	{
		/* take the whole thing */
		p->m_link = q->m_link;
	} else
	{							/* break it up - 1st allocate a new
								   MD to describe the remainder */
		/*********** TBD **********
		*  Nicer Handling of This *
		*         Situation       *
		**************************/
		if ((q1 = mgetmd()) == NULL)
		{
#if	DBGIUMEM
			kprintf("ffit: Null Mget\n");
#endif
			return NULL;
		}

		/*  init new MD  */

		q1->m_length = q->m_length - amount;
		q1->m_start = q->m_start + amount;
		q1->m_link = q->m_link;

		/*  adjust allocated block  */

		q->m_length = amount;
		p->m_link = q1;
	}

	/*  link allocate block into allocated list,
	   mark owner of block, & adjust rover  */

	q->m_link = mp->mp_mal;
	mp->mp_mal = q;

	q->m_own = run;

	return q;					/* got some */
}

#else

MD *ffit(P(long) amount, P(MPB *) mp)
PP(long amount;)
PP(MPB *mp;)
{
	register MD *q;
	register MD *p;
	register MD *q1;
	register BOOLEAN getmax;
	register int32_t maxval;
	
#if	STATIUMEM
	++ccffit;
#endif

	p = mp->mp_rover;
	maxval = 0;
	if (p == NULL)		/* get free list pointer */
	{
#if	DBGIUMEM
		kprintf("ffit: null rover\n");
#endif
		return NULL;
	}

	if (amount == -1)
	{
		getmax = TRUE;
	} else
	{
		getmax = FALSE;
	}

	q = p->m_link;
	do
	{
		if (q == NULL)
		{
			p = (MD *)mp;
			q = p->m_link;
		}
	
		if (!getmax && q->m_length >= amount)
		{
			if (q->m_length == amount)
			{
				/* take the whole thing */
				p->m_link = q->m_link;
			} else
			{
				if ((q1 = mgetmd()) == NULL)
				{
#if	DBGIUMEM
					kprintf("ffit: Null Mget\n");
#endif
					return NULL;
				}
	
				/*  init new MD  */
			
				q1->m_length = q->m_length - amount;
				q1->m_start = q->m_start + amount;
				q1->m_link = q->m_link;
			
				/*  adjust allocated block  */
			
				q->m_length = amount;
				p->m_link = q1;
			}
	
			/*  link allocate block into allocated list,
			   mark owner of block, & adjust rover  */
		
			q->m_link = mp->mp_mal;
			mp->mp_mal = q;
		
			q->m_own = run;
			
			mp->mp_rover = (MD *)mp == p ? p->m_link : p;
			return q;					/* got some */
		} else
		{
			if (q->m_length > maxval)
				maxval = q->m_length;
		}
		
		p = q;
		q = p->m_link;
	} while (mp->mp_rover != p);
	
	if (getmax)
		return (MD *)maxval;
	else
		return NULL;
}
#endif /* ALTRAM_SUPPORT */


/*
 *  xsetblk - 
 *
 *	Function 0x4A	Mshrink
 *
 *	Last modified	SCC	19 Apr 85
 */

/* 206de: 00e147b6 */
/* 306de: 00e1821c */
/* 306us: 00e181c2 */
ERROR xsetblk(P(int16_t) n, P(VOIDPTR) blk, P(int32_t) len)
PP(int16_t n;)									/*  dummy, not used         */
PP(VOIDPTR blk;)								/*  addr of block to free   */
#if GEMDOS >= 0x18 | !BINEXACT
PP(register int32_t len;)								/*  length of block to free */
#else
PP(int32_t len;)								/*  length of block to free */
#endif
{
	register MD *m, *p;

	UNUSED(n);
	/*
	 * Traverse the list of memory descriptors looking for this block.
	 */

#if ALTRAM_SUPPORT
	for (p = pmd.mp_mal; p; p = p->m_link)
		if ((intptr_t) blk == (p->m_start & ~M_ALTFLAG))
			goto found;

	/*
	 * If block address doesn't match any memory descriptor, then abort.
	 */

	return E_IMBA;

found:
#else
	for (p = pmd.mp_mal; p; p = p->m_link)
		if ((intptr_t) blk == (p->m_start))
			break;

	/*
	 * If block address doesn't match any memory descriptor, then abort.
	 */

	if (p == NULL)
		return E_IMBA;
#endif

	/*
	 *  Always shrink to an even word length.
	 */
#if GEMDOS >= 0x18 | !BINEXACT
	len++;
	len &= ~1L;
#else
	if (len & 1)
		len++;
#endif

	/*
	 *  If the caller is not shrinking the block size, then abort.
	 */

	if (p->m_length < len)
		return E_GSBF;
	if (p->m_length == len)
		return E_OK;

	if (len == 0)
	{
		freeit(p, &pmd);
		return E_OK;
	}
	
	/*
	 *  Create a memory descriptor for the freed portion of memory.
	 */

	m = mgetmd();
	/*
	 * what if 0? *
	 */
	if (m == NULL)
	{
#if	DBGUMEM
		panic("umem.c/xsetblk: Null Return From MGET\n");
#endif
		return ERR;
	}
	m->m_start = p->m_start + len;
	m->m_length = p->m_length - len;
	p->m_length = len;
	freeit(m, &pmd);

	return E_OK;
}


/*
 *  freeit - Free up a memory descriptor
 */

/* 306de: 00e182bc */
/* 306us: 00e18262 */
/* 104de: 00fc8b26 */
#if ALTRAM_SUPPORT
VOID freeit(P(MD *) m, P(MPB *) mp)
PP(register MD *m;)
PP(MPB *mp;)
{
	register MD *p, *q;
	register intptr_t s;
	register intptr_t addr;
	MD *p1;
	
#if	STATIUMEM
	++ccfreeit;
#endif

	p1 = NULL;

	addr = m->m_start;
	q = (MD *)mp;
	p = ((MPB *)q)->mp_mfl;
	for (; p; p = (q = p)->m_link)
	{
		s = p->m_start;
		if (s > 0 && addr > 0 && addr < s)
			break;
		if (s < 0 && addr > 0) 
			break;
		if (s < 0 && addr < 0 && addr < s)
			break;
		p1 = p;
	}
	
	m->m_link = p;
	q->m_link = m;

	if (p)
	{
		if (m->m_start + m->m_length == p->m_start)
		{								/* join to higher neighbor */
			m->m_length += p->m_length;
			m->m_link = p->m_link;

			xmdfree(p);
		}
	}
	
	if (p1)
	{
		if (p1->m_start + p1->m_length == m->m_start)
		{								/* join to lower neighbor */
			p1->m_length += m->m_length;
			p1->m_link = m->m_link;

			xmdfree(m);
		}
	}
}
#else
VOID freeit(P(MD *) m, P(MPB *) _mp)
PP(MD *m;)
PP(MPB *_mp;)
{
	register MD *p, *q;
	register MPB *mp;
	MD *p1;
	
#if	STATIUMEM
	++ccfreeit;
#endif

	mp = _mp;
	p1 = NULL;
	q = (MD *)mp;
	p = ((MPB *)q)->mp_mfl;
	
	for (; p; p = (q = p)->m_link)
	{
		if (m->m_start <= p->m_start)
			break;
		p1 = p;
	}

	m->m_link = p;
	q->m_link = m;
	if (mp->mp_rover == NULL)
		mp->mp_rover = m;

	if (p)
	{
		if (m->m_start + m->m_length == p->m_start)
		{								/* join to higher neighbor */
			m->m_length += p->m_length;
			m->m_link = p->m_link;
			
			if (mp->mp_rover == p)
				mp->mp_rover = m;
			xmdfree(p);
		}
	}
	
	if (p1)
	{
		if (p1->m_start + p1->m_length == m->m_start)
		{								/* join to lower neighbor */
			p1->m_length += m->m_length;
			p1->m_link = m->m_link;

			if (mp->mp_rover == m)
				mp->mp_rover = p1;
			xmdfree(m);
		}
	}
}
#endif


/*
 *  xmalloc - 
 *
 *	Function 0x44	Mxalloc
 *
 *	Last modified	SCC	3 Jun 85
 */

#if ALTRAM_SUPPORT
/* 306de: 00e18372 */
/* 306us: 00e18318 */
int32_t xmxalloc(P(int32_t) amount, P(int16_t) mode)
PP(int32_t amount;)
PP(int16_t mode;)
{
	register MD *m;

	if (amount == -1L)
	{
		return xmfsize(&pmd, mode);
	} else
	{
		/*
		 *  Pass the request on to the internal routine.  If it was not able 
		 *  to grant the request, then abort.
		 */
	
		if ((m = ffit(amount, &pmd, mode)))
			return m->m_start & ~M_ALTFLAG;
		else
			return 0;
	}
}
#endif


/*
 *  xmalloc - 
 *
 *	Function 0x48	Malloc
 *
 *	Last modified	SCC	3 Jun 85
 */

/* 306de: 00e183cc */
/* 306us: 00e18372 */
/* 104de: 00fc8c10 */
int32_t xmalloc(P(int32_t) amount)
PP(int32_t amount;)
{
#if ALTRAM_SUPPORT
	if (run->p_flags & PF_ALLOCTTRAM)
		return xmxalloc(amount, MX_PTTRAM);
	else
		return xmxalloc(amount, MX_STRAM);
#else
	register MD *m;

	if (amount != -1L && (amount & 1))
		amount++;
	/*
	 *  Pass the request on to the internal routine.  If it was not able 
	 *  to grant the request, then abort.
	 */

	if ((m = ffit(amount, &pmd)) == NULL)
		return 0;
	if (amount == -1)
		return (int32_t)m;
	return m->m_start;
#endif
}


/*
 *  xmfree - 
 *
 *	Function 0x49	Mfree
 */

/* 306de: 00e183fe */
/* 306us: 00e183a4 */
/* 104de: 00fc8c64 */
ERROR xmfree(P(int32_t) addr)
PP(int32_t addr;)
{
	register MD *p, **q;

#if ALTRAM_SUPPORT
	for (p = *(q = &pmd.mp_mal); p; p = *(q = &p->m_link))
		if (addr == (p->m_start & ~M_ALTFLAG))
			goto found;

	return E_IMBA;

found:
#else
	for (p = *(q = &pmd.mp_mal); p; p = *(q = &p->m_link))
		if (addr == (p->m_start))
			break;
	if (p == NULL)
		return E_IMBA;

#endif
	*q = p->m_link;
	freeit(p, &pmd);

	return E_OK;
}


/* 306de: 00e183fe */
/* 306us: 00e183a4 */
/* 104de: 00fc8cac */
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


#if ALTRAM_SUPPORT
/* 306de: 00e184f8 */
/* 306us: 00e1849e */
ERROR xmaddalt(P(char *) start, P(int32_t) len)
PP(char *start;)
PP(int32_t len;)
{
	register intptr_t s;
	register MD *q;
	
	s = (intptr_t)start;
	/* make start address even */
	if ((s &= 1))
	{
		s = 2 - s;
		start += s;
		len -= s;
	}
	len &= ~1L;
	if (len <= 0)
		return E_OK;
	if ((q = mgetmd()) == NULL)
		return ERR;
	q->m_start = (intptr_t)start | M_ALTFLAG;
	q->m_length = len;
	q->m_link = NULL;
	q->m_own = NULL;
	freeit(q, &pmd);
	
	return E_OK;
}
#endif


/* 306de: 00e18570 */
/* 306us: 00e18516 */
/* 104de: 00fc8d12 */
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
