/*      DESKINS.C               3/18/89 - 9/18/89       Derek Mui       */
/*      Fix at ins_app, at app_free. Do the str check before freeing    */
/*      the app                 3/3/92                  D.Mui           */
/*      Change all the iconblk to ciconblk      7/11/92 D.Mui           */
/*      Change at ins_wicons and ins_icons      7/11/92 D.Mui           */
/*      Changed arrows at install desk icons    8/06/92 cjg             */
/*      and install window icons to invert                              */
/*      when selected.                                                  */


/************************************************************************/
/*      New Desktop for Atari ST/TT Computer                            */
/*      Atari Corp                                                      */
/*      Copyright 1989,1990     All Rights Reserved                     */
/************************************************************************/

#include "desktop.h"




/*
 * Install application
 */
/* 306de: 00e2cacc */
VOID ins_app(NOTHING)
{
	register OBJECT *obj;
	register APP *app;
	APP *sapp;
	int16_t install, ret, newapp;
	int16_t cont, setdir, dofull, where;
	int16_t type, sret, icon, graphic;
	const char *str;
	char buffer[8];
	int32_t l;

	cont = TRUE;
	obj = NULL;

	cont = x_first(&str, &type);

	while (cont)
	{
		if (type != WINICON)
			goto is_1;

		if (install)					/* Not an application   */
			goto is_1;

		obj = get_tree(ADINSAPP);

		icon = app->a_icon;
		/* if it is a wild card match */
		if (*scasb(app->a_name, '*') == '*')
			newapp = TRUE;				/* then we need app         */
		else
			newapp = FALSE;

		if (!thedesk->autofile[0])
			ret = FALSE;
		else							/* skip the graphic flag */
			ret = streq(str, &thedesk->autofile[3]);

		sret = ret ? TRUE : FALSE;
		obj[AUTOBOX].ob_state = ret ? SELECTED : NORMAL;
		obj[NORMALBOX].ob_state = ret ? NORMAL : SELECTED;

		obj[APGEM].ob_state = NORMAL;
		obj[APDOS].ob_state = NORMAL;
		obj[APPARMS].ob_state = NORMAL;

		inf_sset(obj, APDFTYPE, newapp ? Nostr : &app->a_doc[2]);
		xinf_sset(obj, APNAME, g_name(str));

		switch (app->a_type)
		{
		case PRG:
			ret = APGEM;
			break;

		case TTP:
			ret = APPARMS;
			break;

		case TOS:
			ret = APDOS;
			break;

		default:
			fill_string(str, STNOMEM);
			goto is_1;
		}

		obj[ret].ob_state = SELECTED;

		fm_draw(ADINSAPP);
		where = 0;
	ins_2:
		ret = xform_do(obj, where);

		if (ret == APCANCEL)
		{
			cont = FALSE;
			goto is_1;
		}

		if (ret == APOK)				/* install          */
		{								/* do we need a new one?    */
			/* check function key */
			if (newapp)
			{							/* get the Function key definition */
				app = app_alloc();		/* app_alloc will clean up doc  */
				if (!app)
				{
					do1_alert(NOAPP);
					goto ins_6;
				}
			} else						/* clean up the old define  */
			{
				app->a_doc[0] = 0;
			}
			
			/* get the doc icon type    */
			strcpy(buffer, "*.");
			fs_sget((LPTREE)obj, APDFTYPE, &buffer[2]);

			lp_fill(str, &app->a_name);
			lp_collect();

			strcpy(app->a_doc, buffer);
			graphic = 1;

			if (obj[APGEM].ob_state & SELECTED)
				type = PRG;

			if (obj[APDOS].ob_state & SELECTED)
			{
				graphic = 0;
				type = TOS;
			}

			if (obj[APPARMS].ob_state & SELECTED)
			{
				graphic = 0;
				type = TTP;
			}

			app->a_type = type;
			app->a_icon = icon;

			if (obj[AUTOBOX].ob_state & SELECTED)
			{
				if (*str)
				{
					if ((int)strlen(str) < (PATHLEN - 4))
					{
						save_2(thedesk->autofile, graphic);
						thedesk->autofile[2] = ' ';
						strcpy(&thedesk->autofile[3], str);
					} else
					{
						do1_alert(STNOMEM);
					}
				}
			} else
			{
				if (sret)				/* change from auto to normal   */
					strcpy(thedesk->autofile, Nostr);
			}
		}
		/* OK to install */
		if (ret == APREMOVE)
		{
			if (!newapp)
				app_free(app);
			if (*str)
				strcpy(thedesk->autofile, Nostr);
		}

	is_1:
		if (cont == FALSE)
			break;

		cont = x_next(&str, &type);
	}

ins_6:
	if (obj)
		do_finish(ADINSAPP);
	else
		do1_alert(STNOMEM);
}


/*
 * Install desktop icons
 */
/* 306de: 00e2d086 */
VOID ins_icons(NOTHING)
{
	register OBJECT *obj;
	register CICONBLK *iblk;
	register OBJECT *obj1;
	register int16_t type, item, icon, style;
	int16_t ret, limit, redraw, select, xitem;
	int16_t driver, quit, which;
	char buf1[2];
	char idbuffer[2];
	char buffer[14];
	GRECT pt;

	quit = FALSE;
	xitem = item = o_item;
	obj = get_tree(ADINSDIS);
	idbuffer[1] = 0;
	obj1 = background;
	limit = numicon;					/* max number of icon   */

#if !BINEXACT
	which = ret = 0; /* quiet compiler */
#endif

	while (TRUE)
	{
		redraw = FALSE;

		if (o_status)					/* an icon is selected  */
		{
			type = backid[item].i_type;
			strcpy(buffer, ((CICONBLK *) (obj1[item].ob_spec))->monoblk.ib_ptext);
			buf1[0] = idbuffer[0] = backid[item].i_iblk.ib_char;
			icon = backid[item].i_icon;
			if (icon >= numicon)
				icon = numicon - 1;
		} else							/* no icon is selected  */
		{
			buffer[0] = 0;
			idbuffer[0] = 0;
			icon = 0;
			type = DISK;
			buf1[0] = 0;
		}

		driver = TRUE;
		style = NORMAL;
		select = EDITABLE;

		obj[DRID].ob_flags = select;
		obj[DRID].ob_state = style;

		if (driver)
			obj[ret].ob_state = SELECTED;

		cp_iblk(get_icon(icon), &iblk->monoblk);

		iblk->monoblk.ib_char = 0;

		inf_sset(obj, DRLABEL, buffer);
		inf_sset(obj, DRID, idbuffer);

	in_5:
		fm_draw(ADINSDIS);

	in_2:
		ret = xform_do(obj, 0);

		if (ret == DRCANCEL)
		{
			quit = TRUE;
			goto in_1;
		}

		if (ret == DRREMOVE)				/* skip */
			goto in_1;
		/* this is install  */
		fs_sget((LPTREE)obj, DRID, idbuffer);

		if (idbuffer[0] != CHAR_FOR_CARTRIDGE)
			idbuffer[0] = toupper(idbuffer[0]);

		if (o_status)					/* icon selected    */
			goto in_4;					/* don't allocate   */

	in_41:
		if ((item = av_icon()) == -1)	/* get new one  */
		{
			do1_alert(NOICON);
			goto in_1;
		}

	in_4:
		redraw = TRUE;				/* user selected OK */
		iblk = (CICONBLK *) (obj1[item].ob_spec);
		cp_iblk(get_icon(icon), &iblk->monoblk);
		backid[item].i_icon = icon;

		strcpy(iblk->monoblk.ib_ptext, ((TEDINFO *) (obj[DRLABEL].ob_spec))->te_ptext);

		if (driver)
		{
			if (!which)					/* Disk Drive   */
			{
				type = DISK;
				iblk->monoblk.ib_char = idbuffer[0];
			} else
			{
				iblk->monoblk.ib_char = 0;
			}
		} else
		{
			iblk->monoblk.ib_char = 0;
		}
		
		backid[item].i_type = type;
	in_1:
		if (redraw)
		{
			pt.g_x = obj1[0].ob_x + obj1[item].ob_x;
			pt.g_y = obj1[0].ob_y + obj1[item].ob_y;
			pt.g_w = obj1[item].ob_width;
			pt.g_h = obj1[item].ob_height;
			do_redraw(0, &pt, 0);
		}

		if (quit)
			break;

		xitem++;

		if (!i_next(xitem, obj1, &xitem))
			break;

		item = xitem;

	}									/* while */

	do_finish(ADINSDIS);
}




/* 306de: 00e2d47e */
VOID cp_iblk(P(const ICONBLK *)src_iblk, P(ICONBLK *)dest_iblk)
PP(register const ICONBLK *src_iblk;)
PP(register ICONBLK *dest_iblk;)
{
	dest_iblk->ib_pmask = src_iblk->ib_pmask;
	dest_iblk->ib_pdata = src_iblk->ib_pdata;
	dest_iblk->ib_char = src_iblk->ib_char;
	dest_iblk->ib_xchar = src_iblk->ib_xchar;
	dest_iblk->ib_ychar = src_iblk->ib_ychar;
}



/*
 * Delay the icon scrolling
 */
/* 306de: 00e2d9e8 */
VOID cl_delay(NOTHING)
{
	int32_t i, j;

	j = 100000;
	i = evnt_dclick(0, 0);
	if (i)
		j = j / i;
	for (i = 0; i < j; i++)
	{
	}
}
