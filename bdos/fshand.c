/*  fshand.c - file handle routines for the file system			*/


/*
 * Note: the order & grouping of functions here absolutely
 * makes no sense.
 * But this is how they appaeared in the orginal ROMs.
 */

#include "tos.h"
#include "fs.h"
#include "bios.h"
#include "../bios/biosdefs.h"
#include "mem.h"
#include <toserrno.h>
#include "btools.h"

#undef min
#define min(a,b) (((a) < (b)) ? (a) : (b))


static VOID makbuf PROTO((FCB *f, DTAINFO *dt));


/*
 *  local macros
 */

#define dirscan(a,c) ((DND *) scan(a,c,FA_DIREC,&negone))

/*
 *  negone - for use as parameter
 */

STATIC int32_t negone = -1L;

/*
 *  dots -, dots2  -
 */

STATIC char /* const */ dots[22] = { ".          " };
STATIC char /* const */ dots2[22] = { "..         " };

/***************************************************************************
 *
 * uc - utility routine to return the upper-case of character passed in
 *
 ***************************************************************************/

int uc(P(char) c)
PP(register char c;)
{
	return c >= 'a' && c <= 'z' ? (c & 0x5F) : c;
}


/*
 *  getdmd - allocate storage for and initialize a DMD
 */

/* 306de: 00e1423e */
/* 306us: 00e141e4 */
/* 104de: 00fc4d2a */
/* 100fr: 00fc4eba */
DMD *getdmd(P(int) drv)
PP(int drv;)
{
	register DMD *dm;

	if ((drvtbl[drv] = dm = MGET(DMD)))
	{
		if ((dm->m_dtl = MGET(DND)))
		{
			if ((dm->m_dtl->d_ofd = MGET(OFD)))
			{
				if ((dm->m_fatofd = MGET(OFD)))
					return dm;
				xmfreblk(dm->m_dtl->d_ofd);
			}
			xmfreblk(dm->m_dtl);
		}
		xmfreblk(dm);
	}
	return NULL;
}



/*
 *  syshnd -
 */

/* 306de: 00e16e68 */
/* 306us: 00e16e0e */
/* 104de: 00fc788a */
/* 106de: 00e07a5a */
/* 100fr: 00fc4f46 */
FH syshnd(P(FH) h)
PP(register FH h;)
{
	if (h >= NUMSTD)
		return h - NUMSTD;

	if ((h = run->p_uft[h]) > 0)
		return h - NUMSTD;

	return h;
}



/*
 *  getofd -
 */
/* 306de: 00e16e98 */
/* 306us: 00e16e3e */
/* 104de: 00fc78ba */
/* 100fr: 00fc4f80 */
OFD *getofd(P(FH) h)
PP(FH h;)
{
#if GEMDOS >= 0x18
	if (h < 0 || h >= OPNFILES)
		return NULL;
	h = syshnd(h);
	if (h < 0)
		return NULL;
	return sft[h].f_ofd;
#else
	/* BUG: no validity checks here */
	return sft[syshnd(h)].f_ofd;
#endif
}


/*
 *  ixdirdup -
 */

VOID ixdirdup(P(FH) h, P(int16_t) dn, P(PD *) p)
PP(FH h;)									/* file handle              */
PP(int16_t dn;)									/* directory number         */
PP(PD *p;)
{
	p->p_curdir[h] = dn;
	diruse[dn]++;
}


/*
 *  dup -
 *	duplicate a file handle.
 *
 *	Function 0x45	Fdup
 *
 *	Error returns
 *		EIHNDL
 *		ENHNDL
 *
 *	Last modified	SCC	 5 Apr 85
 */

/* 306de: 00e16eda */
/* 306us: 00e16e80 */
/* 104de: 00fc78fc */
/* 100fr: 00fc4fd6 */
ERROR xdup(P(int16_t) _h)
PP(int16_t _h;)							/*+ h must be a standard handle (checked) */
{
	register FH i;
	register int16_t h;
	
	h = _h;
	if (h < 0 || h >= NUMSTD)
		return E_IHNDL;				/* only dup standard */

	for (i = 0; i < (OPNFILES - NUMSTD); i++)
		if (!sft[i].f_own)
			break;
	
	if (i == (OPNFILES - NUMSTD))
		return E_NHNDL;

	sft[i].f_own = run;

	if ((h = run->p_uft[h]) > 0)
		sft[i].f_ofd = sft[h - NUMSTD].f_ofd;
	else
		sft[i].f_ofd = (OFD *)(long)h; /* hmpf */

	sft[i].f_use = 1;

	return i + NUMSTD;
}


/*
 *  xforce -
 *
 *	Function 0x46	Fforce
 *
 *	Error returns
 *		EIHNDL
 *
 *	Last modified	SCC	5 Apr 85
 */

/* 306de: 00e16f5e */
/* 306us: 00e16f04 */
/* 104de: 00fc7980 */
/* 100fr: 00fc509e */
ERROR xforce(P(int16_t) std, P(int16_t) h)
PP(int16_t std;)
PP(int16_t h;)
{
	return ixforce(std, h, run);
}


/*
 *  ixforce - force a std handle to a non-std handle.
 *	if the std handle is for an open non-char device, close it
 */

/* 306de: 00e16f74 */
/* 306us: 00e16f1a */
/* 104de: 00fc7996 */
/* 100fr: 00fc50b8 */
ERROR ixforce(P(FH) _std, P(FH) _h, P(PD *) _p)
PP(FH _std;)								/* std must be a standard handle    */
PP(FH _h;)									/* h   must NOT be a standard handle    */
PP(PD *_p;)
{
	register PD *p = _p;
	register long fh;
	register FH h;
	register FH std;

	h = _h;
	std = _std;
	if (std < 0 || std >= NUMSTD)
		return E_IHNDL;

#if 0
	if (p->p_uft[std] > 0)
		xclose(std);
#endif

	if (h < 0)
	{
		p->p_uft[std] = h;
	} else
	{
		if (h < NUMSTD)
			return E_IHNDL;
		if ((fh = (long) sft[h - NUMSTD].f_ofd) < 0L)
		{
			p->p_uft[std] = fh;
		} else
		{
			p->p_uft[std] = h;
			sft[h - NUMSTD].f_use++;
		}
	}
	return E_OK;
}


/*
 *  xlog2 -
 *	return log base 2 of n
 */

/* 306de: 00e172e0 */
/* 306us: 00e17286 */
/* 104de: 00fc7d02 */
/* 100fr: 00fc515a */
int xlog2(P(int) _n)
PP(int _n;)
{
	register int i;
	register int n = _n;

	for (i = 0; n; i++)
		n >>= 1;

	return i - 1;
}


/*
 *  login -
 *	log in media 'b' on drive 'drv'.
 *
 */
/* 306de: 00e1428e */
/* 306us: 00e14234 */
/* 104de: 00fc4d7a */
/* 100fr: 00fc5180 */
ERROR login(P(BPB *) b, P(int) drv)
PP(BPB *b;)									/*  bios parm block for drive       */
PP(int drv;)								/*  drive number            */
{
	long unused;
	OFD *fo, *f;
	DND *d;
	DMD *dm;
	int rsiz, cs, n;
	RECNO fs; /* BUG: should by unsigned */
	CLNO ncl, fcl;

	UNUSED(unused);
	rsiz = b->recsiz;
	cs = b->clsiz;
	n = b->rdlen;
	fs = b->fsiz;

	if ((dm = getdmd(drv)) == NULL)
		return E_NSMEM;

	d = dm->m_dtl;						/*  root DND for drive      */
	dm->m_fsiz = fs;					/*  fat size            */
	f = d->d_ofd;						/*  root dir file       */
	dm->m_drvnum = drv;					/*  drv nbr into media descr    */
	f->o_dmd = dm;						/*  link to OFD for rt dir file */

	d->d_drv = dm;						/*  link root DND with DMD  */
	d->d_name[0] = 0;					/*  null out name of root   */

	dm->m_16 = b->b_flags & B_16;		/* set 12 or 16 bit fat flag */
#if FAT1_SUPPORT
	dm->m_1fat = b->b_flags & B_1FAT;	/* set fixed media flag */
#endif
	dm->m_clsiz = cs;					/*  set cluster size in sectors */
	dm->m_clsizb = b->clsizb;			/*    and in bytes      */
	dm->m_recsiz = rsiz;				/*  set record (sector) size    */
	dm->m_numcl = b->numcl;				/*  set cluster size in records */
	dm->m_clrlog = xlog2(cs);			/*    and log of it     */
	dm->m_clrm = logmsk[dm->m_clrlog];	/*  and mask of it  */
	dm->m_rblog = xlog2(rsiz);			/*  set log of bytes/record */
	dm->m_rbm = logmsk[dm->m_rblog];	/*  and mask of it  */
	dm->m_clblog = xlog2(dm->m_clsizb);	/*  log of bytes/clus   */

	f->o_fileln = n * rsiz;				/*  size of file (root dir) */


	ncl = (n + cs - 1) / cs;			/* number of "clusters" in root */
	d->d_strtcl = f->o_strtcl = -1 - ncl;	/*  root start clus */
	fcl = (fs + cs - 1) / cs;

	fo = dm->m_fatofd;					/*  OFD for 'fat file'      */
	fo->o_strtcl = d->d_strtcl - fcl;	/*  start clus for fat  */
	fo->o_dmd = dm;						/*  link with DMD       */

	dm->m_recoff[BT_FAT] = b->fatrec - (fo->o_strtcl * cs);
	dm->m_recoff[BT_ROOT] = (b->fatrec + fs) - (d->d_strtcl * cs);

	/* 2 is first data cluster */

	dm->m_recoff[BT_DATA] = b->datrec - (2 * cs);

	fo->o_bytnum = 3;
	fo->o_curbyt = 3;
	fo->o_fileln = fs * rsiz;

	return E_OK;
}


/*
 *  cl2rec -
 */

RECNO cl2rec(P(CLNO) cl, P(DMD *)dm)
PP(CLNO cl;)
PP(DMD *dm;)
{
	return cl * dm->m_clsiz;
}


/*
 *  xfr2usr -
 */
/* 306de: 00e13876 */
/* 306us: 00e1381c */
VOID xfr2usr(P(int) n, P(char *) s, P(char *) d)
PP(int n;)
PP(char *s;)
PP(char *d;)
{
	while (n--)
		*d++ = *s++;
}


/*
 *  usr2xfr -
 */
/* 306de: 00e1386c */
/* 306us: 00e13812 */
VOID usr2xfr(P(int) n, P(char *) d, P(char *) s)
PP(int n;)
PP(char *s;)
PP(char *d;)
{
	while (n--)
		*d++ = *s++;
}


/* 306de: 00e17306 */
/* 306us: 00e172ac */
/* 104de: 00fc7d28 */
/* 100fr: 00fc540a */
VOID xmovs(P(int) n, P(const VOIDPTR) src, P(VOIDPTR) dst)
PP(int n;)
PP(const VOIDPTR src;)
PP(VOIDPTR dst;)
{
	while (n--)
	{
#ifdef __GNUC__
		*((char *)dst) = *((const char *)src);
		dst = (char *)dst + 1;
		src = (const char *)src + 1;
#else
		*((char *)dst)++ = *((const char *)src)++;
#endif
	}
}


/*
 *  xcmps - utility routine to compare two 11-character strings
 *
 *	Last modified	19 Jul 85	SCC
 */
/* 306de: 00e17330 */
/* 306us: 00e172d6 */
/* 104de: 00fc7d52 */
/* 100fr: 00fc5432 */
int xcmps(P(const char *) s, P(const char *) d)
PP(const char *s;)
PP(const char *d;)
{
	register int i;

	for (i = 0; i < 11; i++)
		if (uc(*s++) != uc(*d++))
			return 0;
	return 1;
}


/*
 *  xclose - Close a file.
 *
 *	Function 0x3E	Fclose
 *
 *	Error returns
 *		EIHNDL
 *		ixclose()
 *
 *	SCC:	I have added 'rc' to allow return of status from ixclose().  I 
 *		do not yet know whether it is appropriate to perform the 
 *		operations inside the 'if' statement following the invocation 
 *		of ixclose(), but I am leaving the flow of control intact.
 */

/* 306de: 00e17024 */
/* 306us: 00e16fca */
/* 104de: 00fc7a46 */
/* 100fr: 00fc5486 */
ERROR xclose(P(FH) h)
PP(register FH h;)
{
	register FH h0;
	register OFD *fd;
	register ERROR rc;

	if (h < 0)
		return E_OK;					/* always a good close on a character device */

	if ((h0 = h) < NUMSTD)
	{
		h = run->p_uft[h];
		run->p_uft[h0] = 0;				/* mark std dev as not in use */
		if (h < 0)
			return E_OK;
	} else if (((long) sft[h - NUMSTD].f_ofd) < 0L) /* BUG: h has not being checked yet for being < OPNFILES */
	{
		if (--sft[h - NUMSTD].f_use == 0)
		{
			sft[h - NUMSTD].f_ofd = NULL;
			sft[h - NUMSTD].f_own = NULL;
		}
		return E_OK;
	}

	if (!(fd = getofd(h)))
		return E_IHNDL;

	rc = ixclose(fd, 0);

	if (--sft[h - NUMSTD].f_use == 0)
	{
		/* sftdel(&sft[h - NUMSTD]); */
		xmfreblk(sft[h - NUMSTD].f_ofd);
		sft[h - NUMSTD].f_ofd = NULL;
		sft[h - NUMSTD].f_own = NULL;
	}
	
	return rc;
}


/*
 *  ixclose -
 *
 *	Error returns
 *		EINTRN
 *
 *	Last modified	SCC	10 Apr 85
 *
 *	NOTE:	I'm not sure that returning immediatly upon an error from 
 *		ixlseek() is the right thing to do.  Some data structures may 
 *		not be updated correctly.  Watch out for this!
 *		Also, I'm not sure that the EINTRN return is ok.
 */

/* 306de: 00e160ba */
/* 306us: 00e16060 */
/* 104de: 00fc6aa4 */
/* 100fr: 00fc55ae */
ERROR ixclose(P(OFD *) fd, P(int) part)
PP(register OFD *fd;)
PP(int part;)
{
	register OFD *p;
	register OFD **q;
	DMD *d;
	long tmp;
	register int unused;
	register int i;
	BCB *b;
	
	d = fd->o_dmd;
	UNUSED(unused);
	UNUSED(d);
	
	if (fd->o_flag & O_DIRTY)
	{
		ixlseek(fd->o_dirfil, fd->o_dirbyt + 22);
		
		/*
		 * copy the time, date, cluster, and length fields from the OFD of the
		 * (dir) file we are closeing to the FCB for this (dir) file in the 
		 * parent dir.
		 */
		swp68((uint16_t *)&fd->o_strtcl);
		swp68l(&fd->o_fileln);

		if (part & CL_DIR)
		{
			tmp = fd->o_fileln;
			fd->o_fileln = 0;
			ixwrite(fd->o_dirfil, 10L, &fd->o_td.time);
			fd->o_fileln = tmp;
		} else
		{
			ixwrite(fd->o_dirfil, 10L, &fd->o_td.time);
#if GEMDOS >= 0x18
			/* get buffer address of attribute byte */
			ixlseek(fd->o_dirfil, fd->o_dirbyt + 11);
			fattr = (char *)ixread(fd->o_dirfil, 1L, NULL);
			if (!(*fattr & (FA_DIREC|FA_ARCH|FA_LABEL)))
				*fattr |= FA_ARCH;
#endif
		}
		swp68((uint16_t *)&fd->o_strtcl);
		swp68l(&fd->o_fileln);
		/* fd->o_flag &= ~O_DIRTY; BUG: missing */
	}

	if ((!part) || (part & CL_FULL))
	{
		q = &fd->o_dnode->d_files;

		for (p = *q; p; p = *(q = &p->o_link))
			if (p == fd)
				break;

		/* someone else has this file open */

		if (p)
			*q = p->o_link;
		else
			return E_INTRN;			/* some kind of internal error */
	}

#if GEMDOS >= 0x18
	/* only flush to appropriate drive */
	flushall();
#else
	for (i = BI_FAT; i < BI_DIR + 1; i++)
	{
		for (b = bufl[i]; b != NULL; b = b->b_link)
			flushbcb(b);
	}
#endif

	return E_OK;
}


/*
 *  flush -
 *
 *	Last modified	SCC	10 Apr 85
 *
 *	NOTE:	rwabs() is a macro that includes a longjmp() which is executed 
 *		if the BIOS returns an error, therefore flush() does not need 
 *		to return any error codes.
 */
/* 104de: 00fc4faa */
/* 106de: 00e0517a */
/* 100fr: 00fc56ca */
VOID flushbcb(P(BCB *) _b)
PP(BCB *_b;)
{
	register DMD *dm;				/*  media descr for buffer  */
	register BCB *b = _b;
	register int typ;
	register int drv;
	
	if (b->b_bufdrv == -1 || !b->b_dirty)
	{
		b->b_bufdrv = -1;
		return;
	}

	dm = b->b_dm;
	typ = b->b_buftyp;
	drv = b->b_bufdrv;
	b->b_bufdrv = -1;
	rwabsw(b->b_bufr, 1, b->b_bufrec + dm->m_recoff[typ], drv);
	/* flush to both fats */
	if (typ == BT_FAT)
	{
		rwabsw(b->b_bufr, 1, b->b_bufrec + dm->m_recoff[BT_FAT] - dm->m_fsiz, drv);
	}
	
	b->b_bufdrv = drv;					/* re-validate */
	b->b_dirty = 0;
}


/*
 *  usrio -
 *
 *	Last modified	SCC	10 Apr 85
 *
 *	NOTE:	rwabs() is a macro that includes a longjmp() which is executed 
 *		if the BIOS returns an error, therefore usrio() does not need 
 *		to return any error codes.
 */
/* 104de: 00fc50c0 */
/* 100fr: 00fc57b2 */
static VOID usrio(P(int) wrtflg, P(RECNO) count, P(RECNO) recno, P(char *)buf, P(DMD *)dmd)
PP(int wrtflg;)
PP(RECNO count;)
PP(RECNO recno;)
PP(char *buf;)
PP(DMD *dmd;)
{
	register BCB *b;
	
	for (b = bufl[BI_DATA]; b != NULL; b = b->b_link)
		if (dmd->m_drvnum == b->b_bufdrv && b->b_bufrec >= recno && b->b_bufrec < (recno + count))
		{
			flushbcb(b);
#if GEMDOS >= 0x15
			b->b_bufdrv = -1;
#endif
		}
	rwabs(wrtflg, buf, count, dmd->m_recoff[BT_DATA] + recno, dmd->m_drvnum);
}


/*
 *  getrec -
 *	return the ptr to the buffer containing the desired record
 */

/* 306de: 00e1473e */
/* 306us: 00e146e4 */
/* 104de: 00fc516a */
/* 106de: 00e0553a */
/* 100fr: 00fc5858 */
char *getrec(P(RECNO) recno, P(DMD *)dm, P(int) wrtflg)
PP(RECNO recno;)
PP(register DMD *dm;)
PP(int wrtflg;)
{
	register BCB *b;
	register int typ;
	register CLNO cl;
	register int err;
#if GEMDOS >= 0x18
	register int drv;
	BCB *mtbuf;
	register BCB *p;
	BCB **q;
	BCB **phdr;
	CLNL cl;
#else
	BCB *p;
	BCB *mtbuf;
	BCB **q;
	BCB **phdr;
#endif
	
#if GEMDOS >= 0x18
	drv = dm->m_drvnum;
#else
#define drv dm->m_drvnum
#endif
	cl = recno >> dm->m_clrlog;			/*  calculate cluster nbr   */
	if (cl < dm->m_dtl->d_strtcl)
	{
		typ = BT_FAT;
	} else if (recno < 0)
	{
		typ = BT_ROOT;
	} else
	{
		typ = BT_DATA;
	}
	
	mtbuf = NULL;
	phdr = &bufl[typ != BT_FAT];

	/*
	 *  see if the desired record for the desired drive is in memory.
	 * if it is, we will use it.  Otherwise we will use
	 *     the last invalid (available) buffer,  or
	 *     the last (least recently) used buffer.
	 */

	for (b = *(q = phdr); b; b = *(q = &b->b_link))
	{
		if (b->b_bufdrv == drv && b->b_bufrec == recno)
			break;
		/*  
		 *  keep track of the last invalid buffer
		 */
		if (b->b_bufdrv == -1)			/*  if buffer not valid */
			mtbuf = b;					/*    then it's 'empty' */
	}


	if (!b)
	{
		/* 
		 *  not in memory.  If there was an 'empty; buffer, use it.
		 */
		if (mtbuf)
			b = mtbuf;

#if GEMDOS >= 0x18
		if (Mediach(drv) == MEDIAMAYCHANGE)
		{
			invalidate(drv);
		}
#endif

		/*
		 *  find predecessor of mtbuf, or last guy in list, which
		 *  is the least recently used.
		 */

	doio:
		for (p = *(q = phdr); p->b_link; p = *(q = &p->b_link))
			if (b == p)
				break;
		b = p;

		/*
		 *  flush the current contents of the buffer, and read in the 
		 * new record.
		 */
#if GEMDOS >= 0x18
		if (b->b_bufdrv != -1 && b->b_dirty)
			flush(b);
		b->b_bufdrv = -1;					/* invalidate in case of error */
#else
		flushbcb(b);
#endif
		rwabs(0, b->b_bufr, 1, recno + dm->m_recoff[typ], drv);

		/*
		 *  make the new buffer current
		 */

		b->b_bufrec = recno;
		b->b_dirty = 0;
		b->b_buftyp = typ;
		b->b_bufdrv = drv;
		b->b_dm = dm;
	} else
	{									/* use a buffer, but first validate media */
		if ((err = Mediach(b->b_bufdrv)))
		{
#if GEMDOS >= 0x18
			if (err == MEDIAMAYCHANGE)
			{
				invalidate(b->b_bufdrv);
				goto doio;				/* media may be changed */
			} else
#else
			if (err == MEDIAMAYCHANGE)
				goto doio;				/* media may be changed */
#endif
			else if (err == MEDIACHANGE)
			{							/* media definitely changed */
				errdrv = b->b_bufdrv;
				rwerr = E_CHNG;			/* media change */
				xlongjmp(errbuf, rwerr);
			}
		}
	}

	/*
	 *  now put the current buffer at the head of the list
	 */

	*q = b->b_link;
	b->b_link = *phdr;
	*phdr = b;

	/*
	 *  if we are writing to the buffer, dirty it.
	 */

	if (wrtflg)
		b->b_dirty = 1;

	return b->b_bufr;

#undef drv
}


/*
 *  makofd -
 */

/* 306de: 00e161de */
/* 306us: 00e16184 */
/* 104de: 00fc6c00 */
/* 100fr: 00fc59fc */
OFD *makofd(P(DND *) _p)
PP(DND *_p;)
{
	register OFD *f;
	register DND *p;
	
	p = _p;
	if ((f = MGET(OFD)) == NULL)
		return NULL;

	f->o_strtcl = p->d_strtcl;
	f->o_fileln = 0x7fffffffL;
	f->o_dirfil = p->d_dirfil;
	f->o_dnode = p->d_parent;
	f->o_dirbyt = p->d_dirpos;
	f->o_td.date = p->d_td.date;
	f->o_td.time = p->d_td.time;
	f->o_dmd = p->d_drv;
#if 0 /* BUG: missing */
	f->o_link = NULL;
	f->o_flag = 0;
#endif

	return f;
}



/*
 *  match - utility routine to compare file names
 */

/* 306de: 00e1737c */
/* 306us: 00e17322 */
/* 104de: 00fc7d9e */
/* 100fr: 00fc5a5a */
BOOLEAN match(P(const char *) s1, P(const char *) s2)
PP(register const char *s1;)							/*  name we are checking        */
PP(register const char *s2;)									/*  name in fcb             */
{
	register int i;

	/*
	 *  check for deleted entry.  wild cards don't match deleted entries,
	 *  only specific requests for deleted entries do.
	 */

	if (*s2 == 0xe5)
	{
		if (*s1 == '?')
			return FALSE;
		else if (*s1 == 0xe5)
			return TRUE;
	}

	/*
	 *  compare names
	 */

	for (i = 0; i < 11; i++, s1++, s2++)
		if (*s1 != '?')
			if (uc(*s1) != uc(*s2))
				return FALSE;

	/*
	 *  check attribute match
	 * volume labels and subdirs must be specifically asked for
	 */
	if (*s1 != FA_LABEL /* && *s1 != FA_DIREC */)
		if (*s2 == 0)
			return TRUE;

	return *s1 & *s2 ? TRUE : FALSE;
}


/*
 *  builds -
 *
 *	Last modified	LTG	23 Jul 85
 */

/* 306de: 00e17424 */
/* 306us: 00e173ca */
/* 104de: 00fc7e46 */
/* 106de: 00e08016 */
/* 100fr: 00fc5ae8 */
VOID builds(P(const char *) s1, P(char *) s2)
PP(register char *s1;)							/*  source          */
PP(register char *s2;)									/*  s2 dest         */
{
	register int i;
	register char c;

	for (i = 0; (i < 8) && (*s1) && (*s1 != '*') && (*s1 != SLASH) && (*s1 != '.') && (*s1 != ' '); i++)
		*s2++ = uc(*s1++);

	if (i == 8)
		while (*s1 && (*s1 != '.') && (*s1 != SLASH))
			s1++;

	c = ((*s1 == '*') ? '?' : ' ');

	if (*s1 == '*')
		s1++;

	if (*s1 == '.')
		s1++;

	for (; i < 8; i++)
		*s2++ = c;

	for (i = 0; (i < 3) && (*s1) && (*s1 != '*') && (*s1 != SLASH) && (*s1 != '.') && (*s1 != ' '); i++)
		*s2++ = uc(*s1++);

	c = ((*s1 == '*') ? '?' : ' ');

	for (; i < 3; i++)
		*s2++ = c;
}


/*
 *  getpath - get a path element
 *	The buffer pointed to by 'd' must be at least the size of the file
 *	spec buffer in a directory entry (including file type), and will
 *	be filled with the directory style format of the path element if
 *	no error has occurred.
 *
 *  returns
 *	-1 if '.'
 *	-2 if '..'
 *	 0 if p => name of a file (no trailing SLASH or !dirspec)
 *	>0 (nbr of chars in path element (up to SLASH)) && buffer 'd' filled.
 *
 */

/* 306de: 00e17508 */
/* 306us: 00e174ae */
/* 104de: 00fc7f2a */
/* 100fr: 00fc5bc8 */
int getpath(P(const char *) p, P(char *) d, P(int) dirspec)
PP(register const char *p;)								/*  start of path element to crack  */
PP(register char *d;)									/*  ptr to destination buffer       */
PP(int dirspec;)							/*  true = no file name, just dir path  */
{
	register int i, i2;
	register const char *p1;

	for (i = 0, p1 = p; *p1; p1++, i++)
		if (*p1 == SLASH)
			break;

	/*
	 *  If the string we have just scanned over is a directory name, it
	 * will either be terminated by a SLASH, or 'dirspec' will be set
	 * indicating that we are dealing with a directory path only
	 * (no file name at the end).
	 */

	if (*p1 != '\0' || dirspec)
	{									/*  directory name  */
		if ((i2 = contains_dots(p, *p1)) < 0)
			return i2;
		if (i)							/*  if not null path el */
			builds(p, d);				/*  d => dir style fn   */

		return i;						/*  return nbr chars    */
	}

	return 0;							/*  if string is a file name        */
}


/*
 *  xread -
 *	read 'len' bytes  from handle 'h'
 *
 *	Function 0x3F	Fread
 *
 *	Error returns
 *		EIHNDL
 *		bios()
 *
 *	Last modified	SCC	8 Apr 85
 */

/* 306de: 00e170f0 */
/* 306us: 00e17096 */
/* 104de: 00fc7b12 */
/* 100fr: 00fc5c2a */
ERROR xread(P(int16_t) h, P(long) len, P(VOIDPTR) ubufr)
PP(int16_t h;)
PP(long len;)
PP(VOIDPTR ubufr;)
{
	register OFD *p;

	if ((p = getofd(h)) != NULL)
	{
		return ixread(p, len, ubufr);
	}
	
	return E_IHNDL;
}


/*
 *  ixread -
 *
 *	Last modified	SCC	26 July 85
 */

/* 306de: 00e16236 */
/* 306us: 00e161dc */
/* 104de: 00fc6c58 */
/* 100fr: 00fc5c5c */
ERROR ixread(P(OFD *)p, P(long) len, P(VOIDPTR) ubufr)
PP(register OFD *p;)
PP(register long len;)
PP(register VOIDPTR ubufr;)
{
	register long maxlen;

#if 0 /* WTF? why has this been disabled? */
	/* Make sure file not opened as write only. */
	if (p->o_mod == WO_MODE)
		return E_ACCDN;
#endif

	if (len > (maxlen = p->o_fileln - p->o_bytnum))
		len = maxlen;

	if (len > 0)
	{
		return xrw(0, p, len, ubufr, xfr2usr);
	}
	return 0;						/* zero bytes read for zero requested */
}



/*
 * [1]	We play games here (thanx, Jason).  The ixwrite() call will essentially
 *	copy the time, date, cluster, and length fields from the OFD of the
 *	(dir) file we are closeing to the FCB for this (dir) file in the 
 *	parent dir.  The fileln field of this dir is thus set to 0.  But if 
 *	this is a directory we are closing (path & CL_DIR), shouldn't the 
 *	fileln be zero anyway?  I give up.
 *					- ktb
 */



/*
 *  xwrite -
 *	write 'len' bytes to handle 'h'.
 *
 *	Function 0x40	Fwrite
 *
 *	Error returns
 *		EIHNDL
 *		bios()
 *
 *	Last modified	SCC	10 Apr 85
 */

/* 306de: 00e17130 */
/* 306us: 00e170d6 */
/* 104de: 00fc7b52 */
/* 100fr: 00fc5caa */
ERROR xwrite(P(FH) h, P(long) len, P(VOIDPTR) ubufr)
PP(FH h;)
PP(long len;)
PP(VOIDPTR ubufr;)
{
	register OFD *p;

	if ((p = getofd(h)) != NULL)
	{
#if 0
		if (len == 0)
			return 0;
		p->o_flag |= O_DIRTY;
#endif
#if 0
		/* WTF? why has this been disabled? */
		/* Make sure not read only. */
		if (p->o_mod == RO_MODE)
			return E_ACCDN;
#endif
		return ixwrite(p, len, ubufr);
	}

	return E_IHNDL;
}


/*
 *  ixwrite -
 */

/* 306de: 00e16286 */
/* 306us: 00e1622c */
/* 104de: 00fc6ca8 */
/* 100fr: 00fc5cdc */
ERROR ixwrite(P(OFD *) p, P(long) len, P(VOIDPTR) ubufr)
PP(OFD *p;)
PP(long len;)
PP(VOIDPTR ubufr;)
{
	return xrw(1, p, len, ubufr, usr2xfr);
}



/*
 *  clfix -
 *	replace the contents of the fat entry indexed by 'cl' with the value
 *	'link', which is the index of the next cluster in the chain.
 */

/* 306de: 00e1498a */
/* 306us: 00e14930 */
/* 104de: 00fc5380 */
/* 100fr: 00fc5d04 */
VOID clfix(P(CLNO) cl, P(CLNO) link, P(DMD *) dm)
PP(register CLNO cl;)
PP(CLNO link;)
PP(register DMD *dm;)
{
	CLNO f[1];
	CLNO mask;
	register long pos;
	
	if (dm->m_16)
	{
		swp68((uint16_t *)&link);
		pos = (long) (cl << 1); /* BUG: cast too late */
		ixlseek(dm->m_fatofd, pos);
		ixwrite(dm->m_fatofd, 2L, &link);
		return;
	}
	
	pos = (cl + (cl >> 1));

	link = link & 0x0fff;

	if (cl & 1)
	{
		link = link << 4;
		mask = 0x000f;
	} else
	{
		mask = 0xf000;
	}
	
	ixlseek(dm->m_fatofd, pos);

	/* pre -read */
	ixread(dm->m_fatofd, 2L, f);

	swp68((uint16_t *)&f[0]);
	f[0] = (f[0] & mask) | link;
	swp68((uint16_t *)&f[0]);

	ixlseek(dm->m_fatofd, pos);
	ixwrite(dm->m_fatofd, 2L, f);
}


/*
 *  getcl -
 *	get the contents of the fat entry indexed by 'cl'.
 *
 *  returns
 *	0xffff if entry contains the end of file marker
 *	otherwise, the contents of the entry (16 bit value always returned).
 */

/* 306de: 00e14b62 */
/* 306us: 00e14b08 */
/* 104de: 00fc5558 */
/* 100fr: 00fc5dfa */
CLNO getcl(P(CLNO) cl, P(DMD *) dm)
PP(register CLNO cl;)
PP(register DMD *dm;)
{
	uint16_t f[1];
	
	if (cl < 0 /* && cl >= dm->m_dtl->d_strtcl */)
	{
		return cl + 1;
	}

	if (dm->m_16)
	{
		ixlseek(dm->m_fatofd, (long) (cl << 1)); /* BUG: cast too late */
		ixread(dm->m_fatofd, 2L, f);
		swp68(&f[0]);
		return f[0];
	}
	ixlseek(dm->m_fatofd, ((long) (cl + (cl >> 1))));
	ixread(dm->m_fatofd, 2L, f);
	swp68(&f[0]);
	if (cl & 1)
		cl = f[0] >> 4;
	else
		cl = 0x0fff & f[0];
	if (cl == 0x0fff) /* BUG: should mask */
		return -1;
	return cl;
}




/*
 *  nextcl -
 *	get the cluster number which follows the cluster indicated in the curcl
 *	field of the OFD, and place it in the OFD.
 *
 *  returns
 *	E_OK	if success,
 *	-1	if error
 */

/* 306de: 00e14d1a */
/* 306us: 00e14cc0 */
/* 104de: 00fc5710 */
/* 100fr: 00fc5eb4 */
int nextcl(P(OFD *) _p, P(int) wrtflg)
PP(OFD *_p;)
PP(int wrtflg;)
{
	register DMD *dm;
	register OFD *p;
	register CLNO i;
	register CLNO cl;
	register CLNO cl2;
	register CLNO rover;
	
	p = _p;
	cl = p->o_curcl;
	dm = p->o_dmd;

	if (cl < 0)
	{
		cl2 = cl + 1;
		goto retcl;
	}
	if (cl > 0)
		cl2 = getcl(cl, dm);
	if (cl == 0)
		cl2 = p->o_strtcl ? p->o_strtcl : ENDOFCHAIN;
	
	if (wrtflg && endofchain(cl2))
	{									/* end of file, allocate new clusters */
		rover = cl;
		for (i = 2; i < dm->m_numcl; i++)
		{
			if (rover < 2)
				rover = 2;

			if (!(cl2 = getcl(rover, dm)))
				break;
			rover = (rover + 1) % dm->m_numcl;
		}

		cl2 = rover;

		if (i < dm->m_numcl)
		{
			clfix(cl2, ENDOFCHAIN, dm);
			if (cl != 0)
			{
				clfix(cl, cl2, dm);
			} else
			{
				p->o_strtcl = cl2;
				p->o_flag |= O_DIRTY;
			}
		} else
		{
			return -1;
		}
	}

	if (endofchain(cl2))
		return -1;

retcl:
	p->o_curcl = cl2;
	p->o_currec = cl2rec(cl2, dm);
	p->o_curbyt = 0;

	return 0L;
}


/*
 *  addit -
 *	update the OFD for the file to reflect the fact that 'siz' bytes
 *	have been written to it.
 */

/* 306de: 00e14ece */
/* 306us: 00e14e74 */
/* 104de: 00fc58c4 */
/* 100fr: 00fc5f98 */
static VOID addit(P(OFD *) p, P(long) siz, P(int) flg)
PP(register OFD *p;)
PP(long siz;)
PP(int flg;)								/* update curbyt ? (yes if less than 1 cluster transferred) */
{
	p->o_bytnum += siz;

	if (flg)
		p->o_curbyt += siz;

	if (p->o_bytnum > p->o_fileln)
	{
		p->o_fileln = p->o_bytnum;
		p->o_flag |= O_DIRTY;
	}
}


/*
 *  xrw - read/write 'len' bytes from/to the file indicated by the OFD at 'p'.
 *
 *  details
 *	We wish to do the i/o in whole clusters as much as possible.
 *	Therefore, we break the i/o up into 5 sections.  Data which occupies 
 *	part of a logical record (e.g., sector) with data not in the request 
 *	(both at the start and the end of the the request) are handled
 *	separateley and are called header (tail) bytes.  Data which are
 *	contained complete in sectors but share part of a cluster with data not
 *	in the request are called header (tail) records.  These are also
 *	handled separately.  In between handling of header and tail sections,
 *	we do i/o in terms of whole clusters.
 *
 *  returns
 *	nbr of bytes read/written from/to the file.
 */

/* 306de: 00e14f10 */
/* 306us: 00e14eb6 */
/* 104de: 00fc5906 */
/* 106de: 00e05ad6 */
/* 100fr: 00fc5fda */
ERROR xrw(P(int) wrtflg, P(OFD *) _p, P(long) len, P(char *) ubufr, P(xfer) bufxfr)
PP(int wrtflg;)
PP(OFD *_p;)
PP(long len;)
PP(char *ubufr;)
PP(xfer bufxfr;)
{
	register DMD *dm;
	register OFD *p;
	char *bufp;
	int16_t bytn;
	RECNO recn;
	int recsiz;
	int lenxfr;
	int clsiz;
	int clsizb;
	CLNO curcl;
	int lentail;
	RECNO num;
	RECNO hdrrec;
	int lsiz;
	RECNO tailrec;
	int last;
	RECNO nrecs;
	int lflg;
	long nbyts;
	long rc;
	long bytpos;
	long lenrec;
	long lenmid;
	
	/*
	 *  determine where we currently are in the file
	 */

	p = _p;
	dm = p->o_dmd;						/* get drive media descriptor */

	recsiz = dm->m_recsiz;				/* inefficient: will already be accessed through register var */
	clsiz = dm->m_clsiz;				/* " */
	clsizb = dm->m_clsizb;				/* " */
	bytpos = p->o_bytnum;				/* starting file position */
	curcl = p->o_curcl;
	UNUSED(curcl);

	/*
	 *  get logical record number to start i/o with
	 * (bytn will be byte offset into sector # recn)
	 */

	DIVMOD(recn, bytn, p->o_curbyt, dm->m_rblog);
	recn += p->o_currec;

	/*
	 *  determine "header" of request.
	 */

	if (bytn)							/* do header */
	{									/*
										 *  xfer len is
										 * min( #bytes req'd , #bytes left in current record )
										 */
		lenxfr = min(len, recsiz - bytn);
		bufp = getrec(recn, dm, wrtflg);	/*  get desired record  */
		addit(p, (long) lenxfr, 1);		/*  update ofd      */
		len -= lenxfr;					/*  nbr left to do  */
		recn++;							/*    starting w/ next  */

		if (!ubufr)
		{
			rc = (long) (bufp + bytn);	/* return buffer address instead */
			goto exit;
		}

		(*bufxfr) (lenxfr, bufp + bytn, ubufr);
		ubufr += lenxfr;
	}

	/*
	 *  "header" complete.  See if there is a "tail".  
	 *  After that, see if there is anything left in the middle.
	 */

	lentail = len & dm->m_rbm;
	
	if ((lenmid = len - lentail) != 0)			/*  Is there a Middle ? */
	{
		hdrrec = recn & dm->m_clrm;

		if (hdrrec)
		{
			/*  if hdrrec != 0, then we do not start on a clus bndy;
			 * so determine the min of (the nbr sects 
			 * remaining in the current cluster) and (the nbr 
			 * of sects remaining in the file).  This will be 
			 * the number of header records to read/write.
			 */
			
#if 0
			hdrrec = (dm->m_clsiz - hdrrec);	/* M00.14.01 */
			if (hdrrec > lenmid >> dm->m_rblog)	/* M00.14.01 */
				hdrrec = lenmid >> dm->m_rblog;	/* M00.14.01 */
#endif

			usrio(wrtflg, hdrrec, recn, ubufr, dm);
			ubufr += (lsiz = hdrrec << dm->m_rblog);
			lenmid -= lsiz;
			addit(p, (long) lsiz, 1);
		}

		/* 
		 *  do whole clusters 
		 */

		lenrec = lenmid >> dm->m_rblog;	/* nbr of records  */
		DIVMOD(num, tailrec, lenrec, dm->m_clrlog);	/* nbr of clusters */

		last = nrecs = nbyts = lflg = 0;

		while (num--)					/*  for each whole cluster...   */
		{
			rc = nextcl(p, wrtflg);

			/* 
			 *  if eof or non-contiguous cluster, or last cluster 
			 * of request, 
			 * then finish pending I/O 
			 */

			if (!rc && p->o_currec == (last + nrecs))
			{
				nrecs += clsiz;
				nbyts += clsizb;
				if (!num)
					goto mulio;
			} else
			{
				if (!num)
					lflg = 1;
			mulio:
			 	if (nrecs)
					usrio(wrtflg, nrecs, last, ubufr, dm);
				ubufr += nbyts;
				addit(p, nbyts, 0);
				if (rc)
					goto eof;
				last = p->o_currec;
				nrecs = clsiz;
				nbyts = clsizb;
				if (!num && lflg)
				{
					lflg = 0;
					goto mulio;
				}
			}
		}

		/* 
		 *  do "tail" records 
		 */

		if (tailrec)
		{
			if (nextcl(p, wrtflg))
				goto eof;
			lsiz = tailrec << dm->m_rblog;
			addit(p, (long) lsiz, 1);
			usrio(wrtflg, tailrec, p->o_currec, ubufr, dm);
			ubufr += lsiz;
		}
	}

	/* 
	 * do tail bytes within this cluster 
	 */

	if (lentail)
	{
		DIVMOD(recn, bytn, p->o_curbyt, dm->m_rblog);

		if (!recn || recn == clsiz)
		{
			if (nextcl(p, wrtflg))
				goto eof;
			recn = 0;
		}

		bufp = getrec(p->o_currec + recn, dm, wrtflg);
		addit(p, (long) lentail, 1);

		if (!ubufr)
		{
			rc = (long) bufp;
			goto exit;
		}

#if BINEXACT
		/* BUG too many arguments */
		(*bufxfr) (lentail, bufp, ubufr, wrtflg);
#else
		(*bufxfr) (lentail, bufp, ubufr);
#endif
	}
	/*  end tail bytes  */
eof:
	rc = p->o_bytnum - bytpos;
exit:
 	return rc;
}



/*
 *  GetDnd - find a dnd with matching name
 */

static DND *GetDnd(P(DND *) d, P(FCB *) fcb)
PP(register DND *d;)								/*  name of file in FCB format      */
PP(register FCB *fcb;)									/*  root where we start the search  */
{
	register DND *dnd;
	OFD *ofd;
	
	ofd = d->d_ofd;
	dnd = MGET(DND);
	if (dnd == NULL)
		return NULL;
	if (d->d_left)
		dnd->d_right = d->d_left;
	d->d_left = dnd;
	dnd->d_parent = d;
	dnd->d_ofd = NULL;
	dnd->d_strtcl = fcb->f_clust;
	swp68((uint16_t *)&dnd->d_strtcl);
	dnd->d_drv = d->d_drv;
	dnd->d_dirfil = ofd;
	dnd->d_dirpos = ofd->o_bytnum - sizeof(FCB);
	dnd->d_td.time = fcb->f_td.time;
	dnd->d_td.date = fcb->f_td.date;
	xmovs(11, fcb->f_name, dnd->d_name);
	return dnd;
}


/*
 * [1]	The first call to dirscan is if there are no children logged in.
 *	However, we need to call dirscan if children are logged in and we still
 *	didn't find the desired node, as the desired child may've been flushed.
 *	This is a terrible thing to have happen to a child.  However, we can't
 *	afford to have all these kids around here, so when new ones come in, we
 *	see which we can flush out (see makdnd()).  This is a hack -- no doubt
 *	about that; the cached DND scheme needs to be redesigned all around.
 *	Anyway, the second call to dirscan backs up to the parent (note that n
 *	has not yet been bumped, so is still pointing to the current subdir's
 *	name -- in effect, starting us at this level all over again.
 *			-- ktb
 */

/*
 *  scan - scan a directory for an entry with the desired name.
 *	scans a directory indicated by a DND.  attributes figure in matching
 *	as well as the entry's name.  posp is an indicator as to where to start
 *	searching.  A posp of -1 means to use the scan pointer in the dnd, and
 *	return the pointer to the DND, not the FCB.
 */

/* 306de: 00e15580 */
/* 306us: 00e15526 */
/* 104de: 00fc5f76 */
/* 106de: 00e06146 */
/* 100fr: 00fc63fe */
FCB *scan(P(DND *) dnd, P(const char *) n, P(int16_t) att, P(int32_t *) posp)
PP(register DND *dnd;)
PP(const char *n;)
PP(int att;)
PP(int32_t *posp;)
{
	DND *dnd1;
	register OFD *fd;
	register FCB *fcb;
	BOOLEAN m;					/*  T: found a matching FCB     */
	int cmp;
	long pos;
	char name[12];

	m = 0;								/*  have_match = false          */
	builds(n, name);					/*  format name into dir format     */
	name[11] = att;

	/*
	 *  if there is no open file descr for this directory, make one
	 */

	if (!(fd = dnd->d_ofd))
	{
		if (!(dnd->d_ofd = fd = makofd(dnd)))
			return NULL;
	}

	/*
	 *  seek to desired starting position.  If posp == -1, then start at
	 * the beginning.
	 */
	if ((pos = *posp) == -1)
		pos = dnd->d_scan;
	ixlseek(fd, pos);

	/*
	 *  scan thru the directory file, looking for a match
	 */
	cmp = 0;
	for (dnd1 = dnd->d_left; dnd1 != NULL; dnd1 = dnd1->d_right)
		if ((cmp = xcmps(name, dnd1->d_name)) != 0)
			break;

	while ((fcb = (FCB *) ixread(fd, (long)sizeof(FCB), NULL)) && fcb->f_name[0])
	{
		/*
		 *  Add New DND.
		 *  ( iff after scan ptr && complete flag not set && not a .
		 *  or .. && subdirectory && not deleted )
		 */

		if (fd->o_bytnum > dnd->d_scan && !(fd->o_flag & 2) && fcb->f_name[0] != '.' && (fcb->f_attrib & FA_DIREC) && fcb->f_name[0] != ERASE_MARKER)
		{								/*  see if we already have it  */
			if (xcmps(name, fcb->f_name) == 0 || cmp == 0)
				if (!(dnd1 = GetDnd(dnd, fcb)))
					return NULL;
		}
		
		if ((m = match(name, fcb->f_name)) != 0)
			break;
	}

	/* restore directory scanning pointer */

	if (*posp == -1L)
	{
		if (fd->o_bytnum > dnd->d_scan)
			dnd->d_scan = fd->o_bytnum;
	} else
	{
		*posp = fd->o_bytnum;
	}
	
	/*
	 *  if there was no match, but we were looking for a deleted entry,
	 *  then return a pointer to a deleted fcb.  Otherwise, if there was
	 *  no match, return a null pointer
	 */

	if (!m)
	{									/*  assumes that (*n != 0xe5) (if posp == -1)  */
		if (fcb && *n == ERASE_MARKER)
			return fcb;
		fd->o_flag |= 2;
		return NULL;
	}

	if (*posp == -1)
	{									/*  seek to position of found entry  */
		ixlseek(fd, fd->o_bytnum - sizeof(FCB));
		return (FCB *)dnd1;
	}

	return fcb;
}


/*
 *  ckdrv - check the drive, see if it needs to be logged in.
 *
 *  returns:
 *	ERR	if Getbpb() failed
 *	ENSMEM	if login() failed
 *	EINTRN	if no room in dirtbl
 *	drive nbr if success.
 */

/* 306de: 00e152e2 */
/* 306us: 00e15288 */
/* 104de: 00fc5cd8 */
/* 100fr: 00fc65a0 */
ERROR ckdrv(P(int) d)
PP(int d;)									/* has this drive been accessed, or had a media change */
{
	register drvmask mask;
	register int i;
	register BPB *b;
	
	mask = DRVMASK(d);

	if (!(mask & drvsel))
	{									/*  drive has not been selected yet  */
		b = Getbpb(d);

		if (!b)
			return ERR;
#if 0
		if ((ERROR) b < 0)
			return (ERROR) b;
#endif

		if (login(b, d))
			return E_NSMEM;

		drvsel |= mask;
	}

	if ((!run->p_curdir[d]) || (!dirtbl[run->p_curdir[d]]))
	{									/* need to allocate current dir on this drv */

		for (i = 1; i < NCURDIR; i++)	/*  find unused slot    */
			if (!diruse[i])
				break;

		/* no slot available */
		if (i == NCURDIR)
			return ERR;
		diruse[i]++;					/*  mark as used    */
		dirtbl[i] = drvtbl[d]->m_dtl;	/*  link to DND     */
		run->p_curdir[d] = i;			/*  link to process */
	}

	return d;
}



/*
 *  dcrack - parse out start of 1st path element, get DND
 *	if needed, logs in the drive specified (explicitly or implicitly) in
 *	the path spec pointed to by 'np', parses out the first path element
 *	in that path spec, and adjusts 'np' to point to the first char in that
 *	path element.
 *
 *  returns
 *	ptr to DND for 1st element in path, or
 *	error
 */

/* 306de: 00e156b4 */
/* 306us: 00e1565a */
/* 104de: 00fc60aa */
/* 100fr: 00fc669e */
static DND *dcrack(P(const char **) np)
PP(const char **np;)
{
	register const char *n;
	register DND *p;
	register int d;

	/*
	 *  get drive spec (or default) and make sure drive is logged in
	 */

	n = *np;							/*  get ptr to name     */
	if (n[1] == ':')					/*  if we start with drive spec */
	{
		d = uc(n[0]) - 'A';				/*    compute drive number  */
		n += 2;							/*    bump past drive number    */
	} else								/*  otherwise           */
	{
		d = run->p_curdrv;				/*    assume default        */
	}
	
	if (ckdrv(d) < 0)					/*  check for valid drive & log */
		return NULL;					/*    in.  abort if error   */

	/*
	 *  if the pathspec begins with SLASH, then the first element is
	 *  the root.  Otherwise, it is the current default directory.  Get
	 *  the proper DND for this element
	 */

	if (*n == SLASH)
	{									/* [D:]\path */
		p = drvtbl[d]->m_dtl;			/*  get root dir for log drive  */
		n++;							/*  skip over slash     */
	} else
	{
		p = dirtbl[run->p_curdir[d]];	/*  else use curr dir   */
	}
	
	/* whew ! */ /*  <= thankyou, Jason, for that wonderful comment */

	*np = n;
	return p;
}


/*
 *  findit - find a file/dir entry
 */

/* 306de: 00e15750 */
/* 306us: 00e156f6 */
/* 104de: 00fc6146 */
/* 100fr: 00fc672e */
DND *findit(P(const char *) name, P(const char **) sp, P(int) dflag)
PP(const char *name;)								/*  name of file/dir            */
PP(const char **sp;)
PP(int dflag;)								/*  T: name is for a directory      */
{
	register DND *p;
	const char *n;
	register DND *pp;
	DND *newp;
	register int i;
	char *cp;
	char s[11];

	/* crack directory and drive */

	n = name;

	if ((p = dcrack(&n)) == NULL)
		return p;

	/*
	 *  Force scan() to read from the beginning of the directory again,
	 *  since we have gone to a scheme of keeping fewer DNDs in memory.
	 */

	do
	{
		if (!(i = getpath(n, s, dflag)))
			break;

		if (i < 0)
		{								/*  path is '.' or '..'  */
			if (i == -2)				/*  go to parent (..)  */
				p = p->d_parent;

			i = -i;						/*  num chars is 1 or 2  */
			goto scanxt;
		}
		
#if 0
		cp = &s[11];
		while (cp > s)
			if (*--cp == '?')
				return NULL;
#endif
		UNUSED(cp);
		
		/*
		 * go down a level in the path...
		 * save a pointer to the current DND, which will
		 * become the parent, and get the node on the left,
		 * which is the first child.
		 */

		if (!(newp = p->d_left))
		{								/*  [1]         */
			/*  make sure children  */
			newp = dirscan(p, n);		/*  are logged in   */
		}

		pp = p;							/*  save ptr to parent dnd  */

		if (!(p = newp))				/*  If no children, exit loop */
			break;

		/*
		 *  check all subdirectories at this level.  if we run out
		 * of siblings in the DND list (p->d_right == NULL), then
		 * we should rescan the whole directory and make sure they
		 * are all logged in.
		 */

		while (p && (xcmps(s, p->d_name) == FALSE))
		{
			if (!(newp = p->d_right))			/*  next sibling    */
			{
				/* if no more siblings  */
				p = 0;
				if (pp && !(pp->d_ofd->o_flag & 2))
				{
					p = dirscan(pp, n);
				}
			} else
				p = newp;
		}

	scanxt:
		if (*(n = n + i))
			n++;
		else
			break;
	} while (p && i);

	/* p = 0 ==> not found
	   i = 0 ==> found at p (dnd entry)
	   n = points at filename */

	*sp = n;

	return p;
}


/*
 *  xchdir - change current dir to path p (extended cd n:=[a:][\bin])
 *
 *	Function 0x3B	Dsetpath
 *
 *	Error returns
 *		EPTHNF
 *		ckdrv()
 */

/* 306de: 00e15876 */
/* 306us: 00e1581c */
/* 104de: 00fc626c */
/* 100fr: 00fc6840 */
ERROR xchdir(P(const char *) p)
PP(const char *p;)
{
	long l;
	register int dr;
	register int i;
	register int dlog;
	const char *s;

	UNUSED(i);
	if (p[1] == ':')
	{
		dlog = uc(p[0]) - 'A';
		p += 2;
	} else
	{
		dlog = run->p_curdrv;
	}

	if ((l = ckdrv(dlog)) < 0)
		return l;

	/* find space in dirtbl */
	if ((dr = run->p_curdir[dlog]))
	{
		--diruse[dr];					/* someone is still using it */
	}

	for (dr = 1; dr < NCURDIR; dr++)
	{
		if (!diruse[dr])
			break;
	}
	if (dr >= NCURDIR)
		return E_PTHNF;

	/* BUG: if drive was specified in path this will call findit() on the current drive */
	if (!(l = (long) findit(p, &s, 1)))
		return E_PTHNF;

	diruse[dr]++;

	dirtbl[dr] = (DND *) l;

	run->p_curdir[dlog] = dr;

	return E_OK;
}


/*
 *  packit - pack into user buffer
 */

/* 306de: 00e17568 */
/* 306us: 00e1750e */
/* 104de: 00fc7f8a */
/* 100fr: 00fc6928 */
char *packit(P(const char *) s, P(char *) d)
PP(register const char *s;)
PP(register char *d;)
{
	register const char *s0;
	register int i;

	if (!(*s))
		goto pakok;

	s0 = s;
	for (i = 0; (i < 8) && (*s) && (*s != ' '); i++)
		*d++ = *s++;

	if (*s0 == '.')
		goto pakok;

	s = s0 + 8;							/* ext */

	if (*s != ' ')
		*d++ = '.';
	else
		goto pakok;

	for (i = 0; (i < 3) && (*s) && (*s != ' '); i++)
		*d++ = *s++;
  pakok:*d = 0;
	return d;
}


/*
 *  dopath -
 *
 */

/* 306de: 00e1761a */
/* 306us: 00e175c0 */
/* 104de: 00fc803c */
/* 100fr: 00fc6994 */
char *dopath(P(DND *) p, P(char *) buf)
PP(DND *p;)
PP(char *buf;)
{
	if (p->d_parent)
		buf = dopath(p->d_parent, buf);

	buf = packit(p->d_name, buf);
	*buf++ = SLASH;
	return buf;
}


/*
 *  xgetdir -
 *
 *	Function 0x47	Dgetpath
 *
 *	Error returns
 *		EDRIVE
 */

/* 306de: 00e15972 */
/* 306us: 00e15918 */
/* 104de: 00fc6368 */
/* 100fr: 00fc69dc */
ERROR xgetdir(P(char *) buf, P(int16_t) drv)					/*+ return text of current dir into specified buffer */
PP(char *buf;)
PP(int16_t drv;)
{
	register DND *p;

	drv = drv != 0 ? drv - 1 : run->p_curdrv;

	if (/* !(Drvmap() & DRVMASK(drv)) || */ ckdrv(drv) < 0)
	{
		*buf = 0;
		return E_DRIVE;
	}

	p = dirtbl[run->p_curdir[drv]];
	buf = dopath(p, buf);
	*--buf = 0;							/* null as last char, not slash */

	return E_OK;
}


/*
 *  xgetdta - Function 0x2F	Fgetdta
 */

/* 306de: 00e1720e */
/* 306us: 00e171b4 */
/* 104de: 00fc7c30 */
/* 106de: 00e07e00 */
/* 404: 00e1b57c */
/* 100fr: 00fc6a5c */
DTAINFO *xgetdta(NOTHING)							/*+ return address of dta */
{
	return run->p_xdta;
}


/*
 *  xsetdta - Function 0x1A	Fsetdta
 */

/* 306de: 00e17220 */
/* 306us: 00e171c6 */
/* 104de: 00fc7c42 */
/* 100fr: 00fc6a6e */
VOID xsetdta(P(DTAINFO *) addr)							/*+ set transfer address to addr */
PP(DTAINFO *addr;)
{
	run->p_xdta = addr;
}



/*
 *  xsetdrv - set default drive
 *	( 0 = A, etc )
 *	Function 0x0E	Dsetdrv
 */

/* 306de: 00e17234 */
/* 306us: 00e171da */
/* 104de: 00fc7c56 */
/* 100fr: 00fc6a82 */
ERROR xsetdrv(P(int16_t) drv)
PP(int16_t drv;)
{
	run->p_curdrv = drv;
	return Drvmap();
}


/*
 *  xgetdrv - get default drive
 *	(0 = A, etc )
 *
 *	Function 0x19	Dgetdrv
 *
 *	Last modified	SCC	1 May 85
 */

/* 306de: 00e17254 */
/* 306us: 00e171fa */
/* 104de: 00fc7c76 */
/* 100fr: 00fc6aa2 */
ERROR xgetdrv(NOTHING)
{
	return run->p_curdrv;
}


/*
 *  xsfirst - search first for matching name, into dta
 *
 *	Function 0x4E	Fsfirst
 *
 *	Error returns
 *		EFILNF
 */

/* 306de: 00e1726a */
/* 306us: 00e17210 */
/* 104de: 00fc7c8c */
/* 106de: 00e07e5c */
/* 100fr: 00fc6ab8 */
ERROR xsfirst(P(const char *) name, P(int16_t) att)
PP(const char *name;)
PP(int16_t att;)
{
	return ixsfirst(name, att, run->p_xdta);
}


/*
 *  ixsfirst - search for first dir entry that matches pattern
 *	search first for matching name, into specified address.  if
 *	address = 0L, caller wants search only, no buffer info
 *  returns:
 *	error code.
 */

/* 306de: 00e15e3a */
/* 306us: 00e15de0 */
/* 104de: 00fc6824 */
/* 100fr: 00fc6ad6 */
ERROR ixsfirst(P(const char *) name, P(int16_t) att, P(DTAINFO *)addr)
PP(const char *name;)								/*  name of file to match   */
PP(int16_t att;)							/*  attribute of file       */
PP(DTAINFO *addr;)						/*  ptr to dta info         */
{
	const char *s;
	char unused[12];
	DND *dn;
	int32_t pos;
	register FCB *f;

	UNUSED(unused);
	if (att != FA_LABEL)
		att |= FA_ARCH | FA_RDONLY;

	if ((dn = findit(name, &s, 0)) == NULL)
		return E_FILNF;

	/* now scan for filename from start of directory */

	pos = 0;

	if (dn)
	{
		if ((f = scan(dn, s, att, &pos)) == NULL)
			return E_FILNF;
	} else
		return E_FILNF;

	if (addr)
	{
		xmovs(12, s, addr->dt_name);
		addr->dt_attr = att;
		xmovs(sizeof(pos), &pos, addr->dt_pos);
		xmovs(sizeof(dn), &dn, addr->dt_dnd);
		makbuf(f, addr);
	}

	return E_OK;
}



/*
 *  xsnext -
 *	search next, return into dta
 *
 *	Function 0x4F	Fsnext
 *
 *	Error returns
 *		ENMFIL
 */

/* 306de: 00e15f20 */
/* 306us: 00e15ec6 */
/* 104de: 00fc690a */
/* 100fr: 00fc6bb6 */
ERROR xsnext(NOTHING)
{
	register FCB *f;
	DND *dnd;
	char attr;
	int32_t pos;
	
	xmovs(sizeof(dnd), run->p_xdta->dt_dnd, &dnd);
	xmovs(sizeof(pos), run->p_xdta->dt_pos, &pos);
	attr = run->p_xdta->dt_attr;

	f = scan(dnd, &run->p_xdta->dt_name[0], attr, &pos);

	/* has the DTA been initialized? */
	if (f == NULL)
		return E_NMFIL;
	
	xmovs(sizeof(pos), &pos, run->p_xdta->dt_pos);
	makbuf(f, run->p_xdta);
	return E_OK;
}


/*
 *  makbuf - copy info from FCB into DTA info area
 */

/* 306de: 00e159f6 */
/* 306us: 00e1599c */
/* 104de: 00fc63ec */
/* 100fr: 00fc6c7e */
VOID makbuf(P(FCB *) f, P(DTAINFO *) dt)
PP(FCB *f;)
PP(DTAINFO *dt;)
{
	register FCB *fp;
	register DTAINFO *dtp;
	register int i;
	
	UNUSED(fp);
	UNUSED(dtp);
	UNUSED(i);

	dt->dt_fattr = f->f_attrib;
	xmovs(sizeof(dt->dt_td), &f->f_td, &dt->dt_td); /* use of xmovs unneeded: both are aligned */
	swp68(&dt->dt_td.time);
	swp68(&dt->dt_td.date);
	xmovs(sizeof(dt->dt_fileln), &f->f_fileln, &dt->dt_fileln); /* use of xmovs unneeded: both are aligned */
	swp68l(&dt->dt_fileln);

#if 0
	if (f->f_attrib & FA_LABEL)
	{
		xmovs(11, f->f_name, dt->dt_fname);
		dt->dt_fname[11] = 0;
	} else
#endif
	{
		packit(f->f_name, dt->dt_fname);
	}
}


/*
 *  opnfil - does the real work in opening a file
 *
 *	Error returns
 *		ENHNDL
 *
 *	NOTES:
 *		make a pointer to the ith entry of sft 
 *		make i a register int.
 */

/* 306de: 00e17176 */
/* 306us: 00e1711c */
/* 104de: 00fc7b98 */
/* 100fr: 00fc6d1e */
ERROR opnfil(P(const FCB *) f, P(DND *) dn, P(int16_t) mod)
PP(const FCB *f;)
PP(DND *dn;)
PP(int16_t mod;)
{
	register FH i;
	register FH h;

	/* find free sft handle */
	for (i = 0; i < (OPNFILES - NUMSTD); i++)
		if (!sft[i].f_own)
			break;

	if (i == (OPNFILES - NUMSTD))
		return E_NHNDL;

	sft[i].f_own = run;
	sft[i].f_use = 1;
	h = i + NUMSTD;

	return makopn(f, dn, h, mod);
}



/*
 *  makopn - make an open file for sft handle h 
 *
 *	Last modified	SCC	8 Apr 85
 */

/* 306de: 00e162ae */
/* 306us: 00e16254 */
/* 104de: 00fc6cd0 */
/* 100fr: 00fc6d9e */
ERROR makopn(P(const FCB *) f, P(DND *) dn, P(FH) h, P(int16_t) mod)
PP(register const FCB *f;)
PP(DND *dn;)
PP(FH h;)
PP(int mod;)
{
	register OFD *p;
	register DMD *dm;
	register OFD *p2;
	int unused;
	
	UNUSED(unused);
	dm = dn->d_drv;

	if (!(p = MGET(OFD)))
		return E_NSMEM;

	p->o_mod = mod;						/*  set mode            */
	p->o_dmd = dm;						/*  link OFD to media       */
	sft[h - NUMSTD].f_ofd = p;
	p->o_usecnt = 0;					/*  init usage          */
	p->o_curcl = 0;						/*  init file pointer info  */
	p->o_curbyt = 0;					/*  "               */
	p->o_dnode = dn;					/*  link to directory       */
	p->o_dirfil = dn->d_ofd;			/*  link to dir's ofd       */
	p->o_dirbyt = dn->d_ofd->o_bytnum - sizeof(FCB);	/*  offset of fcb in dir */

	for (p2 = dn->d_files; p2; p2 = p2->o_link)
		if (p2->o_dirbyt == p->o_dirbyt)
			break;						/* same dir, same dcnt */

	p->o_link = dn->d_files;
	dn->d_files = p;

	if (p2)
	{									/* steal time,date,startcl,fileln */
		xmovs(12, &p2->o_td.time, &p->o_td.time);
		/* not used yet... */
		p2->o_thread = p;
	} else
	{
		p->o_strtcl = f->f_clust;		/*  1st cluster of file */
		swp68((uint16_t *)&p->o_strtcl);
		p->o_fileln = f->f_fileln;		/*  init length of file */
		swp68l(&p->o_fileln);
		p->o_td.date = f->f_td.date;
		p->o_td.time = f->f_td.time;
	}

	return h;
}



/*
 *  dirinit -
 */

/* 306de: 00e15a60 */
/* 306us: 00e15a06 */
/* 104de: 00fc6456 */
/* 100fr: 00fc6eb8 */
FCB *dirinit(P(DND *)dn)
PP(DND *dn;)								/*  dir descr for dir           */
{
	register OFD *fd;							/*  ofd for this dir            */
	int num;
	register int i;
	register int i2;
	char *s1;
	DMD *dm;
	FCB *f1;

	fd = dn->d_ofd;						/*  OFD for dir */
	num = (dm = fd->o_dmd)->m_recsiz;	/*  bytes/rec   */

	/*
	 *  for each record in the current cluster, besides the first record,
	 * get the record and zero it out
	 */

	for (i2 = 1; i2 < dm->m_clsiz; i2++)
	{
		s1 = getrec(fd->o_currec + i2, dn->d_drv, 1);
		for (i = 0; i < num; i++)
			*s1++ = '\0';
	}

	/*
	 *  now zero out the first record and return a pointer to it
	 */

	f1 = (FCB *) (s1 = getrec(fd->o_currec, dn->d_drv, 1));
	for (i = 0; i < num; i++)
		*s1++ = '\0';

	return f1;
}


/*
 *  xcreat -
 *  create file with specified name, attributes
 *
 *	Function 0x3C	Fcreate
 *
 *	Error returns
 *		EPTHNF
 *		EACCDN
 *		ENHNDL
 *
 *	Last modified	SCC	13 May 85
 */

/* 306de: 00e1728c */
/* 306us: 00e17232 */
/* 104de: 00fc7cae */
/* 100fr: 00fc6f5c */
ERROR xcreat(P(const char *) fname, P(int8_t) attr)
PP(const char *fname;)
PP(int8_t attr;)
{
#if 0
	if ((attr & FA_DIREC) || ((attr & FA_LABEL) && (attr != FA_LABEL)))
		return E_BADRQ;
	return ixcreat(fname, attr & (FA_RDONLY|FA_HIDDEN|FA_SYSTEM|FA_LABEL|FA_ARCH));
#else
	return ixcreat(fname, attr & (FA_RDONLY|FA_HIDDEN|FA_SYSTEM|FA_LABEL|FA_ARCH|0x40|0x80));
#endif
}


/*
 *  ixcreat - internal routine for creating files
 */

/* 306de: 00e163be */
/* 306us: 00e16364 */
/* 104de: 00fc6de0 */
/* 100fr: 00fc6f78 */
ERROR ixcreat(P(const char *) name, P(int8_t) attr)
PP(const char *name;)
PP(int8_t attr;)
{
	register DND *dn;
	register FCB *f;
	register OFD *fd;
	const char *s;
	char unused[4];
	char n[2];
	char a[11];
	int i;
	int unused2;
	int f2;
	int32_t pos;
	ERROR rc;
	
	UNUSED(unused);
	UNUSED(unused2);

	n[0] = ERASE_MARKER;
	n[1] = 0;
	
	/* first find path */
	
	if ((dn = findit(name, &s, 0)) == NULL)
		return E_PTHNF;
	
	if (contains_dots(s, 0) != 0)
		return E_PTHNF;
	
	if (!(fd = dn->d_ofd))
		if (!(dn->d_ofd = fd = makofd(dn)))
			/*  no ofd for dir file, no space for one   */
			return E_NSMEM;
	
	/* is it already there ? */
	pos = 0;
#if 0
	if (attr == FA_LABEL)
	{
		if (dn->d_drv->m_dtl != dn)
			return E_ACCDN;
		if ((f = scan(dn, "*.*", FA_LABEL, &pos)))
		{
			pos -= sizeof(FCB);
			if ((rc = ixdel(dn, f, pos)) /* != 0 */)
				return rc;
		} else
		{
			pos = 0;
		}
	} else
#endif
	{
		if ((f = scan(dn, s, -1, &pos)))
		{
			if ((f->f_attrib & (FA_DIREC | FA_RDONLY)) /* || (attr == FA_DIREC) */)
				/*  subdir or read only  */
				return E_ACCDN;
			pos -= sizeof(FCB);
			ixdel(dn, f, pos);
		} else
		{
			pos = 0;
		}
	}
		
	/* now scan for empty space */
	for (;;)
	{
		if ((f = scan(dn, n, -1, &pos)) != NULL)
			break;
		/*  not in current dir, need to grow  */
		if ((int) (fd->o_curcl) < 0)
			/*  but can't grow root  */
			return E_ACCDN;
		
		if (nextcl(fd, 1))
			return E_ACCDN;
		
		/* f = */ dirinit(dn); /* BUG: assignment missing; f is still NULL */
		pos = 0;
	}
	
	pos -= sizeof(FCB);
	builds(s, a);
#if 0
	if (!(attr & (FA_DIREC | FA_LABEL)))
		attr |= FA_ARCH;
#endif
	f->f_attrib = attr;
	for (i = 0; i < 10; i++)
		f->f_fill[i] = 0;
	f->f_td.time = time;
	swp68(&f->f_td.time);
	f->f_td.date = date;
	swp68(&f->f_td.date);
	f->f_clust = 0;
	f->f_fileln = 0;
	ixlseek(fd, pos);
	ixwrite(fd, 11L, a);					/* write name, set dirty flag */
	ixclose(fd, CL_DIR);					/* partial close to flush */
	ixlseek(fd, pos);
	s = (const char *) ixread(fd, (long)sizeof(FCB), NULL);
	f2 = rc = opnfil((const FCB *) s, dn, (f->f_attrib & FA_RDONLY) ? RO_MODE : RW_MODE);
	
	if (rc < 0)
		return rc;
	
	getofd(f2)->o_flag |= O_DIRTY;
	
	return f2;
}


/*
 *  xmkdir - make a directory, given path 's'
 *
 *	Function 0x39	Dcreate
 *
 */

/* 306de: 00e15afc */
/* 306us: 00e15aa2 */
/* 104de: 00fc64f2 */
/* 106de: 00e066c2 */
/* 100fr: 00fc7190 */
ERROR xmkdir(P(const char *) s)
PP(const char *s;)
{
	int h;
	CLNO cl;
	ERROR rc;
	OFD *f;
	register FCB *f2;
	OFD *fd;
	OFD *f0;
	FCB *b;
	DND *dn;

	if ((h = rc = ixcreat(s, FA_DIREC)) < 0)
		return rc;

	f = getofd(h);

	/* build a DND in the tree */

	fd = f->o_dirfil;

	ixlseek(fd, f->o_dirbyt);
	b = (FCB *) ixread(fd, (long)sizeof(FCB), NULL);

	if ((dn = GetDnd(f->o_dnode, b)) == NULL)
	{
		/* ixdel(f->o_dnode, b, f->o_dirbyt); */	/* M01.01.1103.01 */
		return E_NSMEM;
	}

	if ((dn->d_ofd = f0 = makofd(dn)) == NULL)
	{
		/* BUG: dn is leaked */
		return E_NSMEM;
	}

	/* initialize dir cluster */

	if (nextcl(f0, 1))
	{
		ixclose(f, CL_DIR | CL_FULL);
		xmfreblk(f);
		sft[h - NUMSTD].f_own = (VOIDPTR)(sft[h - NUMSTD].f_ofd = 0);
		xrmdir(s);
		return E_ACCDN;
	}

	f2 = dirinit(dn);					/* pointer to dirty dir block */

	/* write identifier */

	xmovs(sizeof(dots), dots, f2->f_name);
	f2->f_attrib = FA_DIREC;
	f2->f_td.time = time; /* BUG: not swapped */
	f2->f_td.date = date; /* BUG: not swapped */
	cl = f0->o_strtcl;
	swp68((uint16_t *)&cl);
	f2->f_clust = cl;
	f2->f_fileln = 0;
	f2++;
	
	/* write parent entry .. */

	xmovs(sizeof(dots2), dots2, f2->f_name);
	f2->f_attrib = FA_DIREC;
	f2->f_td.time = time; /* BUG: not swapped */
	f2->f_td.date = date; /* BUG: not swapped */
	cl = f->o_dirfil->o_strtcl;
	if (cl < 0)
		cl = 0;
	swp68((uint16_t *) &cl);
	f2->f_clust = cl;
	f2->f_fileln = 0;
	xmovs(sizeof(OFD), f0, f); /* BUG: wrong size */
	f->o_flag |= O_DIRTY;

	ixclose(f, CL_DIR | CL_FULL);		/* force flush and write */
	xmfreblk(f);
	
	sft[h - NUMSTD].f_own = NULL;
	sft[h - NUMSTD].f_ofd = NULL;
	
	return E_OK;
}


/*	
 *  xopen - open a file (path name)
 *
 *  returns
 *	<0 = error
 *	>0 = file handle
 *
 *	Function 0x3D	Fopen
 *
 *	Error returns
 *		EFILNF
 *		opnfil()
 *
 *	Last modified	SCC	5 Apr 85
 */

/* 306de: 00e172c8 */
/* 306us: 00e1726e */
/* 104de: 00fc7cea */
/* 100fr: 00fc73b4 */
ERROR xopen(P(const char *) fname, P(int16_t) mode)
PP(const char *fname;)
PP(int16_t mode;)
{
	return ixopen(fname, mode);
}




/*
 *  ixopen - open a file 
 *
 *  returns
 *	<0 = error
 *	>0 = file handle
 */

/* 306de: 00e16670 */
/* 306us: 00e16616 */
/* 104de: 00fc7092 */
/* 100fr: 00fc73c8 */
ERROR ixopen(P(const char *) name, P(int16_t) mode)
PP(const char *name;)
PP(int16_t mode;)
{
	register FCB *f;
	register DND *dn;
	const char *s;
	int32_t pos;

	/* first find path */
	if ((dn = findit(name, &s, 0)) == NULL)
		return E_FILNF;

	/* 
	 *  now scan the directory file for a matching filename 
	 */

	pos = 0;
	if (!(f = scan(dn, s, FA_NORM, &pos)))
		return E_FILNF;

	/* Check to see if the file is read only */
	if ((f->f_attrib & FA_RDONLY) && (mode != RO_MODE))
		return E_ACCDN;

	return opnfil(f, dn, mode);
}



/*
 *  xchmod - change/get attrib of path p
 *		if wrt = 1, set; else get
 *
 *	Function 0x43	Fattrib
 *
 *	Error returns
 *		EPTHNF
 *		EFILNF
 *
 */

/* 306de: 00e166e6 */
/* 306us: 00e1668c */
/* 104de: 00fc7108 */
/* BUG: wrong return type */
/* 100fr: 00fc743a */
int xchmod(P(const char *) p, P(int16_t) wrt, P(char) mod)
PP(const char *p;)
PP(int16_t wrt;)
PP(char mod;)
{
	register OFD *fd;
	register DND *dn;
	register FCB *fcb;
	const char *s;
	int32_t pos;
	
	if ((dn = findit(p, &s, 0)) == NULL)
		return E_PTHNF;

	pos = 0;
	fcb = scan(dn, s, FA_NORM, &pos);
	if (fcb == NULL)
		return E_FILNF;

	pos -= 21;							/* point at attribute in file */
	fd = dn->d_ofd;
	ixlseek(fd, pos);
	if (!wrt)
	{
		ixread(fd, 1L, &mod);
	}
	if (wrt)
	{
		ixwrite(fd, 1L, &mod);
		ixclose(fd, CL_DIR);			/* for flush */
	}
	return mod;
}


/*
 *  xgsdtof - get/set date/time of file into of from buffer
 *
 *	Function 0x57	Fdatime
 */

/* 306de: 00e167c4 */
/* 306us: 00e1676a */
/* 104de: 00fc71e6 */
/* 100fr: 00fc74f0 */
ERROR xgsdtof(P(uint16_t *) buf, P(FH) h, P(int16_t) wrt)
PP(uint16_t *buf;)
PP(FH h;)
PP(int16_t wrt;)
{
	register OFD *f;
	register OFD *p;

	f = getofd(h);
#if 0 /* BUG: missing */
	if (f == NULL || ((ERROR)f) < 0)
		return E_IHNDL;
#endif
	p = f->o_dirfil;
	ixlseek(p, f->o_dirbyt + 22);
	
	if (!wrt)
	{
		ixread(p, 4L, buf);
	}
	swp68(&buf[0]);
	swp68(&buf[1]);
	if (wrt)
	{
		ixwrite(p, 4L, buf);
		ixclose(p, CL_DIR);
	}

#if !BINEXACT
	/* BUG: no return value */
	return E_OK;
#endif
}



/*	
 *  xunlink - unlink (delete) a file
 *
 *	Function 0x41 	Fdelete
 *
 *  returns
 *	EFILNF	file not found
 *	EACCDN	access denied
 *	ixdel()
 *
 */

/* 306de: 00e16876 */
/* 306us: 00e1681c */
/* 104de: 00fc7298 */
/* 100fr: 00fc7574 */
ERROR xunlink(P(const char *) name)
PP(const char *name;)								/*  path name of file to delete     */
{
	register DND *dn;
	register FCB *f;
	const char *s;
	int32_t pos;

	/* first find path */
	if ((dn = findit(name, &s, 0)) == NULL)
		return E_FILNF;

	/* now scan for filename */
	pos = 0;
	if ((f = scan(dn, s, FA_NORM, &pos)) == NULL)
		return E_FILNF;

	if (f->f_attrib & FA_RDONLY)
		return E_ACCDN;

	pos -= sizeof(FCB);

	return ixdel(dn, f, pos);
}


/*
 *  ixdel - internal delete file.
 *
 *  Traverse the list of files open for this directory node.
 *  If a file is found that has the same position in the directory as the one 
 *  we are to delete, then scan the system file table to see if this process is 
 *  then owner.  If so, then close it, otherwise abort.
 *  
 *  NOTE: 	both 'for' loops scan for the entire length of their 
 *		respective data structures, and do not drop out of the loop on 
 *		the first occurence of a match.
 * 	Used by
 * 		ixcreat()
 * 		xunlink()
 * 		xrmdir()
 * 
 */

/* 306de: 00e168e6 */
/* 306us: 00e1688c */
/* 104de: 00fc7308 */
/* 100fr: 00fc75e6 */
ERROR ixdel(P(DND *) dn, P(FCB *) f, P(long) pos)
PP(DND *dn;)
PP(FCB *f;)
PP(long pos;)
{
	register DMD *dm;
	register OFD *fd;
	register CLNO n2;
	CLNO n;
	char c;

	for (fd = dn->d_files; fd; fd = fd->o_link)
		if (fd->o_dirbyt == pos)
			for (n = 0; n < (OPNFILES - NUMSTD); n++)
				if (sft[n].f_ofd == fd)
				{
					if (sft[n].f_own == run)
						ixclose(fd, 0);
					else
						return E_ACCDN;
				}
	/*
	 * Traverse this file's chain of allocated clusters, freeing them.
	 */

	dm = dn->d_drv;
	n = f->f_clust;
	swp68((uint16_t *)&n);
	
	while (n && !endofchain(n))
	{
		n2 = getcl(n, dm);
#if 0
		if (n2 == FREECLUSTER || (n2 >= 0xfff0 && n2 != ENDOFCHAIN))
		{
			break;
		} else
#endif
		{
			clfix(n, FREECLUSTER, dm);
		}
		n = n2;
	}

	/*
	 * Mark the directory entry as erased.
	 */

	fd = dn->d_ofd;
	ixlseek(fd, pos);
	c = ERASE_MARKER;
	ixwrite(fd, 1L, &c);
	ixclose(fd, CL_DIR);

	/*
	 *	NOTE	that the preceding routines that do physical disk operations 
	 *	will 'longjmp' on failure at the BIOS level, thereby allowing us to 
	 *	simply return with E_OK.
	 */

	return E_OK;
}


/*
 *  xrmdir - remove (delete) a directory
 *
 *	Function 0x3A	Ddelete
 *
 *	Error returns
 *		EPTHNF
 *		EACCDN
 *		EINTRN
 *
 */

/* 306de: 00e15d08 */
/* 306us: 00e15cae */
/* 104de: 00fc66fe */
/* 100fr: 00fc76ec */
ERROR xrmdir(P(const char *)p)
PP(const char *p;)
{
	register DND *d;
	DND *d1;
	DND **q;
	register FCB *f;
	OFD *fd, *f2;
	register long pos;
	char unused[8];
	const char *s;

	UNUSED(unused);
	if ((d = findit(p, &s, 1)) == NULL)
		return E_PTHNF;

#if 0
	if (!d->d_parent)					/*  Can't delete root  */
		return E_ACCDN;

	for (i = 1; i <= NCURDIR; i++)		/*  Can't delete in use  */
		if (diruse[i])
			if (dirtbl[i] == d)
				return E_ACCDN;
#endif

	if (!(fd = d->d_ofd))
		if (!(fd = makofd(d)))
			return E_NSMEM;

	ixlseek(fd, (long)(2 * sizeof(FCB)));
	do
	{
		if (!(f = (FCB *) ixread(fd, (long)sizeof(FCB), NULL)))
			break;
	} while (f->f_name[0] == ERASE_MARKER);


	if (f != NULL && f->f_name[0] != 0)
		return E_ACCDN;

#if GEMDOS >= 0x18
	if (!d->d_parent)					/*  Can't delete root  */
		return E_BADRQ;
#endif

	for (d1 = *(q = &d->d_parent->d_left); d1 != d; d1 = *(q = &d1->d_right))
		;								/* follow sib-links */

	if (d1 != d) 					/* internal error */
		return E_INTRN;
	if (d->d_files)					/* open files ? - internal error */
		return E_INTRN;
	if (d->d_left)				/* subdir - internal error */
		return E_INTRN;

	/* take him out ! */

	*q = d->d_right;

	if (d->d_ofd)
	{
		xmfreblk(d->d_ofd);
	}

	d1 = d->d_parent;
	xmfreblk(d);
	ixlseek(f2 = fd->o_dirfil, pos = fd->o_dirbyt);
	f = (FCB *) ixread(f2, (long)sizeof(FCB), NULL);

	return ixdel(d1, f, pos);
}


/*	Function 0x36	Dfree

	Error returns
		ERR

	Last modified	SCC	15 May 85
 */

/* 306de: 00e153c8 */
/* 306us: 00e1536e */
/* 104de: 00fc5dbe */
/* 100fr: 00fc782a */
ERROR xgetfree(P(int32_t *) bufp, P(int16_t) drv)					/*+ get disk free space data into buffer */
PP(int16_t drv;)
PP(int32_t *bufp;)
{
	register CLNO i, free;
	register DMD *dm;
	register int32_t *buf;
	
	buf = bufp;
	drv = drv ? drv - 1 : run->p_curdrv;

	if ((i = ckdrv(drv)) < 0)
		return ERR;

	dm = drvtbl[i];
	free = 0;
#if 0
	if (dm->m_16)
	{
		free = xgscan16(dm, dm->m_numcl, 1);
	} else
#endif
	{
		for (i = 2; i < dm->m_numcl; i++)
			if (!getcl(i, dm))
				free++;
	}
	*buf++ = free; /* BUG: will be sign-extended */
	*buf++ = dm->m_numcl; /* BUG: will be sign-extended */
	*buf++ = dm->m_recsiz; /* BUG: will be sign-extended */
	*buf++ = dm->m_clsiz; /* BUG: will be sign-extended */
	return E_OK;
}


/*
 *  xrename - rename a file,
 *	oldpath p1, new path p2
 *
 *	Function 0x56	Frename
 *
 *	Error returns
 *		EPTHNF
 *
 */

/* 306de: 00e16a06 */
/* 306us: 00e169ac */
/* 104de: 00fc7428 */
/* 100fr: 00fc78b2 */
ERROR xrename(P(int16_t) n, P(const char *) p1, P(const char *)p2)	/*+ rename file, old path p1, new path p2 */
PP(int16_t n;)									/*  not used                */
PP(const char *p1;)
PP(const char *p2;)
{
	const char *s1;
	const char *s2;
	register OFD *f1;
	register OFD *fd;
	register OFD *fd2;
	char buf[11];
	int hnew;
	int att;
	FCB *f;
	DND *dn1;
	DND *dn2;
	register ERROR rc;
	register ERROR h1;
	
	UNUSED(n);

	if (!ixsfirst(p2, 0, NULL))
		return E_ACCDN;

	if ((dn1 = findit(p1, &s1, 0)) == NULL)
		return E_PTHNF;

#if GEMDOS >= 0x15
	/* a label may not be renamed via Frename() */
   	if ((f = scan(dn1, s1, ~FA_LABEL, &pos)) == NULL)
		return E_FILNF;
	att = f->f_attrib;
	
	/* nor might a file replace a label or directory */
	if (!ixsfirst(p2, ~FA_LABEL, NULL))
		return E_ACCDN;
#endif

	if ((dn2 = findit(p2, &s2, 0)) == NULL)
		return E_PTHNF;
#if GEMDOS >= 0x15
	if (*s2 == '\0')
		return E_BADRQ;
#endif

	/* disallow cross-device rename */
	if (dn1->d_drv->m_drvnum != dn2->d_drv->m_drvnum)
		return E_NSAME;
	
#if GEMDOS >= 0x15
	if (att == FA_DIREC)
	{
		/* directories can be renamed only within the same parent dir */
		if (dn1 != dn2)
			return E_ACCDN;
		return xrendir(dn1, p1, s2);
	}
#endif
	
	if ((h1 = xopen(p1, RW_MODE)) < 0)
		return h1;

	f1 = getofd((int) h1);

	fd = f1->o_dirfil;
	buf[0] = ERASE_MARKER;
	ixlseek(fd, f1->o_dirbyt);

	if (dn1 != dn2)
	{
		/* get old attribute */
		f = (FCB *) ixread(fd, (long)sizeof(FCB), NULL);
		att = f->f_attrib;
		/* erase (0xe5) old file */
		ixlseek(fd, f1->o_dirbyt);
		ixwrite(fd, 1L, buf);

		/* copy time/date/clust, etc. */

		ixlseek(fd, f1->o_dirbyt + 22);
		ixread(fd, 10L, buf);
		hnew = xcreat(p2, att);
		fd2 = getofd(hnew); /* BUG: no check for valid hnew/fd2 */
		ixlseek(fd2->o_dirfil, fd2->o_dirbyt + 22);
		ixwrite(fd2->o_dirfil, 10L, buf);
		fd2->o_flag &= ~O_DIRTY;
		xclose(hnew);
		ixclose(fd2->o_dirfil, CL_DIR);
	} else
	{
		builds(s2, buf);
		ixwrite(fd, 11L, buf);
	}

	if ((rc = xclose((int) h1)) < 0)
		return rc;

	return ixclose(fd, CL_DIR);
}


/*
 *  xlseek -
 *	seek to byte position n on file with handle h
 *
 *  Function 0x42	Fseek
 *
 *	Error returns
 *		EIHNDL
 *		EINVFN
 *		ixlseek()
 */

/* 306de: 00e16cf6 */
/* 306us: 00e16c9c */
/* 104de: 00fc7718 */
/* 100fr: 00fc7a90 */
ERROR xlseek(P(long) n, P(int16_t) h, P(int16_t) flg)
PP(long n;)
PP(int16_t h;)
PP(int16_t flg;)
{
	register OFD *f;

	if (!(f = getofd(h)) /* || (ERROR)f < 0 */)
		return E_IHNDL;

	if (flg == SEEK_END)
		n += f->o_fileln;
	else if (flg == SEEK_CUR)
		n += f->o_bytnum;
	else if (flg != SEEK_SET)
		return E_INVFN;

	return ixlseek(f, n);
}


/*
 *  ixlseek -
 *	file position seek
 *
 *	Error returns
 *		ERANGE
 *		EINTRN
 *
 *	Last modified	LTG	31 Jul 85
 *
 *	NOTE:	This function returns ERANGE and EINTRN errors, which are new 
 *		error numbers I just made up (that is, they were not defined 
 *		by the BIOS or by PC DOS).
 */

/* 306de: 00e16d58 */
/* 306us: 00e16cfe */
/* 104de: 00fc777a */
/* 100fr: 00fc7aec */
ERROR ixlseek(P(OFD *) _p, P(long) n)
PP(OFD *_p;)								/*  file descriptor for file in use */
PP(long n;)								/*  number of bytes to seek     */
{
	register CLNO clnum;
	register CLNO clx;
	int curnum;
	int unused;
	int curflg;
	register CLNO i;
	register DMD *dm;
	register OFD *p;

	UNUSED(unused);
	p = _p;
	if (n > p->o_fileln)
		return E_BADARG; /* E_RANGE */

	if (n < 0)
		return E_BADARG; /* E_RANGE */

	dm = p->o_dmd;
	if (n == 0)
	{
		clx = 0;
		p->o_curbyt = 0;
		goto fillin;
	}

	/* do we need to start from the beginning ? */

	curflg = p->o_curbyt != 0 && p->o_curbyt != dm->m_clsizb ? 0 : 1;

	DIVMOD(clnum, p->o_curbyt, n, dm->m_clblog);

	if (p->o_curcl && n >= p->o_bytnum)
	{
		curnum = p->o_bytnum >> dm->m_clblog;
		clnum -= curnum;
		clnum += curflg;

		clx = p->o_curcl;
	} else
	{
		clx = p->o_strtcl;
	}
	
	for (i = 1; i < clnum; i++)
		if ((clx = getcl(clx, dm)) == ENDOFCHAIN)
		{
			return ERR;
		}
		
	/* go one more except on cluster boundary */

	if (p->o_curbyt && clnum)
		clx = getcl(clx, dm);

fillin:
	p->o_curcl = clx;
	p->o_currec = cl2rec(clx, dm);
	p->o_bytnum = n;

	return n;
}


#if 1

/*
 *  divmod - do divide and modulo arithmetic
 *	the divide is accomplished with the log2 shift factor passed in as
 *	as pseudo divisor, the remainder (modulo) is left in the variable 
 *	pointed to by the third argument.
 */

int16_t divmod(P(int16_t *) modp, P(int32_t) divdnd, P(int16_t) divsor)
PP(int16_t *modp;)
PP(int32_t divdnd;)
PP(int16_t divsor;)							/* divsor is log2 of actual divisor */
{
	*modp = divdnd & logmsk[divsor];

	return divdnd >> divsor;
}

#endif


/* 306de: 00e17662 */
/* 306us: 00e17608 */
/* 104de: 00fc8084 */
/* 100fr: 00fc7c14 */
int contains_dots(P(const char *) name, P(char) ill)
PP(register const char *name;)
PP(char ill;)
{
	register int i;
	
	if (*name == '\0')
		return 1;
	for (i = 0; --i > -3; )
	{
		if (*name++ != '.')
			break;
		if (*name == ill)
			return i;
	}
	return 0;
}


/*
 *  ncmps -  compare two text strings.
 */

/* 306de: 00e176a4 */
/* 306us: 00e1764a */
/* 104de: 00fc80c6 */
/* 100fr: 00fc7c56 */
int ncmps(P(int) n, P(const char *) s, P(const char *) d)
PP(int n;)
PP(const char *s;)
PP(const char *d;)
{
	while (n--)
		if (*s++ != *d++)
			return 0;

	return 1;
}


