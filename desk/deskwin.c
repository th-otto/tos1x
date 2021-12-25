/*      DESKWIN.C       06/11/84 - 04/01/85             Lee Lorenzen    */
/*                      4/7/86                          MDF             */
/*      for 3.0         11/4/87 - 11/19/87                      mdf     */

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

#define WKIND_FILE (-1)

extern intptr_t drawaddr;

short n_winsave;
GRECT g_winsave[NUM_WNODES];
DESKWIN *g_wlist;						/* head of window list      */

LINEF_STATIC VOID win_ocalc PROTO((DESKWIN *pwin, int16_t wfit, int16_t hfit, FNODE **ppstart));
LINEF_STATIC VOID win_icalc PROTO((FNODE *pfnode));
LINEF_STATIC VOID win_blt PROTO((DESKWIN *pw, BOOLEAN vertical, int16_t newcv));


/* 104de: 00fdc09c */
/* 106de: 00e1d518 */
VOID win_view(P(int16_t) vtype, P(int16_t) isort)
PP(int16_t vtype;)
PP(int16_t isort;)
{
	register THEDSK *d;
	
	d = thedesk;
	d->g_iview = vtype;
	d->g_isort = isort;

	switch (vtype)
	{
	case V_TEXT:
		d->g_iwext = (gl_width == 320 ? LEN_FNODE - 2 : LEN_FNODE) * gl_wchar;
		d->g_ihext = gl_hchar;
		d->g_iwint = gl_width == 320 ? 0 : 2 * gl_wchar - 1;
		d->g_ihint = 2;
		d->g_num = d->g_nmtext;
		d->g_pxy = d->g_xytext;
		break;
	case V_ICON:
		d->g_iwext = d->g_wicon;
		d->g_ihext = d->g_hicon;
		d->g_iwint = gl_height <= 300 ? 0 : 8;
		d->g_ihint = MIN_HINT;
		d->g_num = d->g_nmicon;
		d->g_pxy = d->g_xyicon;
		break;
	}
	d->g_iwspc = d->g_iwext + d->g_iwint;
	d->g_ihspc = d->g_ihext + d->g_ihint;
	if ((d->g_incol = d->g_full.g_w / d->g_iwspc) == 0)
		d->g_incol = 1;
}



/*
 *	Start up by initializing global variables
 */
/* 104de: 00fdc184 */
/* 106de: 00e1d608 */
VOID win_start(NOTHING)
{
	register int i;
	OBJECT *tree;
	register DESKWIN *pw;
	register THEDSK *d;

	d = thedesk;
	/*
	 *	Initialize all objects as children of the 0th root which is
	 *	the parent of unused objects.
	 * (inlined obj_init)
	 */
	tree = d->g_pscreen = d->g_screen;
	for (i = 0; i < NUM_SOBS; i++)
	{
		d->g_screen[i].ob_head = NIL;
		d->g_screen[i].ob_next = NIL;
		d->g_screen[i].ob_tail = NIL;
	}
	movs(sizeof(OBJECT), &gl_sampob[0], &d->g_screen[ROOT]);
	r_set((GRECT *) &d->g_screen[ROOT].ob_x, 0, 0, gl_width, gl_height);
	for (i = 0; i < (NUM_WNODES + NUM_ROBS - 1); i++)
	{
		movs(sizeof(OBJECT), &gl_sampob[1], &d->g_screen[i + DROOT]);
		objc_add(tree, ROOT, i + DROOT);
	}
	win_view(V_ICON, S_NAME);

	for (i = 0; i < NUM_WNODES; i++)
	{
		pw = &g_wlist[i];
		pw->w_obid = 0;
		pw->w_id = 0;
		LBCOPY(&g_winsave[i], &d->win_save[i].x_save, sizeof(GRECT));
	}
	thedesk->n_winalloc = 0;
	n_winsave = 0;
}



/*
 *	Allocate a window for use as a folder window
 */
/* 104de: 00fdc2a6 */
/* 106de: 00e1d748 */
DESKWIN *win_alloc(P(int16_t) obid)
PP(int16_t obid;)
{
	register DESKWIN *pw;
	register int16_t wob;
	register GRECT *pt;
	register THEDSK *d;

	d = thedesk;
	if (d->n_winalloc == NUM_WNODES)
		return NULL;
	pt = &g_winsave[n_winsave];
	wob = obj_walloc(pt->g_x, pt->g_y, pt->g_w, pt->g_h);
	if (wob)
	{
		d->n_winalloc++;
		n_winsave++;
		pw = &g_wlist[wob - NUM_ROBS];
		pw->w_flags = 0;
		pw->w_obid = obid;
		pw->w_root = wob;
		pw->w_cvcol = 0;
		pw->w_cvrow = 0;
		pw->w_pncol = pt->g_w / d->g_iwspc;
		pw->w_pnrow = pt->g_h / d->g_ihspc;
		pw->w_vncol = 0;
		pw->w_vnrow = 0;
		pw->w_id = wind_create(WKIND_FILE, d->g_desk.g_x, d->g_desk.g_y, d->g_desk.g_w, d->g_desk.g_h);
		r_set(&pw->w_curr, pt->g_x, pt->g_y, pt->g_w, pt->g_h);
		if (pw->w_id != -1)
		{
			return pw;
		} else
		{
			win_free(pw);
		}
	}
	return NULL;
}


/*
 *	Free a window node.
 */
/* 104de: 00fdc376 */
/* 106de: 00e1d82c */
VOID win_free(P(DESKWIN *)thewin)
PP(register DESKWIN *thewin;)
{
	if (thewin->w_id != -1)
		wind_delete(thewin->w_id);

	thedesk->n_winalloc--;
	thewin->w_id = 0;
	thewin->w_obid = 0;
	objc_order(thedesk->g_pscreen, thewin->w_root, 1);
#if BINEXACT
	obj_wfree(thewin->w_root, 0L, 0L);
#else
	obj_wfree(thewin->w_root, 0, 0, 0, 0);
#endif
	n_winsave--;
	LBCOPY(&g_winsave[n_winsave], &thewin->w_curr, sizeof(GRECT));
}


/*
 *	Find the WNODE that has this id.
 */
/* 104de: 00fdc3f4 */
/* 106de: 00e1d8c2 */
DESKWIN *win_find(P(int16_t) wh)
PP(int16_t wh;)
{
	register int ii;

	for (ii = 0; ii < NUM_WNODES; ii++)
	{
		if (g_wlist[ii].w_id == wh)
			return &g_wlist[ii];
	}
	return NULL;
}


/*
 *	Bring a window node to the top of the window list.
 */
VOID win_top(P(DESKWIN *)thewin)
PP(register DESKWIN *thewin;)
{
	int unused;
	
	UNUSED(unused);
	objc_order(thedesk->g_pscreen, thewin->w_root, NIL);
	if (!streq(thedesk->p_cartname, thewin->w_name))
		pro_chdir(thewin->w_name[1], &thewin->w_name[4]);
}


/*
 *	Find out if the window node on top has size, if it does then it
 *	is the currently active window.  If not, then no window is on
 *	top and return 0.
 */
DESKWIN *win_ontop(NOTHING)
{
	register THEDSK *d;
	register DESKWIN *pw;
	register int16_t tail;

	d = thedesk;
	tail = d->g_screen[ROOT].ob_tail;
	if (d->g_screen[tail].ob_width != 0 && d->g_screen[tail].ob_height != 0)
	{
		pw = &g_wlist[tail - NUM_ROBS];
		if (!streq(d->p_cartname, pw->w_name))
			pro_chdir(pw->w_name[1], &pw->w_name[4]);
		return pw;
	} else
	{
		return NULL;
	}
}


/*
 *	Find the window node that is the ith from the bottom.  Where
 *	0 is the bottom (desktop surface) and 1-4 are windows.
 */
DESKWIN *win_ith(P(int) level)
PP(register int level;)
{
	register int16_t wob;
	register THEDSK *d;
	
	d = thedesk;
	/* skip over desktop surface and count windows */
	wob = d->g_screen[ROOT].ob_head;
	while (level--)
	{
		wob = d->g_screen[wob].ob_next;
	}
	return &g_wlist[wob - NUM_ROBS];
}


/*
 *	Calculate a bunch of parameters related to how many file objects
 *	will fit in a window.
 */
/* 104de: 00fdc524 */
/* 106de: 00e1da26 */
LINEF_STATIC VOID win_ocalc(P(DESKWIN *)pwin, P(int16_t) wfit, P(int16_t) hfit, P(FNODE **)ppstart)
PP(register DESKWIN *pwin;)
PP(int16_t wfit;)
PP(int16_t hfit;)
PP(FNODE **ppstart;)
{
	register FNODE *pf;
	register int16_t start;
	register int16_t cnt;
	register int16_t w_space;
	register THEDSK *d;

	d = thedesk;
	/* 
	 * zero out obid ptrs in flist and count
	 * up # of files in virtual file space
	 */
	cnt = 0;
	for (pf = pwin->w_path->p_flist; pf; pf = pf->f_next)
	{
		pf->f_obid = NIL;
		cnt++;
	}
	/* set windows virtual number of rows and columns */
	pwin->w_vncol = cnt < d->g_incol ? cnt : d->g_incol;
	pwin->w_vnrow = cnt / d->g_incol;
	if ((cnt % d->g_incol) != 0)
		pwin->w_vnrow += 1;
	if (pwin->w_vnrow == 0)
		pwin->w_vnrow++;
	if (pwin->w_vncol == 0)
		pwin->w_vncol++;
	if (wfit == 0)
		wfit++;
	w_space = pwin->w_pncol = min(wfit, pwin->w_vncol);
	while ((pwin->w_vncol - pwin->w_cvcol) < w_space)
		pwin->w_cvcol--;
	if (hfit == 0)
		hfit++;
	w_space = pwin->w_pnrow = min(hfit, pwin->w_vnrow);
	while ((pwin->w_vnrow - pwin->w_cvrow) < w_space)
		pwin->w_cvrow--;
	/* 
	 * based on windows current virtual
	 * upper left row & column calculate
	 * the start and stop files
	 */
	start = pwin->w_cvrow * d->g_incol + pwin->w_cvcol;
	pf = pwin->w_path->p_flist;
	while (start-- != 0 && pf)
		pf = pf->f_next;
	*ppstart = pf;
}



/*
 *	Calculate a bunch of parameters dealing with a particular
 *	icon.
 */
LINEF_STATIC VOID win_icalc(P(FNODE *)pfnode)
PP(register FNODE *pfnode;)
{
	pfnode->f_pa = app_afind(FALSE, pfnode->f_attr & FA_DIREC ? AT_ISFOLD : AT_ISFILE, -1, pfnode->f_name, &pfnode->f_isapp);
}


/*
 *	Build an object tree of the list of files that are currently
 *	viewable in a full-screen virtual window.  Next adjust root of
 *	tree to take into account the current view of the full-screen
 *	through a window on the physical display.
 */
/* 104de: 00fdc652 */
/* 106de: 00e1db70 */
VOID win_bldview(P(DESKWIN *)pwin, P(int16_t) x, P(int16_t) y, P(int16_t) w, P(int16_t) h)
PP(register DESKWIN *pwin;)
PP(int16_t x;)
PP(int16_t y;)
PP(int16_t w;)
PP(int16_t h;)
{
	FNODE *pfirst;
	register FNODE *pf;
	register int16_t obid;
	register int16_t skipcnt;
	register int16_t sl_value;
	register int16_t r_cnt;
	register int16_t c_cnt;
	int16_t o_wfit;
	int16_t o_hfit;							/* object grid      */
	int16_t i_index;
	int16_t junk;
	int16_t unused;
	int16_t xoff;
	int16_t yoff;
	int16_t wh;
	int16_t sl_size;
	register THEDSK *d;
	
	UNUSED(unused);
	d = thedesk;
	/* free all this windows kids and set size */
	obj_wfree(pwin->w_root, x, y, w, h);
	/* make pfirst point at 1st file in current view */
	win_ocalc(pwin, w / d->g_iwspc, h / d->g_ihspc, &pfirst);
	pf = pfirst;
	o_wfit = min(pwin->w_pncol + 1, pwin->w_vncol - pwin->w_cvcol);
	o_hfit = min(pwin->w_pnrow + 1, pwin->w_vnrow - pwin->w_cvrow);
	r_cnt = c_cnt = 0;
	while (c_cnt < o_wfit && r_cnt < o_hfit && pf)
	{
		/* calc offset */
		yoff = r_cnt * d->g_ihspc;
		xoff = c_cnt * d->g_iwspc;

		/* allocate object */
		obid = obj_ialloc(pwin->w_root, xoff + d->g_iwint, yoff + d->g_ihint, d->g_iwext, d->g_ihext);
		if (!obid)
			/* error case, no more obs */
			return;
		/* remember it */
		pf->f_obid = obid;
		/* build object     */
		d->g_screen[obid].ob_state = WHITEBAK;
		d->g_screen[obid].ob_flags = 0;
		switch (d->g_iview)
		{
		case V_TEXT:
			d->g_screen[obid].ob_type = G_USERDEF;
			d->g_screen[obid].ob_spec = (intptr_t)&d->g_udefs[obid];
			d->g_udefs[obid].ub_code = drawaddr;
			d->g_udefs[obid].ub_parm = (intptr_t)&pf->f_attr;
			win_icalc(pf);
			break;
		case V_ICON:
			d->g_screen[obid].ob_type = G_ICON;
			win_icalc(pf);
			i_index = pf->f_isapp ? pf->f_pa->a_aicon : pf->f_pa->a_dicon;
			d->g_index[obid] = i_index;
			d->g_screen[obid].ob_spec = (intptr_t)&d->gl_icons[obid];
			movs(sizeof(ICONBLK), &d->g_iblist[i_index], &d->gl_icons[obid]);
			d->gl_icons[obid].ib_ptext = pf->f_name;
			break;
		}
		pf = pf->f_next;
		c_cnt++;
		if (c_cnt == o_wfit)
		{
			/* next row so skip next file in virt grid */
			r_cnt++;
			c_cnt = 0;
			skipcnt = pwin->w_vncol - o_wfit;
			while (skipcnt-- && pf)
				pf = pf->f_next;
		}
	}
	
	/* set slider size & position */
	wh = pwin->w_id;
	sl_size = mul_div(pwin->w_pncol, 1000, pwin->w_vncol);
#if BINEXACT
	wind_set(wh, WF_HSLSIZE, sl_size, 0L, 0);
#else
	wind_set(wh, WF_HSLSIZE, sl_size, 0, 0, 0);
#endif
	wind_get(wh, WF_HSLSIZE, &sl_size, &junk, &junk, &junk);
	if (pwin->w_vncol > pwin->w_pncol)
		sl_value = mul_div(pwin->w_cvcol, 1000, pwin->w_vncol - pwin->w_pncol);
	else
		sl_value = 0;
#if BINEXACT
	wind_set(wh, WF_HSLIDE, sl_value, 0L, 0);
#else
	wind_set(wh, WF_HSLIDE, sl_value, 0, 0, 0);
#endif

	sl_size = mul_div(pwin->w_pnrow, 1000, pwin->w_vnrow);
#if BINEXACT
	wind_set(wh, WF_VSLSIZE, sl_size, 0L, 0);
#else
	wind_set(wh, WF_VSLSIZE, sl_size, 0, 0, 0);
#endif
	wind_get(wh, WF_VSLSIZE, &sl_size, &junk, &junk, &junk);
	if (pwin->w_vnrow > pwin->w_pnrow)
		sl_value = mul_div(pwin->w_cvrow, 1000, pwin->w_vnrow - pwin->w_pnrow);
	else
		sl_value = 0;
#if BINEXACT
	wind_set(wh, WF_VSLIDE, sl_value, 0L, 0);
#else
	wind_set(wh, WF_VSLIDE, sl_value, 0, 0, 0);
#endif
}


/*
 *	Routine to blt the contents of a window based on a new 
 *	current row or column
 */
/* 104de: 00fdc988 */
/* 106de: 00e1def0 */
LINEF_STATIC VOID win_blt(P(DESKWIN *)pw, P(BOOLEAN) vertical, P(int16_t) newcv)
PP(register DESKWIN *pw;)
PP(BOOLEAN vertical;)
PP(register int16_t newcv;)
{
	register int16_t delcv;
	int16_t pn;
	register int16_t sx;
	register int16_t sy;
	int16_t dx;
	int16_t dy;
	int16_t wblt;
	int16_t hblt;
	int16_t revblt;
	int16_t tmp;
	GRECT c;
	GRECT t;
	register GRECT *pc;
	
	pc = &c;
	newcv = newcv > 0 ? newcv : 0;

	if (vertical)
	{
		newcv = min(pw->w_vnrow - pw->w_pnrow, newcv);
		pn = pw->w_pnrow;
		delcv = newcv - pw->w_cvrow;
		pw->w_cvrow += delcv;
	} else
	{
		newcv = min(pw->w_vncol - pw->w_pncol, newcv);
		pn = pw->w_pncol;
		delcv = newcv - pw->w_cvcol;
		pw->w_cvcol += delcv;
	}
	if (!delcv)
#if BINEXACT
		return FALSE;
#else
		return;
#endif

	wind_grget(pw->w_id, WF_WORKXYWH, pc);
	win_bldview(pw, pc->g_x, pc->g_y, pc->g_w, pc->g_h);
	/* see if any part is off the screen */
	rc_copy(pc, &t);
	rc_intersect(&gl_rfull, &t);
	if (rc_equal(pc, &t))
	{
		/*
		 * blt as much as we can
		 * adjust clip & draw the rest
		 */
		if ((revblt = (delcv < 0)) != 0)
			delcv = -delcv;
		if (pn > delcv)
		{
			/* see how much there is pretend blt up */
			if (vertical)
			{
				sx = dx = 0;
				sy = delcv * thedesk->g_ihspc;
				dy = 0;
				wblt = pc->g_w;
				hblt = pc->g_h - sy;
			} else
			{
				sx = delcv * thedesk->g_iwspc;
				dx = 0;
				sy = dy = 0;
				wblt = pc->g_w - sx;
				hblt = pc->g_h;
			}
			if (revblt)
			{
				tmp = sx;
				sx = dx;
				dx = tmp;
				tmp = sy;
				sy = dy;
				dy = tmp;
			}
			gsx_sclip(pc);
			bb_screen(S_ONLY, sx + pc->g_x, sy + pc->g_y, dx + pc->g_x, dy + pc->g_y, wblt, hblt);
			if (vertical)
			{
				if (!revblt)
					pc->g_y += hblt;
				pc->g_h -= hblt;
			} else
			{
				if (!revblt)
					pc->g_x += wblt;
				pc->g_w -= wblt;
			}
		}
	}
	do_wredraw(pw->w_id, pc->g_x, pc->g_y, pc->g_w, pc->g_h);
}


/*
 *	Routine to change the current virtual row or column being viewed
 *	in the upper left corner based on a new slide amount.
 */
VOID win_slide(P(int16_t) wh, P(uint16_t) sl_value, P(BOOLEAN) vertical)
PP(int16_t wh;)
PP(uint16_t sl_value;)
PP(BOOLEAN vertical;)
{
	register DESKWIN *pw;
	int16_t unused;
	int16_t newcv;
	int16_t unused2;
	int16_t vn, pn, i, sls, sl_size;

	UNUSED(unused);
	UNUSED(unused2);
	pw = win_find(wh);

	if (vertical)
	{
		vn = pw->w_vnrow;
		pn = pw->w_pnrow;
		sls = WF_VSLSIZE;
	} else
	{
		vn = pw->w_vncol;
		pn = pw->w_pncol;
		sls = WF_HSLSIZE;
	}
	wind_get(wh, sls, &sl_size, &i, &i, &i);
	newcv = mul_div(sl_value, vn - pn, 1000);
	win_blt(pw, vertical, newcv);
}


/*
 *	Routine to change the current virtual row or column being viewed
 *	in the upper left corner based on a new slide amount.
 */
VOID win_arrow(P(int16_t) wh, P(int16_t) arrow_type)
PP(int16_t wh;)
PP(int16_t arrow_type;)
{
	register DESKWIN *pw;
	register BOOLEAN vertical;
	register int16_t newcv;

	pw = win_find(wh);
	vertical = TRUE;
	switch (arrow_type)
	{
	case WA_UPPAGE:
		newcv = pw->w_cvrow - pw->w_pnrow;
		break;
	case WA_DNPAGE:
		newcv = pw->w_cvrow + pw->w_pnrow;
		break;
	case WA_UPLINE:
		newcv = pw->w_cvrow - 1;
		break;
	case WA_DNLINE:
		newcv = pw->w_cvrow + 1;
		break;
	case WA_LFPAGE:
		newcv = pw->w_cvcol - pw->w_pncol;
		vertical = FALSE;
		break;
	case WA_RTPAGE:
		newcv = pw->w_cvcol + pw->w_pncol;
		vertical = FALSE;
		break;
	case WA_LFLINE:
		newcv = pw->w_cvcol - 1;
		vertical = FALSE;
		break;
	case WA_RTLINE:
		newcv = pw->w_cvcol + 1;
		vertical = FALSE;
		break;
#if !BINEXACT
	default:
		return;
#endif
	}
	win_blt(pw, vertical, newcv);
}


/*
 * Routine to build all existing windows again,
 * and redraw them.
 */
VOID win_bdall(void)
{
	register int ii;
	register int16_t wh;
	GRECT c;
	register THEDSK *d;
	register DESKWIN *win;
	
	d = thedesk; /* FIXME: unused */
	UNUSED(d);
	for (ii = 0; ii < NUM_WNODES; ii++)
	{
		wh = g_wlist[ii].w_id;
		if (wh)
		{
			wind_grget(wh, WF_WORKXYWH, &c);
			win_bldview(&g_wlist[ii], c.g_x, c.g_y, c.g_w, c.g_h);
		}
	}
	/* draw all existing windows. */
	for (ii = NUM_WNODES; ii != 0; ii--)
	{
		win = win_ith(ii);
		if (win->w_id != 0)
		{
			wind_grget(win->w_id, WF_WORKXYWH, &c);
			send_msg(WM_REDRAW, gl_apid, win->w_id, c.g_x, c.g_y, c.g_w, c.g_h);
		}
	}
}


/*
 *	Return the next icon that was selected after the current icon.
 */
int16_t win_isel(P(OBJECT *)olist, P(int16_t) root, P(int16_t) curr)
PP(OBJECT *olist;)
PP(register int16_t root;)
PP(register int16_t curr;)
{
	if (curr == 0)
		curr = olist[root].ob_head;
	else
		curr = olist[curr].ob_next;

	while (curr > root)
	{
		if (olist[curr].ob_state & SELECTED)
			return curr;
		curr = olist[curr].ob_next;
	}
	return 0;
}


/*
 *	Return pointer to this icons name.  It will always be an icon that
 *	is on the desktop.
 */
char *win_iname(P(int16_t) curr)
PP(int16_t curr;)
{
	ICONBLK *pib;
	char *ptext;

	pib = (ICONBLK *)thedesk->g_screen[curr].ob_spec;
	ptext = pib->ib_ptext;
	return ptext;
}



/*
 *	Set the information lines of a particular window
 */
VOID win_sinfo(P(DESKWIN *)pwin)
PP(register DESKWIN *pwin;)
{
	register THEDSK *d;
	struct {
		int32_t size;
		uint16_t count;
	} parms;

	d = thedesk;
	parms.size = pwin->w_path->p_size;
	parms.count = pwin->w_path->p_count;
	rsrc_gaddr(R_STRING, STINFOST, (VOIDPTR *) &d->str);
	LSTCPY(g_buffer, d->str);
	merge_str(pwin->w_info, g_buffer, &parms);
}


/*
 *	Set the name and information lines of a particular window
 */
VOID win_sname(P(DESKWIN *)pw)
PP(register DESKWIN *pw;)
{
	register char *psrc;
	register char *pdst;

	psrc = pw->w_path->p_spec;
	pdst = pw->w_name;
	*pdst++ = ' ';
	while (*psrc && *psrc != '*')
		*pdst++ = *psrc++;
	*pdst++ = ' ';
	*pdst = 0;
}


/*
 * wind_get for getting a GRECT
 * (renamed from wind_get_grect for alcyon limitation)
 */
int16_t wind_grget(P(int16_t) w_handle, P(int16_t) w_field, P(GRECT *)gr)
PP(int16_t w_handle;)
PP(int16_t w_field;)
PP(GRECT *gr;)
{
    return wind_get(w_handle, w_field, &gr->g_x, &gr->g_y, &gr->g_w, &gr->g_h);
}

