/*      DESKFUN.C       08/30/84 - 05/30/85             Lee Lorenzen    */
/*                      10/2/86  - 01/16/87             MDF             */
/*      merge source    5/27/87  - 5/28/87              mdf             */
/*      for 2.3         6/11/87                         mdf             */

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
#include "toserrno.h"

char *g_buffer;						/* merge string buffer  */
STATIC char cp_dst[LEN_ZFPATH];


/*
 * Perform an alert box message
 */
/* 306de: 00e301dc */
/* 104de: 00fd947e */
/* 106de: 00e1a152 */
int16_t fun_alert(P(int16_t) defbutton, P(int16_t) item, P(VOIDPTR) parms)
PP(int16_t defbutton;)
PP(int16_t item;)
PP(VOIDPTR parms;)
{
	register char *dst;
	register THEDSK *d;

	dst = g_buffer;
	d = thedesk;
	rsrc_gaddr(R_STRING, item, (VOIDPTR *)&d->str);
	if (parms != NULL)
	{
		merge_str(dst, d->str, parms);
		d->str = dst;
	}
	return form_alert(defbutton, d->str);
}


/*
 * send message to myself
 */
/* 104de: 00fd94c8 */
/* 106de: 00e1a1b0 */
VOID send_msg(P(int16_t) type, P(int16_t) whom, P(int16_t) w3, P(int16_t) w4, P(int16_t) w5, P(int16_t) w6, P(int16_t) w7)
{
	int16_t msg[8];
	
	msg[0] = type;
	msg[1] = gl_apid;
	msg[2] = 0;
	msg[3] = w3;
	msg[4] = w4;
	msg[5] = w5;
	msg[6] = w6;
	msg[7] = w7;
	appl_write(gl_apid, 16, msg);
}


/* 104de: 00fd9510 */
/* 106de: 00e1a1fe */
VOID up_allwin(P(const char *) path, P(BOOLEAN) dofull)
PP(const char *path;)
PP(BOOLEAN dofull;)
{
	register DESKWIN *win;
	register int i;
	
	graf_mouse(HOURGLASS, NULL);
	for (i = NUM_WNODES; i != 0; i--)
	{
		win = win_ith(i);
		if (win->w_id != 0)
		{
			if (dofull)						/* compare the full path    */
			{
				if (streq(win->w_path->p_spec, path))
					up_win(win);
			} else							/* just the id  */
			{
				if (win->w_path->p_spec[0] == path[0])
				{
					up_win(win);
				}
			}
		}
	}
	graf_mouse(ARROW, NULL);
}


/* 104de: 00fd9572 */
/* 106de: 00e1a27c */
/* Rebuild window path and pflist */
/* aka fun_rebld */
VOID up_1win(P(DESKWIN *) win)
PP(register DESKWIN *win;)
{
	char *path;
	register int i;
	GRECT gr;
	
	graf_mouse(HOURGLASS, NULL);
	path = win->w_path->p_spec;
	for (i = NUM_WNODES; i != 0; i--)
	{
		win = win_ith(i);
		if (win->w_id != 0)
		{
			if (streq(win->w_path->p_spec, path))
			{
				pn_folder(win->w_path);
				desk_verify(win->w_id, TRUE);
				win_sinfo(win);
#ifdef __GNUC__
				wind_set(win->w_id, WF_INFO, ((intptr_t)win->w_info) >> 16, (intptr_t)win->w_info, 0, 0);
#else
				wind_set(win->w_id, WF_INFO, win->w_info, 0, 0);
#endif
				wind_get(win->w_id, WF_WORKXYWH, &gr.g_x, &gr.g_y, &gr.g_w, &gr.g_h);
				send_msg(WM_REDRAW, gl_apid, win->w_id, gr.g_x, gr.g_y, gr.g_w, gr.g_h);
			}
		}
	}
	graf_mouse(ARROW, NULL);
}


/* 104de: 00fd95c0 */
/* 106de: 00e1a2e2 */
VOID up_win(P(DESKWIN *) win)
PP(register DESKWIN *win;)
{
	GRECT gr;

	pn_folder(win->w_path);
	desk_verify(win->w_id, TRUE);
	win_sinfo(win);
#ifdef __GNUC__
	wind_set(win->w_id, WF_INFO, ((intptr_t)win->w_info) >> 16, (intptr_t)win->w_info, 0, 0);
#else
	wind_set(win->w_id, WF_INFO, win->w_info, 0, 0);
#endif
	wind_get(win->w_id, WF_WORKXYWH, &gr.g_x, &gr.g_y, &gr.g_w, &gr.g_h);
	send_msg(WM_REDRAW, gl_apid, win->w_id, gr.g_x, gr.g_y, gr.g_w, gr.g_h);
}


/*
 * Create a new folder on the top window
 */
/* 104de: 00fd9624 */
/* 106de: 00e1a364 */
/* aka fun_mkdir */
BOOLEAN newfolder(P(DESKWIN *) win)
PP(register DESKWIN *win;)
{
	register LPTREE tree;
	register PNODE *pp_node;
	register char *ptmp;
	register BOOLEAN cont;
	register int i;
	char fnew_name[NAMELEN - 2];
	char unew_name[NAMELEN];
	long unused;
	BOOLEAN more;
	DTA dta;
	int ret;

	UNUSED(unused);
	UNUSED(more);
	UNUSED(ret);

	tree = (LPTREE)thedesk->g_atree[ADMKDBOX];
	pp_node = win->w_path;
	ptmp = thedesk->g_srcpth;
	strcpy(ptmp, pp_node->p_spec);
	
#if 0 /* BUG: cartidge not handled */
	if (pp_node->p_spec[0] == CHAR_FOR_CARTRIDGE)
	{
		fun_alert(1, STNOMEM, NULL);
		return;
	}
#endif

	i = 0;
	while (*ptmp++)
	{
		if (*ptmp == '\\')
			i++;
	}

	if (i > MAX_LEVEL)
	{
#if 0 /* ZZZ */
		fun_alert(1, STFOF8DEE, NULL);
#endif
		return FALSE;
	}

	do
	{
		fnew_name[0] = 0;
		inf_sset((OBJECT *)tree, MKNAME, fnew_name);
		cont = FALSE;
		if (xform_do((OBJECT *)tree, ROOT) == MKOK)
		{
			desk_wait(TRUE);
			fs_sget(tree, MKNAME, fnew_name);
			unfmt_str(fnew_name, unew_name);
			if (unew_name[0])				/* no name  */
			{
				add_fname(thedesk->g_srcpth, unew_name);

				dos_sdta(&dta);

				if (dos_sfirst(thedesk->g_srcpth, FA_DIREC|FA_SYSTEM|FA_HIDDEN))
				{
					/* file exists */
#if 0 /* ZZZ */
					cont = fun_alert(1, STFOEXISTS, NULL) - 1 ? FALSE : TRUE;
#endif
				} else
				{
					dos_mkdir(thedesk->g_srcpth);
					if (DOS_AX == ~E_ACCDN - 30)
					{
#if 0 /* ZZZ */
						fun_alert(1, STDISKFULL, NULL);
#endif
					} else
					{
						if (dos_error())
							up_1win(win);
					}
				}
				del_fname(thedesk->g_srcpth);
			}
		}
	} while (cont);

	desk_wait(FALSE);
	return TRUE;
}


/* 104de: 00fd9768 */
/* 106de: 00e1a4ec */
BOOLEAN fun_op(P(int) op, P(PNODE *) pspath)
PP(register int op;)
PP(register PNODE *pspath;)
{
	register char *tmp;
	register int level;
	uint16_t fcnt;
	uint16_t dcnt;
	uint32_t size;
	
	/* do the operation */
	if (op != -1)
	{
		/* get count of source files */
		if (dir_op(OP_COUNT, &pspath->p_spec[0], pspath->p_flist, thedesk->g_tmppth, &fcnt, &dcnt, &size) == FALSE)
			return FALSE;
		if (op == OP_COPY || op == OP_MOVE)
		{
			if (par_chk(pspath->p_spec, pspath->p_flist, thedesk->g_tmppth))
			{
				level = f_level - 2;
				tmp = thedesk->g_tmppth;
				while (*tmp++ != '\0')
				{
					if (*tmp == '\\')
						level++;
				}
				if (level > MAX_LEVEL + 1)
				{
#if 0 /* ZZZ */
					fun_alert(1, STFOF8DEE, NULL);
#endif
					return FALSE;
				}
			} else
			{
				return FALSE;
			}
		}
		/* do the operation */
		dir_op(op, pspath->p_spec, pspath->p_flist, thedesk->g_tmppth, &fcnt, &dcnt, &size);
		return TRUE;
	}
	return FALSE;
	
}


/*
 *	Routine to call when a list of files has been dragged on
 *	top of a particular destination inside of a window,
 *  or a disk on in the desktop
 */
/* 104de: 00fd9848 */
/* 106de: 00e1a5e2 */
BOOLEAN fun_wdst(P(PNODE *) pspath, P(APP *) app, P(int) obid)
PP(PNODE *pspath;)
PP(register APP *app;)
PP(int obid;)
{
	register int op;
	ICONBLK *iblk;
	BOOLEAN ret;

	op = -1;
	if (app != NULL)
	{
		switch (app->a_type)
		{
		case AT_ISCART:
#if 0 /* ZZZ */
			fun_alert(1, STNOROM, NULL);
#endif
			return FALSE;
#if BINEXACT
			break;
#endif
		case AT_ISTRSH:
			op = OP_DELETE;
			break;
		case AT_ISDISK:
			/*
			 * if destination is disk then use
			 * icon char. to build dest path
			 */
			iblk = get_spec(thedesk->g_screen, obid);
			thedesk->g_tmppth[0] = iblk->ib_char & 255;
			strcpy(&thedesk->g_tmppth[1], ":\\*.*");
			op = OP_COPY;
			break;
		}
	}
	
	ret = fun_op(op, pspath);
	if (ret)
	{
		if (app->a_type == AT_ISDISK)
		{
			up_allwin(thedesk->g_tmppth, TRUE);
			goto upwin;
		}
		if (app->a_type == AT_ISTRSH)
		{
		upwin:
			up_allwin(pspath->p_spec, TRUE);
		}
	}
	return ret;
}


/* 104de: 00fd9922 */
/* 106de: 00e1a5e2 */
BOOLEAN fun_file2win(P(PNODE *) pn_src, P(char *) spec, P(APP *) app, P(FNODE *) fn_dest)
PP(PNODE *pn_src;)
PP(char *spec;)
PP(register APP *app;)
PP(register FNODE *fn_dest;)
{
	int ret;
	register char *p;
	
	strcpy(thedesk->g_tmppth, spec);
	for (p = thedesk->g_tmppth; *p != '*'; ++p)
		;
	*p = '\0';
	if (app != NULL && app->a_type == AT_ISFOLD)
	{
		p = strcpy(p, fn_dest->f_name);
		strcpy(p - 1, wilds);
	} else
	{
		strcat(p, getall);
	}
	strcpy(cp_dst, thedesk->g_tmppth);
	ret = fun_op(OP_COPY, pn_src);
	if (ret)
	{
		up_allwin(cp_dst, TRUE);
		up_allwin(pn_src->p_spec, TRUE);
	}
	return ret;
}


/* 104de: 00fd99e0 */
/* 106de: 00e1a7b4 */
VOID fun_win2desk(P(int16_t) wh, P(int16_t) obj)
PP(int16_t wh;)
PP(int16_t obj;)
{
	DESKWIN *win;
	APP *app;
	
	app = app_afind(TRUE, AT_ISFILE, obj, NULL, NULL);
	win = win_find(wh);
	if (streq(win->w_name, thedesk->p_cartname))
	{
		switch (app->a_type)
		{
		case AT_ISDISK:
		case AT_ISCART:
#if 0 /* ZZZ */
			fun_alert(1, STNOROM, NULL);
#endif
			break;
		case AT_ISTRSH:
			form_error(~E_ACCDN - 30);
			break;
		}
	} else
	{
		fun_wdst(win->w_path, app, obj);
	}
}


/* 104de: 00fd9a6c */
/* 106de: 00e1a856 */
BOOLEAN fun_f2any(P(int16_t) sobj, P(DESKWIN *) wn_dest, P(APP *) an_dest, P(FNODE *) fn_dest, P(int16_t) dobj)
PP(int16_t sobj;)
PP(DESKWIN *wn_dest;)
PP(APP *an_dest;)
PP(FNODE *fn_dest;)
PP(int16_t dobj;)
{
	register BOOLEAN okay;
	ICONBLK *ib_src;
	register FNODE *bp8;
	register PNODE *pn_src;
	
	ib_src = get_spec(thedesk->g_screen, sobj);
	pro_chroot(ib_src->ib_char);
	if (DOS_ERR)
		return FALSE;
	pn_src = pn_open(ib_src->ib_char, "", "*", "*", FA_DIREC|FA_HIDDEN|FA_SYSTEM);
#if !BINEXACT
	okay = FALSE; /* BUG: should be above */
#endif
	if (pn_src != NULL)
	{
		pn_folder(pn_src);
#if BINEXACT
		okay = FALSE; /* BUG: should be above */
#endif
		if (pn_src->p_flist != NULL)
		{
			for (bp8 = pn_src->p_flist; bp8; bp8 = bp8->f_next)
				bp8->f_obid = 0;
			thedesk->g_screen[ROOT].ob_state = SELECTED;
			if (wn_dest != NULL)
				okay = fun_file2win(pn_src, wn_dest->w_path->p_spec, an_dest, fn_dest);
			else
				okay = fun_wdst(pn_src, an_dest, dobj);
			thedesk->g_screen[ROOT].ob_state = NORMAL;
		}
		pn_free(pn_src);
		desk_clear(0);
	}
	return okay;
}


/* 104de: 00fd9b3c */
/* 106de: 00e1a94c */
VOID fun_desk2win(P(int16_t) wh, P(int16_t) dobj)
PP(int16_t wh;)
PP(register int16_t dobj;)
{
	register DESKWIN *wn_dest;
	FNODE *fn_dest;
	BOOLEAN isapp;
	FNODE *fn_src;
	register int16_t sobj;
	register APP *an_src;
	register APP *an_dest;

	wn_dest = win_find(wh);
	an_dest = i_find(wh, dobj, &fn_dest, &isapp);
	sobj = 0;
	while ((sobj = win_isel(thedesk->g_screen, TRUE, sobj)))
	{
		an_src = i_find(0, sobj, &fn_src, &isapp);
		if (an_src->a_type == AT_ISTRSH)
		{
#if 0 /* ZZZ */
			fun_alert(1, STNOBIN2, NULL);
#endif
			continue;
		}
		if (an_src->a_type == AT_ISCART)
		{
#if 0 /* ZZZ */
			fun_alert(1, STNOROM, NULL);
#endif
			continue;
		}
		if (fun_f2any(sobj, wn_dest, an_dest, fn_dest, dobj))
			up_1win(wn_dest);
	}
}


/* 104de: 00fd9be0 */
/* 106de: 00e1aa12 */
BOOLEAN fun_d2desk(P(int16_t) dobj)
PP(int16_t dobj;)
{
	int16_t sobj;
	BOOLEAN isapp;
	FNODE *fn;
	register APP *source;
	register APP *target;
	long unused;
	ICONBLK *src_icon;
	ICONBLK *dst_icon;
	char dst_name[12];
	char src_name[2];
	char *parms[3];
	BOOLEAN cont;
	register THEDSK *d;
	long unused2;

	UNUSED(unused);
	UNUSED(unused2);
	d = thedesk;
	cont = FALSE;
	target = app_afind(TRUE, AT_ISFILE, dobj, NULL, NULL);
	sobj = 0;
	while ((sobj = win_isel(d->g_screen, TRUE, sobj)))
	{
		source = i_find(0, sobj, &fn, &isapp);

		if (source == target)
			continue;
		if (source->a_type == AT_ISTRSH)
		{
			fun_alert(1, STNODRAG, NULL);
			return FALSE;
		} else if (source->a_type == AT_ISCART)
		{
			fun_alert(1, STNODRAG, NULL);
			return FALSE;
		} else
		{
			switch (target->a_type)
			{
			case AT_ISTRSH:
				src_icon = get_spec(d->g_screen, sobj);
				src_name[0] = src_icon->ib_char & 255;
				src_name[1] = '\0';
				fun_alert(1, STNOBIN, NULL);
				return FALSE;
			case AT_ISCART:
				fun_alert(1, STROMRDONLY, NULL);
				return FALSE;
#if BINEXACT
				break;
#endif
			case AT_ISDISK:
				src_icon = get_spec(d->g_screen, sobj);
				dst_icon = get_spec(d->g_screen, dobj);
				src_name[0] = src_icon->ib_char & 255;
				src_name[1] = '\0';
				dst_name[0] = ' ';
				dst_name[1] = dst_icon->ib_char & 255;
				dst_name[2] = '\0';
				if (src_name[0] > 'B' ||
					src_name[0] < 'A' ||
					dst_name[1] > 'B' ||
					dst_name[1] < 'A')
				{
#if 0 /* ZZZ */
					fun_alert(1, FCDISKONLY, NULL);
#endif
					return FALSE;
				}
				parms[0] = src_name;
				parms[1] = dst_name + 1;
				parms[2] = dst_name + 1;
				if (fun_alert(2, STCOPY, parms) == 1)
				{
					fc_start(src_name, CMD_COPY);
					cont = FALSE;
				}
				break;
			}
		}
	}
	return cont;
}


/* 104de: 00fd9d76 */
/* 106de: 00e1abd2 */
BOOLEAN desk1_drag(P(int16_t) wh, P(int16_t) dest_wh, P(int16_t) sobj, P(int16_t) dobj)
PP(register int16_t wh;)
PP(register int16_t dest_wh;)
PP(register int16_t sobj;)
PP(register int16_t dobj;)
{
	BOOLEAN done;
	BOOLEAN isapp;
	FNODE *pf;
	register DESKWIN *srcwin;
	register DESKWIN *dstwin;
	register APP *app;
	
	done = FALSE;
	if (wh)
	{
		if (dest_wh)
		{
			srcwin = win_find(wh);
			dstwin = win_find(dest_wh);
			if (streq(srcwin->w_name, thedesk->p_cartname) ||
				streq(dstwin->w_name, thedesk->p_cartname))
			{
#if 0 /* ZZZ */
				fun_alert(1, STNOROM, NULL);
#endif
			} else
			{
				app = i_find(dest_wh, dobj, &pf, &isapp);
				if (fun_file2win(srcwin->w_path, dstwin->w_path->p_spec, app, pf) && wh != dest_wh)
					desk_clear(wh);
			}
		} else
		{
			if (dobj == sobj)
			{
				fun_alert(1, STNOWIN, NULL);
			} else
			{
				fun_win2desk(wh, dobj);
			}
		}
	} else
	{
		if (dest_wh)
		{
			fun_desk2win(dest_wh, dobj);
		} else
		{
			if (dobj != sobj)
				done = fun_d2desk(dobj);
		}
	}
	return done;
}
