/*      GEMWMLIB.C      4/23/84 - 07/11/85      Lee Lorenzen            */
/*      merge High C vers. w. 2.2               8/24/87         mdf     */
/*      fix wm_delete bug                       10/8/87         mdf     */

/*
 *       Copyright 1999, Caldera Thin Clients, Inc.
 *                 2002-2016 The EmuTOS development team
 *
 *       This software is licenced under the GNU Public License.
 *       Please see LICENSE.TXT for further information.
 *
 *                  Historical Copyright
 *       -------------------------------------------------------------
 *       GEM Application Environment Services              Version 2.3
 *       Serial No.  XXXX-0000-654321              All Rights Reserved
 *       Copyright (C) 1987                      Digital Research Inc.
 *       -------------------------------------------------------------
 */

#include "aes.h"
#include "gemlib.h"
#include "taddr.h"
#include "gsxdefs.h"

#define DROP_SIZE 2						/* Windows have drop shadows */

#if MULTIAPP
#define NUM_MWIN NUM_WIN+1
#define INACROOT NUM_WIN
#endif
#if SINGLAPP
#define NUM_MWIN NUM_WIN
#endif


int16_t gl_wtop;
OBJECT *gl_awind;

/*
 * current desktop background pattern.
 */
LPTREE gl_newdesk;

/*
 * current object within gl_newdesk.
 */
int16_t gl_newroot;

SPB *ad_windspb;

STATIC OBJECT W_TREE[NUM_MWIN];
STATIC OBJECT W_ACTIVE[MAXOBJ];

STATIC BOOLEAN w_walkflag;
STATIC LPTREE gl_wtree;
STATIC TEDINFO gl_aname;
STATIC TEDINFO gl_ainfo;
STATIC int16_t wind_msg[8];
STATIC BOOLEAN wasclr; /* WTF */


static int16_t const gl_watype[MAXOBJ] =
{
    G_IBOX,         /* W_BOX        */
    G_BOX,          /* W_TITLE      */
    G_BOXCHAR,      /* W_CLOSER     */
    G_BOXTEXT,      /* W_NAME       */
    G_BOXCHAR,      /* W_FULLER     */
    G_BOXTEXT,      /* W_INFO       */
    G_IBOX,         /* W_DATA       */
    G_IBOX,         /* W_WORK       */
    G_BOXCHAR,      /* W_SIZER      */
    G_BOX,          /* W_VBAR       */
    G_BOXCHAR,      /* W_UPARROW    */
    G_BOXCHAR,      /* W_DNARROW    */
    G_BOX,          /* W_VSLIDE     */
    G_BOX,          /* W_VELEV      */
    G_BOX,          /* W_HBAR       */
    G_BOXCHAR,      /* W_LFARROW    */
    G_BOXCHAR,      /* W_RTARROW    */
    G_BOX,          /* W_HSLIDE     */
    G_BOX           /* W_HELEV      */
};

static int32_t const gl_waspec[MAXOBJ] =
{
    0x00011101L,    /* W_BOX        */
    0x00011101L,    /* W_TITLE      */
    0x05011101L,    /* W_CLOSER     */
    0x0L,           /* W_NAME       */
    0x07011101L,    /* W_FULLER     */
    0x0L,           /* W_INFO       */
    0x00001101L,    /* W_DATA       */
    0x00001101L,    /* W_WORK       */
    0x06011101L,    /* W_SIZER      */
    0x00011101L,    /* W_VBAR       */
    0x01011101L,    /* W_UPARROW    */
    0x02011101L,    /* W_DNARROW    */
    0x00011111L,    /* W_VSLIDE     */
    0x00011101L,    /* W_VELEV      */
    0x00011101L,    /* W_HBAR       */
    0x04011101L,    /* W_LFARROW    */
    0x03011101L,    /* W_RTARROW    */
    0x00011111L,    /* W_HSLIDE     */
    0x00011101L     /* W_HELEV      */
};

#if BINEXACT
static short const garbage[] = {
	 /* hההה?? */
	0x2304, 0x3405, 0x4506, 0x56a7, 0x6708, 0x7809, 0x890a, 0x9a0b, 0xab0c, 0xbc0d, 0xcd0e, 0xde0f, 0x2314, 0x3405,
	0x4506, 0x5607, 0x6708, 0x7819, 0x890a, 0x9a0b, 0xab0c, 0xbc0d, 0xcd0e, 0xde0f
};
#endif

static TEDINFO const gl_asamp =
{
	0x0L, 0x0L, 0x0L, IBM, MD_REPLACE, TE_LEFT, SYS_FG, 0x0, 1, 80, 80
};


static BOOLEAN w_union PROTO((ORECT *po, GRECT *pt));



/* 306de: 00e211cc */
LINEF_STATIC VOID w_nilit(P(int16_t) num, P(OBJECT *) olist)
PP(register int16_t num;)
PP(OBJECT * olist;)
{
    while (num--)
    {
        olist[num].ob_next = olist[num].ob_head = olist[num].ob_tail = NIL;
    }
}




/*
 *  Routine to add a child object to a parent object.  The child
 *  is added at the end of the parent's current sibling list.
 *  It is also initialized.
 */
LINEF_STATIC VOID w_obadd(P(OBJECT *) olist, P(int16_t) parent, P(int16_t) child)
PP(OBJECT *olist;)
PP(register int16_t parent;)
PP(register int16_t child;)
{
	register int16_t lastkid;

	if (parent != NIL && child != NIL)
	{
		olist[child].ob_next = parent;

		lastkid = olist[parent].ob_tail;
		if (lastkid == NIL)
			olist[parent].ob_head = child;
		else
			olist[lastkid].ob_next = child;

		olist[parent].ob_tail = child;
	}
}


/* 306de: 00e21296 */
LINEF_STATIC VOID w_setup(P(PD *) ppd, P(int16_t) w_handle, P(int16_t) kind)
PP(PD *ppd;)
PP(int16_t w_handle;)
PP(int16_t kind;)
{
	register WINDOW *pwin;
	int i;
	
	pwin = srchwp(w_handle);
	pwin->w_owner = ppd;
	pwin->w_flags |= VF_INUSE;
	pwin->w_kind = kind;
	pwin->w_hslide = pwin->w_vslide = 0;	/* slider at left/top	*/
	pwin->w_hslsiz = pwin->w_vslsiz = -1;	/* use default size 	*/
}


/* 306de: 00e21328 */
LINEF_STATIC GRECT *w_getxptr(P(int16_t) which, P(int16_t) w_handle)
PP(int16_t which;)
PP(int16_t w_handle;)
{
	register WINDOW *pwin = srchwp(w_handle);
	
	switch (which)
	{
	case WS_CURR:
	case WS_TRUE:
		return (GRECT *) (&W_TREE[w_handle].ob_x);
#if BINEXACT
		break;
#endif
	case WS_PREV:
		return &pwin->w_prev;
#if BINEXACT
		break;
#endif
	case WS_WORK:
		return &pwin->w_work;
#if BINEXACT
		break;
#endif
	case WS_FULL:
		return &pwin->w_full;
#if BINEXACT
		break;
#endif
	}
#if !BINEXACT
	/* BUG: no return value here, but won't be reached */
	return 0;
#endif
}


/*
 * Get the size (x,y,w,h) of the window
 */
/* 306de: 00e213a6 */
VOID w_getsize(P(int16_t) which, P(int16_t) w_handle, P(GRECT *)pt)
PP(register int16_t which;)
PP(int16_t w_handle;)
PP(register GRECT *pt;)
{
	rc_copy(w_getxptr(which, w_handle), pt);

#if DROP_SIZE
	if (which == WS_TRUE && pt->g_w && pt->g_h)
	{
		pt->g_w += DROP_SIZE;
		pt->g_h += DROP_SIZE;
	}
#endif
}


LINEF_STATIC VOID w_setsize(P(int16_t) which, P(int16_t) w_handle, P(GRECT *)pt)
PP(int16_t which;)
PP(int16_t w_handle;)
PP(GRECT *pt;)
{
	rc_copy(pt, w_getxptr(which, w_handle));
}


/*
 * setcol() - set the color of an object.
 */
/* 306de: 00e21412 */
static VOID setcol(P(int16_t) ndx, P(WINDOW *) wp, P(BOOLEAN) topped)
PP(int16_t ndx;)							/* index into object structure */
PP(WINDOW *wp;)								/* pointer to window structure */
PP(BOOLEAN topped;)							/* YES: top window color */
{
	register int16_t color;
	register OBJECT *obj;
	
	obj = &W_ACTIVE[ndx];
	if (obj->ob_type == G_BOXTEXT)
	{
		((TEDINFO *) (obj->ob_spec))->te_color = color;
	} else
	{
		obj->ob_spec = (obj->ob_spec & 0xffff0000L) | ((int32_t)color & 0x0000ffffL);
	}
}


/* 306de: 00e21484 */
LINEF_STATIC VOID w_adjust(P(int16_t) parent, P(int16_t) obj, P(int16_t) x, P(int16_t) y, P(int16_t) w, P(int16_t) h)
PP(int16_t parent;)
PP(register int16_t obj;)
PP(int16_t x;)
PP(int16_t y;)
PP(int16_t w;)
PP(int16_t h;)
{
	register OBJECT *pobj;
	
	pobj = &W_ACTIVE[obj];
#if BINEXACT
	rc_copy((GRECT *)&x, (GRECT *)&pobj->ob_x); /* WTF */
#else
	pobj->ob_x = x;
	pobj->ob_y = y;
	pobj->ob_width = w;
	pobj->ob_height = h;
#endif

	pobj->ob_head = pobj->ob_tail = NIL;
	w_obadd(&W_ACTIVE[ROOT], parent, obj);
}


/* 306de: 00e214d4 */
LINEF_STATIC VOID w_hvassign(
	P(BOOLEAN) isvert, P(int16_t) parent, P(int16_t) obj,
	P(int16_t) vx, P(int16_t) vy,
	P(int16_t) hx, P(int16_t) hy,
	P(int16_t) w, P(int16_t) h)
PP(int16_t isvert;)
PP(register int16_t parent;)
PP(register int16_t obj;)
PP(int16_t vx;)
PP(int16_t vy;)
PP(int16_t hx;)
PP(int16_t hy;)
PP(int16_t w;)
PP(int16_t h;)
{
	if (isvert)
		w_adjust(parent, obj, vx, vy, gl_wbox, h);
	else
		w_adjust(parent, obj, hx, hy, w, gl_hbox);
}


/*
 *	Walk the list and draw the parts of the window tree owned by this window
 */
/* 306de: 00e21528 */
LINEF_STATIC VOID do_walk(P(int16_t) wh, P(OBJECT *) tree, P(int16_t) obj, P(int16_t) depth, P(GRECT *) pc)
PP(register int16_t wh;)
PP(OBJECT *tree;)
PP(int16_t obj;)
PP(int16_t depth;)
PP(register GRECT *pc;)
{
	register ORECT *po;
	GRECT t;

	if (w_walkflag || wh == NIL)
#if BINEXACT
		return TRUE; /* why? */
#else
		return;
#endif

	/* clip to screen */
	if (pc)
		rc_intersect(&gl_rfull, pc);
	else
		pc = &gl_rfull;

	/* walk owner rectangle list */
	for (po = srchwp(wh)->w_rlist; po; po = po->o_link)
	{
		rc_copy(&po->o_gr, &t);
		/* intersect owner rectangle with clip rectangles */
		if (rc_intersect(pc, &t))
		{
			if (wh == gl_wtop)
				w_getsize(WS_TRUE, wh, &t); /* hmm.... */
			/* set clip and draw */
			gsx_sclip(&t);
			ob_draw((LPTREE)tree, obj, depth);
		}
	}
}


/*
 *  Draw the desktop background pattern underneath the current set of windows
 */
/* 306de: 00e215e0 */
VOID w_drawdesk(P(GRECT *) dirty)
PP(register GRECT *dirty;)							/* rectangle of dirty area */
{
	register LPTREE tree;
	register int16_t depth;
	register int16_t root;

	if (gl_newdesk)
	{
		tree = gl_newdesk;
		depth = MAX_DEPTH;
		root = gl_newroot;
	} else
	{
		tree = gl_wtree;
		depth = 0;
		root = ROOT;
	}

	/* account for drop shadow: BUGFIX in 2.1 */
#if DROP_SIZE
	/* BUG: modifies callers arguments */
	dirty->g_w += DROP_SIZE;
	dirty->g_h += DROP_SIZE;
#endif

	do_walk(DESK, (OBJECT *)tree, root, depth, dirty);
}


LINEF_STATIC VOID w_cpwalk(P(int16_t) wh, P(int16_t) obj, P(int16_t) depth, P(BOOLEAN) usetrue)
PP(register int16_t wh;)
PP(int16_t obj;)
PP(int16_t depth;)
PP(BOOLEAN usetrue;)
{
	GRECT c;

	/* start with window's true size as clip */
	if (usetrue)
	{
		w_getsize(WS_TRUE, wh, &c);
	} else
	{
		/* use global clip */
		gsx_gclip(&c);
		/* add in drop shadow */
#if DROP_SIZE
		c.g_w += DROP_SIZE;
		c.g_h += DROP_SIZE;
#endif
	}
	w_bldactive(wh);
	do_walk(wh, gl_awind, obj, depth, &c);
}


/* 306de: 00e21690 */
LINEF_STATIC VOID w_strchg(P(int16_t) w_handle, P(int16_t) obj, P(intptr_t) pstring)
PP(register int16_t w_handle;)
PP(register int16_t obj;)
PP(register intptr_t pstring;)
{
	register WINDOW *pwin;
	
	pwin = srchwp(w_handle);
	if (obj == W_NAME)
		gl_aname.te_ptext = pwin->w_pname = (char *)pstring;
	else
		gl_ainfo.te_ptext = pwin->w_pinfo = (char *)pstring;

	w_cpwalk(w_handle, obj, MAX_DEPTH, TRUE);
}


/* 306de: 00e216f4 */
LINEF_STATIC VOID w_barcalc(P(BOOLEAN) isvert, P(int16_t) space, P(int16_t) sl_value, P(int16_t) sl_size, P(int16_t) min_sld, P(GRECT *)ptv, P(GRECT *) pth)
PP(BOOLEAN isvert;)
PP(register int16_t space;)
PP(register int16_t sl_value;)
PP(register int16_t sl_size;)
PP(register int16_t min_sld;)
PP(GRECT *ptv;)
PP(GRECT *pth;)
{
	if (sl_size == -1)
		sl_size = min_sld;
	else
		sl_size = max(min_sld, mul_div(sl_size, space, 1000));

	sl_value = mul_div(space - sl_size, sl_value, 1000);

	if (isvert)
		r_set(ptv, 0, sl_value, gl_wbox, sl_size);
	else
		r_set(pth, sl_value, 0, sl_size, gl_hbox);
}


/* 306de: 00e21790 */
LINEF_STATIC VOID w_bldbar(P(uint16_t) kind, P(BOOLEAN) istop,
	P(int16_t) w_bar, P(WINDOW *) wp,
	P(int16_t) x, P(int16_t) y, P(int16_t) w, P(int16_t) h)
PP(uint16_t kind;)
PP(BOOLEAN istop;)
PP(int16_t w_bar;)
PP(register WINDOW *wp;)
PP(register int16_t x;)
PP(register int16_t y;)
PP(register int16_t w;)
PP(register int16_t h;)
{
	int16_t sl_value, sl_size;
	BOOLEAN isvert;
	int16_t obj;
	uint16_t upcmp, dncmp, slcmp;
	register int16_t w_up;
	int16_t w_dn, w_slide, min_sld;
	int16_t w_elev;
	int16_t unused;
	int16_t space;
	
	UNUSED(unused);
	isvert = w_bar == W_VBAR;
	if (isvert)
	{
		sl_value = wp->w_vslide;
		sl_size = wp->w_vslsiz;
		upcmp = UPARROW;
		dncmp = DNARROW;
		slcmp = VSLIDE;
		w_up = W_UPARROW;
		w_dn = W_DNARROW;
		w_slide = W_VSLIDE;
		min_sld = gl_hbox;
		w_elev = W_VELEV;
	} else
	{
		sl_value = wp->w_hslide;
		sl_size = wp->w_hslsiz;
		upcmp = LFARROW;
		dncmp = RTARROW;
		slcmp = HSLIDE;
		w_up = W_LFARROW;
		w_dn = W_RTARROW;
		w_slide = W_HSLIDE;
		min_sld = gl_wbox;
		w_elev = W_HELEV;
	}
	
	setcol(w_bar, wp, istop);
	setcol(w_up, wp, istop);
	setcol(w_dn, wp, istop);
	setcol(w_slide, wp, istop);
	setcol(w_elev, wp, istop);
	w_hvassign(isvert, W_DATA, w_bar, x, y, x, y, w, h);
	x = y = 0;
	if (istop)
	{
		if (kind & upcmp)
		{
			w_adjust(w_bar, w_up, x, y, gl_wbox, gl_hbox);
			if (isvert)
			{
				y += (gl_hbox - 1);
				h -= (gl_hbox - 1);
			} else
			{
				x += (gl_wbox - 1);
				w -= (gl_wbox - 1);
			}
		}
		if (kind & dncmp)
		{
			w -= (gl_wbox - 1);
			h -= (gl_hbox - 1);
			w_hvassign(isvert, w_bar, w_dn, x, y + h - 1,
						x + w - 1, y, gl_wbox, gl_hbox);
		}
		if (kind & slcmp)
		{
			w_hvassign(isvert, w_bar, w_slide, x, y, x, y, w, h);
			space = isvert ? h : w;

			w_barcalc(isvert, space, sl_value, sl_size, min_sld,
				  (GRECT *)&W_ACTIVE[W_VELEV].ob_x, (GRECT *)&W_ACTIVE[W_HELEV].ob_x);

			obj = isvert ? W_VELEV : W_HELEV;
			W_ACTIVE[obj].ob_head = W_ACTIVE[obj].ob_tail = NIL;
			w_obadd(&W_ACTIVE[ROOT], w_slide, obj);
		}
	}
}


#define w_top() (gl_wtop != NIL ? gl_wtop : DESK)


VOID w_setactive(NOTHING)
{
	GRECT d;
	register int16_t wh;

	wh = w_top();
	w_getsize(WS_WORK, wh, &d);

	/* BUG: don't chg own if null */
	ct_chgown(srchwp(wh)->w_owner, &d);
}


/* 306de: 00e21a70 */
VOID w_bldactive(P(int16_t) w_handle)
PP(register int16_t w_handle;)
{
	BOOLEAN istop, issub;
	register int16_t kind;
	register int16_t havevbar;
	register int16_t havehbar;
	GRECT t;
	register int16_t tempw;
	int16_t offx, offy;
	register GRECT *pt;
	register WINDOW *pw;
	
	pw = srchwp(w_handle);
	pt = &t;

	if (w_handle == NIL)
#if BINEXACT
		return TRUE; /* why? */
#else
		return;
#endif

	istop = gl_wtop == w_handle;	/* set if it is on top */
	kind = pw->w_kind;				/* get the kind of window */
	w_nilit(MAXOBJ, W_ACTIVE);

	/* start adding pieces & adjusting sizes */
	gl_aname.te_ptext = pw->w_pname;
	gl_ainfo.te_ptext = pw->w_pinfo;
#if 0
	gl_aname.te_just = TE_CNTR;
	issub = (pw->w_flags & VF_SUBWIN) && (srchwp(gl_wtop)->w_flags & VF_SUBWIN);
#else
	UNUSED(issub);
#endif
	w_getsize(WS_CURR, w_handle, pt);
	rc_copy(pt, (GRECT *)&W_ACTIVE[W_BOX].ob_x); /* FIXME: typecast */
	offx = pt->g_x;
	offy = pt->g_y;

	/* do title area */
	setcol(W_BOX, pw, istop);
	pt->g_x = pt->g_y = 0;
	if (kind & (NAME | CLOSER | FULLER))
	{
		setcol(W_TITLE, pw, istop);
		w_adjust(W_BOX, W_TITLE, pt->g_x, pt->g_y, pt->g_w, gl_hbox);
		tempw = pt->g_w;
		if ((kind & CLOSER) && (istop /* || issub */))
		{
			setcol(W_CLOSER, pw, istop);
			w_adjust(W_TITLE, W_CLOSER, pt->g_x, pt->g_y, gl_wbox, gl_hbox);
			pt->g_x += gl_wbox;
			tempw -= gl_wbox;
		}
		if ((kind & FULLER) && (istop /* || issub */))
		{
			tempw -= gl_wbox;
			setcol(W_FULLER, pw, istop);
			w_adjust(W_TITLE, W_FULLER, pt->g_x+tempw, pt->g_y, gl_wbox, gl_hbox);
		}
		if (kind & NAME)
		{
			setcol(W_NAME, pw, istop);
			w_adjust(W_TITLE, W_NAME, pt->g_x, pt->g_y, tempw, gl_hbox);
#if 0
			W_ACTIVE[W_NAME].ob_state = (istop || issub) ? NORMAL : DISABLED;

			/* comment out following line to enable pattern in window title */
			gl_aname.te_color = (istop && !issub) ? WTS_FG : WTN_FG;
#endif
		}
		pt->g_x = 0;
		pt->g_y += (gl_hbox - 1);
		pt->g_h -= (gl_hbox - 1);
	}

	/* do info area */
	if (kind & INFO)
	{
		setcol(W_INFO, pw, istop);
		w_adjust(W_BOX, W_INFO, pt->g_x, pt->g_y, pt->g_w, gl_hbox);
		pt->g_y += (gl_hbox - 1);
		pt->g_h -= (gl_hbox - 1);
	}

	/* do data area */
	w_adjust(W_BOX, W_DATA, pt->g_x, pt->g_y, pt->g_w, pt->g_h);

	/* do work area */
	pt->g_x++;
	pt->g_y++;
	pt->g_w -= 2;
	pt->g_h -= 2;
	havevbar = kind & (UPARROW | DNARROW | VSLIDE | SIZER);
	havehbar = kind & (LFARROW | RTARROW | HSLIDE | SIZER);
	if (havevbar)
		pt->g_w -= (gl_wbox - 1);
	if (havehbar)
		pt->g_h -= (gl_hbox - 1);

	pt->g_x += offx;
	pt->g_y += offy;

	pt->g_x = pt->g_y = 1;
	w_adjust(W_DATA, W_WORK, pt->g_x, pt->g_y, pt->g_w, pt->g_h);

	/* do vertical bar area */
	if (havevbar)
	{
		pt->g_x += pt->g_w;
		w_bldbar(kind, istop /* || issub */, W_VBAR, pw, pt->g_x, 0, pt->g_w + 2, pt->g_h+2);
	}

	/* do horizontal bar area */
	if (havehbar)
	{
		pt->g_y += pt->g_h;
		w_bldbar(kind, istop /* || issub */, W_HBAR, pw, 0, pt->g_y, pt->g_w + 2, pt->g_h+2);
	}

	/* do sizer area */
	if (havevbar && havehbar)
	{
		setcol(W_SIZER, pw, istop);
		w_adjust(W_DATA, W_SIZER, pt->g_x, pt->g_y, gl_wbox, gl_hbox);
		W_ACTIVE[W_SIZER].ob_spec &= 0xffffL;
		W_ACTIVE[W_SIZER].ob_spec |= (istop && (kind & SIZER)) ? 0x06010000L: 0x00010000L;
	}
}


/* 
 * ap_sendmsg() - send message to current process
 */
/* 206us: 00e1e2ea */
/* 306de: 00e21daa */
VOID ap_sendmsg(P(int16_t *) ap_msg, P(int16_t) type, P(int16_t) towhom, P(int16_t) w3, P(int16_t) w4, P(int16_t) w5, P(int16_t) w6, P(int16_t) w7)
PP(int16_t *ap_msg;)
PP(int16_t type;)
PP(int16_t towhom;)
PP(int16_t w3;)
PP(int16_t w4;)
PP(int16_t w5;)
PP(int16_t w6;)
PP(int16_t w7;)
{
	ap_msg[0] = type;
	ap_msg[1] = rlr->p_pid;
	ap_msg[2] = 0;
	ap_msg[3] = w3;
	ap_msg[4] = w4;
	ap_msg[5] = w5;
	ap_msg[6] = w6;
	ap_msg[7] = w7;
	ap_rdwr(AQWRT, towhom, 16, ADDR(&ap_msg[0]));
}


/* 206us: 00e1e35c */
/* 306de: 00e21e1c */
LINEF_STATIC VOID w_redraw(P(int16_t) w_handle, P(GRECT *) dirty)
PP(register int16_t w_handle;)
PP(GRECT *dirty;)
{
	GRECT t, d;
	register GRECT *pt;
	register WINDOW *wp;
	
	wp = srchwp(w_handle);
	pt = &t;
	
	/* make sure work rect and word rect intersect */
	rc_copy(dirty, pt);
	w_getsize(WS_WORK, w_handle, &d);
	if (rc_intersect(pt, &d))
	{
		/* make sure window owns a rectangle */
		if (w_union(wp->w_rlist, &d))
		{
			/* intersect redraw rect with union of owner rects */
			if (rc_intersect(&d, pt))
				ap_sendmsg(wind_msg, WM_REDRAW, wp->w_owner->p_pid, w_handle, pt->g_x, pt->g_y, pt->g_w, pt->g_h);
		}
	}
}


/*
 *	Routine to fix rectangles in preparation for a source to destination
 *	blit.  If the source is at -1, then the source and destination left
 *	fringes need to be realigned.
 */
/* 206us: 00e1e400 */
/* 306de: 00e21ec0 */
LINEF_STATIC BOOLEAN w_mvfix(P(GRECT *) ps, P(GRECT *) pd)
PP(register GRECT *ps;)
PP(register GRECT *pd;)
{
	register int16_t tmpsx;

	tmpsx = ps->g_x;
	rc_intersect(&gl_rfull, ps);
	if (tmpsx == -1)
	{
		pd->g_x++;
		pd->g_w--;
		return TRUE;
	}

	return FALSE;
}


/*
 *	Call to move top window.  This involves BLTing the window if none
 *	of it that is partially off the screen needs to be redrawn, else
 *	the whole desktop is just updated.	All uncovered portions of the
 *	desktop are redrawn by later calling w_update.
 */
/* 206us: 00e1e43e */
/* 306de: 00e21efe */
LINEF_STATIC BOOLEAN w_move(P(int16_t) w_handle, P(int16_t *) pstop, P(GRECT *) prc)
PP(register int16_t w_handle;)
PP(register int16_t *pstop;)
PP(GRECT *prc;)
{
	GRECT s;		/* source */
	GRECT d;		/* destination */
	register GRECT *pc;
	register int16_t sminus1, dminus1;

	if (w_walkflag)
#if BINEXACT
		return;
#else
		return FALSE;
#endif
	
	w_getsize(WS_PREV, w_handle, &s);
#if DROP_SIZE
	s.g_w += DROP_SIZE;
	s.g_h += DROP_SIZE;
#endif
	w_getsize(WS_TRUE, w_handle, &d);

	/* set flags for when part of the source is off the screen */
	if (((s.g_x + s.g_w > gl_width) && (d.g_x < s.g_x)) ||
		((s.g_y + s.g_h > gl_height) && (d.g_y < s.g_y)))
	{
		rc_union(&s, &d);
		*pstop = DESK;
	} else
	{
		*pstop = w_handle;
	}

	/* intersect with full screen and align fringes if -1 xpos */
	sminus1 = w_mvfix(&s, &d);
	dminus1 = w_mvfix(&d, &s);

	/* blit what we can */
	if (*pstop == w_handle)
	{
		gsx_sclip(&gl_rfull);
		bb_screen(S_ONLY, s.g_x, s.g_y, d.g_x, d.g_y, s.g_w, s.g_h);
		/* cleanup left edge */
		if (sminus1 != dminus1)
		{
			if (dminus1)
				s.g_x--;
			if (sminus1)
			{
				d.g_x--;
				d.g_w = 1;
				gsx_sclip(&d);
				w_cpwalk(gl_wtop, 0, 0, 0);
			}
		}
		pc = &s;
	} else
	{
		pc = &d;
	}

	/* clean up the rest by returning clip rect */
	rc_copy(pc, prc);

	return *pstop == w_handle;
}


/*
 *	Draw windows from top to bottom.  If top is 0, then start at the topmost
 *	window.  If bottom is 0, then start at the bottomost window.  For the
 *	first window drawn, just do the insides, since DRAW_CHANGE has already
 *	drawn the outside borders.
 */
/* 306de: 00e22038 */
VOID w_update(P(int16_t) bottom, P(GRECT *) pt, P(int16_t) top, P(BOOLEAN) moved)
PP(register int16_t bottom;)
PP(register GRECT *pt;)
PP(register int16_t top;)
PP(BOOLEAN moved;)
{
	register int16_t i, ni;
	register BOOLEAN done;
	
	if (w_walkflag)
		return;
	
	/* limit to screen */
	rc_intersect(&gl_rfull, pt);
	gsx_moff();

	/* update windows from top to bottom */
	if (bottom == DESK)
		bottom = W_TREE[ROOT].ob_head;

	/* if there are windows */
	if (bottom != NIL)
	{
		/* start at the top */
		if (top == DESK)
			top = W_TREE[ROOT].ob_tail;
		/* draw windows from top to bottom */
		do
		{
			if (!(moved && top == gl_wtop))
			{
				/* set clip and draw a window's border	*/
				gsx_sclip(pt);
				w_cpwalk(top, 0, MAX_DEPTH, FALSE);	/* let appl. draw inside */
				w_redraw(top, pt);
			}
			
			/* scan to find prev */
			i = bottom;
			done = i == top;
			while (i != top)
			{
				ni = W_TREE[i].ob_next;
				if (ni == top)
					top = i;
				else
					i = ni;
			}
		} while (!done);
	}

	gsx_mon();
}


#if 0
static VOID w_setmen(P(int16_t) pid)
PP(int16_t pid;)
{
	int16_t npid;

	npid = menu_tree[pid] ? pid : 0;
	if (gl_mntree != menu_tree[npid])
		mn_bar(menu_tree[npid], TRUE, npid);

	npid = desk_tree[pid] ? pid : 0;
	if (gl_newdesk != desk_tree[npid])
	{
		gl_newdesk = desk_tree[npid];
		gl_newroot = desk_root[npid];
		w_drawdesk(&gl_rscreen);
	}
}


/*
 *	Routine to draw menu of top most window as the current menu bar.
 */
static VOID w_menufix(NOTHING)
{
	int16_t pid;

	pid = D.w_win[w_top()].w_owner->p_pid;
	w_setmen(pid);
}
#endif


/*
 *	Draw the tree of windows given a major change in some window.  It
 *	may have been sized, moved, fulled, topped, or closed.	An attempt
 *	should be made to minimize the amount of redrawing of other windows
 *	that has to occur.	W_REDRAW() will actually issue window redraw
 *	requests based on the rectangle that needs to be cleaned up.
 */
/* 306de: 00e220fa */
LINEF_STATIC VOID draw_change(P(int16_t) w_handle, P(GRECT *) pt)
PP(register int16_t w_handle;)
PP(register GRECT *pt;)
{
	GRECT c;
	register GRECT *pc;
	register GRECT *pw;
	register int16_t start;
	int16_t moved;
	int16_t diffbord;
	int16_t stop;
	register int16_t oldtop, clrold;
#if 0
	BOOLEAN wasclr;
	GRECT pprev;
#endif
	long unused;
	
	UNUSED(unused);
	UNUSED(diffbord);
	
	pc = &c;
#if 0
	wasclr = !(srchwp(w_handle)->w_flags & VF_BROKEN);
#endif

	/* save old size */
	w_getsize(WS_CURR, w_handle, pc);
	w_setsize(WS_PREV, w_handle, pc);

	/* set new sizes */
	w_setsize(WS_CURR, w_handle, pt);
	pw = w_getxptr(WS_WORK, w_handle);
	wm_calc(WC_WORK, srchwp(w_handle)->w_kind, pt->g_x, pt->g_y, pt->g_w, pt->g_h, &pw->g_x, &pw->g_y, &pw->g_w, &pw->g_h);

	/* update rectangle lists */
	everyobj(gl_wtree, ROOT, NIL, (EVERYOBJ_CALLBACK)newrect, 0, 0, MAX_DEPTH);

	/* remember oldtop & set new one */
	oldtop = gl_wtop;
	gl_wtop = W_TREE[ROOT].ob_tail;

#if 0
	/* if top has changed then change menu */
	if (gl_wtop != oldtop)
		w_menufix();
#endif

	/* set ctrl rect and mouse owner */
	w_setactive();

	if (w_walkflag)
#if BINEXACT
		return TRUE;
#else
		return;
#endif
	
	start = w_handle;		/* init. starting window */
	stop = DESK;			/* stop at the top */

	/* set flag to say we haven't moved the top window */
	moved = FALSE;

	/*
	 * if same upper left corner, and not a zero size window,
	 * then it's a size or top request; otherwise it's a move,
	 * grow, open or close
	 */
	if (/* !rc_equal(&gl_rzero, pt) && */
		pt->g_x == pc->g_x && pt->g_y == pc->g_y)
	{
		/* size or top request */
		if (pt->g_w == pc->g_w && pt->g_h == pc->g_h)
		{
			/* handle top request (sizes of prev and current are the same) */

			/* return if this isn't a top request */
			if (w_handle != W_TREE[ROOT].ob_tail || w_handle == oldtop)
#if BINEXACT
				return TRUE; /* why? */
#else
				return;
#endif

			/* draw oldtop covered with deactivated borders */
			if (oldtop != NIL)
			{
				w_cpwalk(oldtop, 0, MAX_DEPTH, 1);
				clrold = !(srchwp(oldtop)->w_flags & VF_BROKEN);
			} else
			{
				clrold = TRUE;
			}
			
			/*
			 * if oldtop isn't overlapped and new top was clear,
			 * then just draw activated borders
			 */
			if (clrold && wasclr)
			{
				w_cpwalk(gl_wtop, 0, MAX_DEPTH, 1);
#if BINEXACT
				return TRUE; /* why? */
#else
				return;
#endif
			}
		} else
		{	/* handle size request */

			/* stop before current window if shrink was a pure subset */
			if (pt->g_w <= pc->g_w && pt->g_h <= pc->g_h)
			{
				stop = w_handle;
				w_cpwalk(gl_wtop, 0, MAX_DEPTH, 1);
				moved = TRUE;
			}

			/* start at bottom if a shrink occurred */
			if (pt->g_w < pc->g_w || pt->g_h < pc->g_h)
				start = DESK;

			/* update rect. is the union of two sizes + the drop shadow */
			pc->g_w = max(pt->g_w, pc->g_w) + DROP_SIZE;
			pc->g_h = max(pt->g_h, pc->g_h) + DROP_SIZE;
		}
	} else
	{
		/* move or grow or open or close */
		if (!(pc->g_w && pc->g_h) ||
			((pt->g_x <= pc->g_x) &&
			 (pt->g_y <= pc->g_y) &&
			 (pt->g_x+pt->g_w >= pc->g_x+pc->g_w) &&
			 (pt->g_y+pt->g_h >= pc->g_y+pc->g_h)) )
		{
			/* a grow that is a superset or an open */
			rc_copy(pt, pc);
		} else
		{
			/* move, close or shrink */

			/* do a move of top guy */
			if ((pt->g_w == pc->g_w) && (pt->g_h == pc->g_h) && (gl_wtop == w_handle))
			{
				moved = w_move(w_handle, &stop, pc);
				start = DESK;
			}

			/* check for a close */
			if (!(pt->g_w && pt->g_h))
				start = DESK;

			/* handle other moves and shrinks */
			if (start != DESK)
			{
				rc_union(pt, pc);
				if (!rc_equal(pt, pc))
					start = DESK;
			}
		}
	}

	/* update gl_wtop after close, or open */
	if (oldtop != W_TREE[ROOT].ob_tail)
	{
		if (gl_wtop != NIL)
		{
			/* open or close with other windows open */
			w_getsize(WS_CURR, gl_wtop, pt);
			rc_union(pt, pc);
			/* if it was an open, then draw the old top guy covered */
			if (oldtop != NIL && oldtop != w_handle)
			{
				/* only an open if prev size was zero */
#if 0
				w_getsize(WS_PREV, gl_wtop, &pprev);
				if (rc_equal(&pprev, &gl_rzero))
#endif
					w_cpwalk(oldtop, 0, MAX_DEPTH, 1);
			}
		}
	}

#if 0
	/* account for drop shadow (BUGFIX in 2.1) */
#if DROP_SIZE
	pc->g_w += DROP_SIZE;
	pc->g_h += DROP_SIZE;
#endif
#endif

	/* update the desktop background */
	if (start == DESK)
		w_drawdesk(pc);

	/* start the redrawing	*/
	w_update(start, pc, stop, moved);
}


/*
 *	Walk down ORECT list looking for the next rect that still has
 *	size when clipped with the passed in clip rectangle
 */
/* 306de: 00e22404 */
LINEF_STATIC VOID w_owns(P(int16_t) w_handle, P(ORECT *) po, P(GRECT *) pt, P(GRECT *) poutwds)
PP(int16_t w_handle;)
PP(register ORECT *po;)
PP(GRECT *pt;)
PP(register GRECT *poutwds;)
{
	while (po)
	{
		rc_copy(&po->o_gr, poutwds);
		srchwp(w_handle)->w_rnext = po = po->o_link;
		if (rc_intersect(pt, poutwds) /* &&
			rc_intersect(&gl_rfull, poutwds) */)
			return;
	}

	poutwds->g_w = poutwds->g_h = 0;
}


/*
 *	Walk down ORECT list and accumulate the union of all the owner rectangles
 */
/* 306de: 00e22464 */
LINEF_STATIC BOOLEAN w_union(P(ORECT *) po, P(GRECT *) pt)
PP(register ORECT *po;)
PP(register GRECT *pt;)
{
	if (!po)
		return FALSE;

	rc_copy(&po->o_gr, pt);
	po = po->o_link;
	while (po)
	{
		rc_union(&po->o_gr, pt);
		po = po->o_link;
	}

	return TRUE;
}


/*
 *  Start the window manager up by initializing internal variables
 */
/* 306de: 00e224ae */
BOOLEAN wm_start(NOTHING)
{
	register int16_t i;
	register THEGLO *DGLO;
	register ORECT *po;
	register LPTREE tree;

	DGLO = &D;
	
	/* init owner rectangles */
	/* or_start(): */
	rul = NULL;
	for (i = 0; i < NUM_ORECT; i++)
	{
		DGLO->g_olist[i].o_link = rul;
		rul = &DGLO->g_olist[i];
	}
	
	/* init window extent objects */
	memset(W_TREE, 0, NUM_MWIN * sizeof(OBJECT));
	w_nilit(NUM_MWIN, &W_TREE[ROOT]);
	
	for (i = 0; i < NUM_MWIN; i++)
	{
		DGLO->w_win[i].w_flags = 0x0;
		DGLO->w_win[i].w_rlist = NULL;
		W_TREE[i].ob_type = G_IBOX;
	}
	W_TREE[ROOT].ob_type = G_BOX;
	tree = ad_stdesk;
	W_TREE[ROOT].ob_spec = LLGET(OB_SPEC(ROOT));

	/* init window element objects */
	memset(W_ACTIVE, 0, MAXOBJ * sizeof(OBJECT));
	w_nilit(MAXOBJ, W_ACTIVE);
	for (i = 0; i < MAXOBJ; i++)
	{
		W_ACTIVE[i].ob_type = gl_watype[i];
		W_ACTIVE[i].ob_spec = gl_waspec[i];
	}
	W_ACTIVE[ROOT].ob_state = SHADOWED;

	/* init rectangle list */
	DGLO->w_win[0].w_rlist = po = get_orect();
	po->o_link = NULL;
	po->o_gr.g_x = 0;
	po->o_gr.g_y = gl_hbox;
	po->o_gr.g_w = gl_width;
	po->o_gr.g_h = gl_height - gl_hbox;
	w_setup(rlr, DESK, NONE);
	w_setsize(WS_CURR, DESK, &gl_rscreen);
	w_setsize(WS_PREV, DESK, &gl_rscreen);
	w_setsize(WS_FULL, DESK, &gl_rfull);
	w_setsize(WS_WORK, DESK, &gl_rfull);

	/* init global variables */
	gl_wtop = NIL;
	gl_wtree = (LPTREE)&W_TREE[ROOT];
	gl_awind = W_ACTIVE;
	gl_newdesk = 0;
	w_walkflag = FALSE;
	
	/* init tedinfo parts of title and info lines */
	movs(sizeof(TEDINFO), &gl_asamp, &gl_aname);
	movs(sizeof(TEDINFO), &gl_asamp, &gl_ainfo);
	gl_aname.te_just = TE_CNTR;
	W_ACTIVE[W_NAME].ob_spec = (intptr_t)&gl_aname;
	W_ACTIVE[W_INFO].ob_spec = (intptr_t)&gl_ainfo;
	
	return TRUE;
}


/*
 * AES #100 - wind_create - Initializes a new window 
 *
 * wm_create() - allocates the application's full-size window and 
 *		 returns the window's handle.
 *	       - returns FAILURE (-1) if no handle is available or
 *		 if an error occurred.
 */
/* 206us: 00e1ec82 */
/* 306de: 00e22742 */
/* 206x: 00e1e3a8 */
int16_t wm_create(P(uint16_t) kind, P(GRECT *) rect)
PP(uint16_t kind;)						/* kind of window to be created */
PP(GRECT *rect;)						/* x, y, width and height of full size window */
{
	register int16_t i;

#if BINEXACT
	/* BUG: condition should test for NUM_WIN first */
	for (i = 0; (D.w_win[i].w_flags & VF_INUSE) && (i < NUM_WIN); i++)
		;
#else
	for (i = 0; (i < NUM_WIN) && (D.w_win[i].w_flags & VF_INUSE); i++)
		;
#endif
	if (i < NUM_WIN)
	{
		w_setup(rlr, i, kind);
		w_setsize(WS_CURR, i, &gl_rzero);
		w_setsize(WS_PREV, i, &gl_rzero);
		w_setsize(WS_FULL, i, rect);
		return i;
	}

	return -1;
}


/*
 *	Opens or closes a window
 */
/* 306de: 00e227c6 */
static VOID wm_opcl(P(int16_t) wh, P(GRECT *) pt, P(BOOLEAN) isadd)
PP(register int16_t wh;)
PP(register GRECT *pt;)
PP(BOOLEAN isadd;)
{
	GRECT t;

	rc_copy(pt, &t);
	wm_update(BEG_UPDATE);
	if (isadd)
	{
#if 0
		D.w_win[wh].w_flags |= VF_INTREE;
#endif
		w_obadd(&W_TREE[ROOT], ROOT, wh);
	} else
	{
		ob_delete(gl_wtree, wh);
#if 0
		D.w_win[wh].w_flags &= ~VF_INTREE;
#endif
	}
	draw_change(wh, &t);
	if (isadd)
		w_setsize(WS_PREV, wh, pt);
	wm_update(END_UPDATE);
}



/*
 * AES #101 - wind_open - Open window
 *
 * wm_open() - opens a window in its given size and location.
 *	     - returns FALSE (0) if given handle is invalid,
 *	       or if window has already been opened.
 *	     - returns TRUE (1) if everything is fine.
 */
/* 306de: 00e22844 */
/* BUG: does not return anything */
VOID wm_open(P(int16_t) w_handle, P(GRECT *) rect)
PP(int16_t w_handle;)					/* handle of window to be opened */
PP(GRECT *rect;)						/* x, y, width and height of opened window */
{
	wm_opcl(w_handle, rect, TRUE);
}


/*
 * AES #102 - wind_close - Close window
 *
 * wm_close() - closes an opened window
 *	      - returns FALSE (0) if given handle is invalid,
 *	        or if window has already been closed.
 *	      - returns TRUE (1) if everything is fine.
 *
 */
/* 306de: 00e2285e */
/* BUG: does not return anything */
VOID wm_close(P(int16_t) w_handle)
PP(int16_t w_handle;)							/* handle of window to be closed */
{
	wm_opcl(w_handle, &gl_rzero, FALSE);
}


/*
 * AES #103 - wind_delete - Delete window
 *
 * wm_delete() - closes the window if it is not already closed,
 *		 and frees the window structure.
 *	       - returns FALSE (0) if given handle is invalid.
 *	       - returns TRUE (1) if everything is fine.
 *
 */
/* 306de: 00e22878 */
/* BUG: does not return anything */
VOID wm_delete(P(int16_t) w_handle)
PP(int16_t w_handle;)							/* handle of window to be deleted */
{
#if BINEXACT
	D.w_win[w_handle].w_flags &= ~VF_INUSE;
#else
	newrect(gl_wtree, w_handle, 0, 0);		/* give back recs. */
	w_setsize(WS_CURR, w_handle, &gl_rscreen);
	w_setsize(WS_PREV, w_handle, &gl_rscreen);
	w_setsize(WS_FULL, w_handle, &gl_rfull);
	w_setsize(WS_WORK, w_handle, &gl_rfull);
	D.w_win[w_handle].w_flags = 0x0;		/* &= ~VF_INUSE; */
	D.w_win[w_handle].w_owner = NULL;
#endif
}


/*
 * AES #105 - wind_get - Obtains various properties of a window.
 *
 * wm_get() - returns information of window in the given array
 *	    - returns FALSE (0) if given handle is invalid
 *	    - returns TRUE (1) if everything is fine
 *
 */
/* 306de: 00e22896 */
VOID wm_get(P(int16_t) w_handle, P(int16_t) w_field, P(int16_t *)poutwds)
PP(register int16_t w_handle;)						/* window handle */
PP(int16_t w_field;)								/* flag to identify what info to be returned */
PP(register int16_t *poutwds;)							/* return values */
{
	register int16_t which;
	GRECT t;
	register ORECT *po;
	register WINDOW *pwin;
	
	pwin = srchwp(w_handle);
	which = -1;
	switch (w_field)
	{
	case WF_WORKXYWH:
		which = WS_WORK;
		break;
	case WF_CURRXYWH:
		which = WS_CURR;
		break;
	case WF_PREVXYWH:
		which = WS_PREV;
		break;
	case WF_FULLXYWH:
		which = WS_FULL;
		break;
	case WF_HSLIDE:
		poutwds[0] = pwin->w_hslide;
		break;
	case WF_VSLIDE:
		poutwds[0] = pwin->w_vslide;
		break;
	case WF_HSLSIZE:
		poutwds[0] = pwin->w_hslsiz;
		break;
	case WF_VSLSIZE:
		poutwds[0] = pwin->w_vslsiz;
		break;
	case WF_TOP:
		poutwds[0] = /*w_top()*/ gl_wtop == NIL ? DESK : gl_wtop;
		break;
	case WF_FIRSTXYWH:
	case WF_NEXTXYWH:
		w_getsize(WS_WORK, w_handle, &t);
		po = w_field == WF_FIRSTXYWH ? pwin->w_rlist : pwin->w_rnext;
		w_owns(w_handle, po, &t, (GRECT *)poutwds);
		break;
	case WF_SCREEN:
		gsx_mret((VOIDPTR *)poutwds, (int32_t *)(poutwds + 2));
		break;
#if 0 /* PC-GEM only; conflicts with WF_COLOR */
    case WF_TATTRB:
        poutwds[0] = D.w_win[w_handle].w_flags >> 3;
        break;
#endif
	case WF_NEWDESK:
		if (gl_newdesk)
		{
			*((LPTREE *)poutwds) = gl_newdesk;
			poutwds[2] = gl_newroot;
		} else
		{
			*((LPTREE *)poutwds) = gl_wtree;
			poutwds[2] = ROOT;
		}
#if !BINEXACT
		break; /* somehow not removed by optimize */
#endif
	}
	/* BUG: WF_COLOR/WF_DCOLOR not supported */

	if (which != -1)
		w_getsize(which, w_handle, (GRECT *)poutwds);
}


#if 0
static int16_t wm_gsizes(int16_t w_field, int16_t *psl, int16_t *psz)
{
	if (w_field == WF_HSLSIZ || w_field == WF_HSLIDE)
	{
		*psl = W_ACTIVE[W_HELEV].ob_x;
		*psz = W_ACTIVE[W_HELEV].ob_width;
		return W_HBAR;
	}

	if (w_field == WF_VSLSIZ || w_field == WF_VSLIDE)
	{
		*psl = W_ACTIVE[W_VELEV].ob_y;
		*psz = W_ACTIVE[W_VELEV].ob_height;
		return W_VBAR;
	}

	return 0;
}


/*
 *	Routine to top a window and then make the right redraws happen
 */
static void wm_mktop(int16_t w_handle)
{
	GRECT t, p;

	if (w_handle != gl_wtop)
	{
		ob_order(gl_wtree, w_handle, NIL);
		w_getsize(WS_PREV, w_handle, &p);
		w_getsize(WS_CURR, w_handle, &t);
		draw_change(w_handle, &t);
		w_setsize(WS_PREV, w_handle, &p);
	}
}
#endif


/*
 * AES #106 - wind_set - Alter various window attributes.
 *
 * wm_set() - changes information of a window
 *	    - returns FALSE (0) if given handle is invalid
 *	    - returns TRUE (1) if everything is fine
 *
 */
/* 306de: 00e229b4 */
/* BUG: does not return anything */
VOID wm_set(P(int16_t) w_handle, P(int16_t) w_field, P(int16_t *) pinwds)
PP(register int16_t w_handle;)						/* window handle */
PP(register int16_t w_field;)						/* flag to identify what info to be changed */
PP(register int16_t *pinwds;)							/* values to change to */
{
	int i;
	int16_t which;
	register int16_t osl, osz;
	int16_t blen, minw, gadget;
	GRECT t;
	register WINDOW *pwin;

	UNUSED(i);
	
	pwin = &D.w_win[w_handle];
	which = -1;
	
	wm_update(BEG_UPDATE);		/* grab the window sync */
	
	switch (w_field)
	{
	case WF_NAME:
		which = W_NAME;
		break;
	case WF_INFO:
		which = W_INFO;
		break;
#if 0
	case WF_SIZTOP: /* PC-GEM only; conflicts with WF_DCOLOR */
		ob_order(gl_wtree, w_handle, NIL);
		/* fall thru	*/
#endif
	case WF_CURRXYWH:
		draw_change(w_handle, (GRECT *)pinwds);
		break;
	case WF_TOP:
		if (w_handle != gl_wtop)
		{
			wasclr = !(pwin->w_flags & VF_BROKEN);
			ob_order(gl_wtree, w_handle, NIL);
			w_getsize(WS_CURR, w_handle, &t);
			draw_change(w_handle, &t);
		}
		break;
	case WF_RESVD:
		if (w_handle)
		{
			w_walkflag = TRUE;
		} else
		{
			w_walkflag = FALSE;
			w_drawdesk((GRECT *)pinwds);
			w_update(DESK, (GRECT *)pinwds, DESK, FALSE);
		}
		break;
	case WF_NEWDESK:
		/* BUG: should check that handle really was desktop */
		gl_newdesk = *(LPTREE *) pinwds;
		gl_newroot = pinwds[2];
		break;
	case WF_HSLSIZE:
	case WF_VSLSIZE:
	case WF_HSLIDE:
	case WF_VSLIDE:
		pinwds[0] = max(-1, pinwds[0]);
		pinwds[0] = min(1000, pinwds[0]);
		if (w_field == WF_HSLSIZE || w_field == WF_HSLIDE)
		{
			if (w_field == WF_HSLSIZE)
			{
				osz = pwin->w_hslsiz = pinwds[0];
				osl = pwin->w_hslide;
			} else
			{
				osl = pwin->w_hslide = pinwds[0];
				osz = pwin->w_hslsiz;
			}
			blen = W_ACTIVE[W_HSLIDE].ob_width;
			gadget = W_HSLIDE;
			minw = gl_wbox;
		} else
		{
			if (w_field == WF_VSLSIZE)
			{
				osz = pwin->w_vslsiz = pinwds[0];
				osl = pwin->w_vslide;
			} else
			{
				osl = pwin->w_vslide = pinwds[0];
				osz = pwin->w_vslsiz;
			}
			blen = W_ACTIVE[W_VSLIDE].ob_height;
			gadget = W_VSLIDE;
			minw = gl_hbox;
		}
		if (w_handle == gl_wtop)
			w_cpwalk(w_handle, gadget, MAX_DEPTH, TRUE);
		UNUSED(osz);
		UNUSED(osl);
		UNUSED(blen);
		UNUSED(minw);
		break;
#if 0 /* PC-GEM only; conflicts with WF_COLOR */
	case WF_TATTRB:
		if (pinwds[0] & WA_SUBWIN)
			pwin->w_flags |= VF_SUBWIN;
		else
			pwin->w_flags &= ~VF_SUBWIN;
		if (pinwds[0] & WA_KEEPWIN)
			pwin->w_flags |= VF_KEEPWIN;
		else
			pwin->w_flags &= ~VF_KEEPWIN;
		break;
#endif
	}

	if (which != -1)
#if BINEXACT
		w_strchg(w_handle, which, pinwds[0], pinwds[1]);
#else
		w_strchg(w_handle, which, *(intptr_t *)pinwds);
#endif

	wm_update(END_UPDATE);		/* give up the sync */
}


/*
 * AES #106 - wind_find - Find the ID of a window at the given coordinates.
 *
 * wm_find() - Given an x and y location, will figure out which window the mouse is in
 *
 */
/* 306de: 00e22c02 */
int16_t wm_find(P(int) mx, P(int) my)
PP(int mx;)									/* mouse's x position */
PP(int my;)									/* mouse's y position */
{
	return ob_find(gl_wtree, ROOT, 2, mx, my);
}


/*
 * AES #107 - wind_update - Blocks or releases screen operations.
 *
 * wm_update() - locks or unlocks the current state of the window 
 *		 tree while an application is responding to a 
 *		 window update message in his message pipe or is 
 *		 making some other direct screen update based on
 *		 his current rectangle list.
 *
 */
/* BUG: does not return anything */
/* 306de: 00e22c24 */
#if (AESVERSION >= 0x330) | !BINEXACT
int16_t wm_update(P(int) beg_update)
#else
VOID wm_update(P(int) beg_update)
#endif
PP(register int beg_update;)								/* flag for the call's function */
{
	if (beg_update < 2)
	{
		if (beg_update)
		{
			if (!tak_flag(&wind_spb))
				ev_block(AMUTEX, (intptr_t)ad_windspb);
		} else
		{
			unsync(&wind_spb);
		}
	} else
	{
		beg_update -= 2;
		take_ownership(beg_update);
	}
#if (AESVERSION >= 0x330) | !BINEXACT
	return TRUE;
#endif
}


/*
 * AES #108 - wind_calc - Calculates the limits or the total space requirement of a window 
 *
 *	Given a width and height of a Work Area and the Kind of window desired,
 *	calculate the required window size including the Border Area.
 *	OR
 *	Given the width and height of a window including the Border Area and the
 *	Kind of window desired, calculate the result size of the window Work Area.
 */
/* BUG: does not return anything */
/* 306de: 00e22c80 */
VOID wm_calc(P(int16_t) wtype, P(int16_t) kind, P(int16_t) ix, P(int16_t) iy, P(int16_t) iw, P(int16_t) ih, P(int16_t *) ox, P(int16_t *) oy, P(int16_t *) ow, P(int16_t *) oh)
PP(int16_t wtype;)								/* the type of calculation to perform */
PP(register int16_t kind;)						/* components present in the window */
PP(int16_t ix;)									/* input x-coordinate of window */
PP(int16_t iy;)									/* input y-coordinate of window */
PP(int16_t iw;)									/* input width of window */
PP(int16_t ih;)									/* input height of window */
PP(int16_t *ox;)								/* output x-coordinate of work/border area */
PP(int16_t *oy;)								/* output y-coordinate of work/border area */
PP(int16_t *ow;)								/* output width of work/border area */
PP(int16_t *oh;)								/* output height of work/border area */
{
	register int16_t tb, bb, lb, rb;

	tb = bb = rb = lb = 1;

	if (kind & (NAME | CLOSER | FULLER))
		tb += gl_hbox - 1;

	if (kind & INFO)
		tb += gl_hbox - 1;

	if (kind & (UPARROW | DNARROW | VSLIDE | SIZER))
		rb += gl_wbox - 1;

	if (kind & (LFARROW | RTARROW | HSLIDE | SIZER))
		bb += gl_hbox - 1;

	/* negate values to calc Border Area */
	if (wtype == WC_BORDER)
	{
		lb = -lb;
		tb = -tb;
		rb = -rb;
		bb = -bb;
	}

	*ox = ix + lb;
	*oy = iy + tb;
	*ow = iw - lb - rb;
	*oh = ih - tb - bb;
}


/*
 * AES #109 - wind_new - Close all windows.
 *
 * wm_new() - Delete all the window structures and clean 
 *	      up the window update semaphore.  This 
 *	      routine is very critical, so don't call 
 *	      it when you are not sure.  You must call 
 *	      this guy right after you return from the 
 *	      child process.	Only at this moment the 
 *	      system can be able to recover itself.
 *
 * Comments:
 *	(Jul 23 91 ml.) This may need to be modified for
 * future multitasking system.
 *	
 */
/* 306de: 00e22d36 */
#if !BINEXACT
int16_t wm_new(NOTHING)
#else
VOID wm_new(NOTHING)
#endif
{
#if 0
	register int wh;

	/* Remove locks: */
	while (ml_ocnt > 0)
		wm_update(END_MCTRL);
	while (wind_spb.sy_tas > 0)
		wm_update(END_UPDATE);

	/* Delete windows: */
	for (wh = 1; wh < NUM_WIN; wh++)
	{
		if (D.w_win[wh].w_flags & VF_INTREE)
			wm_close(wh);
		if (D.w_win[wh].w_flags & VF_INUSE)
			wm_delete(wh);
	}
#else
	register SPB *spb;
	
	wm_start();
	ml_ocnt = 0;
	gl_mntree = 0;
	gl_mowner = ctl_pd;
	spb = ad_windspb;
	if (spb->sy_tas)
	{
		while (spb->sy_tas)
		{
			unsync(spb);
		}
	}
#endif
#if !BINEXACT
	return TRUE;
#endif
}
