/*
 *************************************************************************
 *			Revision Control System
 * =======================================================================
 *  $Author: mui $	$Date: 89/04/26 18:23:06 $
 * =======================================================================
 *
 * Revision 2.2  89/04/26  18:23:06  mui
 * TT
 * 
 * Revision 2.1  89/02/22  05:26:30  kbad
 * *** TOS 1.4  FINAL RELEASE VERSION ***
 * 
 * Revision 1.14  88/11/02  12:00:29  mui
 * Change fs_fnum from word to long
 * 
 * Revision 1.13  88/11/01  16:07:28  kbad
 * fix hidden/system/readonly files (now they don't show)
 * 
 * Revision 1.12  88/11/01  11:21:04  kbad
 * Reg opt @ r_dir, r_files
 * 
 * Revision 1.11  88/10/24  10:31:33  mui
 * click anywhere to reload the directory
 * 
 * Revision 1.10  88/10/17  13:37:39  kbad
 * yanked fs_start to fix fs_input growing clip rect problem
 * 
 * Revision 1.9  88/09/09  17:11:25  kbad
 * Fixed the colon cancer - fixed fs_back colon handling
 * 
 * Revision 1.8  88/08/17  20:35:35  mui
 * change to handle more than 16 devices
 * 
 * Revision 1.7  88/07/29  01:30:12  kbad
 * change r_files to fix filename copy
 * 
 * Revision 1.6  88/07/28  21:25:19  mui
 * use GEMDOS to handle all path functions
 * 
 * Revision 1.5  88/07/08  11:51:38  mui
 * don't read them in until it is needed
 * 
 * Revision 1.4  88/07/07 17:55:48  mui
 * Get default directory from GEMDOS
 *
 * Revision 1.3  88/07/01 16:21:52  mui
 * Change r_files to read in everything once
 *
 * Revision 1.2  88/07/01 15:49:12  mui
 * Fix fs_input to handle drive: with no extension
 *
 * Revision 1.1  88/06/02  12:33:50  lozben
 * Initial revision
 * 
 *************************************************************************
 */
/*  	NEWFSLIB.C	10/27/87 - 01/06/88	Derek Mui		*/
/*	Totally rewritten by Derek Mui					*/
/*	Change fs_input	1/21/88	- 1/22/88	D.Mui			*/
/*	Change at r_dir		1/28/88		D.Mui			*/
/*	Allocate all the memory first	2/10/88		D.Mui		*/
/*	Save the extension always and append to the new dir  2/12/88	*/
/*	Change at r_files		2/23/88	D.Mui			*/
/*	Save the default drive's directory	2/24/88	D.Mui		*/
/*	Save all the drive's default directory	2/29/88	D.Mui		*/
/*	Update 		3/1/88 - 3/2/88			D.Mui		*/
/*	Save and set new clipping rect	3/15/88		D.Mui		*/
/*	Change at fix_path		3/22/88		D.Mui		*/
/*	Optimize at fs_input		3/24/88		D.Mui		*/
/*	Fix at fs_input variable, fs_topptr 4/25/88	D.Mui		*/
/*	Change the unsigned to signed at r_sort 4/27/88 D.Mui		*/
/*	Change fs_input so that CATALOGGER will work	D.Mui		*/
/*	Change to make the underscore disappear	5/17/88	D.Mui		*/
/*	Fix the fs_input for doing cancel	9/5/90	D.Mui		*/
/*	Fix at r_file for checking the extension size 9/5/90	D.Mui	*/
/*	Change gsx_mfset to gr_mrestore			5/8/91	D.Mui	*/
/*	Fix the Ftitle 11 characters problem		6/11/91	D.Mui	*/
/*	Mininum height of evelator is 1		1/6/92		D.Mui	*/
/*	Add ini_fsel to adjust drive boxes	7/15/92		D.Mui	*/
/*	Arrows, Sliders and Close Box get SELECTED 08/10/92     c.gee   */

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
#include "gemrsc.h"
#include "dos.h"
#include "ostruct.h"


/*
 * BEWARE, requires change in GEM.RSC
 */
#define LEN_FSNAME 40
#define NM_NAMES (F9NAME - F1NAME + 1)
#define NAME_OFFSET F1NAME
/* max file allowed */
#define NM_FILES 100

STATIC GRECT gl_rfs;
STATIC VOIDPTR ad_fstree;
STATIC char *ad_fsnames;
STATIC _DTA *ad_fsdta;
STATIC char gl_tmp1[LEN_FSNAME];
STATIC char gl_tmp2[LEN_FSNAME];
STATIC long *g_fslist;

static char const gl_fsobj[4] = { FTITLE, FILEBOX, SCRLBAR, 0 };

#define Drvmap() trp13(0xa)


/* 100de: 00fe6d9c */
VOID fs_start(NOTHING)
{
	OBJECT *tree;

	/*
	 *	Start up the file selector by initializing the fs_tree
	 */
	rs_gaddr(ad_sysglo, R_TREE, SELECTOR, (VOIDPTR *)&tree);
	ad_fstree = tree;
	ob_center((LPTREE)tree, &gl_rfs);
}


/*
 *	Routine to back off the end of a file string.
 */
/* 306de: 00e1ce92 */
/* 104de: 00fe0a3a */
/* 106de: 00e22754 */
/* 100de: 00fe6dca */
LINEF_STATIC char *fs_back(P(char *) pstr, P(char *) pend)
PP(register char *pstr;)
PP(register char *pend;)
{
	/* back off to last slash */
	while (*pend != ':' && *pend != '\\' && pend != pstr)
	{
		pend--;
	}
	/* if a : then insert a backslash for fsel dir line */
	if (*pend == ':')
	{
		pend++;
		ins_char(pend, 0, '\\', 64);
	}

	return pend;
}



/*
 *	Routine to back up a path and return the pointer to the beginning
 *	of the file specification part
 */
/* 100de: 00fe6e0a */
LINEF_STATIC char *fs_pspec(P(char *) pstr, P(char *) pend)
PP(register char *pstr;)
PP(register char *pend;)
{
	pend = fs_back(pstr, pend);
	if (*pend == '\\')
		pend++;
	else
	{
		strcpy(pstr, "A:\\*.*");
		/* pstr[0] += dos_gdrv(); BUG: missing */
		pend = pstr + 3;
	}
	return pend;
}


/*
 *	Make a particular path the active path.  This involves
 *	reading its directory, initializing a file list, and filling
 *	out the information in the path node.  Then sort the files.
 */
/* 100de: 00fe6e42 */
LINEF_STATIC BOOLEAN fs_active(P(char *) ppath, P(char *)pspec, P(int16_t *) pcount)
PP(char *ppath;)
PP(char *pspec;)
PP(int16_t *pcount;)
{
	int16_t ret;
	int16_t thefile;
	int16_t len;
	int unused;
	int16_t fs_index;
	register int16_t i;
	register int16_t j;
	register int16_t gap;
	long temp;

	UNUSED(unused);
	gsx_mfset(ad_hgmice);

	thefile = 0;
	fs_index = 0;
	len = 0;

	dos_sdta(ad_fsdta);
	ret = dos_sfirst(ppath, FA_DIREC);
	while (ret)
	{
		/* if it is a real file */
		/*   or directory then  */
		/*   save it and set    */
		/*   first byte to tell */
		/*   which      */
		if (ad_fsdta->d_fname[0] != '.')
		{
			ad_fsdta->d_fname[-1] = (ad_fsdta->d_attrib & FA_DIREC) ? 0x07 : ' ';
			if (ad_fsdta->d_fname[-1] == 0x07 || wildcmp(pspec, ad_fsdta->d_fname))
			{
				len = LSTCPY(fs_index + ad_fsnames, &ad_fsdta->d_fname[-1]);
				g_fslist[thefile] = fs_index;
				fs_index += len + 2;
				thefile++;
			}
		}
		ret = dos_snext();

		if (thefile >= NM_FILES)
		{
			ret = FALSE;
			chrout(7);
		}
	}
	*pcount = thefile;
	/* sort files using shell */
	/*   sort on page 108 of */
	/*   K&R C Prog. Lang.  */
	for (gap = thefile / 2; gap > 0; gap /= 2)
	{
		for (i = gap; i < thefile; i++)
		{
			for (j = i - gap; j >= 0; j -= gap)
			{
				LSTCPY(gl_tmp1, ad_fsnames + g_fslist[j]);
				LSTCPY(gl_tmp2, ad_fsnames + g_fslist[j + gap]);
				if (strchk(gl_tmp1, gl_tmp2) <= 0)
					break;
				temp = g_fslist[j];
				g_fslist[j] = g_fslist[j + gap];
				g_fslist[j + gap] = temp;
			}
		}
	}
	gsx_mfset(ad_armice);
	return TRUE;
}


/*
 *	Routine to adjust the scroll counters by one in either
 *	direction, being careful not to overrun or underrun the
 *	tail and heads of the list
 */
/* 100de: 00fe701a */
LINEF_STATIC int16_t fs_1scroll(P(int16_t) curr, P(int16_t) count, P(int16_t) touchob)
PP(register int16_t curr;)
PP(register int16_t count;)
PP(register int16_t touchob;)
{
	register int16_t newcurr;

	newcurr = (touchob == FUPAROW) ? (curr - 1) : (curr + 1);
	if (newcurr < 0)
		newcurr++;
	if ((count - newcurr) < NM_NAMES)
		newcurr--;
	return count > NM_NAMES ? newcurr : curr;
}


/*
 *	Routine to take the filenames that will appear in the window, 
 *	based on the current scrolled position, and point at them 
 *	with the sub-tree of G_STRINGs that makes up the window box.
 */
/* 100de: 00fe7060 */
LINEF_STATIC BOOLEAN fs_format(P(LPTREE) tree, P(int16_t) currtop, P(int16_t) count)
PP(register LPTREE tree;)
PP(int16_t currtop;)
PP(int16_t count;)
{
	register int16_t i;
	register int16_t cnt;
	register int16_t y;
	register int16_t h;
	register int16_t th;
	char *adtext;
	int16_t unused;
	int16_t tlen;

	UNUSED(unused);
	/* build in real text strings */
	cnt = min(NM_NAMES, count - currtop);
	for (i = 0; i < NM_NAMES; i++)
	{
		if (i < cnt)
		{
			LSTCPY(gl_tmp2, ad_fsnames + g_fslist[currtop + i]);
			fmt_str(&gl_tmp2[1], &gl_tmp1[1]);
			gl_tmp1[0] = gl_tmp2[0];
		} else
		{
			gl_tmp1[0] = ' ';
			gl_tmp1[1] = '\0';
		}
		fs_sset(tree, NAME_OFFSET + i, gl_tmp1, &adtext, &tlen);
		LWSET(OB_STATE(NAME_OFFSET + i), NORMAL);
	}
	/* size and position the elevator */
	y = 0;
	th = h = LWGET(OB_HEIGHT(FSVSLID));
	if (count > NM_NAMES)
	{
		h = mul_div(NM_NAMES, h, count);
		h = max(gl_hbox / 2, h);		/* min size elevator    */
		y = mul_div(currtop, th - h, count - NM_NAMES);
	}
	LWSET(OB_Y(FSVELEV), y);
	LWSET(OB_HEIGHT(FSVELEV), h);
	return TRUE;
}


/*
 *	Routine to select or deselect a file name in the scrollable 
 *	list.
 */
/* 100de: 00fe718c */
LINEF_STATIC VOID fs_sel(P(int16_t) sel, P(int16_t) state)
PP(int16_t sel;)
PP(int16_t state;)
{
	if (sel)
		ob_change((LPTREE)ad_fstree, F1NAME + sel - 1, state, TRUE);
}


/*
 *	Routine to handle scrolling the directory window a certain number
 *	of file names.
 */
/* 100de: 00fe71b2 */
LINEF_STATIC int16_t fs_nscroll(P(LPTREE) tree, P(int16_t *) psel, P(int16_t) curr, P(int16_t) count, P(int16_t) touchob, P(int16_t) n)
PP(register LPTREE tree;)
PP(register int16_t *psel;)
PP(int16_t curr;)
PP(int16_t count;)
PP(int16_t touchob;)
PP(int16_t n;)
{
	register int16_t i;
	register int16_t newcurr;
	register int16_t diffcurr;
	int16_t sy;
	GRECT r[2];

	/* single scroll n times */
	newcurr = curr;
	for (i = 0; i < n; i++)
		newcurr = fs_1scroll(newcurr, count, touchob);
	/* if things changed then redraw */
	diffcurr = newcurr - curr;
	if (diffcurr)
	{
		curr = newcurr;
		fs_sel(*psel, NORMAL);
		*psel = 0;
		fs_format(tree, curr, count);
		gsx_gclip(&r[0]);
		ob_actxywh(tree, F1NAME, &r[1]);

		sy = r[1].g_h;
		r[1].g_h = r[1].g_h * NM_NAMES;
		if (diffcurr > 0)
		{
			if (diffcurr < NM_NAMES)
			{
				bb_screen(S_ONLY, r[1].g_x, r[1].g_y + diffcurr * sy, r[1].g_x, r[1].g_y, r[1].g_w, sy * (NM_NAMES - diffcurr));
				r[1].g_y += sy * (NM_NAMES - diffcurr);
				r[1].g_h = diffcurr * sy;
			} else
			{
				r[1].g_h = sy * NM_NAMES;
			}
		} else
		{
			diffcurr = -diffcurr;
			if (diffcurr < NM_NAMES)
			{
				bb_screen(S_ONLY, r[1].g_x, r[1].g_y, r[1].g_x, r[1].g_y + diffcurr * sy, r[1].g_w, sy * (NM_NAMES - diffcurr));
				r[1].g_h = diffcurr * sy;
			} else
			{
				r[1].g_h = sy * NM_NAMES;
			}
		}

		gsx_sclip(&r[1]);
		ob_draw(tree, FILEBOX, MAX_DEPTH);
		gsx_sclip(&r[0]);
		ob_draw(tree, FSVSLID, MAX_DEPTH);
	}
	return curr;
}


/*
 *	Routine to call when a new directory has been specified.  This
 *	will activate the directory, format it, and display ir[0].
 */
/* 100de: 00fe732a */
LINEF_STATIC VOID fs_newdir(P(char *) ftitle, P(char *) fpath, P(char *) pspec, P(OBJECT *) tree, P(int16_t *) pcount)
PP(char *ftitle;)
PP(char *fpath;)
PP(char *pspec;)
PP(OBJECT *tree;)
PP(int16_t *pcount;)
{
	const char *ptmp;

	ob_draw((LPTREE)tree, FDIRECTORY, MAX_DEPTH);
	fs_active(fpath, pspec, pcount);
	fs_format((LPTREE)tree, ROOT, *pcount);
	gl_tmp1[0] = ' ';
	strcpy(&gl_tmp1[1], pspec);
	strcat(&gl_tmp1[1], " ");
	LSTCPY(ftitle, gl_tmp1);
	ptmp = gl_fsobj;
	while (*ptmp)
		ob_draw((LPTREE)tree, *ptmp++, MAX_DEPTH);
}


/*
 * AES #90 - fsel_input - File selection input
 * AES #91 - fsel_exinput - File selection extended input
 *
 *	File Selector input routine that takes control of the mouse
 *	and keyboard, searchs and sort the directory, draws the file 
 *	selector, interacts with the user to determine a selection
 *	or change of path, and returns to the application with
 *	the selected path, filename, and exit button.
 *	Add the label parameter,
 */
/* 306de: 00e1cef2 */
/* 104de: 00fe0a8a */
/* 106de: 00e227b4 */
/* 100de: 00fe73c0 */
int16_t fs_input(P(char *) pipath, P(char *) pisel, P(int16_t *) pbutton)
PP(char *pipath;)
PP(char *pisel;)
PP(int16_t *pbutton;)
{
	register int16_t touchob;
	register int16_t value;
	register int16_t fnum;
	int16_t curr;
	int16_t elevpos;
	int16_t count;
	int16_t mx, my;
	int16_t sel;
	int16_t pt_x, pt_y;
	register LPTREE tree;
	long dummy;
	char *ad_fpath;
	char *ad_fname;
	char *ad_ftitle;
	int16_t fname_len;
	int16_t fpath_len;
	int16_t temp_len;
	int16_t dclkret;
	int16_t cont;
	BOOLEAN firsttime;
	BOOLEAN newname;
	register char *pstr;
	register char *pspec;
	register THEGLO *DGLO;


	UNUSED(dummy);
	UNUSED(curr);
	DGLO = &D;
	/* get all the memory */
	ad_fsnames = dos_alloc((long)40 * LEN_FSNAME); /* BUG: should be 100 (NM_FILES) */
	if (!ad_fsnames)
		return FALSE;
	g_fslist = dos_alloc((long)NM_FILES * sizeof(char *));
	if (!g_fslist)
	{
		dos_free(ad_fsnames);
		return FALSE;
	}
	/* allocate dta buffer  */
	ad_fsdta = dos_alloc(256L);
	if (!ad_fsdta)
	{
		dos_free(ad_fsnames);
		dos_free(g_fslist);
		return FALSE;
	}

	/* init strings in form */
	tree = (LPTREE)ad_fstree;
	fs_sset(tree, FTITLE, " *.* ", &ad_ftitle, &temp_len);
	fs_sset(tree, FDIRECTORY, pipath, &ad_fpath, &fpath_len);
	LSTCPY(gl_tmp1, pisel);
	fmt_str(gl_tmp1, gl_tmp2);
	fs_sset(tree, FSELECTION, gl_tmp2, &ad_fname, &fname_len);

	/* set clip and start form fill-in by drawing the form */
	gsx_sclip(&gl_rfs);
	fm_dial(FMD_START, &gl_rcenter, &gl_rfs);
	DGLO->g_dir[0] = '\0';
	ob_draw(tree, ROOT, 1);


	/* init for while loop by forcing initial fs_newdir call */
	sel = 0;
	newname = FALSE;
	cont = firsttime = TRUE;
#ifdef __GNUC__
	elevpos = 0; /* BUG: uninitialized */
	count = 0;
#endif
	while (cont)
	{
		touchob = firsttime ? 0 : fm_do(tree, FSELECTION);
		gsx_mxmy(&mx, &my);
		fpath_len = LSTCPY(DGLO->g_loc1, ad_fpath);
		if (!streq(DGLO->g_dir, DGLO->g_loc1))
		{
			fs_sel(sel, NORMAL);
			if (touchob == FSOK || touchob == FSCANCEL)
				ob_change(tree, touchob, NORMAL, TRUE);
			strcpy(DGLO->g_dir, DGLO->g_loc1);
			pspec = fs_pspec(DGLO->g_dir, &DGLO->g_dir[fpath_len]);
			LSTCPY(ad_fpath, DGLO->g_dir);
			pstr = fs_pspec(DGLO->g_loc1, &DGLO->g_loc1[fpath_len]);
			strcpy(pstr, "*.*");
			fs_newdir(ad_ftitle, DGLO->g_loc1, pspec, (OBJECT *)tree, &count);
			elevpos = sel = 0;
			firsttime = FALSE;
		}

		value = 0;
		dclkret = (touchob & 0x8000) != 0;
		touchob &= 0x7fff;
		switch (touchob)
		{
		case FSOK:
		case FSCANCEL:
			cont = FALSE;
			break;
		case FUPAROW:
		case FDNAROW:
			value = 1;
			break;
		case FSVSLID:
			ob_offset(tree, FSVELEV, &pt_x, &pt_y);
			touchob = my <= pt_y ? FUPAROW : FDNAROW;
			value = NM_NAMES;
			break;
		case FSVELEV:
		  	take_ownership(TRUE);
			value = gr_slidebox(tree, FSVSLID, FSVELEV, TRUE);
			take_ownership(FALSE);
			value = elevpos - mul_div(value, count - NM_NAMES, 1000);
			if (value >= 0)
			{
				touchob = FUPAROW;
			} else
			{
				touchob = FDNAROW;
				value = -value;
			}
			break;
		case F1NAME:
		case F2NAME:
		case F3NAME:
		case F4NAME:
		case F5NAME:
		case F6NAME:
		case F7NAME:
		case F8NAME:
		case F9NAME:
			fnum = touchob - F1NAME + 1;
			if (sel && sel != fnum)
				fs_sel(sel, NORMAL);
			if (sel != fnum)
			{
				sel = fnum;
				fs_sel(sel, SELECTED);
			}
			/* get string and see if file or folder */
			fs_sget((OBJECT *)tree, touchob, gl_tmp1);
			if (gl_tmp1[0] == ' ')
			{
				/* copy to selection */
				newname = TRUE;
				if (dclkret)
					cont = FALSE;
			} else
			{
				/* append in folder name */
				pstr = fs_pspec(DGLO->g_loc1, &DGLO->g_loc1[fpath_len]);
				strcpy(gl_tmp2, pstr - 1);
				unfmt_str(&gl_tmp1[1], pstr);
				strcat(pstr, gl_tmp2);
				firsttime = TRUE;
			}
			break;
		case FCLSBOX:
			pspec = pstr = fs_back(DGLO->g_loc1, &DGLO->g_loc1[fpath_len]);
			if (*pstr-- == '\\')
			{
				firsttime = TRUE;
				if (*pstr != ':')
				{
					pstr = fs_back(DGLO->g_loc1, pstr);
					if (*pstr == '\\')
						strcpy(pstr, pspec);
				}
			}
			break;
		case FTITLE:
			firsttime = TRUE;
			/* break; */
		}
		if (firsttime)
		{
			LSTCPY(ad_fpath, DGLO->g_loc1);
			DGLO->g_dir[0] = '\0';
			gl_tmp1[1] = '\0';
			newname = TRUE;
		}
		if (newname)
		{
			LSTCPY(ad_fname, &gl_tmp1[1]);
			ob_draw(tree, FSELECTION, MAX_DEPTH);
			if (!cont)
				ob_change(tree, FSOK, SELECTED, TRUE);
			newname = FALSE;
		}
		if (value)
			elevpos = fs_nscroll(tree, &sel, elevpos, count, touchob, value);
	}
	
	/* return path and file name to app */
	LSTCPY(pipath, ad_fpath);
	LSTCPY(gl_tmp1, ad_fname);
	unfmt_str(gl_tmp1, gl_tmp2);
	LSTCPY(pisel, gl_tmp2);

	/* start the redraw */
	fm_dial(FMD_FINISH, &gl_rcenter, &gl_rfs);

	/* return exit button   */
	if ((*pbutton = inf_what((OBJECT *)tree, FSOK, FSCANCEL)) == -1)
		*pbutton = 0;

	dos_free(ad_fsdta);
	dos_free(g_fslist);
	dos_free(ad_fsnames);

	return TRUE;
}
