/*  osmem.c - allocate/release os memory				*/

#include "tos.h"
#include "fs.h"
#include "bios.h"
#include "mem.h"
#include <toserrno.h>

/* should actually be offsetof(struct MDBLOCK, buf) */
#define MD_OFFSET (sizeof(MDBLOCK *) + 2)

static MD *mdfind PROTO((MDBLOCK **p1, int *a, MDBLOCK *p));
int mdlink PROTO((MD *m, MD *p));

static MDBLOCK *ofdmore PROTO((NOTHING));
static MDBLOCK *getosm PROTO((NOTHING));



MDBLOCK ofdbuf[80];
MDBLOCK *ofdlist;
MDBLOCK *root[MAXQUICK];
#define ofdfree root[4]


/* 306de: 00e185b0 */
/* 306us: 00e18556 */
/* 104de: 00fc8d52 */
VOID osminit(NOTHING)
{
	ofdlist = NULL;
	ofdadd(ofdbuf, (long)sizeof(ofdbuf));
}


/* 306de: 00e185ce */
/* 306us: 00e18574 */
/* 104de: 00fc8d70 */
VOID ofdadd(P(MDBLOCK *) p, P(long) len)
PP(register MDBLOCK *p;)
PP(register long len;)
{
	register VOIDPTR unused;
	register int x;
	
	UNUSED(unused);
	UNUSED(x);
	
	len = (len / sizeof(*p)) * sizeof(*p);
	
	while (len != 0)
	{
		p->o_link = ofdlist;
		ofdlist = p;
		p->x_flag = 0;
		len -= sizeof(*p);
		p++;
	}
}


/* 306de: 00e1862c */
/* 306us: 00e185d2 */
/* 104de: 00fc8dce */
OFD *mgetofd(NOTHING)
{
	register MDBLOCK *p;
	register MD *x;
	register int32_t *y;
	register int i;
	register int thisfree;
	register int total;
	
	total = 0;
	for (p = ofdlist; p; p = p->o_link)
	{
		if (p->x_flag == 0)
			goto found;
		if (p->x_flag > 0)
		{
			thisfree = 0;
			x = p->buf;
			for (i = MDS_PER_BLOCK - 1; i >= 0; i--, x++)
			{
				if (x->m_own == MF_FREE)
				{
					total++;
					thisfree++;
				}
			}
			if (thisfree == MDS_PER_BLOCK)
			{
				goto found;
			}
		}
	}

	p = ofdmore();
	if (p != NULL)
		goto found;

	if (total >= MDS_PER_BLOCK)
	{
		p = getosm();
		if (p != NULL)
			goto found;
	} else
	{
		y = (int32_t *)fsgetofd();
		if (y != NULL)
		{
			p = (MDBLOCK *)((char *)y - MD_OFFSET);
			goto found;
		}
	}
	foldermsg();
	
found:
	p->x_flag = -1;
	y = (int32_t *)p->buf;
	while (y < (int32_t *)(&p->buf[MDS_PER_BLOCK]))
	{
		*y = 0;
		y++;
	}
	return (OFD *)p->buf;
}


/* 306de: 00e186da */
/* 306us: 00e18680 */
/* 104de: 00fc8e7c */
static MDBLOCK *ofdmore(NOTHING)
{
	register MDBLOCK *p;
	register MDBLOCK *q;
	register PD **pp;
	
	p = ofdfree;
	if (p == NULL)
		return NULL;
	while (p != NULL)
	{
		for (q = p; q->o_link != NULL && q->o_link == (MDBLOCK *)&q->buf[MDS_PER_BLOCK-1].m_own; q = q->o_link)
			;
		pp = &q->buf[MDS_PER_BLOCK-1].m_own;
		q = q->o_link;
		ofdadd(p, (long)pp - (long)p);
		p = q;
	}
	ofdfree = NULL;
	return ofdlist;
}


/* 306de: 00e18738 */
/* 306us: 00e186de */
/* 104de: 00fc8eda */
MD *mgetmd(NOTHING)
{
	register MDBLOCK *p;
	register MDBLOCK *q;
	register MD *x;
	register int i;
	OFD *y;
	
	q = NULL;
	p = ofdlist;
	while (p != NULL)
	{
		if (p->x_flag == 0)
		{
			q = p;
		} else if (p->x_flag > 0)
		{
			x = p->buf;
			for (i = MDS_PER_BLOCK-1; i >= 0; i--, x++)
			{
				if (x->m_own == MF_FREE)
				{
					goto found;
				}
			}
		}
		p = p->o_link;
	}
	if (q != NULL)
	{
		p = q;
	} else
	{
		p = ofdmore();
		if (p != NULL)
		{
			;
		} else
		{
			if ((y = (OFD *)fsgetofd()) != NULL)
			{
				p = (MDBLOCK *)((char *)y - MD_OFFSET);
			} else
			{
				return NULL;
			}
		}
	}
	p->x_flag = 1;
	x = p->buf;
	(x++)->m_own = MF_FREE;
	(x++)->m_own = MF_FREE;
	(x++)->m_own = MF_FREE;
found:
	x->m_link = (MD *)(x->m_start = x->m_length = (intptr_t)(x->m_own = NULL));
	return x;
}


/*
 *  getosm - get a block of memory from the main o/s memory pool
 *	(as opposed to the 'fast' list of freed blocks).
 */

/* 306de: 00e18804 */
/* 306us: 00e187aa */
/* 104de: 00fc8fa6 */
static MDBLOCK *getosm(NOTHING)
{
	register MDBLOCK *p;
	register MDBLOCK *q;
	register MD *x;
	MDBLOCK *p1;
	register int i;
	register int idx;
	register int thisfree;
	register int maxfree;
	int a;
	MD *p2;
	
	p1 = p = NULL;
	q = ofdlist;
	maxfree = 0;
	while (q != NULL)
	{
		if (q->x_flag > 0)
		{
			thisfree = 0;
			x = q->buf;
			for (i = MDS_PER_BLOCK-1; i >= 0; i--, x++)
			{
				if (x->m_own == MF_FREE)
				{
					thisfree++;
					if (p1 == NULL)
						p1 = q;
				}
			}
			if (thisfree > maxfree)
			{
				p = q;
				maxfree = thisfree;
				if (thisfree == MDS_PER_BLOCK)
					return p;
				if (thisfree == MDS_PER_BLOCK-1)
					break;
			}
		}
		q = q->o_link;
	}
	
	if (p1 == p && !(p1 = p->o_link))
		return NULL;
	
	a = 0;
	x = p->buf;
	idx = 0;
	while (x->m_own == MF_FREE)
		idx++, x++;
	while (1)
	{
		p2 = mdfind(&p1, &a, p);
		mdlink(x, p2);
#if GEMDOS >= 0x18
		x->m_own = MF_FREE;
#else
		p2->m_own = NULL;
#endif
		x++;
		idx++;
		while (idx < MDS_PER_BLOCK)
		{
			if (x->m_own != MF_FREE)
				goto search;
			idx++, x++;
		}
		return p;
	search:;
	}
}


/* 306de: 00e188f8 */
/* 306us: 00e1889e */
/* 104de: 00fc909e */
int mdlink(P(MD *) m, P(MD *) p)
PP(register MD *m;)
PP(register MD *p;)
{
#if GEMDOS >= 0x18
	register int i;
	static MD **mds[2] = { &pmd.mp_mfl, &pmd.mp_mal };
	register MD *q;
	MD *p1;
	MD *p2;
	
	for (i = 0; i < 2; i++)
	{
		p1 = (MD *)mds[i];
		q = (p2 = p1)->m_link;
		while (q != NULL)
		{
			if (q == m)
				goto found;
			q = (p2 = q)->m_link;
		}
	}
#else
	register MD *q;
	MD **p1;
	MD *p2;
	
	for (p1 = &pmd.mp_mfl; p1 < &pmd.mp_rover; p1++)
	{
		q = (p2 = (MD *)p1)->m_link;
		while (q != NULL)
		{
			if (q == m)
				goto found;
			q = (p2 = q)->m_link;
		}
	}
#endif

	return TRUE;
	
found:
	*p = *m;
	p2->m_link = p;
	return FALSE;
}


/* 306de: 00e18962 */
/* 306us: 00e18908 */
/* 104de: 00fc9106 */
MD *mdfind(P(MDBLOCK **) p1, P(int *) a, P(MDBLOCK *) p)
PP(MDBLOCK **p1;)
PP(int *a;)
PP(MDBLOCK *p;)
{
	register MDBLOCK *q;
	register MD *m;
	register int i;
	
	q = *p1;
	i = *a;
	
	while (q != NULL)
	{
#if GEMDOS >= 0x18
		if (q->x_flag > 0)
#endif
		{
			m = &q->buf[i];
			while (i < MDS_PER_BLOCK)
			{
				if (m->m_own == MF_FREE)
				{
					*p1 = q;
					*a = i;
					return m;
				}
				i++, m++;
			}
		}
		q = q->o_link;
		if (q == p)
			q = q->o_link;
		i = 0;
	}

#if !BINEXACT
	/* BUG: no explicit return statement here, but has q == NULL in D0 */
	return NULL;
#endif
}


/*
 *  oftdel - delete an entry from the oft list
 */

/* 306de: 00e189ce */
/* 306us: 00e18974 */
/* 104de: 00fc916c */
OFD *oftdel(P(OFD *) ofd)
PP(OFD *ofd;)
{
	register MDBLOCK *p;

	p = (MDBLOCK *)((char *)ofd - MD_OFFSET);
	if (p->x_flag == 0)
		foldermsg();
	p->x_flag = 0;
	return NULL;
}


/* 306de: 00e189f8 */
/* 306us: 00e1899e */
/* 104de: 00fc9196 */
VOIDPTR xmdfree(P(MD *) m)
PP(register MD *m;)
{
	register MDBLOCK *p;
	register MD *q;
	register int i;
	
	for (p = ofdlist; p; p = p->o_link)
	{
		if ((MD *)p < m && m < (MD *)(p + 1))
		{
			if (p->x_flag <= 0)
			{
				break; /* goto fail */
			}
			q = &p->buf[MDS_PER_BLOCK-1];
			for (i = MDS_PER_BLOCK-1; i >= 0; i--, q--)
			{
				if (m == q)
				{
					if (q->m_own == MF_FREE)
					{
						goto fail;
					}
					q->m_own = MF_FREE;
					return NULL;
				}
			}
			break; /* goto fail; */
		}
	}
fail:
	foldermsg();
	unreachable();
}
