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
#include "desksupp.h"
#undef NUM_STRINGS
#undef NUM_FRSTR
#undef NUM_UD
#undef NUM_IMAGES
#undef NUM_BB
#undef NUM_FRIMG
#undef NUM_IB
#undef NUM_CIB
#undef NUM_TI
#undef NUM_OBS
#undef NUM_TREE
#undef SCREEN
#include "fmtrsc.h"
#include "deskstr.h"


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
#define INTERLV		1					/* neg, so use skew table for format    */
#define SINGLESKEW	3					/* amount of SKEW for a single sided and high density disk */
#define	DOUBLESKEW	2					/* amount of skew between sides     */

#define	BADSECT		-16
#define MAXBAD		16					/* max number of bad sector allowed */

#include "../bios/bpb.h"

static char const s_fmterr[] = S_FMTERR;
static char const s_notsame[] = S_NOTSAME;
static char const s_freespace[] = S_FREESPACE;


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
 * sigh, why use bios/xbios from AES here?
 */
#undef Getbpb
#undef Rwabs
#undef Flopfmt
#undef Protobt
#undef Floprd
#undef Flopwr
#define Getbpb(devno) bios(7, devno)
#define Rwabs(a,b,c,d,e) bios(4, a, b, c, d, e)
#define Floprd(a,b,c,d,e,f,g) xbios(8, a, b, c, d, e, f, g)
#define Flopwr(a,b,c,d,e,f,g) xbios(9, a, b, c, d, e, f, g)
#define Flopfmt(a,b,c,d,e,f,g,h,i) xbios(10, a, b, c, d, e, f, g, h, i)
#define Protobt(a,b,c,d) xbios(18, a, b, c, d)
#define Dbmsg(a) xbios(11, a)


STATIC const char *fc_cmd;
STATIC OBJECT *fc_tree;
STATIC TEDINFO *fc_ted;
STATIC int16_t fc_x;
STATIC int16_t fc_y;


LINEF_STATIC VOID fc_bar PROTO((int16_t *w_inc, int16_t *bar_max, int16_t maxvalue));
LINEF_STATIC VOID fc_draw PROTO((NOTHING));
LINEF_STATIC VOID fc_clfix PROTO((int16_t cl, uint16_t num, BPB *bpb, VOIDPTR fat));
LINEF_STATIC VOID fc_do PROTO((OBJECT *tree, int16_t depth, BOOLEAN fmdo, int16_t startfld));
LINEF_STATIC VOID do1_alert PROTO((int16_t err, int16_t dev));
LINEF_STATIC BOOLEAN fc_alloc PROTO((VOIDPTR *buf, long *size));
LINEF_STATIC int16_t fc_rwtracks PROTO((int16_t op, intptr_t buf, intptr_t sktable, int16_t dev, int16_t side, int16_t w_inc, int16_t track, int16_t numtracks, char *cmd));

VOID fc_swp68 PROTO((uint16_t *val));

/* from aes/jbind.S */
long err_trap PROTO((int16_t err, int16_t dev));


/*
 * format and copy init
 */
LINEF_STATIC VOID fc_init(NOTHING)
{
	GRECT gr;
	
	ap_init();
	rom_ram(5, (intptr_t)pglobal, 0);
	rsrc_gaddr(R_TREE, ADFORMAT, (VOIDPTR *)&fc_tree);
	rsrc_gaddr(R_TEDINFO, 0, (VOIDPTR *)&fc_ted);
	/* WTF: those objects do not exist in the resource tree */
	fc_x = fc_tree[FCBOXS].ob_x;
	fc_y = fc_tree[FCBOXS].ob_y;
	ob_center((LPTREE)&fc_tree[ROOT], &gr);
	ob_center((LPTREE)&fc_tree[FCCOPYBOX], &gr);
	ob_center((LPTREE)&fc_tree[FCPROGRESS], &gr);
	desk_wait(FALSE);
}


/*
 * format disk
 */
/* 306de: 00e2a1a4 */
/* 104de: 00fe6d20 */
/* 106de: 00e29542 */
VOID sh_format(P(char *) fname, P(char *) cmd)
PP(char *fname;)
PP(char *cmd;)
{
	register intptr_t bufaddr;
	register int16_t trackno;
	register int16_t disktype;
	register int16_t badindex;
	register int16_t ret;
	register int16_t *badtable;
	register int16_t *fat;
	register BPB *bpbaddr;
	long sktable;
	struct {
		int32_t total;
		int32_t avail;
	} parms;
	int i;
	int16_t j;
	int16_t k;
	int16_t bar_max;
	int16_t w_inc;
	int sideno;
	int16_t curtrk;
	int devno;
	int track;
	int numside;
	int16_t cl;

	UNUSED(curtrk);	

	/* format needs 8k buffer */
	/* BUG: no malloc check */
	bufaddr = (intptr_t)dos_alloc(FSIZE);
	fat = (int16_t *)bufaddr;						/* the bad sector table     */

	/* my bad sector table */
	badtable = (int16_t *)dos_alloc(FSIZE);

	fc_init();
	fc_ted->te_ptext = fname;
	fc_cmd = cmd;
	while (TRUE)
	{
		fc_ted[1].te_txtlen = 12; /* WTF: sets te_txtlen in FCLABEL */
		fc_do(fc_tree, 2, TRUE, FCLABEL);
		if (fc_tree[FCCNCL].ob_state != NORMAL)
		{
			fc_tree[FCCNCL].ob_state = NORMAL;
			break;
		}
		fc_tree[FCFORMAT].ob_state = NORMAL;
		numside = 1;						/* assume single sided  */
		track = MAXTRACK;					/* always 80 tracks */
		disktype = 2;
		if (fc_tree[FCDOUBLE].ob_state != NORMAL)
		{
			numside = 2;					/* it is double sided   */
			disktype = 3;
		}
		fc_tree[FCCMD].ob_spec = (intptr_t)cmd;
		fc_bar(&w_inc, &bar_max, track);
		fc_tree[FCBARS].ob_width = 0;
		devno = fname[0] - 'A';
		sktable = Dbmsg(devno); /* WTF */

		ret = 0;							/* assume it is ok  */
		badindex = 0;
		for (trackno = 0; trackno < track && !ret; trackno++)
		{
			for (sideno = 0; sideno < numside && !ret; sideno++)
			{
				ret = (int16_t) (Flopfmt(bufaddr, sktable, devno,
								MAXSPT, trackno, sideno, INTERLV, MAGIC, VIRGIN));
				if (ret < 0 && ret > E_BADSF)
				{
					do1_alert(ret, devno);
				}
				if (ret == E_BADSF)				/* Bad sectors !    */
				{
					if (trackno < 2 || ((badindex + MAXSPT) >= MAXBAD))
					{
						do1_alert(1, devno);
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
				if (trackno == 0 && ret == 0)
				{
					ret = Floprd(bufaddr, 0L, devno, 1, 0, 0, 1);
				}
				if (ret < 0)
				{
					/* some other error */
					do1_alert(1, devno);
				}
			}
			if (ret == 0)
			{
				/* increment destination bar */
				fc_tree[FCBARS].ob_width += w_inc;
				fc_do(&fc_tree[FCBARS], 0, FALSE, 0);
			}
		}
		if (ret == 0)
		{
			/* set up the Boot Sector info  */
			Protobt(bufaddr, 0x01000000L, disktype, 0);
#if TP_31 /* MS_DOS */
			*((long *)bufaddr) = 0xeb34904eL;
#endif
			Flopwr(bufaddr, sktable, devno, 1, 0, 0, 1);
			/* now set up the fat0 and fat1 */
			bpbaddr = (BPB *)Getbpb(devno);
			/* 27-Mar-1985 lmd
			 * write boot sector again
			 * (this makes the media dirty, with drivemode = "changed")
			 */

			Flopwr(bufaddr, sktable, devno, 1, 0, 0, 1);
			k = max(bpbaddr->fsiz, bpbaddr->rdlen);
			j = (k * SECSIZE) / 2;

			/* clean up root directory  */
			for (i = 0; i < j; i++)
				fat[i] = 0;
			/* get the label */
			fat[5] = 0x0008;			/* file attribute   */
			LBCOPY((VOIDPTR)bufaddr, fc_ted[1].te_ptext, 11);

			i = 1 + (bpbaddr->fsiz * 2);
			Rwabs(WSECTS, bufaddr, bpbaddr->rdlen, i, devno);
			
			/* clean up FAT table   */
			for (i = 0; i < j; i++)
				fat[i] = 0;

			/* the first 3 bytes have to be 0xF7FFFF */
			fat[0] = 0xF7FF;				/* MS-DOS format        */
			fat[1] = 0xFF00;
			/* now make up the sector map   */
			for (i = 0; i < badindex; i++)
			{
				cl = (badtable[i] - bpbaddr->datrec) / bpbaddr->clsiz + 2;
				fc_clfix(cl, -1, bpbaddr, (VOIDPTR)bufaddr);
			}
			/* write out fat 0  */
			Rwabs(WSECTS, (VOIDPTR)bufaddr, bpbaddr->fsiz, 1, devno);
			/* write out fat 1  */
			Rwabs(WSECTS, (VOIDPTR)bufaddr, bpbaddr->fsiz, 1 + bpbaddr->fsiz, devno);
		}
		
		desk_wait(FALSE);
		
		if (!ret)
		{
			/* now compute the size in bytes and tell the user  */
			dos_space(devno + 1, &parms.total, &parms.avail);
			merge_str((char *)bufaddr, s_freespace, (uint16_t *)&parms.avail);
			fc_draw();
			fm_alert(1, (char *)bufaddr);
		}
	}
	dos_free((VOIDPTR) bufaddr);
	dos_free(fc_tree); /* WTF */ /* BUG: not allocated */
	dos_free(badtable);
	rsrc_free();
}


/*
 * disk copy
 */
/* 306de: 00e2a654 */
/* 104de: 00fe7126 */
/* 106de: 00e299a0 */
VOID sh_copy(P(char *) fname, P(char *) cmd)
PP(char *fname;)
PP(char *cmd;)
{
	register int devnos;
	register int devnod;
	register int side;
	register int trackno;
	register int ret;
	register DSB *dsbs;
	register DSB *dsbd;
	VOIDPTR buf;
	int i;
	int j;
	int16_t w_inc;
	long bufsize;
	int trackbufs;
	int trkops;
	int16_t bar_max;
	long unused;
	int16_t sides;
	int16_t tracks;
	long sktables;
	long sktabled;

	UNUSED(unused);

	fc_init();
	
	fc_ted[2].te_ptext = fname;
	fc_ted[3].te_ptext = fname + 3;
	devnos = fname[0] - 'A';
	devnod = fname[3] - 'A';
	if (fc_alloc(&buf, &bufsize))
	{
		fc_tree[FCBOXS].ob_next = FCSIDEBOX;
		fc_tree[FCPROGRESS].ob_tail = FCSINGLE;
		fc_cmd = cmd;
		while (TRUE)
		{
			fc_do(&fc_tree[FCCOPYBOX], 1, TRUE, ROOT);
			if (fc_tree[FCEXIT].ob_state != NORMAL)
			{
				fc_tree[FCEXIT].ob_state = NORMAL;
				break;
			}
			fc_tree[FCCOPY].ob_state = NORMAL;
			
			dsbs = (DSB *)Getbpb(devnos);
			dsbd = (DSB *)Getbpb(devnod);
			desk_wait(FALSE);
			if (dsbs == NULL)
				break;
			if (dsbd == NULL)
				break;
			if (dsbs->tracks != dsbd->tracks ||
				dsbs->sides != dsbd->sides)
			{
				do1_alert(0, devnos);
				break;
			}
			tracks = dsbs->tracks;
			sides = dsbs->sides;
			fc_tree[FCCMD].ob_spec = (intptr_t)cmd;
			fc_bar(&w_inc, &bar_max, tracks);
			sktables = Dbmsg(devnos); /* WTF */
			sktabled = Dbmsg(devnod);
			ret = 0;
			for (side = 0; side < sides && ret == 0; side++)
			{
				fc_tree[FCBARS].ob_width = 0;
				fc_tree[FCBARD].ob_width = 0;
				trackno = 0;
				trackbufs = bufsize / (MAXSPT * SECSIZE);
				trkops = tracks / trackbufs;
				for (j = 0; j < 2 && ret == 0; j++)
				{
					for (i = 0; i < trkops; i++)
					{
						if (fc_rwtracks(8, (intptr_t)buf, sktables, devnos, side, w_inc, trackno, trackbufs, cmd) != 0)
						{
							ret = 1;
							break;
						}
						if (fc_rwtracks(9, (intptr_t)buf, sktabled, devnod, side, w_inc, trackno, trackbufs, cmd) != 0)
						{
							ret = 1;
							break;
						}
						trackno += trackbufs;
					}
					trackbufs = tracks % trackbufs;
					trkops = 1;
				}
				if (ret == 0)
				{
					for (i = 21; i < 26; i += 4)
					{
						fc_tree[i].ob_spec = 0x11100L;
						fc_do(&fc_tree[i], 0, FALSE, ROOT);
						fc_tree[i].ob_spec = 0x111A1L;
					}
				}
			}
			if (ret == 0)
			{
				Floprd(buf, sktables, devnos, 1, 0, 0, 1);
				/* change the serialno */
				Protobt(buf, 0x01000000L, -1, -1);
				Flopwr(buf, sktabled, devnod, 1, 0, 0, 1);
			}
			desk_wait(FALSE);
		}
		fc_tree[FCBOXS].ob_next = ROOT;
		fc_tree[FCPROGRESS].ob_tail = FCLABEL;
		dos_free((VOIDPTR) buf);
		dos_free(fc_tree); /* WTF */ /* BUG: not allocated */
		rsrc_free();
	}
}


/*
 * Inc and redraw slider bar
 */
/* 306de: 00e2aa84 */
/* 104de: 00fe74ba */
VOID fc_bar(P(int16_t *) w_inc, P(int16_t *) bar_max, P(int16_t) maxvalue)
PP(register int16_t *w_inc;)
PP(register int16_t *bar_max;)
PP(int16_t maxvalue;)
{
	register int16_t x;
	register int16_t y;

	x = fc_tree[FCPROGRESS].ob_x;
	y = fc_tree[FCPROGRESS].ob_y;
	*w_inc = fc_tree[FCBOXS].ob_width / MAXTRACK;
	*bar_max = *w_inc * MAXTRACK;
	fc_tree[FCBOXS].ob_width = *bar_max;
	fc_tree[FCBOXD].ob_width = *bar_max;
#if BINEXACT
	/* BUG: missing parameter */
	fc_do(&fc_tree[FCPROGRESS], 1, FALSE);
#else
	fc_do(&fc_tree[FCPROGRESS], 1, FALSE, 0);
#endif
	fc_tree[FCBARS].ob_x = fc_x + x;
	fc_tree[FCBARS].ob_y = fc_y + y;
	fc_tree[FCBARD].ob_x = fc_tree[FCBOXD].ob_x + x;
	fc_tree[FCBARD].ob_y = fc_tree[FCBOXD].ob_y + y;
	if (maxvalue == MAXTRACK / 2)
		*w_inc += *w_inc;
	desk_wait(TRUE);
}


LINEF_STATIC VOID fc_do(P(OBJECT *) tree, P(int16_t) depth, P(BOOLEAN) fmdo, P(int16_t) startfld)
PP(OBJECT *tree;)
PP(int16_t depth;)
PP(BOOLEAN fmdo;)
PP(int16_t startfld;)
{
	objc_draw(tree, ROOT, depth, fc_tree[ROOT].ob_x - 8, fc_tree[ROOT].ob_y - 8, fc_tree[ROOT].ob_width + 16, fc_tree[ROOT].ob_height + 16);
	if (fmdo)
		fm_do((LPTREE)tree, startfld);
}


LINEF_STATIC int16_t fc_rwtracks(P(int16_t) op, P(intptr_t) buf, P(intptr_t) sktable, P(int16_t) dev, P(int16_t) side, P(int16_t) w_inc, P(int16_t) track, P(int16_t) numtracks, P(char *) cmd)
PP(int16_t op;)
PP(register intptr_t buf;)
PP(intptr_t sktable;)
PP(int16_t dev;)
PP(int16_t side;)
PP(int16_t w_inc;)
PP(int16_t track;)
PP(int16_t numtracks;)
PP(char *cmd;)
{
	register int16_t i;
	register int16_t obj;
	register int16_t ret;
	register LPTREE pobj;

	UNUSED(cmd);	
#if !BINEXACT
	/* BUG: not initialized */
	ret = 0;
#endif
	for (i = track; i < numtracks + track; i++)
	{
		obj = FCBARD;
		if (op == 9)
			obj = FCBARS;
		fc_tree[obj].ob_width += w_inc;
		pobj = (LPTREE)&fc_tree[obj];
		fc_do((OBJECT *)pobj, 0, FALSE, 0);
		ret = xbios(op, buf, sktable, dev, 1, i, side, MAXSPT);
		if (op == 9 && ret == 0)
			ret = xbios(8, buf, sktable, dev, 1, i, side, MAXSPT);
		if (ret != 0)
		{
			do1_alert(ret, dev);
			break;
		}
		buf += MAXSPT * SECSIZE;
	}
	return ret;
}


LINEF_STATIC BOOLEAN fc_alloc(P(VOIDPTR *) buf, P(long *)size)
PP(VOIDPTR *buf;)
PP(long *size;)
{
	*size = dos_avail();
	if (*size < MAXSPT * SECSIZE)
		return FALSE;
	*buf = dos_alloc(*size);
	return TRUE;
}


LINEF_STATIC VOID do1_alert(P(int16_t) err, P(int16_t) dev)
PP(int16_t err;)
PP(int16_t dev;)
{
	fc_draw();
	desk_wait(FALSE);
	if (err < 0)
		err_trap(err, dev);
	else if (err != 0)
		fm_alert(1, s_fmterr);
	else
		fm_alert(1, s_notsame);
}


/*
 * put in the next cluster number
 */
/* 306de: 00e2a9d0 */
/* 104de: 00fe7408 */
/* 106de: 00e29cd6 */
LINEF_STATIC VOID fc_clfix(P(int16_t) cl, P(uint16_t) num, P(BPB *)bpb, P(VOIDPTR) fat)
PP(int16_t cl;)
PP(uint16_t num;)
PP(BPB *bpb;)
PP(VOIDPTR fat;)
{
	union {
		uint8_t b[2];
		int16_t s;
		uint16_t u;
	} temp;
	uint8_t *p;
	uint16_t mask;
	intptr_t ncl;

	if (bpb->b_flags & B_16)
	{
		/* 16bit fats on a floppy??? */
		ncl = cl * 2;
		*((uint16_t *)((char *)fat + ncl)) = -1;
	} else
	{
		ncl = cl + (cl >> 1);				/* multiply by 1.5  */
		num = 0xfff;
		/* get the fat value 12 bit */
	
		if (cl & 0x1)						/* is it odd ?      */
		{
			num = 0xfff0;
			mask = 0x000f;
		} else
		{
			mask = 0xf000;
		}
		p = (uint8_t*)((intptr_t)fat + ncl);
		temp.b[0] = p[0];
		temp.b[1] = p[1];
		fc_swp68(&temp.u);
		temp.s = (temp.s & mask) | num;
		fc_swp68(&temp.u);
		p[0] = temp.b[0];
		p[1] = temp.b[1];
	}
}


/* 306de: 00e2ab0c */
/* 104de: 00fe752a */
LINEF_STATIC VOID fc_draw(NOTHING)
{
	sh_draw(fc_cmd, ROOT, 1);
}


#if 0 /* provided in assembler */
/* same as swp68() in bdos */
LINEF_STATIC VOID fc_swp68(P(uint16_t *) val)
PP(uint16_t *val;)
{
#ifdef __ALCYON__
	asm("movea.l    8(a6),a0");
	asm("move.w     (a0),d0");
	asm("ror.w      #8,d0");
	asm("move.w     d0,(a0)");
#else
	*val = (*val << 8) | (*val >> 8);
#endif
}
#endif

