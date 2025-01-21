/*  osmem.c - allocate/release os memory				*/

/*
**  mods
**
**  mod no.	 date      who	comments
**  ------------ --------  ---	--------
**  M01.01a.0708 08 Jul 86 ktb	xmgetblk wasn't checking root index
**
*/

/*
 * Note: the order & grouping of functions here absolutely
 * makes no sense.
 * But this is how they appaeared in the orginal ROMs.
 */

#include "tos.h"
#include "fs.h"
#include "bios.h"
#include "mem.h"
#include <toserrno.h>
#include "btools.h"
#include "pghdr.h"

#ifndef	DBGFREMEM
#define	DBGFREMEM	0
#endif

#ifndef	DBGOSMEM
#define	DBGOSMEM	0
#endif

#ifndef	DBGUMEM
#define	DBGUMEM	0
#endif

#ifndef	OSMPANIC
#define	OSMPANIC	0
#endif


#define	DBGPROC	0


/*
 * osmptr - 
 */
STATIC int osmptr;
int osmlen;
STATIC int16_t osmem[LENOSM];

/*
 *  root - root array for 'quick' pool.
 *	root is an array of ptrs to memblocks of size 'i' paragraphs,
 *	where 'i' is the index into the araay (a paragraph is 16 bites).
 *  Each list is singly linked.  Items on the list are
 *	deleted/added in LIFO order from the root.  
 */
MDBLOCK *root[MAXQUICK];



/* should actually be offsetof(struct MDBLOCK, buf) */
#define MD_OFFSET (sizeof(MDBLOCK *) + 2)




/*
 *  getosm - get a block of memory from the main o/s memory pool
 *	(as opposed to the 'fast' list of freed blocks).
 */
/* 306de: 00e18804 */
/* 306us: 00e187aa */
/* 104de: 00fc8fa6 */
/* 100fr: 00fc7c92 */
static VOIDPTR getosm(P(int) nwords)
PP(int nwords;)
{
	register VOIDPTR m;

	if (nwords > osmlen)
	{
		/*  not enough room  */
#if	OSMPANIC
		mgtpanic(root, 20);				/*  will not return     */
#endif
		return (0);
	}

	osmlen -= nwords;					/*  new length of free block    */
	m = &osmem[osmptr];					/*  start at base       */
	osmptr += nwords;					/*  new base            */
	return m;							/*  allocated memory        */
}


/*
 *  xmgetblk - get a block of memory from the o/s pool.
 *	first try to get a block of size i**16 bytes (i paragraphs) from
 *	the 'fast' list - a list of lists of blocks, where list[i] is a 
 *	list of i paragraphs sized blocks.  These lists are singly linked
 *	and are deleted/removed in LIFO order from the root.  If there is 
 *	no free blocks on the desired list, we call getosm to get a block
 *	from the os memory pool
 */
VOIDPTR xmgetblk(P(int) size)
PP(int size;)
{
	int w;
	MDBLOCK *m;
	int16_t *q;
	MDBLOCK **r;

	w = size * (16 / sizeof(osmem[0]));	/*  number of words     */

	/*
	 **  allocate block
	 */

#if 0
	/*  M01.01a.0708.01  */
	if (i >= MAXQUICK)
	{
		return NULL;
	}
#endif

	if (*(r = &root[size]))
	{									/*  there is an item on the list  */
		m = *r;							/*  get 1st item on list    */
		*r = m->o_link;					/*  root pts to next item   */
	} else
	{									/*  nothing on list, try pool  */
		if ((m = getosm(w + 1)))		/*  add size of control word    */
		{
#ifdef __GNUC__
			*((int16_t *)m) = size;			/*  put size in control word    */
			m = (void *)((char *)m + 2);
#else
			*((int16_t *)m)++ = size;	/*  put size in control word    */
#endif
		}
	}

	/*
	 **  zero out the block
	 */

	if ((q = (int16_t *)m) != NULL)
		for (size = 0; size < w; size++)
			*q++ = 0;

	return m;
}


/*
 *  xmfreblk - free up memory allocated through mgetblk
 */
VOID xmfreblk(P(VOIDPTR) m)
PP(VOIDPTR m;)
{
	register int i;

	i = *((int16_t *)m - 1);
#if	DBGOSMEM
	if (i < 0 || i >= MAXQUICK)
	{
		/*  bad index */
		kprintf("xmfreblk: bad index (0x%x)\n");
		kprintf("stack at %08lx\n", &m);
		while (1)
			;
	} else
#endif
	{
		/* ok to free up */
		((MDBLOCK *)m)->o_link = root[i];
		root[i] = m;
#if	DBGFREMEM
		if (((MDBLOCK *)m)->o_link == m)
		{
			kprintf("xmfreblk: Circular link in root[%x]\n", i);
			kprintf("\tat %lx\n", (long)m);
		}
#endif
	}
}


/*
 * values of 'mode' for Pexec()
 */
#define PE_LOADGO     0
#define PE_LOAD       3
#define PE_GO         4
#define PE_BASEPAGE   5
#define PE_GOTHENFREE 6
#define PE_BPFLAGS    7
#define PE_RELOCATE   50    /* required for NatFeats support only, not in Atari TOS */

#define TPASIZE_QUANTUM (128*1024L)

#define MINSTACK 0x800L


VOID ixterm PROTO((PD *r));



/*	
 *  xtermres - 
 *	Function 0x31	Ptermres
 */

/* 306de: 00e176d6 */
/* 306us: 00e1767c */
/* 104de: 00fc80f8 */
/* 106de: 00e082c8 */
/* 100fr: 00fc7d9a */
VOID xtermres(P(int32_t) blkln, P(int16_t) rc)
PP(int32_t blkln;)
PP(int16_t rc;)
{
	xsetblk(0, run, blkln);
#if GEMDOS >= 0x15
	xmakeres(run);
#else
	/* inlined version of xmakeres() */
	{
	register MD *m;
	register MD **q;

	for (m = *(q = &pmd.mp_mal); m; m = *q)
	{
		if (m->m_own == run)
		{
			*q = m->m_link;				/* pouf ! like magic */
			xmfreblk(m);
		} else
			q = &m->m_link;
	}
	}
#endif
	xterm(rc);
}



/*
 *  xterm - terminate a process
 *	terminate the current process and transfer control to the colling
 *	process.  All files opened by the terminating process are closed.
 *
 *	Function 0x4C	Pterm
 */

/* 306de: 00e17704 */
/* 306us: 00e176aa */
/* 104de: 00fc8126 */
/* 100fr: 00fc7dea */
VOID xterm(P(uint16_t) rc)
PP(uint16_t rc;)
{
	register PD *r;

	indcall(trap13(0x0005, 0x0102, -1L));	/*  call user term handler */
#if TOSVERSION >= 0x102
	xbgettime();
#endif
	
	run = (r = run)->p_parent;
	ixterm(r);
	run->p_dreg[0] = rc;
	gouser();
}


/*
 *  x0term - Terminate Current Process
 *	terminates the calling process and returns to the parent process
 *	with a return code of 0 (success).
 *
 *	Function 0x00	Pterm0
 */

/* 306de: 00e17760 */
/* 306us: 00e17706 */
/* 104de: 00fc8182 */
/* 100fr: 00fc7e42 */
VOID x0term(NOTHING)
{
	xterm(0);
}


/*
 *  ixterm - terminate a process
 *	terminate process with PD 'r'.
 */

/* 306de: 00e1776c */
/* 306us: 00e17712 */
/* 104de: 00fc818e */
/* 100fr: 00fc7e4e */
VOID ixterm(P(PD *) r)
PP(register PD *r;)									/*  PD of process to terminate      */
{
	register int h;
	register int i;

	/*  check the standard devices in both file tables  */
	for (i = 0; i < NUMSTD; i++)
		if ((h = r->p_uft[i]) > 0)
			xclose(h);

	for (i = 0; i < (OPNFILES - NUMSTD); i++)
		if (r == sft[i].f_own)
			xclose(i + NUMSTD);

	/*  check directory usage */
	for (i = 0; i < NUMCURDIR; i++)
	{
		if ((h = (char)r->p_curdir[i]) /* != 0 */)
#if GEMDOS >= 0x15
			if (diruse[h])
#endif
				--diruse[h];
	}

	/* free process memory */
#if GEMDOS >= 0x18
	xmfreall(r);
#else
	{
		/* inlined version of xmfreall() */
		register MD *m, **q;
	
		for (m = *(q = &pmd.mp_mal); m; )
		{
			if (m->m_own == r)
			{
				*q = m->m_link;
				freeit(m, &pmd);
			} else
			{
				q = &m->m_link;
			}
			m = *q;
		}
	}
#endif
}


/*
 *  paramsize - unused
 */
#if BINEXACT
static int paramsize(P(char *) str, P(char *) end)
PP(char *str;)
PP(char *end;)
{
	register int cnt;

	for (cnt = 0; *str != '\0' && *str != ' '; ++cnt, ++str)
		;

	*end = *str;
	*str = '\0';
	return cnt;
}
#endif

/*  
 *  xexec - execute a new process
 *	Function 0x4B	Pexec
 *
 * 	flag = 0: load&go, 3:load/nogo, 4:justgo, 5:create psp 
 * 	load&go(cmdlin,cmdtail), load/nogo(cmdlin,cmdtail), justgo(psp) 
 * 	create psp - user receives a memory partition 
 *
 */

#if GEMDOS >= 0x17
static ERROR xpgmld PROTO((PGMHDR01 *hdr, FH fh, PD *p));
#else
static int xpgmld PROTO((const char *s, PD *p));
#endif

/* 104de: 00fc8250 */
/* 106de: 00e08420 */
/* 162de: 00e08420 */
/* 100fr: 00fc7f36 */
ERROR xexec(P(int16_t) mode, P(char *) s, P(char *) t, P(char *) v)
PP(int16_t mode;)								/*  0, 3, 4, or 5       */
PP(char *s;)
PP(char *t;)
PP(char *v;)								/* command, tail, environment   */
{
	/*
	 * the setjmp() routine used in GEMDOS does not save any registers,
	 * so no register variables must be used here.
	 */
	PD *volatile b;
	char *volatile ptr;
	char *volatile e;
	int volatile i;
	int volatile h;
	int volatile cnt;
#if GEMDOS < 0x17
	short volatile unused;
#endif
	ERROR volatile rc;
	int32_t volatile max;
	MD *volatile p;
	MD *volatile env;
	int32_t *volatile spl;
	int16_t *spw;
#if GEMDOS >= 0x17
	long volatile unused;
	ERROR volatile rc2;
	FH volatile fh;
	PGMHDR01 hdr;
	MPB *ppmd;
	char unused2[12];
	
	UNUSED(unused2);
#endif

	UNUSED(unused);
	UNUSED(cnt);
#ifdef __GNUC__
	/* BUG: not initialized */
	p = env = 0;
#endif
	
	/*
	 *   check validity of mode - 1,2 or >5 is not allowed
	 */
	if (mode != PE_LOADGO && (mode < PE_LOAD ||
#if GEMDOS >= 0x15
		mode > PE_BPFLAGS
#else
		mode > PE_BASEPAGE
#endif
		))
		return E_INVFN;

#if GEMDOS >= 0x17
	xmovs(sizeof(errbuf), errbuf, bakbuf);

	if ((rc = xsetjmp(errbuf)) != 0)
	{
		/* Free any memory allocated to this program. */
		if (fh)
			xclose(fh);
		if (p)
			freeit(p, ppmd);
		if (env)
			freeit(env, &pmd);
		xlongjmp(bakbuf, rc);
	}
#endif

	/*
	 *   if we have to load, find the file
	 */
	if (mode == PE_LOADGO || mode == PE_LOAD)
	{
#if GEMDOS >= 0x17
		/*
		 * This block formerly was in a separate function,
		 * but we may have to close the filehandle in case
		 * of critical errors
		 */
		 
		/* open file for read */
		if ((fh = rc2 = xopen(s, RO_MODE)) < 0)
			return rc2;			/*  file not found  */

		/* read file header */
		rc2 = xread(fh, (long)sizeof(hdr), &hdr);
		if (rc2 != sizeof(hdr) || hdr.h01_magic != 0x601a)
		{
			xclose(fh);
			if (rc2 < 0)
				return rc2;
			else
				return E_PLFMT;
		}
#else
		if ((int)ixsfirst(s, 0, NULL)) /* bogus cast: apparently ixsfirst() was not properly declared here */
			return E_FILNF;			/*  file not found  */
#endif
	} else
	{
#if GEMDOS >= 0x17
		hdr.h01_ldflags = 0;
#endif
	}
	
#if GEMDOS < 0x17
	xmovs(sizeof(errbuf), errbuf, bakbuf);

	if ((rc = xsetjmp(errbuf)) != 0)
	{
		if (rc != E_CHNG)
			xlongjmp(bakbuf, rc);
		/* we allocated memory in a previous incarnation */
		if (mode != PE_GO)
		{
			freeit(p, &pmd);
			freeit(env, &pmd);
		}
		xlongjmp(bakbuf, rc);
	}
#endif

	/* will we need memory and a psp ? */

	if (mode != PE_GO
#if GEMDOS >= 0x15
		&& mode != PE_GOTHENFREE
#endif
		)
	{									/* get largest memory partition available */
		if (!v)
			v = run->p_env;

		/*
		 *  envsize - determine size of env area
		 *	counts bytes starting at 'env' upto and including the terminating
		 *	double null.
		 */
	
		e = v;
		i = 0;
		for (;;)
		{
			if (*e++ == '\0')
			{
				if (*e++ == '\0')
					break;
				i++;
			}
			i++;
		}
	
		i += 2;					/*  count terminating double null  */
		if (i & 1)						/*  make an even number     */
			i += 1;

		/*
		 *  allocate environment
		 */
		if (!(env = ffit((long)(i), &pmd)))
		{
#if	DBGPROC
			kprintf("xexec: Not Enough Memory!\n");
#endif
			return E_NSMEM;
		}

		/* 
		 * now copy it 
		 */
		e = (char *)env->m_start;
#if 0 /* that would be too easy... */
		xmovs(i, v, e);
#else
		while (i--)
			*e++ = *v++;
#endif

		/* 
		 *   allocate base page
		 */

#if GEMDOS >= 0x17
		ppmd = &pmd;
		max = (int32_t)ffit(-1L, ppmd);
		if (max < sizeof(PD))
#else
		if ((max = (int32_t)ffit(-1L, &pmd)) < sizeof(PD))
#endif
		{								/*  not enough even for PD  */
			freeit(env, &pmd);
#if	DBGPROC
			kprintf("xexec: No Room For Base Pg\n");
#endif
			return E_NSMEM; /* BUG: fh still open */
		}

		/*  allocate the base page.  The owner of it is either the
		   new process being created, or the parent  */

#if GEMDOS >= 0x17
		p = (MD *)ffit(max, ppmd);
#else
		p = (MD *)ffit(max, &pmd);
#endif
		b = (PD *)p->m_start;
		
		/* set owner of environment & bp */
		p->m_own = env->m_own = (mode == PE_LOADGO
#if GEMDOS < 0x15
			|| mode == PE_GO /* won't happen, since we don't get here for mode == PE_GO */
#endif
			) ? b : run;
		max = p->m_length;
		
		/*
		 *   We know we have at least enough room for the PD (room 
		 *  for the rest of the pgm checked for in pgmld)
		 *   initialize the PD (first, by zero'ing it out)
		 */

		b->p_lowtpa = (int32_t) b;
		b->p_hitpa = (int32_t) b + max;
#if 0 /* that would be too easy... */
		bzero((char *)b + 8, sizeof(PD) - 8);
#else
		for (i = 0, ptr = (char *)b + 8; i < sizeof(PD); i++)
			*ptr++ = 0;
#endif
		b->p_xdta = (DTAINFO *)&b->p_cmdlin[0];	/* default p_xdta is p_cmdlin */
#if GEMDOS >= 0x17
		b->p_flags = hdr.h01_ldflags;
#endif
		b->p_env = (char *)env->m_start;

		/* now inherit standard files from me */

		for (i = 0; i < NUMSTD; i++)
		{
			if ((h = run->p_uft[i]) > 0)
				ixforce(i, run->p_uft[i], b);
			else
				b->p_uft[i] = h;
		}

		/* and current directory set */

		for (i = 0; i < NUMCURDIR; i++)
			ixdirdup(i, run->p_curdir[i], b);

		/* and current drive */

		b->p_curdrv = run->p_curdrv;
#if GEMDOS >= 0x17
		b->p_lddrv = run->p_lddrv;
#endif

		/* copy tail */

		ptr = &b->p_cmdlin[0];
		for (i = 0; i < (PDCLSIZE - 3) && *t; i++)
			*ptr++ = *t++;

		*ptr++ = 0;
		t = (char *) b;
	}

	/* 
	 *   for 3 or 0, need to load, supply baspage containing: 
	 *      tpa limits, filled in with start addrs,lens 
	 */

	if (mode == PE_LOADGO || mode == PE_LOAD)
	{
#if GEMDOS >= 0x17
		if ((rc = xpgmld(&hdr, fh, (PD *)t)) != 0)
#else
		if ((rc = xpgmld(s, (PD *)t)) != 0)
#endif
		{
#if	DBGPROC
			kprintf("cmain: error returned from xpgmld = %lx\n", rc);
#endif
			ixterm((PD *)t);
			return rc;
		}
	}
	
	if (mode == PE_LOADGO || mode == PE_GO
#if GEMDOS >= 0x15
		|| mode == PE_GOTHENFREE
#endif
		)
	{
		b = (PD *) t;
		b->p_parent = run;
		spl = (int32_t *) b->p_hitpa;
		*--spl = (int32_t) b;
		*--spl = 0L;					/* bogus retadd */

		/* 10 regs (40 bytes) of zeroes  */

		for (i = 0; i < 10; i++)
			*--spl = 0L;

		*--spl = b->p_tbase;			/* text start */
		spw = (int16_t *) spl;
		*--spw = 0;						/* startup status reg */
		spl = (int32_t *) spw;
		*--spl = (long) &supstk[SUPSIZ];
		b->p_areg[6 - 3] = b->p_areg[7 - 3] = (long) spl;
		b->p_areg[5 - 3] = b->p_dbase;
		b->p_areg[4 - 3] = b->p_bbase;
		run = b;

#if GEMDOS >= 0x15
		if (mode == PE_GOTHENFREE)
		{
			xmsetown(run, run);
			xmsetown(run->p_env, run);
		}
		
		gouser();
#else
		if (mode != PE_BASEPAGE)
			gouser();
#endif
	}

	/* sub-func 3, 5 and 7 return here */

	return (ERROR) t;
}


#if BINEXACT
static VOID unused(P(char **) pp, P(char *) p)
PP(char **pp;)
PP(char *p;)
{
	*--pp = p;
}
#endif


/*
 *  xpgmld - oldest known gemdos load format - very similar to cp/m 68k
 *	load in the (open) program file with handle 'h' using load file
 *	strategy like cp/m 68k.  Specifically:
 *
 *		read in program header and determine format parameters
 *		seek past the symbol table to the start of the relo info
 *  		read in the first offset (it's different than the rest in that 
 *		  it is a longword instead of a byte).
 *  		make the first adjustment
 *  		until we run out of relocation info or we have an error
 *			read in relocation info into the bss area
 *			fix up the code using that info
 *		zero out the bss
 */


/* 104de: 00fc86f4 */
/* 106de: 00e088c4 */
/* 100fr: 00fc83a6 */
static int xpgmld(P(const char *) s, P(PD *) pdptr)
PP(const char *s;)
PP(PD *pdptr;)
{
	register char *rp;				/*  relocation info pointer */
	char *relocstart;
	int fh;
	int16_t magic;
	int16_t absflag;
	int32_t *cp;					/*  code pointer        */
	intptr_t tbase;					/*  base addr of text segment   */
	int32_t addr;
	int32_t flen;
	ERROR rc;
	int32_t fixbase;
	int32_t relst;
	int32_t rlen;					/*  nbr of relocation bytes */
	register short c;
	int32_t blen;
	int32_t tpalen;
	register int32_t fixp;
	register int32_t n;
	int32_t segments[4];
#if GEMDOS >= 0x15
	int32_t ldflags;
#endif
	
	/* open file for read */
#if BINEXACT
	if ((fh = rc = xopen(s)) < 0) /* BUG: mode not passed; BUG: not declared as returning long */
		return rc;			/*  file not found  */
#else
	if ((fh = rc = xopen(s, RO_MODE)) < 0)
		return rc;			/*  file not found  */
#endif

	xread(fh, (long)sizeof(magic), &magic);
	if (magic != 0x601a)
	{
#if GEMDOS >= 0x15 /* BUG: missing */
		xclose(fh);
#endif
		return E_PLFMT;
	}
	xread(fh, (long)sizeof(segments), segments);
	xread(fh, (long)sizeof(rc), &rc); /* skip unused field */
#if GEMDOS >= 0x15
	xread(fh, (long)sizeof(ldflags), &ldflags);
#else
	xread(fh, (long)sizeof(rc), &rc); /* skip unused field */
#endif
	xread(fh, (long)sizeof(absflag), &absflag);
	
	/* relst = 0; */ /* BUG: seems to be removed */

	/*
	 *  calculate program load info
	 */

	flen = segments[0] + segments[1];
	cp = &pdptr->p_tbase;
	tpalen = pdptr->p_hitpa - pdptr->p_lowtpa - sizeof(PD);
	pdptr++;	/*  1st byte after PD   */
	tbase = addr = (intptr_t)pdptr;
	fixbase = tbase;
	relocstart = (char *)(tbase + flen);
	blen = tpalen - flen;
	
	/*
	 *  see if there is enough room to load in the file, then see if
	 *  the requested bss space is larger than the space we have to offer
	 */

	if (blen < segments[2])
	{
#if GEMDOS >= 0x15 /* BUG: missing */
		xclose(fh);
#endif
		return E_NSMEM;
	}
	
	/*
	 *  initialize PD fields
	 */
	for (n = 0; n < 3; n++)
	{
		*cp++ = addr; /* sets pdptr->p_tbase */
		*cp++ = segments[n];
		addr += segments[n];
	}
	
	/*  
	 *  read in the program file (text and data)
	 *  if there is an error reading in the file or if it is an abs
	 * file, then we are finished
	 * Remember that the I/O routines will jump back via longjmp()
	 * on hard errors.
	 */
	xread(fh, flen, (VOIDPTR)tbase);

#if GEMDOS < 0x15
	if (absflag)		/*  do we need to clr bss here? */
		return 0l; /* BUG: file not closed */
#else
	if (!absflag)		/*  do we need to clr bss here? */
#endif
	{
		/*  
		 *  if not an absolute format, position past the symbols and start the 
		 * reloc pointer  (flen is tlen + dlen).  NOTE that relst is 
		 * init'd to 0, so if the format is absolute, we will not drop
		 * into the fixup code.
		 */
		xlseek(flen + segments[3] + sizeof(struct pgmhdr01), fh, SEEK_SET);

		xread(fh, (long) sizeof(relst), &relst);

		if (relst != 0)
		{
			fixp = fixbase + relst;

			/*  make sure we didn't wrap memory or overrun the bss  */

			if (fixp < fixbase || (char *)fixp >= relocstart)
			{
#if GEMDOS >= 0x15 /* BUG: missing */
				xclose(fh);
#endif
				return E_PLFMT;
			}
			
			*((int32_t *) (fixp)) += fixbase;	/*  1st fixup     */
			
			do {
				if (fixp < fixbase || (char *)fixp >= relocstart)
				{
#if GEMDOS >= 0x15 /* BUG: missing */
					xclose(fh);
#endif
					return E_PLFMT;
				}
				
				/*  read in relocation info  */
				rlen = xread(fh, blen, relocstart);
				n = rlen;
				
				rp = relocstart;
				/* do fixups using that info */
				while (n)
				{
					if (!(c = *rp++))
						goto done;
					c &= 0xff;
					if (c == 1)
					{
						fixp += 0xfe;
					} else
					{
						/*  get the byte at rp, don't sign ext, add to cp  */
						fixp += c;
						*((int32_t *) (fixp)) += fixbase;
					}
					n--;
				}
			} while (rlen == blen);
		}
		done:;
	}
	
	/* zero out the bss */
#if GEMDOS >= 0x15
	if (ldflags & PF_FASTLOAD)
	{
		zeromem(relocstart, relocstart + segments[2]);
	} else
	{
		zeromem(relocstart, relocstart + blen);
	}
#else
	for (fixp = (intptr_t)relocstart, n = 3; n < blen; n += 4, fixp += 4)
		*((int32_t *)fixp) = 0;
#endif
	
	xclose(fh);
	return (long)E_OK;
}


#define STATIUMEM 0

#ifndef	DBGIUMEM
#define	DBGIUMEM	0
#endif

#if	STATIUMEM

long ccffit = 0;

long ccfreeit = 0;

#endif

/* 306de: 00e180b8 */
/* 306us: 00e1805e */
/* 104de: 00fc898a */
/* 100fr: 00fc862a */
MD *ffit(P(long) amount, P(MPB *) mp)
PP(long amount;)
PP(MPB *mp;)
{
	register MD *q;
	register MD *p;
	register MD *q1;
	register BOOLEAN getmax;
	register int32_t maxval;
	long unused;
	
#if	STATIUMEM
	++ccffit;
#endif

	UNUSED(unused);
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
				if ((q1 = MGET(MD)) == NULL)
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
/* 162de: 00e08c9a */
ERROR xsetblk(P(int16_t) n, P(VOIDPTR) blk, P(int32_t) len)
PP(int16_t n;)									/*  dummy, not used         */
PP(VOIDPTR blk;)								/*  addr of block to free   */
#if GEMDOS >= 0x17 | !BINEXACT
PP(register int32_t len;)								/*  length of block to free */
#else
PP(int32_t len;)								/*  length of block to free */
#endif
{
	register MD *m;
	register MD *p;
#if (GEMDOS == 0x17)
	MPB *ppmd;
#endif

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
#if GEMDOS == 0x17
	for (p = (ppmd = &pmd)->mp_mal; p; p = p->m_link)
		if ((intptr_t) blk == p->m_start)
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
#endif

	/*
	 *  If the caller is not shrinking the block size, then abort.
	 */

	if (p->m_length < len)
		return E_GSBF;

	/*
	 *  Always shrink to an even word length.
	 */
#if GEMDOS >= 0x17 | !BINEXACT
	len++;
	len &= ~1L;
#else
	if (len & 1)
		len++;
#endif

#if GEMDOS >= 0x15
	if (p->m_length == len)
		return E_OK;

	if (len == 0)
	{
#if TP_29 /* M_SHRINK */
		xmfree((intptr_t) blk);
#else
#if GEMDOS == 0x17
		freeit(p, ppmd);
#else
		freeit(p, &pmd);
#endif
#endif
		return E_OK;
	}
#endif
	
	/*
	 *  Create a memory descriptor for the freed portion of memory.
	 */

	m = MGET(MD);
	/*
	 * what if 0? *
	 */
#if	DBGUMEM
	if (m == NULL)
	{
		panic("umem.c/xsetblk: Null Return From MGET\n");
		return ERR;
	}
#endif
	m->m_start = p->m_start + len;
	m->m_length = p->m_length - len;
	p->m_length = len;
#if GEMDOS == 0x17
	freeit(m, ppmd);
#else
	freeit(m, &pmd);
#endif

	return E_OK;
}


/*
 *  freeit - Free up a memory descriptor
 */

/* 306de: 00e182bc */
/* 306us: 00e18262 */
/* 104de: 00fc8b26 */
/* 100fr: 00fc879c */
VOID freeit(P(MD *) m, P(MPB *) _mp)
PP(MD *m;)
PP(MPB *_mp;)
{
	register MD *p, *q;
	register MPB *mp;
	
#if	STATIUMEM
	++ccfreeit;
#endif

	mp = _mp;
	q = NULL;
	p = mp->mp_mfl;
	
	for (; p; p = (q = p)->m_link)
	{
		if (m->m_start <= p->m_start)
			break;
	}

	m->m_link = p;
	if (q)
		q->m_link = m;
	else
		mp->mp_mfl = m;
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
			xmfreblk(p);
		}
	}
	
	if (q)
	{
		if (q->m_start + q->m_length == m->m_start)
		{								/* join to lower neighbor */
			q->m_length += m->m_length;
			q->m_link = m->m_link;

			if (mp->mp_rover == m)
				mp->mp_rover = q;
			xmfreblk(m);
		}
	}
}



/*
 *  xmxalloc - 
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


#if GEMDOS == 0x17
/* 162de: 00e08e22 */
int32_t xmxalloc(P(int32_t) amount, P(int16_t) mode)
PP(int32_t amount;)
PP(int16_t mode;)
{
	register MD *x;
	register MD *m;

	x = m = NULL;
	if (amount != -1L && (amount & 1))
		amount++;

	if (amount == -1 && mode > MX_TTRAM)
	{
		x = NULL;
		m = ffit(-1L, &pmd);
		if (x > m)
		{
			return (int32_t)x;
		} else
		{
			return (int32_t)m;
		}
	}

	switch (mode)
	{
	case MX_STRAM:
	case MX_TTRAM:
	case MX_PSTRAM:
	case MX_PTTRAM:
		m = ffit(amount, &pmd);
		break;
	default:
		return 0;
	}
	if (amount != -1 && m)
		return m->m_start;
	else
		return (int32_t)m;
}

/* 162de: 00e08ede */
int32_t xmalloc(P(int32_t) amount)
PP(int32_t amount;)
{
	return xmxalloc(amount, MX_STRAM);
}

#else

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
/* 100fr: 00fc886e */
int32_t xmalloc(P(int32_t) amount)
PP(register int32_t amount;)
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

	/*
	 *  If the request was -1L, the internal routine returned the amount 
	 *  of available memory, rather than a pointer to a memory descriptor.
	 */
	if (amount == -1)
		return (int32_t)m;

	/*
	 *  The internal routine returned a pointer to a memory descriptor.  
	 *  Return its pointer to the start of the block.
	 */
	return m->m_start;
#endif
}

#endif /* GEMDOS == 0x17 */


/*
 *  xmfree - 
 *
 *	Function 0x49	Mfree
 */

/* 306de: 00e183fe */
/* 306us: 00e183a4 */
/* 104de: 00fc8c64 */
/* 100fr: 00fc88bc */
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
#if GEMDOS == 0x17
	register MPB *ppmd;
	ppmd = &pmd;
	for (p = *(q = &pmd.mp_mal); p; p = *(q = &p->m_link))
		if (addr == p->m_start)
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
#endif
	*q = p->m_link;
#if GEMDOS == 0x17
	freeit(p, ppmd);
#else
	freeit(p, &pmd);
#endif

	return E_OK;
}


