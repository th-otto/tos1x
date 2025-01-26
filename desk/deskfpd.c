/*      DESKFPD.C       06/11/84 - 03/29/85             Lee Lorenzen    */
/*      source merge    5/19/87  - 5/28/87              mdf             */
/*      for 3.0         11/4/87                         mdf             */

/*
 *       Copyright 1999, Caldera Thin Clients, Inc.                      
 *       This software is licenced under the GNU Public License.         
 *       Please see LICENSE.TXT for further information.                 
 *                                                                       
 *                  Historical Copyright                                 
 *       -------------------------------------------------------------
 *       GEM Desktop                                       Version 3.0
 *       Serial No.  XXXX-0000-654321              All Rights Reserved
 *       Copyright (C) 1987                      Digital Research Inc.
 *       -------------------------------------------------------------
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
	register int i;
	
	d = thedesk;
	for (i = NUM_FNODES - 2; i >= 0; i--)
		d->g_flist[i].f_next = &d->g_flist[i + 1];
	d->g_favail = &d->g_flist[0];
	d->g_flist[NUM_FNODES - 1].f_next = NULL;
}


LINEF_STATIC VOID pn_init(NOTHING)
{
	register THEDSK *d;
	register int i;

	d = thedesk;
	for (i = NUM_PNODES - 1; i >= 0; i--)
	{
		d->g_plist[i].p_next = &d->g_plist[i + 1];
		/* d->g_plist[i].p_flist = NULL; BUG: missing */
	}
	d->g_pavail = d->g_plist;
	d->g_phead = NULL;
	d->g_plist[NUM_PNODES - 1].p_next = NULL;
}


/*
 *	Initialize the list of pnodes
 */
VOID fpd_start(NOTHING)
{
	register THEDSK *d;
	
	d = thedesk;
	d->a_wdta = (DTA *)d->g_wdta;
	d->a_wspec = d->g_wspec;
	fn_init();
	pn_init();
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
	const char *start;
	const char *p1st;
	register const char *plast;
	register const char *pperiod;

	start = pspec;
	/* get the drive */
	while (*pspec && *pspec != ':')
		pspec++;
	if (*pspec == ':')
	{
		pspec--;
		*pdrv = *pspec;
		pspec++;
		pspec++;
		if (*pspec == '\\')
			pspec++;
	} else
	{
		*pdrv = dos_gdrv() + 'A';
		pspec = start;
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


/*
 *	Find the file node that matches a particular object id.
*/
FNODE *fpd_ofind(P(FNODE *) pf, P(int16_t) obj)
PP(register FNODE *pf;)
PP(register int16_t obj;)
{
	while (pf)
	{
		if (pf->f_obid == obj)
			return pf;
		pf = pf->f_next;
	}
	return NULL;
}


/*
 *	Find the list item that is after start and points to stop item.
 */
FNODE *fpd_elist(P(FNODE *) pfpd, P(FNODE *) pstop)
PP(register FNODE *pfpd;)
PP(FNODE *pstop;)
{
	while (pfpd->f_next != pstop)
		pfpd = pfpd->f_next;
	return pfpd;
}


/*
 *	Free a single file node
 */
LINEF_STATIC VOID fn_free(P(FNODE *) thefile)
PP(register FNODE *thefile;)
{
	thefile->f_next = thedesk->g_favail;
	thedesk->g_favail = thefile;
}


/*
 *	Free a list of file nodes.
 */
LINEF_STATIC VOID fl_free(P(FNODE *) pflist)
PP(register FNODE *pflist;)
{
	register FNODE *thelast;

	if (pflist)
	{
		thelast = fpd_elist(pflist, NULL);
		thelast->f_next = thedesk->g_favail;
		thedesk->g_favail = pflist;
	}
}


/*
 *	Allocate a file node.
 */
/* 104de: 00fd8f4a */
/* 106de: 00e19b90 */
LINEF_STATIC FNODE *fn_alloc(NOTHING)
{
	register FNODE *thefile;
	register THEDSK *d;
	
	d = thedesk;
	if (d->g_favail)
	{
		thefile = d->g_favail;
		d->g_favail = d->g_favail->f_next;
		return thefile;
	}
	return NULL;
}


/*
 *	Allocate a path node.
 */
/* 104de: 00fd8fae */
/* 106de: 00e19c04 */
LINEF_STATIC PNODE *pn_alloc(NOTHING)
{
	register PNODE *thepath;
	register THEDSK *d;
	
	d = thedesk;
	if (d->g_pavail != NULL)
	{
		/* get up off the avail list */
		thepath = d->g_pavail;
		d->g_pavail = d->g_pavail->p_next;
		/* put us on the active list */
		thepath->p_next = d->g_phead;
		d->g_phead = thepath;
		/* init. and return */
		thepath->p_flags = 0;
		thepath->p_flist = NULL;
		return thepath;
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
	/* free our file list */
	fl_free(thepath->p_flist);
	/*
	 * if first in list unlink by changing phead else
	 * by finding and chang our previouse guy
	 */
	pp = &d->g_phead;
	while (thepath != *pp)
	{
		pp = &(*pp)->p_next;
	}
	*pp = thepath->p_next;
	/* put us on the avail list */
	thepath->p_next = d->g_pavail;
	d->g_pavail = thepath;
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
		} else
		{
			return NULL;
		}
	} else
	{
		return NULL;
	}
}


/*
 *	Close a particular path.
 */
VOID pn_close(P(PNODE *) thepath)
PP(PNODE *thepath;)
{
	pn_free(thepath);
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
				return chk;
			chk = ((pf2->f_time >> 5) & 0x003F) - ((pf1->f_time >> 5) & 0x003F);
			if (chk)
				return chk;
			return ((pf2->f_time & 0x001F) - (pf1->f_time & 0x001F));
#else
			/* only compares hours & mins? */
			return ((pf2->f_time >> 5)) - ((pf1->f_time >> 5));
#endif
		}
	}
#ifndef __ALCYON__
	/* not reached */
	return 0;
#endif
}


/*
 *	Routine to compare two fnodes to see which one is greater.
 *	Folders always sort out first, and then it is based on
 *	the G.g_isort parameter.  Return (-1) if pf1 < pf2, (0) if
 *	pf1 == pf2, and (1) if pf1 > pf2.
 */
LINEF_STATIC int pn_comp(P(FNODE *) pf1, P(FNODE *) pf2)
PP(register FNODE *pf1;)
PP(register FNODE *pf2;)
{
	/* Folders always sort out first */
	if ((pf1->f_attr ^ pf2->f_attr) & FA_DIREC)
		return (pf1->f_attr & FA_DIREC) ? -1 : 1;
	else
		return pn_fcomp(pf1, pf2, thedesk->g_isort);
}


/* 104de: 00fd9118 */
/* 106de: 00e19da6 */
FNODE *pn_sort(P(int16_t) lstcnt, P(FNODE *) pflist)
PP(int16_t lstcnt;)
PP(FNODE *pflist;)
{
	register FNODE *pf;
	register FNODE *pftemp;
	register THEDSK *d;
	FNODE *newlist;
	register int16_t gap;
	register int16_t i;
	register int16_t j;

	d = thedesk;
	/* build index array if necessary */
	if (lstcnt == -1)
	{
		lstcnt = 0;
		for (pf = pflist; pf; pf = pf->f_next)
		{
			d->ml_pfndx[lstcnt] = pf;
			lstcnt++;
		}
	}

	/* sort files using shell sort on page 108 of R C Prog. Lang. */
	for (gap = lstcnt / 2; gap > 0; gap /= 2)
	{
		for (i = gap; i < lstcnt; i++)
		{
			for (j = i - gap; j >= 0; j -= gap)
			{
				if (pn_comp(d->ml_pfndx[j], d->ml_pfndx[j + gap]) <= 0)
					break;
				pftemp = d->ml_pfndx[j];
				d->ml_pfndx[j] = d->ml_pfndx[j + gap];
				d->ml_pfndx[j + gap] = pftemp;
			}
		}
	}

	/* link up the list in order */
	newlist = NULL;
	pf = (FNODE *) &newlist;
	for (i = 0; i < lstcnt; i++)
	{
		pf->f_next = d->ml_pfndx[i];
		pf = d->ml_pfndx[i];
	}
	pf->f_next = NULL;
	
	return newlist;
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
	register FNODE **prevfile;
	register int found;
	register int ret;
	register int firsttime;
	register BOOLEAN iscart;

	if (thepath->p_spec[0] == CHAR_FOR_CARTRIDGE)
		iscart = TRUE;
	else
		iscart = FALSE;
	thepath->p_count = 0;
	thepath->p_size = 0;
	fl_free(thepath->p_flist);
	thefile = NULL;
	prevfile = &thepath->p_flist;
	if (iscart)
	{
		found = cart_sfirst((char *)thedesk->a_wdta, thepath->p_attr);
	} else
	{
		dos_sdta(thedesk->a_wdta);
		found = dos_sfirst(thepath->p_spec, thepath->p_attr);
	}
	while (found)
	{
		if (!thefile)
		{
			/* make so each dir. has a available new folder */
			thefile = fn_alloc();
		    if (!thefile )
		    {	
				found = FALSE;
				DOS_AX = E_NOFNODES;
		    }
		} else
		{
			if ((thedesk->g_wdta[30] != '.' ||
				 (thedesk->g_wdta[31] != '.' && thedesk->g_wdta[31] != '\0'))
				 )
			{
				/* if it is a real file or directory then save it */
				movs(23, &thedesk->g_wdta[20], &thefile->f_junk);
				thepath->p_size += thefile->f_size;
				*prevfile = thedesk->ml_pfndx[thepath->p_count++] = thefile;
				prevfile = &thefile->f_next;
				thefile = NULL;
			}
			if (iscart)
				found = cart_snext();
			else
				found = dos_snext();
		}
	}
	
	*prevfile = NULL;
	if (thefile)
		fn_free(thefile);
	thepath->p_flist = pn_sort(thepath->p_count, thepath->p_flist);
	return DOS_AX;
}
