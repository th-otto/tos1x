/*      DESKTOP.C       05/04/84 - 09/05/85     Lee Lorenzen            */
/*      for 3.0         3/12/86  - 1/29/87      MDF                     */
/*
 *       Copyright 1999, Caldera Thin Clients, Inc.                      
 *       This software is licenced under the GNU Public License.         
 *       Please see LICENSE.TXT for further information.                 
 *                                                                       
 *                  Historical Copyright                                 
 *       -------------------------------------------------------------
 *       GEM Desktop                                       Version 2.3
 *       Serial No.  XXXX-0000-654321              All Rights Reserved
 *       Copyright (C) 1987                      Digital Research Inc.
 *       -------------------------------------------------------------
 */


#include "desktop.h"
#include "taddr.h"

THEDSK *thedesk;
int16_t gl_apid;
int16_t pglobal[15];

static int8_t const ILL_HDSK[] = { FORMITEM, OUTPITEM, IAPPITEM, 0 };
static int8_t const ILL_ITEM[] = { L2ITEM, L3ITEM, L4ITEM, L5ITEM, 0 };
static int8_t const ILL_FILE[] = { FORMITEM, IDSKITEM, 0 };
static int8_t const ILL_DOCU[] = { FORMITEM, IDSKITEM, IAPPITEM, 0 };
static int8_t const ILL_FOLD[] = { OUTPITEM, FORMITEM, IDSKITEM, IAPPITEM, 0 };
static int8_t const ILL_FDSK[] = { OUTPITEM, IAPPITEM, 0 };
static int8_t const ILL_TRASH[] = { OPENITEM, OUTPITEM, FORMITEM, IDSKITEM, IAPPITEM, IDSKITEM, 0 };
static int8_t const ILL_NOSEL[] = { OPENITEM, SHOWITEM, FORMITEM, IDSKITEM, IAPPITEM, 0 };
static int8_t const ILL_NOTOP[] = { NEWFITEM, CLSFITEM, CLSWITEM, 0 };
static int8_t const ILL_DESKTOP[] = { NEWFITEM, CLSFITEM, CLSWITEM, ICONITEM, TEXTITEM, NAMEITEM, DATEITEM, SIZEITEM, TYPEITEM, 0 };
static int8_t const ILL_YSEL[] = { OPENITEM, IDSKITEM, FORMITEM, SHOWITEM, 0 };
static int8_t const ILL_CART[] = { SHOWITEM, NEWFITEM, FORMITEM, OUTPITEM, IAPPITEM, 0 };
#if TOSVERSION >= 0x104
static int8_t const ILL_NOCART[] = { NEWFITEM, 0 };
static int16_t const top_items[] = { ABOUITEM, OPENITEM, ICONITEM, IDSKITEM, 0 };
#endif


#undef Blitmode
#define Blitmode(a) trp14(64, a)




LINEF_STATIC VOID men_list PROTO((LPTREE mlist, const int8_t *dlist, BOOLEAN enable));


/*
 *	Turn on the hour glass to signify a wait and turn it off when were
 *	done.
 */
/* 104de: 00fdb032 */
/* 106de: 00e1c1ae */
/* 100de: 00fe1082 */
VOID desk_wait(P(BOOLEAN) turnon)
PP(BOOLEAN turnon;)
{
	graf_mouse(turnon ? HOURGLASS : ARROW, NULL);
}


/*
 *	Given an icon index, go find the ANODE which it represents
 */
/* 104de: 00fdb04c */
/* 106de: 00e1c1ce */
/* 100de: 00fe109c */
APP *i_find(P(int16_t) wh, P(int16_t) item, P(FNODE **)ppf, P(BOOLEAN *)pisapp)
PP(register int16_t wh;)
PP(register int16_t item;)
PP(FNODE **ppf;)
PP(register BOOLEAN *pisapp;)
{
	register APP *pa;
	char *pname;
	DESKWIN *pw;
	register FNODE *pf;
	
	pa = NULL;
	pf = NULL;

	if (!wh)							/* On desktop? */
	{
		pname = win_iname(item);
		pa = app_afind(TRUE, -1, item, pname, pisapp);
	} else
	{
		pw = win_find(wh);
		/*
		 *	Find the file node that matches a particular object id.
		 */
		pf = fpd_ofind(pw->w_path->p_flist, item);

		if (pf)
		{
			pname = pf->f_name;
			pa = app_afind(FALSE, pf->f_attr & FA_DIREC ? AT_ISFOLD : AT_ISFILE, -1, pname, pisapp);
		}
	}
	*ppf = pf;
	return pa;
}


/* 104de: 00fdb152 */
/* 106de: 00e1c2fc */
/* 100de: 00fe1134 */
/*
 *	Enable/Disable the menu items in dlist
 */
LINEF_STATIC VOID men_list(P(LPTREE) mlist, P(const int8_t *)dlist, P(BOOLEAN) enable)
PP(register LPTREE mlist;)
PP(register const int8_t *dlist;)
PP(register BOOLEAN enable;)
{
	while (*dlist)
	{
		menu_ienable((OBJECT *)mlist, *dlist++, enable);
	}
}


/*
 * 	Based on current selected icons, figure out which
 *	menu items should be selected (deselected)
 */
/* 104de: 00fdb17c */
/* 106de: 00e1c332 */
/* 100de: 00fe115e */
VOID men_update(P(LPTREE) tree)
PP(register LPTREE tree;)
{
	register int16_t item;
	register int16_t nsel;
	BOOLEAN isapp;
	FNODE *pjunk;
	const int8_t *pvalue;
	register APP *appl;
	register int unused;
	
	UNUSED(unused);
	/* enable all items */
	for (item = OPENITEM; item <= PREFITEM; item++)
		menu_ienable((OBJECT *)tree, item, TRUE);
	men_list(tree, ILL_ITEM, FALSE);

	nsel = 0;
	for (item = 0; (item = win_isel(thedesk->g_screen, thedesk->g_croot, item)); nsel++)
	{
		appl = i_find(thedesk->g_cwin, item, &pjunk, &isapp);
		switch (appl->a_type)
		{
#ifdef __GNUC__
		default:
			__builtin_unreachable(); /* silence compiler */
#endif
		case AT_ISFILE:
			pvalue = isapp ? ILL_FILE : ILL_DOCU;
			break;
		case AT_ISFOLD:
			pvalue = ILL_FOLD;
			break;
		case AT_ISCART:
			pvalue = ILL_CART;
			break;
		case AT_ISDISK:
			pvalue = (char)appl->a_char > 'B' ? ILL_HDSK : ILL_FDSK;
			break;
		case AT_ISTRSH:
			pvalue = ILL_TRASH;
			/* break; */
		}
		men_list(tree, pvalue, FALSE);	/* disable certain items */
	}

	pvalue = win_ontop() ? ILL_DESKTOP : ILL_NOTOP;
	men_list(tree, pvalue, pvalue != ILL_DESKTOP ? FALSE : TRUE);

#if TOSVERSION >= 0x104
	{
		BOOLEAN iscart;
		DESKWIN *pw;
		pw = win_ontop();
		if (pw != NULL)
		{
			if (streq(pw->w_name, thedesk->p_cartname))
				iscart = FALSE;
			else
				iscart = TRUE;
			men_list(tree, ILL_NOCART, iscart);
		}
	}
#endif
	
	if (nsel != 1)
	{
		pvalue = nsel ? ILL_YSEL : ILL_NOSEL;
		men_list(tree, pvalue, FALSE);
	}
}


/* 100de: 00fe12b4 */
LINEF_STATIC BOOLEAN do_deskmenu(P(int16_t) item)
PP(register int16_t item;)
{
	register BOOLEAN done;
	register LPTREE tree;

	done = FALSE;
	if (item == ABOUITEM)
	{
		tree = (LPTREE)thedesk->g_atree[ADDINFO];
		/* draw the form */
		inf_show((OBJECT *)tree, ROOT);
		LWSET(OB_STATE(DEOK), NORMAL);
	}
	return done;
}


/* 104de: 00fdb318 */
/* 106de: 00e1c4f4 */
/* 100de: 00fe12e8 */
BOOLEAN do_filemenu(P(int16_t) item)
PP(int16_t item;)
{
	register BOOLEAN done;
	register int16_t curr;
	int16_t savwin;
	int16_t junk;
	int16_t first;
	register DESKWIN *pw;
	FNODE *pf;
	register APP *pa;
	register THEDSK *d;
	register int unused1;
	register int unused2;

	UNUSED(unused1);
	UNUSED(unused2);
	UNUSED(pa);
	UNUSED(pf);
	UNUSED(first);
	UNUSED(junk);
	UNUSED(savwin);
	d = thedesk;
	done = FALSE;
	pw = win_ontop();					/* DESKTOP v1.2  win_find(G.g_cwin); */

	curr = win_isel(d->g_screen, d->g_croot, 0);
	switch (item)
	{
	case OPENITEM:
		if (curr)
			done = open_item(curr);
		break;
	case SHOWITEM:
		if (curr)
			done = show_item(curr);
		break;
	case NEWFITEM:
		if (pw)
		{
			newfolder(pw);
			desk_clear(0);
		}
		break;
	case CLSFITEM:
		if (pw)
		{
			desk_clear(d->g_cwin);
			close_window(pw, FALSE);
		}
		break;
	case CLSWITEM:
		if (pw)
		{
			desk_clear(d->g_cwin);
			close_window(pw, TRUE);
		}
		break;
	case FORMITEM:
		if (curr)
			done = do_format(curr);
		break;
	case OUTPITEM:
		/* break */
		;
	}
	return done;
}


/* 104de: 00fdb3bc */
/* 106de: 00e1c5c0 */
/* 100de: 00fe1392 */
BOOLEAN do_viewmenu(P(int16_t) item)
PP(register int16_t item;)
{
	register BOOLEAN done;
	register short newview;
	register short newsort;
	register THEDSK *d;
	register int unused2;
	
	UNUSED(unused2);
	d = thedesk;
	done = FALSE;
	newview = d->g_iview;
	newsort = d->g_isort;
	switch (item)
	{
	case ICONITEM:
		newview = V_ICON;
		break;
	case TEXTITEM:
		newview = V_TEXT;
		break;
	case NAMEITEM:
		newsort = S_NAME;
		break;
	case DATEITEM:
		newsort = S_DATE;
		break;
	case SIZEITEM:
		newsort = S_SIZE;
		break;
	case TYPEITEM:
		newsort = S_TYPE;
		/* break; */
	}
	if (newview != d->g_iview || newsort != d->g_isort)
	{
		if (newview != d->g_iview)
		{
			menu_icheck(d->g_atree[ADMENU], d->g_cviewitem, FALSE);
			d->g_cviewitem = item;
			menu_icheck(d->g_atree[ADMENU], item, TRUE);
		}
		if (newsort != d->g_isort)
		{
			menu_icheck(d->g_atree[ADMENU], d->g_csortitem, FALSE);
			d->g_csortitem = item;
			menu_icheck(d->g_atree[ADMENU], item, TRUE);
		}
		win_view(newview, newsort);
	}
	return done;
}


/* 104de: 00fdb470 */
/* 106de: 00e1c6a0 */
/* 100de: 00fe1446 */
BOOLEAN do_optnmenu(P(int16_t) item)
PP(int16_t item;)
{
	register APP *pa;
	register BOOLEAN done;
	register BOOLEAN rebld;
	register int16_t curr;
	register int unused1;
	register int unused2;
	int16_t x, y, w, h;
	FNODE *pf;
	BOOLEAN isapp;
	register THEDSK *d;
	
#if !BINEXACT
	/* BUG: missing */
	pa = NULL;
	pf = NULL;
	isapp = FALSE;
#endif
	UNUSED(unused1);
	UNUSED(unused2);
	d = thedesk;
	done = FALSE;
	rebld = FALSE;

	get_xywh(d->g_screen, d->g_croot, &x, &y, &w, &h);
	curr = win_isel(d->g_screen, d->g_croot, 0);
	if (curr)
		pa = i_find(d->g_cwin, curr, &pf, &isapp);

	switch (item)
	{
	case IDSKITEM:
		if (pa)
			rebld = ins_disk(pa);
		if (rebld)
		{
			app_blddesk();
			wind_get(0, WF_WORKXYWH, &x, &y, &w, &h);
			do_wredraw(0, x, y, w, h);
		}
		break;
	case IAPPITEM:
		if (pa && isapp)
			rebld = ins_app(pf->f_name, pa);
		if (rebld)
		{
#if TOSVERSION >= 0x104
			hd_keybd(0x011b);
#else
			desk_wait(TRUE);
			win_bdall();
			win_shwall();
			desk_wait(FALSE);
#endif
		}
		break;
	case PREFITEM:
		done = desk_pref();
		break;
	case SAVEITEM:
#if TOSVERSION >= 0x104
		if (fun_alert(1, SAVETOP, NULL) == 1)
#endif
		{
			desk_wait(TRUE);
			cnx_put();
			save_inf(TRUE);
			desk_wait(FALSE);
		}
		break;
	case PRINTITEM:
#if TOSVERSION >= 0x104
		if (fun_alert(1, PRINTTOP, NULL) == 1)
#endif
		{
			desk_wait(TRUE);
			av_hardcopy();
			desk_wait(FALSE);
		}
#if TOSVERSION >= 0x104
		break;
	case BITBLT:
		Blitmode(d->s_bitblt ? 0 : 1);
		d->s_bitblt = !d->s_bitblt;
		menu_icheck(d->g_atree[ADMENU], BITBLT, d->s_bitblt);
		/* BUG: not checked whether call enabled blitter */
		/* BUG: BITBLT item not disabled if blitter not present */
		break;
#endif
	}
	return done;
}


/* 104de: 00fdb5ea */
/* 106de: 00e1c868 */
/* 100de: 00fe1574 */
BOOLEAN hd_button(P(int16_t) clicks, P(int16_t) mx, P(int16_t) my, P(int16_t) bstate, P(int16_t) keystate)
PP(int16_t clicks;)
PP(int16_t mx;)
PP(int16_t my;)
PP(int16_t bstate;)
PP(int16_t keystate;)
{
	BOOLEAN done;
	int16_t junk;
	GRECT c;
	register int16_t wh;
	register int16_t root;
	int16_t dobj;
	register int unused;
	register int16_t dest_wh;
	register DESKWIN *wn;
	register THEDSK *d;
	register GRECT *pc;
	
	UNUSED(unused);
	d = thedesk;
	pc = &c;
	done = FALSE;

	wh = wind_find(mx, my);

	if (wh != d->g_cwin)
		desk_clear(d->g_cwin);

	desk_verify(wh, FALSE);

	d->g_wlastsel = wh;
	wind_get(wh, WF_WORKXYWH, &pc->g_x, &pc->g_y, &pc->g_w, &pc->g_h);

	if (clicks == 1)
	{
		act_bsclick(d->g_cwin, d->g_pscreen, d->g_croot, mx, my, keystate, pc, FALSE);
		graf_mkstate(&junk, &junk, &bstate, &junk);
		if (bstate & 1)
		{
			dest_wh = act_bdown(d->g_cwin, d->g_pscreen, d->g_croot, mx, my, keystate, pc, &dobj);

			if (dest_wh != NIL)
			{
				if (dest_wh != 0)
				{
					wn = win_find(dest_wh);
					root = wn->w_root;
				} else
				{
					root = DROOT;
				}
				done = fun_ddrag(wh, dest_wh, root, dobj);
			}
		}
	} else
	{
		act_bsclick(d->g_cwin, d->g_pscreen, d->g_croot, mx, my, keystate, &c, TRUE);
		done = do_filemenu(OPENITEM);
	}
	men_update((LPTREE)d->g_atree[ADMENU]);
	return done;
}


/* 104de: 00fdb6f6 */
/* 106de: 00e1c9a8 */
/* 100de: 00fe16b8 */
BOOLEAN hd_keybd(P(uint16_t) key)
PP(uint16_t key;)
{
	BOOLEAN changed;
	DESKWIN *pw;
	
	changed = FALSE;
	if (key == 0x011b)
	{
		pw = win_ontop();
		if (pw)
		{
#if TOSVERSION >= 0x104

			if (!streq(thedesk->p_cartname, pw->w_name))
			{
				if (pro_chroot(pw->w_path->p_spec[0]))
				{
					desk_wait(TRUE);
					changed = mediach(pw->w_path->p_spec[0] - 'A');
					desk_wait(FALSE);
					if (changed)
						return FALSE;
					up_1win(pw);
				}
			} else
#endif
			{
				up_1win(pw);
			}
		}
	}
	return changed;
}


/* 104de: 00fdb774 */
/* 106de: 00e1ca44 */
/* 100de: 00fe16e0 */
BOOLEAN hd_menu(P(int16_t) title, P(int16_t) item)
PP(register int16_t title;)
PP(register int16_t item;)
{
	register BOOLEAN done;
	register THEDSK *d;
	
	d = thedesk;
	done = FALSE;
	switch (title)
	{
	case DESKMENU:
#if TOSVERSION >= 0x104
		if (item == ABOUITEM)
		{
			/*
			 * rb_start/rb_stop:
			 * start/stop the infamous RAINBOW animation
			 */
			rb_start();
			fmdodraw(thedesk->g_atree[ADDINFO], DEOK);
			rb_stop();
		}
#else
		done = do_deskmenu(item);
#endif
		break;
	case FILEMENU:
		done = do_filemenu(item);
		break;
	case VIEWMENU:
		done = do_viewmenu(item);
		/* for every window go sort again and rebuild views */
		desk_wait(TRUE);
#if TOSVERSION >= 0x104
		{
			register int i;
			for (i = 0; i < NUM_WNODES; i++)
			{
				if (g_wlist[i].w_id != 0)
				{
					g_wlist[i].w_path->p_flist = pn_sort(-1, g_wlist[i].w_path->p_flist);
				}
			}
		}
		win_bdall();
#else
		win_srtall();
		win_bdall();
		win_shwall();
#endif
		desk_wait(FALSE);
		break;
	case OPTNMENU:
		done = do_optnmenu(item);
		/* break; */
	}
	menu_tnormal(d->g_atree[ADMENU], title, TRUE);
	return done;
}


/* 104de: 00fdb85a */
/* 106de: 00e1cb54 */
/* 100de: 00fe1756 */
BOOLEAN hd_msg(NOTHING)
{
	int16_t x, y, w, h;
	register BOOLEAN done;
	register DESKWIN *pw;
	register int unused;
	register int unused2;
	register BOOLEAN change;
	register THEDSK *d;
	
	UNUSED(unused);
	UNUSED(unused2);
	d = thedesk;
	done = change = FALSE;
	switch (d->g_rmsg[0])
	{
	case WM_REDRAW:
	case WM_TOPPED:
	case WM_CLOSED:
	case WM_FULLED:
	case WM_ARROWED:
	case WM_HSLID:
	case WM_VSLID:
	case WM_SIZED:
	case WM_MOVED:
		desk_clear(d->g_cwin);
		/* break; */
	}
	switch (d->g_rmsg[0])
	{
	case MN_SELECTED:
		desk_verify(d->g_wlastsel, FALSE);
		done = hd_menu(d->g_rmsg[3], d->g_rmsg[4]);
		break;

	case WM_REDRAW:
		if (d->g_rmsg[3])
		{
			do_wredraw(d->g_rmsg[3], d->g_rmsg[4], d->g_rmsg[5], d->g_rmsg[6], d->g_rmsg[7]);
		}
		break;

	case WM_TOPPED:
		wind_set(d->g_rmsg[3], WF_TOP, 0, 0, 0, 0);
		wind_get(d->g_rmsg[3], WF_WORKXYWH, &x, &y, &w, &h);
		pw = win_find(d->g_rmsg[3]);
		win_top(pw);
		desk_verify(pw->w_id, FALSE);
		/* change = TRUE; */
		d->g_wlastsel = pw->w_id;
		break;

	case WM_CLOSED:
		do_filemenu(CLSFITEM);
		change = TRUE;
		break;

	case WM_FULLED:
		do_wfull(d->g_rmsg[3]);
		desk_verify(d->g_rmsg[3], TRUE);
		change = TRUE;
		break;

	case WM_ARROWED:
		win_arrow(d->g_rmsg[3], d->g_rmsg[4]);
		break;

	case WM_HSLID:
		win_slide(d->g_rmsg[3], d->g_rmsg[4], FALSE);
		break;

	case WM_VSLID:
		win_slide(d->g_rmsg[3], d->g_rmsg[4], TRUE);
		break;

	case WM_MOVED:
	case WM_SIZED:
		x = d->g_rmsg[4];
		y = d->g_rmsg[5];
		do_xyfix(&x, &y);
		w = d->g_rmsg[6];
		h = d->g_rmsg[7];
		wind_set(d->g_rmsg[3], WF_CURRXYWH, x, y, w, h);
		if (d->g_rmsg[0] == WM_SIZED)
		{
			desk_verify(d->g_rmsg[3], TRUE);
		} else
		{
			wind_get(d->g_rmsg[3], WF_WORKXYWH, &x, &y, &w, &h);
			pw = win_find(d->g_rmsg[3]);
			r_set((GRECT *) (&d->g_screen[pw->w_root].ob_x), x, y, w, h);
		}
		change = TRUE;
		/* break; */
	}

    /*
     * if our window has shrunk AND we're displaying a different number
     * of columns, we need to send a redraw message because the AES won't
     */
	if (change)
	{
#if TOSVERSION >= 0x104
		wind_get(d->g_rmsg[3], WF_CURRXYWH, &x, &y, &w, &h);
		pw = win_find(d->g_rmsg[3]);
		r_set(&pw->w_curr, x, y, w, h);
#else
		cnx_put();
#endif
	}
	
	d->g_rmsg[0] = 0;
	men_update((LPTREE)d->g_atree[ADMENU]);
	return done;
}


/* 104de: 00fdba7e */
/* 106de: 00e1cdde */
/* 100de: 00fe1964 */
VOID cnx_put(NOTHING)
{
	register int iwin;
	register int nwin;
	register WSAVE *pws;
	register DESKWIN *pw;
	register THEDSK *d;
	
	d = thedesk;
	d->g_cnxsave.vitem_save = d->g_cviewitem - ICONITEM;
	d->g_cnxsave.sitem_save = d->g_csortitem - NAMEITEM;
	d->g_cnxsave.ccopy_save = d->g_ccopypref;
	d->g_cnxsave.cdele_save = d->g_cdelepref;
#if TOSVERSION >= 0x104
	d->g_cnxsave.cbit_save = d->s_bitblt;
	d->g_cnxsave.covwr_save = d->g_covwrpref;
#else
	d->g_cnxsave.cdclk_save = d->g_cdclkpref;
#endif
#if TOSVERSION >= 0x162
	d->ccache_save = d->g_ccachepref;
	d->g_cnxsave.pref_save = gl_restype;
#else
	d->g_cnxsave.pref_save = gl_restype - 1;
#endif

#if TOSVERSION >= 0x104
	for (iwin = 0; iwin < NUM_WNODES; iwin++)
	{
		LBCOPY(&d->g_cnxsave.win_save[iwin].gr_save, &g_winsave[iwin], sizeof(GRECT));
	}
#endif
	
	nwin = 0;
	for (iwin = 0; iwin < NUM_WNODES; iwin++)
	{
		pw = win_ith(iwin + 1);

		if (pw->w_id != 0)
		{
			pws = &d->g_cnxsave.win_save[nwin];
			nwin++;
			wind_get(pw->w_id, WF_CURRXYWH, &pws->gr_save.g_x, &pws->gr_save.g_y, &pws->gr_save.g_w, &pws->gr_save.g_h);
			do_xyfix(&pws->gr_save.g_x, &pws->gr_save.g_y);
			pws->hsl_save = pw->w_cvcol;
			pws->vsl_save = pw->w_cvrow;
			pws->obid_save = pw->w_obid;
			strcpy(pws->pth_save, pw->w_path->p_spec);
		}
	}
	while (nwin < NUM_WNODES)
	{
		pws = &d->g_cnxsave.win_save[nwin];
		pws->pth_save[0] = '\0';
		pws->obid_save = 0;
		nwin++;
	}
}


/* 104de: 00fdbb94 */
/* 106de: 00e1cf10 */
/* 100de: 00fe1a46 */
VOID cnx_get(NOTHING)
{
	register int nw;
	int16_t drv;
	register WSAVE *pws;
	register DESKWIN *pw;
	char fname[LEN_ZFNAME - 5];
	char fext[LEN_ZEXT];
	register THEDSK *d;
	
	d = thedesk;
	do_viewmenu(ICONITEM + d->g_cnxsave.vitem_save);
	do_viewmenu(NAMEITEM + d->g_cnxsave.sitem_save);
	d->g_ccopypref = d->g_cnxsave.ccopy_save;
	d->g_cdelepref = d->g_cnxsave.cdele_save;
#if TOSVERSION >= 0x104
	d->s_bitblt = d->g_cnxsave.cbit_save;
	d->g_covwrpref = d->g_cnxsave.covwr_save;
#else
	d->g_cdclkpref = d->g_cnxsave.cdclk_save;
#endif
#if TOSVERSION >= 0x162
	d->g_ccachepref = d->ccache_save;
#endif
#if !TP_48 /* ARROWFIX */
	d->g_cdclkpref = evnt_dclick(d->g_cdclkpref, 1);
#endif
#if TOSVERSION <= 0x102
	gl_nextrez = d->g_cnxsave.pref_save + 1;
#endif

	for (nw = 0; nw < NUM_WNODES; nw++)
	{
		pws = &d->g_cnxsave.win_save[nw];
		if (pws->pth_save[0])
		{
			if ((pw = win_alloc(pws->obid_save)))
			{
				pw->w_cvcol = pws->hsl_save;
				pw->w_cvrow = pws->vsl_save;
				fpd_parse(pws->pth_save, &drv, d->g_tmppth, fname, fext);
				do_xyfix(&pws->gr_save.g_x, &pws->gr_save.g_y);
				pro_chdir(drv, d->g_tmppth);
				if (DOS_ERR == 0)
				{
					do_diropen(pw, TRUE, pws->obid_save, drv, d->g_tmppth, fname, fext, &pws->gr_save);
				} else
				{
					win_free(pw);
				}
			}

		}
	}
	cnx_put();
}



/*
 *  Run desktop
 */
/* 104de: 00fdbc88 */
/* 106de: 00e1d034 */
/* 100de: 00fe1b60 */
BOOLEAN deskmain(NOTHING)
{
	register int16_t obj;
	register int ii;
	register BOOLEAN done;
#define blitter_present done /* reuse register */
	register int16_t flags;
	int16_t ev_which;
	int16_t mx, my;
	int16_t bstate;
	int16_t k_state;
	int16_t kret;
	int16_t bret;
	register THEDSK *d;
	register int unused;
	char unused2[54];

	UNUSED(unused);
	UNUSED(unused2);
	
	/* initialize libraries	*/
	d = thedesk;
	
	obj = ap_init();

	/* initialize mouse */
	wind_update(BEG_UPDATE);

    /* get desktop work area coordinates */
    wind_get(DESK, WF_WORKXYWH, &d->g_desk.g_x, &d->g_desk.g_y, &d->g_desk.g_w, &d->g_desk.g_h);

	/* desk and calc full */
	wind_calc(1, -1, d->g_desk.g_x, d->g_desk.g_y, d->g_desk.g_w, d->g_desk.g_h, &d->g_full.g_x, &d->g_full.g_y, &d->g_full.g_w, &d->g_full.g_h);

	/* init long addrs that will be used alot */
	d->g_pcmd = d->g_cmd;
	d->g_ptail = d->g_tail;
	d->a_fcb1 = d->g_fcb1;
	d->a_fcb2 = d->g_fcb2;
	d->p_msgbuf = d->g_rmsg;
	
	desk_wait(TRUE);

	/* initialize resources */
	rsrc_init();

	/* initialize menus and dialogs */
#if TOSVERSION >= 0x104
	rsrc_gaddr(R_STRING, STCART, (VOIDPTR *)&d->p_cartname);
#endif
	for (ii = 0; ii < NUM_ADTREES; ii++)
		ini_tree(&d->g_atree[ii], ii);

	if (!read_inf())
	{
		ap_exit();
		return FALSE;
	}
	
	/* initialize windows */
	win_start();

	/* initialize folders, paths, and drives */
	fpd_start();

	/* show menu */
	desk_verify(DESK, FALSE);				/* should this be here  */

	menu_bar(d->g_atree[ADMENU], TRUE);

	/* establish menu items that need to be checked, check 'em */
	men_update((LPTREE)d->g_atree[ADMENU]);
	for (ii = 0; ii < 7; ii++)
		ob_change((LPTREE)d->g_atree[ADMENU], ii + ICONITEM, NORMAL, FALSE);
	ob_change((LPTREE)d->g_atree[ADMENU], L4ITEM, DISABLED, FALSE);
	
	if (isdrive() == 0)
	{
		ob_change((LPTREE)d->g_atree[ADMENU], SAVEITEM, DISABLED, FALSE);
	}
	
	d->g_cviewitem = ICONITEM;
	menu_icheck(d->g_atree[ADMENU], d->g_cviewitem, TRUE);

	d->g_csortitem = NAMEITEM;
	menu_icheck(d->g_atree[ADMENU], d->g_csortitem, TRUE);

	/* set up initial prefs */
	d->g_ccopypref = TRUE;
	d->g_cdelepref = TRUE;
	d->g_cdclkpref = 3;

	/* initialize desktop and its objects */
	app_blddesk();

	/* Take over the desktop */
	do_wredraw(DESK, d->g_desk.g_x, d->g_desk.g_y, d->g_desk.g_w, d->g_desk.g_h);
#ifdef __GNUC__
	wind_set(DESK, WF_NEWDESK, ((intptr_t)d->g_pscreen) >> 16, (intptr_t)d->g_pscreen, DROOT, FALSE);
#else
	wind_set(DESK, WF_NEWDESK, d->g_pscreen, DROOT, FALSE);
#endif
	
	/* set up current parms */
	desk_verify(DESK, FALSE);

	/* establish desktop's state from info found in app_start, open windows */
	d->g_wlastsel = DESK;

	cnx_get();
	
#if TOSVERSION >= 0x104
	tree = d->g_atree[ADMENU];
	blitter_present = Blitmode(-1);
	if (blitter_present & 2)
	{
		LWSET(OB_TAIL(EXTRABOX), BITBLT);
		LWSET(OB_NEXT(PRINTITEM), L6ITEM);
		LWSET(OB_HEIGHT(EXTRABOX), gl_hchar * 8);
		d->s_bitblt = d->g_cnxsave.cbit_save;
		menu_icheck(d->g_atree[ADMENU], BITBLT, d->s_bitblt);
		Blitmode(d->s_bitblt);
	} else
	{
		LWSET(OB_TAIL(EXTRABOX), PRINTITEM);
		LWSET(OB_NEXT(PRINTITEM), EXTRABOX);
		LWSET(OB_HEIGHT(EXTRABOX), gl_hchar * 6);
	}
#endif
	
#if TOSVERSION >= 0x104
	ii = 0;
	while (TRUE)
	{
		int16_t x;
		int16_t y;
		int16_t x2;

		if ((obj = top_items[ii++]) == 0)
			break;
		--obj;
		objc_offset(tree, obj, &x, &y);
		y = LWGET(OB_WIDTH(obj));
		x2 = x + y;
		if (x2 >= d->g_desk.g_w)
		{
			x = (x - x2) + d->g_desk.g_w - gl_wchar;
			LWSET(OB_X(obj), x);
		}
	}
#endif
	
	wind_update(END_UPDATE);

	/* get ready for main loop */
	flags = MU_BUTTON | MU_MESAG | MU_KEYBD;
	done = FALSE;

	/* turn mouse on */
	desk_wait(FALSE);

	/* loop handling user input until done */
	while (!done)
	{
		/* block for input */
		ev_which = evnt_multi(flags, 0x02, 0x01, 0x01,
			0, 0, 0, 0, 0,
			0, 0, 0, 0, 0,
			d->p_msgbuf,
			0, 0,
			&mx, &my, &bstate, &k_state, &kret, &bret);

		/* grab the screen */
		wind_update(BEG_UPDATE);

		/* handle system message */
		if (ev_which & MU_MESAG)
			done = hd_msg();

		/* handle keybd message */
		if (ev_which & MU_KEYBD)
			done = hd_keybd(kret);

		/* handle button down */
		if (ev_which & MU_BUTTON)
			done = hd_button(bret, mx, my, bstate, k_state);

		/* free the screen */
		wind_update(END_UPDATE);
	}

	/* save state in memory for when we come back to the desktop */
	cnx_put();
	save_inf(FALSE);

	/* turn off the menu bar */
	menu_bar(NULL, FALSE);

	/* exit the gem AES */
	obj = ap_exit();
	UNUSED(obj);

	/* resolution change? */
	if (gl_rschange)
	{
		set_defdrv();
		if (isdrive() != 0)
		{
			pro_chroot(dos_gdrv() + 'A');
			if (DOS_ERR != 0)
				diskin = FALSE;
			else
				diskin = TRUE;
		}
		return FALSE;
	} else
	{
		return TRUE;
	}
#undef blitter_present
}
