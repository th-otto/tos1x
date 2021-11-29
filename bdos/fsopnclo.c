/*  fsopnclo.c - open/close/create/delete routines for file system	*/

#include "tos.h"
#include <ostruct.h>
#include <toserrno.h>
#include "fs.h"
#include "bios.h"
#include "mem.h"
#include "btools.h"


ERROR xrendir PROTO((DND *dn, const char *name, const char *to));


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
ERROR ixclose(P(OFD *) fd, P(int) part)
PP(register OFD *fd;)
PP(int part;)
{
	register OFD *p;
	register OFD **q;
	register long tmp;
	register int i;
	BCB *b;
	char x1[34];
	struct {
		_DOSTIME f_td;			/* time, date */
		CLNO f_clust;
		int32_t f_fileln;
	} f;
	char x2[6];
	char *fattr;
	
	UNUSED(b);
	UNUSED(tmp);
	UNUSED(i);
	UNUSED(x1);
	UNUSED(x2);
	
	if (fd->o_flag & O_DIRTY)
	{
		ixlseek(fd->o_dirfil, fd->o_dirbyt + 22);
		
		/*
		 * copy the time, date, cluster, and length fields from the OFD of the
		 * (dir) file we are closeing to the FCB for this (dir) file in the 
		 * parent dir.
		 */
		f.f_td.time = fd->o_td.time;
		f.f_td.date = fd->o_td.date;
		f.f_clust = fd->o_strtcl;
		f.f_fileln = fd->o_fileln;
		swp68((uint16_t *)&f.f_clust);
		swp68l(&f.f_fileln);

		if (part & CL_DIR)
		{
			f.f_fileln = 0;
			ixwrite(fd->o_dirfil, 10L, &f);
		} else
		{
			ixwrite(fd->o_dirfil, 10L, &f);
			/* get buffer address of attribute byte */
			ixlseek(fd->o_dirfil, fd->o_dirbyt + 11);
			fattr = (char *)ixread(fd->o_dirfil, 1L, NULL);
			if (!(*fattr & (FA_DIREC|FA_ARCH|FA_LABEL)))
				*fattr |= FA_ARCH;
		}
		fd->o_flag &= ~O_DIRTY;
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
	for (i = BI_DIR; i >= BI_FAT; i--)
	{
		for (b = bufl[i]; b != NULL; b = b->b_link)
			if (b->b_dirty)
			{
				flushbcb(b);
			}
	}
#endif

	return E_OK;
}


/*
 *  makofd -
 */

/* 306de: 00e161de */
/* 306us: 00e16184 */
/* 104de: 00fc6c00 */
OFD *makofd(P(DND *) p)
PP(register DND *p;)
{
	register OFD *f;

	f = mgetofd();

	f->o_strtcl = p->d_strtcl;
	f->o_fileln = 0x7fffffffL;
	f->o_dirfil = p->d_dirfil;
	f->o_dnode = p->d_parent;
	f->o_dirbyt = p->d_dirpos;
	f->o_td.date = p->d_td.date;
	f->o_td.time = p->d_td.time;
	f->o_dmd = p->d_drv;
	f->o_link = NULL;
	f->o_flag = 0;
	
	return f;
}



/*
 *  ixread -
 *
 *	Last modified	SCC	26 July 85
 */

/* 306de: 00e16236 */
/* 306us: 00e161dc */
/* 104de: 00fc6c58 */
ERROR ixread(P(OFD *)p, P(long) len, P(VOIDPTR) ubufr)
PP(register OFD *p;)
PP(register long len;)
PP(VOIDPTR ubufr;)
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
		len = xrw(0, p, len, ubufr, xfr2usr);
		return len;
	}
	return len;						/* zero bytes read for zero requested */
}



/*
 *  ixwrite -
 */

/* 306de: 00e16286 */
/* 306us: 00e1622c */
/* 104de: 00fc6ca8 */
ERROR ixwrite(P(OFD *) p, P(long) len, P(VOIDPTR) ubufr)
PP(OFD *p;)
PP(long len;)
PP(VOIDPTR ubufr;)
{
	return xrw(1, p, len, ubufr, usr2xfr);
}



/*
 *  makopn - make an open file for sft handle h 
 *
 *	Last modified	SCC	8 Apr 85
 */

/* 306de: 00e162ae */
/* 306us: 00e16254 */
/* 104de: 00fc6cd0 */
ERROR makopn(P(const FCB *) f, P(DND *) dn, P(FH) h, P(int16_t) mod)
PP(register const FCB *f;)
PP(DND *dn;)
PP(FH h;)
PP(int mod;)
{
	register OFD *p;
	register DMD *dm;
	register OFD *p2;

	dm = dn->d_drv;

	p = mgetofd();

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
 *  ixcreat - internal routine for creating files
 */

/* 306de: 00e163be */
/* 306us: 00e16364 */
/* 104de: 00fc6de0 */
ERROR ixcreat(P(const char *) name, P(int8_t) attr)
PP(const char *name;)
PP(int8_t attr;)
{
	register DND *dn;
	register FCB *f;
	register OFD *fd;
	const char *s;
	char n[2];
	char a[11];
	register int i, f2;
	int32_t pos;
	ERROR rc;
	
	n[0] = ERASE_MARKER;
	n[1] = 0;
	
	/* first find path */
	
	if ((dn = findit(name, &s, 0)) == NULL)
		return E_PTHNF;
	
	if (contains_dots(s, 0) != 0)
		return E_PTHNF;
	
	if (ffhndl() < 0)
		return E_NHNDL;
	
	if (!(fd = dn->d_ofd))
		dn->d_ofd = fd = makofd(dn);
	
	/* is it already there ? */
	pos = 0;
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
	{
		if ((f = scan(dn, s, -1 & ~FA_LABEL, &pos)))
		{
			if ((f->f_attrib & (FA_DIREC | FA_RDONLY)) || (attr == FA_DIREC))
				/*  subdir or read only  */
				return E_ACCDN;
			pos -= sizeof(FCB);
			if ((rc = ixdel(dn, f, pos)) /* != 0 */)
				return rc;
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
		
		dirlock = TRUE;
		rc = nextcl(fd, 1);
		dirlock = TRUE;
		if (rc != 0)
			return E_ACCDN;
		
		dirinit(dn);
		pos = 0;
	}
	
	builds(s, a);
	if (!(attr & (FA_DIREC | FA_LABEL)))
		attr |= FA_ARCH;
	f->f_attrib = attr;
	for (i = 0; i < 10; i++)
		f->f_fill[i] = 0;
	f->f_td.time = time;
	swp68(&f->f_td.time);
	f->f_td.date = date;
	swp68(&f->f_td.date);
	f->f_clust = 0;
	f->f_fileln = 0;
	pos -= sizeof(FCB);
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
 *  ixopen - open a file 
 *
 *  returns
 *	<0 = error
 *	>0 = file handle
 */

/* 306de: 00e16670 */
/* 306us: 00e16616 */
/* 104de: 00fc7092 */
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
ERROR xchmod(P(const char *) p, P(int16_t) wrt, P(char) mod)
PP(const char *p;)
PP(int16_t wrt;)
PP(char mod;)
{
	register OFD *fd;
	register DND *dn;
	const char *s;
	int32_t pos;
	char attr;
	
	pos = 0;
	if ((dn = findit(p, &s, 0)) == NULL ||
		!scan(dn, s, FA_NORM, &pos))
		return E_FILNF;

	pos -= 21;							/* point at attribute in file */
	fd = dn->d_ofd;
	ixlseek(fd, pos);
	ixread(fd, 1L, &attr);
	if (!wrt)
	{
		return attr & 0xffL;
	} else
	{
		if (mod & ~(FA_ARCH|FA_SYSTEM|FA_HIDDEN|FA_RDONLY))
			return E_ACCDN;
		ixlseek(fd, pos);
		ixwrite(fd, 1L, &mod);
		ixclose(fd, CL_DIR);			/* for flush */
	}
	return mod & 0xffL;
}


/*
 *  xgsdtof - get/set date/time of file into of from buffer
 *
 *	Function 0x57	Fdatime
 */

/* 306de: 00e167c4 */
/* 306us: 00e1676a */
/* 104de: 00fc71e6 */
ERROR xgsdtof(P(uint16_t *) buf, P(FH) h, P(int16_t) wrt)
PP(uint16_t *buf;)
PP(FH h;)
PP(int16_t wrt;)
{
	register OFD *f;
	register OFD *p;
	uint16_t b[2];

	f = getofd(h);
	if (f == NULL || ((ERROR)f) < 0)
		return E_IHNDL;

	if (!wrt)
	{
		buf[0] = f->o_td.time;
		buf[1] = f->o_td.date;
		swp68(&buf[0]);
		swp68(&buf[1]);
		return E_OK;
	}

	b[0] = buf[0];
	b[1] = buf[1];
	swp68(&b[0]);
	swp68(&b[1]);

	for (p = f->o_dnode->d_files; p; p = p->o_link)
	{
		if (p->o_strtcl == f->o_strtcl)
		{
			p->o_td.time = b[0];
			p->o_td.date = b[1];
			p->o_flag |= O_DIRTY;
		}
	}

	return E_OK;
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
ERROR xunlink(P(const char *) name)
PP(const char *name;)								/*  path name of file to delete     */
{
	register DND *dn;
	register FCB *f;
	const char *s;
	int32_t pos;

	/* first find path */

	pos = 0;
	if ((dn = findit(name, &s, 0)) == NULL ||
		(f = scan(dn, s, FA_NORM, &pos)) == NULL)
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
ERROR ixdel(P(DND *) dn, P(FCB *) f, P(long) pos)
PP(DND *dn;)
PP(FCB *f;)
PP(long pos;)
{
	register DMD *dm;
	register OFD *fd;
	register uint16_t /* CLNO */ n;
	register uint16_t /* CLNO */ n2;
	char c;
	CLNO cl;

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
	cl = f->f_clust;
	swp68((uint16_t *)&cl);
	n = cl;
	dirlock = TRUE;
	
	while (n && !endofchain(n))
	{
		n2 = getcl(n, dm);
		if (n2 == FREECLUSTER || (n2 >= 0xfff0 && n2 != ENDOFCHAIN))
		{
			break;
		} else
		{
			clfix(n, FREECLUSTER, dm);
		}
		n = n2;
	}
	dirlock = TRUE;

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
	FCB *f;
	DND *dn1;
	DND *dn2;
	register int hnew;
	register int att;
	register ERROR rc;
	register ERROR h1;
	int32_t pos;
	
	UNUSED(n);

	pos = 0;
	if ((dn1 = findit(p1, &s1, 0)) == NULL)
		return E_PTHNF;

	/* a label may not be renamed via Frename() */
   	if ((f = scan(dn1, s1, ~FA_LABEL, &pos)) == NULL)
		return E_FILNF;
	att = f->f_attrib;
	
	/* nor might a file replace a label or directory */
	if (!ixsfirst(p2, ~FA_LABEL, NULL))
		return E_ACCDN;

	if ((dn2 = findit(p2, &s2, 0)) == NULL)
		return E_PTHNF;
	if (*s2 == '\0')
		return E_BADRQ;

	/* disallow cross-device rename */
	if (dn1->d_drv->m_drvnum != dn2->d_drv->m_drvnum)
		return E_NSAME;
	
	if (att == FA_DIREC)
	{
		/* directories can be renamed only within the same parent dir */
		if (dn1 != dn2)
			return E_ACCDN;
		return xrendir(dn1, p1, s2);
	}
	
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


/* 306de: 00e16c48 */
/* 306us: 00e16bee */
/* 104de: 00fc766a */
ERROR xrendir(P(DND *) dn, P(const char *) name, P(const char *) to)
PP(DND *dn;)
PP(const char *name;)
PP(const char *to;)
{
	char buf[20];
	const char *s1;
	DND *dn1;
	register int i;
	
	UNUSED(i);
	
	if (contains_dots(to, 0))
		return E_BADRQ;

	if ((dn1 = findit(name, &s1, 1)) == NULL)
		return E_PTHNF;
	builds(to, buf);
	xmovs(11, buf, dn1->d_name);
	ixlseek(dn1->d_dirfil, dn1->d_dirpos);
	ixwrite(dn1->d_dirfil, 11L, buf);
	return ixclose(dn1->d_dirfil, CL_DIR);
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
ERROR xlseek(P(long) n, P(int16_t) h, P(int16_t) flg)
PP(long n;)
PP(int16_t h;)
PP(int16_t flg;)
{
	register OFD *f;

	if (!(f = getofd(h)) || (ERROR)f < 0)
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
ERROR ixlseek(P(OFD *) p, P(long) n)
PP(register OFD *p;)								/*  file descriptor for file in use */
PP(register long n;)								/*  number of bytes to seek     */
{
	register CLNO clnum;
	register CLNO clx;
	int curnum;
	register CLNO i;
	int curflg;
	register DMD *dm;

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
	
	dirlock = TRUE;
	for (i = 1; i < clnum; i++)
		if ((clx = getcl(clx, dm)) == ENDOFCHAIN)
		{
			dirlock = TRUE;
			return ERR;
		}
		
	/* go one more except on cluster boundary */

	if (p->o_curbyt && clnum)
		clx = getcl(clx, dm);
	dirlock = TRUE;

fillin:
	p->o_curcl = clx;
	p->o_currec = cl2rec(clx, dm);
	p->o_bytnum = n;

	return n;
}



#if 0 /* old code no longer in use */

FTAB *sftsrch PROTO((int field, VOIDPTR ptr));

/*
 *  used in calls to sftsrch to distinguish which field we are matching on
 */

#define	SFTOFD		0
#define	SFTOWNER	1

/*
 *  SFTOFDSRCH - search sft for entry with matching OFD ptr
 *	call sftsrch with correct parms
 */

#define	SFTOFDSRCH(o)	sftsrch( SFTOFD , (char *) o )

/*
 *  SFTOWNSRCH - search sft for entry with matching PD
 *	call sftsrch with correct parms
 */

#define	SFTOWNSRCH(p)	sftsrch( SFTOWN , (char *) p )


/*
 *  sftsrch - search the sft for an entry with the specified OFD
 *  returns:
 *	ptr to the matching sft, or
 *	NULL
 */

FTAB *sftsrch(P(int) field, P(VOIDPTR) ptr)
PP(int field;)								/*  which field to match on     */
PP(VOIDPTR ptr;)								/*  ptr to match on         */
{
	register FTAB *sftp;						/*  scan ptr for sft            */
	register int i;
	register OFD *ofd;
	register PD *pd;

	switch (field)
	{
	case SFTOFD:
		for (i = 0, sftp = sft, ofd = (OFD *) ptr; i < OPNFILES && sftp->f_ofd != ofd; ++i, ++sftp)
			;
		break;
	case SFTOWNER:
		for (i = 0, sftp = sft, pd = (PD *) ptr; i < OPNFILES && sftp->f_own != pd; ++i, ++sftp)
			;
		break;
	default:
		i = OPNFILES;					/* setup for null return  */
	}
	return i >= OPNFILES ? (FTAB *) NULL : sftp;
}

#endif
