/*	DESKFPD.C	06/11/84 - 03/29/85		Lee Lorenzen	*/
/*	source merge	5/19/87  - 5/28/87		mdf		*/
/*	for 3.0		11/4/87				mdf		*/

/*
*       Copyright 1999, Caldera Thin Clients, Inc.                      
*       This software is licenced under the GNU Public License.         
*       Please see LICENSE.TXT for further information.                 
*                                                                       
*                  Historical Copyright                                 
*	-------------------------------------------------------------
*	GEM Desktop					  Version 3.0
*	Serial No.  XXXX-0000-654321		  All Rights Reserved
*	Copyright (C) 1987			Digital Research Inc.
*	-------------------------------------------------------------
*/

#include "desktop.h"


#undef Mshrink
#define Mshrink(a,b) trap(0x4a,0,a,b)


/*
 *	Initialize the list of fnodes
 */
/* 104de: 00fd8d76 */
/* 106de: 00e19988 */
LINEF_STATIC VOID fn_init(NOTHING)
{
	register THEDSK *d;
	
	d = thedesk;
	d->g_favail = NULL;
	d->g_fnnext = 0;
	d->g_fnavail = 0;
}


/*
 *	Initialize the list of pnodes
 */
/* 104de: 00fd8d90 */
/* 106de: 00e199aa */
VOID pn_init(NOTHING)
{
	register THEDSK *d;
	register int i;
	
	d = thedesk;
	d->a_wdta = d->g_wdta;
	fn_init();
	for (i = NUM_PNODES - 1; i >= 0; i--)
	{
		d->g_plist[i].p_next = &d->g_plist[i + 1];
		d->g_plist[i].p_flist = NULL;
	}
	d->g_pavail = d->g_plist;
	d->g_phead = NULL;
	d->g_plist[NUM_PNODES - 1].p_next = NULL;
}


/*
 *	Build a filespec out of drive letter, a pointer to a path, a pointer
 *	to a filename, and a pointer to an extension.
 */
/* 104de: 00fd8df2 */
/* 106de: 00e19a14 */
LINEF_STATIC BOOLEAN fpd_bldspec(P(int16_t) drive, P(const char *) ppath, P(const char *)pname, P(const char *) pext, P(char *) pspec)
PP(register int16_t drive;)
PP(register const char *ppath;)
PP(register const char *pname;)
PP(const char *pext;)
PP(register char *pspec;)
{
	if (((int)strlen(ppath) + LEN_ZFNAME) >= (LEN_ZFPATH - 1))
		return FALSE;
	*pspec++ = drive;
	*pspec++ = ':';
	*pspec++ = '\\';
	if (*ppath)
	{
		while (*ppath)
			*pspec++ = *ppath++;
		if (*pname)
			*pspec++ = '\\';
	}

	if (*pname)
	{
		while (*pname)
			*pspec++ = *pname++;
		if (*pext)
		{
			*pspec++ = '.';
			while (*pext)
				*pspec++ = *pext++;
		}
	}
	*pspec++ = 0;
	return TRUE;
}


/* 104de: 00fd8e6c */
/* 106de: 00e19a14 */
VOID fpd_parse(P(const char *) pspec, P(int16_t *) pdrv, P(char *) ppath, P(char *) pname, P(char *) pext)
PP(register const char *pspec;)
PP(int16_t *pdrv;)
PP(char *ppath;)
PP(char *pname;)
PP(char *pext;)
{
	const char *pstart;
	const char *p1st;
	register const char *plast;
	register const char *pperiod;

	pstart = pspec;
	/* get the drive */
	if (*pspec++ != '\0' && *pspec == ':')
	{
		pspec--;
		*pdrv = *pspec;
		pspec += 2;
		if (*pspec == '\\')
			pspec++;
	} else
	{
		*pdrv = dos_gdrv() + 'A';
		pspec = pstart;
	}
	/* scan for key bytes */
	p1st = pspec;
	plast = pspec;
	pperiod = NULL;
	while (*pspec)
	{
		if (*pspec == '\\')
			plast = pspec;
		if (*pspec == '.')
			pperiod = pspec;
		pspec++;
	}
	if (pperiod == NULL)
		pperiod = pspec;
	/* get the path */
	while (p1st != plast)
		*ppath++ = *p1st++;
	*ppath = 0;
	if (*plast == '\\')
		plast++;
	/* get the name */
	while (plast != pperiod)
		*pname++ = *plast++;
	*pname = 0;
	/* get the ext  */
	if (*pperiod)
	{
		pperiod++;
		while (pperiod != pspec)
			*pext++ = *pperiod++;
	}
	*pext = 0;
}


/* 104de: 00fd8f32 */
/* 106de: 00e19a14 */
LINEF_STATIC VOID fn_pfree(P(VOIDPTR *) ptr)
PP(register VOIDPTR *ptr;)
{
	if (*ptr != NULL)
	{
		dos_free(*ptr);
		*ptr = NULL;
	}
}


/*
 *	Allocate a file node.
 */
/* 104de: 00fd8f4a */
/* 106de: 00e19b90 */
LINEF_STATIC FNODE *fn_alloc(NOTHING)
{
	register THEDSK *d;
	register intptr_t size;
	FNODE *p;
	
	d = thedesk;
	if (d->g_favail == NULL)
	{
		size = dos_avail();
		if (size >= sizeof(FNODE))
		{
			d->g_favail = dos_alloc(size);
			d->g_fnnext = 0;
			d->g_fnavail = size / sizeof(FNODE);
		} else
		{
			goto error;
		}
	}
	if (d->g_fnnext < d->g_fnavail)
	{
		p = d->g_favail;
		return &p[d->g_fnnext++];
	}
error:
	return NULL;
}


/* 104de: 00fd8fae */
/* 106de: 00e19c04 */
LINEF_STATIC PNODE *pn_alloc(NOTHING)
{
	register PNODE *pp;
	register THEDSK *d;
	
	d = thedesk;
	if (d->g_pavail != NULL)
	{
		pp = d->g_pavail;
		d->g_pavail = d->g_pavail->p_next;
		pp->p_next = d->g_phead;
		d->g_phead = pp;
		pp->p_flags = 0;
		pp->p_flist = NULL;
		return pp;
	}
	return NULL;
}


/*
 *	Open a particular path.  
 */
/* 104de: 00fd8fe4 */
/* 106de: 00e19c44 */
PNODE *pn_open(P(int16_t) drive, P(const char *) path, P(const char *) name, P(const char *) ext, P(uint16_t) attr)
PP(int16_t drive;)
PP(const char *path;)
PP(const char *name;)
PP(const char *ext;)
PP(uint16_t attr;)
{
	register PNODE *thepath;

	thepath = pn_alloc();
	if (thepath != NULL)
	{
		if (fpd_bldspec(drive, path, name, ext, thepath->p_spec))
		{
			thepath->p_attr = attr;
			return thepath;
		}
	}
	return NULL;
}


/*
 *	Free a path node.
 */
/* 104de: 00fd9022 */
/* 106de: 00e19c8a */
VOID pn_free(P(PNODE *)thepath)
PP(register PNODE *thepath;)
{
	register PNODE **pp;
	register THEDSK *d;
	
	d = thedesk;
	fn_pfree(&thepath->p_flist);
	pp = &d->g_phead;
	while (thepath != *pp)
	{
		pp = &(*pp)->p_next;
	}
	*pp = thepath->p_next;
	thepath->p_next = d->g_pavail;
	d->g_pavail = thepath;
}


/*
 *	Compare file nodes pf1 & pf2, using a field
 *	determined by which
 */
/* 104de: 00fd9056 */
/* 106de: 00e19cc8 */
LINEF_STATIC int pn_fcomp(P(FNODE *) pf1, P(FNODE *) pf2, P(int) which)
PP(register FNODE *pf1;)
PP(register FNODE *pf2;)
PP(int which;)
{
	register int16_t chk;
	register const char *ps1;
	register const char *ps2;

	ps1 = pf1->f_name;
	ps2 = pf2->f_name;

	switch (which)
	{
	case S_SIZE:
		if (pf2->f_size > pf1->f_size)
			return 1;
		if (pf2->f_size < pf1->f_size)
			return -1;
		return strchk(ps1, ps2);
	case S_TYPE:
		if ((chk = strchk(scasb(ps1, '.'), scasb(ps2, '.'))))
			return chk;
		/* == falls thru */
	case S_NAME:
		return strchk(ps1, ps2);
	case S_DATE:
		chk = pf2->f_date - pf1->f_date;
		if (chk)
		{
			return chk;
		} else
		{
#if 0
			chk = (pf2->f_time >> 11) - (pf1->f_time >> 11);
			if (chk)
				return (chk);
			chk = ((pf2->f_time >> 5) & 0x003F) - ((pf1->f_time >> 5) & 0x003F);
			if (chk)
				return (chk);
			return ((pf2->f_time & 0x001F) - (pf1->f_time & 0x001F));
#else
			/* only compares hours & mins? */
			return ((pf2->f_time >> 5)) - ((pf1->f_time >> 5));
#endif
		}
	}
#if !BINEXACT
	/* not reached */
	return 0;
#endif
}


/* 104de: 00fd9118 */
/* 106de: 00e19da6 */
FNODE *pn_sort(P(int16_t) lstcnt, P(FNODE *) pflist)
PP(register int16_t lstcnt;)
PP(FNODE *pflist;)
{
	register FNODE *pf;
	FNODE *newlist;
	FNODE tmp;
	register int16_t i;
	register int16_t j;
	register int16_t gap;
	int chk;

	/* build index array if necessary */
	if (lstcnt == -1)
	{
		lstcnt = 0;
		for (pf = pflist; pf; pf = pf->f_next)
		{
			pflist[lstcnt].f_pfndx = pf;
			lstcnt++;
		}
	}

	if (lstcnt == 0)
		return pflist;
	/* sort files using shell sort on page 108 of R C Prog. Lang. */
	for (gap = lstcnt / 2; gap > 0; gap /= 2)
	{
		for (i = gap; i < lstcnt; i++)
		{
			for (j = i - gap; j >= 0; j -= gap)
			{
				/* Folders always sort out first */
				if ((pflist[j].f_pfndx->f_attr ^ pflist[j + gap].f_pfndx->f_attr) & FA_DIREC)
				{
					chk = pflist[j].f_pfndx->f_attr & FA_DIREC ? -1 : 1;
				} else
				{	
					chk = pn_fcomp(pflist[j].f_pfndx, pflist[j + gap].f_pfndx, thedesk->g_isort);
				}
				if (chk <= 0)
					break;
				pf = pflist[j].f_pfndx;
				pflist[j].f_pfndx = pflist[j + gap].f_pfndx;
				pflist[j + gap].f_pfndx = pf;
			}
		}
	}

	/* link up the list in order */
	newlist = NULL;
	pf = (FNODE *) &newlist;
	for (i = 0; i < lstcnt; i++)
	{
		pf->f_next = pflist[i].f_pfndx;
		pf = pflist[i].f_pfndx;
	}
	pf->f_next = NULL;
	
	movs(sizeof(tmp), newlist, &tmp);
	movs(sizeof(tmp), pflist, newlist);
	movs(sizeof(tmp), &tmp, pflist);
	for (i = 0; i < lstcnt; i++)
	{
		if (pflist[i].f_next == pflist)
			pflist[i].f_next = newlist;
		else if (pflist[i].f_next == newlist)
			pflist[i].f_next = pflist;
	}
		
	return pflist;
}


/*
 *	Make a particular path the active path.  This involves
 *	reading its directory, initializing a file list, and filling
 *	out the information in the path node.
 */
/* 104de: 00fd931a */
/* 106de: 00e19fbe */
int pn_folder(P(PNODE *) thepath)
PP(register PNODE *thepath;)
{
	register FNODE *thefile;
	register THEDSK *d;
	register int found;
	register intptr_t size;
	register BOOLEAN iscart;
	FNODE *f;

	if (thepath->p_spec[0] == CHAR_FOR_CARTRIDGE)
		iscart = TRUE;
	else
		iscart = FALSE;
	d = thedesk;
	thepath->p_count = 0;
	thepath->p_size = 0;
	fn_pfree(&thepath->p_flist);
	thefile = NULL;
	if (iscart)
	{
		found = cart_sfirst(thedesk->a_wdta, thepath->p_attr);
	} else
	{
		dos_sdta(thedesk->a_wdta);
		found = dos_sfirst(thepath->p_spec, thepath->p_attr);
	}
	while (found)
	{
		if ((thedesk->g_wdta[30] != '.' ||
			 (thedesk->g_wdta[31] != '.' && thedesk->g_wdta[31] != '\0'))
			  && ((thedesk->g_wdta[21] & (FA_SYSTEM|FA_HIDDEN)) == 0)
			 )
		{
			/* make so each dir. has a available new folder */
			thefile = fn_alloc();
			if (thefile == NULL)
			{
				found = FALSE;
				DOS_AX = E_NOFNODES;
				break;
			}
			movs(23, &thedesk->g_wdta[20], &thefile->f_junk);
			thepath->p_size += thefile->f_size;
			thefile->f_pfndx = thefile;
			if (thepath->p_count == 0)
				thepath->p_flist = thefile;
			thepath->p_count += 1;
		}
		if (iscart)
			found = cart_snext();
		else
			found = dos_snext();
	}
	
	if (thepath->p_count != 0)
	{
		thepath->p_flist = pn_sort(thepath->p_count, thepath->p_flist);
		f = d->g_favail;
		size = d->g_fnnext;
		size *= sizeof(FNODE);
		size += (intptr_t)f;
		size -= (intptr_t)d->g_favail;
		Mshrink(d->g_favail, size);
	} else
	{
		if (thepath->p_flist)
			dos_free(thepath->p_flist);
		thepath->p_flist = NULL;
	}
	fn_init();
	return DOS_AX;
}

