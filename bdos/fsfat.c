/*  fsfat.c - fat mgmt routines for file system				*/

#include "tos.h"
#include "fs.h"
#include "bios.h"
#include "mem.h"
#include <toserrno.h>
#include "../bios/biosdefs.h"

#undef min
#define min(a,b) (((a) < (b)) ? (a) : (b))


static CLNO xgscan16 PROTO((DMD *dm, CLNO numcl, int flag));


/*
 *  dirtbl - default directories.
 * Each entry points to the DND for someone's default directory.
 * They are linked to each process by the p_curdir entry in the PD.
 * The first entry (dirtbl[0]) is not used, as p_curdir[i]==0
 * means 'none set yet'.
 */

DND *dirtbl[NCURDIR];

/*
 *  diruse - use count 
 *  drvsel - mask of drives selected since power up
 */

char diruse[NCURDIR];

drvmask drvsel;

/* static */ char *dirrec;
/* static */ RECNO rrecno;
/* static */ DMD *rdm;
/* static */ int rwrtflg;

static DND *leftmost PROTO((DND *));



/* 306de: 00e1412c */
/* 306us: 00e140d2 */
/* 104de: 00fc4c18 */
DND *fsgetofd(NOTHING)
{
	register int i;
	register DMD *dm;
	register DND *dnd;
	register DND *parent;
	
	for (i = 0; i < BLKDEVNUM; i++)
	{
		dm = drvtbl[i];
		if (dm != NULL && (dnd = dm->m_dtl) != NULL && (dnd = leftmost(dnd)) != NULL)
		{
			if (dnd->d_ofd != NULL)
				oftdel(dnd->d_ofd);
			parent = dnd->d_parent;
			if (parent->d_left == dnd)
			{
				parent->d_left = dnd->d_right;
			} else
			{
				parent = parent->d_left;
				while (parent->d_right != dnd)
					parent = parent->d_right;
				parent->d_right = dnd->d_right;
			}
			return dnd;
		}
	}
	return NULL;
}


/* 306de: 00e141ac */
/* 306us: 00e14152 */
/* 104de: 00fc4c98 */
static DND *leftmost(P(DND *) dnd)
PP(register DND *dnd;)
{
	register int i;
	register DND *p;
	
	for (;;)
	{
		if (dnd->d_fill == 0 && dnd->d_left == NULL && dnd->d_files == NULL && dnd->d_parent != NULL && X_USER(dnd) != osuser)
		{
			for (i = 0; i < NCURDIR; i++)
			{
				if (diruse[i] && dirtbl[i] == dnd)
					break;
			}
			if (i == NCURDIR)
				return dnd;
		}
		if ((p = dnd->d_left) != NULL)
		{
			p = leftmost(p);
			if (p != NULL)
				return p;
		}
		dnd = dnd->d_right;
		if (dnd == NULL)
			return NULL;
	}
}


/*
 *  getdmd - allocate storage for and initialize a DMD
 */

/* 306de: 00e1423e */
/* 306us: 00e141e4 */
/* 104de: 00fc4d2a */
DMD *getdmd(P(int) drv)
PP(int drv;)
{
	register DMD *dm;

	drvtbl[drv] = dm = (DMD *)mgetofd();
	dm->m_dtl = (DND *)mgetofd();
	dm->m_dtl->d_ofd = mgetofd();

	dm->m_fatofd = mgetofd();

	return dm;
}



/*
 *  login -
 *	log in media 'b' on drive 'drv'.
 *
 */

/* 306de: 00e1428e */
/* 306us: 00e14234 */
/* 104de: 00fc4d7a */
ERROR login(P(BPB *) b, P(int) drv)
PP(BPB *b;)									/*  bios parm block for drive       */
PP(int drv;)								/*  drive number            */
{
	OFD *fo, *f;
	DND *d;
	DMD *dm;
	int rsiz, cs, n;
	RECNO fs; /* BUG: should by unsigned */
	CLNO ncl, fcl;

	rsiz = b->recsiz;
	cs = b->clsiz;
	n = b->rdlen;
	fs = b->fsiz;

	dm = getdmd(drv);

	d = dm->m_dtl;						/*  root DND for drive      */
	dm->m_fsiz = fs;					/*  fat size            */
	f = d->d_ofd;						/*  root dir file       */
	dm->m_drvnum = drv;					/*  drv nbr into media descr    */
	f->o_dmd = dm;						/*  link to OFD for rt dir file */

	d->d_drv = dm;						/*  link root DND with DMD  */
	d->d_name[0] = 0;					/*  null out name of root   */

	dm->m_fatrec = b->fatrec;
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


#if GEMDOS >= 0x18
/* 306de: 00e144d2 */
/* 306us: 00e14478 */
static VOID invalidate(P(int) drv)
PP(register int drv;)
{
	register BCB *b;
	register BCB **bp;
	
	for (bp = bufl; bp < &bufl[2]; bp++)
	{
		for (b = *bp; b != NULL; b = b->b_link)
		{
			if (b->b_bufdrv == drv && !b->b_dirty)
				b->b_bufdrv = -1;
		}
	}
}


/*
 *  flush - flush all modified disk buffers for drive
 *
 *	Last modified	SCC	10 Apr 85
 *
 *	NOTE:	rwabs() is a macro that includes a longjmp() which is executed 
 *		if the BIOS returns an error, therefore flush() does not need 
 *		to return any error codes.
 */

/* 306de: 00e14516 */
/* 306us: 00e144bc */
static VOID flush(P(BCB *) b)
PP(register BCB *b;)
{
	register DMD *dm;				/*  media descr for buffer  */
	register int typ;
	register int drv;
	int n;
	
	dm = b->b_dm;
	typ = b->b_buftyp;
	drv = b->b_bufdrv;
	n = typ != BT_DATA ? BI_FAT : BI_DATA;

	for (b = bufl[n]; b != NULL; b = b->b_link)
	{
		if (b->b_bufdrv == drv && b->b_dirty)
		{
			typ = b->b_buftyp;
			b->b_bufdrv = -1;					/* invalidate in case of error */
			rwabsw(b->b_bufr, 1, b->b_bufrec + dm->m_recoff[typ], drv);
			
			/* flush to both fats */
			if (typ == BT_FAT 
#if FAT1_SUPPORT
				&& !dm->m_1fat
#endif
				)
				rwabsw(b->b_bufr, 1, b->b_bufrec + dm->m_recoff[BT_FAT] - dm->m_fsiz, drv);

			b->b_bufdrv = drv;					/* re-validate */
			b->b_dirty = 0;
		}
	}
}


/* 306de: 00e14624 */
/* 306us: 00e145ca */
VOID flushall(NOTHING)
{
	register int drv;
	register int typ;
	register BCB *b;
	
	for (drv = 0; drv < BLKDEVNUM; drv++)
	{
		for (typ = BI_DIR; typ >= BI_FAT; typ--)
		{
			for (b = bufl[typ]; b != NULL; b = b->b_link)
				if (b->b_bufdrv == drv && b->b_dirty)
				{
					flush(b);
					break;
				}
		}
	}
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

/* 306de: 00e14676 */
/* 306us: 00e1461c */
static VOID usrio(P(int) wrtflg, P(RECNO) count, P(RECNO) recno, P(char *) buf, P(DMD *)dm)
PP(int wrtflg;)
PP(RECNO count;)
PP(RECNO recno;)
PP(char *buf;)
PP(DMD *dm;)
{
	register int drv;
	register RECNO end; /* BUG: should by unsigned */
	register RECNO start; /* BUG: should by unsigned */
	register BCB *b;

	start = recno;
	end = start + count;
	drv = dm->m_drvnum;
	if (Mediach(drv) == MEDIAMAYCHANGE)
	{
#if GEMDOS >= 0x18
		invalidate(drv);
#endif
	}
	for (b = bufl[BI_DATA]; b != NULL; b = b->b_link)
	{
		if (b->b_bufdrv == drv && b->b_bufrec >= start && b->b_bufrec < end)
		{
			if (b->b_dirty)
			{
				flush(b);
			}
			b->b_bufdrv = -1;
		}
	}
	rwabs(wrtflg, buf, count, start + dm->m_recoff[BT_DATA], dm->m_drvnum);
}


#else

/* 104de: 00fc4faa */
VOID flushbcb(P(BCB *) b)
PP(register BCB *b;)
{
	register DMD *dm;				/*  media descr for buffer  */
	register int typ;
	register int drv;
	
	if (b->b_bufdrv == -1)
		return;
	if (!b->b_dirty)
		return;

	dm = b->b_dm;
	typ = b->b_buftyp;
	drv = b->b_bufdrv;

	for (b = (BCB *)&bufl[typ != BT_DATA ? BI_FAT : BI_DATA]; b != NULL; b = b->b_link) /* BUG: address operator is wrong */
	{
		if (b->b_bufdrv == drv && b->b_dirty && b->b_buftyp == typ)
		{
			b->b_bufdrv = -1;					/* invalidate in case of error */
			rwabsw(b->b_bufr, 1, b->b_bufrec + dm->m_recoff[typ], drv);
			
			/* flush to both fats */
			if (typ == BT_FAT 
#if FAT1_SUPPORT
				&& !dm->m_1fat
#endif
				)
				rwabsw(b->b_bufr, 1, b->b_bufrec + dm->m_recoff[BT_FAT] - dm->m_fsiz, drv);

			b->b_bufdrv = drv;					/* re-validate */
			b->b_dirty = 0;
		}
	}
}


/* 104de: 00fc50c0 */
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
			b->b_bufdrv = -1;
		}
	rwabs(wrtflg, buf, count, dmd->m_recoff[BT_DATA] + recno, dmd->m_drvnum);
}

#endif


/*
 *  getrec -
 *	return the ptr to the buffer containing the desired record
 */

/* 306de: 00e1473e */
/* 306us: 00e146e4 */
/* 104de: 00fc516a */
char *getrec(P(RECNO) recno, P(DMD *)dm, P(int) wrtflg)
PP(register RECNO recno;)
PP(register DMD *dm;)
PP(int wrtflg;)
{
	register BCB *b;
	register int typ;
	register int unused;
	register int err;
#if GEMDOS >= 0x18
	register int drv;
	BCB *mtbuf;
	register BCB *p;
	BCB **q;
	BCB **phdr;
	LRECNO lrecno;
#else
	register BCB **q;
	BCB *p;
	BCB *mtbuf;
	BCB **phdr;
	LRECNO lrecno;
#endif
	
	UNUSED(unused);
#if GEMDOS >= 0x18
	drv = dm->m_drvnum;
#else
#define drv dm->m_drvnum
#endif
	lrecno = recno;
	if (recno >= 0 || (-dm->m_recoff[BI_FAT] - dm->m_fatrec) > recno)
	{
		lrecno &= 0x0000ffffL;
	}
	if (lrecno < (dm->m_dtl->d_strtcl << dm->m_clrlog))
	{
		typ = BT_FAT;
	} else if (lrecno < 0)
	{
		typ = BT_ROOT;
	} else
	{
		typ = BT_DATA;
	}
	
	mtbuf = NULL;
	phdr = &bufl[typ == BT_DATA];

	/*
	 *  see if the desired record for the desired drive is in memory.
	 * if it is, we will use it.  Otherwise we will use
	 *     the last invalid (available) buffer,  or
	 *     the last (least recently) used buffer.
	 */

	for (b = *(q = phdr); b; b = *(q = &b->b_link))
	{
		if (b->b_bufdrv == drv && b->b_bufrec == recno)
		{
			break;
		}
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
		b->b_bufrec = -1;					/* invalidate in case of error */
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
			if (err == MEDIACHANGE)
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


/* 306de: 00e1492c */
/* 306us: 00e148d2 */
/* 104de: 00fc5322 */
static char *getdirrec(P(RECNO) recno, P(DMD *)dm, P(int) wrtflg)
PP(RECNO recno;)
PP(DMD *dm;)
PP(int wrtflg;)
{
	dirlock = TRUE;
	dirrec = getrec(recno - (dm->m_recoff[BT_FAT] - dm->m_fatrec), dm, wrtflg);
	rrecno = recno;
	rdm = dm;
	rwrtflg = wrtflg;
	dirlock = FALSE;
	return dirrec;
}


/*
 *  clfix -
 *	replace the contents of the fat entry indexed by 'cl' with the value
 *	'link', which is the index of the next cluster in the chain.
 */

/* 306de: 00e1498a */
/* 306us: 00e14930 */
/* 104de: 00fc5380 */
VOID clfix(P(CLNO) cl, P(CLNO) link, P(DMD *) dm)
PP(register CLNO cl;)
PP(CLNO link;)
PP(register DMD *dm;)
{
	CLNO f[1];
	char *buf2;
	CLNO mask;
	CLNO fix;
	register char *buf;
	register char *fixp;
	register RECNO recno;
	register long pos;
	char *bufp;
	
	if (dm->m_16)
	{
		pos = (long) (cl) << 1;
		f[0] = pos & logmsk[dm->m_rblog]; /* inefficient: should use dm->m_rbm instead */
		recno = pos >> dm->m_rblog;
		buf = (dirlock || dm != rdm || recno != rrecno || !rwrtflg) ? getdirrec(recno, dm, 1) : dirrec;
		swp68((uint16_t *)&link);
		*((CLNO *)(buf + f[0])) = link;
		return; /* superfluous return */
	} else
	{
		fixp = (char *)&fix;
		
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
		
		f[0] = pos & logmsk[dm->m_rblog]; /* inefficient: should use dm->m_rbm instead */
		recno = pos >> dm->m_rblog;
		buf = (dirlock || dm != rdm || recno != rrecno || !rwrtflg) ? getdirrec(recno, dm, 1) : dirrec;
		fixp[1] = *(bufp = &buf[f[0]]);
		if (f[0] == (dm->m_recsiz - 1))
		{
			/* content spans FAT sectors ... */
			buf2 = buf;
			buf = (dirlock || dm != rdm || (recno + 1) != rrecno || !rwrtflg) ? getdirrec(recno + 1, dm, 1) : dirrec;
			fixp[0] = buf[0];
		} else
		{
			buf2 = NULL;
			fixp[0] = bufp[1];
		}
		fix = (fix & mask) | link;
		if (buf2 == NULL)
		{
			bufp[0] = fixp[1];
			bufp[1] = fixp[0];
		} else
		{
			bufp[0] = fixp[1];
			buf[0] = fixp[0];
		}
	}
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
CLNO getcl(P(CLNO) cl, P(DMD *) dm)
PP(register CLNO cl;)
PP(register DMD *dm;)
{
	CLNO f[1];
	CLNO val;
	register long pos;
	register RECNO recno;
	register char *buf;
	register char *fixp;
	char *bufp;
	
	if (cl < 0 && cl >= dm->m_dtl->d_strtcl)
	{
		return cl + 1;
	}

	if (dm->m_16)
	{
		pos = (long) (cl) << 1;
		f[0] = pos & logmsk[dm->m_rblog]; /* inefficient: should use dm->m_rbm instead */
		recno = pos >> dm->m_rblog;
		/*
		 * BUG: query should be: dirlock || dm != rdm || recno != rrecno || rwrtflg
		 * The following generates buggy code were rwrtflg is never checked!!
		 */
		buf = (dirlock || dm != rdm || recno != rrecno || (0 && !rwrtflg)) ? getdirrec(recno, dm, 0) : dirrec;
		/* BUG: cast generates buggy code: suba.l a1,a1;move.w -2(a6),a1 will sign-extend it anyway */
		val = *((CLNO *)(buf + (unsigned)f[0]));
		swp68((uint16_t *)&val);
		return val;
	} else
	{
		fixp = (char *)&val;
		pos = (cl + (cl >> 1));
		f[0] = pos & logmsk[dm->m_rblog]; /* inefficient: should use dm->m_rbm instead */
		recno = pos >> dm->m_rblog;
		buf = (dirlock || dm != rdm || recno != rrecno || (0 && !rwrtflg)) ? getdirrec(recno, dm, 0) : dirrec; /* BUG: see above */
		/* BUG: cast generates buggy code: suba.l a1,a1;move.w -2(a6),a1 will sign-extend it anyway */
		fixp[1] = *(bufp = buf + (unsigned)f[0]);
		
		if (f[0] == (dm->m_recsiz - 1))
		{
			/* content spans FAT sectors ... */
			buf = (dirlock || dm != rdm || (recno + 1) != rrecno || (0 && !rwrtflg)) ? getdirrec(recno + 1, dm, 0) : dirrec; /* BUG: see above */
			fixp[0] = buf[0];
		} else
		{
			fixp[0] = bufp[1];
		}
		if (cl & 1)
			cl = val >> 4;
		else
			cl = val;
		if ((cl & 0x0ff0) == 0x0ff0)
			cl |= 0xf000;
		else
			cl &= 0x0fff;
		return cl;
	}	
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
int nextcl(P(OFD *) p, P(int) wrtflg)
PP(register OFD *p;)
PP(int wrtflg;)
{
	register DMD *dm;
	register CLNO i;
	register CLNO cl;
	register CLNO cl2;
	register CLNO rover;
	register CLNO numcl;
	
	cl = p->o_curcl;
	dm = p->o_dmd;

	if (cl < dm->m_dtl->d_strtcl)
	{
		cl2 = cl + 1;
		goto retcl;
	} else if (cl != 0)
	{
		cl2 = getcl(cl, dm);
	} else
	{
		cl2 = p->o_strtcl ? p->o_strtcl : ENDOFCHAIN;
	}
	
	if (wrtflg && endofchain(cl2))
	{									/* end of file, allocate new clusters */
		numcl = dm->m_numcl;
		
		if (cl == 0 && dm->m_16)
		{
			if ((cl2 = xgscan16(dm, numcl, 0)) /* != 0 */)
				i = 0;
			else
				i = numcl;
			goto skip;
		}
		rover = cl;
		for (i = 2; i < numcl; i++)
		{
			if (rover < 2)
				rover = 2;

			if (getcl(rover, dm) == 0)
				break;
			rover = (rover + 1) % numcl;
		}

		cl2 = rover;
skip:

		if (i < numcl)
		{
			if (cl != 0)
			{
				clfix(cl, cl2, dm);
			} else
			{
				p->o_strtcl = cl2;
				p->o_flag |= O_DIRTY;
			}
			clfix(cl2, ENDOFCHAIN, dm);
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


/* 306de: 00e14e22 */
/* 306us: 00e14dc8 */
/* 104de: 00fc5818 */
CLNO xgscan16(P(DMD *) dm, P(CLNO) numcl, P(int) flag)
PP(DMD *dm;)
PP(CLNO numcl;)
PP(int flag;)
{
	register CLNO i;
	register CLNO count;
	register RECNO recno;
	register CLNO n;
	register CLNO ncl;
	register CLNO *buf;
	register char *p; /* bad alcyon hack: no more integer registers available */
		
	n = numcl;
	ncl = dm->m_recsiz >> 1;
	p = 0;
	recno = 0;
	i = 2;
	count = ncl < n ? ncl : n;
	count -= 2;
	buf = ((CLNO *)(getdirrec(recno, dm, 0))) + 2;
	for (;;)
	{
		if (!flag)
		{
			while (count-- && *buf++ != 0)
				i++;
			if (count >= 0)
				return i;
		} else
		{
			while (count--)
			{
				if (*buf++ == 0)
					p++;
				i++;
			}
			if (i == n)
				return (CLNO)(intptr_t)p; /* WTF */
		}
		if (i >= n)
			break;
		recno++;
		count = (n - i) > ncl ? ncl : (n - i);
		buf = ((CLNO *)(getdirrec(recno, dm, 0)));
	}
		
	return 0;
}



/*
 *  addit -
 *	update the OFD for the file to reflect the fact that 'siz' bytes
 *	have been written to it.
 */

/* 306de: 00e14ece */
/* 306us: 00e14e74 */
/* 104de: 00fc58c4 */
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
ERROR xrw(P(int) wrtflg, P(OFD *) p, P(long) len, P(char *) ubufr, P(xfer) bufxfr)
PP(int wrtflg;)
PP(register OFD *p;)
PP(long len;)
PP(char *ubufr;)
PP(xfer bufxfr;)
{
	register DMD *dm;
	char *bufp;
	int16_t bytn;
	RECNO recn;
	int recsiz;
	int lenxfr;
	int clsiz;
	int clsizb;
	int lentail;
	RECNO num;
	RECNO hdrrec;
	int lsiz;
	RECNO tailrec;
	int last;
	RECNO nrecs;
	int lflg;
	long nbyts;
	register long rc;
	long bytpos;
	long lenrec;
	long lenmid;
	RECNO midrec;
	
	/*
	 *  determine where we currently are in the file
	 */

	dm = p->o_dmd;						/* get drive media descriptor */

	recsiz = dm->m_recsiz;				/* inefficient: will already be accessed through register var */
	clsiz = dm->m_clsiz;				/* " */
	clsizb = dm->m_clsizb;				/* " */
	bytpos = p->o_bytnum;				/* starting file position */

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
	dirlock = TRUE;
	
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
			
			if ((midrec = lenmid >> dm->m_rblog) > (dm->m_clsiz - hdrrec))
				midrec = dm->m_clsiz - hdrrec;

			usrio(wrtflg, midrec, recn, ubufr, dm);
			ubufr += (lsiz = midrec << dm->m_rblog);
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
	dirlock = TRUE;
 	return rc;
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
ERROR ckdrv(P(int) d)
PP(register int d;)									/* has this drive been accessed, or had a media change */
{
	register drvmask mask;
	register int i;
	register BPB *b;
	long unused;
	
	UNUSED(unused);
	
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
				goto found;

		/* no slot available */
		return ERR;
	found:
		diruse[i]++;					/*  mark as used    */
		dirtbl[i] = drvtbl[d]->m_dtl;	/*  link to DND     */
		run->p_curdir[d] = i;			/*  link to process */
	}

	return d;
}



/*	Function 0x36	Dfree

	Error returns
		ERR

	Last modified	SCC	15 May 85
 */

/* 306de: 00e153c8 */
/* 306us: 00e1536e */
/* 104de: 00fc5dbe */
ERROR xgetfree(P(int32_t *) bufp, P(int16_t) drv)					/*+ get disk free space data into buffer */
PP(register int16_t drv;)
PP(int32_t *bufp;)
{
	register CLNO i, free, numcl;
	register int32_t *buf;
	register DMD *dm;
	
	buf = bufp;
	drv = drv ? drv - 1 : run->p_curdrv;

	if ((i = ckdrv(drv)) < 0)
		return ERR;

	dm = drvtbl[i];
	free = 0;
	dirlock = TRUE;
	numcl = dm->m_numcl;
	if (dm->m_16)
	{
		free = xgscan16(dm, numcl, 1);
	} else
	{
		for (i = 2; i < numcl; i++)
			if (!getcl(i, dm))
				free++;
	}
	dirlock = TRUE;
	*buf++ = free; /* BUG: will be sign-extended */
	*buf++ = dm->m_numcl; /* BUG: will be sign-extended */
	*buf++ = dm->m_recsiz; /* BUG: will be sign-extended */
	*buf++ = dm->m_clsiz; /* BUG: will be sign-extended */
	return E_OK;
}


#if 0 /* now a macro */
/*
 *  cl2rec -
 */

RECNO cl2rec(P(CLNO) cl, P(DMD *)dm)
PP(CLNO cl;)
PP(DMD *dm;)
{
	return cl * dm->m_clsiz;
}

#endif


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
