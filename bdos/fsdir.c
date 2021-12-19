/*  fsdir - directory routines for the file system			*/

#include "tos.h"
#include "fs.h"
#include "bios.h"
#include "mem.h"
#include <toserrno.h>
#include "btools.h"


/*
 *  local macros
 */

#define dirscan(a,c) ((DND *) scan(a,c,FA_DIREC,&negone))

static VOID makbuf PROTO((FCB *f, DTAINFO *dt));

/*
 *  local structures
 */

/*
 *  negone - for use as parameter
 */

STATIC int32_t negone = -1L;

/*
 *  dots -, dots2  -
 */

STATIC char /* const */ dots[22] = { ".          " };
STATIC char /* const */ dots2[22] = { "..         " };

/*
 *  GetDnd - find a dnd with matching name
 */

static DND *GetDnd(P(DND *) d, P(FCB *) fcb)
PP(register DND *d;)								/*  name of file in FCB format      */
PP(register FCB *fcb;)									/*  root where we start the search  */
{
	register DND *dnd;
	OFD *ofd;
	CLNO clust;
	
	clust = fcb->f_clust;
	swp68((uint16_t *)&clust);
	for (dnd = d->d_left; dnd; dnd = dnd->d_right)
	{
		if (xcmps(fcb->f_name, dnd->d_name))
			return dnd;
	}
	ofd = d->d_ofd;
	X_USER(d) = osuser;
	dnd = (DND *)mgetofd();
	if (d->d_left)
		dnd->d_right = d->d_left;
	d->d_left = dnd;
	dnd->d_ofd = NULL;
	dnd->d_parent = d;
	dnd->d_strtcl = fcb->f_clust;
	swp68((uint16_t *)&dnd->d_strtcl);
	dnd->d_drv = d->d_drv;
	dnd->d_dirfil = ofd;
	dnd->d_dirpos = ofd->o_bytnum - sizeof(FCB);
	dnd->d_fill = '\0';
	dnd->d_td.time = fcb->f_td.time;
	dnd->d_td.date = fcb->f_td.date;
	xmovs(11, fcb->f_name, dnd->d_name);
	return dnd;
}


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
FCB *scan(P(DND *) dnd, P(const char *) n, P(int16_t) att, P(int32_t *) posp)
PP(register DND *dnd;)
PP(const char *n;)
PP(int att;)
PP(int32_t *posp;)
{
	DND *dnd1;
	long pos;
	char name[12];
	register OFD *fd;
	register FCB *fcb;
	register BOOLEAN m;					/*  T: found a matching FCB     */

	dnd1 = NULL;
	X_USER(dnd) = osuser;
	m = 0;								/*  have_match = false          */
	builds(n, name);					/*  format name into dir format     */
	name[11] = att;

	/*
	 *  if there is no open file descr for this directory, make one
	 */

	if (!(fd = dnd->d_ofd))
	{
		dnd->d_ofd = fd = makofd(dnd);
	}

	/*
	 *  seek to desired starting position.  If posp == -1, then start at
	 * the beginning.
	 */
	if ((pos = *posp) == -1)
		pos = 0;
	ixlseek(fd, pos);

	/*
	 *  scan thru the directory file, looking for a match
	 */

	while ((fcb = (FCB *) ixread(fd, (long)sizeof(FCB), NULL)) && fcb->f_name[0])
	{
		if (!(m = match(name, fcb->f_name)))
			continue;

		/*
		 *  Add New DND.
		 *  ( iff after scan ptr && complete flag not set && not a .
		 *  or .. && subdirectory && not deleted )
		 */

		if (*posp == -1 && fcb->f_name[0] != '.' && (fcb->f_attrib & FA_DIREC) && fcb->f_name[0] != ERASE_MARKER)
		{								/*  see if we already have it  */
			if (!(dnd1 = GetDnd(dnd, fcb)))
				return NULL;
		}
		break;
	}

	/* restore directory scanning pointer */

	if (*posp != -1L)
		*posp = fd->o_bytnum;

	/*
	 *  if there was no match, but we were looking for a deleted entry,
	 *  then return a pointer to a deleted fcb.  Otherwise, if there was
	 *  no match, return a null pointer
	 */

	if (!m)
	{									/*  assumes that (*n != 0xe5) (if posp == -1)  */
		if (fcb && *n == ERASE_MARKER)
			return fcb;
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
	X_USER(p) = osuser;
	return p;
}


/*
 *  findit - find a file/dir entry
 */

/* 306de: 00e15750 */
/* 306us: 00e156f6 */
/* 104de: 00fc6146 */
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
	char s[11];
	register char *cp;
	
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
		
		cp = &s[11];
		while (cp > s)
			if (*--cp == '?')
				return NULL;
		
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
				if (pp)
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

	if (p)
		X_USER(p) = osuser;
	return p;
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
ERROR xchdir(P(const char *) p)
PP(const char *p;)
{
	register long l;
	register int i;
	register int dlog;
	register int dr;
	const char *s;

	if (p[1] == ':')
	{
		dlog = uc(p[0]) - 'A';
		p += 2;
	} else
	{
		dlog = run->p_curdrv;
	}

	/* BUG: if drive was specified in path this will call findit() on the current drive */
	if (!(l = (long) findit(p, &s, 1)))
		return E_PTHNF;

	/* find space in dirtbl */
	dr = run->p_curdir[dlog];

	for (i = 1; i < NCURDIR; i++)
	{
		if (dirtbl[i] == (DND *)l)
		{
			goto found;
		}
	}
	for (i = 1; i < NCURDIR; i++)
	{
		if (!diruse[i])
		{
			dirtbl[i] = (DND *)l;
			goto found;
		}
	}
	return E_PTHNF;

found:

	if (dr != 0 && diruse[dr])
		--diruse[dr];

	diruse[i]++;

	run->p_curdir[dlog] = i;

	return E_OK;
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
 *  makbuf - copy info from FCB into DTA info area
 */

/* 306de: 00e159f6 */
/* 306us: 00e1599c */
/* 104de: 00fc63ec */
VOID makbuf(P(FCB *) fp, P(DTAINFO *) dtp)
PP(FCB *fp;)
PP(DTAINFO *dtp;)
{
	register FCB *f;
	register DTAINFO *dt;
	
	dt = dtp;
	f = fp;
	dt->dt_fattr = f->f_attrib;
	dt->dt_td.time = f->f_td.time;
	dt->dt_td.date = f->f_td.date;
	swp68(&dt->dt_td.time);
	swp68(&dt->dt_td.date);
	dt->dt_fileln = f->f_fileln;
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
 *  dirinit -
 */

/* 306de: 00e15a60 */
/* 306us: 00e15a06 */
/* 104de: 00fc6456 */
FCB *dirinit(P(DND *)dn)
PP(register DND *dn;)								/*  dir descr for dir           */
{
	register OFD *fd;							/*  ofd for this dir            */
	int num;
	register int i;
	register int i2;
	char *s1;
	DMD *dm;
	register FCB *f1;

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
 *  xmkdir - make a directory, given path 's'
 *
 *	Function 0x39	Dcreate
 *
 */

/* 306de: 00e15afc */
/* 306us: 00e15aa2 */
/* 104de: 00fc64f2 */
ERROR xmkdir(P(const char *) s)
PP(const char *s;)
{
	int h;
	CLNO cl;
	int plen;
	ERROR rc;
	OFD *fd;
	FCB f;

	if ((h = rc = ixcreat(s, FA_DIREC)) < 0)
		return rc;

	fd = getofd(h);

	if ((rc = ixwrite(fd, 1L, dots)) != 1)
	{
		f.f_clust = fd->o_strtcl;
		ixdel(fd->o_dnode, &f, fd->o_dirbyt);
		xclose(h);
		return rc != 0 ? rc : E_ACCDN;
	}
	
	/* build a DND in the tree */

	ixlseek(fd, 0L);

	/* write identifier */

	xmovs(sizeof(dots), dots, f.f_name);
	f.f_attrib = FA_DIREC;
	f.f_td.time = time;
	swp68(&f.f_td.time);
	f.f_td.date = date;
	swp68(&f.f_td.date);
	f.f_clust = fd->o_strtcl;
	swp68((uint16_t *)&f.f_clust);
	f.f_fileln = 0;
	ixwrite(fd, (long)sizeof(f), &f);
	
	/* write parent entry .. */

	xmovs(sizeof(dots2), dots2, f.f_name);
	f.f_attrib = FA_DIREC;
	f.f_td.time = fd->o_dirfil->o_td.time;
	f.f_td.date = fd->o_dirfil->o_td.date;
	cl = fd->o_dirfil->o_strtcl;
	if (cl < 0)
		cl = 0;
	swp68((uint16_t *) &cl);
	f.f_clust = cl;
	f.f_fileln = 0;
	ixwrite(fd, (long)sizeof(f), &f);

	zeromem(&f, &f + 1);
	plen = (fd->o_dmd->m_clsizb / sizeof(f)) - 2;
	while (plen != 0)
	{
		ixwrite(fd, (long)sizeof(f), &f);
		--plen;
	}
	
	fd->o_fileln = 0;
	xclose(h);		/* force flush and write */
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
ERROR xrmdir(P(const char *)p)
PP(const char *p;)
{
	register DND *d;
	DND *d1;
	register DND **q;
	register FCB *f;
	OFD *fd, *f2;
	register long pos;
	const char *s;

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
		fd = makofd(d);

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

	if (d1 != d 					/* internal error */
		|| d->d_files				/* open files ? - internal error */
		|| d->d_left)				/* subdir - internal error */
		return E_INTRN;

	/* take him out ! */

	*q = d->d_right;

	if (d->d_ofd)
	{
		oftdel(d->d_ofd);
	}

	d1 = d->d_parent;
	oftdel((OFD *)d);
	ixlseek(f2 = fd->o_dirfil, pos = fd->o_dirbyt);
	f = (FCB *) ixread(f2, (long)sizeof(FCB), NULL);

	return ixdel(d1, f, pos);
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
ERROR ixsfirst(P(const char *) name, P(int16_t) att, P(DTAINFO *)addr)
PP(const char *name;)								/*  name of file to match   */
PP(int16_t att;)							/*  attribute of file       */
PP(DTAINFO *addr;)						/*  ptr to dta info         */
{
	const char *s;
	int32_t pos;
	register DND *dn;
	register FCB *f;

	if (att != FA_LABEL)
		att |= FA_ARCH | FA_RDONLY;

	if ((dn = findit(name, &s, 0)) == NULL)
		return E_PTHNF; /* was E_FILNF before */

	/* now scan for filename from start of directory */

	pos = 0;

	if ((f = scan(dn, s, att, &pos)) == NULL)
		return E_FILNF;

	if (addr)
	{
		xmovs(12, s, addr->dt_name);
		addr->dt_attr = att;
		if (dn->d_strtcl < 0)
		{
			addr->dt_offset_drive = pos;
		} else
		{
			addr->dt_offset_drive = 0;
			addr->dt_curcl = dn->d_ofd->o_curcl;
			addr->dt_curbyt = dn->d_ofd->o_curbyt;
		}
		addr->dt_offset_drive |= dn->d_drv->m_drvnum;
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
ERROR xsnext(NOTHING)
{
	register DTAINFO *dt;
	register DMD *dmd;
	register FCB *f;
	char attr;
	register uint16_t curbyt;
	register uint16_t /* CLNO */ curcl;
	register BOOLEAN first;
	int32_t pos;
	char *s1;
	char name[12];
	DND *dnd;
	
	dt = run->p_xdta;
	dmd = drvtbl[dt->dt_offset_drive & DTA_DRIVEMASK];
	attr = dt->dt_attr;
	curbyt = dt->dt_curbyt;
	curcl = dt->dt_curcl;
	pos = dt->dt_offset_drive & ~DTA_DRIVEMASK;
	first = FALSE;
	
	/* has the DTA been initialized? */
	if (dt->dt_name[0] == '\0')
		return E_NMFIL;
	if (pos != 0)
	{
		dnd = dmd->m_dtl;
		f = scan(dnd, dt->dt_name, attr, &pos);
		if (f == NULL)
		{
			goto notfound;
		} else
		{
			dt->dt_offset_drive = dmd->m_drvnum | pos;
			goto found;
		}
	}

	builds(dt->dt_name, name);
	name[11] = dt->dt_attr;
	dirlock = TRUE;
	first = TRUE;
	while (1)
	{
		if (first || (curbyt % dmd->m_recsiz) == 0)
		{
			first = FALSE;
			if (curbyt == dmd->m_clsizb)
			{
				curbyt = 0;
				curcl = getcl(curcl, dmd);
				if (endofchain(curcl))
				{
					goto notfound;
				}
			}
			s1 = getrec(curcl * dmd->m_clsiz + curbyt / dmd->m_recsiz, dmd, FALSE);
		}
		f = (FCB *)(s1 + curbyt % dmd->m_recsiz);
		do {
			if (f->f_name[0] == '\0')
			{
				goto notfound;
			}
			if (match(name, f->f_name))
			{
				dt->dt_curbyt = curbyt + sizeof(FCB);
				dt->dt_curcl = curcl;
				goto found;
			} else
			{
				f++;
				curbyt += sizeof(FCB);
			}
		} while ((curbyt % dmd->m_recsiz) != 0);
	}

notfound:
	dt->dt_name[0] = '\0';
	dt->dt_fname[0] = '\0';
	dirlock = TRUE;
	return E_NMFIL;

found:
	makbuf(f, dt);
	dirlock = TRUE;
	return E_OK;
}


#if 0 /* old code - no longer used */

VOID freednd PROTO((DND *dn));
int namlen PROTO((const char *s11));
DND *makdnd PROTO((DND *, FCB *b));

/*
 *  makdnd - make a child subdirectory of directory p
 */

DND *makdnd(P(DND *) p, P(FCB *) b)
PP(DND *p;)
PP(FCB *b;)
{
	register DND *p1;
	register DND **prev;
	OFD *fd;
	register int i;
	int in_use;
	fd = p->d_ofd;

	/*
	 *  scavenge a DND at this level if we can find one that has not
	 *  d_left
	 */

	for (prev = &p->d_left; (p1 = *prev) != NULL; prev = &p1->d_right)
	{
		if (!p1->d_left)
		{
			/* check dirtbl[] to see if anyone is using this guy */

			in_use = 0;
			for (i = 1; i < NCURDIR; i++)
				if (diruse[i])
					if (dirtbl[i] == p1)
						in_use = 1;

			if (!in_use && p1->d_files == NULL)
			{
				/* clean out this DND for reuse */

				p1->d_flag = 0;
				p1->d_scan = 0L;
				p1->d_files = (OFD *) 0;
				if (p1->d_ofd)
				{
					oftdel(p1->d_ofd);
				}
				break;
			}
		}
	}

	/* we didn't find one that qualifies, so allocate a new one */

	if (!p1)
	{
		if (!(p1 = MGET(DND)))
			return (DND *) 0;			/* ran out of system memory */

		/* do this init only on a newly allocated DND */
		p1->d_right = p->d_left;
		p->d_left = p1;
		p1->d_parent = p;
	}

	/* complete the initialization */

	p1->d_ofd = (OFD *) 0;
	p1->d_strtcl = b->f_clust;
	swp68((uint16_t *)&p1->d_strtcl);
	p1->d_drv = p->d_drv;
	p1->d_dirfil = fd;
	p1->d_dirpos = fd->o_bytnum - sizeof(FCB);
	p1->d_td.time = b->f_td.time;
	p1->d_td.date = b->f_td.date;
	xmovs(11, (char *) b->f_name, (char *) p1->d_name);

	return p1;
}


/*
 *	namlen -
 *		parameter points to a character string of 11 bytes max
 *
 */

int namlen(P(const char *) s11)
PP(const char *s11;)
{
	int i, len;

	for (i = len = 1; i <= 11; i++, s11++)
		if (*s11 && (*s11 != ' '))
		{
			len++;
			if (i == 9)
				len++;
		}
	return len;
}

/*
 *  freednd - free an allocated and linked-in DND
 *
 */

VOID freednd(P(DND *) dn)
PP(DND *dn;)
{
	DND **prev;

	if (dn->d_ofd)						/* free associated OFD if it's linked */
		xmfreblk(dn->d_ofd);

	for (prev = &(dn->d_parent->d_left); *prev != dn; prev = &((*prev)->d_right))
		;								/* find the predecessor to this DND */
	*prev = dn->d_right;				/* then cut this DND out of the list */

	while (dn->d_left)					/* is this step really necessary? */
		freednd(dn->d_left);

	xmfreblk(dn);				/* finally free this DND */
}

#endif
