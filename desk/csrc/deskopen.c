/*      DESKOPEN.C              3/16/89 - 5/23/89       Derek Mui       */
/*      Fix show item           9/6/89                  D.Mui           */
/*      Fixed open dir when there is no window  7/20/90 D.Mui           */
/*      Fixed at do_box when it is from desktop 5/2/91  D.Mui           */
/*      Change all the iconblk to ciconblk      7/11/92 D.Mui           */
/*      FILEFT and FIRIGHT are inverted when    8/06/92 c.gee           */
/*      selected.                                                       */
/*                                                                      */

/************************************************************************/
/*      New Desktop for Atari ST/TT Computer                            */
/*      Atari Corp                                                      */
/*      Copyright 1989,1990     All Rights Reserved                     */
/************************************************************************/

#include "desktop.h"

VOID sh_witem PROTO((NOTHING));
BOOLEAN sh_disk PROTO((char *buffer));
BOOLEAN drv_exist PROTO((int16_t id));
VOID locate_item PROTO((int16_t item, const char **path, BOOLEAN file));



/*
 * Inquire cell size
 */
/* 306de: 00e302e6 */
VOID xvq_chcells(P(int16_t *)num)
PP(int16_t *num;)
{
	contrl[5] = 1;
	gsx_ncode(5, 0, 0);
	*num = intout[0];
}


/*
 * open the default windows
 */
/* 306de: 00e30310 */
VOID open_def(NOTHING)
{
	register int16_t i;
	register DESKWIN *win;

	win = thedesk->winpd;

	for (i = 0; i < MAXWIN; i++)
	{
		if (win[i].w_path[0])
		{
			if (!open_disk(0, win[i].w_path, FALSE))
				win[i].w_path[0] = 0;
		}
	}
}


/* 306de: 00e30366 */
VOID ch_path(P(DESKWIN *)win)
PP(register DESKWIN *win;)
{
	int16_t i, num, len;

	i = 0;
	len = strlen(win->w_path);

	if (win->w_sizes.g_w >= thedesk->full.g_w || len >= 127)
	{
		num = (win->w_sizes.g_w - (2 * gl_wbox)) / gl_wchar;
		if (len > num)
			i = len - num;
	}

	wind_set(win->w_id, WF_NAME, &win->w_path[i], 0, 0);
}


/*
 * Pass in window stuff and tells if you want to open it or not
 * init -- initalize window
 * open -- open a disk
 */
/* 306de: 00e303f8 */
BOOLEAN open_subdir(P(DESKWIN *)win, P(int16_t) icon, P(BOOLEAN) opendisk, P(BOOLEAN) init, P(BOOLEAN) redraw)
PP(register DESKWIN *win;)
PP(int16_t icon;)
PP(BOOLEAN opendisk;)
PP(BOOLEAN init;)
PP(BOOLEAN redraw;)
{
	int16_t handle, num, len, i;
	BOOLEAN status;
	char *path;

	UNUSED(i);
	UNUSED(len);
	UNUSED(num);
	
	desk_wait(TRUE);
	status = FALSE;

	if (!c_path_alloc(win->w_path))		/* check the path length */
		goto sub_1;

	path = win->w_path;
	handle = win->w_id;

	if (read_files(win, 0x16))
	{
		if (init)						/* initalize to zero    */
		{
			wind_set(handle, WF_HSLIDE, 0, 0, 0, 0);
			wind_set(handle, WF_VSLIDE, 0, 0, 0, 0);
			win->w_coli = 0;
			win->w_rowi = 0;
			win->w_obj->ob_width = win->w_work.g_w;
		}

		ch_path(win);					/* check and set the path   */
		winfo(win);

		if (opendisk)					/* open a disk  */
		{
			do_box(win, icon, TRUE, TRUE, FALSE);
			win->w_icon = icon;			/* set the new icon number that */
			open_window(handle);
			view_fixmode(win);
		}

		view_adjust(win);				/* adjust icons according to    */
		status = TRUE;
	}

  sub_1:
	if (status && redraw)
		do_redraw(win->w_id, &win->w_work, 0);

	desk_wait(FALSE);
	UNUSED(path);
	return status;
}


/* 306de: 00e3051e */
VOID show_item(NOTHING)
{
	register DESKWIN *win;

	if (x_status)						/* something is selected    */
	{
		sh_witem();
	} else
	{
		if ((win = w_gfirst()) != NULL)
		{
			strcpy(win->w_buf, wildext);
			win->w_buf[0] = win->w_path[0];
			sh_disk(win->w_buf);
		}
	}
}


/*
 * Show the info of an item
 */
/* 306de: 00e3056c */
VOID sh_witem(NOTHING)
{
	DIR dir1;
	register DIR *dir;
	DIR *dir2;
	register OBJECT *obj;
	register int16_t curri, ret, which;
	int16_t cont, changed, limit;
	int16_t opened, subtype;
	int32_t ndir, nfile, nsize;
	char buffer[20];
	char newname[NAMELEN];
	int32_t sizes[4];
	char *newstr;
	char *oldstr;
	uint16_t len, pos;
	const char *file;
	char *savestr;
#if TOSVERSION >= 0x400
	int16_t mk_x, mk_y, mk_buttons, mk_kstate;
#endif

	UNUSED(sizes);
	
	changed = FALSE;					/* any changes made?    */
	cont = TRUE;
	opened = FALSE;
	back_update = FALSE;

	obj = get_tree(ADFILEIN);

	bfill(32, 0, dr);					/* set up drive table   */

	if (x_type == DESKICON)
	{
		limit = background[0].ob_tail;
		curri = 1;
	} else
	{
		dir2 = x_win->w_memory;
		limit = x_win->w_items;
		curri = 0;
	}

#if !BINEXACT
	subtype = 0; /* quiet compiler */
	dir2 = NULL; /* quiet compiler */
#endif
	while (cont)
	{									/* desktop icon     */
		if (x_type == DESKICON)
		{
		ss_1:
			for (; curri <= limit; curri++)
			{
				if (background[curri].ob_state & SELECTED)
					goto ss_2;
			}
			goto ss_5;

		ss_2:
			subtype = backid[curri].i_type;
			file = backid[curri].i_path;

			switch (subtype)
			{
			case TRASHCAN:				/* trash can info   */
				ret = TRSINFO;
			case DISK:
				strcpy(buffer, wildext);
				buffer[0] = ((CICONBLK *) (background[curri++].ob_spec))->monoblk.ib_char;
				if (sh_disk(buffer))
					goto ss_1;
				else
					goto ss_5;
			}

			curri++;

			if (*file == CHAR_FOR_CARTRIDGE)
			{
				do1_alert(STNOMEM);
				goto ss_1;
			}

			dir1 = dtabuf.dirfile;
		} else							/* window icon  */
		{
			for (; curri < limit; curri++)
			{
				if (dir2[curri].d_state & SELECTED)
					goto ss_3;
			}

			goto ss_5;
		ss_3:
			dir1 = dir2[curri];
			file = put_name(x_win, dir2[curri].d_name);
			curri++;

			if (*file == CHAR_FOR_CARTRIDGE)
			{
				do1_alert(STNOMEM);
				goto ss_1;
			}
		}

		dir = &dir1;
		len = strlen(file) + 20;		/* file's name length   */
		newstr = (char *)Malloc((int32_t) len);
		oldstr = (char *)Malloc((int32_t) len);

		if (!newstr || !oldstr)
		{
			do1_alert(FCNOMEM);
			goto ss_5;
		}

		strcpy(oldstr, file);

		strcpy(newstr, oldstr);

		if (dir->d_att & FA_DIREC)		/* directory file   */
		{
			strcat(newstr, wilds);		/* attach wild card */
			/* i_status = FALSE; */		/* force it to do only one file */

			if (dofiles(newstr, newstr, OP_COUNT, &ndir, &nfile, &nsize, S_TEXT, FALSE))
			{
				f_str(obj, FINFOLDS, ndir);
				f_str(obj, FINFILES, nfile);
				f_str(obj, FISIZE, nsize);
			} else
				goto ss_5;

			*r_slash(newstr) = 0;
			((TEDINFO *) (obj[INFTITLE].ob_spec))->te_ptext = NO_CONST(Foldinfo);
		} else
		{
			*(((TEDINFO *) (obj[FINFOLDS].ob_spec))->te_ptext) = 0;
			*(((TEDINFO *) (obj[FINFILES].ob_spec))->te_ptext) = 0;
			f_str(obj, FISIZE, dir->d_size);
			((TEDINFO *) (obj[INFTITLE].ob_spec))->te_ptext = NO_CONST(Fileinfo);
		}

		fmt_time(dir->d_time, buffer);	/* put in time  */
		inf_sset(obj, FITIME, buffer);
		fmt_date(dir->d_date, buffer);
		inf_sset(obj, FIDATE, buffer);

	sf_1:
		if (!(dir->d_att & FA_DIREC))
		{
			obj[FIRONLY].ob_state = (dir->d_att & FA_RDONLY) ? SELECTED : NORMAL;
			obj[FIRWRITE].ob_state = (dir->d_att & FA_RDONLY) ? NORMAL : SELECTED;
		} else
		{
			obj[FIRONLY].ob_state = DISABLED;
			obj[FIRWRITE].ob_state = DISABLED;
		}
		/* put in name  */
		xinf_sset(obj, FINAME, dir->d_name);
		pos = 0;						/* text position    */

		fm_draw(ADFILEIN);
		opened = TRUE;
	ss_7:
		which = xform_do(obj, 0);

		desk_wait(TRUE);

		if (which == FIOK)				/* OK       */
		{
			fs_sget((LPTREE)obj, FINAME, buffer);
			unfmt_str(buffer, newname);
			rep_path(newname, newstr);

			if (!(dir->d_att & FA_DIREC))
			{
				if (obj[FIRONLY].ob_state & SELECTED)
				{
					if (dir->d_att & FA_RDONLY)
						goto sf_2;

					ret = dir->d_att |= FA_RDONLY;
				} else
				{
					if (dir->d_att & FA_RDONLY)
						ret = dir->d_att &= ~FA_RDONLY;
					else
						goto sf_2;
				}

				Fattrib(oldstr, 1, ret);
				dir->d_att = ret;
				changed = TRUE;
				dr[*oldstr - 'A'] = 1;
			}
			/* name changed ?   */
		sf_2:
			if (!streq(dir->d_name, newname))
			{							/* Yes          */
				if (Frename(0, oldstr, newstr))
				{
					if (do1_alert(STNOMEM) == 1)	/* Retry    */
						goto sf_1;
				} else
				{
					upfdesk(oldstr, newstr);	/* check background file */
					changed = TRUE;
					dr[*oldstr - 'A'] = 1;
				}
			}
		}
		/* OK is selected   */
		desk_wait(FALSE);
	ss_6:
		Mfree(newstr);
		Mfree(oldstr);

		if (which == FICNCL)			/* stop */
			break;
	}

  ss_5:
	if (opened)
		do_finish(ADFILEIN);

	if (changed)						/* something has changed    */
	{
		if (x_type == WINICON)
			up_allwin(x_win->w_path, TRUE);
		else
		{
			for (ret = 0; ret < 32; ret++)
			{
				if (dr[ret])
				{
					buffer[0] = ret + 'A';
					up_allwin(buffer, FALSE);
				}
			}
		}

		if (back_update)
			lp_collect();				/* garbage collection   */
	}
}


/*
 * Show the info of desktop items
 */
/* 306de: 00e30c7e */
BOOLEAN sh_disk(P(char *)buffer)
PP(char *buffer;)
{
	register OBJECT *obj;
	int32_t ndir, nfile, nsize;
	char newname[14];
	int32_t sizes[4];
	buffer[1] = 0;

	if (buffer[0] == CHAR_FOR_CARTRIDGE)
	{
		do1_alert(STNOMEM);
		return TRUE;
	}

	if (!ch_drive(buffer[0]))
		return TRUE;

	obj = get_tree(ADDISKIN);
	inf_sset(obj, DIDRIVE, buffer);
	buffer[1] = ':';
	ndir = nfile = nsize = 0;

#if 0
	i_status = FALSE;	/* force to do only one item    */
#endif

	if (dofiles(buffer, buffer, OP_COUNT, &ndir, &nfile, &nsize, S_TEXT, FALSE))
	{
		f_str(obj, DINFOLDS, ndir);
		f_str(obj, DINFILES, nfile);
		f_str(obj, DIUSED, nsize);
		desk_wait(TRUE);
		desk_dfree(sizes, buffer[0] - 'A' + 1);
		sizes[1] = sizes[0] * sizes[2] * sizes[3];
		f_str(obj, DIAVAIL, sizes[1]);
		Fsetdta(&dtabuf);
		if (Fsfirst(buffer, FA_LABEL))
			newname[0] = 0;				/* No volume label  */
		else
			fmt_str(dtabuf.dirfile.d_name, newname);

		inf_sset(obj, DIVOLUME, newname);
		desk_wait(FALSE);
		fmdodraw(ADDISKIN, 0);
	}

	return TRUE;
}


/*
 * Close a path
 */
/* 306de: 00e30e48 */
VOID close_path(P(DESKWIN *)win)
PP(register DESKWIN *win;)
{
	char *ptr;
	int16_t item;
	char buffer[14];

	UNUSED(ptr);
	save_mid(win->w_path, buffer);
	if (cut_path(win->w_path))			/* close a folder   */
	{
		do_box(win, 0, FALSE, FALSE, FALSE);
#if !BINEXACT
		/* BUG: item uninitialized */
		item = 0;
#endif
		if (!open_subdir(win, item, FALSE, TRUE, TRUE))
			cat_path(buffer, win->w_path);
	} else
	{
		close_top();
	}
}


/*
 * Close top window
 */
/* 306de: 00e30eca */
VOID close_top(NOTHING)
{
	register DESKWIN *win;

	if ((win = get_top()) != NULL)
	{
		do_box(win, win->w_icon, TRUE, FALSE, FALSE);
		close_window(win->w_id, TRUE);	/* close it */
	}
}


/*
 * open an item
 */
/* 306de: 00e30f10 */
VOID open_item(P(int16_t) item, P(int16_t) type, P(DESKWIN *)win)
PP(register int16_t item;)
PP(int16_t type;)
PP(DESKWIN *win;)
{
	char buffer[16];
	register IDTYPE *itype;
	int16_t ret;

	switch (type)
	{
	case DESKICON:
		itype = &backid[item];

		switch (itype->i_type)
		{
		case DISK:						/* open a disk      */
			strcpy(buffer, wildext);
			buffer[0] = itype->i_iblk.ib_char;
			open_disk(item, buffer, TRUE);
			break;

		case TRASHCAN:
			fill_string(itype->i_name, TRSINFO);
			break;

		default:
			return;
		}

		background[item].ob_state = NORMAL;
		do_redraw(0, &thedesk->full, item);
		break;

	case WINICON:
		open_file(win, item, Nostr);
		break;
	}
}


/*
 * Open a file, it may be an executable file
 */
/* 306de: 00e310e6 */
VOID open_file(P(DESKWIN *)win, P(int16_t) item, P(const char *)tail)
PP(register DESKWIN *win;)
PP(int16_t item;)
PP(const char *tail;)
{
	int16_t i, dump, key;
	register DIR *dir;
	char buffer[NAMELEN];

	UNUSED(buffer);
	UNUSED(i);
	
	if (!win)							/* open from the desktop    */
	{
		exec_file(backid[item].i_path, win, item, tail);
	} else
	{
		dir = get_dir(win, item);

		if (dir->d_att & FA_DIREC)		/* open folder  */
		{
			graf_mkstate(&dump, &dump, &dump, &key);

			if (key == K_ALT)
			{
				strcpy(path3, win->w_path);
				cat_path(dir->d_name, path3);
				open_disk(0, path3, FALSE);
			} else
			{
				cat_path(dir->d_name, win->w_path);
				do_box(win, item, FALSE, TRUE, FALSE);
				if (!(open_subdir(win, item, FALSE, TRUE, TRUE)))
					cut_path(win->w_path);
			}
		} else							/* open exec file   */
		{								/* deselect the item    */
#if 0
			get_dir(win, item)->d_state = NORMAL;
			win->w_obj[item].ob_state = NORMAL;
#endif
			exec_file(put_name(win, dir->d_name), win, item, tail);
#if 0
			winfo(win);
#endif
		}
	}
}


/*
 * open a disk icon
 */
/* 306de: 00e31224 */
BOOLEAN open_disk(P(int16_t) icon, P(const char *)path, P(BOOLEAN) init)
PP(int16_t icon;								/* icon number  */)
PP(const char *path;)
PP(BOOLEAN init;)
{
	int16_t handle;
	DESKWIN *win;

	if (path[0] == CHAR_FOR_CARTRIDGE)	/* cartridge    */
	{
		if (!cart_init())				/* error    */
		{
			do1_alert(STNOMEM);
			return FALSE;
		}
	} else
	{
		if (!ch_drive(path[0]))			/* drive exists? */
			return FALSE;
	}

	if (c_path_alloc(path))				/* check the path length    */
	{
		if ((handle = create_window()) == -1)
		{
			do1_alert(STNOWIND);
		} else
		{
			win = get_win(handle);
			strcpy(win->w_path, path);

			if (open_subdir(win, icon, TRUE, init, FALSE))
				return TRUE;
			else
				close_window(handle, FALSE);	/* delete the window    */
		}
	}
	return FALSE;
}


/*
 * Do a grow or shrink box on a disk icon
 */
/* 306de: 00e312ee */
VOID do_box(P(DESKWIN *)win, P(int16_t) item, P(int16_t) desk, P(int16_t) open, P(BOOLEAN) openfull)
PP(DESKWIN *win;)
PP(int16_t item;)
PP(int16_t desk;)
PP(int16_t open;)								/* item number, desk icon, open/close */
PP(BOOLEAN openfull;)
{
	GRECT pc;
	GRECT dc;
	OBJECT *obj;

	obj = win->w_obj;

	rc_copy(openfull ? &thedesk->full : &win->w_work, &dc);

	if ((obj[item].ob_flags & HIDETREE) || !item)
	{
		if (desk)
			rc_center(&thedesk->full, &pc);
		else
			rc_copy(&win->w_work, &pc);

		pc.g_w = 0;
		pc.g_h = 0;
	} else
	{
		objc_offset(obj, item, &pc.g_x, &pc.g_y);
		pc.g_w = gl_wbox;
		pc.g_h = gl_hbox;
	}

	form_dial(open ? FMD_GROW : FMD_SHRINK, pc.g_x, pc.g_y, pc.g_w, pc.g_h, dc.g_x, dc.g_y, dc.g_w, dc.g_h);
}


/*
 * Does the drive exist
 */
/* 306de: 00e313f6 */
BOOLEAN drv_exist(P(int16_t) id)
PP(int16_t id;)
{
	register int32_t map;
	int16_t handle;

	map = (int32_t) Drvmap();
	handle = id - 'A';
	map = map >> handle;
	return (map & 0x01) ? TRUE : FALSE;
}


/*
 * Check drive and put up alert
 */
/* 306de: 00e31432 */
BOOLEAN ch_drive(P(int16_t) id)
PP(int16_t id;)
{
	char buffer[4];

	if (!drv_exist(id))
	{
		buffer[0] = id;
		buffer[1] = 0;
		fill_string(buffer, STNOMEM);
		return FALSE;
	}

	return TRUE;
}



/*
 * Update the desk file or desk dir on the background
 * If new is a NULL pointer then erase the icon if matches
 */
/* 306de: 00e31466 */
VOID upfdesk(P(char *)s, P(char *)new)
PP(char *s;)
PP(register char *new;)
{
	register OBJECT *obj;
	register APP *app;
	register int16_t i, type;
	int16_t install;
	char *ptr;
	char *addr;

	obj = background;

	for (i = 1; i <= obj->ob_tail; i++)
	{
		if (obj[i].ob_flags != HIDETREE)
		{
			type = backid[i].i_type;
		}
	}
	/* check the install application */
	if (!install)
	{
		if (streq(app->a_name, s))
		{
			if (new)
				lp_fill(new, &app->a_name);
			else
				app_free(app);

			back_update = TRUE;
		}
	}

	q_sea(s, new);
}


/*
 * Locate an item
 */
/* 306de: 00e3162c */
VOID locate_item(P(int16_t) item, P(const char **)path, P(BOOLEAN) file)
PP(int16_t item;)
PP(const char **path;)
PP(BOOLEAN file;)
{
	int16_t button;
	char buffer[16];

l_1:
	strcpy(path1, "C:\\*.*");
	path1[0] = (isdrive() & 0x04) ? 'C' : 'A'; /* WTF? */
	strcpy(buffer, Nostr);
	fsel_exinput(path1, buffer, &button, Litem);

	if (button)
	{
		if (file)
		{
			if (buffer[0] && path1[0])
				rep_path(buffer, path1);
			else
				goto l_1;
		}
		lp_fill(path1, path);
		lp_collect();
	}
}
