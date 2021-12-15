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
			if (fun_alert(2, STNOMEM) == 1)
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
