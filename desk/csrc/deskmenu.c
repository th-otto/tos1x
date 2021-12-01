/*      DESKMENU.C              3/16/89 - 9/18/89       Derek Mui       */
/*      Put o_select and x_select into menu_verify      7/3/90  D.Mui   */
/*      Scan ascii '>' instead of whole scan code       7/12/90 D.Mui   */
/*      Two new help menu               7/12/90         D.Mui           */
/*      Display print screen if it is ST mode   7/31/90 D.Mui           */
/*      Fix the alt drive table                 8/27/90 D.Mui           */
/*      Use m_cpu to determine cache or no cache        9/19/90 D.Mui   */
/*      Fix at read_inf to read file only       7/15/91 D.Mui           */
/*      Changes to do_opt()                    07/07/92 C.Gee           */
/*        - Call mv_desk() instead of av_desk()                         */
/*        - Call mins_app() instead of ins_app()                        */
/*        - Call mdesk_pref() instead of desk_pref()                    */
/*        - Add set_video() to do_opt()                                 */
/*      Changes to tb3[] - added VIDITEM object                         */
/*      Changes to hdkeybd() - added VIDITEM object                     */


/************************************************************************/
/*      New Desktop for Atari ST/TT Computer                            */
/*      Atari Corp                                                      */
/*      Copyright 1989,1990     All Rights Reserved                     */
/************************************************************************/

#include "desktop.h"

int16_t d_exit;		/* desktop exit flag	*/

/* Alternate keys table */

/* USA|UK|SPAIN|ITALY|SWEDEN */
#if (OS_COUNTRY == CTRY_US) | (OS_COUNTRY == CTRY_UK) | (OS_COUNTRY == CTRY_ES) | (OS_COUNTRY == CTRY_IT) | (OS_COUNTRY == CTRY_SE)
static int16_t const keytable[] = {
	0x1e00,	/* ALT-'A' */
	0x3000, /* ALT-'B' */
	0x2e00, /* ALT-'C' */
	0x2000, /* ALT-'D' */
	0x1200, /* ALT-'E' */
	0x2100, /* ALT-'F' */
	0x2200, /* ALT-'G' */
	0x2300, /* ALT-'H' */
	0x1700, /* ALT-'I' */
	0x2400, /* ALT-'J' */
	0x2500, /* ALT-'K' */
	0x2600, /* ALT-'L' */
	0x3200, /* ALT-'M' */
	0x3100, /* ALT-'N' */
	0x1800, /* ALT-'O' */
	0x1900, /* ALT-'P' */
	0x1000, /* ALT-'Q' */
	0x1300, /* ALT-'R' */
	0x1f00, /* ALT-'S' */
	0x1400, /* ALT-'T' */
	0x1600, /* ALT-'U' */
	0x2f00, /* ALT-'V' */
	0x1100, /* ALT-'W' */
	0x2d00, /* ALT-'X' */
	0x1500, /* ALT-'Y' */
	0x2c00, /* ALT-'Z' */
	0
};
#endif

#if (OS_COUNTRY == CTRY_DE) | (OS_COUNTRY == CTRY_SF) | (OS_COUNTRY == CTRY_SG) | (OS_COUNTRY == CTRY_PL) | (OS_COUNTRY == CTRY_CZ)
/* GERMANY|SWISSFRE|SWISSGER */
static int16_t const keytable[] = {
	0x1e00,	/* ALT-'A' */
	0x3000, /* ALT-'B' */
	0x2e00, /* ALT-'C' */
	0x2000, /* ALT-'D' */
	0x1200, /* ALT-'E' */
	0x2100, /* ALT-'F' */
	0x2200, /* ALT-'G' */
	0x2300, /* ALT-'H' */
	0x1700, /* ALT-'I' */
	0x2400, /* ALT-'J' */
	0x2500, /* ALT-'K' */
	0x2600, /* ALT-'L' */
	0x3200, /* ALT-'M' */
	0x3100, /* ALT-'N' */
	0x1800, /* ALT-'O' */
	0x1900, /* ALT-'P' */
	0x1000, /* ALT-'Q' */
	0x1300, /* ALT-'R' */
	0x1f00, /* ALT-'S' */
	0x1400, /* ALT-'T' */
	0x1600, /* ALT-'U' */
	0x2f00, /* ALT-'V' */
	0x1100, /* ALT-'W' */
	0x2d00, /* ALT-'X' */
	0x2c00, /* ALT-'Y' */
	0x1500, /* ALT-'Z' */
	0
};
#endif

#if (OS_COUNTRY == CTRY_FR)
/* FRENCH */
static int16_t const keytable[] = {
	0x1000,	/* ALT-'A' */
	0x3000, /* ALT-'B' */
	0x2e00, /* ALT-'C' */
	0x2000, /* ALT-'D' */
	0x1200, /* ALT-'E' */
	0x2100, /* ALT-'F' */
	0x2200, /* ALT-'G' */
	0x2300, /* ALT-'H' */
	0x1700, /* ALT-'I' */
	0x2400, /* ALT-'J' */
	0x2500, /* ALT-'K' */
	0x2600, /* ALT-'L' */
	0x2700, /* ALT-'M' */
	0x3100, /* ALT-'N' */
	0x1800, /* ALT-'O' */
	0x1900, /* ALT-'P' */
	0x1e00, /* ALT-'Q' */
	0x1300, /* ALT-'R' */
	0x1f00, /* ALT-'S' */
	0x1400, /* ALT-'T' */
	0x1600, /* ALT-'U' */
	0x2f00, /* ALT-'V' */
	0x2c00, /* ALT-'W' */
	0x2d00, /* ALT-'X' */
	0x1500, /* ALT-'Y' */
	0x1100, /* ALT-'Z' */
	0
};
#endif


/* Control keys table */

/* USA|UK|SPAIN|ITALY|SWEDEN */
#if (OS_COUNTRY == CTRY_US) | (OS_COUNTRY == CTRY_UK) | (OS_COUNTRY == CTRY_ES) | (OS_COUNTRY == CTRY_IT) | (OS_COUNTRY == CTRY_SE)
/* USA|UK|SPAIN|ITALY|SWEDEN */
static int16_t const contable[] = {
	0x1e01,	/* CTRL-'A' */
	0x3002, /* CTRL-'B' */
	0x2e03, /* CTRL-'C' */
	0x2004, /* CTRL-'D' */
	0x1205, /* CTRL-'E' */
	0x2106, /* CTRL-'F' */
	0x2207, /* CTRL-'G' */
	0x2308, /* CTRL-'H' */
	0x1709, /* CTRL-'I' */
	0x240a, /* CTRL-'J' */
	0x250b, /* CTRL-'K' */
	0x260c, /* CTRL-'L' */
	0x320d, /* CTRL-'M' */
	0x310e, /* CTRL-'N' */
	0x180f, /* CTRL-'O' */
	0x1910, /* CTRL-'P' */
	0x1011, /* CTRL-'Q' */
	0x1312, /* CTRL-'R' */
	0x1f13, /* CTRL-'S' */
	0x1414, /* CTRL-'T' */
	0x1615, /* CTRL-'U' */
	0x2f16, /* CTRL-'V' */
	0x1117, /* CTRL-'W' */
	0x2d18, /* CTRL-'X' */
	0x1519, /* CTRL-'Y' */
	0x2c1a, /* CTRL-'Z' */
	0
};
#endif

#if (OS_COUNTRY == CTRY_DE) | (OS_COUNTRY == CTRY_SF) | (OS_COUNTRY == CTRY_SG) | (OS_COUNTRY == CTRY_PL) | (OS_COUNTRY == CTRY_CZ)
/* GERMANY|SWISSFRE|SWISSGER */
static int16_t const contable[] = {
	0x1e01,	/* CTRL-'A' */
	0x3002, /* CTRL-'B' */
	0x2e03, /* CTRL-'C' */
	0x2004, /* CTRL-'D' */
	0x1205, /* CTRL-'E' */
	0x2106, /* CTRL-'F' */
	0x2207, /* CTRL-'G' */
	0x2308, /* CTRL-'H' */
	0x1709, /* CTRL-'I' */
	0x240a, /* CTRL-'J' */
	0x250b, /* CTRL-'K' */
	0x260c, /* CTRL-'L' */
	0x320d, /* CTRL-'M' */
	0x310e, /* CTRL-'N' */
	0x180f, /* CTRL-'O' */
	0x1910, /* CTRL-'P' */
	0x1011, /* CTRL-'Q' */
	0x1312, /* CTRL-'R' */
	0x1f13, /* CTRL-'S' */
	0x1414, /* CTRL-'T' */
	0x1615, /* CTRL-'U' */
	0x2f16, /* CTRL-'V' */
	0x1117, /* CTRL-'W' */
	0x2d18, /* CTRL-'X' */
	0x2c19, /* CTRL-'Y' */
	0x151a, /* CTRL-'Z' */
	0
};
#endif

#if (OS_COUNTRY == CTRY_FR)
/* FRENCH */
static int16_t const contable[] = {
	0x1001,	/* CTRL-'A' */
	0x3002, /* CTRL-'B' */
	0x2e03, /* CTRL-'C' */
	0x2004, /* CTRL-'D' */
	0x1205, /* CTRL-'E' */
	0x2106, /* CTRL-'F' */
	0x2207, /* CTRL-'G' */
	0x2308, /* CTRL-'H' */
	0x1709, /* CTRL-'I' */
	0x240a, /* CTRL-'J' */
	0x250b, /* CTRL-'K' */
	0x260c, /* CTRL-'L' */
	0x270d, /* CTRL-'M' */
	0x310e, /* CTRL-'N' */
	0x180f, /* CTRL-'O' */
	0x1910, /* CTRL-'P' */
	0x1e11, /* CTRL-'Q' */
	0x1312, /* CTRL-'R' */
	0x1f13, /* CTRL-'S' */
	0x1414, /* CTRL-'T' */
	0x1615, /* CTRL-'U' */
	0x2f16, /* CTRL-'V' */
	0x2c17, /* CTRL-'W' */
	0x2d18, /* CTRL-'X' */
	0x1519, /* CTRL-'Y' */
	0x111a, /* CTRL-'Z' */
	0
};
#endif

/* Arrow keys table */
static int16_t const arrowtab[] = {
	0x4d36, 0x5032, 0x4838, 0x4b34, 0x4800, 0x5000, 0x4d00,	0x4b00, 0
};

/* Arrow keys Message */
static int16_t const arrowimg[] = { 5, 1, 0, 4, 2, 3, 7, 6 };

static int16_t const xxxview[9] = {
	ICONITEM, TEXTITEM, 0, NAMEITEM, DATEITEM, SIZEITEM,
	TYPEITEM, 0
};

/* Alternate Number Table */

static int16_t const altnum[] = { 0x7800, 0x7900, 0x7a00, 0x7c00, 0x7d00, 0x7b00, 0 };

BOOLEAN o_status;							/* for o_select */
DESKWIN *o_win;
int16_t o_type;
int16_t o_item;


int16_t loop_find PROTO((int16_t input, const int16_t *table, int16_t *index));
VOID hd_keybd PROTO((uint16_t key));
VOID do_scroll PROTO((int16_t *msgbuff));
VOID do_opt PROTO((int16_t msgbuff));
VOID hd_menu PROTO((int16_t *msgbuff));



/*
 * Loop to find matching array
 */
/* 306de: 00e2ddbc */
int16_t loop_find(P(int16_t) input, P(const int16_t *) table, P(int16_t *)index)
PP(int16_t input;)
PP(const int16_t *table;)
PP(int16_t *index;)
{
	register int16_t i;

	i = 0;

	while (table[i])
	{
		if (input == table[i])
		{
			*index = i;
			return TRUE;
		} else
		{
			i++;
		}
	}

	return FALSE;
}


/*
 * Enable or disable the menu item according to current status
 */
/* 306de: 00e2de02 */
VOID menu_verify(NOTHING)
{
	int16_t enable;
	register int16_t i;
	DESKWIN *win;
	int16_t type;
	const char *str;

	UNUSED(win);

	/* If there is a window opened/closed check to see if there is anything selected */
	o_select();
	x_select();

	enable = winhead->w_id == -1 ? FALSE : TRUE;

	i = 0;

	if (x_status)
	{
		enable = TRUE;
		if (x_type == WINICON)
			i = 1;
	} else
	{
		enable = FALSE;
	}
	
	enable = x_first(&str, &type);

	menu_ienable(thedesk->rtree[ADMENU], IAPPITEM, enable);

	enable = FALSE;

	if (w_gfirst())
	{
		if (w_gnext())
			enable = TRUE;

		menu_ienable(thedesk->rtree[ADMENU], SHOWITEM, TRUE);
	}

	ch_cache(FALSE);
#ifdef PRINTITEM /* take out for sparrow */
	menu_ienable(thedesk->rtree[ADMENU], PRINTITEM, gl_restype <= 3 ? TRUE : FALSE);
#endif
}


/*
 * Handle the keyboard
 */
/* 206de: 00e2a5be */
/* 306de: 00e2e024 */
VOID hd_keybd(P(uint16_t) key)
PP(uint16_t key;)
{
	OBJECT *obj;
	register DESKWIN *win;
	register int16_t item;
	int16_t msgbuff[8];
	char buffer[NAMELEN];
	int16_t i;
	char *str;
	APP *app;

	UNUSED(str);
	UNUSED(obj);
	
	win = get_top();

	item = toupper(key);

	{
		if (loop_find(key, altnum, &i))
		{
			if (restable[i])
			{
				if (app_reschange(i + 1))
				{
					d_exit = L_CHGRES;
					return;
				}
			}
		}
	}

	/* open a disk drive */
	if (loop_find(key, keytable, &i))
	{
		if (win)
			clr_xwin(win, TRUE);
	hx_1:
		strcpy(buffer, wildext);
		buffer[0] = i + 'A';
		open_disk(0, buffer, TRUE);
		return;
	}

	if (loop_find(key, contable, &i))
	{
		if (ch_drive(i + 'A'))
		{
			if (win)					/* replace top window   */
			{
				strcpy(win->w_buf, win->w_path);
				strcpy(buffer, g_name(win->w_path));
				strcpy(win->w_path, wildext);
				win->w_path[0] = i + 'A';
				rep_path(buffer, win->w_path);
				if (!up_win(win, FALSE))
					strcpy(win->w_path, win->w_buf);
				return;
			} else						/* open a window    */
				goto hx_1;
		}
	}

	if (win)							/* there is a window    */
	{
		if (loop_find(key, arrowtab, &i))
		{
			msgbuff[0] = WM_ARROWED;
			msgbuff[3] = win->w_id;
			msgbuff[4] = arrowimg[i];
#if !BINEXACT
			/* BUG: was uninitialized */
			msgbuff[5] = 0;
			msgbuff[6] = 0;
			msgbuff[7] = 0;
#endif
			do_scroll(msgbuff);
			return;
		}
	}

	if (item == 0x0D)					/* return       */
	{
		clr_allwin();					/* deselect all items   */
		clr_dicons();
	}

	if (item == 0x1B)					/* escape       */
	{
		if (win)						/* update top window    */
			up_win(win, TRUE);
	}
}


/* 206de: 00e2a9e8 */
/* 306de: 00e2e44e */
VOID do_scroll(P(int16_t *)msgbuff)
PP(int16_t *msgbuff;)
{
	register int16_t act;
	register DESKWIN *win;
	int16_t bdown, x, y;

	act = msgbuff[4];

	if ((win = get_win(msgbuff[3])) != NULL)
	{
		switch (act)
		{
		case WA_DNPAGE:						/* page down */
		case WA_UPPAGE:						/* page up */
			srl_row(win, win->w_xrow, act == WA_DNPAGE ? SDOWN : SUP);
			break;

		case WA_DNLINE:						/* arrow down */
		case WA_UPLINE:						/* arrow up */
			do {
				srl_row(win, 1, act == WA_UPLINE ? SUP : SDOWN);
				graf_mkstate(&x, &y, &bdown, &x);
			} while (bdown);
			break;

		case WA_RTPAGE:						/* page left or right */
		case WA_LFPAGE:
			srl_col(win, win->w_xcol, act == WA_LFPAGE ? SRIGHT : SLEFT); /* hhmm? */
			break;

		case WA_RTLINE:
		case WA_LFLINE:						/* scroll left */
			do {
				srl_col(win, 1, act == WA_LFLINE ? SRIGHT : SLEFT); /* hhmm? */
				graf_mkstate(&x, &y, &bdown, &x);
			} while (bdown);
			break;
		}
	}
}



/*
 * Do the option menu
 */
/* 206de. 00e2aaf8 */
/* 306de: 00e2e55e */
VOID do_opt(P(int16_t) msgbuff)
PP(int16_t msgbuff;)
{
	register OBJECT *obj;
	int16_t ret, button, handle;
	char buffer[16];
	const char *str;

	UNUSED(obj);
	
	switch (msgbuff)
	{
	case IDSKITEM:						/* install disk icon    */
		if (x_status)
		{
			if (x_type == DESKICON)
				goto opt1;
			else
				goto opt2;
		}

		{
		opt2:
			/* ins_wicons() */;
		}
		if (ret == 1)
		{
		opt1:
			ins_icons();
		}
		break;

	case IAPPITEM:
		if (x_first(&str, &button))
			ins_app();
		break;

	case PREFITEM:						/* desktop preference   */
		desk_pref();
		break;

	case SAVEITEM:						/* save desktop     */
		if (do1_alert(SAVETOP) == 1)
			save_inf(TRUE);
		break;

#ifdef PRINTITEM								/* take out for sparrow */
	case PRINTITEM:						/* print screen     */
		if (!(thedesk->rtree[ADMENU][PRINTITEM].ob_state & DISABLED))
		{
			if (do1_alert(PRINTTOP) == 1)
			{
				desk_wait(TRUE);
				av_hardcopy();
				desk_wait(FALSE);
			}
		}
		break;
#endif

#ifdef BITBLT
	case BITBLT:
		thedesk->cbit_save = !thedesk->cbit_save;
		ch_cache(TRUE);
		break;
#endif
	}
}


/*
 * Do the sorting menu
 */
/* 306de: 00e2e812 */
VOID do_view(P(int16_t) msgbuff)
PP(int16_t msgbuff;)
{
	int16_t mode, i;

#if !BINEXACT
	i = 0; /* quiet compiler */
#endif
	switch (msgbuff)
	{
	case ICONITEM:						/* show as icon */
		mode = S_ICON;
		goto v_1;

	case TEXTITEM:						/* show as text */
		mode = S_TEXT;
	v_1:
		i = 0;
		if (mode == thedesk->s_view)				/* No change    */
			break;

		thedesk->s_view = mode;
		sort_show(0, TRUE);
		break;

	case NAMEITEM:
		mode = S_NAME;
		goto v_2;

	case DATEITEM:
		mode = S_DATE;
		goto v_2;

	case SIZEITEM:
		mode = S_SIZE;
		goto v_2;

	case TYPEITEM:
		mode = S_TYPE;

	v_2:
		i = 3;
		if (mode == thedesk->s_sort)				/* No change    */
			break;
		thedesk->s_sort = mode;
		sort_show(thedesk->s_sort, FALSE);
		break;
	}

  	while (xxxview[i])
		menu_icheck(thedesk->rtree[ADMENU], xxxview[i++], 0);

	menu_icheck(thedesk->rtree[ADMENU], msgbuff, 1);
}


/*
 * Do the file menu
 */
/* 306de: 00e2e958 */
VOID do_file(P(int16_t) msgbuff)
PP(int16_t msgbuff;)
{
	OBJECT *obj;
	int16_t ret, type;
	register DESKWIN *win;
	char buffer[NAMELEN];
	char buf2[NAMELEN];
	const char *str;
	const char *str1;

	win = get_top();

	switch (msgbuff)
	{
	case OPENITEM:
		if (o_status)
			open_item(o_item, o_type, o_win);
		else
			launch_pref();
		break;

	case SHOWITEM:
		show_item();
		break;

	case NEWFITEM:
		if (win)
			newfolder(win);
		break;

	case CLSFITEM:
		if (win)
			close_path(win);			/* close one path   */
		break;

	case CLSWITEM:						/* close the top window */
		close_top();
		break;

	case FORMITEM:
		str = "A";

		if (x_status && x_type == DESKICON)
		{
			ret = x_first(&str1, &type);
			while (ret)
			{
				if (type == DISK)
				{
					if (*str1 == 'A' || *str1 == 'B')
					{
						str = str1;
						break;
					}
				}
				ret = x_next(&str1, &type);
			}
		}

		fc_start(str, CMD_FORMAT);
		clr_dicons();
		break;
	}
}


/*
 * Handle Menu
 */
/* 306de: 00e2eb92 */
VOID hd_menu(P(int16_t *)msgbuff)
PP(int16_t *msgbuff;)
{
	switch (msgbuff[3])
	{
	case DESKMENU:
		/* roton(); */
		fmdodraw(ADDINFO, 0);
		/* rotoff(); */
		break;

	case FILEMENU:
		do_file(msgbuff[4]);
		break;

	case VIEWMENU:
		do_view(msgbuff[4]);
		break;

	case OPTNMENU:
		do_opt(msgbuff[4]);
		break;
	}

	menu_tnormal(thedesk->rtree[ADMENU], msgbuff[3], 1);
}


/*
 * Handle all the different messages
 */
/* 306de: 00e2ec12 */
VOID hd_msg(NOTHING)
{
	register int d7;
	register int d6;
	register int16_t handle;
	register DESKWIN *win;
	register THEDSK *d;
	register OBJECT *obj;
	int16_t shrink;
	int16_t x, y, w, h;
	GRECT pt;
	GRECT *pc;

	d = thedesk;
	d7 = d6 = 0;
	
	UNUSED(w);
	UNUSED(h);
	UNUSED(y);
	
	switch (d->p_msgbuf[0])
	{
	case WM_REDRAW:
	case WM_TOPPED:
	case WM_CLOSED:
	case WM_ARROWED:
	case WM_HSLID:
	case WM_VSLID:
	case WM_MOVED:
	case WM_FULLED:
	case WM_SIZED:
		break;
	}
	if (d->p_msgbuf[0] == MN_SELECTED)
	{
		hd_menu(d->p_msgbuf);
	} else
	{
		pc = (GRECT *)&d->p_msgbuf[4];				/* pc == msgbuff[4,5,6,7]   */
		handle = d->p_msgbuf[3];

		if (!(win = get_win(handle)))
			return;

		obj = win->w_obj;

		switch (d->p_msgbuf[0])
		{
		case WM_REDRAW:
		case WM_USER:
			do_redraw(handle, pc, 0);
			return;

		case WM_TOPPED:
		case WM_NEWTOP:
			clr_allwin();
			wind_set(handle, WF_TOP, 0, 0, 0, 0);
			make_top(win);
			return;
		}

		if (handle != get_top()->w_id)
			return;

		switch (d->p_msgbuf[0])
		{
		case WM_CLOSED:				/* close one path   */
			close_path(win);
			break;

		case WM_ARROWED:
			do_scroll(d->p_msgbuf);
			break;

		case WM_HSLID:
			srl_hzbar(win, d->p_msgbuf[4]);
			break;

		case WM_VSLID:
			srl_verbar(win, d->p_msgbuf[4]);
			break;

		case WM_MOVED:					/* set the current x,y,w,h  */
			do_xyfix((GRECT *)&d->p_msgbuf[4]);
			wind_set(handle, WF_CURRXYWH, d->p_msgbuf[4], d->p_msgbuf[5], d->p_msgbuf[6], d->p_msgbuf[7]);

			/* set the position offset  */
			obj[0].ob_x += d->p_msgbuf[4] - win->w_sizes.g_x;
			obj[0].ob_y += d->p_msgbuf[5] - win->w_sizes.g_y;
			rc_copy(pc, &win->w_sizes);

			wind_get(handle, WF_WORKXYWH, &d->p_msgbuf[4], &d->p_msgbuf[5], &d->p_msgbuf[6], &d->p_msgbuf[7]);

			rc_copy(pc, &win->w_work);
			break;

		case WM_FULLED:
			wind_get(handle, WF_CURRXYWH, &d->p_msgbuf[4], &d->p_msgbuf[5], &d->p_msgbuf[6], &d->p_msgbuf[7]);

			/* already in full size     */
			if (rc_equal((GRECT *)&d->p_msgbuf[4], &thedesk->full))
			{							/* so shrink it         */
				wind_get(handle, WF_PREVXYWH, &d->p_msgbuf[4], &d->p_msgbuf[5], &d->p_msgbuf[6], &d->p_msgbuf[7]);
				form_dial(2, pc->g_x, pc->g_y, pc->g_w, pc->g_h, thedesk->full.g_x, thedesk->full.g_y, thedesk->full.g_w, thedesk->full.g_h);
			} else
			{
				rc_copy(&thedesk->full, pc);		/* calculate the center point   */
				rc_copy(&win->w_sizes, &pt);
				rc_center(&pt, &pt);
				/* form grow box        */
				form_dial(1, pt.g_x, pt.g_y, pt.g_w, pt.g_h, pc->g_x, pc->g_y, pc->g_w, pc->g_h);
			}

		case WM_SIZED:
			do_xyfix((GRECT *)&d->p_msgbuf[4]);
			wind_set(handle, WF_CURRXYWH, d->p_msgbuf[4], d->p_msgbuf[5], d->p_msgbuf[6], d->p_msgbuf[7]);

			rc_copy(pc, &win->w_sizes);

			wind_get(handle, WF_WORKXYWH, &obj->ob_x, &obj->ob_y, &obj->ob_width, &obj->ob_height);

			shrink = FALSE;

			if (obj->ob_width < win->w_work.g_w && obj->ob_height <= win->w_work.g_h)
				shrink = TRUE;

			if (obj->ob_height < win->w_work.g_h && obj->ob_width <= win->w_work.g_w)
				shrink = TRUE;

			rc_copy((GRECT *)&obj->ob_x, &win->w_work);

			ch_path(win);

			if (shrink)
				x = win->w_xcol;

			view_adjust(win);			/* adjust parameter */
			break;

		default:
			break;
		}
	}
}


/*
 * Handle all the events
 */
/* 306de: 00e2f07c */
VOID actions(NOTHING)
{
	int16_t event, kstate, kreturn, button, clicks;
	int16_t mx, my;
	int16_t msgbuff[8];

	d_exit = L_NOEXIT;

	while (d_exit == L_NOEXIT)
	{
		menu_verify();
		q_write();						/* update inf file  */
		event = evnt_multi(MU_MESAG | MU_BUTTON | MU_KEYBD, 2, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, thedesk->p_msgbuff,	/* message buffer   */
					0, 0,		/* timer counter    */
					&mx, &my, &button, &kstate, &kreturn, &clicks);

		wind_update(TRUE);

		if (event & MU_MESAG)
			hd_msg(msgbuff);

		if (event & MU_KEYBD)
			hd_keybd(kreturn);

		if (event & MU_BUTTON)
			hd_button(clicks, kstate, mx, my);

		wind_update(FALSE);
	}
}


/*
 * Find out available memory
 */
/* 306de: 00e2f15c */
int32_t av_mem(NOTHING)
{
	register char *start;
	register char *addr;
	register char **new;
	int32_t total, size;

	total = 0;
	start = (char *) 0;

	while (TRUE)
	{
		size = Malloc(0xFFFFFFFFL);
		if (size >= sizeof(char *))
		{
			addr = (char *)Malloc(size);
			total += size;
			if (!start)
				start = addr;
			else
				*new = addr;

			new = (char **)addr;
		} else
		{
			if (start)
				*new = NULL;
			break;
		}
	}

	if (start)
	{
		new = (char **)start;

		while (new)
		{
			addr = *new;
			Mfree(new);
			new = (char **)addr;
		}
	}

	return total;
}
