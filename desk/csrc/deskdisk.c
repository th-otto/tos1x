/*      DESKDISK.C From 1.4     12/7/87 - 12/15/87      Derek.Mui       */
/*      For newdesktop          3/18/89 - 6/15/89       Derek Mui       */
/*      Update and crunch       8/30/89                 D.Mui           */
/*      Change at fc_format     1/29/90                 D.Mui           */
/*      Add high density formatting     2/21/90         D.Mui           */
/*      Change the up_allwin to up_1allwin      11/14/90        D.Mui   */
/*      Change the high density media cookie value      4/26/91 D.Mui   */
/*      Change the setting of FCDOUBLE button           4/30/91 D.Mui   */

/*      Discussion of skew factors
 *       
 *       The optimal skew factor for single/double sided formats is:
 *       7 8 9 1 2 3 4 5 6
 *       5 6 7 8 9 1 2 3 4
 *       ( that is, a skew factor of 2 )
 *
 *       This is because the floppy drive always does a seek-with-verify,
 *       so the controller needs to read sector 9, seek to the next head/side
 *       ( where it's too late to catch the ID of sector 8 ), read the sector
 *       ID of sector 9 ( to verify the seek; now the seek is done ). and
 *       then begin reading with sector 1.
 *
 *       However, some Atari single-sided drives are actually 6ms drives.
 *       They have extra circuitry to convert the 3ms step pulses into 
 *       6ms pulses, but this slows them down enough that the above
 *       skew factor is not enough. Hence, single-sided disks are formatted
 *       with a skew factor of 3 ( or 6, depending ).
 */

/************************************************************************/
/*      New Desktop for Atari ST/TT Computer                            */
/*      Atari Corp                                                      */
/*      Copyright 1989,1990     All Rights Reserved                     */
/************************************************************************/

#include "desktop.h"
#include "toserrno.h"

#define MAXTRACK	80					/* maximum number of track      */
#define FC_NUMOBJS	26
#define MAXSPT		18					/* Maximum sector / track       */
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

STATIC int16_t w_inc;

STATIC int16_t bar_max;					/* in case user copies disk > 80 tracks */

static int16_t const ttable[] = { FCCNCL, FCCOPY, FCFORMAT, SRCDRA, SRCDRB, ADRIVE,
	BDRIVE
};

static int16_t const skew1[MAXSPT * 2] = {
	1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11,
	12, 13, 14, 15, 16, 17, 18,
	1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11,
	12, 13, 14, 15, 16, 17, 18
};

static int16_t const skew2[MAXSPT] = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 1, 2, 3, 4, 5, 6, 7, 8, 9 };


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


BOOLEAN fc_format PROTO((OBJECT *obj));
VOID fc_copy PROTO((OBJECT *obj));
int16_t fc_rwsec PROTO((int16_t op, VOIDPTR buf, int16_t nsect, int16_t sect, int16_t dev));
LINEF_STATIC VOID fc_clfix PROTO((uint16_t cl, uint16_t *fat));
VOID fc_bar PROTO((OBJECT *obj, int16_t which));
VOID fc_draw PROTO((OBJECT *obj, int16_t which));




/*
 * format and copy start
 */
/* 306de: 00e29ea2 */
/* 104de: 00fe6a5a */
VOID fc_start(P(const char *)source, P(int16_t) op)
PP(const char *source;)
PP(int16_t op;)
{
	register BOOLEAN ret;
	register int16_t width;
	int16_t i, field, operation;
	register char *destdr;
	register OBJECT *obj;
	int32_t value;

	obj = get_tree(ADFORMAT);

	/* check for switch in cookie jar   */

	obj[FCDOUBLE].ob_state = SELECTED;

	destdr = (char *)&obj[DESTDR].ob_spec;		/* to set boxchar in DESTDR */

	width = obj[FCBARA].ob_width;
	w_inc = width / MAXTRACK;
	bar_max = width = w_inc * MAXTRACK;
	obj[FCBARA].ob_width = width;
	obj[FCBARB].ob_width = width;

	for (i = 0; i < 7; i++)
		obj[ttable[i]].ob_state = NORMAL;

	inf_sset(obj, FCLABEL, Nostr);

	obj[FCBOXF].ob_flags = HIDETREE;
	obj[FCBOXC].ob_flags = HIDETREE;

	ret = *source == 'A';

	if (op == CMD_COPY)
	{									/* format box   */
		obj[ret ? BDRIVE : ADRIVE].ob_state = SELECTED;
		/* copy box */
		obj[ret ? SRCDRA : SRCDRB].ob_state = SELECTED;
		*destdr = ret ? 'B' : 'A';
		obj[FCCOPY].ob_state = SELECTED;
		ret = FCCOPY;
	} else
	{									/* op == CMD_FORMAT     */
		/* copy box         */
		obj[ret ? SRCDRB : SRCDRA].ob_state = SELECTED;
		*destdr = ret ? 'A' : 'B';
		/* format box */
		obj[ret ? ADRIVE : BDRIVE].ob_state = SELECTED;
		obj[FCFORMAT].ob_state = SELECTED;
		ret = FCFORMAT;
	}

	fm_draw(ADFORMAT);

	operation = FALSE;

#if !BINEXACT
	field = 0; /* BUG: used uninitailized below */
#endif
	while (TRUE)						/* while loop   */
	{
	fc_1:
		switch (ret)
		{
		case FCFORMAT:
			drawfld(obj, FCBOXC);		/* erase copy function */
			obj[FCBOXC].ob_flags = HIDETREE;
			obj[FCBOXF].ob_flags = 0;
			fc_draw(obj, FCBOXF);		/* draw the format  */
			field = 0;
			break;

		case FCCOPY:
			drawfld(obj, FCBOXF);		/* erase the format     */
			obj[FCBOXF].ob_flags = HIDETREE;
			obj[FCBOXC].ob_flags = 0;
			fc_draw(obj, FCBOXC);
			field = NIL;
			break;

		case SRCDRA:					/* set the copy drive   */
		case SRCDRB:
			*destdr = ret == SRCDRA ? 'B' : 'A';
			drawfld(obj, DESTDR);
			break;

		case FCCNCL:					/* cancel       */
			do_finish(ADFORMAT);
			if (operation)
			{
				up_allwin("A", FALSE);
				up_allwin("B", FALSE);
			}
			return;

		case FCOK:
			desk_wait(TRUE);
			obj[FCBARA].ob_width = 0;
			obj[FCBARB].ob_width = 0;
			operation = TRUE;

			if (obj[FCFORMAT].ob_state & SELECTED)
			{
				ret = fc_format(obj);
			} else
			{
				fc_copy(obj);
				ret = TRUE;
			}
			obj[FCBARA].ob_width = width;
			obj[FCBARB].ob_width = width;
			obj[FCOK].ob_state = NORMAL;
			drawfld(obj, FCBARA);
			drawfld(obj, FCBARB);
			drawfld(obj, FCOK);
			desk_wait(FALSE);
			if (!ret)
			{
				ret = FCCNCL;
				goto fc_1;
			}
		}

		ret = form_do(obj, field) & 0x7FFF;
	}
}


/*
 * format disk
 */
/* 306de: 00e2a1a4 */
/* 104de: 00fe6d20 */
BOOLEAN fc_format(P(OBJECT *)obj)
PP(OBJECT *obj;)
{
	register char *bufaddr;
	register int16_t badindex, ret, i, trackno;
	int32_t dsb, valuel, value2;
	int16_t devno, j, k, disktype;
	int16_t sideno, curtrk, skew, skewi;
	int16_t track, numside, cl;
	register int16_t *badtable;
	register int16_t *fat;
	register BPB *bpbaddr;
	char label1[14];
	char label2[14];
	int32_t lbuf[4];
	int16_t spt;
	const int16_t *sktable;

	UNUSED(curtrk);
	UNUSED(value2);
	UNUSED(valuel);
	UNUSED(dsb);
	
	/* format needs 8k buffer   */
	if (!(bufaddr = (char *)dos_alloc(FSIZE)))		/* no memory            */
	{
	memerr:
		do1_alert(FCNOMEM);
		return TRUE;
	}

	fat = (int16_t *)bufaddr;						/* the bad sector table     */

	/* my bad sector table      */
	if (!(badtable = (int16_t *)dos_alloc(FSIZE)))	/* no memory            */
	{
		dos_free(bufaddr);
		goto memerr;
	}

	track = MAXTRACK;					/* always 80 tracks */
	spt = 9;
	numside = 2;						/* assume double sided  */
	disktype = 3;
	sktable = skew2;

	if (obj[FCSINGLE].ob_state & SELECTED)
	{
		numside = 1;					/* it is single sided   */
		disktype = 2;
	} else
	{
	}

	devno = (obj[ADRIVE].ob_state & SELECTED) ? 0 : 1;

	ret = 0;							/* assume it is ok  */
	badindex = 0;						/* bad sector table */

	/* amount of skew from track to track   */
	skew = numside == 1 || disktype == 4 ? SINGLESKEW : DOUBLESKEW;

	skewi = 0;

	for (trackno = 0; (trackno < track) && (!ret); trackno++)
	{
		for (sideno = 0; (sideno < numside) && (!ret); sideno++)
		{
			skewi -= skew;
			if (skewi < 0)
				skewi += spt;

		fagain:
			ret = (int16_t) (Flopfmt(bufaddr, &sktable[skewi], devno,
								 spt, trackno, sideno, INTERLV, MAGIC, VIRGIN));

			if (ret == E_BADSF)				/* Bad sectors !    */
			{
				if (trackno < 2 || ((badindex + spt) >= MAXBAD))
				{
					if (do1_alert(FCFAIL) == 1)	/* too many bad sectors */
						goto fagain;
					else
						ret = 1;
					break;
				} else
				{
					for (i = 0; fat[i]; i++, badindex++)
					{
						badtable[badindex] = (trackno * numside * spt) + ((fat[i] - 1) + (sideno * spt));

						ret = 0;
					}
				}
			}
			/* if errror == 16 */
			if (ret)					/* some other error */
			{							/* retry        */
				if (do1_alert(FCFAIL) == 1)
					goto fagain;
			}

		}								/* sideno   */

		fc_bar(obj, devno);				/* increment destination bar    */

	}									/* for trackno */

	if (!ret)							/* set up the Boot Sector info  */
	{
		Protobt(bufaddr, 0x01000000L, disktype, 0);
		*bufaddr = 0xe9;

#if BINEXACT
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

#if BINEXACT
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
		/* get the label    */
		strcpy(label1, ((TEDINFO *) (obj[FCLABEL].ob_spec))->te_ptext);

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
		Dfree(lbuf, devno + 1);
		lbuf[0] = lbuf[0] * lbuf[2] * lbuf[3];
		merge_str(g_buffer, get_string(FCSIZE), lbuf);
		if (form_alert(1, g_buffer) == 1)
			ret = TRUE;					/* To Continue  */
	}

	Mfree(bufaddr);
	Mfree(badtable);
	return ret;
}


/*
 * disk copy
 */
/* 306de: 00e2a654 */
VOID fc_copy(P(OBJECT *)obj)
PP(OBJECT *obj;)
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
	
	if (!(bootbuf = Malloc(0x258L)))
	{
errmem:
		do1_alert(FCNOMEM);
		return;
	}

	devnos = (obj[SRCDRA].ob_state & SELECTED) ? 0 : 1;
	devnod = devnos ? 0 : 1;

chksrc:
	if (!(dsbs = (DSB *)Getbpb(devnos)))
	{
		if (do1_alert(FCFAIL) == 1)		/* retry */
			goto chksrc;
		Mfree(bootbuf);
		return;
	}

/* should spc exist? */
	spc = dsbs->spc;					/* sectors per cylinder    */
	bps = dsbs->b.recsiz;				/* bytes per sector    */
	bpc = spc * bps;					/* bytes per cylinder      */

	/* buffer at least a track */
	if ((bufsize = Malloc(0xFFFFFFFFL)) < (int32_t) bpc)
	{
		Mfree(bootbuf);
		goto errmem;
	}

	buf = Malloc(bufsize);				/* get the buffer       */
	disksect = spc * (dsbs->tracks);	/* total sectors on disk    */
	sectbufs = (bufsize / bps);			/* how many sector buffers  */
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
#if BINEXACT
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
			/* draw bar once per track  */
			trkops = sectbufs / spc;	/* how many track operations */
			for (j = 0; j < trkops; j++)
			{
				if (fc_rwsec(op, (VOIDPTR)bufptr, spc, sectno, dev))
					goto bailout;
				sectno += spc;
				bufptr += bpc;
				fc_bar(obj, dev);
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
				fc_bar(obj, dev);
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
						if (do1_alert(FCFAIL) == 1)	/* retry */
							goto fc_c1;
						goto bailout;
					}
					if ((dsbs->sides != dsbd->sides) ||
						(spc != dsbd->spc) || (dsbs->tracks != dsbd->tracks) || (bps != dsbd->b.recsiz))
					{
						if (do1_alert(FCNOTYPE) != 1)
							goto bailout;

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
#if BINEXACT
	fc_rwsec(WSECTS, (VOIDPTR)bootbuf, 0x10000L, devnod);
#else
	fc_rwsec(WSECTS, (VOIDPTR)bootbuf, 1, 0, devnod);
#endif

  bailout:
	Mfree(buf);
	Mfree(bootbuf);
	return;
}


/* 306de: 00e2a982 */
/* 104de: 00fe73d0 */
int16_t fc_rwsec(P(int16_t) op, P(VOIDPTR) buf, P(int16_t) nsect, P(int16_t) sect, P(int16_t) dev)
PP(int16_t op;)
PP(VOIDPTR buf;)
PP(int16_t nsect;)
PP(int16_t sect;)
PP(int16_t dev;)
{
	register int16_t ret;

  rerw:
  	if ((ret = Rwabs(op, buf, nsect, sect, dev)))
		if ((ret = do1_alert(FCFAIL)) == 1)	/* retry */
			goto rerw;
	return ret;						/* 0=>OK, 2=>error */
}


/*
 * put in the next cluster number
 */
/* 306de: 00e2a9d0 */
/* 104de: 00fe7408 */
static VOID fc_clfix(P(uint16_t) cl, P(uint16_t *)fat)
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


/*
 * Inc and redraw slider bar
 */
/* 306de: 00e2aa84 */
VOID fc_bar(P(OBJECT *)obj, P(int16_t) which)
PP(register OBJECT *obj;)
PP(register int16_t which;)
{
	register int16_t wid;

	which = which ? FCBARB : FCBARA;

	wid = obj[which].ob_width + w_inc;

	wid = wid < bar_max ? wid : bar_max;	/* don't overflow box */

	obj[which].ob_width = wid;
	obj[which].ob_spec = 0xFF1121L;
	fc_draw(obj, which);
	obj[which].ob_spec = 0xFF1101L;

}


/* 306de: 00e2ab0c */
VOID fc_draw(P(OBJECT *)obj, P(int16_t) which)
PP(OBJECT *obj;)
PP(int16_t which;)
{
	GRECT size;

	rc_copy((GRECT *)&obj[which].ob_x, &size);
	objc_offset(obj, which, &size.g_x, &size.g_y);
	objc_draw(obj, which, MAX_DEPTH, size.g_x, size.g_y, size.g_w + 2, size.g_h);
}
