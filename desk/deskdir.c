/*      DESKDIR.C       09/03/84 - 06/05/85     Lee Lorenzen            */
/*                      4/7/86   - 8/27/86      MDF                     */
/*      merge source    5/19/97  - 5/28/87      mdf                     */
/*      for 3.0         11/13/87                mdf                     */

/*
 *       Copyright 1999, Caldera Thin Clients, Inc.                      
 *       This software is licenced under the GNU Public License.         
 *       Please see LICENSE.TXT for further information.                 
 *                                                                       
 *                  Historical Copyright                                 
 *       -------------------------------------------------------------
 *       GEM Desktop                                       Version 3.0
 *       Serial No.  XXXX-0000-654321              All Rights Reserved
 *       Copyright (C) 1987                      Digital Research Inc.
 *       -------------------------------------------------------------
 */

#include "desktop.h"
#include "taddr.h"
#include "dos.h"

#undef Fread
#define Fread(a,b,c)    trap(0x3f,a,b,c)
#undef Fwrite
#define Fwrite(a,b,c)    trap(0x40,a,b,c)
#ifdef __ALCYON__
#undef Bconstat
#undef Bconin
#define Bconstat(a) trp13(0x10002L)
#define Bconin(d) trp13(0x20002L)
#endif


#define FO_RDONLY        0	/* Open read-only - same as O_RDONLY */
#define FO_WRONLY        1	/* Open write-only - same as O_WRONLY */
#define FO_RDWR          2	/* Open read/write - same as O_RDWR */


int f_level;
int f_maxlevel;
uint8_t gl_dta[sizeof(DTA) + 6];


LINEF_STATIC VOID sub_path PROTO((char *path));
LINEF_STATIC VOID do_namecon PROTO((NOTHING));
LINEF_STATIC BOOLEAN d_dofdel PROTO((char *path));
LINEF_STATIC VOID show_hide PROTO((OBJECT *tree));



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
	/* form_dial(FMD_START, 0, 0, 0, 0, x, y, w, h); */
	objc_draw((OBJECT *)tree, ROOT, MAX_DEPTH, x, y, w, h);
}


VOID do_namecon(NOTHING)
{
	register THEDSK *d;
	
	d = thedesk;
	desk_wait(FALSE);
	if (d->ml_havebox)
	{
		fm_draw((LPTREE)d->g_atree[SAMENAME]);
	} else
	{
		show_hide(d->g_atree[SAMENAME]);
		d->ml_havebox = TRUE;
	}
	form_do(d->g_atree[SAMENAME], 0);
	if (d->ml_dlpr)
	{
		ob_change((LPTREE)d->g_atree[CPBOX], OKCP, SELECTED, FALSE);
		fm_draw((LPTREE)d->g_atree[CPBOX]);
		ob_change((LPTREE)d->g_atree[CPBOX], OKCP, NORMAL, FALSE);
	}
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


LINEF_STATIC VOID show_hide(P(OBJECT *) tree)
PP(OBJECT *tree;)
{
	int16_t xd, yd, wd, hd;

	form_center(tree, &xd, &yd, &wd, &hd);
	form_dial(FMD_START, 0, 0, 0, 0, xd, yd, wd, hd);
	objc_draw(tree, ROOT, MAX_DEPTH, xd, yd, wd, hd);
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
	strcat(path, "\\*.*");
}


/*
 *	Remove the last directory in the path and replace it with
 *	*.*.
 */
LINEF_STATIC VOID sub_path(P(char *)path)
PP(register char *path;)
{
	/* scan to last slash */
	while (*path)
		path++;

	/* now skip to previous directory in path */
	while (*path != '\\')
	{
		path--;
	}
	path--;
	while (*path != '\\')
	{
		path--;
	}
	/* append a *.* */
	strcpy(path, "\\*.*");
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
	/* scan to last slash */
	while (*path)
		path++;
	while (*path != '\\')
		path--;
	strcpy(path, "\\*.*");
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
	while (*pstr)
		pstr++;
	while (*pstr != '\\')
		pstr--;
	pstr++;
	strcpy(d->ml_ftmp, pstr);
	fmt_str(d->ml_ftmp, newstr);
}


/* 104de: 00fd6ad0 */
/* 106de: 00e171f4 */
/* aka d_errmsg */
BOOLEAN dos_error(NOTHING)
{
	if (DOS_ERR)
	{
		if (DOS_AX <= -32)
			form_error(~DOS_AX - 30);
		return FALSE;
	}
	return TRUE;
}


/*
 *	Directory routine to DO File DELeting.
 */
/* 104de: 00fd7814 */
/* 106de: 00e1812a */
LINEF_STATIC BOOLEAN d_dofdel(P(char *)path)
PP(char *path;)
{
	dos_delete(ADDR(path));
	return dos_error();
}


/*
 *	Directory routine to DO File COPYing.
 */
/* 104de: 00fd7316 */
/* 106de: 00e17b2a */
LINEF_STATIC BOOLEAN d_dofcopy(P(char *)psrc_file, P(char *)pdst_file, P(uint16_t) time, P(uint16_t) date, P(int) attr)
PP(register char *psrc_file;)
PP(char *pdst_file;)
PP(uint16_t time;)
PP(uint16_t date;)
PP(int attr;)
{
	register THEDSK *d;
	int16_t srcfh, dstfh;
	int16_t amntrd, amntwr;
	register BOOLEAN copy;
	register BOOLEAN cont;
	register BOOLEAN more;
	register BOOLEAN samedir;
	
	UNUSED(samedir);
	d = thedesk;
	copy = TRUE;
	/* open the source file */
	srcfh = dos_open(ADDR(psrc_file), 0);
	if (!(more = dos_error()))
		return more;
	/* open the dest file   */
	cont = TRUE;
	while (cont)
	{
		copy = FALSE;
		more = TRUE;
		dstfh = dos_open(ADDR(pdst_file), 0);
		/* handle dos error */
		if (DOS_ERR)
		{
			if (DOS_AX == E_FILENOTFND)
				copy = TRUE;
			else
				more = dos_error();
			cont = FALSE;
		} else
		{
			/* dest file already exists */
			dos_close(dstfh);
			/* get the filenames from the pathnames */
			get_fname(psrc_file, &d->ml_fsrc[0]);
			get_fname(pdst_file, &d->ml_fdst[0]);
			/* put in filenames in dialog */
			inf_sset(d->g_atree[SAMENAME], FNAME, d->ml_fsrc);
			inf_sset(d->g_atree[SAMENAME], EDFNAME, d->ml_fdst);
			strcpy(d->ml_fsrc, d->ml_fdst);

			/* show dialog */

			do_namecon();

			/* if okay then if its  */
			/*   the same name then */
			/*   overwrite else get */
			/*   new name and go    */
			/*   around to check it */
			copy = inf_what(d->g_atree[SAMENAME], COPY, QUIT);

			if (copy)
			{
				desk_wait(TRUE);
				fs_ssget(d->g_atree[SAMENAME], EDFNAME, d->ml_fdst);
				if (streq(d->ml_fsrc, d->ml_fdst))
					cont = FALSE;
				unfmt_str(d->ml_fdst, d->ml_fstr);
				if (d->ml_fstr[0] == 0)
				{
					copy = cont = FALSE;
				} else
				{
					del_fname(pdst_file);
					add_fname(pdst_file, d->ml_fstr);
				}
			} else
			{
				dos_close(srcfh);
				cont = copy = FALSE;
			}
		}
	}

	if (copy && more)
		dstfh = dos_create(ADDR(pdst_file), attr & ~FA_RDONLY);
	amntrd = copy;
	while (amntrd && more)
	{
		if ((more = dos_error()))
		{
			amntrd = dos_read(srcfh, d->g_xlen, d->g_xbuf);
			if ((more = dos_error()))
			{
				if (amntrd)
				{
					amntwr = dos_write(dstfh, amntrd, d->g_xbuf);
					if ((more = dos_error()))
					{
						if (amntrd != amntwr)
						{
							/* disk full        */
							fun_alert(1, STDISKFULL, NULL);
							more = FALSE;
							dos_close(srcfh);
							dos_close(dstfh);
							d_dofdel(ADDR(pdst_file));
						}
					}
				}
			}
		}
	}
	if (copy && more)
	{
		dos_set(dstfh, time, date);
		more = dos_error();
		dos_close(srcfh);
		dos_close(dstfh);
	}

	return more;
}


/*
 *	Directory routine to DO an operation on an entire sub-directory.
 */
/* 104de: 00fd6e40 */
/* 106de: 00e175d0 */
BOOLEAN d_doop(P(int) op, P(OBJECT *)tree, P(char *)psrc_path, P(char *)pdst_path, P(uint16_t *)pfcnt, P(uint16_t *)pdcnt)
PP(int op;)
PP(OBJECT *tree;)
PP(char *psrc_path;)
PP(register char *pdst_path;)
PP(uint16_t *pfcnt;)
PP(uint16_t *pdcnt;)
{
	register int cont;
	register int skip;
	register int more;
	register int level;
	register int max_level;
	register char *ptmp;
	register THEDSK *d;
	
	d = thedesk;
	/* start recursion at level 0 */
	level = 0;
	max_level = 1;
	f_level = 1;

	dos_sdta(&d->g_dtastk[level]);
	dos_sfirst(ADDR(psrc_path), FA_DIREC|FA_HIDDEN|FA_SYSTEM);

	cont = more = TRUE;
	while (cont && more)
	{
		skip = FALSE;
		if (DOS_ERR)
		{
			/* no more files error  */
			if (DOS_AX == E_NOFILES || DOS_AX == E_FILENOTFND)
			{
				switch (op)
				{
				case OP_COUNT:
					d->g_ndirs++;
					break;
				case OP_DELETE:
					ptmp = psrc_path;
					while (*ptmp != '*')
						(VOID)*ptmp++; /* BUG: dereference */
					ptmp--;
					*ptmp = 0;
					dos_rmdir(ADDR(psrc_path));
					more = dos_error();
					strcat(psrc_path, "\\*.*");
					break;
				case OP_COPY:
					/* break */
					;
				}
				if (tree)
				{
					*pdcnt -= 1;
					merge_str(d->ml_dirs, "%W", pdcnt);
					inf_sset(tree, d->ml_dlfo, d->ml_dirs);
					drawfld(tree, d->ml_dlfo);
				}
				skip = TRUE;
				if (max_level > f_level)
					f_level = max_level;
				max_level = 1;
				level--;
				if (level < 0)
				{
					cont = FALSE;
				} else
				{
					sub_path(psrc_path);
					if (op == OP_COPY)
						sub_path(pdst_path);
					dos_sdta(ADDR(&d->g_dtastk[level]));
				}
			} else
			{
				more = dos_error();
			}
		}
		if (!skip && more)
		{
			if (d->g_dtastk[level].dirfile.d_att & FA_DIREC)
			{							/* step down 1 level    */
				if (d->g_dtastk[level].dirfile.d_name[0] != '.' && level < MAX_LEVEL)
				{
					/* change path name */
					add_path(psrc_path, d->g_dtastk[level].dirfile.d_name);
					if (op == OP_COPY)
					{
						add_fname(pdst_path, d->g_dtastk[level].dirfile.d_name);
						dos_mkdir(ADDR(pdst_path));
						more = dos_error();
						strcat(pdst_path, "\\*.*");
					}
					level++;
					max_level++;
					dos_sdta(ADDR(&d->g_dtastk[level]));
					if (more)
						dos_sfirst(ADDR(psrc_path), FA_DIREC|FA_HIDDEN|FA_SYSTEM);
				}
			} else
			{
				if (op != OP_COUNT)
					add_fname(psrc_path, d->g_dtastk[level].dirfile.d_name);
				switch (op)
				{
				case OP_COUNT:
					d->g_nfiles++;
					d->g_size += d->g_dtastk[level].dirfile.d_size;
					break;
				case OP_DELETE:
					more = d_dofdel(psrc_path);
					break;
				case OP_COPY:
					add_fname(pdst_path, d->g_dtastk[level].dirfile.d_name);
					more = d_dofcopy(psrc_path, pdst_path,
									 d->g_dtastk[level].dirfile.d_time,
									 d->g_dtastk[level].dirfile.d_date,
									 d->g_dtastk[level].dirfile.d_att);
					del_fname(pdst_path);
					/* break; */
				}
				if (op != OP_COUNT)
					del_fname(psrc_path);
				if (tree)
				{
					*pfcnt -= 1;
					merge_str(d->ml_files, "%W", pfcnt);
					inf_sset(tree, d->ml_dlfi, d->ml_files);
					drawfld(tree, d->ml_dlfi);
				}
			}
		}
		if (cont)
			dos_snext();
	}

	return more;
}


/*
 *	return pointer to next folder in path.
 *	start at the current position of the ptr.
 *	assume path will eventually end with \*.*
 */
LINEF_STATIC char *ret_path(P(char *) pcurr, P(char *) path)
PP(register char *pcurr;)
PP(register char *path;)
{
	/* find next level */
	while (*pcurr != '\\' && *pcurr)
		(VOID)*pcurr++; /* BUG: dereference */
	(VOID)*pcurr++; /* BUG: dereference */
	while (path != pcurr)
		(VOID)*path++; /* BUG: dereference */
	while (*path != '\\' && *path)
		(VOID)*path++; /* BUG: dereference */
	*path = '\0';
	return pcurr;
}


/*
 *	Check to see if source is a parent of the destination.
 *	Return TRUE if all ok else FALSE.
 * 	Must assume that src and dst paths both end with "\*.*".
 */
/* 104de: 00fd7774 */
/* 106de: 00e18070 */
BOOLEAN par_chk(P(const char *)psrc_path, P(FNODE *)pflist, P(char *)pdst_path)
PP(const char *psrc_path;)
PP(FNODE *pflist;)
PP(char *pdst_path;)
{
	BOOLEAN same;
	BOOLEAN notsame;
	FNODE *last;
	int len;
	register char *tsrc;
	register char *tdst;
	register FNODE *pf;
	THEDSK *d;
	
	d = thedesk;
	if (psrc_path[0] != pdst_path[0])	/* check drives */
		return TRUE;
	notsame = FALSE;
	for (pf = pflist; pf != NULL; pf = pf->f_next)
	{
		if (pf->f_obid != NIL &&
			(d->g_screen[pf->f_obid].ob_state & SELECTED) &&
			 pf->f_attr == FA_DIREC)
		{
			notsame = TRUE;
			last = pf;
		}
	}
	if (notsame)
	{
		tsrc = d->g_srcpth;
		tdst = d->g_dstpth;
		same = FALSE;
		for (;;)
		{
			strcpy(d->g_srcpth, psrc_path);
			len = (int)strlen(d->g_srcpth);
			d->g_srcpth[len - 3] = '\0';
			strcat(d->g_srcpth, last->f_name);
			strcat(d->g_srcpth, "\\*.*");
			strcpy(d->g_dstpth, pdst_path);
			tsrc = ret_path(tsrc, d->g_srcpth);
			tdst = ret_path(tdst, d->g_dstpth);
			if (!streq(tsrc, "*.*") && !streq(tdst, "*.*"))
			{
				same = streq(tdst, tsrc) ? TRUE : FALSE;
			} else
			{
				break;
			}
		}
		if (same)
		{
			fun_alert(1, STILLCOPY, NULL);
			return FALSE;
		}
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
BOOLEAN dir_op(P(int) op, P(char *)psrc_path, P(FNODE *)pflist, P(char *)pdst_path, P(uint16_t *)pfcnt, P(uint16_t *)pdcnt, P(uint32_t *)psize)
PP(int op;)
PP(char *psrc_path;)
PP(FNODE *pflist;)
PP(char *pdst_path;)
PP(uint16_t *pfcnt;)
PP(uint16_t *pdcnt;)
PP(uint32_t *psize;)
{
	LPTREE tree;
	register FNODE *pf;
	long lavail;
	FNODE *f_next;
	BOOLEAN ret;
	BOOLEAN more;
	register int obj;
	register THEDSK *d;
	char *pglsrc;
	char *pgldst;
	
	UNUSED(pglsrc);
	UNUSED(pgldst);
	UNUSED(obj);
	d = thedesk;
	tree = 0;
	d->ml_havebox = FALSE;
	f_maxlevel = 0;
	switch (op)
	{
	case OP_COUNT:
		d->g_nfiles = 0;
		d->g_ndirs = 0;
		d->g_size = 0;
		break;
	case OP_DELETE:
		if ((d->ml_dlpr = d->g_cdelepref))
		{
			tree = (LPTREE)d->g_atree[DELBOX];
			d->ml_dlfi = DELFILES;
			d->ml_dlfo = DELDIR;
			d->ml_dlok = DELOK;
			d->ml_dlcn = DELCNCL;
		}
		break;
	case OP_COPY:
		lavail = dos_avail();
		d->g_xlen = (lavail > 0x0000fff0L) ? 0xfff0 : LLOWD(lavail);
		d->g_xlen -= 0x0200;
		d->g_xbuf = dos_alloc(LW(d->g_xlen));

		if ((d->ml_dlpr = d->g_ccopypref))
		{
			tree = (LPTREE)d->g_atree[CPBOX];
			d->ml_dlfi = NUMFILE;
			d->ml_dlfo = NUMDIR;
			d->ml_dlok = OKCP;
			d->ml_dlcn = CCANCEL;
		}
		break;
	}

	if (tree)
	{
		merge_str(d->ml_files, "%W", pfcnt);
		inf_sset((OBJECT *)tree, d->ml_dlfi, d->ml_files);
		merge_str(d->ml_dirs, "%W", pdcnt);
		inf_sset((OBJECT *)tree, d->ml_dlfo, d->ml_dirs);
		d->ml_havebox = TRUE;
		show_hide((OBJECT *)tree);
		form_do((OBJECT *)tree, ROOT);
		ret = inf_what((OBJECT *)tree, d->ml_dlok, d->ml_dlcn);
		if (ret)
			desk_wait(TRUE);
	} else
	{
		ret = TRUE;
	}

	if (ret)
	{
		for (pf = pflist, more= TRUE; pf && more; pf = f_next)
		{
			f_next = pf->f_next;
			if (pf->f_obid != NIL && (d->g_screen[pf->f_obid].ob_state & SELECTED))
			{
				strcpy(d->g_srcpth, psrc_path);
				if (op == OP_COPY)
				{
					strcpy(d->g_dstpth, pdst_path);
				}
				if (pf->f_attr == FA_DIREC)
				{
					add_path(d->g_srcpth, &pf->f_name[0]);
					switch (op)
					{
					case OP_COPY:
						add_fname(d->g_dstpth, pf->f_name);
						dos_sdta(gl_dta);
						if (dos_sfirst(d->g_dstpth, FA_DIREC|FA_HIDDEN|FA_SYSTEM))
						{
							DOS_ERR = TRUE;
							DOS_AX = E_NOACCESS;
						} else
						{
							dos_mkdir(ADDR(d->g_dstpth));
						}
						while (DOS_ERR && more)
						{
							/* see if dest folder already exists */
							if (DOS_AX == E_NOACCESS)
							{
								/* get the folder name from the pathnames */
								fmt_str(pf->f_name, d->ml_fsrc);
								d->ml_fdst[0] = 0;
								/* put in folder name in dialog */
								inf_sset(d->g_atree[SAMENAME], FNAME, d->ml_fsrc);
								inf_sset(d->g_atree[SAMENAME], EDFNAME, d->ml_fdst);
								/* show dialog */
								do_namecon();
								/* if okay then make dir or try again */
								/* until we succeed or cancel is hit */
								more = inf_what(d->g_atree[SAMENAME], COPY, QUIT);

								if (more)
								{
									desk_wait(TRUE);
									fs_ssget(d->g_atree[SAMENAME], EDFNAME, d->ml_fdst);
									unfmt_str(d->ml_fdst, d->ml_fstr);
									del_fname(d->g_dstpth);
									if (d->ml_fstr[0] != 0)
									{
										add_fname(d->g_dstpth, d->ml_fstr);
										if (dos_sfirst(d->g_dstpth, FA_DIREC|FA_HIDDEN|FA_SYSTEM))
										{
											DOS_ERR = TRUE;
											DOS_AX = E_NOACCESS;
										} else
										{
											dos_mkdir(ADDR(d->g_dstpth));
										}
									} else
									{
										more = FALSE;
									}
								}
							} else
							{
								more = FALSE;
							}
						}
						strcat(d->g_dstpth, "\\*.*");
					}
					if (more)
					{
						more = d_doop(op, (OBJECT *)tree, d->g_srcpth, d->g_dstpth, pfcnt, pdcnt);
						if (f_level > f_maxlevel)
							f_maxlevel = f_level;
					}
				} else
				{
					if (op != OP_COUNT)
						add_fname(d->g_srcpth, &pf->f_name[0]);
					switch (op)
					{
					case OP_COUNT:
						d->g_nfiles++;
						d->g_size += pf->f_size;
						break;
					case OP_DELETE:
						more = d_dofdel(d->g_srcpth);
						break;
					case OP_COPY:
						add_fname(d->g_dstpth, &pf->f_name[0]);
						more = d_dofcopy(d->g_srcpth, d->g_dstpth, pf->f_time, pf->f_date, pf->f_attr);
						del_fname(d->g_dstpth);
						/* break; */
					}
					if (op != OP_COUNT)
						del_fname(psrc_path);
					if (tree)
					{
						*pfcnt -= 1;
						merge_str(d->ml_files, "%W", pfcnt);
						inf_sset((OBJECT *)tree, d->ml_dlfi, d->ml_files);
						drawfld((OBJECT *)tree, d->ml_dlfi);
					}
				}
			}
		}
	}
	
	switch (op)
	{
	case OP_COUNT:
		*pfcnt = d->g_nfiles;
		*pdcnt = d->g_ndirs;
		*psize = d->g_size;
		break;
	case OP_DELETE:
		break;
	case OP_COPY:
		dos_free(d->g_xbuf);
		/* break; */
	}
	
	if (d->ml_havebox)
		do_finish(d->g_atree[SAMENAME]);
	return TRUE;
}
