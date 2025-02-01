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
/* 100de: 00fde60e */
BOOLEAN ins_disk(P(APP *) app)
PP(register APP *app;)
{
	register LPTREE tree;
	register APP *newapp;
	int ret;
	register BOOLEAN found;
	char driveid[2];
	char label[14];
	char newdrive[2];
	char newlabel[14];
	short unused;
	int16_t icon;
	char unused2[6];
	BOOLEAN change;
	
	UNUSED(unused);
	UNUSED(unused2);
	UNUSED(found);
	tree = (LPTREE)thedesk->g_atree[ADINSDIS];
	ret = FALSE;
	change = FALSE;
	driveid[0] = app->a_char;
	driveid[1] = '\0';
	strcpy(label, app->a_pappl);
	inf_sset((OBJECT *)tree, DRID, driveid);
	inf_sset((OBJECT *)tree, DRLABEL, label);
	inf_show((OBJECT *)tree, ROOT);
	fs_ssget((OBJECT *)tree, DRID, newdrive);
	fs_ssget((OBJECT *)tree, DRLABEL, newlabel);

	/* BUG: object is not displayed in resource */
#define DRFLOPPY 6
	icon = LWGET(OB_STATE(DRFLOPPY)) & SELECTED;

	if (newdrive[0] == ' ' || newdrive[0] == '\0')
		change = TRUE;
	else if (newdrive[0] != CHAR_FOR_CARTRIDGE)
		newdrive[0] = toupper(newdrive[0]);
	if (LWGET(OB_STATE(DROK)) & SELECTED)
	{
		LWSET(OB_STATE(DROK), NORMAL);
		if (change)
			goto retit;
		if (driveid[0] != newdrive[0])
		{
			newapp = app_alloc(FALSE);
			/* if (newapp != NULL) BUG: missing */
			{
				newapp->a_apptype = app->a_apptype;
				newapp->a_type = newdrive[0] != CHAR_FOR_CARTRIDGE ? AT_ISDISK : AT_ISCART;
				newapp->a_obid = app->a_obid;
				newapp->a_pappl = app->a_pappl;
				newapp->a_pdata = NULL;
				newapp->a_aicon = app->a_aicon;
				newapp->a_dicon = -1;
				newapp->a_char = newdrive[0];
				if (app->a_x < gl_width / 2)
					newapp->a_x = thedesk->g_icw + app->a_x;
				else
					newapp->a_x = app->a_x - thedesk->g_icw;
				if (app->a_y < (gl_height - gl_hbox) / 2)
					newapp->a_y = thedesk->g_ich + app->a_y;
				else
					newapp->a_y = app->a_y - thedesk->g_ich;
				newapp->a_y = thedesk->g_hicon + app->a_y;
				app_mtoi(newapp->a_x, newapp->a_y, &newapp->a_x, &newapp->a_y);
				app = newapp;
				ret = TRUE;
			}
		}
		if (!streq(label, newlabel))
		{
			newlabel[(int)strlen(newlabel)] = '@';
			escan_str(newlabel, &app->a_pappl);
			ret = TRUE;
		}
	} else if (LWGET(OB_STATE(DRREMOVE)) & SELECTED)
	{
		LWSET(OB_STATE(DRREMOVE), NORMAL);
		if (change)
			goto retit;
		for (app = thedesk->applist; app != NULL; )
		{
			if (app->a_aicon == icon && app->a_char == newdrive[0])
			{
				app_free(app);
				app = thedesk->applist;
				ret = TRUE;
			} else
			{
				app = app->a_next;
			}
		}
	} else if (LWGET(OB_STATE(DRCANCEL)) & SELECTED)
	{
		LWSET(OB_STATE(DRCANCEL), NORMAL);
	}
retit:
	return ret;
}


/* 104de: 00fd8a16 */
/* 106de: 00e195be */
/* 100de: 00fde8c0 */
BOOLEAN ins_app(P(char *) name, P(APP *) app)
PP(char *name;)
PP(register APP *app;)
{
	register LPTREE tree;
	register APP *newapp;
	register const char *src;
	char buffer[12];
	char newname[12];
	char ext[4];
	char newext[4];
	char filetype[14];
	int16_t icon;
	int16_t newicon;
	int apptype;
	int newapptype;
	BOOLEAN change;
	int field;
	BOOLEAN isnew;
	
	tree = (LPTREE)thedesk->g_atree[ADINSAPP];
	isnew = *app->a_pappl == '*' || *app->a_pappl == '?';
	fmt_str(name, buffer);
	for (src = app->a_pdata; *src != '\0' && *src != '.'; src++)
		;
	if (*src == '.')
		src++;
	strcpy(ext, src);
	/* stuff in appl name */
	inf_sset((OBJECT *)tree, APNAME, buffer);
	inf_sset((OBJECT *)tree, APDFTYPE, ext);
	apptype = app->a_apptype;
	if (app->a_apptype & AF_ISCRYS)
		LWSET(OB_STATE(APGEM), SELECTED);
	else if (app->a_apptype & AF_ISPARM)
		LWSET(OB_STATE(APPARMS), SELECTED);
	else
		LWSET(OB_STATE(APDOS), SELECTED);

	icon = app->a_aicon - IPRG;
	/* BUG: these objects do not exist in resource */
	LWSET(OB_STATE(icon + 11), SELECTED);
	
	inf_show((OBJECT *)tree, ROOT);
	change = FALSE;
	fs_ssget((OBJECT *)tree, APNAME, newname);
	fs_ssget((OBJECT *)tree, APDFTYPE, newext);
	field = inf_gindex((OBJECT *)tree, APGEM, 3);
	switch (field)
	{
	case 0:
		newapptype = PRG;
		break;
	case 1:
		newapptype = TOS;
		break;
	case 2:
		newapptype = TTP;
		/* break; */
#ifdef __GNUC__
	default:
		__builtin_unreachable();
#endif
	}
	LWSET(OB_STATE(APGEM + field), NORMAL);

	/* BUG: these objects do not exist in resource */
	newicon = inf_gindex((OBJECT *)tree, 11, 17);
	LWSET(OB_STATE(newicon + 11), NORMAL);

	if (LWGET(OB_STATE(APOK)) & SELECTED)
	{	
		if (!streq(buffer, newname) || !streq(ext, newext) || isnew)
		{
			newapp = app_alloc(TRUE);
			if (newapp != NULL)
			{
				newapp->a_apptype = newapptype;
				newapp->a_type = AT_ISFILE;
				newapp->a_obid = NIL;
				unfmt_str(newname, filetype);
				filetype[(int)strlen(filetype)] = '@';
				escan_str(filetype, &newapp->a_pappl);
				if (newext[0] != '\0')
				{
					strcpy(filetype, "*.*");
					strcpy(&filetype[2], newext);
				} else
				{
					filetype[0] = '\0';
				}
				filetype[(int)strlen(filetype)] = '@';
				escan_str(filetype, &newapp->a_pdata);
				newapp->a_aicon = newicon + IPRG;
				newapp->a_dicon = newicon + IFILE;
				newapp->a_char = 0;
				newapp->a_x = 0;
				newapp->a_y = 0;
				app = newapp;
				change = TRUE;
			}
		}
		if (apptype != newapptype)
		{
			app->a_apptype = newapptype;
			change = TRUE;
		}
		LWSET(OB_STATE(APOK), NORMAL);
	} else
	{
		LWSET(OB_STATE(APCANCEL), NORMAL);
	}
	return change;
}
