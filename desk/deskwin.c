/*	DESKWIN.C	06/11/84 - 04/01/85		Lee Lorenzen	*/
/*			4/7/86				MDF		*/
/*	for 3.0		11/4/87	- 11/19/87			mdf     */

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
#include "taddr.h"
#include "toserrno.h"

char *g_buffer;						/* merge string buffer  */


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
	
	desk_wait(TRUE);
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
	desk_wait(FALSE);
}


/* 104de: 00fd9572 */
/* 106de: 00e1a27c */
VOID up_1win(P(DESKWIN *) win)
PP(register DESKWIN *win;)
{
	char *path;
	register int i;
	
	desk_wait(TRUE);
	path = win->w_path->p_spec;
	for (i = NUM_WNODES; i != 0; i--)
	{
		win = win_ith(i);
		if (win->w_id != 0)
		{
			if (streq(win->w_path->p_spec, path))
				up_win(win);
		}
	}
	desk_wait(FALSE);
}


/* 104de: 00fd95c0 */
/* 106de: 00e1a2e2 */
VOID up_win(P(DESKWIN *) win)
PP(register DESKWIN *win;)
{
	GRECT gr;

	pn_folder(win->w_path);
	xfda13c(win->w_id, TRUE);
	xfdcd94(win);
	wind_set(win->w_id, WF_INFO, win->w_info, 0, 0);
	wind_grget(win->w_id, WF_WORKXYWH, &gr);
	send_msg(WM_REDRAW, gl_apid, win->w_id, gr.g_x, gr.g_y, gr.g_w, gr.g_h);
}


/*
 * Create a new folder on the top window
 */
/* 104de: 00fd9624 */
/* 106de: 00e1a364 */
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
		fun_alert(1, STFOF8DEE, NULL);
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
				xtr_mask(thedesk->g_srcpth, unew_name);

				dos_sdta(&dta);

				if (dos_sfirst(thedesk->g_srcpth, FA_DIREC|FA_SYSTEM|FA_HIDDEN))
				{
					/* file exists */
					cont = fun_alert(1, STFOEXISTS, NULL) - 1 ? FALSE : TRUE;
				} else
				{
					dos_mkdir(thedesk->g_srcpth);
					if (DOS_AX == ~E_ACCDN - 30)
					{
						fun_alert(1, STDISKFULL, NULL);
					} else
					{
						if (dos_error())
							up_1win(win);
					}
				}
				rep_all(thedesk->g_srcpth);
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
					fun_alert(1, STFOF8DEE, NULL);
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
			fun_alert(1, STNOROM, NULL);
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
			iblk = (ICONBLK *)get_spec(thedesk->g_screen, obid);
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

