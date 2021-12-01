/*      DESKFILE.C              3/17/89 - 6/15/89       Derek Mui       */
/*      Change read_files       9/14/89                 D.Mui           */
/*      Change the way it gets icon     9/15/89         D.Mui           */
/*      Fix at sort by date             6/28/90         D.Mui           */
/*      Fix at read_files to allow lower case 7/18/90   D.Mui           */
/*      Fix at read_files for calculating volume value  4/29/91 D.Mui   */
/*      Fix at read_files for calculating volume again  8/13/91 D.Mui   */
/*      Change all the iconblk to ciconblk      7/11/92 D.Mui           */

/************************************************************************/
/*      New Desktop for Atari ST/TT Computer                            */
/*      Atari Corp                                                      */
/*      Copyright 1989,1990     All Rights Reserved                     */
/************************************************************************/

#include "desktop.h"
#include "toserrno.h"


#define CTLC 	3

#undef Setprt
#define Setprt(a) trp14int(0x21, a)

int16_t pri_str PROTO((int16_t where, const char *ptr));


/* 306de: 00e2ab7a */
int16_t pri_str(P(int16_t) where, P(const char *) ptr)
PP(int16_t where;)
PP(const char *ptr;)
{
	int32_t c;
	int16_t ch;

	while (*ptr)
	{
	pr_1:
		if (!Bconout(where, *ptr++))	/* device not present? */
		{
			if (do_alert(2, STNOMEM) == 1)
				goto pr_1;
			else
				return FALSE;
		}

		if (Bconstat(2))
		{
			ch = (int16_t) (c = Bconin(2));
			if (ch == CTLC || ch == 'q' || ch == 'Q' || (c & 0x00ff0000L) == 0x00610000)
				return FALSE;
		}
	}
	return TRUE;
}


/*
 * Create a new folder on the top window
 */
/* 306de: 00e2ada2 */
VOID newfolder(P(DESKWIN *)win)
PP(register DESKWIN *win;)
{
	char namenew[NAMELEN];
	char nameold[NAMELEN];
	char name[NAMELEN];
	int16_t i, ret, update;
	register OBJECT *obj;
	char buf[2];

	UNUSED(i);
	UNUSED(nameold);
	
	if (win->w_path[0] == CHAR_FOR_CARTRIDGE)
	{
		do_alert(1, STNOMEM);
		return;
	}

	if (!c_path_alloc(win->w_path))
		return;

	obj = get_tree(ADMKDBOX);

	while (TRUE)
	{
		update = FALSE;
		name[0] = 0;
		inf_sset(obj, MKNAME, name);
		fm_draw(ADMKDBOX);				/* draw the box     */
		if (xform_do(obj, 0) == MKCNCL)
			break;

		fs_sget((LPTREE)obj, MKNAME, name);
		unfmt_str(name, namenew);
		if (!namenew[0])				/* no name  */
			break;

		rep_path(namenew);	/* append the name  */

		ret = m_sfirst(FA_DIREC);

		if (ret)						/* Error    */
		{
			if (ret == E_FILNF)			/* File Not found */
				goto n_1;

			if (ret == E_ACCDN)			/* access denied */
			{
				buf[0] = win->w_buf[0];
				buf[1] = 0;
				fill_string(buf, STDISKFULL);
			}

			break;
		} else							/* file exists  */
		{
			if (do1_alert(STFOEXISTS) == 2)
				break;
			else
				continue;				/* retry    */
		}
	n_1:
		desk_wait(TRUE);

	n_2:
		if (Dcreate(win->w_buf))
		{
			if (fill_string(win->w_buf, STNOMEM) == 2)
				goto n_2;
		} else
			update = TRUE;

		desk_wait(FALSE);

		break;
	}									/* while    */

	do_finish(ADMKDBOX);

	if (update)
		up_allwin(win->w_path, TRUE);
}


/*
 * Sort the files
 */
/* 306de: 00e2af56 */
VOID sort_file(P(DESKWIN *)win, P(int16_t) mode)
PP(DESKWIN *win;)
PP(int16_t mode;)
{
	register DIR *dir;
	register int16_t n;
	register int16_t gap, i, j, ret;
	DIR buff;
	register DIR *dir2;
	register DIR *dir1;
	char *ps1, *ps2;

	dir = win->w_memory;
	n = win->w_items;

	for (gap = n / 2; gap > 0; gap /= 2)
	{
		for (i = gap; i < n; i++)
		{
			for (j = i - gap; j >= 0; j -= gap)
			{
				if (mode == S_NO)
					goto ss_1;

				if ((dir[j + gap].d_att & FA_DIREC) && (dir[j].d_att & FA_DIREC))
					goto ss_1;

				if (dir[j + gap].d_att & FA_DIREC)
					goto ss_2;

				if (dir[j].d_att & FA_DIREC)
					break;
			ss_1:
				dir1 = &dir[j];
				dir2 = &dir[j + gap];
				ps1 = &dir[j].d_name[0];
				ps2 = &dir[j + gap].d_name[0];

#if !BINEXACT
				ret = 0; /* quiet compiler */
#endif
				switch (mode)
				{
				case S_NO:
					if (dir1->d_order > dir2->d_order)
						ret = 1;
					else
						ret = -1;
					break;

				case S_SIZE:
					if (dir2->d_size > dir1->d_size)
						ret = 1;
					else if (dir2->d_size < dir1->d_size)
						ret = -1;
					else
						ret = strchk(ps1, ps2);
					break;

				case S_TYPE:
					if ((ret = strchk(scasb(ps1, '.'), scasb(ps2, '.'))))
						break;

				case S_NAME:
					ret = strchk(ps1, ps2);
					break;

				case S_DATE:
					ret = 0;
					if (dir2->d_date > dir1->d_date)
						ret = 1;

					if (dir2->d_date < dir1->d_date)
						ret = -1;

					if (!ret)
					{
						if ((dir2->d_time >> 5) > (dir1->d_time >> 5))
							ret = 1;
					}
				}						/* switch    */

				if (ret <= 0)
					break;

			ss_2:
				buff = dir[j];
				dir[j] = dir[j + gap];
				dir[j + gap] = buff;
			}
		}
	}
}


/*
 * Set up all the files pointer
 * Scroll up or down
 */
/* 306de: 00e2b17e */
VOID set_newview(P(int16_t) index, P(DESKWIN *)win)
PP(int16_t index;)
PP(register DESKWIN *win;)
{
	register int16_t i, k, items, vicons;
	DIR *dir;
	register ICONBLK *icon;
	register OBJECT *obj;
	OBJECT *obj1;
	int16_t len, type;
	char *text;
	
	obj = win->w_obj;					/* get all the icons source */
	obj->ob_next = 0xFFFF;
	/* No objects           */
	if (!(items = win->w_items))
	{
		obj->ob_head = 0xFFFF;
		obj->ob_tail = 0xFFFF;
		return;
	} else
	{
		obj->ob_head = 1;
		obj->ob_tail = 1;
	}

	obj++;								/* points to the rigth object   */

	dir = win->w_memory;

	vicons = win->w_hvicons + 1;

	obj1 = get_tree(STNOMEM);
	len = strlen(((TEDINFO *) (obj1[0].ob_spec))->te_ptext);
	text = win->w_text;

	for (k = 1, i = index; ((i < items) && (k < vicons)); i++, k++, obj++)
	{
		if (thedesk->s_view == S_ICON)
		{
			icon = get_icon(type);
			cp_iblk(icon, (ICONBLK *) (obj->ob_spec));
			((CICONBLK *) (obj->ob_spec))->monoblk.ib_char = 0;
			((CICONBLK *) (obj->ob_spec))->monoblk.ib_ptext = &dir[i].d_name[0];
		} else
		{
			bldstring(&dir[i], text);
			text += len;
			*(text - 1) = 0;
		}

		obj->ob_flags = 0;
		obj->ob_state = dir[i].d_state;
		obj->ob_next = k + 1;
	}

	obj--;								/* go back to last one      */
	obj->ob_next = 0;					/* points back to parent    */

	win->w_obj->ob_tail = k - 1;		/* set up the parents   */

	obj++;								/* finish up the rest   */

	for (; k < vicons; k++, obj++)
		obj->ob_flags = HIDETREE;
}


/*
 * Read the files into a window
 */
/* 306de: 00e2b316 */
int16_t read_files(P(DESKWIN *)win, P(int16_t) attr)
PP(register DESKWIN *win;)
PP(int16_t attr;)
{
	register int32_t items, volume, sizes;
	register DIR *addr;
	char buffer[NAMELEN];
	char *path;
	int16_t ret, i;

	items = 0;
	sizes = 0;

	Fsetdta(&dtabuf);					/* set dta buffer   */

	/*  Check to see if the drive is OK     */
	/*  Look for all subdir file        */

	path = win->w_path;

	save_ext(path, buffer);

	i = 0;
	while (buffer[i])
	{
		buffer[i] = toupper(buffer[i]);
		i++;
	}

	rep_path(getall, path);				/* search everything    */

	if (path[0] == CHAR_FOR_CARTRIDGE)
#if BINEXACT
		ret = !cart_sfirst((char *)&dtabuf); /* BUG: missing parameter attr (not used there) */
#else
		ret = !cart_sfirst((char *)&dtabuf, FA_ARCH|FA_DIREC|FA_RDONLY);
#endif
	else
		ret = Fsfirst(path, FA_ARCH|FA_DIREC|FA_RDONLY);		/* Error    */

	if (ret)
	{
		if (ret != E_FILNF)				/* Fatal error  */
		{
			rep_path(buffer, path);
			return FALSE;
		}
	}

	if (win->w_memory)					/* Memory allocated?    */
	{
		Mfree(win->w_memory);			/* Free it      */
		win->w_memory = NULL;
	}

	if (ret == E_FILNF)					/* file not found   */
		goto r_2;

	addr = (DIR *)Malloc(0xFFFFFFFFL);			/* we should have memory */

	if (!addr)							/* No memory        */
	{
		do1_alert(FCNOMEM);
		goto r_1;
	}
	/* How many files we can store */

	volume = ((int32_t) addr) / (int32_t) (sizeof(DIR));

	addr = (DIR *)Malloc(addr);

	win->w_memory = addr;

	if (!volume)
		goto r_2;

	do
	{									/* volume label     */
		if (dtabuf.dirfile.d_att & FA_LABEL)
			goto r_3;
		/* directory file   */
		if (dtabuf.dirfile.d_att & FA_DIREC)
		{
			if (dtabuf.dirfile.d_name[0] == '.')
#if (TOSVERSION >= 0x400) | !BINEXACT
				/* BUGFIX in 4.x; without this will skip names with extension only */
				if (dtabuf.dirfile.d_name[1] == '.' || !dtabuf.dirfile.d_name[1])
#endif
					goto r_3;
		} else
		{								/* file match ?     */
			if (!wildcmp(buffer, dtabuf.dirfile.d_name))
				goto r_3;
		}

		if (items <= volume)
		{
			dtabuf.dirfile.d_order = items;
			dtabuf.dirfile.d_state = NORMAL;
			*addr++ = dtabuf.dirfile;
			sizes += dtabuf.dirfile.d_size;
			items++;
		} else
			break;

	r_3:
		if (path[0] == CHAR_FOR_CARTRIDGE)
			ret = !cart_snext();
		else
			ret = Fsnext();

	} while (!ret);

  r_2:
	rep_path(buffer, path);

	/* Free up some memory      */

	if (items)
	{
		Mshrink(win->w_memory, (int32_t) ((intptr_t) addr - (intptr_t) win->w_memory));
	} else
	{
		Mfree(win->w_memory);
		win->w_memory = NULL;
	}

  r_1:
	win->w_items = (uint16_t) items;		/* total number of files    */
	sort_file(win, thedesk->s_sort);
	return TRUE;
}
