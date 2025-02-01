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
#include "desksupp.h"

char *g_buffer;						/* merge string buffer  */

/*
 * Perform an alert box message
 */
/* 306de: 00e301dc */
/* 104de: 00fd947e */
/* 106de: 00e1a152 */
/* 100de: 00fdf252 */
int16_t fun_alert(P(int16_t) defbutton, P(int16_t) item, P(VOIDPTR) parms)
PP(int16_t defbutton;)
PP(int16_t item;)
PP(VOIDPTR parms;)
{
	register char *dst;
	register THEDSK *d;

	dst = g_buffer;
	d = thedesk;
	rsrc_gaddr(R_STRING, item, (VOIDPTR *)&d->a_alert);
	if (parms != NULL)
	{
		merge_str(dst, d->a_alert, parms);
		d->a_alert = dst;
	}
	return form_alert(defbutton, d->a_alert);
}


/*
 * send message to myself
 */
/* 104de: 00fd94c8 */
/* 106de: 00e1a1b0 */
/* 100de: 00fdf2a0 */
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


/* 104de: 00fd9572 */
/* 106de: 00e1a27c */
/* 100de: 00fdf2ec */
/* Rebuild window path and pflist */
/* aka fun_rebld */
VOID up_1win(P(DESKWIN *) win)
PP(register DESKWIN *win;)
{
	register char *path;
	register int i;
	register int ok;
	int16_t x, y, w, h;
	
	graf_mouse(HOURGLASS, NULL);
	path = win->w_path->p_spec;
	for (i = NUM_WNODES; i != 0; i--)
	{
		win = win_ith(i);
		if (win->w_id != 0)
		{
			if (streq(win->w_path->p_spec, path))
			{
				ok = pn_folder(win->w_path);
				UNUSED(ok);
				desk_verify(win->w_id, TRUE);
				win_sinfo(win);
#ifdef __GNUC__
				wind_set(win->w_id, WF_INFO, ((intptr_t)win->w_info) >> 16, (intptr_t)win->w_info, 0, 0);
#else
				wind_set(win->w_id, WF_INFO, win->w_info, 0, 0);
#endif
				wind_get(win->w_id, WF_WORKXYWH, &x, &y, &w, &h);
				send_msg(WM_REDRAW, gl_apid, win->w_id, x, y, w, h);
			}
		}
	}
	graf_mouse(ARROW, NULL);
}


/*
 * Create a new folder on the top window
 */
/* 104de: 00fd9624 */
/* 106de: 00e1a364 */
/* 100de: 00fdf3b8 */
/* aka fun_mkdir */
BOOLEAN newfolder(P(DESKWIN *) win)
PP(register DESKWIN *win;)
{
	register LPTREE tree;
	register PNODE *pp_node;
	register char *ptmp;
	register BOOLEAN more;
	register BOOLEAN cont;
	register BOOLEAN unused;
	register int i;
	char fnew_name[NAMELEN - 2];
	char unew_name[NAMELEN];
	int strid;

	UNUSED(unused);
	tree = (LPTREE)thedesk->g_atree[ADMKDBOX];
	pp_node = win->w_path;
	ptmp = thedesk->g_srcpth;
	strcpy(ptmp, pp_node->p_spec);
	
#if 0 /* BUG: cartridge not handled */
	if (pp_node->p_spec[0] == CHAR_FOR_CARTRIDGE)
	{
		fun_alert(1, STROMRDONLY, NULL);
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
		fun_alert(1, STDEEP, NULL);
		return FALSE;
	}

	cont = TRUE;
	while (cont)
	{
		fnew_name[0] = 0;
		inf_sset((OBJECT *)tree, MKNAME, fnew_name);
		show_hide((OBJECT *)tree);
		form_do((OBJECT *)tree, ROOT);
		cont = FALSE;
		if (inf_what((OBJECT *)tree, MKOK, MKCNCL))
		{
			desk_wait(TRUE);
			fs_ssget((OBJECT *)tree, MKNAME, fnew_name);
			unfmt_str(fnew_name, unew_name);
			if (unew_name[0])				/* no name  */
			{
				add_fname(thedesk->g_srcpth, unew_name);

				dos_sdta(gl_dta);

				if (dos_sfirst(thedesk->g_srcpth, FA_DIREC|FA_SYSTEM|FA_HIDDEN))
				{
					/* file exists */
					DOS_ERR = TRUE;
					DOS_AX = ~E_ACCDN - 30;
					strid = STSAMENAME;
				} else
				{
					dos_mkdir(thedesk->g_srcpth);
					strid = STDISKFULL;
				}
				if (DOS_ERR && DOS_AX == ~E_ACCDN - 30)
				{
					cont = fun_alert(1, strid, NULL) - 1;
					del_fname(thedesk->g_srcpth);
				} else
				{
					if ((more = dos_error()))
						up_1win(win);
				}
			}
		}
	}

	desk_wait(FALSE);
	do_finish((OBJECT *)tree);
	return TRUE;
}


/* 104de: 00fd9768 */
/* 106de: 00e1a4ec */
/* 100de: 00fdf538 */
BOOLEAN fun_op(P(int) op, P(PNODE *) pspath)
PP(int op;)
PP(register PNODE *pspath;)
{
	register char *tmp;
	uint16_t fcnt;
	uint16_t dcnt;
	uint32_t size;
	int unused;
	int level;
	int unused2;
	
	UNUSED(unused);
	UNUSED(unused2);
	/* do the operation */
	if (op != -1)
	{
		if (op == OP_COPY)
		{
			if (par_chk(pspath->p_spec, pspath->p_flist, thedesk->g_tmppth))
			{
				/* get count of source files */
				/* BUG: error code not checked */
				dir_op(OP_COUNT, &pspath->p_spec[0], pspath->p_flist, thedesk->g_tmppth, &fcnt, &dcnt, &size);
				level = f_maxlevel;
				tmp = thedesk->g_tmppth;
				while (*tmp++ != '\0')
				{
					if (*tmp == '\\')
						level++;
				}
				if (level > MAX_LEVEL + 1)
				{
					fun_alert(1, STILLCOPY, NULL);
					return FALSE;
				}
			} else
			{
				return FALSE;
			}
		}
		dir_op(OP_COUNT, &pspath->p_spec[0], pspath->p_flist, thedesk->g_tmppth, &fcnt, &dcnt, &size);
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
/* 100de: 00fdf640 */
BOOLEAN fun_wdst(P(PNODE *) pspath, P(APP *) app, P(int) obid)
PP(PNODE *pspath;)
PP(register APP *app;)
PP(int obid;)
{
	register int op;
	ICONBLK *iblk;

	op = -1;
	if (app != NULL)
	{
		switch (app->a_type)
		{
		case AT_ISCART:
			fun_alert(1, STROMRDONLY, NULL);
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
			/* break; */
		}
	}
	
	return fun_op(op, pspath);
}


/*
 *	Routine to call when the source of a drag is a disk
 *	and the destination is either a window or another
 *	disk.
 */
/* 104de: 00fd9922 */
/* 106de: 00e1a5e2 */
/* 100de: 00fdf6d8 */
BOOLEAN fun_file2win(P(PNODE *) pn_src, P(char *) spec, P(APP *) app, P(FNODE *) fn_dest)
PP(PNODE *pn_src;)
PP(char *spec;)
PP(register APP *app;)
PP(register FNODE *fn_dest;)
{
	register char *p;
	
	strcpy(thedesk->g_tmppth, spec);
	for (p = thedesk->g_tmppth; *p != '*'; ++p)
		;
	*p = '\0';
	if (app != NULL && app->a_type == AT_ISFOLD)
	{
		p = strcpy(p, fn_dest->f_name);
		strcpy(p - 1, "\\*.*");
	} else
	{
		strcat(p, "*.*");
	}
	return fun_op(OP_COPY, pn_src);
}


/* 104de: 00fd9d76 */
/* 106de: 00e1abd2 */
/* 100de: 00fdf75a */
VOID desk1_drag(P(int16_t) wh, P(int16_t) dest_wh, P(int16_t) dobj)
PP(register int16_t wh;)
PP(register int16_t dest_wh;)
PP(int16_t dobj;)
{
	BOOLEAN done;
	BOOLEAN isapp;
	FNODE *pf;
	register DESKWIN *srcwin;
	register DESKWIN *dstwin;
	register APP *app;
	
	srcwin = win_find(wh);
	dstwin = win_find(dest_wh);
#if 0 /* BUG: cartridge not handled */
	if (streq(srcwin->w_name, thedesk->p_cartname) ||
		streq(dstwin->w_name, thedesk->p_cartname))
	{
		fun_alert(1, STNOROM, NULL);
	} else
#endif
	{
		app = i_find(dest_wh, dobj, &pf, &isapp);
		done = fun_file2win(srcwin->w_path, dstwin->w_path->p_spec, app, pf);
		if (done)
		{
			if (wh != dest_wh)
				desk_clear(wh);
			up_1win(dstwin);
		}
	}
}


/* 104de: 00fd99e0 */
/* 106de: 00e1a7b4 */
/* 100de: 00fdf7ba */
VOID fun_win2desk(P(int16_t) wh, P(int16_t) obj)
PP(int16_t wh;)
PP(int16_t obj;)
{
	BOOLEAN done;
	DESKWIN *win;
	APP *app;
	
	app = app_afind(TRUE, AT_ISFILE, obj, NULL, NULL);
	win = win_find(wh);
#if 0 /* BUG: cartridge & trashcan not handled */
	if (streq(win->w_name, thedesk->p_cartname))
	{
		switch (app->a_type)
		{
		case AT_ISDISK:
		case AT_ISCART:
			fun_alert(1, STNOROM, NULL);
			break;
		case AT_ISTRSH:
			form_error(~E_ACCDN - 30);
			break;
		}
	} else
#endif
	{
		done = fun_wdst(win->w_path, app, obj);
		if (done)
			up_1win(win);
	}
}


/* 104de: 00fd9a6c */
/* 106de: 00e1a856 */
/* 100de: 00fdf808 */
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
	pn_src = pn_open(ib_src->ib_char, "", "*", "*", FA_DIREC|FA_HIDDEN|FA_SYSTEM);
#if !BINEXACT
	okay = FALSE; /* BUG: should be above */
#endif
	if (pn_src != NULL)
	{
		okay = pn_folder(pn_src);
#if BINEXACT
		if (okay == ~E_NMFIL - 30) { } /* E_NOFILES */
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
		pn_close(pn_src);
		desk_clear(0);
	}
	return okay;
}


/* 104de: 00fd9b3c */
/* 106de: 00e1a94c */
/* 100de: 00fdf8d0 */
VOID fun_desk2win(P(int16_t) wh, P(int16_t) dobj)
PP(int16_t wh;)
PP(register int16_t dobj;)
{
	register DESKWIN *wn_dest;
	FNODE *fn_dest;
	BOOLEAN more;
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
			fun_alert(1, STNOIMAGE, NULL);
			continue;
		}
		if (an_src->a_type == AT_ISCART)
		{
			fun_alert(1, STROMRDONLY, NULL);
			continue;
		}
		more = fun_f2any(sobj, wn_dest, an_dest, fn_dest, dobj);
		if (more)
			up_1win(wn_dest);
	}
}


/* 104de: 00fd9be0 */
/* 106de: 00e1aa12 */
/* 100de: 00fdf982 */
BOOLEAN fun_d2desk(P(int16_t) dobj)
PP(int16_t dobj;)
{
	int16_t sobj;
	BOOLEAN isapp;
	FNODE *fn;
	register APP *source;
	register APP *target;
	short fbutton;
	char *parm1[1];
	ICONBLK *src_icon;
	ICONBLK *dst_icon;
	char trsh_name[2];
	char dst_name[4];
	char src_name[2];
	char *parms[3];
	BOOLEAN cont;

	cont = FALSE;
	target = app_afind(TRUE, AT_ISFILE, dobj, NULL, NULL);
	sobj = 0;
	while ((sobj = win_isel(thedesk->g_screen, TRUE, sobj)))
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
			fbutton = TRUE;
			switch (target->a_type)
			{
			case AT_ISTRSH:
				src_icon = get_spec(thedesk->g_screen, sobj);
				trsh_name[0] = src_icon->ib_char & 255;
				trsh_name[1] = '\0';
				parm1[0] = trsh_name;
				fbutton = fun_alert(2, STNOBIN, parm1);
				return FALSE;
#if BINEXACT
				break;
#endif
			case AT_ISCART:
				fun_alert(1, STROMRDONLY, NULL);
				return FALSE;
#if BINEXACT
				break;
#endif
			case AT_ISDISK:
				src_icon = get_spec(thedesk->g_screen, sobj);
				dst_icon = get_spec(thedesk->g_screen, dobj);
				src_name[0] = src_icon->ib_char & 255;
				src_name[1] = '\0';
				dst_name[0] = ' ';
				dst_name[1] = dst_icon->ib_char & 255;
				dst_name[2] = '\0';
				dst_name[3] = '\0';
#if 0
				if (src_name[0] > 'B' ||
					src_name[0] < 'A' ||
					dst_name[1] > 'B' ||
					dst_name[1] < 'A')
				{
					fun_alert(1, FCDISKONLY, NULL);
					return FALSE;
				}
#endif
				parms[0] = src_name;
				parms[1] = dst_name + 1;
				parms[2] = dst_name + 1;
				fbutton = fun_alert(2, STCOPY, parms);
				src_name[1] = ':';
				dst_name[2] = ':';
				
				if (fbutton == 1)
				{
					fbutton = pro_cmd(ini_str(STTCOPY), src_name, TRUE, CMD_COPY);
					if (fbutton)
					{
						pro_run(TRUE, TRUE, 0, dobj);
						cont = TRUE;
					}
				}
				break;
			}
		}
	}
	return cont;
}


/* 100de: 00fdfbb0 */
BOOLEAN fun_ddrag(P(int16_t) src_wh, P(int16_t) dest_wh, P(int16_t) sobj, P(int16_t) dobj)
PP(register int16_t src_wh;)
PP(register int16_t dest_wh;)
PP(register int16_t sobj;)
PP(register int16_t dobj;)
{
	BOOLEAN ret;
	
	ret = FALSE;
	if (src_wh)
	{
		if (dest_wh)
			desk1_drag(src_wh, dest_wh, dobj);
		else if (dobj == sobj)
			fun_alert(1, STNOWIN, NULL);
		else
			fun_win2desk(src_wh, dobj);
	} else
	{
		if (dest_wh)
			fun_desk2win(dest_wh, dobj);
		else if (dobj != sobj)
			ret = fun_d2desk(dobj);
	}
	return ret;
}
