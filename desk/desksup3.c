#include "deskstr.h"
#include "taddr.h"
#include "desksupp.h"

#define E_NOFILES 18

#undef Drvmap
#define Drvmap()        trp13(10)


/* initialize resources */
BOOLEAN rsrc_init(NOTHING)
{
	int unused;
	
	UNUSED(unused);
	rom_ram(1, (intptr_t)pglobal, 0);
	return TRUE;
}


VOID ini_tree(P(OBJECT **)gaddr, P(int16_t) id)
PP(OBJECT **gaddr;)
PP(int16_t id;)
{
	int16_t ret;

	ret = rsrc_gaddr(R_TREE, id, (VOIDPTR *)gaddr);
	UNUSED(ret);
}


char *ini_str(P(int16_t) id)
PP(int16_t id;)
{
	char *str;

	rsrc_gaddr(R_STRING, id, (VOIDPTR *)&str);
	LSTCPY(ADDR(&thedesk->gl_lngstr[0]), str);
	return &thedesk->gl_lngstr[0];
}


/*
 *	Clear out the selections for this particular window
 */
/* 104de: 00fda0e0 */
/* 106de: 00e1afba */
VOID desk_clear(P(int16_t) wh)
PP(register int16_t wh;)
{
	register DESKWIN *pw;
	GRECT c;
	register int16_t root;

	/* get current size */
	wind_get(wh, WF_WORKXYWH, &c.g_x, &c.g_y, &c.g_w, &c.g_h);
	/* find its tree of items */
	if (wh != 0)
	{
		pw = win_find(wh);
		root = pw->w_root;
	} else
	{
		root = DROOT;
	}
	/* clear all selections */
	act_allchg(wh, thedesk->g_pscreen, root, 0, &gl_rfull, &c, SELECTED, FALSE, TRUE, TRUE);
}


/*
 *	Verify window display by building a new view.
 */
/* 104de: 00fda13c */
/* 106de: 00e1b02a */
VOID desk_verify(P(int16_t) wh, P(BOOLEAN) changed)
PP(register int16_t wh;)
PP(register BOOLEAN changed;)
{
	register DESKWIN *pw;
	register THEDSK *d;
	int16_t xc, yc, wc, hc;

	d = thedesk;
	if (wh)
	{
		pw = win_find(wh);
		if (changed)
		{
			wind_get(wh, WF_WORKXYWH, &xc, &yc, &wc, &hc);
			win_bldview(pw, xc, yc, wc, hc);
		}
		d->g_croot = pw->w_root;
	} else
	{
		/* The desktop itself... */
		d->g_croot = DROOT;
	}
	
	d->g_cwin = wh;
}


VOID do_wredraw(P(int16_t) w_handle, P(int16_t) xc, P(int16_t) yc, P(int16_t) wc, P(int16_t) hc)
PP(register int16_t w_handle;)
PP(int16_t xc;)
PP(int16_t yc;)
PP(int16_t wc;)
PP(int16_t hc;)
{
	GRECT t;
	register DESKWIN *pw;
	register GRECT *pt;
	register LPTREE tree;
	register int16_t root;

	pt = &t;
	tree = (LPTREE)thedesk->g_pscreen;

	if (w_handle != 0)
	{
		pw = win_find(w_handle);
		root = pw->w_root;
	} else
	{
		root = DROOT;
	}

	graf_mouse(M_OFF, NULL);
	wind_get(w_handle, WF_FIRSTXYWH, &pt->g_x, &pt->g_y, &pt->g_w, &pt->g_h);
	while (pt->g_w && pt->g_h)
	{
		if (rc_intersect((GRECT *)&xc, pt)) /* FIXME: assuming parameters on stack */
		{
			if (rc_intersect(&gl_rscreen, pt))
			{
				objc_draw((OBJECT *)tree, root, MAX_DEPTH, pt->g_x, pt->g_y, pt->g_w, pt->g_h);
			}
		}
		wind_get(w_handle, WF_NEXTXYWH, &pt->g_x, &pt->g_y, &pt->g_w, &pt->g_h);
	}
	graf_mouse(M_ON, NULL);
}


/*
 *	Picks ob_x, ob_y, ob_width, ob_height fields out of object list.
 */
/* 104de: 00fda22c */
/* 106de: 00e1b156 */
VOID get_xywh(P(OBJECT *)olist, P(int16_t) obj, P(int16_t *)px, P(int16_t *)py, P(int16_t *)pw, P(int16_t *)ph)
PP(OBJECT *olist;)
PP(register int16_t obj;)
PP(int16_t *px;)
PP(int16_t *py;)
PP(int16_t *pw;)
PP(int16_t *ph;)
{
	*px = olist[obj].ob_x;
	*py = olist[obj].ob_y;
	*pw = olist[obj].ob_width;
	*ph = olist[obj].ob_height;
}


/*
 *	Picks ob_spec field out of object list.
 */
/* 104de: 00fda28a */
/* 106de: 00e1b1bc */
ICONBLK *get_spec(P(OBJECT *) tree, P(int) obj)
PP(OBJECT *tree;)
PP(int obj;)
{
	return (ICONBLK *)tree[obj].ob_spec;
}


/* 104de: 00fda2a0 */
/* 106de: 00e1b1d4 */
VOID do_xyfix(P(int16_t *)px, P(int16_t *)py)
PP(register int16_t *px;)
PP(register int16_t *py;)
{
	int16_t tx, ty, tw, th;

	wind_get(0, WF_WORKXYWH, &tx, &ty, &tw, &th);
	tx = *px;
	*px = (tx & 0x000f);
	if (*px < 8)
		*px = tx & 0xfff0;
	else
		*px = (tx & 0xfff0) + 16;
	*py = max(*py, ty);
}


/* 104de: 00fda2fa */
/* 106de: 00e1b23e */
VOID do_wopen(P(BOOLEAN) new_win, P(int16_t) wh, P(int16_t) obj, P(int16_t) x, P(int16_t) y, P(int16_t) w, P(int16_t) h)
PP(register BOOLEAN new_win;)
PP(register int16_t wh;)
PP(register int16_t obj;)
PP(int16_t x;)
PP(int16_t y;)
PP(int16_t w;)
PP(int16_t h;)
{
	int16_t dx, dy, dw, dh;
	GRECT c;
	register VOIDPTR unused;
	register THEDSK *d;
	register GRECT *pc;
	
	UNUSED(unused);
	pc = &c;
	d = thedesk;
	do_xyfix(&x, &y);
	/* Zooming box effect */
	get_xywh(d->g_screen, obj, &dx, &dy, &dw, &dh);
	get_xywh(d->g_screen, d->g_croot, &pc->g_x, &pc->g_y, &pc->g_w, &pc->g_h);

	/* Zooming box effect */
	dx += pc->g_x;
	dy += pc->g_y;

	if (d->g_screen[obj].ob_type == G_USERDEF)
		dw = w;
	graf_growbox(dx, dy, dw, dh, x, y, w, h);

	act_chg(d->g_cwin, d->g_pscreen, d->g_croot, obj, pc, SELECTED, FALSE, TRUE, TRUE);
	if (new_win)
	{
		wind_open(wh, x, y, w, h);
	}
	d->g_wlastsel = wh;
}


/* 104de: 00fda3de */
/* 106de: 00e1b33c */
VOID zoom_closed(P(BOOLEAN) close, P(int16_t) w_id, P(int16_t) xicon, P(int16_t) yicon)
PP(register BOOLEAN close;)
PP(register int16_t w_id;)
PP(register int16_t xicon;)
PP(register int16_t yicon;)
{
	int16_t xc, yc, wc, hc;
	register THEDSK *d;
	
	d = thedesk;
	wind_get(w_id, WF_WORKXYWH, &xc, &yc, &wc, &hc);
	if (close)
		wind_close(w_id);

	graf_shrinkbox(xicon, yicon, d->g_wicon, d->g_hicon, xc, yc, wc, hc);
}


/* 104de: 00fda422 */
/* 106de: 00e1b394 */
VOID do_wfull(P(int16_t) wh)
PP(register int16_t wh;)
{
	GRECT curr, prev, full;
	register GRECT *pcurr;
	register GRECT *pprev;
	register GRECT *pfull;

	pcurr = &curr;
	pprev = &prev;
	pfull = &full;
	wind_get(wh, WF_CURRXYWH, &pcurr->g_x, &pcurr->g_y, &pcurr->g_w, &pcurr->g_h);
	wind_get(wh, WF_PREVXYWH, &pprev->g_x, &pprev->g_y, &pprev->g_w, &pprev->g_h);
	wind_get(wh, WF_FULLXYWH, &pfull->g_x, &pfull->g_y, &pfull->g_w, &pfull->g_h);

	if (rc_equal(pcurr, pfull))
	{
		wind_set(wh, WF_CURRXYWH, pprev->g_x, pprev->g_y, pprev->g_w, pprev->g_h);
		graf_shrinkbox(pprev->g_x, pprev->g_y, pprev->g_w, pprev->g_h, pfull->g_x, pfull->g_y, pfull->g_w, pfull->g_h);
	} else
	{
		graf_growbox(pcurr->g_x, pcurr->g_y, pcurr->g_w, pcurr->g_h, pfull->g_x, pfull->g_y, pfull->g_w, pfull->g_h);
		wind_set(wh, WF_CURRXYWH, pfull->g_x, pfull->g_y, pfull->g_w, pfull->g_h);
	}
}


/*
 *	Open a directory, it may be the root or a subdirectory.
 */
/* 104de: 00fda4b6 */
/* 104de: 00e1b450 */
BOOLEAN do_diropen(P(DESKWIN *)pw, P(BOOLEAN) new_win, P(int16_t) curr_icon, P(int16_t) drv, P(const char *)ppath, P(const char *)pname, P(const char *)pext, P(GRECT *)pt)
PP(register DESKWIN *pw;)
PP(register BOOLEAN new_win;)
PP(register int16_t curr_icon;)
PP(register int16_t drv;)
PP(char *ppath;)
PP(char *pname;)
PP(char *pext;)
PP(register GRECT *pt;)
{
	register int16_t ret;
	PNODE *tmp;

	/* convert to hourglass */
	desk_wait(TRUE);
	/* open a path node */
	tmp = pn_open(drv, ppath, pname, pext, FA_DIREC);
	if (tmp == NULL)
	{
		fun_alert(1, STDEEP, NULL);
		pw = win_ontop();
		if (pw)
			thedesk->g_wlastsel = pw->w_id;
		else
			thedesk->g_wlastsel = 0;
		desk_verify(thedesk->g_wlastsel, TRUE);
		goto done;
	} else
	{
		pw->w_path = tmp;
	}

	/* activate path by search and sort of directory */
	ret = pn_folder(pw->w_path);
	UNUSED(ret);
	if (drv == CHAR_FOR_CARTRIDGE)
	{
		strcpy(pw->w_name, S_CARTNAME);
	} else
	{
		/* set new name and info lines for window */
		win_sname(pw);
	}
	win_sinfo(pw);
#ifdef __GNUC__
	wind_set(pw->w_id, WF_NAME, ((intptr_t)pw->w_name) >> 16, ((intptr_t)pw->w_name), 0, 0);
	wind_set(pw->w_id, WF_INFO, ((intptr_t)pw->w_info) >> 16, ((intptr_t)pw->w_info), 0, 0);
#else
	wind_set(pw->w_id, WF_NAME, pw->w_name, 0, 0);
	wind_set(pw->w_id, WF_INFO, pw->w_info, 0, 0);
#endif

	/* do actual wind_open */
	if (curr_icon > 0)
	{
		do_wopen(new_win, pw->w_id, curr_icon, pt->g_x, pt->g_y, pt->g_w, pt->g_h);
		if (new_win)
			win_top(pw);
	}
	/*
	 * verify contents of windows object list
	 * by building view and make it current
	 */
	desk_verify(pw->w_id, TRUE);
	/* make it redraw */
	if (!new_win)
		do_wredraw(pw->w_id, pt->g_x, pt->g_y, pt->g_w, pt->g_h);

done:
	desk_wait(FALSE);
	return TRUE;
}


/*
 *	Open an application
 */
/* 104de: 00fda5d2 */
/* 106de: 00e1b5ac */
BOOLEAN do_aopen(P(APP *)pa, P(BOOLEAN) isapp, P(int16_t) curr, P(int16_t) drv, P(const char *)ppath, P(const char *)pname)
PP(register APP *pa;)
PP(BOOLEAN isapp;)
PP(int16_t curr;)
PP(int16_t drv;)
PP(const char *ppath;)
PP(const char *pname;)
{
	register BOOLEAN isgraf;
	register BOOLEAN iscr;
	register BOOLEAN isparm;
	register BOOLEAN uninstalled;
	BOOLEAN ret;
	BOOLEAN done;
	int16_t rx, ry, rw, rh;
	int16_t cx, cy, cw, ch;
	LPTREE tree;
	char *ptail;
	register char *pcmd;
	char name[LEN_ZFNAME + 1];
	BOOLEAN isover;
	register THEDSK *d;

	UNUSED(tree);
	d = thedesk;
	get_xywh(d->g_screen, curr, &cx, &cy, &cw, &ch);
	get_xywh(d->g_screen, d->g_croot, &rx, &ry, &rw, &rh);
	
	cx += rx;
	cy += ry;
	/* set flags */
	done = FALSE;
	isgraf = pa->a_apptype & AF_ISGRAF;
	iscr = TRUE;
	isparm = pa->a_apptype & AF_ISPARM;
	isover = pa->a_apptype & AF_ISFMEM;
	uninstalled = *pa->a_pappl == '*' || *pa->a_pappl == '?' || *pa->a_pappl == 0;

	/* change current dir. to selected icon's */
	if (!isover)
		pro_chdir(drv, ppath);
	/*
	 * see if application was selected directly or a
	 * data file with an associated primary application
	 */
	pcmd = ptail = NULL;
	d->g_cmd[0] = 0;
	d->g_tail[1] = 0;
	ret = TRUE;

	if (!uninstalled && !isapp)
	{
		/* an installed docum. */
		pcmd = pa->a_pappl;
		ptail = pname;
	} else
	{
		if (isapp)
		{
			/* DOS-based app. has been selected */
			if (isparm)
			{
				pcmd = d->g_cmd;
				ptail = &d->g_tail[1];
				ret = opn_appl(pname, "\0", pcmd, ptail);
			} else
			{
				pcmd = pname;
			}
		} else
		{
			/* DOS-based document been selected */
			ret = fun_alert(3, STNOAPPL, NULL);
			pcmd = &d->g_cmd;
			ptail = &d->g_tail[1];
			switch (ret)
			{
			case 1:
				/* show file */
				ret = pro_cmd(ini_str(STTSHOW), pname, TRUE, CMD_TYPE);
				break;
			case 2:
				/* print file */
				ret = pro_cmd(ini_str(STTPRINT), pname, TRUE, CMD_PRINT);
				isgraf = TRUE;
				break;
			case 3:
				ret = FALSE;
				/* break; */
			}
		}
	}
	

	/* user wants to run another application */
	if (ret)
	{
		if (pcmd != d->g_cmd && pcmd != NULL)
			strcpy(d->g_cmd, pcmd);
		if (ptail != &d->g_tail[1] && ptail != NULL)
			strcpy(d->g_tail + 1, ptail);
		if (isover)
			d->g_tail[0] = 0xff; /* what? */
		done = pro_run(isgraf, iscr, d->g_cwin, curr);
	}

	return done;
}


/*
 *	Open a disk
 */
/* 104de: 00fda85e */
/* 106de: 00e1b8ac */
BOOLEAN do_dopen(P(int16_t) curr)
PP(register int16_t curr;)
{
	register int button;
	register BOOLEAN ret;
	register int drv;
	register DESKWIN *pw;
	register ICONBLK *pib;
	register THEDSK *d;
	
	d = thedesk;
	ret = FALSE;
	pib = get_spec(d->g_screen, curr);
	desk_wait(TRUE);
	drv = pib->ib_char & 0x00ff;
	pw = win_alloc(curr);
	if (pw == NULL)
	{
		rsrc_gaddr(R_STRING, STNOWIND, (VOIDPTR *)&d->a_alert);
		button = form_alert(1, d->a_alert);
	} else
	{
		if (drv != CHAR_FOR_CARTRIDGE)
			pro_chroot(drv);
		else
			DOS_ERR = 0;
		if (DOS_ERR == 0)
		{
			pro_chdir(drv, "");
			
			do_diropen(pw, TRUE, curr, drv, "", "*", "*", (GRECT *) &d->g_screen[pw->w_root].ob_x);
		} else
		{
			win_free(pw);
		}
	}
	desk_wait(FALSE);
	return ret;
}


/*
 *	Open a folder
 */
/* 104de: 00fda900 */
/* 106de: 00e1b974 */
BOOLEAN do_fopen(P(DESKWIN *)pw, P(int16_t) curr, P(int16_t) drv, P(const char *)ppath, P(const char *)pname, P(const char *)pext)
PP(register DESKWIN *pw;)
PP(int16_t curr;)
PP(int16_t drv;)
PP(const char *ppath;)
PP(const char *pname;)
PP(const char *pext;)
{
	int ok;
	BOOLEAN ret;
	GRECT t;
	register GRECT *pt;

	UNUSED(ok);
	pt = &t;
	ret = FALSE;
	wind_get(pw->w_id, WF_WORKXYWH, &pt->g_x, &pt->g_y, &pt->g_w, &pt->g_h);
	desk_wait(TRUE);
	pro_chroot(drv);
	if (DOS_ERR == 0)
	{
		pro_chdir(drv, "");
		pro_chdir(drv, ppath);
		pn_close(pw->w_path);
		if (DOS_ERR != 0)
		{
			ppath = "";
			pname = "*";
			pext  = "*";
		}
		do_diropen(pw, FALSE, curr, drv, ppath, pname, pext, pt);
	}
	desk_wait(FALSE);
	return ret;
}


/*
 *	Open an icon
 */
/* 104de: 00fda984 */
/* 106de: 00e1ba18 */
BOOLEAN open_item(P(int16_t) curr)
PP(register int16_t curr;)
{
	BOOLEAN done;
	register APP *pa;
	register DESKWIN *pw;
	register THEDSK *d;
	FNODE *pf;
	int16_t drv;
	BOOLEAN isapp;
	char path[LEN_ZFPATH];
	char name[10]; /* BUG: too short */
	char ext[LEN_ZEXT];

	d = thedesk;

	done = FALSE;

	pa = i_find(d->g_cwin, curr, &pf, &isapp);
	if (d->g_cwin == 0)
	{
		drv = 0;
#ifndef __ALCYON__
		pw = NULL; /* silence compiler */
#endif
	} else
	{
		pw = win_find(d->g_cwin);
#if TOSVERSION >= 0x104
		sh_iscart = streq(pw->w_name, d->p_cartname) ? TRUE : FALSE;
#endif
		if (pf)
			fpd_parse(pw->w_path->p_spec, &drv, path, name, ext);
	}
	
	if (pa)
	{
		switch (pa->a_type)
		{
		case AT_ISFILE:
			done = do_aopen(pa, isapp, curr, drv, path, pf->f_name);
			break;
		
		case AT_ISFOLD:
			if (path[0] != 0)
				strcat(path, "\\");
			strcat(path, pf->f_name);
			/* pw->w_cvrow = 0; */	/* reset slider     */
			done = do_fopen(pw, curr, drv, path, name, ext);
			break;
		
		case AT_ISDISK:
			done = do_dopen(curr);
			break;
		
		case AT_ISCART:
			done = do_dopen(curr);
			break;
		
		case AT_ISTRSH:
			rsrc_gaddr(R_STRING, STNOOPEN, (VOIDPTR *)&d->a_alert);
			form_alert(1, d->a_alert);
			/* break; */
		}
	}

	return done;
}


/*
 *	Get information on an icon.
 */
/* 104de: 00fdaaa8 */
/* 106de: 00e1bb86 */
BOOLEAN show_item(P(int16_t) curr)
PP(register int16_t curr;)
{
	BOOLEAN done;
	BOOLEAN ret;
	BOOLEAN isapp;
	register APP *pa;
	register DESKWIN *pw;
	FNODE *pf;
	register THEDSK *d;
	ICONBLK *ib;
	register LPTREE tree;

	d = thedesk;
	done = FALSE;
	pa = i_find(d->g_cwin, curr, &pf, &isapp);
	if (d->g_cwin != 0)
		pw = win_find(d->g_cwin);
#ifndef __ALCYON__
	else
		pw = NULL; /* BUG: not handled */
#endif

	if (pa)
	{
		switch (pa->a_type)
		{
		case AT_ISFILE:
			pro_chroot(pw->w_path->p_spec[0]);
			if (DOS_ERR)
				goto error;
			ret = inf_file(pw->w_path->p_spec, pf);
			if (ret)
				up_1win(pw);
			break;
		case AT_ISFOLD:
			pro_chroot(pw->w_path->p_spec[0]);
			if (DOS_ERR)
				goto error;
			inf_folder(pw->w_path->p_spec, pf);
			break;
		case AT_ISDISK:
			ib = get_spec(d->g_screen, curr);
			pro_chroot(ib->ib_char & 0xFF);
			if (DOS_ERR)
				goto error;
			inf_disk(ib->ib_char & 0xFF);
			break;
		case AT_ISTRSH:
			tree = (LPTREE)d->g_atree[ADPINFO];
			inf_show((OBJECT *)tree, ROOT);
			LWSET(OB_STATE(APDOK), NORMAL);
			/* break; */
		}
	}
error:
	return done;
}


/* 104de: 00fdab74 */
/* 106de: 00e1bc5e */
BOOLEAN do_format(P(int16_t) curr)
PP(register int16_t curr;)
{
	register APP *app;
	register ICONBLK *ib;
	register THEDSK *d;
	register BOOLEAN ok;
	register int ret;
	BOOLEAN isapp;
	char *ptmp;
	char *pname;
	char drive[6];

	d = thedesk;
	ok = FALSE;
	app = NULL;
	if (d->g_cwin == 0)
	{
		pname = win_iname(curr);
		app = app_afind(TRUE, -1, curr, pname, &isapp);
	}
	if (app != NULL)
	{
		switch (app->a_type)
		{
		case AT_ISDISK:
			ib = get_spec(d->g_screen, curr);
			drive[0] = ib->ib_char & 0xff;
			drive[1] = '\0';
			ptmp = drive;
			ret = fun_alert(2, STFORMAT, &ptmp);
			strcpy(&drive[1], ":/ /V");
			if (ret == 1)
			{
				ret = pro_cmd(ini_str(STTFORMAT), drive, TRUE, CMD_FORMAT);
				if (ret != 0)
				{
					ok = pro_run(TRUE, TRUE, d->g_cwin, curr);
				}
			}
			break;
		}
	}
	return ok;
}



/* 104de: 00fdac02 */
/* 106de: 00e1bd06 */
BOOLEAN true_closewnd(P(DESKWIN *)pw)
PP(register DESKWIN *pw;)
{
	int16_t x, y, w, h;
	register THEDSK *d;
	register BOOLEAN unused;
	register BOOLEAN ret;
	
	UNUSED(unused);
	d = thedesk;
	ret = FALSE;
	wind_get(pw->w_id, WF_WORKXYWH, &x, &y, &w, &h);
	zoom_closed(TRUE, pw->w_id, d->g_screen[pw->w_obid].ob_x, d->g_screen[pw->w_obid].ob_y);
	pn_close(pw->w_path);
	win_free(pw);
	pw = win_ontop();
	if (pw)
		d->g_wlastsel = pw->w_id;
	else
		d->g_wlastsel = 0;
	desk_verify(d->g_wlastsel, TRUE);
	return ret;
}


/* 104de: 00fdac8c */
/* 106de: 00e1bdac */
BOOLEAN w_setpath(P(DESKWIN *)pw, P(int) drv, P(const char *)path, P(const char *)name, P(const char *)ext)
PP(register DESKWIN *pw;)
PP(int drv;)
PP(const char *path;)
PP(const char *name;)
PP(const char *ext;)
{
	BOOLEAN unused;
	BOOLEAN res;
	GRECT rc;
	int16_t icx, icy;
	register THEDSK *d;
	register GRECT *pc;
	
	UNUSED(unused);
	pc = &rc;
	d = thedesk;
	res = FALSE;
	wind_get(pw->w_id, WF_WORKXYWH, &pc->g_x, &pc->g_y, &pc->g_w, &pc->g_h);
	icx = pc->g_x + (pc->g_w / 2) - (d->g_wicon / 2);
	icy = pc->g_y + (pc->g_h / 2) - (d->g_hicon / 2);
	zoom_closed(0, pw->w_id, icx, icy);
#if 0
	pw->w_cvcol = 0;
	pw->w_cvrow = 0;
#endif
	do_fopen(pw, 0, drv, path, name, ext);
	return res;
}


/* 104de: 00fdad22 */
/* 106de: 00e1be52 */
BOOLEAN close_window(P(DESKWIN *)pw, P(BOOLEAN) trueclose)
PP(register DESKWIN *pw;)
PP(register BOOLEAN trueclose;)
{
	register char *ppath;
	register char *pend;
	int16_t drv;
	char path[LEN_ZFPATH];
	char name[10]; /* BUG: too short */
	char ext[LEN_ZEXT];
	register BOOLEAN rv;

	rv = FALSE;
	graf_mouse(HOURGLASS, NULL);
	fpd_parse(pw->w_path->p_spec, &drv, path, name, ext);
	if (trueclose)
		path[0] = 0;
	if (!path[0])
	{
		rv = true_closewnd(pw);
	} else
	{
		ppath = pend = path;
		pend += (int)strlen(path) - 1;
		while (pend != ppath && *pend != '\\')
		{
			--pend;
		}
		*pend = 0;
		rv = w_setpath(pw, drv, path, name, ext);
	}
	graf_mouse(ARROW, NULL);
	return rv;
}


#undef Floprd
#define Floprd(a,b,c,d,e,f,g)   trp14(8,a,b,c,d,e,f,g)

#define MEDIACHANGE 2

/* 104de: 00fdadb6 */
/* 106de: 00e1bf02 */
VOID pro_chroot(P(int) drive)
PP(int drive;)
{
	long drvmap;
	register intptr_t ptr;
	register int ret;
	register BOOLEAN rv;
	register int drv;
	
	rv = TRUE;
	DOS_ERR = 0;
#if TOSVERSION >= 0x104
	if ((char)drive == CHAR_FOR_CARTRIDGE) /* FIXME: cast */
		return TRUE;
	desk_wait(TRUE);
#endif
	drvmap = Drvmap();
	drv = drive - 'A';
	drvmap = drvmap >> drv;
	drvmap = drvmap & 1;
	if (drvmap == 0)
	{
		fm_error(~E_DRIVE - 30);
		DOS_ERR = TRUE;
	} else
	{
		if (drive < 'C')
		{
			ptr = (intptr_t)dos_alloc(512L);
			
			if (ptr != NULL)
			{
				while (rv)
				{
					desk_wait(TRUE);
					ret = Floprd(ptr, 0L, drive - 'A', 1, 0, 0, 1);
					if (ret != 0 && ret != E_CHNG)
					{
						rv = eralert(ret == E_SEEK ? 1 : 2, drive - 'A');
					} else
					{
						rv = 0;
					}
				}
				/*
				 * set mediachange status for floppy
				 */
				Rwabs(0, NULL, MEDIACHANGE, 0, drive - 'A');
				dos_free((VOIDPTR)ptr);
				if (ret != 0 && ret != E_CHNG)
					DOS_ERR = TRUE;
			} else
			{
				fm_error(~E_NSMEM - 30);
			}
		}
		desk_wait(FALSE);
	}
}
