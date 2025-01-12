/*      DESKDISK.C      05/04/84 - 06/20/85     Lee Lorenzen            */
/*      for 3.0 (xm)    3/12/86  - 01/17/87     MDF                     */
/*      for 3.0                 11/13/87                mdf             */

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
#include "taddr.h"
#include "toserrno.h"


#define MAXTRACK	80					/* maximum number of track      */
#define FC_NUMOBJS	26
#define MAXSPT		9					/* Maximum sector / track       */
#define	SECSIZE		512
#define	TRKSIZE		0x1200				/* (bytesPerSector) * (sectorsPerTrack) */
#define RSECTS		2					/* |= 0x02 so mediach state is not checked */
#define WSECTS		3

#define FSIZE		0x2000L				/* format buffer size (8k)     */
#define	VIRGIN		0xe5e5				/* FORMAT value to write to new sectors */
#define	MAGIC		0x87654321L
#define INTERLV		-1					/* neg, so use skew table for format    */
#define SINGLESKEW	3					/* amount of SKEW for a single sided and high density disk */
#define	DOUBLESKEW	2					/* amount of skew between sides     */

#define	BADSECT		-16
#define MAXBAD		16					/* max number of bad sector allowed */

#include "../bios/bpb.h"


/* The DSB location is returned by getbpb (Xbios 7) and is defined in
 *	gemdos/rwabs.c.  We use it to determine the # of sides for
 *	fc_copy, since it's easier to call getbpb and use the
 *	system data structures than to read the boot sector
 *	ourselves. getbpb actually returns a pointer to
 *	this global system structure.
 *	(kbad 880830)
 */

#define DSB	struct dsb					/* Device Status Block (BLKDEV in bios.h) */
DSB
{
	BPB b;								/* BIOS Parameter Block     */

	int16_t tracks;						/* #tracks (cylinders) on dev   */
	int16_t sides;						/* #sides per cylinder      */
	int16_t spc;						/* #sectors/cylinder        */
	int16_t spt;						/* #sectors/track       */
	int16_t hidden;						/* #hidden tracks       */
	uint8_t serial[3];					/* 24-bit volume serial number  */
};

/*
 * sigh, why use trp13/trp14 from AES here?
 */
#undef Getbpb
#undef Rwabs
#undef Flopfmt
#undef Protobt
#define Getbpb(devno) trp13(7, devno)
#define Rwabs(a,b,c,d,e) trp13(4, a, b, c, d, e)
#define Flopfmt(a,b,c,d,e,f,g,h,i) trp14(10, a, b, c, d, e, f, g, h, i)
#define Protobt(a,b,c,d) trp14(18, a, b, c, d)


STATIC int16_t w_inc;
STATIC int16_t bar_max;					/* in case user copies disk > 80 tracks */

/* ZZZ */
#define FCCNCL 0
#define FCCOPY 0
#define FCFORMAT 0
#define SRCDRA 0
#define SRCDRB 0
#define ADRIVE 0
#define BDRIVE 0

static int16_t const ttable[] = { FCCNCL, FCCOPY, FCFORMAT, SRCDRA, SRCDRB, ADRIVE, BDRIVE };

static int16_t const skew2[MAXSPT] = { 3, 4, 5, 6, 7, 8, 9, 1, 2 };


LINEF_STATIC VOID fc_draw PROTO((LPTREE tree, int16_t which));
LINEF_STATIC VOID fc_format PROTO((LPTREE tree));
LINEF_STATIC VOID fc_copy PROTO((LPTREE tree));
LINEF_STATIC VOID fc_bar PROTO((LPTREE tree, int16_t which));
LINEF_STATIC int16_t fc_rwsec PROTO((int16_t op, VOIDPTR buf, int16_t nsect, int16_t sect, int16_t dev));
LINEF_STATIC VOID fc_clfix PROTO((uint16_t cl, uint16_t *fat));


/*
 * format and copy start
 */
/* 104de: 00fe6a5a */
/* 106de: 00e29230 */
VOID fc_start(P(const char *)source, P(int16_t) op)
PP(const char *source;)
PP(int16_t op;)
{
#if 0 /* ZZZ */
	register BOOLEAN ret;
	register int16_t width;
	int16_t i, field;
	register char *destdr;
	register LPTREE tree;
	int32_t value;
	int32_t unused;

	UNUSED(value);
	UNUSED(unused);
	tree = (LPTREE)thedesk->g_atree[ADFORMAT];

	destdr = (char *)OB_SPEC(DESTDR);		/* to set boxchar in DESTDR */

	width = LWGET(OB_WIDTH(FCBARA));
	w_inc = width / MAXTRACK;
	bar_max = width = w_inc * MAXTRACK;
	LWSET(OB_WIDTH(FCBARA), width);
	LWSET(OB_WIDTH(FCBARB), width);

	for (i = 0; i < 7; i++)
		LWSET(OB_STATE(ttable[i]), NORMAL);

	inf_sset((OBJECT *)tree, FCLABEL, "");

	LWSET(OB_FLAGS(FCBOXF), HIDETREE);
	LWSET(OB_FLAGS(FCBOXC), HIDETREE);

	ret = *source != 'A' ? FALSE : TRUE;

	if (op == CMD_COPY)
	{									/* format box   */
		LWSET(OB_STATE(ret ? BDRIVE : ADRIVE), SELECTED);
		/* copy box */
		LWSET(OB_STATE(ret ? SRCDRA : SRCDRB), SELECTED);
		*destdr = ret ? 'B' : 'A';
		LWSET(OB_STATE(FCCOPY), SELECTED);
		ret = FCCOPY;
	} else
	{									/* op == CMD_FORMAT     */
		/* copy box */
		LWSET(OB_STATE(ret ? SRCDRB : SRCDRA), SELECTED);
		*destdr = ret ? 'A' : 'B';
		/* format box */
		LWSET(OB_STATE(ret ? ADRIVE : BDRIVE), SELECTED);
		LWSET(OB_STATE(FCFORMAT), SELECTED);
		ret = FCFORMAT;
	}

	fm_draw(tree);

#ifndef __ALCYON__
	field = 0; /* BUG: used uninitailized below */
#endif
	while (TRUE)						/* while loop   */
	{
		switch (ret)
		{
		case FCFORMAT:
			drawfld((OBJECT *)tree, FCBOXC);		/* erase copy function */
			LWSET(OB_FLAGS(FCBOXC), HIDETREE);
			LWSET(OB_FLAGS(FCBOXF), NONE);
			fc_draw(tree, FCBOXF);		/* draw the format  */
			field = 0;
			break;

		case FCCOPY:
			drawfld((OBJECT *)tree, FCBOXF);		/* erase the format     */
			LWSET(OB_FLAGS(FCBOXF), HIDETREE);
			LWSET(OB_FLAGS(FCBOXC), NONE);
			fc_draw(tree, FCBOXC);
			field = NIL;
			break;

		case SRCDRA:					/* set the copy drive   */
		case SRCDRB:
			*destdr = ret == SRCDRA ? 'B' : 'A';
			drawfld((OBJECT *)tree, DESTDR);
			break;

		case FCCNCL:					/* cancel       */
			do_finish((OBJECT *)tree);
			up_allwin("A", FALSE);
			up_allwin("B", FALSE);
			desk_clear(DESK);
			return;

		case FCOK:
			desk_wait(TRUE);
			LWSET(OB_WIDTH(FCBARA), 0);
			LWSET(OB_WIDTH(FCBARB), 0);

			if (LWGET(OB_STATE(FCFORMAT)) & SELECTED)
			{
				fc_format(tree);
			} else
			{
				fc_copy(tree);
			}
			LWSET(OB_WIDTH(FCBARA), width);
			LWSET(OB_WIDTH(FCBARB), width);
			LWSET(OB_STATE(FCOK), NORMAL);
			drawfld((OBJECT *)tree, FCBARA);
			drawfld((OBJECT *)tree, FCBARB);
			drawfld((OBJECT *)tree, FCOK);
			desk_wait(FALSE);
		}

		ret = form_do((OBJECT *)tree, field) & 0x7FFF;
	}
#endif
}


/*
 * format disk
 */
/* 306de: 00e2a1a4 */
/* 104de: 00fe6d20 */
/* 106de: 00e29542 */
LINEF_STATIC VOID fc_format(P(LPTREE) tree)
PP(LPTREE tree;)
{
	register char *bufaddr;
	register int16_t badindex;
	register int16_t ret;
	register int16_t i;
	register int16_t trackno;
	int32_t dsb;
	int32_t avail;
	int32_t total;
	int16_t devno;
	int16_t j;
	int16_t k;
	int16_t disktype;
	int16_t sideno;
	int16_t curtrk;
	int16_t track;
	int16_t numside;
	int16_t cl;
	register int16_t *badtable;
	register int16_t *fat;
	register BPB *bpbaddr;
	int16_t sktable[MAXSPT];
	int16_t skewtable[MAXSPT];
	int16_t skew;
	char label1[14];
	char label2[14];

	UNUSED(curtrk);
	UNUSED(dsb);
	
	/* format needs 8k buffer   */
	if (!(bufaddr = (char *)dos_alloc(FSIZE)))		/* no memory            */
	{
	memerr:
		do1_alert(FCNOMEM);
		return;
	}

	fat = (int16_t *)bufaddr;						/* the bad sector table     */

	/* my bad sector table */
	if (!(badtable = (int16_t *)dos_alloc(FSIZE)))	/* no memory            */
	{
		dos_free(bufaddr);
		goto memerr;
	}

	track = MAXTRACK;					/* always 80 tracks */
	numside = 2;						/* assume double sided  */
	disktype = 3;

#if 0 /* ZZZ */
	if (LWGET(OB_STATE(FCSINGLE)) & SELECTED)
	{
		numside = 1;					/* it is single sided   */
		disktype = 2;
	}

	devno = (LWGET(OB_STATE(ADRIVE)) & SELECTED) ? 0 : 1;
#endif

	ret = 0;							/* assume it is ok  */
	badindex = 0;						/* bad sector table */

	for (i = 0; i < MAXSPT; i++)
		skewtable[i] = skew2[i];

	/* amount of skew from track to track   */
	skew = numside == 1 ? SINGLESKEW : DOUBLESKEW;

	for (trackno = 0; trackno < track && !ret; trackno++)
	{
		for (sideno = 0; sideno < numside && !ret; sideno++)
		{
			for (i = skew; i < MAXSPT; i++)
			{
				sktable[i] = skewtable[i - skew];
			}
			for (i = 0; i < skew; i++)
			{
				ret = MAXSPT - skew;
				sktable[i] = skewtable[ret + i];
			}
			for (i = 0; i < MAXSPT; i++)
			{
				skewtable[i] = sktable[i];
			}
			
		fagain:
			ret = (int16_t) (Flopfmt(bufaddr, sktable, devno,
								MAXSPT, trackno, sideno, INTERLV, MAGIC, VIRGIN));

			if (ret == E_BADSF)				/* Bad sectors !    */
			{
				if (trackno < 2 || ((badindex + MAXSPT) >= MAXBAD))
				{
#if 0 /* ZZZ */
					while (do1_alert(FCFAIL) == 1)	/* too many bad sectors */
						;
#endif
					ret = 1;
					break;
				} else
				{
					for (i = 0; fat[i]; i++, badindex++)
					{
						badtable[badindex] = (trackno * numside * MAXSPT) + ((fat[i] - 1) + (sideno * MAXSPT));

						ret = 0;
					}
				}
			}
			/* if errror == 16 */
			if (ret)					/* some other error */
			{							/* retry        */
#if 0 /* ZZZ */
				if (do1_alert(FCFAIL) == 1)
					goto fagain;
#endif
			}

		}								/* sideno   */

		fc_bar(tree, devno);			/* increment destination bar    */

	}									/* for trackno */

	if (!ret)							/* set up the Boot Sector info  */
	{
		Protobt(bufaddr, 0x01000000L, disktype, 0);
#if TP_31 /* MS_DOS */
		*((long *)bufaddr) = 0xeb34904eL;
#else
		*bufaddr = 0xe9;
#endif

#ifdef __ALCYON__
		if ((ret = fc_rwsec(WSECTS, bufaddr, 0x10000L, devno)))
#else
		if ((ret = fc_rwsec(WSECTS, bufaddr, 1, 0, devno)))
#endif
			goto eout1;
		/* now set up the fat0 and fat1 */
		bpbaddr = (BPB *)Getbpb(devno);

		/* 27-Mar-1985 lmd
		 * write boot sector again
		 * (this makes the media dirty, with drivemode = "changed")
		 */

#ifdef __ALCYON__
		if ((ret = fc_rwsec(WSECTS, bufaddr, 0x10000L, devno)))
#else
		if ((ret = fc_rwsec(WSECTS, bufaddr, 1, 0, devno)))
#endif
			goto eout1;

		k = max(bpbaddr->fsiz, bpbaddr->rdlen);
		j = (k * SECSIZE) / 2;

		/* clean up root directory  */
		for (i = 0; i < j; i++)
			fat[i] = 0;
		/* get the label */
#if 0 /* ZZZ */
		fs_sget(tree, FCLABEL, label1);
#endif

		if (label1[0])
		{
			bfill(11, ' ', label2);
			i = 0;
			while (label1[i])
			{
				label2[i] = label1[i];
				i++;
			}

			LBCOPY(bufaddr, label2, 11);
			fat[5] |= 0x0008;			/* file attribute   */
		}

		i = 1 + (bpbaddr->fsiz * 2);

		if ((ret = fc_rwsec(WSECTS, bufaddr, bpbaddr->rdlen, i, devno)))
			goto eout1;

		/* clean up FAT table   */
		for (i = 0; i < j; i++)
			fat[i] = 0;

		/* the first 3 bytes have to be 0xF7FFFF */

		fat[0] = 0xF9FF;				/* MS-DOS format        */
		fat[1] = 0xFF00;
		/* now make up the sector map   */
		for (i = 0; i < badindex; i++)
		{
			cl = (badtable[i] - bpbaddr->datrec) / bpbaddr->clsiz + 2;
			fc_clfix(cl, (uint16_t *)fat);
		}
		/* write out fat 0  */
		if ((ret = fc_rwsec(WSECTS, fat, bpbaddr->fsiz, 1, devno)))
			goto eout1;
		/* write out fat 1  */
		ret = fc_rwsec(WSECTS, fat, bpbaddr->fsiz, 1 + bpbaddr->fsiz, devno);

	}
  eout1:
	/* now compute the size in bytes and tell the user  */

	desk_wait(FALSE);

	if (!ret)
	{
		dos_space(devno + 1, &total, &avail);
#if 0 /* ZZZ */
		fun_alert(1, FCSIZE, &avail);
#endif
	}

	dos_free(bufaddr);
	dos_free(badtable);
}


/*
 * disk copy
 */
/* 306de: 00e2a654 */
/* 104de: 00fe7126 */
/* 106de: 00e299a0 */
LINEF_STATIC VOID fc_copy(P(LPTREE) tree)
PP(LPTREE tree;)
{
	register intptr_t bootbuf, buf;
	intptr_t bufptr;
	int32_t bufsize;
	int16_t devnos, devnod;
	register DSB *dsbs, *dsbd;
	int16_t spc, bps, bpc, disksect, sectbufs, leftover;
	int16_t checkit, last, ret;
	int16_t dev, sectno, ssect, dsect, trkops;
	register int16_t j, op, loop;

	UNUSED(ret);
	
	if (!(bootbuf = (intptr_t)dos_alloc(0x258L)))
	{
errmem:
		do1_alert(FCNOMEM);
		return;
	}

#if 0 /* ZZZ */
	devnos = (LWGET(OB_STATE(SRCDRA)) & SELECTED) ? 0 : 1;
#endif
	devnod = devnos ? 0 : 1;

chksrc:
	if (!(dsbs = (DSB *)Getbpb(devnos)))
	{
#if 0 /* ZZZ */
		if (do1_alert(FCFAIL) == 1)		/* retry */
			goto chksrc;
#endif
		dos_free((VOIDPTR)bootbuf);
		return;
	}

/* should spc exist? */
	spc = dsbs->spc;					/* sectors per cylinder    */
	bps = dsbs->b.recsiz;				/* bytes per sector    */
	bpc = spc * bps;					/* bytes per cylinder      */

	/* buffer at least a track */
	if ((bufsize = dos_avail()) < (int32_t) bpc)
	{
		dos_free((VOIDPTR)bootbuf);
		goto errmem;
	}

	buf = (intptr_t)dos_alloc(bufsize);				/* get the buffer       */
	disksect = spc * dsbs->tracks;		/* total sectors on disk    */
	sectbufs = bufsize / bps;			/* how many sector buffers  */
	leftover = disksect % sectbufs;		/* sectors left for last loop */

	checkit = TRUE;
	last = FALSE;
	ssect = dsect = sectno = 0;

	if (!(loop = disksect / sectbufs))	/* how many times to loop   */
	{
		sectbufs = leftover;
		last = TRUE;
		loop = 1;
	}

	/* read boot sector */
#ifdef __ALCYON__
	if (fc_rwsec(RSECTS, (VOIDPTR)bootbuf, 0x10000L, devnos))
#else
	if (fc_rwsec(RSECTS, (VOIDPTR)bootbuf, 1, 0, devnos))
#endif
		goto bailout;

	while (loop--)
	{
		dev = devnos;
		for (op = RSECTS; op <= WSECTS; op++)	/* read, write loop        */
		{
			bufptr = buf;
			/* draw bar once per track */
			trkops = sectbufs / spc;	/* how many track operations */
			for (j = 0; j < trkops; j++)
			{
				if (fc_rwsec(op, (VOIDPTR)bufptr, spc, sectno, dev))
					goto bailout;
				sectno += spc;
				bufptr += bpc;
				fc_bar(tree, dev);
			}
#if BINEXACT
			/*
			 * This is miscompiled into
			 * ...
			 * divs -14(a6),d5
			 * swap d5
			 * beq ...
			 * however swap sets the Z-bit if the 32-bit result is zero
			 */
			if ((j = sectbufs % spc))
#else
			j = sectbufs % spc;
			if (j)
#endif
			{
				if (fc_rwsec(op, (VOIDPTR)bufptr, j, sectno, dev))
					goto bailout;
				sectno += j;
				fc_bar(tree, dev);
			}
			if (op == RSECTS)
			{
				ssect = sectno;
				sectno = dsect;
				if (checkit)
				{
					checkit = FALSE;
				fc_c1:
					if (!(dsbd = (DSB *)Getbpb(devnod)))
					{
#if 0 /* ZZZ */
						if (do1_alert(FCFAIL) == 1)	/* retry */
							goto fc_c1;
#endif
						goto bailout;
					}
					if ((dsbs->sides != dsbd->sides) ||
						(spc != dsbd->spc) || (dsbs->tracks != dsbd->tracks) || (bps != dsbd->b.recsiz))
					{
#if 0 /* ZZZ */
						if (fun_alert(1, FCNOTYPE, NULL) != 1)
							goto bailout;
#endif

						goto fc_c1;		/* try again    */
					}
				}
			} else
			{
				dsect = sectno;
				sectno = ssect;
			}
			dev = devnod;
		}

		if (!loop && !last)
		{
			loop = 1;
			sectbufs = leftover;
			last = TRUE;
		}
	}

	/* change the serialno */
	Protobt(bootbuf, 0x01000000L, -1, -1);
#ifdef __ALCYON__
	fc_rwsec(WSECTS, (VOIDPTR)bootbuf, 0x10000L, devnod);
#else
	fc_rwsec(WSECTS, (VOIDPTR)bootbuf, 1, 0, devnod);
#endif

  bailout:
	dos_free((VOIDPTR)buf);
	dos_free((VOIDPTR)bootbuf);
}


/* 306de: 00e2a982 */
/* 104de: 00fe73d0 */
/* 106de: 00e29c90 */
LINEF_STATIC int16_t fc_rwsec(P(int16_t) op, P(VOIDPTR) buf, P(int16_t) nsect, P(int16_t) sect, P(int16_t) dev)
PP(int16_t op;)
PP(VOIDPTR buf;)
PP(int16_t nsect;)
PP(int16_t sect;)
PP(int16_t dev;)
{
	register int16_t ret;

  rerw:
  	if ((ret = Rwabs(op, buf, nsect, sect, dev)))
#if 0 /* ZZZ */
		if ((ret = do1_alert(FCFAIL)) == 1)	/* retry */
#endif
			goto rerw;
	return ret;						/* 0=>OK, 2=>error */
}


/*
 * put in the next cluster number
 */
/* 306de: 00e2a9d0 */
/* 104de: 00fe7408 */
/* 106de: 00e29cd6 */
LINEF_STATIC VOID fc_clfix(P(uint16_t) cl, P(uint16_t *)fat)
PP(uint16_t cl;)
PP(uint16_t *fat;)
{
	register uint16_t ncl, cluster;
	uint16_t temp, num;

	UNUSED(temp);
	
	num = 0x0FF7;

	ncl = cl + (cl >> 1);				/* multiply by 1.5  */
	/* get the fat value 12 bit */

	cluster = fat[ncl] & 0x00FF;
	cluster |= fat[ncl + 1] << 8;

	if (cl & 0x1)						/* is it odd ?      */
	{
		cluster &= 0x000F;				/* leave the last byte alone    */
		num = num << 4;
	} else
		cluster &= 0xF000;				/* leave the high byte alone    */

	num = cluster | num;

	fat[ncl] = num;
	fat[ncl + 1] = num >> 8;
}


int16_t do1_alert(P(int16_t) item)
PP(int16_t item;)
{
	return fun_alert(1, item, NULL);
}


/*
 * Inc and redraw slider bar
 */
/* 306de: 00e2aa84 */
/* 104de: 00fe74ba */
VOID fc_bar(P(LPTREE)tree, P(int16_t) which)
PP(LPTREE tree;)
PP(register int16_t which;)
{
	register int16_t *width;
	register intptr_t *obspec;
	register int16_t wid;

#if 0 /* ZZZ */
	if (which)
		which = FCBARB;
	else
		which = FCBARA;
#endif
	width = (int16_t *)OB_WIDTH(which);
	obspec = (intptr_t *)OB_SPEC(which);

	wid = *width + w_inc;

	wid = wid < bar_max ? wid : bar_max;	/* don't overflow box */

	*width = wid;
	*obspec = 0xFF1121L;
	fc_draw(tree, which);
	*obspec = 0xFF1101L;
}



/* 306de: 00e2ab0c */
/* 104de: 00fe752a */
VOID fc_draw(P(LPTREE)tree, P(int16_t) which)
PP(LPTREE tree;)
PP(int16_t which;)
{
	GRECT size;

	RC_COPY((GRECT *)OB_X(which), &size);
	objc_offset((OBJECT *)tree, which, &size.g_x, &size.g_y);
	objc_draw((OBJECT *)tree, which, MAX_DEPTH, size.g_x, size.g_y, size.g_w + 2, size.g_h);
}
