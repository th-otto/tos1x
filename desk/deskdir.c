/*	DESKDIR.C	09/03/84 - 06/05/85	Lee Lorenzen		*/
/*			4/7/86   - 8/27/86	MDF			*/
/*	merge source	5/19/97  - 5/28/87	mdf			*/
/*	for 3.0		11/13/87		mdf			*/

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
#include "dos.h"

#undef Fread
#define Fread(a,b,c)    trap(0x3f,a,b,c)
#undef Fwrite
#define Fwrite(a,b,c)    trap(0x40,a,b,c)
#if BINEXACT
#undef Bconstat
#undef Bconin
#define Bconstat(a) trp13(0x10002L)
#define Bconin(d) trp13(0x20002L)
#endif


#define FO_RDONLY        0	/* Open read-only - same as O_RDONLY */
#define FO_WRONLY        1	/* Open write-only - same as O_WRONLY */
#define FO_RDWR          2	/* Open read/write - same as O_RDWR */


char const wilds[] = "\\*.*\0";
char const getall[] = "*.*";
int f_level;
STATIC char do_srcpath[PATHLEN];
STATIC char do_dstpath[PATHLEN];
STATIC char do_dstname[LEN_ZFNAME + 2];
STATIC char do_srcname[LEN_ZFNAME + 2];


LINEF_STATIC BOOLEAN dirop_init PROTO((int op, char *psrc_path, char *pdst_path, uint16_t *pfcnt, uint16_t *pdcnt));
LINEF_STATIC VOID sub_path PROTO((char *path));
LINEF_STATIC BOOLEAN dirop_file PROTO((int op, char *psrc_path, char *pdst_path, const char *fname, int attr, uint16_t time, uint16_t date));
LINEF_STATIC int do_namecon PROTO((char *dstpath, char *name));
LINEF_STATIC BOOLEAN notsame_name PROTO((char *srcpath, char *dstpath));
LINEF_STATIC BOOLEAN d_dofdel PROTO((char *path, BOOLEAN flag));
LINEF_STATIC VOID splitpath PROTO((char *path, char *filename, char *dirname));


/* 306de: 00e2fc7c */
/* 104de: 00fd68fa */
/* 106de: 00e16fb2 */
char *r_slash(P(const char *)path)
PP(register const char *path;)
{
	while (*path)
		path++;

	while (*path != '\\')
	{
		path--;
	}
	return NO_CONST(path);
}


/* 306de: 00e2fafe */
/* 104de: 00fd691c */
VOID do_finish(P(OBJECT *) obj)
PP(OBJECT *obj;)
{
	int16_t x, y, w, h;

	form_center(obj, &x, &y, &w, &h);
	form_dial(FMD_FINISH, 0, 0, 0, 0, x, y, w, h);
}


/*
 *	Routine to DRAW a DIALog box centered on the screen
 */
/* 306de: 00e2fa08 */
/* 104de: 00fd695a */
/* 106de: 00e17024 */
VOID fm_draw(P(LPTREE) tree)
PP(LPTREE tree;)
{
	int16_t x, y, w, h;

	form_center((OBJECT *)tree, &x, &y, &w, &h);
	form_dial(FMD_START, 0, 0, 0, 0, x, y, w, h);
	objc_draw((OBJECT *)tree, ROOT, MAX_DEPTH, x, y, w, h);
}


/*
 * Draw a single field of a dialog box
 */
/* 306de: 00e2f890 */
/* 104de: 00fd69b6 */
/* 106de: 00e1708e */
VOID drawfld(P(OBJECT *)obj, P(int16_t) which)
PP(OBJECT *obj;)
PP(int16_t which;)
{
	GRECT t;
	RC_COPY((GRECT *)&obj[which].ob_x, &t);
	objc_offset(obj, which, &t.g_x, &t.g_y);
	objc_draw(obj, which, 0, t.g_x, t.g_y, t.g_w, t.g_h);
}


/* 104de: 00fd6a0a */
/* 106de: 00e170f0 */
VOID drawclip(P(OBJECT *)obj, P(int16_t) which)
PP(OBJECT *obj;)
PP(int16_t which;)
{
	GRECT t;
	RC_COPY((GRECT *)&obj[which].ob_x, &t);
	ob_offset((LPTREE)obj, which, &t.g_x, &t.g_y);
	gsx_sclip(&t);
	ob_draw((LPTREE)obj, which, 0);
}


/*
 *	Add a file name to the end of an existing path.
 */
/* 104de: 00fd6a5a */
VOID add_fname(P(char *) path, P(const char *) name)
PP(register char *path;)
PP(const char *name;)
{
	while (*path != '*')
		path++;
	strcpy(path, name);
}


/*
 *	Remove the file name from the end of a path and append on
 *	an \*.*
 */
VOID del_fname(P(char *) path)
PP(register char *path;)
{
	path = r_slash(path);
	strcpy(path, wilds);
}



/*
 *	Parse to find the filename part of a path and return a copy of it
 *	in a form ready to be placed in a dialog box.
 */
VOID get_fname(P(const char *) pstr, P(char *) newstr)
PP(register const char *pstr;)
PP(register char *newstr;)
{
	register THEDSK *d;
	
	d = thedesk;
	pstr = r_slash(pstr);
	pstr++;
	strcpy(d->ml_ftmp, pstr);
	fmt_str(d->ml_ftmp, newstr);
}


/* 104de: 00fd6ad0 */
/* 106de: 00e171f4 */
BOOLEAN dos_error(NOTHING)
{
	if (DOS_ERR)
	{
		if (DOS_AX == E_ACCDN)
			fun_alert(1, STILLCOPY, NULL);
		else if (DOS_AX <= -32)
			form_error(~DOS_AX - 30);
		return FALSE;
	}
	return TRUE;
}


/* 104de: 00fd6b16 */
/* 106de: 00e17244 */
LINEF_STATIC BOOLEAN dirop_init(P(int) op, P(char *)psrc_path, P(char *)pdst_path, P(uint16_t *)pfcnt, P(uint16_t *)pdcnt)
PP(int op;)
PP(char *psrc_path;)
PP(char *pdst_path;)
PP(uint16_t *pfcnt;)
PP(uint16_t *pdcnt;)
{
	register THEDSK *d;
	register LPTREE tree;
	char *str;
	int16_t strid;
	long fcnt;
	long dcnt;

	UNUSED(psrc_path);
	UNUSED(pdst_path);
	d = thedesk;
	tree = 0;
	d->g_xbuf = NULL;
	d->ml_dlpr = FALSE;
	d->ml_havebox = FALSE;
	d->g_nfiles = *pfcnt;
	d->g_ndirs = *pdcnt;
#ifdef __GNUC__
	strid = 0; /* silence compiler */
#endif
	switch (op)
	{
	case OP_COUNT:
		d->g_nfiles = 0;
		d->g_ndirs = 0;
		d->g_size = 0;
		break;
	case OP_MOVE:
		strid = STMOVESTR;
		if (d->g_ccopypref || d->g_cdelepref)
			d->ml_dlpr = TRUE;
		goto copy;
	case OP_COPY:
		strid = STCPYSTR;
		if (d->g_ccopypref)
			d->ml_dlpr = TRUE;
	copy:
		d->g_xlen = dos_avail();
		if (d->g_xlen == 0)
		{
			do1_alert(FCNOMEM);
			return FALSE;
		}
		d->g_xbuf = dos_alloc(d->g_xlen);
		break;
	case OP_DELETE:
		strid = STDELSTR;
		if (d->g_cdelepref)
			d->ml_dlpr = TRUE;
		break;
	}
	
	if (d->ml_dlpr)
	{
		tree = (LPTREE)d->g_atree[CPBOX];
		rsrc_gaddr(R_STRING, strid, (VOIDPTR *)&str);
		((TEDINFO *)(LLGET(OB_SPEC(TITLE))))->te_ptext = str;
		fcnt = *pfcnt;
		dcnt = *pdcnt;
		inf_setsize(&fcnt, d->ml_files, (OBJECT *)tree, NUMFILE, FALSE);
		inf_setsize(&dcnt, d->ml_dirs, (OBJECT *)tree, NUMDIR, FALSE);
		inf_sset((OBJECT *)tree, CPFILE, "");
		inf_sset((OBJECT *)tree, CPDIR, "");
		LWSET(OB_FLAGS(CPFILE), HIDETREE);
		LWSET(OB_FLAGS(CPDIR), HIDETREE);
		fm_draw(tree);
		LWSET(OB_FLAGS(CPFILE), NONE);
		LWSET(OB_FLAGS(CPDIR), NONE);
		form_do((OBJECT *)tree, NIL);
		if (!inf_what((OBJECT *)tree, OKCP, CCANCEL))
			return FALSE;
	}
	return TRUE;
}


/*
 *	DIRectory routine that does an OPeration on all the selected files and
 *	folders in the source path.  The selected files and folders are 
 *	marked in the source file list.
 */
/* 104de: 00fd6cce */
/* 106de: 00e17432 */
BOOLEAN dir_op(P(int) op, P(const char *)psrc_path, P(FNODE *)pflist, P(char *)pdst_path, P(uint16_t *)pfcnt, P(uint16_t *)pdcnt, P(uint32_t *)psize)
PP(int op;)
PP(const char *psrc_path;)
PP(register FNODE *pflist;)
PP(char *pdst_path;)
PP(uint16_t *pfcnt;)
PP(uint16_t *pdcnt;)
PP(uint32_t *psize;)
{
	register THEDSK *d;
	register LPTREE tree;
	register int ret;
	
#if !BINEXACT
	tree = 0; /* BUG: used uninitialized below */
#endif
	d = thedesk;
	strcpy(do_srcpath, psrc_path);
	strcpy(do_dstpath, pdst_path);
	op = (gl_kstate & K_CTRL) && op == OP_COPY ? OP_MOVE : op;
#if !BINEXACT
	ret = TRUE; /* BUG: may be used uninitialized */
#endif
	if (dirop_init(op, do_srcpath, do_dstpath, pfcnt, pdcnt))
	{
		desk_wait(TRUE);
		while (pflist != NULL)
		{
			if (pflist->f_obid != NIL && (d->g_screen[pflist->f_obid].ob_state & SELECTED))
			{
				if (pflist->f_attr == FA_DIREC)
				{
					add_path(do_srcpath, pflist->f_name);
					ret = d_doop(op, (OBJECT *)tree, do_srcpath, do_dstpath, pfcnt, pdcnt);
					sub_path(do_srcpath);
				} else
				{
					ret = dirop_file(op, do_srcpath, do_dstpath, pflist->f_name, pflist->f_attr, pflist->f_time, pflist->f_date);
				}
				if (!ret)
					break;
			}
			pflist = pflist->f_next;
		}
	}
	
	if (d->ml_dlpr)
	{
		do_finish(d->g_atree[CPBOX]);
	} else
	{
		if (d->ml_havebox)
			do_finish(d->g_atree[SAMENAME]);
	}
	
	switch (op)
	{
	case OP_COUNT:
		*pfcnt = d->g_nfiles;
		*pdcnt = d->g_ndirs;
		*psize = d->g_size;
		break;
	case OP_COPY:
	case OP_MOVE:
		if (d->g_xbuf != NULL)
			dos_free(d->g_xbuf);
		break;
	}
	
	desk_wait(FALSE);
	return ret;
}


/*
 *	Directory routine to DO an operation on an entire sub-directory.
 */
/* 104de: 00fd6e40 */
/* 106de: 00e175d0 */
BOOLEAN d_doop(P(int) op, P(OBJECT *)tree, P(char *)psrc_path, P(char *)pdst_path, P(uint16_t *)pfcnt, P(uint16_t *)pdcnt)
PP(int op;)
PP(OBJECT *tree;)
PP(register char *psrc_path;)
PP(register char *pdst_path;)
PP(uint16_t *pfcnt;)
PP(uint16_t *pdcnt;)
{
	register int more;
	register int level;
	register BOOLEAN ret;
	char name[LEN_ZFNAME + 2];
	char *srcname;
	THEDSK *d;
	register char *ptr;
	
	ret = FALSE;
	d = thedesk;
	level = 0;
	srcname = ptr = r_slash(psrc_path);
#if BINEXACT
	asm("movea.l    a3,a0");
	asm("clr.b (a0)");
#else
	*ptr = '\0';
#endif
	ptr--;
	while (ptr != NULL)
	{
		if (*ptr-- == '\\')
			break;
	}
	ptr += 2;
	strcpy(do_srcname, ptr);
	*srcname = '\\';

	/* start recursion at level 0 */
	f_level = 0;
	if (op == OP_COUNT || op == OP_DELETE)
	{
		srcname = psrc_path;
	} else
	{
		srcname = pdst_path;
		f_level++;
	}
	while (*srcname != '\0')
	{
		if (*srcname++ == '\\')
			f_level++;
	}
	f_level--;
	strcpy(d->g_srcpth, psrc_path);
	strcpy(d->g_dstpth, pdst_path);
	
loop:
	{
		if (f_level > MAX_LEVEL)
		{
			fun_alert(1, STFOF8DEE, NULL);
			ret = FALSE;
			goto done;
		}
		/* set up initial DTA */
		dos_sdta(&d->g_dtastk[f_level]);
		switch (op)
		{
		case OP_COUNT:
			d->g_ndirs++;
			break;
		case OP_COPY:
		case OP_MOVE:
			strcpy(do_dstname, do_srcname);
			add_fname(d->g_dstpth, do_dstname);
			for (;;)
			{
				/* 13 */
				if (dos_sfirst(d->g_dstpth, FA_DIREC|FA_HIDDEN|FA_SYSTEM) == 0)
				{
					if (DOS_AX == E_NOFILES)
						goto l17;
					dos_error();
					goto done;
					goto l17;
				}
				l14:
				/* for (;;) */
				{
					do
					{
						more = do_namecon(d->g_dstpth, name);
						if (more == 0)
							goto done;
						if (more != 1)
							goto skip;
					} while (name[0] == '\0');
					if (!streq(name, do_dstname))
						goto l15;
					strcat(d->g_dstpth, wilds);
					more = notsame_name(d->g_srcpth, d->g_dstpth);
					ptr = r_slash(d->g_dstpth);
					*ptr = '\0';
					if (!more)
						goto l14;
					goto next;
				}
			l15:
				strcpy(do_dstname, name);
				strcpy(d->g_dstpth, pdst_path);
				add_fname(d->g_dstpth, do_dstname);
			}
			goto l17;
		skip:
			strcat(d->g_dstpth, wilds);
			goto l29;
		l17:
			d->g_ndirs++;
			strcat(d->g_dstpth, wilds);
			d_dofdel(d->g_dstpth, FALSE);
			ptr = r_slash(d->g_dstpth);
			*ptr = '\0';
			dos_mkdir(d->g_dstpth);
			if (DOS_AX == E_NOACCESS)
			{
				DOS_AX = E_ACCDN;
				if (dos_error() == FALSE)
					goto done;
			}
		next:
			strcat(d->g_dstpth, wilds);
			break;
		}
		
		more = dos_sfirst(d->g_srcpth, FA_DIREC|FA_ARCH|FA_RDONLY|FA_HIDDEN|FA_SYSTEM);
		while (TRUE)
		{
			if (more == FALSE)
			{
				if (DOS_AX == E_NOFILES)
					break;
				dos_error();
				goto done;
			}
			if (d->g_dtastk[f_level].dirfile.d_att & FA_DIREC)
			{
				if (d->g_dtastk[f_level].dirfile.d_name[0] != '.')
				{
					++level;
					strcpy(do_srcname, d->g_dtastk[f_level].dirfile.d_name);
					++f_level;
					add_path(d->g_srcpth, do_srcname);
					goto loop;
				}
			} else
			{
				if (!dirop_file(op, d->g_srcpth, d->g_dstpth,
					d->g_dtastk[f_level].dirfile.d_name,
					d->g_dtastk[f_level].dirfile.d_att,
					d->g_dtastk[f_level].dirfile.d_time,
					d->g_dtastk[f_level].dirfile.d_date))
					goto done;
			}
		l25:
			more = dos_snext();
		}
		if (op == OP_DELETE || op == OP_MOVE)
		{
			srcname = r_slash(d->g_srcpth);
			if (srcname[-1] != ':')
			{
				*srcname = '\0';
				dos_rmdir(d->g_srcpth);
				*srcname = '\\';
				if (!dos_error())
					goto done;
			}
		}
	}
l29:
	switch (op)
	{
	case OP_COPY:
	case OP_MOVE:
		if (!d_dofdel(d->g_dstpth, FALSE))
			goto done;
		break;
	case OP_DELETE:
		if (!d_dofdel(d->g_srcpth, FALSE))
			goto done;
		break;
	}
	if (level != 0)
	{
		if (op == OP_COPY || op == OP_MOVE)
			sub_path(d->g_dstpth);
		sub_path(d->g_srcpth);
		--level;
		--f_level;
		dos_sdta(&d->g_dtastk[f_level]);
		goto l25;
	} else
	{
		ret = TRUE;
	}
	
done:
	return ret;
}


/*
 *	Directory routine to DO File COPYing.
 */
/* 104de: 00fd7316 */
/* 106de: 00e17b2a */
LINEF_STATIC BOOLEAN dirop_file(P(int) op, P(char *)psrc_path, P(char *)pdst_path, P(const char *)fname, P(int) attr, P(uint16_t) time, P(uint16_t) date)
PP(int op;)
PP(register char *psrc_path;)
PP(register char *pdst_path;)
PP(const char *fname;)
PP(int attr;)
PP(uint16_t time;)
PP(uint16_t date;)
{
	register int copyok = 1;
	register int dstfh;
	register int srcfh;
	register long amntrd;
	long amntwr;
	register BOOLEAN ret;
	register THEDSK *d;
	char name[LEN_ZFNAME + 2];
	char newname[LEN_ZFNAME + 2];
	char *ptr;
	
	d = thedesk;
	if (op == OP_COUNT)
	{
		d->g_nfiles++;
		d->g_size += d->g_dtastk[f_level].dirfile.d_size;
		return TRUE;
	}
	add_fname(psrc_path, fname);
	if (op != OP_DELETE)
	{
		add_fname(pdst_path, fname);
		strcpy(name, fname);
	}
	ret = FALSE;
	
	switch (op)
	{
	case OP_DELETE:
		if (!d_dofdel(psrc_path, TRUE))
			break;
		dos_delete(psrc_path);
		if (DOS_AX == E_ACCDN)
		{
			ret = TRUE;
			form_error(~E_ACCDN - 30);
		} else
		{
			if (dos_error())
				ret = TRUE;
		}
		break;
	
	case OP_MOVE:
		if (*psrc_path == *pdst_path)
		{
			if (!d_dofdel(pdst_path, TRUE))
				break;
			dos_rename(psrc_path, pdst_path);
			if (!DOS_ERR)
			{
				ret = TRUE;
				goto done;
			}
			if (DOS_AX == E_ACCDN)
				goto copy;
			dos_error();
			goto done;
		}
		/* fall through */
	
	case OP_COPY:
		if (!d_dofdel(pdst_path, TRUE))
			break;
	copy:
		srcfh = dos_open(psrc_path, FO_RDONLY);
		if (!dos_error())
			break;
		amntrd = Fread(srcfh, d->g_xlen, d->g_xbuf);
		if (dos_error())
		{
			for (;;)
			{
				dstfh = dos_open(pdst_path, FO_RDONLY);
				if (DOS_ERR)
				{
					if (DOS_AX == E_FILENOTFND)
						break;
					dos_error();
					goto closeit;
				} else
				{
					dos_close(dstfh);
				}
				if (1)
				{
					do
					{
						if (d->g_covwrpref)
							goto copyname;
						if (!(copyok = do_namecon(pdst_path, newname)))
							goto closeit;
						if (copyok == 2)
						{
							ret = TRUE;
							goto closeit;
						}
					} while (newname[0] == '\0');
				} else
				{
				copyname:
					strcpy(newname, name);
				}
				ptr = r_slash(pdst_path);
				strcpy(ptr + 1, newname);
				if (streq(pdst_path, psrc_path))
				{
					ret = TRUE;
					goto closeit;
				}
				if (streq(newname, name))
					break;
				strcpy(name, newname);
			}
			if (!d_dofdel(pdst_path, TRUE))
				goto closeit;
			dstfh = dos_create(pdst_path, attr & ~FA_RDONLY);
			if (!dos_error())
				goto closeit;
			d->g_nfiles++;
			for (;;)
			{
				amntwr = Fwrite(dstfh, amntrd, d->g_xbuf);
				if (!dos_error())
					break;
				if (amntrd != amntwr)
				{
					fun_alert(1, STDISKFULL, NULL);
					dos_close(dstfh);
					dos_delete(pdst_path);
					dos_error();
					goto closeit;
				}
				if (amntrd < d->g_xlen)
				{
					dos_set(dstfh, time, date);
					ret = TRUE;
					break;
				} else
				{
					amntrd = Fread(srcfh, d->g_xlen, d->g_xbuf);
					if (amntrd == 0)
						break;
					if (!dos_error())
						break;
				}
			}
			dos_close(dstfh);
		}
	closeit:
		dos_close(srcfh);
		break;
	}
	
	if (op == OP_MOVE && ret == TRUE && copyok == 1 &&
		!streq(psrc_path, pdst_path))
	{
		dos_delete(psrc_path);
		if (DOS_ERR)
		{
			ret = FALSE;
			if (DOS_AX == E_ACCDN)
			{
				ret = TRUE;
				form_error(~E_ACCDN - 30);
			} else
			{
				dos_error();
			}
		}
	}
	
done:
	del_fname(psrc_path);
	if (op != OP_DELETE)
		del_fname(pdst_path);
	
	return ret;
}


/*
 *	Add a new directory name to the end of an existing path.  This
 *	includes appending a \*.*.
 */
/* 104de: 00fd75f2 */
/* 106de: 00e17e9e */
VOID add_path(P(char *)path, P(const char *)name)
PP(register char *path;)
PP(const char *name;)
{
	while (*path != '*')
		path++;
	strcpy(path, name);
	strcat(path, wilds);
}


/* 104de: 00fd7620 */
/* 106de: 00e17edc */
LINEF_STATIC int do_namecon(P(char *)dstpath, P(char *)name)
PP(char *dstpath;)
PP(char *name;)
{
	register THEDSK *d;
	register LPTREE tree;
	register int butt;
	GRECT gr;
	char newname[LEN_ZFNAME + 2];
	
	d = thedesk;
	desk_wait(FALSE);
	tree = (LPTREE)d->g_atree[SAMENAME];
	get_fname(dstpath, newname);
	inf_sset((OBJECT *)tree, FNAME, newname);
	inf_sset((OBJECT *)tree, EDFNAME, newname);
	fm_draw(tree);
	d->ml_havebox = TRUE;
	butt = form_do((OBJECT *)tree, ROOT);
	butt &= 0x7fff;
	LWSET(OB_STATE(butt), NORMAL);
	if (d->ml_dlpr)
	{
		tree = (LPTREE)d->g_atree[CPBOX];
		if (butt == SKIP)
			inf_sset((OBJECT *)tree, CPFILE, "");
		LWSET(OB_STATE(OKCP), SELECTED);
		form_center((OBJECT *)tree, &gr.g_x, &gr.g_y, &gr.g_w, &gr.g_h);
		objc_draw((OBJECT *)tree, ROOT, MAX_DEPTH, gr.g_x, gr.g_y, gr.g_w, gr.g_h);
		LWSET(OB_STATE(OKCP), NORMAL);
	}
	desk_wait(TRUE);
	if (butt == COPY)
		butt = 1;
	else
		butt = butt == QUIT ? 0 : 2;
	fs_sget((LPTREE)d->g_atree[SAMENAME], EDFNAME, d->ml_fstr);
	unfmt_str(d->ml_fstr, name);
	return butt;
}


/* 104de: 00fd7730 */
/* 106de: 00318020 */
LINEF_STATIC BOOLEAN notsame_name(P(char *)srcpath, P(char *)dstpath)
PP(register char *srcpath;)
PP(register char *dstpath;)
{
	if (!streq(srcpath, dstpath))
	{
		while (*srcpath != '\0')
		{
			if (*srcpath != *dstpath)
			{
				if (*srcpath == '*')
					break;
				return TRUE;
			}
			if (*dstpath == '\0')
				return TRUE;
			srcpath++;
			dstpath++;
		}
	}
	return FALSE;
}


/*
 *	Check to see if source is a parent of the destination.
 *	Return TRUE if all ok else FALSE.
 * 	Must assume that src and dst paths both end with "\*.*".
 */
/* 104de: 00fd7774 */
/* 106de: 00e18070 */
BOOLEAN par_chk(P(const char *)psrc_path, P(FNODE *)pf, P(char *)pdst_path)
PP(const char *psrc_path;)
PP(register FNODE *pf;)
PP(char *pdst_path;)
{
	register THEDSK *d;
	
	d = thedesk;
	if (psrc_path[0] != pdst_path[0])	/* check drives */
		return TRUE;
	while (pf != NULL)
	{
		if (pf->f_obid != NIL &&
			(d->g_screen[pf->f_obid].ob_state & SELECTED) &&
			 pf->f_attr == FA_DIREC)
		{
			strcpy(d->g_srcpth, psrc_path);
			add_path(d->g_srcpth, pf->f_name);
			strcpy(d->g_dstpth, pdst_path);
			if (!notsame_name(d->g_srcpth, d->g_dstpth))
			{
				fun_alert(1, STILLCOPY, NULL);
				return FALSE;
			}
		}
		pf = pf->f_next;
	}
	return TRUE;
}


/*
 *	Directory routine to DO File DELeting.
 */
/* 104de: 00fd7814 */
/* 106de: 00e1812a */
LINEF_STATIC BOOLEAN d_dofdel(P(char *)path, P(BOOLEAN) flag)
PP(char *path;)
PP(BOOLEAN flag;)
{
	register THEDSK *d;
	register LPTREE tree;
	int32_t nfiles;
	int32_t ndirs;
	char filename[LEN_ZFNAME + 2];
	char dirname[LEN_ZFNAME + 2];
	
	d = thedesk;
	if (Bconstat(2) && Bconin(2) == 0x610000L &&
		fun_alert(1, ABORTCON, NULL) == 1)
		return FALSE;
	if (d->ml_dlpr)
	{
		tree = (LPTREE)d->g_atree[CPBOX];
		splitpath(path, filename, dirname);
		inf_sset((OBJECT *)tree, CPFILE, filename);
		inf_sset((OBJECT *)tree, CPDIR, dirname);
		if (flag)
		{
			nfiles = d->g_nfiles;
			inf_setsize(&nfiles, d->ml_files, (OBJECT *)tree, NUMFILE, FALSE);
			drawclip((OBJECT *)tree, NUMFILE);
			d->g_nfiles--;
		} else
		{
			inf_sset((OBJECT *)tree, CPFILE, "");
			if (d->g_ndirs != 0)
				d->g_ndirs--;
			ndirs = d->g_ndirs;
			inf_setsize(&ndirs, d->ml_dirs, (OBJECT *)tree, NUMDIR, FALSE);
			drawclip((OBJECT *)tree, NUMDIR);
		}
		drawclip((OBJECT *)tree, CPFILE);
		drawclip((OBJECT *)tree, CPDIR);
	}
	return TRUE;
}


LINEF_STATIC VOID splitpath(P(char *)path, P(char *)filename, P(char *)dirname)
PP(register char *path;)
PP(char *filename;)
PP(char *dirname;)
{
	get_fname(path, filename);
	path = r_slash(path);
	if (path[-1] == ':')
	{
		*dirname = '\0';
	} else
	{
		*path = '\0';
		get_fname(path, dirname);
		*path = '\\';
	}
}


/*
 *	Remove the last directory in the path and replace it with
 *	*.*.
 */
LINEF_STATIC VOID sub_path(P(char *)path)
PP(register char *path;)
{
	/* scan to last slash */
	path = r_slash(path);
	/* now skip to previous directory in path */
	path--;
	while (*path != '\\')
		path--;
	/* append a *.* */
	strcpy(path, wilds);
}
