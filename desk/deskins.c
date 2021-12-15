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
#include "taddr.h"


/* 104de: 00fd87dc */
/* 106de: 00e19344 */
BOOLEAN ins_disk(P(APP *) app)
PP(register APP *app;)
{
	register LPTREE tree;
	register APP *newapp;
	register APP *a;
	register BOOLEAN redraw;
	register BOOLEAN found;
	char driveid[2];
	char label[14];
	char newdrive[2];
	char newlabel[14];
	int ret;
	
	tree = (LPTREE)thedesk->g_atree[ADINSDIS];
	driveid[0] = app->a_char;
	driveid[1] = '\0';
	strcpy(label, app->a_pappl);
	inf_sset((OBJECT *)tree, DRID, driveid);
	inf_sset((OBJECT *)tree, DRLABEL, label);
	redraw = FALSE;
	ret = xform_do((OBJECT *)tree, ROOT);
	fs_sget(tree, DRID, newdrive);
	fs_sget(tree, DRLABEL, newlabel);
	if (ret == DRCANCEL)
		return FALSE;
	if (newdrive[0] == ' ' || newdrive[0] == '\0')
		return FALSE;
	if (newdrive[0] != CHAR_FOR_CARTRIDGE)
		newdrive[0] = toupper(newdrive[0]);
	if (newdrive[0] != driveid[0])
	{
		a = thedesk->applist;
		found = FALSE;
		while (a != NULL)
		{
			if (a->a_char == newdrive[0])
			{
				found = TRUE;
				app = a;
				break;
			} else
			{
				a = a->a_next;
			}
		}
	} else
	{
		found = TRUE;
	}
	if (ret == DRREMOVE)
	{
		if (found)
			app_free(app);
		return found;
	} else
	{
		if (!found)
		{
			redraw = TRUE;
			newapp = app_alloc(FALSE);
			if (newapp != NULL)
			{
				newapp->a_apptype = app->a_apptype;
				newapp->a_type = newdrive[0] != CHAR_FOR_CARTRIDGE ? AT_ISDISK : AT_ISCART;
				newapp->a_obid = app->a_obid;
				newapp->a_aicon = app->a_aicon;
				newapp->a_dicon = -1;
				if (app->a_x < gl_width / 2)
					newapp->a_x = thedesk->r_dicon.g_w + app->a_x;
				else
					newapp->a_x = app->a_x - thedesk->r_dicon.g_w;
				if (app->a_y < (gl_height - gl_hbox) / 2)
					newapp->a_y = thedesk->r_dicon.g_h + app->a_y;
				else
					newapp->a_y = app->a_y - thedesk->r_dicon.g_h;
				newapp->a_y = thedesk->dicon.g_h + app->a_y;
				app_mtoi(newapp->a_x, newapp->a_y, &newapp->a_x, &newapp->a_y);
				app = newapp;
			} else
			{
				fun_alert(1, NOICON, NULL);
				return FALSE;
			}
		}
		app->a_char = newdrive[0];
		if (!streq(newlabel, label))
			redraw = TRUE;
		newlabel[(int)strlen(newlabel)] = '@';
		escani_str(newlabel, &app->a_pappl);
		return redraw;
	}
}


/* 104de: 00fd8a16 */
/* 106de: 00e195be */
BOOLEAN ins_app(P(char *) name, P(APP *) app)
PP(char *name;)
PP(register APP *app;)
{
	register LPTREE tree;
	register APP *newapp;
	register const char *src;
	char buffer[12];
	char ext[4];
	char newext[4];
	char filetype[14];
	long unused;
	int ret;
	int apptype;
	int newapptype;
	BOOLEAN change;
	int field;
	BOOLEAN isnew;
	BOOLEAN isauto;
	char path[LEN_ZFPATH];
	DESKWIN *win;
	char o180[2];
	THEDSK *d;
	char *end;
	
	UNUSED(unused);
	d = thedesk;
	tree = (LPTREE)d->g_atree[ADINSAPP];
	isnew = *app->a_pappl == '*' || *app->a_pappl == '?';
	fmt_str(name, buffer);
	src = app->a_pdata;
	src = scasb(src, '.');
	if (*src == '.')
		src++;
	strcpy(ext, src);
	inf_sset((OBJECT *)tree, APNAME, buffer);
	inf_sset((OBJECT *)tree, APDFTYPE, ext);
	apptype = app->a_apptype;
	if (app->a_apptype & AF_ISCRYS)
		LWSET(OB_STATE(APGEM), SELECTED);
	else if (app->a_apptype & AF_ISPARM)
		LWSET(OB_STATE(APPARMS), SELECTED);
	else
		LWSET(OB_STATE(APDOS), SELECTED);
	win = win_find(d->o13720);
	end = strscn(&win->w_name[1], path, ' ');
	*end = '\0';
	unfmt_str(buffer, filetype);
	if (end[-1] == '\\')
	{
		strcat(path, filetype);
	}
	isauto = FALSE;
	LWSET(OB_STATE(AUTOBOX), NORMAL);
	LWSET(OB_STATE(NORMALBOX), NORMAL);
	if (streq(path, &d->autofile[3]))
	{
		LWSET(OB_STATE(AUTOBOX), SELECTED);
		isauto = TRUE;
	} else
	{
		LWSET(OB_STATE(NORMALBOX), SELECTED);
	}
	ret = xform_do((OBJECT *)tree, ROOT);
	change = TRUE;
	fs_sget(tree, APDFTYPE, newext);
	field = inf_gindex(tree, APGEM, 3);
	o180[0] = '0';
	switch (field)
	{
	case 0:
		newapptype = PRG;
		o180[0] = '1';
		break;
	case 1:
		newapptype = TOS;
		break;
	case 2:
		newapptype = TTP;
		break;
#ifdef __GNUC__
	default:
		__builtin_unreachable();
#endif
	}
	LWSET(OB_STATE(APGEM + field), NORMAL);
	if (ret == APCANCEL)
		return FALSE;
	if (ret == APREMOVE)
	{
		if (isauto)
		{
			d->autofile[0] = '\0';
			d->autofile[3] = '\0';
		}
		if (!isnew)
			app_free(app);
#if BINEXACT
		goto retit;
#endif
	} else
	{
		if (apptype & AF_ISFMEM)
			newapptype |= AF_ISFMEM;
		if (!streq(ext, newext) || apptype != newapptype)
		{
			if (isnew)
			{
				newapp = app_alloc(TRUE);
				if (newapp != NULL)
				{
					newapp->a_type = AT_ISFILE;
					newapp->a_obid = NIL;
					path[(int)strlen(path)] = '@';
					*(escani_str(path, &newapp->a_pappl) - 1) = '\0';
					newapp->a_aicon = IPRG - 1;
					newapp->a_dicon = IFILE - 1;
					newapp->a_char = 0;
					newapp->a_x = 0;
					newapp->a_y = 0;
					app = newapp;
				} else
				{
					fun_alert(1, NOAPP, NULL);
					return FALSE;
				}
			}
			app->a_apptype = newapptype;
			if (newext[0] != '\0')
			{
				strcpy(filetype, getall);
				strcpy(&filetype[2], newext);
			} else
			{
				filetype[0] = '\0';
			}
			filetype[(int)strlen(filetype)] = '@';
			escani_str(filetype, &app->a_pdata);
		}
		if (LWGET(OB_STATE(AUTOBOX)) & SELECTED)
		{
			d->autofile[0] = '0';
			d->autofile[1] = o180[0];
			d->autofile[2] = ' ';
			strcpy(&d->autofile[3], path);
		} else
		{
			d->autofile[0] = '\0';
		}
	}
#if BINEXACT
retit:
#endif
	return change;
}



