/*	DESKSUPP.C	05/04/84 - 06/20/85	Lee Lorenzen		*/
/*	for 3.0 (xm)	3/12/86	 - 01/17/87	MDF			*/
/*	for 3.0			11/13/87		mdf		*/

/*
*       Copyright 1999, Caldera Thin Clients, Inc.                      
*       This software is licenced under the GNU Public License.         
*       Please see LICENSE.TXT for further information.                 
*                                                                       
*                  Historical Copyright                                 
*	-------------------------------------------------------------
*	GEM Desktop					  Version 3.0
*	Serial No.  XXXX-0000-654321		  All Rights Reserved
*	Copyright (C) 1987			Digital Research Inc.
*	-------------------------------------------------------------
*/

#include "desktop.h"
#include "gsxdefs.h"
#include "toserrno.h"

#define E_NOFILES 18

#undef Drvmap
#define Drvmap()        trp13int(10)


/* 104de: 00fd9fde */
/* 106de: 00e1ae8e */
BOOLEAN pro_chdir(P(int) drv, P(const char *) path)
PP(int drv;)
PP(const char *path;)
{
	register char *ptr;
	register int i;

	ptr = g_buffer;
	if (drv == CHAR_FOR_CARTRIDGE)
	{
		DOS_ERR = 0;
		return TRUE;
	}
	/* change to directory that application is in */
	if (drv != 0)
	{
		ptr[256] = '\\';
		strcpy(ptr + 257, path);
		for (i = 1; ptr[i + 256] != '\0'; )
		{
			if (ptr[i + 256] == ' ' || ptr[i + 256] == '*')
			{
				ptr[i + 256] = '\0';
				break;
			} else
			{
				i++;
			}
		}
		do_cdir(drv - 'A', ptr + 256);
	}
	return TRUE;
	
}


/* 104de: 00fda066 */
/* 106de: 00e1af28 */
int pro_run(P(int16_t) isgraf, P(int16_t) iscr, P(int16_t) wh, P(int16_t) curr)
PP(int16_t isgraf;)
PP(int16_t iscr;)
PP(int16_t wh;)
PP(int16_t curr;)
{
	register THEDSK *d;
	int ret;
	int len;

	d = thedesk;
	if (d->g_tail[0] == 0)
	{
		d->g_tail[0] = len = (int)strlen(d->g_tail + 1);
		d->g_tail[len + 1] = '\r';
	}
	desk_wait(TRUE);
	ret = shel_write(TRUE, isgraf, iscr, d->g_pcmd, d->g_ptail);
	d->g_tail[0] = '\0';
	if (wh != -1)
	{
		do_wopen(FALSE, wh, curr, d->g_full.g_x, d->g_full.g_y, d->g_full.g_w, d->g_full.g_h);
	}
	return ret;
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
	wind_grget(wh, WF_WORKXYWH, &c);
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
	GRECT clip;

	d = thedesk;
	if (wh)
	{
		pw = win_find(wh);
		if (changed)
		{
			wind_grget(wh, WF_WORKXYWH, &clip);
			win_bldview(pw, clip.g_x, clip.g_y, clip.g_w, clip.g_h);
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
	wind_grget(w_handle, WF_FIRSTXYWH, pt);
	while (pt->g_w && pt->g_h)
	{
		if (rc_intersect((GRECT *)&xc, pt)) /* FIXME: assuming parameters on stack */
		{
			if (rc_intersect(&gl_rscreen, pt))
			{
				objc_draw((OBJECT *)tree, root, MAX_DEPTH, pt->g_x, pt->g_y, pt->g_w, pt->g_h);
			}
		}
		wind_grget(w_handle, WF_NEXTXYWH, pt);
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
	GRECT t;

	wind_grget(0, WF_WORKXYWH, &t);
	t.g_x = *px;
	*px = (t.g_x & 0x000f);
	if (*px < 8)
		*px = t.g_x & 0xfff0;
	else
		*px = (t.g_x & 0xfff0) + 16;
	*py = max(*py, t.g_y);
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
PP(int16_t xicon;)
PP(int16_t yicon;)
{
	GRECT rc;
	register THEDSK *d;
	
	d = thedesk;
	wind_grget(w_id, WF_WORKXYWH, &rc);
	if (close)
		wind_close(w_id);

	graf_shrinkbox(xicon, yicon, d->g_wicon, d->g_hicon, rc.g_x, rc.g_y, rc.g_w, rc.g_h);
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
	wind_grget(wh, WF_CURRXYWH, pcurr);
	wind_grget(wh, WF_PREVXYWH, pprev);
	wind_grget(wh, WF_FULLXYWH, pfull);

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
	PNODE *tmp;

	/* convert to hourglass */
	desk_wait(TRUE);
	/* open a path node */
	tmp = pn_open(drv, ppath, pname, pext, FA_DIREC);
	if (tmp == NULL)
	{
		fun_alert(1, STFOF8DEE, NULL);
		pw = xfdc47a();
		thedesk->g_wlastsel = pw ? pw->w_id : 0;
		desk_verify(thedesk->g_wlastsel, TRUE);
		goto done;
	} else
	{
		pw->w_path = tmp;
	}

	/* activate path by search and sort of directory */
	pn_folder(pw->w_path);
	if (drv == CHAR_FOR_CARTRIDGE)
	{
		strcpy(pw->w_name, thedesk->p_cartname);
	} else
	{
		/* set new name and info lines for window */
		win_sname(pw);
	}
	win_sinfo(pw);
	wind_set(pw->w_id, WF_NAME, pw->w_name, 0L);
	wind_set(pw->w_id, WF_INFO, pw->w_info, 0L);

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
BOOLEAN do_aopen(P(DESKWIN *)win, P(APP *)pa, P(BOOLEAN) isapp, P(int16_t) curr, P(int16_t) drv, P(const char *)ppath, P(const char *)pname)
PP(DESKWIN *win;)
PP(register APP *pa;)
PP(BOOLEAN isapp;)
PP(int16_t curr;)
PP(int16_t drv;)
PP(const char *ppath;)
PP(const char *pname;)
{
	register THEDSK *d;
	BOOLEAN isgraf; /* 2 */
	BOOLEAN iscr; /* 4 */
	BOOLEAN isparm; /* 6 */
	BOOLEAN uninstalled; /* 8 */
	int16_t rx, ry, rw, rh; /* 16 */
	int16_t cx, cy, cw, ch; /* 24 */
	char *ptail; /* 28 */
	register BOOLEAN ret;
	register LPTREE tree;
	register char *pcmd;
	char name[26]; /* 54 */
	BOOLEAN isover;

	d = thedesk;
	get_xywh(d->g_screen, curr, &cx, &cy, &cw, &ch);
	get_xywh(d->g_screen, d->g_croot, &rx, &ry, &rw, &rh);
	
	cx += rx;
	cy += ry;
	/* set flags */
	isgraf = pa->a_apptype & AF_ISGRAF;
	iscr = TRUE;
	isparm = pa->a_apptype & AF_ISPARM;
	isover = pa->a_apptype & AF_ISFMEM;
	uninstalled = *pa->a_pappl == '*' || *pa->a_pappl == '?' || *pa->a_pappl == 0;
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
		ptail = d->g_srcpth;
		strcpy(d->g_srcpth, pname);
		strcpy(d->g_cmd, pcmd);
		win_top(win);
	} else
	{
		if (isapp)
		{
			/* DOS-based app. has been selected */
			if (isparm)
			{
				ptail = &d->g_tail[1];
				tree = (LPTREE)d->g_atree[ADOPENAP];
				inf_setsize(pname, name, (OBJECT *)tree, APPLNAME, TRUE);
				inf_sset((OBJECT *)tree, APPLPARM, "\0");
				if ((ret = xform_do((OBJECT *)tree, APPLPARM) != APPLOK ? FALSE : TRUE))
					fs_sget(tree, APPLPARM, ptail);
			}
			if (ret)
			{
				pcmd = d->g_cmd;
				*pcmd = (char)drv; /* FIXME: useless cast */
				pcmd[1] = '\0';
				strcat(pcmd, ":\\");
				if (*ppath != '\0')
				{
					strcat(pcmd, ppath);
					strcat(pcmd, "\\");
				}
				strcat(pcmd, pname);
			}
		} else
		{
			/* DOS-based document been selected */
			ret = fun_alert(1, STNOAPPL, NULL);
			if (ret == 3) /* cancel */
				return FALSE;
			if (ret == 1)
			{
				/* show file */
				graf_mouse(M_OFF, NULL);
				gsx_escapes(3); /* v_enter_cur */
				showfile(pname, FALSE);
				gsx_escapes(2); /* v_exit_cur */
				graf_mouse(M_ON, NULL);
				return TRUE;
			} else
			{
				tree = (LPTREE)d->g_atree[PRINTFIL];
				fmt_str(pname, d->printname);
				inf_sset((OBJECT *)tree, PFILE, d->printname);
				desk_wait(TRUE);
				fm_draw(tree);
				showfile(pname, TRUE);
				do_finish((OBJECT *)tree);
				desk_wait(FALSE);
				return FALSE;
			}
		}
	}
	

	/* user wants to run another application */
	if (ret)
	{
		if (ptail != &d->g_tail[1] && ptail != NULL)
			strcpy(d->g_tail + 1, ptail);
		if (isover)
			d->g_tail[0] = 0xff; /* what? */
		return pro_run(isgraf, iscr, d->g_cwin, curr);
	}

	return FALSE;
}


/*
 *	Open a disk
 */
/* 104de: 00fda85e */
/* 106de: 00e1b8ac */
BOOLEAN do_dopen(P(int16_t) curr)
PP(register int16_t curr;)
{
	register int drv;
	register DESKWIN *pw;
	register ICONBLK *pib;
	register THEDSK *d;
	
	d = thedesk;
	pib = get_spec(d->g_screen, curr);
	desk_wait(TRUE);
	drv = pib->ib_char & 0x00ff;
	pw = win_alloc(curr);
	if (pw)
	{
		if (pro_chroot(drv))
		{
			if (drv != CHAR_FOR_CARTRIDGE)
				pro_chdir(drv, "");
			
			do_diropen(pw, TRUE, curr, drv, "", "*", "*", (GRECT *) & d->g_screen[pw->w_root].ob_x);
		} else
		{
			win_free(pw);
		}
	} else
	{
		fun_alert(1, STNOWIND, NULL);
	}
	desk_wait(FALSE);
	return FALSE;
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
	GRECT t;
	register GRECT *pt;

	UNUSED(ok);
	pt = &t;
	wind_grget(pw->w_id, WF_WORKXYWH, pt);
	desk_wait(TRUE);
	if (pro_chroot(drv))
	{
		pro_chdir(drv, ppath);
		pn_free(pw->w_path);
		if (DOS_ERR != 0)
		{
			ppath = "";
			pname = "*";
			pext  = "*";
		}
		do_diropen(pw, FALSE, curr, drv, ppath, pname, pext, pt);
	}
	desk_wait(FALSE);
	return FALSE;
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
#if !BINEXACT
		pw = NULL; /* silence compiler */
#endif
	} else
	{
		pw = win_find(d->g_cwin);
		sh_iscart = streq(pw->w_name, d->p_cartname) ? TRUE : FALSE;
		if (pf)
			fpd_parse(pw->w_path->p_spec, &drv, path, name, ext);
	}
	
	if (pa)
	{
		switch (pa->a_type)
		{
		case AT_ISFILE:
			done = do_aopen(pw, pa, isapp, curr, drv, path, pf->f_name);
			break;
		
		case AT_ISFOLD:
			if (path[0] != 0)
				strcat(path, "\\");
			strcat(path, pf->f_name);
			/* pw->w_cvrow = 0; */	/* reset slider     */
			do_fopen(pw, curr, drv, path, name, ext);
			break;
		
		case AT_ISDISK:
		case AT_ISCART:
			do_dopen(curr);
			break;
		
		case AT_ISTRSH:
			fun_alert(1, STNOOPEN, NULL);
			break;
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
	BOOLEAN isapp;
	register APP *pa;
	register DESKWIN *pw;
	FNODE *pf;
	register THEDSK *d;
	ICONBLK *ib;
	register LPTREE tree;

	UNUSED(tree);
	d = thedesk;
	pa = i_find(d->g_cwin, curr, &pf, &isapp);
	if (d->g_cwin != 0)
		pw = win_find(d->g_cwin);
#if !BINEXACT
	else
		pw = NULL; /* BUG: not handled */
#endif

	if (pa)
	{
		switch (pa->a_type)
		{
		case AT_ISTRSH:
			fun_alert(1, TRSINFO, NULL);
			break;
		case AT_ISFILE:
		case AT_ISFOLD:
			if (!pro_chroot(pw->w_path->p_spec[0]))
				goto error;
			if (inf_file(pw->w_path->p_spec, pf, pa->a_type))
				up_1win(pw);
			break;
		case AT_ISDISK:
			ib = get_spec(d->g_screen, curr);
			if (!pro_chroot(ib->ib_char & 0xFF))
				goto error;
			inf_disk(ib->ib_char & 0xFF);
			break;
		}
	}
error:
	return FALSE;
}


/* 104de: 00fdab74 */
/* 106de: 00e1bc5e */
BOOLEAN do_format(P(int16_t) curr)
PP(register int16_t curr;)
{
	register APP *app;
	register ICONBLK *ib;
	register THEDSK *d;
	BOOLEAN isapp;
	char *ptmp;
	char *pname;
	char drive[6];

	d = thedesk;
	app = NULL;
	if (d->g_cwin == 0)
	{
		pname = xfdcd6a(curr);
		app = app_afind(TRUE, -1, curr, pname, &isapp);
	}
	if (app != NULL && app->a_type == AT_ISDISK)
	{
		ib = get_spec(d->g_screen, curr);
		drive[0] = ib->ib_char & 0xff;
		drive[1] = '\0';
		ptmp = drive;
		if (fun_alert(2, STFORMAT, &ptmp) == 1)
			fc_start(drive, CMD_FORMAT);
	}
	return FALSE;
}



/* 104de: 00fdac02 */
/* 106de: 00e1bd06 */
BOOLEAN true_closewnd(P(DESKWIN *)pw)
PP(register DESKWIN *pw;)
{
	int16_t x, y, w, h;
	register THEDSK *d;
	register BOOLEAN ret;
	
	UNUSED(ret);
	d = thedesk;
	wind_get(pw->w_id, WF_WORKXYWH, &x, &y, &w, &h);
	zoom_closed(1, pw->w_id, d->g_screen[pw->w_obid].ob_x, d->g_screen[pw->w_obid].ob_y);
	pn_free(pw->w_path);
	win_free(pw);
	pw = xfdc47a();
	d->g_wlastsel = pw ? pw->w_id : 0;
	desk_verify(d->g_wlastsel, TRUE);
	return FALSE;
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
	int res;
	GRECT rc;
	int16_t icx, icy;
	register THEDSK *d;
	register GRECT *pc;
	
	UNUSED(res);
	pc = &rc;
	d = thedesk;
	wind_grget(pw->w_id, WF_WORKXYWH, pc);
	icx = pc->g_x + (pc->g_w / 2) - (d->g_wicon / 2);
	icy = pc->g_y + (pc->g_h / 2) - (d->g_hicon / 2);
	zoom_closed(0, pw->w_id, icx, icy);
	pw->w_cvcol = 0;
	pw->w_cvrow = 0;
	do_fopen(pw, 0, drv, path, name, ext);
	return FALSE;
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
	desk_wait(TRUE);
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
	desk_wait(FALSE);
	return rv;
}


/* 104de: 00fdadb6 */
/* 106de: 00e1bf02 */
BOOLEAN pro_chroot(P(int) drive)
PP(int drive;)
{
	register long drvmap;
	register BOOLEAN rv;
	int drv;
	char path[10];
	
	if ((char)drive == CHAR_FOR_CARTRIDGE) /* FIXME: cast */
		return TRUE;
	desk_wait(TRUE);
	drvmap = Drvmap();
	drv = drive - 'A';
	drvmap >>= drv;
	drvmap &= 1;
	rv = TRUE;
	if (drvmap == 0)
	{
		fm_error(~E_DRIVE - 30);
		rv = FALSE;
	} else
	{
		path[0] = (char)drive; /* FIXME: cast */
		path[1] = ':';
		strcpy(&path[2], wilds);
		dos_sdta(&thedesk->r_dta);
		if (dos_sfirst(path, FA_DIREC|FA_SYSTEM|FA_HIDDEN) == 0 && DOS_AX != E_NOFILES)
			rv = FALSE;
	}
	desk_wait(FALSE);
	return rv;
}
