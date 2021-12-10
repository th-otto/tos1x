/*
 *************************************************************************
 *			Revision Control System
 * =======================================================================
 *  $Author: mui $	$Date: 89/04/26 18:25:14 $
 * =======================================================================
 *
 * Revision 2.2  89/04/26  18:25:14  mui
 * TT
 * 
 * Revision 2.1  89/02/22  05:28:13  kbad
 * *** TOS 1.4  FINAL RELEASE VERSION ***
 * 
 * Revision 1.2  88/10/26  19:27:23  kbad
 * made menu line redraw in replace vice XOR mode.
 * 
 * Revision 1.1  88/06/02  12:34:30  lozben
 * Initial revision
 * 
 *************************************************************************
 */
/*	GEMMNLIB.C	04/26/84 - 04/05/85	Lowell Webster		*/
/*	Reg Opt		03/08/85 - 03/09/85	Derek Mui		*/
/*	At mn_do, added the ctlmouse	3/4/86	Derek Mui		*/
/*	Fix at mn_do			3/5/86	Derek Mui		*/
/*	Fix at mn_do for disabled menu bar	6/11/86	Derek Mui	*/
/*	Change at mn_bar to do a dsptch		3/10/88	D.Mui		*/
/*	Fix at mn_bar again so it won't lose click 6/25/90	D.Mui	*/

/*
 *	-------------------------------------------------------------
 *	GEM Application Environment Services		  Version 1.1
 *	Serial No.  XXXX-0000-654321		  All Rights Reserved
 *	Copyright (C) 1985			Digital Research Inc.
 *	-------------------------------------------------------------
 */

#include "aes.h"
#include "gemlib.h"
#include "taddr.h"
#include "gsxdefs.h"


LPTREE gl_mntree;
#if BINEXACT
int32_t gl_mnpid;
#else
int16_t gl_mnpid;
#endif
GRECT gl_rmnactv;
char *desk_acc[MAX_ACCS];
int16_t desk_pid[MAX_ACCS];
int16_t gl_dacnt;
int16_t gl_dabase;
int16_t gl_dabox;


VOID rect_change PROTO((LPTREE tree, MOBLK *prmob, int16_t iob, int16_t x));
int16_t menu_set PROTO((LPTREE tree, int16_t last_item, int16_t cur_item, int16_t setit));
VOID menu_sr PROTO((int16_t saveit, LPTREE tree, int16_t imenu));
int16_t menu_down PROTO((LPTREE tree, int16_t ititle));


/*
 *	Change a mouse-wait rectangle based on an object's size.
 */
/* 306de: 00e1ec14 */
/* 104de: 00fe8110 */
/* 106de: 00e23ea6 */
VOID rect_change(P(LPTREE) tree, P(MOBLK *) prmob, P(int16_t) iob, P(int16_t) x)
PP(LPTREE tree;)
PP(MOBLK *prmob;)
PP(int16_t iob;)
PP(int16_t x;)
{
	ob_actxywh(tree, iob, (GRECT *)&prmob->m_x);
	prmob->m_out = x;
}


/*
 * AES #31 - menu_icheck -  Set or clear check mark (tick) in menu options.
 * AES #32 - menu_ienable - Enable or disable a menu entry.
 * AES #33 - menu_tnormal - Displays a menu title in inverse video or normal.
 *
 *	Routine to change the state of a particular object.  The
 *	change in state will not occur if the object is disabled
 *	and the chkdisabled parameter is set.  The object will
 *	be drawn with its new state only if the dodraw parameter
 *	is set.
 */
/* 306de: 00e1ec3a */
/* 104de: 00fe1f60 */
/* 106de: 00e23ecc */
uint16_t do_chg(P(LPTREE) tree, P(int16_t) iitem, P(uint16_t) chgvalue, P(int16_t) dochg, P(int16_t) dodraw, P(int16_t) chkdisabled)
PP(register LPTREE tree;)						/* tree that holds item */
PP(int16_t iitem;)								/* item to affect   */
PP(register uint16_t chgvalue;)					/* bit value to change  */
PP(int16_t dochg;)								/* set or reset value   */
PP(int16_t dodraw;)								/* draw resulting change */
PP(int16_t chkdisabled;)						/* only if item enabled */
{
	register uint16_t curr_state;

	curr_state = LWGET(OB_STATE(iitem));
	if ((chkdisabled) && (curr_state & DISABLED))
		return (FALSE);

	if (dochg)
		curr_state |= chgvalue;
	else
		curr_state &= ~chgvalue;

	if (dodraw)
		gsx_sclip(&gl_rzero);

	ob_change(tree, iitem, curr_state, dodraw);
	return TRUE;
}


/*
 *	Routine to set and reset values of certain items if they
 *	are not the current item
 */
/* 306de: 00e1ecb0 */
/* 104de: 00fe1fc6 */
/* 106de: 00e23f42 */
int16_t menu_set(P(LPTREE) tree, P(int16_t) last_item, P(int16_t) cur_item, P(int16_t) setit)
PP(LPTREE tree;)
PP(register int16_t last_item;)
PP(int16_t cur_item;)
PP(int16_t setit;)
{
	if ((last_item != NIL) && (last_item != cur_item))
	{
		return (do_chg(tree, last_item, SELECTED, setit, TRUE, TRUE));
	}
	return (FALSE);
}


/*
 *	Routine to save or restore the portion of the screen underneath
 *	a menu tree.  This involves BLTing out and back
 *	the data that was underneath the menu before it was pulled
 *	down.
 */
/* 306de: 00e1ecf4 */
/* 104de: 00fe2000 */
/* 106de: 00e23f86 */
VOID menu_sr(P(int16_t) saveit, P(LPTREE) tree, P(int16_t) imenu)
PP(int16_t saveit;)
PP(LPTREE tree;)
PP(int16_t imenu;)
{
	GRECT t;

	gsx_sclip(&gl_rzero);
	ob_actxywh(tree, imenu, &t);
	t.g_x -= MTH;
	t.g_w += 2 * MTH;
	t.g_h += 2 * MTH;
	if (saveit)
		bb_save(&t);
	else
		bb_restore(&t);
}


/*
 *	Routine to pull a menu down.  This involves saving the data
 *	underneath the menu and drawing in the proper menu sub-tree.
 */
/* 306de: 00e1ed46 */
/* 104de: 00fe2040 */
/* 106de: 00e23fd8 */
int16_t menu_down(P(LPTREE) tree, P(int16_t) ititle)
PP(register LPTREE tree;)
PP(register int16_t ititle;)
{
	register int16_t imenu, i;

	/* correlate title # to menu subtree #  */
	imenu = LWGET(OB_HEAD(THEMENUS));
	for (i = ititle - THEACTIVE; i > 1; i--)
		imenu = LWGET(OB_NEXT(imenu));
	/* draw title selected  */
	if (do_chg(tree, ititle, SELECTED, TRUE, TRUE, TRUE))
	{
		/* save area underneath the menu       */
		menu_sr(TRUE, tree, imenu);
		/* draw all items in menu */
		ob_draw(tree, imenu, MAX_DEPTH);
	}
	return imenu;
}


/* 306de: 00e1edce */
/* 104de: 00fe20b8 */
/* 106de: 00e24060 */
int16_t mn_do(P(int16_t *) ptitle, P(int16_t *) pitem)
PP(int16_t *ptitle;)
PP(int16_t *pitem;)
{
	register int32_t tree;
	intptr_t buparm;
	int16_t mnu_flags, done;
	register int16_t cur_menu, cur_item, last_menu, last_item;
	int16_t cur_title, flag, last_title;
	uint16_t ev_which;
	MOBLK p1mor, p2mor;
	int16_t menu_state, rect;
	int16_t lrets[6];
	int16_t curstate;

	tree = gl_mntree;
	/*
	 * initially wait to go into the active part of the bar or the
	 * button state to change or out of the bar when nothing is down
	 */
	menu_state = INBAR;

	done = FALSE;
	buparm = 0x00010101L;
	cur_title = cur_menu = cur_item = NIL;

	ctlmouse(TRUE);

#if !BINEXACT
	rect = 0; /* quiet compiler */
#endif
	while (!done)
	{
		mnu_flags = MU_BUTTON | MU_M1;
		flag = TRUE;
		switch (menu_state)
		{
		case INBAR:
			rect = THEACTIVE;
			flag = FALSE;
			mnu_flags |= MU_M2;
			rect_change(tree, &p2mor, THEBAR, TRUE);
			break;
		case OUTTITLE:
			rect = cur_title;
			break;
		case INBARECT:
			rect = THEACTIVE;
			flag = FALSE;
			mnu_flags |= MU_M2;
			rect_change(tree, &p2mor, cur_menu, FALSE);
			break;
		case OUTITEM:
			rect = cur_item;
			buparm = (gsx_button() & 0x0001) ? 0x00010100L : 0x00010101L;
			break;
		}
		rect_change(tree, &p1mor, rect, flag);

		ev_which = ev_multi(mnu_flags, &p1mor, &p2mor, 0x0L, buparm, 0x0L, &lrets[0]);

		if (ev_which & MU_BUTTON)
		{
			if (menu_state != OUTTITLE)
				done = TRUE;
			else
				buparm ^= 0x00000001;
		}
		if (!done)
		{
			/* save old values  */
			last_title = cur_title;
			last_item = cur_item;
			last_menu = cur_menu;
			/* see if over the bar  */
			cur_title = ob_find(tree, THEACTIVE, 1, lrets[0], lrets[1]);
			curstate = LWGET(OB_STATE(cur_title));
			if ((cur_title != NIL) && (curstate != DISABLED))
			{
				cur_item = NIL;
				menu_state = OUTTITLE;
			} else
			{
				cur_title = last_title;
				if (last_menu != NIL)
				{
					cur_item = ob_find(tree, last_menu, 1, lrets[0], lrets[1]);
					menu_state = (cur_item != NIL) ? OUTITEM : INBARECT;
				} else
				{
					menu_state = INBAR;
					if (curstate != DISABLED)
						done = TRUE;
				}
			}
			/* clean up old state   */
			menu_set(tree, last_item, cur_item, FALSE);
			if (menu_set(tree, last_title, cur_title, FALSE))
				menu_sr(FALSE, tree, last_menu);
			/* set up new state */
			if (menu_set(tree, cur_title, last_title, TRUE))
				cur_menu = menu_down(tree, cur_title);
			menu_set(tree, cur_item, last_item, TRUE);
		}
	}
	
	/* decide what should be cleaned up and returned */
	flag = FALSE;
	if (cur_title != NIL)
	{
		menu_sr(FALSE, tree, cur_menu);
		if ((cur_item != NIL) && (do_chg(tree, cur_item, SELECTED, FALSE, FALSE, TRUE)))
		{
			/* only return TRUE when */
			/*   item is enabled and */
			/*   is not NIL     */
			*ptitle = cur_title;
			*pitem = cur_item;
			flag = TRUE;
		} else
		{
			do_chg(tree, cur_title, SELECTED, FALSE, TRUE, TRUE);
		}
	}

	ctlmouse(FALSE);					/* fixed 3/5/86     */

	return flag;
}


/*
 * AES #30 - menu_bar - Display, delete or install a menu bar.
 *
 *	Routine to display the menu bar.  Clipping is turned completely
 *	off so that this operation will be as fast as possible.  The
 *	global variable gl_mntree which is used in CTLMGR88.C is also
 *	set or reset.
 */
/* 306de: 00e1f098 */
/* 104de: 00fe2348 */
/* 106de: 00e2432a */ 
VOID mn_bar(P(LPTREE) tree, P(int16_t) showit)
PP(register LPTREE tree;)
PP(int16_t showit;)
{
	register int16_t i, ob, h, cnt;
	intptr_t spec;

	UNUSED(spec);
	if (showit)
	{
		gl_mntree = tree;
		ob_actxywh(tree, THEACTIVE, &gl_rmnactv);

#if AESVERSION >= 0x200
		/* change the waiting rectangle   */
		ch_wrect((GRECT *)&gl_ctwait.m_x, &gl_rmnactv);
#endif

		rc_copy(&gl_rmnactv, (GRECT *)&gl_ctwait.m_x);
		/*
		 * BUG: gl_mnpid delcared as long but accessed as short;
		 * this will be sign-extended here, causing users to always
		 * use 0 as menu owner
		 */
		gl_mnpid = rlr->p_pid;
		gl_dabox = LWGET(OB_HEAD(THEMENUS));
		LWSET(OB_HEAD(gl_dabox), NIL);
		LWSET(OB_TAIL(gl_dabox), NIL);
		h = 0;
		i = 1;
		if (gl_dacnt)
		{
			/* add disabled line and each desk acc */
			cnt = 2 + gl_dacnt;
			gl_dabase = gl_dabox + 3;
		} else
		{
			cnt = 1;
		}
		
		while (i <= cnt)
		{
			ob = gl_dabox + i;
			ob_add(tree, gl_dabox, ob);
			/* fixup each desk accessory line */
			if (i > 2)
				LLSET(OB_SPEC(ob), desk_acc[i - 3]);
			h += gl_hchar;
			i++;
		}
		LWSET(OB_HEIGHT(gl_dabox), h);
		gsx_sclip(&gl_rzero);
		ob_draw(tree, THEBAR, MAX_DEPTH);
		gsx_fattr(FALSE, MD_REPLACE, BLACK);	/* not xor mode! */
		gsx_fcline(0, gl_hbox - 1, gl_width - 1, gl_hbox - 1);
	} else
	{
		gl_mntree = 0;
#if AESVERSION >= 0x200
		/* change the waiting rect */
		ch_wrect((GRECT *)&gl_ctwait.m_x, &gl_rmenu);
#endif

		rc_copy(&gl_rmenu, (GRECT *)&gl_ctwait.m_x);
	}
	/* make ctlmgr fix up the size of rect its waiting for */
#if AESVERSION < 0x200
	gl_fakemsg++;
	post_button(ctl_pd, 1, 1);
#else
	post_button(ctl_pd, 0, 1);
#endif
	dsptch();
}


/*
 *	Routine to tell desk accessories that the currently running
 *	application is about to terminate.
 */
/* 104de: 00fe24d2 */
/* 106de: 00e244e4 */
VOID mn_clsda(NOTHING)
{
	register int16_t i;

	for (i = 0; i < gl_dacnt; i++)
#if BINEXACT /* sigh */
		ap_sendmsg(appl_msg, AC_CLOSE, desk_pid[i], i, 0, 0, 0L);
#else
		ap_sendmsg(appl_msg, AC_CLOSE, desk_pid[i], i, 0, 0, 0, 0);
#endif
}


/*
 * AES #35 - menu_register - Register a desk accessory in the 'Desk' accessory menu.
 *
 *	Routine to register a desk accessory item on the menu bar.
 *	The return value is the object index of the menu item that
 *	was added.
 */
/* 306de: 00e1f2b6 */
/* 104de: 00fe250e */
/* 106de: 00e2452c */
int16_t mn_register(P(int16_t) pid, P(char *) pstr)
PP(register int16_t pid;)
PP(register intptr_t pstr;)
{
	char tmpname[13];

	/* use this to name our process */
	if (pid == -1)
	{
		LSTCPY(ADDR(&tmpname[0]), pstr);
		p_nameit(rlr, &tmpname[0]);
		return TRUE;
	} else
	{
		/* add desk acc. if room */
		if (gl_dacnt < MAX_ACCS)
		{
			desk_pid[gl_dacnt] = pid;
			desk_acc[gl_dacnt] = pstr;
			gl_dacnt++;
			return (gl_dacnt - 1);
		} else
			return -1;
	}
}


#if AESVERSION >= 0x200
/*
 * Change the waiting rectangle for new menu bar
 */
/* 306de: 00e1f33c */
VOID ch_wrect(P(GRECT *) r, P(GRECT *) n)
PP(GRECT *r;)								/* old rect */
PP(GRECT *n;)								/* new rect */
{
	PD *p;
	register EVB *e;
	int16_t *p1, *p2;

	p = ctl_pd;

	for (e = p->p_cda->c_msleep; e; e = e->e_link)
	{
		p1 = (int16_t *)&e->e_parm; /* WTF */
		p2 = (int16_t *)&e->e_return; /* WTF */

		if (r->g_x == p1[0] && r->g_y == p1[1] && r->g_w == p2[0] && r->g_h == p2[1])
		{
			e->e_parm = HW(n->g_x) + n->g_y;
			e->e_return = HW(n->g_w) + n->g_h;
		}
	}
}
#endif
