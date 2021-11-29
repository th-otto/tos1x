/*  fshand.c - file handle routines for the file system			*/

#include "tos.h"
#include "fs.h"
#include "bios.h"
#include "mem.h"
#include <toserrno.h>




/*
 *  syshnd -
 */

/* 306de: 00e16e68 */
/* 306us: 00e16e0e */
/* 104de: 00fc788a */
FH syshnd(P(FH) h)
PP(register FH h;)
{
	if (h >= NUMSTD || (h = run->p_uft[h]) > 0)
		h -= NUMSTD;

	return h;
}



/*
 *  getofd -
 */
/* 306de: 00e16e98 */
/* 306us: 00e16e3e */
/* 104de: 00fc78ba */
OFD *getofd(P(FH) h)
PP(FH h;)
{
	if (h < 0 || h >= OPNFILES)
		return NULL;
	h = syshnd(h);
	if (h < 0)
		return NULL;
	return sft[h].f_ofd;
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
ERROR xdup(P(int16_t) h)
PP(int16_t h;)									/*+ h must be a standard handle (checked) */
{
	register FH i;
	register FTAB *p;
	
	if (h < 0 || h >= NUMSTD)
		return E_IHNDL;				/* only dup standard */

	if ((i = ffhndl()) < 0)
		return E_NHNDL;
	
	p = &sft[i];
	p->f_own = run;

	if ((h = run->p_uft[h]) > 0)
		p->f_ofd = sft[h - NUMSTD].f_ofd;
	else
		p->f_ofd = (OFD *)(long)h; /* hmpf */

	p->f_use = 1;

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
ERROR ixforce(P(FH) _std, P(FH) _h, P(PD *) _p)
PP(FH _std;)								/* std must be a standard handle    */
PP(FH _h;)									/* h   must NOT be a standard handle    */
PP(PD *_p;)
{
	register PD *p = _p;
	register FH std = _std;
	register FH h = _h;
	register long fh;

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
		if (getofd(h) == NULL)
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
ERROR xclose(P(FH) h)
PP(FH h;)
{
	register FH h0;
	register OFD *fd;
	register FTAB *ftab;
	register ERROR rc;

	ftab = &sft[h - NUMSTD];
	
	if (h < 0)
		return E_OK;					/* always a good close on a character device */

	if ((h0 = h) < NUMSTD)
	{
		h = run->p_uft[h];
		ftab = &sft[h - NUMSTD];
		run->p_uft[h0] = stddev[h0];				/* mark std dev as not in use */
		if (h < 0)
			return E_OK;
	} else if (((long) ftab->f_ofd) < 0L) /* BUG: h has not being checked yet for being < OPNFILES */
	{
		if (--ftab->f_use == 0)
		{
			ftab->f_ofd = NULL;
			ftab->f_own = NULL;
		}
		return E_OK;
	}

	if (!(fd = getofd(h)))
		return E_IHNDL;

	rc = ixclose(fd, 0);

	if (--ftab->f_use == 0)
	{
		oftdel(ftab->f_ofd);
		ftab->f_ofd = NULL;
		ftab->f_own = NULL;
	}
	
	return rc;
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
ERROR xread(P(int16_t) h, P(long) len, P(VOIDPTR) ubufr)
PP(int16_t h;)
PP(long len;)
PP(VOIDPTR ubufr;)
{
	register OFD *p;

	if ((p = getofd(h)) != NULL)
	{
		if (len == 0)
			return 0;
		return ixread(p, len, ubufr);
	}
	
	return E_IHNDL;
}


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
ERROR xwrite(P(FH) h, P(long) len, P(VOIDPTR) ubufr)
PP(FH h;)
PP(long len;)
PP(VOIDPTR ubufr;)
{
	register OFD *p;

	if ((p = getofd(h)) != NULL)
	{
		if (len == 0)
			return 0;
		p->o_flag |= O_DIRTY;
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
ERROR opnfil(P(const FCB *) f, P(DND *) dn, P(int16_t) mod)
PP(const FCB *f;)
PP(DND *dn;)
PP(int16_t mod;)
{
	register FH i;
	register FH h;

	/* find free sft handle */
	if ((i = ffhndl()) < 0)
		return E_NHNDL;

	sft[i].f_own = run;
	sft[i].f_use = 1;
	h = i + NUMSTD;

	return makopn(f, dn, h, mod);
}



/* 306de: 00e171d8 */
/* 306us: 00e1717e */
/* 104de: 00fc7bfa */
FH ffhndl(NOTHING)
{
	register int i;
	register FTAB *p;
	
	for (i = 0, p = sft; i < (OPNFILES - NUMSTD); i++, p++)
		if (p->f_own == NULL)
			return i;
	return -1;
}
