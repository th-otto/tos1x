/*
 ********************************  opnwk.c   ***********************************
 *
 * =============================================================================
 * $Author: lozben $	$Date: 91/07/30 15:52:15 $
 * =============================================================================
 *
 *******************************************************************************
 */

#include "vdi.h"
#include "fontdef.h"
#include "attrdef.h"
#include "scrndev.h"
#include "lineavar.h"
#include "gsxdef.h"
#include "gsxextrn.h"

#define		SETMODEFLAG	    5			/* for sparrow           */
#define		DEFAULTDEV	    0
#define		STAYINDEV	    1
#define		SSHIFT		    * ((char *) 0x44cL)
#define		SETMODE(a)	    vtrap14b(5, 0L, 0L, 3, a)
#define		SETREZ(a)	    vtrap14b(5, -1L, -1L, a)
#define		EsetGray(a)	    vtrap14(86, a)
#define		EsetBank(a)	    vtrap14(82, a)

FONT_HEAD ram8x16;
FONT_HEAD ram8x8;
#if PLANES8
FONT_HEAD ram16x32;
#endif

/* 
 * v_opnwk():	OPEN_WORKSTATION:
 */
/* 404:   00e10c72 */
/* 306de: 00e06a76 */
/* 206de: 00e0807e */
/* 104de: 00fcc2d6 */
VOID v_opnwk(NOTHING)
{
	register int16_t i;
	register const int16_t *sp;
	register int16_t *dp;
#if TOSVERSION >= 0x400
	register int16_t videoMode;

	if (LV(INTIN)[0] == SETMODEFLAG)
	{
		videoMode = SETMODE(-1);		/* get current video mode    */
		if (videoMode != LV(PTSOUT)[0])		/* see if cur mode != dsred  */
			SETMODE(LV(PTSOUT)[0]);			/* set the video to new mode */
	} else
	{
		if (FindDevice(LV(INTIN)[0]) == NULL)
		{
			LV(CONTRL)[6] = 0;				/* unsuccessfull in opening  */
			return;
		}
	}
#endif
#if TOSVERSION < 0x400
#if TOSVERSION >= 0x300
	register int j;
	register int count;
	register int16_t curRez;
	register int unused;
#endif
	int16_t *old_intin, *old_intout, *old_contrl;
	int16_t new_contrl[7], new_intin[2], new_intout[4];
#if TOSVERSION < 0x300
	int16_t curRez;
#endif
#endif

	/* Move ROM copy of DEV_TAB to RAM */
	sp = ROM_DEV_TAB;
	dp = LV(DEV_TAB);
	for (i = 0; i < 45; i++)
		*dp++ = *sp++;


	/* Move ROM copy of INQ_TAB to RAM */
	sp = ROM_INQ_TAB;
	dp = LV(INQ_TAB);
	for (i = 0; i < 45; i++)
		*dp++ = *sp++;
	LV(INQ_TAB)[14] = MAX_VERT;

	/* Move ROM copy of SIZ_TAB to RAM */
	sp = ROM_SIZ_TAB;
	dp = LV(SIZ_TAB);
	for (i = 0; i < 12; i++)
		*dp++ = *sp++;

	/* 
	 * copy the font headers to ram so they can be altered
	 */
	ram8x8 = f8x8;
	ram8x16 = f8x16;
#if PLANES8
	ram16x32 = f16x32;
#endif
	LV(font_ring)[1] = &ram8x8;

	/*
	 * old Version for ST compatible modes only
	 */

	/*
	 * init all the device dependant stuff
	 */
	curRez = FindDevice();
	if (curRez == 2)                    /* did we switch to medium resolution? */
	{
		LV(DEV_TAB)[0] = 640 - 1;		/* X max                      */
		LV(DEV_TAB)[3] = 169;			/* width of pixel in microns  */
		LV(DEV_TAB)[13] = 4;			/* # of pens available        */
		LV(INQ_TAB)[4] = 2;				/* number of planes           */
	} else if (curRez == 3)             /* did we switch to high resolution? */
	{
		LV(DEV_TAB)[0] = 640 - 1;		/* X max                      */
		LV(DEV_TAB)[1] = 400 - 1;		/* Y max                      */
		LV(DEV_TAB)[3] = 372;			/* width of pixel in microns  */
		LV(DEV_TAB)[13] = 2;			/* # of pens available        */
		LV(DEV_TAB)[35] = 0;			/* color capability flag      */
		LV(DEV_TAB)[39] = 2;			/* number of colors available */
		LV(INQ_TAB)[1] = 1;				/* number of color levels     */
		LV(INQ_TAB)[4] = 1;				/* number of planes           */
		LV(INQ_TAB)[5] = 0;				/* no CLUT                    */
		ram8x8.point = 9;
		ram8x16.point = 10;
		ram8x8.flags ^= DEFAULT;
		ram8x16.flags |= DEFAULT;
	}
	
	LV(CONTRL)[6] = virt_work.handle = 1;
	LV(cur_work) = &virt_work;
	virt_work.next_work = NULL;
	
	LV(line_cw) = -1;					/* invalidate curr line width */
	text_init();						/* initialize the SIZ_TAB info */
	init_wk();

	/* Input must be initialized here and not in init_wk */
	LV(loc_mode) = 0;					/* default is request mode    */
	LV(val_mode) = 0;					/* default is request mode    */
	LV(chc_mode) = 0;					/* default is request mode    */
	LV(str_mode) = 0;					/* default is request mode    */

	/*
	 * Install mouse interrupt service routine, vblank draw routine,
	 * and initialize associated variables and structures. Mouse
	 * cursor and alpha cursor are initially hidden. Timing vectors
	 * are also initialized.
	 */
	LV(GCURX) = LV(DEV_TAB)[0] / 2;
	LV(GCURY) = LV(DEV_TAB)[1] / 2;
	INIT_G();

	/*
	 * Initialize the request color array, and the request extended
	 * color array. Do it for all banks if there are banks in the
	 * current video mode.
	 */
	old_intin = LV(INTIN);
	old_intout = LV(INTOUT);
	old_contrl = LV(CONTRL);

	LV(CONTRL) = new_contrl;
	LV(INTIN) = new_intin;
	LV(INTOUT) = new_intout;

	new_intin[1] = 1;
	dp = &LV(REQ_COL)[0][0];
	sp = new_intout + 1;

	for (i = 0; i < LV(DEV_TAB)[13]; i++)
	{
		new_intin[0] = i;
		vq_color();
		*dp++ = *sp;
		*dp++ = *(sp + 1);
		*dp++ = *(sp + 2);
	}

	LV(CONTRL) = old_contrl;
	LV(INTIN) = old_intin;
	LV(INTOUT) = old_intout;
}

/*----------------------------------------------------------------------------*/

#if TOSVERSION >= 0x400
/* 
 * This function is here for soft loaded vdi. We init the workType then find
 * a device out of a set of caned devices. And do a SETREZ (setscreen) call.
 */
/* 404:   00e10e4a */
const SCREENDEF *FindDevice(P(int16_t) devId)
PP(int16_t devId;)
{
	register const SCREENDEF *dev;
	register int16_t i, curRez;

	curRez = devId - 2;

	if (devId == DEFAULTDEV)
	{
		dev = devices[DEFAULTDEV];
		LV(LA_CURDEV) = dev;
		SETREZ(curRez);					/* get into default res      */
	} else if (devId == STAYINDEV)
	{
		dev = LV(LA_CURDEV);
	} else
	{
		for (i = 0, dev = devices[0];; dev = devices[++i])
		{
			if (dev == NULL)
			{
				dev = devices[DEFAULTDEV];
				LV(LA_CURDEV) = dev;
				curRez = dev->devId - 2;	/* set to defaul rez         */
				SETREZ(curRez);			/* get into default res      */
				break;
			} else if (dev->devId == devId)
			{
				LV(LA_CURDEV) = dev;

				if (curRez <= 8)		/* test if rez exists        */
					SETREZ(curRez);		/* get into desired res      */
				else
					esc_init();

				break;					/* found the proper dev      */
			}
		}
	}
	return dev;
}

/*----------------------------------------------------------------------------*/

/*
 * This function is here for soft loaded vdi. We init the LA_CURDEV if we can.
 */
VOID SetCurDevice(P(int16_t) curRez)
PP(int16_t curRez;)
{
	register const SCREENDEF *dev;
	register int16_t i, devId;

	devId = curRez + 2;
	for (i = 0, dev = devices[0];; dev = devices[++i])
	{
		if (dev->devId == devId)
		{
			LV(LA_CURDEV) = dev;
			break;						/* found the proper dev      */
		}
	}
}

/*----------------------------------------------------------------------------*/

VOID InitFonts(NOTHING)
{
	/* 
	 * copy the font headers to ram so they can be altered
	 */
	ram8x8 = f8x8;
	ram8x16 = f8x16;
#if PLANES8
	ram16x32 = f16x32;
#endif
}

/*----------------------------------------------------------------------------*/

VOID InitDevTabInqTab(NOTHING)
{
	register const SCREENDEF *dev;

	dev = LV(LA_CURDEV);						/* init current dev pointer   */

	LV(DEV_TAB)[0] = dev->xRez - 1;			/* X max                      */
	LV(DEV_TAB)[1] = dev->yRez - 1;			/* Y max                      */
	LV(DEV_TAB)[3] = dev->xSize;			/* width of pixel in microns  */
	LV(DEV_TAB)[4] = dev->ySize;			/* height of pixel in microns */
	LV(DEV_TAB)[13] = dev->maxPen;			/* # of pens available        */
	LV(DEV_TAB)[35] = dev->colFlag;			/* color capability flag      */
	LV(DEV_TAB)[39] = dev->palSize;			/* palette size               */
	LV(INQ_TAB)[1] = dev->palSize;			/* number of background clrs  */
	LV(INQ_TAB)[4] = dev->planes;			/* number of planes           */
	LV(INQ_TAB)[5] = dev->lookupTable;		/* video lookup table         */
}

#endif
