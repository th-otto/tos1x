/*
 ********************************  seedfill.c  *********************************
 *
 * =============================================================================
 * $Author: lozben $	$Date: 91/08/06 20:38:12 $
 * =============================================================================
 *
 * Revision 3.4  91/08/06  20:38:12  lozben
 * We now look at entry 255 of REV_MAP_COL to get a pen value of one.
 * 
 * Revision 3.3  91/01/22  13:34:15  lozben
 * Changed label start to START because there was a name conflict.
 * 
 * Revision 3.2  91/01/14  15:46:01  lozben
 * Made changes so the file can work with the latest gsxextrn.h and
 * the new lineavar.h files.
 * 
 * Revision 3.1  91/01/08  17:06:05  lozben
 * Change declaration int16_t *Qptr to extern int16_t *Qptr.
 * 
 * Revision 3.0  91/01/03  15:19:00  lozben
 * New generation VDI
 * 
 * Revision 2.4  90/02/14  16:15:30  lozben
 * Optimized the code.
 * 
 * Revision 2.3  89/07/13  17:51:29  lozben
 * Enlarged the buffer size to accomodate new rez (1280x960).
 * 
 * Revision 2.2  89/05/16  12:59:45  lozben
 * Seedfill used to initialize FG_BP_[1,2,3,4], now initializes
 * FG_B_PLANES instead. FG_B_PLANES is set to the current color
 * index.
 * 
 * Revision 2.1  89/02/21  17:28:09  kbad
 * *** TOS 1.4  FINAL RELEASE VERSION ***
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

#define EMPTY   	0xffff
#define DOWN_FLAG 	0x8000
#define NOFLAG(v) 	(v & 0x7FFF)
#if TOSVERSION >= 0x300
#define QSIZE 		(3 * (1280 + 1)) /* depends on largest possible screen resolution */
#else
#define QSIZE 		(3 * (640 + 1))
#endif
#define QMAX		(QSIZE - 3)


BOOLEAN get_seed PROTO((int16_t xin, int16_t yin, int16_t *xleftout, int16_t *xrightout, BOOLEAN *collide));
VOID seedfill PROTO((NOTHING));
VOID crunch_Q PROTO((NOTHING));


/*
 * VDI #103 - v_contourfill - Countour fill
 */
/* 306de: 00e0cc8a */
/* 206de: 00e0d2de */
/* 104de: 00fd153e */
VOID d_contourfill(NOTHING)
{
	LV(quitfill) = retfalse;
	seedfill();
}


VOID seedfill(NOTHING)
{
#if TOSVERSION >= 0x300
	register int16_t *q;
	register BOOLEAN gotseed, leftseed;
	register int16_t leftoldy;			/* the previous scan line tmp   */
	register int16_t leftdirection;		/* is next scan line up or down */
	register int16_t oldy;				/* the previous scan line       */
	int16_t direction;					/* is next scan line up or down */
	int16_t qPtr;
	int16_t oldxleft;					/* left end of line at oldy     */
	int16_t oldxright;					/* right end                    */
	int16_t newxleft;					/* ends of line at oldy +       */
	int16_t newxright;					/*     the current direction    */
	int16_t xleft;						/* temporary endpoints          */
	int16_t xright;

	BOOLEAN collision, leftcollision;
#if !PLANES8
	register int16_t color;
#endif

	q = Q;

	Qptr = &qPtr;
#define Qptr0 *Qptr
#else
	/* in TOS prior to 3.x, all those variables are in the "overlay" area */
#define q Q
#define Qptr0 qPtr
#define Qtop qTop
	register int16_t color;
#endif

	xleft = LV(PTSIN)[0];
	oldy = LV(PTSIN)[1];

	if (xleft < LV(XMN_CLIP) || xleft > LV(XMX_CLIP) || oldy < LV(YMN_CLIP) || oldy > LV(YMX_CLIP))
		return;

	search_color = LV(INTIN)[0];

	/* Range check the color and convert the index to a pixel value */

	if (search_color >= LV(DEV_TAB)[13])
		return;

	else if (search_color < 0)
	{
		search_color = get_pix();
		seed_type = 1;
	} else
	{
		/* We mandate that white is all bits on.  Since this yields 15     */
		/* in rom, we must limit it to how many planes there really are.   */
		/* Anding with the mask is only necessary when the driver supports */
		/* move than one resolution.                       */

#if VIDEL_SUPPORT
		search_color = MAP_COL[search_color] & tplane_mask[LV(v_planes)];
		search_color = LV(pal_map)[search_color];
#else
		search_color = MAP_COL[search_color] & tplane_mask[LV(INQ_TAB)[4]
#if TOSVERSION < 0x400
		- 1
#endif
		];
#endif
		seed_type = 0;
	}

	/* Initialize the line drawing parameters */
#if PLANES8
	LV(FG_B_PLANES) = LV(cur_work)->fill_color;
#else
	color = LV(cur_work)->fill_color;
	LV(FG_BP_1) = color & 0x01;
	LV(FG_BP_2) = color & 0x02;
	LV(FG_BP_3) = color & 0x04;
	LV(FG_BP_4) = color & 0x08;
#endif

	LV(LSTLIN) = FALSE;

	gotseed = end_pts(xleft, oldy, &oldxleft, &oldxright);

	qPtr = Qbottom = 0;
	Qtop = 3;							/* one above highest seed point */
	q[0] = (oldy | DOWN_FLAG);
	q[1] = oldxleft;
	q[2] = oldxright;					/* stuff a point going down into the Q */

	done = FALSE;
	if (gotseed)
		goto START;						/* can't get point out of Q or draw it */
	else
		return;

	do
	{
		while (q[qPtr] == EMPTY)
		{
			qPtr += 3;
			if (qPtr == Qtop)
				qPtr = Qbottom;
		}

		oldy = q[qPtr];
		q[qPtr++] = EMPTY;
		oldxleft = q[qPtr++];
		oldxright = q[qPtr++];
		if (qPtr == Qtop)
			crunch_Q();
		if (done)						/* if queue is full, just quit. */
			return;

		fill_line(oldxleft, oldxright, NOFLAG(oldy));

	  START:
		direction = (oldy & DOWN_FLAG) ? 1 : -1;
		gotseed = get_seed(oldxleft, (oldy + direction), &newxleft, &newxright, &collision);

		leftdirection = direction;
		leftseed = gotseed;
		leftcollision = collision;
		leftoldy = oldy;
		while ((newxleft < (oldxleft - 1)) && (leftseed || leftcollision))
		{
			xleft = oldxleft;
			while (xleft > newxleft)
				leftseed = get_seed(--xleft, leftoldy ^ DOWN_FLAG, &xleft, &xright, &leftcollision);
			oldxleft = newxleft;
			if ((xleft < (newxleft - 1)) && (leftseed || leftcollision))
			{
				newxleft = xleft;
				leftoldy += leftdirection;
				leftdirection = -leftdirection;
				leftoldy ^= DOWN_FLAG;
			}
		}
		while (newxright < oldxright)
			gotseed = get_seed(++newxright, oldy + direction, &xleft, &newxright, &collision);
		while ((newxright > (oldxright + 1)) && (gotseed || collision))
		{
			xright = oldxright;
			while (xright < newxright)
				gotseed = get_seed(++xright, oldy ^ DOWN_FLAG, &xleft, &xright, &collision);
			oldxright = newxright;
			if ((xright > (newxright + 1)) && (gotseed || collision))
			{
				newxright = xright;
				oldy += direction;
				direction = -direction;
				oldy ^= DOWN_FLAG;
			}
		}
	} while (Qtop != Qbottom);
}


/*
 * move Qtop down to remove unused seeds
 */
/* 306de: 00e0d042 */
/* 206de: 00e0d7be */
/* 104de: 00fd1a1e */
VOID crunch_Q(NOTHING)
{
#if TOSVERSION >= 0x300
	register int16_t *q = Q;
	register int16_t qTop = Qtop;
#endif

	while (q[qTop - 3] == EMPTY && qTop > Qbottom)
		qTop -= 3;

	if (Qptr0 >= qTop)
	{
		Qptr0 = Qbottom;
		done = (*LV(quitfill)) ();			/* quitfill is set via LINE "A"  */
	}

#if TOSVERSION >= 0x300
	Qtop = qTop;
#endif
}


/* 306de: 00e0d0a6 */
/* 206de: 00e0d818 */
/* 104de: 00fd1a78 */
BOOLEAN get_seed(P(int16_t) xin, P(int16_t) yin, P(int16_t *) xleftout, P(int16_t *) xrightout, P(BOOLEAN *) collide)
#if TOSVERSION >= 0x300
PP(register int16_t xin;)
PP(register int16_t yin;)
PP(register int16_t *xleftout;)
PP(register int16_t *xrightout;)
PP(BOOLEAN *collide;)
#else
PP(int16_t xin;)
PP(int16_t yin;)
PP(int16_t *xleftout;)
PP(int16_t *xrightout;)
PP(BOOLEAN *collide;)
#endif
{
#if TOSVERSION >= 0x300
	register int16_t qTmp;
	register int16_t qHole;				/* an empty space in the Q      */
	register int16_t *q = Q;
#endif

	*collide = FALSE;
	if (done)
		return FALSE;

	/*
	 * false if of search_color
	 */
	if (end_pts(xin, NOFLAG(yin), xleftout, xrightout))
	{
		for (qTmp = Qbottom, qHole = EMPTY; qTmp < Qtop; qTmp += 3)
		{
			/* we ran into another seed so remove it and fill the line */
			if ((q[qTmp + 1] == *xleftout) && (q[qTmp] != EMPTY) && ((q[qTmp] ^ DOWN_FLAG) == yin))
			{

				fill_line(*xleftout, *xrightout, NOFLAG(yin));
				q[qTmp] = EMPTY;
				if ((qTmp + 3) == Qtop)
					crunch_Q();

				*collide = TRUE;
				return FALSE;
			}

			if ((q[qTmp] == EMPTY) && (qHole == EMPTY))
				qHole = qTmp;
		}

		if (qHole == EMPTY)
		{
			if ((Qtop += 3) > QMAX)
			{
				done = TRUE;
				*collide = FALSE;
				return FALSE;
			}

		} else
			qTmp = qHole;

		q[qTmp++] = yin;				/* put the y and endpoints in the Q */
		q[qTmp++] = *xleftout;
		q[qTmp] = *xrightout;
		return TRUE;					/* we put a seed in the Q */
	} else
		return FALSE;					/* we didnt put a seed in the Q */
}


/*
 * VDI #105 - v_get_pixel - Get pixel
 */
/* 306de: 00e0d1ec */
/* 206de: 00e0d9d4 */
/* 104de: 00fd1c34 */
VOID v_get_pixel(NOTHING)
{
#if VIDEL_SUPPORT
	register int32_t pel;
	register int32_t *tmpPtr;
#else
	register int16_t pel;
#endif
	register int16_t *int_out;

	/* Get the requested pixel */

	pel = get_pix();

#if VIDEL_SUPPORT
	tmpPtr = (int32_t *)(int_out = LV(INTOUT));

	if (LV(form_id) == PIXPACKED && LV(v_planes) > 8)
	{
		*tmpPtr = pel;
	} else
#else
	int_out = LV(INTOUT);
#endif
	{
		*int_out++ = pel;

		/*
		 * Correct the pel value for the # of planes so it is a standard value
		 */
#if PLANES8
		if ((LV(INQ_TAB)[4] == 1 && pel == 1) || (LV(INQ_TAB)[4] == 2 && pel == 3) || (LV(INQ_TAB)[4] == 4 && pel == 15))
			pel = 255;
#else
		if ((LV(INQ_TAB)[4] == 1 && pel != 0) || (LV(INQ_TAB)[4] == 2 && pel == 3))
			pel = 15;
#endif

		*int_out = REV_MAP_COL[pel];
		NINTOUT = 2;
	}
}
