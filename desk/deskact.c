/*      DESKACT.C       06/11/84 - 09/05/85             Lee Lorenzen    */
/*      merged source   5/18/87 - 5/28/87               mdf             */

/*
 *       Copyright 1999, Caldera Thin Clients, Inc.                      
 *       This software is licenced under the GNU Public License.         
 *       Please see LICENSE.TXT for further information.                 
 *                                                                       
 *                  Historical Copyright                                 
 *       -------------------------------------------------------------
 *       GEM Desktop                                       Version 2.3
 *       Serial No.  XXXX-0000-654321              All Rights Reserved
 *       Copyright (C) 1985 - 1987               Digital Research Inc.
 *       -------------------------------------------------------------
 */

#include "desktop.h"
#include "taddr.h"


LINEF_STATIC int16_t act_chkobj PROTO((OBJECT *tree, int16_t root, int16_t obj, int16_t mx, int16_t my, int16_t w, int16_t h));
#if LINEF_HACK
LINEF_STATIC VOID gr_accobs PROTO((OBJECT *tree, int16_t root, int16_t *pnum, int16_t *pxypts));
LINEF_STATIC int16_t gr_obfind PROTO((OBJECT *tree, int16_t root, int16_t mx, int16_t my));
LINEF_STATIC VOID move_drvicon PROTO((OBJECT *tree, int16_t root, int16_t x, int16_t y, int16_t *pts));
LINEF_STATIC VOID gr_extent PROTO((int16_t numpts, int16_t *xylnpts, GRECT *pt));
LINEF_STATIC VOID gr_plns PROTO((int16_t x, int16_t y, int16_t numpts, int16_t *xylnpts, int16_t numobs, int16_t *xyobpts));
LINEF_STATIC BOOLEAN gr_bwait PROTO((GRECT *po, int16_t mx, int16_t my, int16_t numpts, int16_t *xylnpts, int16_t numobs, int16_t *xyobpts));
LINEF_STATIC VOID gr_drgplns PROTO((int16_t in_mx, int16_t in_my, GRECT *pc, int16_t numpts, int16_t *xylnpts, int16_t numobs, int16_t *xyobpts, int16_t *pdulx, int16_t *pduly, int16_t *pdwh, int16_t *pdobj));
LINEF_STATIC VOID gr_obalign PROTO((int16_t numobs, nt16_t x, int16_t y, int16_t *xyobpts));
#endif


/* 104de: 00fd5bfe */
/* 106de: 00e161a0 */
/* 100fr: 00fdb918 */
LINEF_STATIC int16_t gr_obfind(P(OBJECT *)tree, P(int16_t) root, P(int16_t) mx, P(int16_t) my)
PP(OBJECT *tree;)
PP(register int16_t root;)
PP(register int16_t mx;)
PP(register int16_t my;)
{
	register int16_t sobj;

	sobj = objc_find(tree, root, 2, mx, my);
	if (sobj != root && sobj != NIL)
		sobj = act_chkobj(tree, root, sobj, mx, my, 1, 1);
	return sobj;
}


/*
 *	Return TRUE as long as the mouse is down.  Block until the
 *	mouse moves into or out of the specified rectangle.
 */
/* 100fr: 00fdb970 */
BOOLEAN gr_isdown(P(int16_t) out, P(int16_t) x, P(int16_t) y, P(int16_t) w, P(int16_t) h, P(int16_t *) pmx, P(int16_t *) pmy, P(uint16_t *) pbutton, P(uint16_t *) pkstate)
PP(int16_t out;)
PP(int16_t x;)
PP(int16_t y;)
PP(int16_t w;)
PP(int16_t h;)
PP(int16_t *pmx;)
PP(int16_t *pmy;)
PP(uint16_t *pbutton;)
PP(uint16_t *pkstate;)
{
	int16_t flags;
	uint16_t ev_which;
	uint16_t kret;
	uint16_t bret;

	flags = MU_BUTTON | MU_M1;
	ev_which = evnt_multi(flags, 0x01, 0xff, 0x00, out, x, y, w, h,
						  0, 0, 0, 0, 0, 0x0L, 0x0, 0x0, pmx, pmy, pbutton, pkstate, &kret, &bret);
	if (ev_which & MU_BUTTON)
		return FALSE;
	return TRUE;
}


LINEF_STATIC VOID gr_accobs(P(OBJECT *) tree, P(int16_t) root, P(int16_t *) pnum, P(int16_t *) pxypts)
PP(OBJECT *tree;)
PP(register int16_t root;)
PP(int16_t *pnum;)
PP(register int16_t *pxypts;)
{
	register int16_t i;
	register int16_t pi;
	register OBJECT *olist;
	register int16_t obj;
	int16_t offx;
	int16_t offy;

	olist = tree;

	offx = olist[root].ob_x;
	offy = olist[root].ob_y;

	i = 0;
	for (obj = olist[root].ob_head; obj > root; obj = olist[obj].ob_next)
	{
		if (olist[obj].ob_state & SELECTED)
		{
			pi = i * 2;
			pxypts[pi] = offx + olist[obj].ob_x;
			pxypts[pi + 1] = offy + olist[obj].ob_y;
			i++;
			if (i >= MAX_OBS)
				break;
		}
	}
	*pnum = i;
}


/* 104de: 00fd5c50 */
/* 106de: 00e16200 */
LINEF_STATIC VOID move_drvicon(P(OBJECT *)tree, P(int16_t) root, P(int16_t) x, P(int16_t) y, P(int16_t *) pts)
PP(register OBJECT *tree;)
PP(int16_t root;)
PP(int16_t x;)
PP(int16_t y;)
PP(int16_t *pts;)
{
	register APP *an_disk;
	register THEDSK *d = thedesk;
	register int16_t objcnt;
	register int16_t obj;
	int16_t oldx;
	int16_t oldy;

	objcnt = 0;
	for (obj = tree[root].ob_head; obj > root; obj = tree[obj].ob_next)
	{
		if (tree[obj].ob_state & SELECTED)
		{
			oldx = tree[obj].ob_x;
			oldy = tree[obj].ob_y;

			app_mtoi(x + pts[2 * objcnt], y + pts[2 * objcnt + 1], &tree[obj].ob_x, &tree[obj].ob_y);

			for (an_disk = d->applist; an_disk; an_disk = an_disk->a_next)
			{
				if (an_disk->a_obid == obj)
				{
					an_disk->a_x = tree[obj].ob_x;
					an_disk->a_y = tree[obj].ob_y;
				}
			}
			do_wredraw(0, oldx, oldy, d->g_wicon, d->g_hicon);
			do_wredraw(0, tree[obj].ob_x, tree[obj].ob_y, d->g_wicon, d->g_hicon);
			++objcnt;
		}
	}
}


/*
 *	Calculate the extent of the list of x,y points given.
 */
/* 104de: 00fd5d7c */
/* 106de: 00e16340 */
LINEF_STATIC VOID gr_extent(P(int16_t) numpts, P(int16_t *)xylnpts, P(GRECT *)pt)
PP(int16_t numpts;)
PP(register int16_t *xylnpts;)
PP(register GRECT *pt;)
{
	register int16_t i;
	int16_t j;
	register int16_t lx, ly, gx, gy;

	lx = ly = 10000;
	gx = 0;
	gy = 0;
	for (i = 0; i < numpts; i++)
	{
		j = i * 2;
		if (xylnpts[j] < lx)
			lx = xylnpts[j];
		if (xylnpts[j + 1] < ly)
			ly = xylnpts[j + 1];
		if (xylnpts[j] > gx)
			gx = xylnpts[j];
		if (xylnpts[j + 1] > gy)
			gy = xylnpts[j + 1];
	}
	r_set(pt, lx, ly, gx - lx + 1, gy - ly + 1);
}


LINEF_STATIC VOID gr_obalign(P(int16_t) numobs, P(int16_t) x, P(int16_t) y, P(int16_t *) xyobpts)
PP(register int16_t numobs;)
PP(register int16_t x;)
PP(register int16_t y;)
PP(register int16_t *xyobpts;)
{
	register int16_t i;
	register int16_t j;

	for (i = 0; i < numobs; i++)
	{
		j = i * 2;
		xyobpts[j] -= x;
		xyobpts[j + 1] -= y;
	}
}


/*
 *	Draw a list of polylines a number of times based on a list of
 *	x,y object locations that are all relative to a certain x,y
 *	offset.
 */
/* 104de: 00fd5e3a */
/* 106de: 00e1640a */
LINEF_STATIC VOID gr_plns(P(int16_t) x, P(int16_t) y, P(int16_t) numpts, P(int16_t *)xylnpts, P(int16_t) numobs, P(int16_t *)xyobpts)
PP(int16_t x;)
PP(int16_t y;)
PP(int16_t numpts;)
PP(register int16_t *xylnpts;)
PP(register int16_t numobs;)
PP(register int16_t *xyobpts;)
{
	register int16_t i, j;

	graf_mouse(M_OFF, NULL);

	for (i = 0; i < numobs; i++)
	{
		j = i * 2;
		gsx_pline(x + xyobpts[j], y + xyobpts[j + 1], numpts, xylnpts);
	}
	graf_mouse(M_ON, NULL);
}


/*
 *  Return TRUE as long as the mouse is down.  Block until the
 *  mouse moves into or out of the specified rectangle.
 */
/* 104de: 00fd5e9a */
/* 106de: 00e1647e */
LINEF_STATIC BOOLEAN gr_bwait(P(GRECT *)po, P(int16_t) mx, P(int16_t) my, P(int16_t) numpts, P(int16_t *)xylnpts, P(int16_t) numobs, P(int16_t *)xyobpts)
PP(register GRECT *po;)
PP(int16_t mx;)
PP(int16_t my;)
PP(int16_t numpts;)
PP(register int16_t *xylnpts;)
PP(int16_t numobs;)
PP(register int16_t *xyobpts;)
{
	int16_t down;
	int16_t ret[4];

	/* draw old */
	gr_plns(po->g_x, po->g_y, numpts, &xylnpts[0], numobs, &xyobpts[0]);
	/* wait for change  */
	down = gr_isdown(TRUE, mx, my, 2, 2, &ret[0], &ret[1], &ret[2], &ret[3]);
	/* erase old */
	gr_plns(po->g_x, po->g_y, numpts, &xylnpts[0], numobs, &xyobpts[0]);
	/* return exit event */
	return down;
}


/*
 *	Drag a list of polylines.
 */
/* 104de: 00fd5f34 */
/* 106de: 00e16528 */
LINEF_STATIC VOID gr_drgplns(P(int16_t) in_mx, P(int16_t) in_my, P(GRECT *)pc, P(int16_t) numpts, P(int16_t *)xylnpts, P(int16_t) numobs, P(int16_t *)xyobpts, P(int16_t *)pdulx, P(int16_t *)pduly, P(int16_t *)pdwh, P(int16_t *)pdobj)
PP(int16_t in_mx;)
PP(int16_t in_my;)
PP(GRECT *pc;)
PP(register int16_t numpts;)
PP(int16_t *xylnpts;)
PP(register int16_t numobs;)
PP(int16_t *xyobpts;)
PP(int16_t *pdulx;)
PP(int16_t *pduly;)
PP(register int16_t *pdwh;)
PP(register int16_t *pdobj;)
{
	OBJECT *tree;
	OBJECT *curr_tree;
	DESKWIN *pw;
	int16_t root;
	int16_t state;
	int i;
	int j;
	int16_t curr_wh;
	int16_t curr_root;
	int16_t curr_sel;
	int16_t dst_wh;
	int16_t offx, offy;
	BOOLEAN down;
	int16_t bstate;
	int16_t keystate;
	BOOLEAN isapp;
	FNODE *pf;
	GRECT o;
	GRECT ln;
	register APP *pa;

	/* figure out extent of single polygon */
	gr_extent(numpts, xylnpts, &ln);
	/* calc overall extent for use as bounds of motion */
	gr_extent(numobs, xyobpts, &o);
	o.g_w += ln.g_w;
	o.g_h += ln.g_h;

	/* inlined gr_obalign */
	gr_obalign(numobs, o.g_x, o.g_y, &xyobpts[0]);

	offx = in_mx - o.g_x;
	offy = in_my - o.g_y;

	curr_wh = 0;
	curr_tree = NULL;
	curr_root = 0;
	curr_sel = 0;
	do
	{
		gsx_sclip(&gl_rscreen);
		gsx_attr(FALSE, MD_XOR, BLACK);
		
		graf_mkstate(&in_mx, &in_my, &bstate, &keystate);
		o.g_x = in_mx - offx;
		o.g_y = in_my - offy;
		rc_constrain(pc, &o);
		down = gr_bwait(&o, in_mx, in_my, numpts, xylnpts, numobs, xyobpts);

		dst_wh = wind_find(in_mx, in_my);
		tree = thedesk->g_pscreen;
		root = DROOT;
		if (dst_wh)
		{
			pw = win_find(dst_wh);
			if (pw)
			{
				tree = thedesk->g_pscreen;
				root = pw->w_root;
			} else
			{
				dst_wh = 0;
			}
		}

		*pdobj = gr_obfind(tree, root, in_mx, in_my);

/* The DESKTOP v1.2 test is rather less efficient here, but it is 
 * the same test. */
		if (*pdobj == root || *pdobj == NIL)
		{
			if (curr_sel)
			{
				act_chg(curr_wh, curr_tree, curr_root, curr_sel, pc, SELECTED, FALSE, TRUE, TRUE);
				curr_wh = 0;
				curr_tree = NULL;
				curr_root = 0;
				curr_sel = 0;
			}
			continue;
		}

		if (*pdobj != curr_sel)
		{
			if (curr_sel)
			{
				act_chg(curr_wh, curr_tree, curr_root, curr_sel, pc, SELECTED, FALSE, TRUE, TRUE);
				curr_wh = 0;
				curr_tree = NULL;
				curr_root = 0;
				curr_sel = 0;
			}
			state = LWGET(OB_STATE(*pdobj));
			if (!(state & SELECTED))
			{
				pa = i_find(dst_wh, *pdobj, &pf, &isapp);
				if (pa->a_type == AT_ISFOLD ||
					pa->a_type == AT_ISDISK ||
					pa->a_type == AT_ISCART ||
					pa->a_type == AT_ISTRSH)
				{
					curr_wh = dst_wh;
					curr_tree = tree;
					curr_root = root;
					curr_sel = *pdobj;
					act_chg(curr_wh, curr_tree, curr_root, curr_sel, pc, SELECTED, TRUE, TRUE, TRUE);
				}
			}
		}
	} while (down);
	if (curr_sel)
		act_chg(curr_wh, curr_tree, curr_root, curr_sel, pc, SELECTED, FALSE, TRUE, TRUE);
	*pdulx = o.g_x;						/* pass back dest. x,y  */
	*pduly = o.g_y;
	*pdwh = dst_wh;
}


#if 0
/*
 *	See if the bit at x,y in a raster form is on or off
 */
static int16_t bit_on(P(int16_t) x, P(int16_t) y, P(int16_t *)praster, P(int16_t) bwidth)
PP(int16_t x;)
PP(int16_t y;)
PP(int16_t *praster;)
PP(int16_t bwidth;)
{
	int16_t windex;
	int16_t tmpw;

	windex = (bwidth * y / 2) + (x / 16);
	tmpw = LWGET((intptr_tr)praster + (windex * 2));
	tmpw = (tmpw >> (15 - (x % 16))) & 0x0001;
	return tmpw;
}
#endif


/*
 *	Check to see which part of the object that the mouse has
 *	been clicked over.  If the type of object is an icon, then use
 *	the icon mask to determine if the icon was actually selected.
 *	If the current view is by text strings then use the name
 *	portion of the text string.
 */
/* 104de: 00fd6228 */
/* 106de: 00e16852 */
LINEF_STATIC int16_t act_chkobj(P(OBJECT *)tree, P(int16_t) root, P(int16_t) obj, P(int16_t) mx, P(int16_t) my, P(int16_t) w, P(int16_t) h)
PP(register OBJECT *tree;)
PP(int16_t root;)
PP(int16_t obj;)
PP(int16_t mx;)
PP(int16_t my;)
PP(int16_t w;)
PP(int16_t h;)
{
	register ICONBLK *ib;
	int16_t view;
	register int16_t ox, oy;
	GRECT t;
	GRECT m;
	register GRECT *pm = &m;

	ox = tree[root].ob_x + tree[obj].ob_x;
	oy = tree[root].ob_y + tree[obj].ob_y;

	view = root == DROOT ? V_ICON : thedesk->g_iview;
	switch (view)
	{
	case V_TEXT:
		r_set(&t, ox, oy, LEN_FNODE * gl_wchar, gl_hchar);
		r_set(pm, mx, my, w, h);
		if (!rc_intersect(&t, pm))
			return root;
		break;
	case V_ICON:
		r_set(&t, mx - ox, my - oy, w, h);
		r_set(pm, mx - ox, my - oy, w, h);
		ib = &thedesk->iconaddr[thedesk->g_index[obj]];
		if (!rc_intersect((GRECT *) &ib->ib_xtext, &t))
		{
			if (!rc_intersect((GRECT *) &ib->ib_xicon, pm))
				return root;
#if 0
			else
			{
				if (!bit_on(pm->g_x - ib->ib_xicon + (w / 2),
							pm->g_y - ib->ib_yicon + (h / 2), ib->ib_pmask, ib->ib_wicon / 8))
					return root;
			}
#endif
		}
		break;
	}

	return obj;
}


/*
 *	Change a single objects state.
 */
/* 104de: 00fd637e */
/* 106de: 00e169cc */
BOOLEAN act_chg(P(int16_t) wh, P(OBJECT *)tree, P(int16_t) root, P(int16_t) obj, P(GRECT *)pc, P(uint16_t) chgvalue, P(int16_t) dochg, P(int16_t) dodraw, P(int16_t) chkdisabled)
PP(int16_t wh;)
PP(OBJECT *tree;)
PP(int16_t root;)
PP(int16_t obj;)
PP(register GRECT *pc;)
PP(register uint16_t chgvalue;)
PP(int16_t dochg;)
PP(int16_t dodraw;)
PP(int16_t chkdisabled;)
{
	register uint16_t curr_state;
	uint16_t old_state;
	GRECT t;
	register OBJECT *olist;
	register GRECT *pt;

	pt = &t;
	olist = tree;
	old_state = curr_state = olist[obj].ob_state;
	if (chkdisabled && (curr_state & DISABLED))
		return FALSE;
	/* get object's extent */
	rc_copy((GRECT *) &olist[obj].ob_x, pt);
	pt->g_x += olist[root].ob_x;
	pt->g_y += olist[root].ob_y;
	/* make change */
	if (dochg)
		curr_state |= chgvalue;
	else
		curr_state &= ~chgvalue;
	/* get it updated on screen  */
	if (old_state != curr_state)
	{
		/* change it without drawing */
		objc_change(tree, obj, 0, pc->g_x, pc->g_y, pc->g_w, pc->g_h, curr_state, FALSE);
		/* clip to uncovered portion desktop or window and the object's extent */
		if (dodraw && rc_intersect(pc, pt))
		{
			do_wredraw(wh, pt->g_x, pt->g_y, pt->g_w, pt->g_h);
		}
	}
	return TRUE;
}


/*
 *	Change state of all objects partially intersecting the given rectangle
 *	but allow one object to be excluded.
 */
/* 104de: 00fd6452 */
/* 106de: 00e16ab8 */
VOID act_allchg(P(int16_t) wh, P(OBJECT *)tree, P(int16_t) root, P(int16_t) ex_obj, P(GRECT *)pt, P(GRECT *)pc, P(int16_t) chgvalue, P(BOOLEAN) dochg, P(BOOLEAN) dodraw, P(BOOLEAN) dox)
PP(int16_t wh;)
PP(OBJECT *tree;)
PP(int16_t root;)
PP(int16_t ex_obj;)
PP(GRECT *pt;)
PP(GRECT *pc;)
PP(int16_t chgvalue;)
PP(BOOLEAN dochg;)
PP(BOOLEAN dodraw;)
PP(BOOLEAN dox;)
{
	register int16_t obj;
	register int16_t newstate;
	int16_t offx, offy;
	GRECT o;
	GRECT a;
	register OBJECT *olist;
	register GRECT *po;
	register GRECT *pa;

	UNUSED(dox);
	po = &o;
	pa = &a;
	olist = tree;

	offx = olist[root].ob_x;
	offy = olist[root].ob_y;
	/* accumulate extent of change in this rectangle */
	pa->g_w = 0;
	pa->g_h = 0;

	for (obj = olist[root].ob_head; obj > root; obj = olist[obj].ob_next)
	{
		if (obj != ex_obj)
		{
			rc_copy((GRECT *) &olist[obj].ob_x, po);
			po->g_x += offx;
			po->g_y += offy;
			if (rc_intersect(pt, po) &&
				root != act_chkobj(tree, root, obj, po->g_x, po->g_y, po->g_w, po->g_h))
			{
				/* make change      */
				newstate = olist[obj].ob_state;
				if (dochg)
					newstate |= chgvalue;
				else
					newstate &= ~chgvalue;
				if (newstate != olist[obj].ob_state)
				{
					olist[obj].ob_state = newstate;
					rc_copy((GRECT *) &olist[obj].ob_x, po);
					po->g_x += offx;
					po->g_y += offy;
					if (pa->g_w)
						rc_union(po, pa);
					else
						rc_copy(po, pa);
				}
			}
		}
	}
	if (dodraw && rc_intersect(pc, pa))
	{
		do_wredraw(wh, pa->g_x, pa->g_y, pa->g_w, pa->g_h);
	}
}


/*
 *	Single click action on the specified tree of objects.
 */
/* 104de: 00fd65ba */
/* 106de: 00e16c46 */
VOID act_bsclick(P(int16_t) wh, P(OBJECT *)tree, P(int16_t) root, P(int16_t) mx, P(int16_t) my, P(int16_t) keystate, P(GRECT *)pc, P(int16_t) dclick)
PP(register int16_t wh;)
PP(register LPTREE tree;)
PP(register int16_t root;)
PP(int16_t mx;)
PP(int16_t my;)
PP(int16_t keystate;)
PP(register GRECT *pc;)
PP(int16_t dclick;)
{
	register int16_t obj;
	int16_t shifted;
	int16_t state;
	register OBJECT *olist;

	shifted = keystate & (K_LSHIFT | K_RSHIFT);
	obj = gr_obfind(tree, root, mx, my);

	if (obj == root || obj == NIL)
	{
		if (!shifted || dclick)
			act_allchg(wh, tree, root, obj, &gl_rfull, pc, SELECTED, FALSE, TRUE, TRUE);
	} else
	{
		olist = tree;
		state = olist[obj].ob_state;
		if (!shifted)
		{
			if (dclick || !(state & SELECTED))
			{
				act_allchg(wh, tree, root, obj, &gl_rfull, pc, SELECTED, FALSE, TRUE, TRUE);
				state |= SELECTED;
			}
		} else
		{
			if (state & SELECTED)
				state &= ~SELECTED;
			else
				state |= SELECTED;
		}
		act_chg(wh, tree, root, obj, pc, SELECTED, state & SELECTED, TRUE, TRUE);
	}
}


/* 104de: 00fd66ba */
/* 106de: 00e16d56 */
int16_t act_bdown(P(int16_t) wh, P(OBJECT *)tree, P(int16_t) root, P(int16_t *) in_mx, P(int16_t *) in_my, P(int16_t) keystate, P(GRECT *)pc, P(int16_t *)pdobj)
PP(register int16_t wh;)
PP(register LPTREE tree;)
PP(register int16_t root;)
PP(int16_t *in_mx;)
PP(int16_t *in_my;)
PP(int16_t keystate;)
PP(GRECT *pc;)
PP(int16_t *pdobj;)
{
	int16_t sobj;
	int16_t offx;
	int16_t offy;
	int16_t numobs;
	int16_t bstate;
	register OBJECT *olist;
	int16_t dst_wh;
	int16_t l_mx, l_my;
	int16_t dulx, duly;
	int16_t i;
	int16_t j;
	register int16_t obj;
	int16_t view;
	int16_t numpts;
	int16_t *pxypts;
	GRECT m;
	register GRECT *pm;
	register THEDSK *d;
	
	pm = &m;
	d = thedesk;

	dst_wh = NIL;
	*pdobj = root;
	l_mx = *in_mx;
	l_my = *in_my;
	sobj = gr_obfind(tree, root, l_mx, l_my);
	/* rubber box to enclose a group of icons */
	if (sobj == root || sobj == NIL)
	{
		r_set(pm, l_mx, l_my, 6, 6);
		graf_rubbox(pm->g_x, pm->g_y, 6, 6, &pm->g_w, &pm->g_h);
		act_allchg(wh, tree, root, sobj, pm, pc, SELECTED, TRUE, TRUE, TRUE);
	} else
	{
		/* drag icon(s) */
		olist = tree;
		if (olist[sobj].ob_state & SELECTED)
		{
			gr_accobs(tree, root, &numobs, d->g_xyobpts);
			if (numobs)
			{
				view = root == DROOT ? V_ICON : d->g_iview;
				if (view == V_ICON)
				{
					numpts = d->g_nmicon;
					pxypts = d->g_xyicon;
				} else
				{
					numpts = d->g_nmtext;
					pxypts = d->g_xytext;
				}
				gr_drgplns(l_mx, l_my, &gl_rfull, numpts, pxypts, numobs, d->g_xyobpts,
						   &dulx, &duly, &dst_wh, pdobj);
				if (dst_wh)
				{
					/* cancel drag if it ends up in same window over itself */
					if (wh == dst_wh && *pdobj == sobj)
						dst_wh = NIL;
				} else
				{
					/* DESKTOP v1.2: Dragging onto the desktop */
					if (wh == 0 && *pdobj == root)	/* Dragging from desktop */
					{
						move_drvicon(tree, root, dulx, duly, d->g_xyobpts);
						dst_wh = NIL;
					}
				}
			}
		}
	}

	evnt_button(
		1, 1, 0,
		&l_mx, &l_my, &bstate, &keystate);
	return dst_wh;
}
