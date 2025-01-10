/*************************************************************************
 *			Revision Control System
 * =======================================================================
 *  $Author: mui $	$Date: 89/04/26 18:23:29 $
 * =======================================================================
 *
 * Revision 2.2  89/04/26  18:23:29  mui
 * TT
 * 
 * Revision 2.1  89/02/22  05:26:52  kbad
 * *** TOS 1.4  FINAL RELEASE VERSION ***
 * 
 * Revision 1.1  88/06/02  12:34:03  lozben
 * Initial revision
 * 
 *************************************************************************/

#include "aes.h"
#include "gemlib.h"
#include "gsxdefs.h"

/*	GEMGRLIB.C	4/11/84 - 01/07/85	Gregg Morris		*/
/*	Reg Opt		03/08/85 - 04/26/85	Derek Mui		*/

/*
 *	-------------------------------------------------------------
 *	GEM Application Environment Services		  Version 1.1
 *	Serial No.  XXXX-0000-654321		  All Rights Reserved
 *	Copyright (C) 1985			Digital Research Inc.
 *	-------------------------------------------------------------
 */





/*
 *  gr_stilldn
 *
 *  Routine to watch the mouse while the button is down
 *  and it stays inside/outside of the specified rectangle.
 *  Return TRUE as long as the mouse is down.  Block until the
 *  mouse moves into or out of the specified rectangle.
 */
BOOLEAN gr_stilldn(P(int16_t) out, P(int16_t) x, P(int16_t) y, P(int16_t) w, P(int16_t) h)
PP(int16_t out;)
PP(int16_t x;)
PP(int16_t y;)
PP(int16_t w;)
PP(int16_t h;)
{
	int16_t rets[6];
	int16_t event;

	/*
	 * compiler had better put the values out, x, y, w, h in the 
	 * right order on the stack to form a MOBLK WTF
	 */
	event = ev_multi(MU_BUTTON | MU_M1, (MOBLK *)&out, NULL, 0x0L, 0x00010100L, 0x0L, &rets[0]); /* 01ff00L */

	if (event & MU_BUTTON)			/* button up */
		return FALSE;
	return TRUE;
}


LINEF_STATIC VOID gr_setup(P(int16_t) color)
PP(int16_t color;)
{
	gsx_sclip(&gl_rscreen);
	gsx_attr(FALSE, MD_XOR, color);
}


VOID gr_clamp(P(int16_t) xorigin, P(int16_t) yorigin, P(int16_t) wmin, P(int16_t) hmin, P(int16_t *) pneww, P(int16_t *) pnewh)
PP(int16_t xorigin;)
PP(int16_t yorigin;)
PP(int16_t wmin;)
PP(int16_t hmin;)
PP(int16_t *pneww;)
PP(int16_t *pnewh;)
{
	int16_t mx, my;

	gsx_mxmy(&mx, &my);
	*pneww = max(mx - xorigin + 1, wmin);
	*pnewh = max(my - yorigin + 1, hmin);
}


#if !TP_30 /* DRAW_BOXES */
/*
 *   gr_scale
 */
LINEF_STATIC VOID gr_scale(P(int16_t) xdist, P(int16_t) ydist, P(int16_t *) pcnt, P(int16_t *) pxstep, P(int16_t *) pystep)
PP(register int16_t xdist;)
PP(register int16_t ydist;)
PP(int16_t *pcnt;)
PP(register int16_t *pxstep;)
PP(register int16_t *pystep;)
{
	register int16_t i;
	register int16_t dist;

	gr_setup(BLACK);

	dist = (xdist + ydist) / 2;

	for (i = 0; dist; i++)
		dist /= 2;

	if ((*pcnt = i))
	{
		*pxstep = max(1, xdist / i);
		*pystep = max(1, ydist / i);
	} else
		*pxstep = *pystep = 1;
}


/*
 * AES #130 - xgrf_stepcalc - Stepcalc for XGraf
 *
 *  routine common to growbox & shrinkbox
 *
 *  gr_stepcalc(po->g_w, po->g_h, pt, &cx, &cy, &cnt, &xstep, &ystep);
 */
LINEF_STATIC VOID gr_stepcalc(P(int16_t) orgw, P(int16_t) orgh, P(GRECT *)pt, P(int16_t *) pcx, P(int16_t *) pcy, P(int16_t *) pcnt, P(int16_t *) pxstep, P(int16_t *) pystep)
PP(int16_t orgw;)
PP(int16_t orgh;)
PP(register GRECT *pt;)
PP(register int16_t *pcx;)
PP(register int16_t *pcy;)
PP(int16_t *pcnt;)
PP(int16_t *pxstep;)
PP(int16_t *pystep;)
{
	*pcx = (pt->g_w / 2) - (orgw / 2);
	*pcy = (pt->g_h / 2) - (orgh / 2);

	gr_scale(*pcx, *pcy, pcnt, pxstep, pystep);

	*pcx += pt->g_x;
	*pcy += pt->g_y;
}
#endif /* TP_30 */


/*
 *				offset from sp at entry
 *	entry:	.w	clipped	+4
 *		.w	cnt	+6
 *		.w	cx	+8
 *		.w	cy	+10
 *		.w	cw	+12
 *		.w	ch	+14
 *		.w	xstep	+16
 *		.w	ystep	+18
 *		.w	dowdht	+20
 *	exit:	none
 */
LINEF_STATIC VOID gr_xor(P(int16_t) clipped, P(int16_t) cnt, P(int16_t) cx, P(int16_t) cy, P(int16_t) cw, P(int16_t) ch, P(int16_t) xstep, P(int16_t) ystep, P(int16_t) dowdht)
PP(int16_t clipped;)
PP(int16_t cnt;)
PP(int16_t cx;)
PP(int16_t cy;)
PP(int16_t cw;)
PP(int16_t ch;)
PP(register int16_t xstep;)
PP(register int16_t ystep;)
PP(int16_t dowdht;)
{
	do
	{
		if (clipped)
			gsx_xcbox((GRECT *)&cx);
		else
			gsx_xbox((GRECT *)&cx);
		cx -= xstep;
		cy -= ystep;
		if (dowdht)
		{
			cw += (2 * xstep);
			ch += (2 * ystep);
		}
	} while (cnt--);
}



/*
 * gr_draw
 */
LINEF_STATIC VOID gr_draw(P(int16_t) have2box, P(GRECT *) po, P(GRECT *) poff)
PP(int16_t have2box;)
PP(register GRECT *po;)
PP(register GRECT *poff;)
{
	GRECT t;

	gsx_xbox(po);
	if (have2box)
	{
		r_set(&t, po->g_x + poff->g_x, po->g_y + poff->g_y, po->g_w + poff->g_w, po->g_h + poff->g_h);
		gsx_xbox(&t);
	}
}



/*
 *	gr_wait
 *
 *				offset from sp at entry
 *
 *	entry:	.l	po		+4
 *		.l	poff		+8
 *		.w	mx		+12
 *		.w	my		+14
 *
 *	exit:	d0 = down
 *
 */
LINEF_STATIC int16_t gr_wait(P(GRECT *) po, P(GRECT *) poff, P(int16_t) mx, P(int16_t) my)
PP(register GRECT *po;)
PP(register GRECT *poff;)
PP(int16_t mx;)
PP(int16_t my;)
{
	register int16_t have2box;
	register int16_t down;

	have2box = !rc_equal(&gl_rzero, poff);
	/* draw old     */
	gsx_moff();
	gr_draw(have2box, po, poff);
	gsx_mon();
	/* wait for change  */
	down = gr_stilldn(TRUE, mx, my, 1, 1);
	/* erase old        */
	gsx_moff();
	gr_draw(have2box, po, poff);
	gsx_mon();
	/* return exit event    */
	return down;
}



/*
 *   gr_rubwind
 *
 *
 *   Stretch the free corner of an XOR box(w,h) that is pinned at
 *   another corner based on mouse movement until the button comes
 *   up.  Also draw a second box offset from the stretching box.
 */
VOID gr_rubwind(P(int16_t) xorigin, P(int16_t) yorigin, P(int16_t) wmin, P(int16_t) hmin, P(GRECT *) poff, P(int16_t *) pwend, P(int16_t *) phend)
PP(int16_t xorigin;)
PP(int16_t yorigin;)
PP(int16_t wmin;)
PP(int16_t hmin;)
PP(GRECT *poff;)
PP(int16_t *pwend;)
PP(int16_t *phend;)
{
	int16_t down;
	GRECT o;

	wm_update(BEG_UPDATE);
	gr_setup(BLACK);

	r_set(&o, xorigin, yorigin, 0, 0);
	/* clamp size of rubber box to no smaller than wmin, hmin    */
	do
	{
		gr_clamp(o.g_x, o.g_y, wmin, hmin, &o.g_w, &o.g_h);
		down = gr_wait(&o, poff, o.g_x + o.g_w - 1, o.g_y + o.g_h - 1);
	} while (down);
	*pwend = o.g_w;
	*phend = o.g_h;
	wm_update(END_UPDATE);
}


/*
 * AES #70 - graf_rubberbox - Graphics rubberbox
 *
 *	gr_rubbox
 *
 *   Stretch the free corner of a XOR box(w,h) that is pinned at
 *   another corner based on mouse movement until the button comes
 *   up.  This is also called a rubber-band box.
 */
VOID gr_rubbox(P(int16_t) xorigin, P(int16_t) yorigin, P(int16_t) wmin, P(int16_t) hmin, P(int16_t *) pwend, P(int16_t *) phend)
PP(int16_t xorigin;)
PP(int16_t yorigin;)
PP(int16_t wmin;)
PP(int16_t hmin;)
PP(int16_t *pwend;)
PP(int16_t *phend;)
{
	gr_rubwind(xorigin, yorigin, wmin, hmin, &gl_rzero, pwend, phend);
}


/*
 * AES #71 - graf_dragbox - Graphics drag box
 *
 *	gr_dragbox
 *
 *	Drag a moving XOR box(w,h) that tracks relative to the mouse
 *	until the button comes up.  The starting x and y represent
 *	the location of the upper left hand corner of the rectangle
 *	relative to the mouse position.  This relative distance should
 *	be maintained.  A constraining rectangle is also given.  The
 *	box should not be able to be dragged out of the contraining
 *	rectangle.
 *
 */
VOID gr_dragbox(P(int16_t) w, P(int16_t) h, P(int16_t) sx, P(int16_t) sy, P(GRECT *) pc, P(int16_t *) pdx, P(int16_t *) pdy)
PP(int16_t w;)
PP(int16_t h;)
PP(register int16_t sx;)
PP(register int16_t sy;)
PP(GRECT *pc;)
PP(int16_t *pdx;)
PP(int16_t *pdy;)
{
	int16_t offx, offy, down;
	GRECT o;
	int16_t mx, my;

	wm_update(BEG_UPDATE);
	gr_setup(BLACK);

	gr_clamp(sx + 1, sy + 1, 0, 0, &offx, &offy);
	r_set(&o, sx, sy, w, h);

	/* get box's x,y from mouse's x,y then constrain result   */
	do
	{
		gsx_mxmy(&mx, &my);
		o.g_x = mx - offx;
		o.g_y = my - offy;
		rc_constrain(pc, &o);
		down = gr_wait(&o, &gl_rzero, mx, my);
	} while (down);
	*pdx = o.g_x;
	*pdy = o.g_y;
	wm_update(END_UPDATE);
}



/*
 * AES #72 - graf_movebox - Graphics move box
 *
 *	gr_movebox
 *
 *	Draw a moving XOR box(w,h) that moves from a point whose upper
 *	left corner is at src_x, src_y to a point at dst_x, dst_y
 */
VOID gr_movebox(P(int16_t) w, P(int16_t) h, P(int16_t) srcx, P(int16_t) srcy, P(int16_t) dstx, P(int16_t) dsty)
PP(int16_t w;)
PP(int16_t h;)
PP(register int16_t srcx;)
PP(register int16_t srcy;)
PP(int16_t dstx;)
PP(int16_t dsty;)
{
	register int16_t i;
	register int16_t signx, signy;
	int16_t cnt, xstep, ystep;

	signx = (srcx < dstx) ? -1 : 1;
	signy = (srcy < dsty) ? -1 : 1;

	gr_scale(signx * (srcx - dstx), signy * (srcy - dsty), &cnt, &xstep, &ystep);

	gsx_moff();
	for (i = 0; i < 2; i++)
		gr_xor(FALSE, cnt, srcx, srcy, w, h, signx * xstep, signy * ystep, FALSE);
	gsx_mon();
}



/*
 * AES #73 - graf_growbox - Graphics grow box
 *
 *	gr_growbox
 *
 *	Draw an small box that moves from the origin x,y to a spot
 *	centered within the rectangle and then expands to match the
 *	size of the rectangle.
 */
#if !TP_30 /* DRAW_BOXES */
VOID gr_growbox(P(GRECT *) po, P(GRECT *) pt)
PP(register GRECT *po;)
PP(GRECT *pt;)
{
	register int16_t i;
	int16_t cx, cy;
	int16_t cnt, xstep, ystep;

	gr_stepcalc(po->g_w, po->g_h, pt, &cx, &cy, &cnt, &xstep, &ystep);
	gr_movebox(po->g_w, po->g_h, po->g_x, po->g_y, cx, cy);
	gsx_moff();
	for (i = 0; i < 2; i++)
		gr_xor(TRUE, cnt, cx, cy, po->g_w, po->g_h, xstep, ystep, TRUE);
	gsx_mon();
}
#endif /* TP_30 */


/*
 * AES #74 - graf_shrinkbox - Graphics shrink box
 *
 *	gr_shrinkbox
 *
 *	Draw a box that shrinks from the rectangle given down around
 *	a small box centered within the rectangle and then moves to the
 *	origin point.
 */
#if !TP_30 /* DRAW_BOXES */
VOID gr_shrinkbox(P(GRECT *) po, P(GRECT *) pt)
PP(register GRECT *po;)
PP(register GRECT *pt;)
{
	register int16_t i;
	int16_t cx, cy;
	int16_t cnt, xstep, ystep;

	gr_stepcalc(po->g_w, po->g_h, pt, &cx, &cy, &cnt, &xstep, &ystep);
	gsx_moff();
	for (i = 0; i < 2; i++)
		gr_xor(TRUE, cnt, pt->g_x, pt->g_y, pt->g_w, pt->g_h, -xstep, -ystep, TRUE);
	gsx_mon();
	gr_movebox(po->g_w, po->g_h, cx, cy, po->g_x, po->g_y);
}
#endif /* TP_30 */



/*
 * AES #75 - graf_watchbox - Graphics watch box
 *
 *	gr_watchbox
 *
 */
int16_t gr_watchbox(P(OBJECT *) tree, P(int16_t) obj, P(int16_t) instate, P(int16_t) outstate)
PP(register LPTREE tree;)
PP(register int16_t obj;)
PP(int16_t instate;)
PP(int16_t outstate;)
{
	register int16_t out;
	register int16_t state;
	GRECT t;

	gsx_sclip(&gl_rscreen);
	ob_actxywh((LPTREE)tree, obj, &t);

	out = FALSE;
	do
	{
		state = out ? outstate : instate;
		ob_change((LPTREE)tree, obj, state, TRUE);
		out = !out;
	} while (gr_stilldn(out, t.g_x, t.g_y, t.g_w, t.g_h));

	return out;
}


/*
 * AES #76 - graf_slidebox - Graphics slide box
 */
int16_t gr_slidebox(P(LPTREE) tree, P(int16_t) parent, P(int16_t) obj, P(int16_t) isvert)
PP(register LPTREE tree;)
PP(int16_t parent;)
PP(int16_t obj;)
PP(int16_t isvert;)
{
	register GRECT *pt, *pc;						/* new pointer for Reg Opt  */
	GRECT t, c;
	register int16_t divnd, divis;

	pt = &t;
	pc = &c;

	ob_actxywh(tree, parent, pc);
	ob_relxywh(tree, obj, pt);
	gr_dragbox(pt->g_w, pt->g_h, pt->g_x + pc->g_x, pt->g_y + pc->g_y, pc, &pt->g_x, &pt->g_y);

	if (isvert)
	{
		divnd = pt->g_y - pc->g_y;
		divis = pc->g_h - pt->g_h;
	} else
	{
		divnd = pt->g_x - pc->g_x;
		divis = pc->g_w - pt->g_w;
	}
	if (divis)
		return mul_div(divnd, 1000, divis);
	else
		return 0;
}



/*
 * AES #79 - graf_mkstate - Graphics mouse and keyboard status
 */
int16_t gr_mkstate(P(int16_t *) pmx, P(int16_t *) pmy, P(int16_t *) pmstat, P(int16_t *) pkstat)
PP(int16_t *pmx;)
PP(int16_t *pmy;)
PP(int16_t *pmstat;)
PP(int16_t *pkstat;)
{
	*pmx = xrat;
	*pmy = yrat;
	*pmstat = button;
	*pkstat = kstate;
#ifdef __GNUC__
	return TRUE;
#endif
}
