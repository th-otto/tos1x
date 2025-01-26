/*
 *************************************************************************
 *			Revision Control System
 * =======================================================================
 *  $Author: mui $	$Date: 89/04/26 18:27:35 $
 * =======================================================================
 *
 * Revision 2.2  89/04/26  18:27:35  mui
 * TT
 * 
 * Revision 2.1  89/02/22  05:30:05  kbad
 * *** TOS 1.4  FINAL RELEASE VERSION ***
 * 
 * Revision 1.1  88/06/02  12:35:21  lozben
 * Initial revision
 * 
 *************************************************************************
 */
/*	GEMWRECT.C	01/25/84 - 02/05/85	Lee Jay Lorenzen	*/
/*	Reg Opt		03/09/85		Derek Mui		*/

/*
 *	-------------------------------------------------------------
 *	GEM Application Environment Services		  Version 1.0
 *	Serial No.  XXXX-0000-654321		  All Rights Reserved
 *	Copyright (C) 1985			Digital Research Inc.
 *	-------------------------------------------------------------
 */

#include "aes.h"
#include "gemlib.h"

#undef TOP
#undef LEFT
#undef RIGHT
#undef BOTTOM

#define TOP 0
#define LEFT 1
#define RIGHT 2
#define BOTTOM 3

ORECT *rul;
STATIC ORECT gl_mkrect;


ORECT *mkpiece PROTO((int16_t tlrb, ORECT *new, ORECT *old));
ORECT *brkrct PROTO((ORECT *new, ORECT *r, ORECT *p));
static VOID mkrect PROTO((LPTREE tree, int16_t wh, int16_t junkx, int16_t junky));



/* init owner rectangles */
VOID or_start(NOTHING)
{
	register int16_t i;

	rul = NULL;
	for (i = 0; i < NUM_ORECT; i++)
	{
		D.g_olist[i].o_link = rul;
		rul = &D.g_olist[i];
	}
}


/* 306de: 00e22d7a */
/* 104de: 00fdee1e */
/* 106de: 00e2074e */
ORECT *get_orect(NOTHING)
{
	ORECT *po;

	if ((po = rul))
		rul = rul->o_link;
	return po;
}


/* 306de: 00e22d9c */
/* 104de: 00fdee3e */
/* 106de: 00e20770 */
ORECT *mkpiece(P(int16_t) tlrb, P(ORECT *) new, P(ORECT *) old)
PP(int16_t tlrb;)
PP(register ORECT *new;)
PP(register ORECT *old;)
{
	register ORECT *rl;

	rl = get_orect();
	rl->o_link = old;
	/* do common calcs  */
	rl->o_gr.g_x = old->o_gr.g_x;
	rl->o_gr.g_w = old->o_gr.g_w;
	rl->o_gr.g_y = max(old->o_gr.g_y, new->o_gr.g_y);
	rl->o_gr.g_h = min(old->o_gr.g_y + old->o_gr.g_h, new->o_gr.g_y + new->o_gr.g_h) - rl->o_gr.g_y;
	/* use/override calcs */
	switch (tlrb)
	{
	case TOP:
		rl->o_gr.g_y = old->o_gr.g_y;
		rl->o_gr.g_h = new->o_gr.g_y - old->o_gr.g_y;
		break;
	case LEFT:
		rl->o_gr.g_w = new->o_gr.g_x - old->o_gr.g_x;
		break;
	case RIGHT:
		rl->o_gr.g_x = new->o_gr.g_x + new->o_gr.g_w;
		rl->o_gr.g_w = (old->o_gr.g_x + old->o_gr.g_w) - (new->o_gr.g_x + new->o_gr.g_w);
		break;
	case BOTTOM:
		rl->o_gr.g_y = new->o_gr.g_y + new->o_gr.g_h;
		rl->o_gr.g_h = (old->o_gr.g_y + old->o_gr.g_h) - (new->o_gr.g_y + new->o_gr.g_h);
		/* break; */
	}
	return rl;
}


/* 306de: 00e22e88 */
/* 104de: 00fdef1a */
/* 106de: 00e2085c */
ORECT *brkrct(P(ORECT *) new, P(ORECT *) r, P(ORECT *) p)
PP(register ORECT *new;)
PP(register ORECT *r;)
PP(register ORECT *p;)
{
	register int16_t i;
	int16_t have_piece[4];

	/* break up rectangle r based on new, adding new orects to list p */
	if ((new->o_gr.g_x < r->o_gr.g_x + r->o_gr.g_w) &&
		(new->o_gr.g_x + new->o_gr.g_w > r->o_gr.g_x) &&
		(new->o_gr.g_y < r->o_gr.g_y + r->o_gr.g_h) &&
		(new->o_gr.g_y + new->o_gr.g_h > r->o_gr.g_y))
	{
		/* there was overlap so we need new rectangles */
		have_piece[TOP] = new->o_gr.g_y > r->o_gr.g_y;
		have_piece[LEFT] = new->o_gr.g_x > r->o_gr.g_x;
		have_piece[RIGHT] = new->o_gr.g_x + new->o_gr.g_w < r->o_gr.g_x + r->o_gr.g_w;
		have_piece[BOTTOM] = new->o_gr.g_y + new->o_gr.g_h < r->o_gr.g_y + r->o_gr.g_h;

		for (i = 0; i < 4; i++)
		{
			if (have_piece[i])
				p = (p->o_link = mkpiece(i, new, r));
		}
		/* take out the old guy */
		p->o_link = r->o_link;
		r->o_link = rul;
		rul = r;
		return p;
	}
	return NULL;
}


/* 306de: 00e22f84 */
/* 104de: 00fdf00c */
/* 106de: 00e20958 */
static VOID mkrect(P(LPTREE) tree, P(int16_t) wh, P(int16_t) junkx, P(int16_t) junky)
PP(LPTREE tree;)
PP(int16_t wh;)
PP(int16_t junkx;)
PP(int16_t junky;)
{
	register WINDOW *pwin;
	ORECT *new;
	register ORECT *r, *p;

	pwin = &D.w_win[wh];
	/* get the new rect that is used for breaking other this windows rects */
	new = &gl_mkrect;
	
	r = (p = (ORECT *)&pwin->w_rlist)->o_link; /* AAAARG */
	/* redo rectangle list  */
	while (r)
	{
		if ((p = brkrct(new, r, p)))
		{
			/* we broke a rectangle which means this can't be blt */
			pwin->w_flags |= VF_BROKEN;
			r = p->o_link;
		} else
		{
			r = (p = r)->o_link;
		}
	}
}


/* 306de: 00e22fe2 */
/* 104de: 00fdf060 */
/* 106de: 00e209b6 */
VOID newrect(P(LPTREE) tree, P(int16_t) wh, P(int16_t) junkx, P(int16_t) junky)
PP(LPTREE tree;)
PP(int16_t wh;)
PP(int16_t junkx;)
PP(int16_t junky;)
{
	register WINDOW *pwin;
	ORECT *r0;
	register ORECT *new, *r;

	pwin = &D.w_win[wh];
	r0 = pwin->w_rlist;
	/* dump rectangle list */
	if (r0)
	{
		for (r = r0; r->o_link; r = r->o_link)
			;
		r->o_link = rul;
		rul = r0;
	}
	/* zero the rectangle list */
	pwin->w_rlist = 0x0;
	/* start out with no broken rectangles */
	pwin->w_flags &= ~VF_BROKEN;
	/* if no size then return */
	w_getsize(WS_TRUE, wh, &gl_mkrect.o_gr);
	if (!(gl_mkrect.o_gr.g_w && gl_mkrect.o_gr.g_h))
		return;
	/* init. a global orect for use during mkrect calls */
	gl_mkrect.o_link = NULL;
	/* break other window's rects with our current rect */
	everyobj(tree, ROOT, wh, mkrect, 0, 0, MAX_DEPTH);
	/* get an orect in this windows list */
	new = get_orect();
	new->o_link = NULL;
	w_getsize(WS_TRUE, wh, &new->o_gr);
	pwin->w_rlist = new;
}
