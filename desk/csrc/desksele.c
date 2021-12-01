/*      DESKSELE.C              10/9/89                 Derek Mui       */
/*      Change all the iconblk to ciconblk      7/11/92 D.Mui           */

/************************************************************************/
/*      New Desktop for Atari ST/TT Computer                            */
/*      Atari Corp                                                      */
/*      Copyright 1989,1990     All Rights Reserved                     */
/************************************************************************/

#include "desktop.h"


BOOLEAN x_status;			/* for x_select         */
STATIC int16_t x_index;		/* For x_next and x_first   */
int16_t x_type;				/* ditto            */
DESKWIN *x_win;				/* ditto            */
STATIC int16_t x_cur;		/* x_del            */
int16_t d_dir;				/* count how many folders are selected inside the window */


int16_t m_objfind PROTO((OBJECT *obj, int16_t mx, int16_t my, int16_t mode));
BOOLEAN d_sdesk PROTO((const char **name, int16_t *type));


/*
 * Turn off the current selected object
 */
/* 306de: 00e322c6 */
VOID x_del(NOTHING)
{
	DIR *dir;

	if (x_type == WINICON)
	{
		dir = x_win->w_memory;
		dir[x_cur].d_state = NORMAL;
	} else
	{
		background[x_cur].ob_state = NORMAL;
	}
}


/*
 * My own object find
 */
/* 306de: 00e32310 */
int16_t m_objfind(P(OBJECT *)obj, P(int16_t) mx, P(int16_t) my, P(int16_t) mode)
PP(register OBJECT *obj;)
PP(register int16_t mx;)
PP(register int16_t my;)
PP(int16_t mode;)								/* TRUE == window mode  */
{
	register int i, limit;
	int16_t status, offx, offy;
	int16_t x1, y1;
	CICONBLK *iblk;
	GRECT pt;
	
	status = -1;

	offx = obj[0].ob_x;
	offy = obj[0].ob_y;
	limit = obj[0].ob_tail;

	for (i = 1; i <= limit; i++)
	{
		if (obj[i].ob_flags & HIDETREE)
			continue;

		if (obj[i].ob_type == G_ICON)	/* icon ?   */
		{
			x1 = obj[i].ob_x + offx;
			y1 = obj[i].ob_y + offy;

			iblk = (CICONBLK *) (obj[i].ob_spec);
			rc_copy((GRECT *)&iblk->monoblk.ib_xicon, &pt);
			pt.g_x += x1;
			pt.g_y += y1;

			if (!inside(mx, my, &pt))
			{
				rc_copy((GRECT *)&iblk->monoblk.ib_xtext, &pt);
				pt.g_x += x1;
				pt.g_y += y1;
				if (inside(mx, my, &pt))
					status = i;
			} else
			{
				status = i;
			}
		} else							/* text mode    */
		{
			rc_copy((GRECT *)&obj[i].ob_x, &pt);
			pt.g_x += offx;
			pt.g_y += offy;
			if (inside(mx, my, &pt))
				status = i;
		}

		if (status != -1 && mode)
			break;
	}

	if (status == -1)					/* if fails then try the root   */
	{
		if (inside(mx, my, (GRECT *)&obj[ROOT].ob_x))
			status = 0;
	}

	return status;
}


/*
 * Find out which object is selected based on the object structures
 * Type can only be DESKICON or WINICON
 */
/* 306de: 00e324c2 */
BOOLEAN o_select(NOTHING)
{
	register DESKWIN *win;
	register OBJECT *obj;
	register int16_t i, j;

	o_type = WINICON;					/* Try the window   */

	win = w_gfirst();

	while (win)
	{
		obj = win->w_obj;
		j = win->w_obj->ob_tail;

		for (i = 1; i <= j; i++)
		{
			if ((obj[i].ob_state & SELECTED) && obj[i].ob_flags != HIDETREE)
			{
				if (in_parent(obj, i))	/* in side parent's box? */
				{
					o_item = i;
					o_win = win;
					o_status = TRUE;
					return o_status = TRUE;
				}
			}
		}

		win = w_gnext();
	}

	o_type = DESKICON;					/* Now try desktop */
	o_win = (DESKWIN *) 0;
	return o_status = i_next(1, background, &o_item);
}


/*
 * Find out if anything is selected
 */
/* 306de: 00e32582 */
BOOLEAN x_select(NOTHING)
{
	register DESKWIN *win;
	register DIR *dir;
	register int16_t i;
	int16_t j;

	x_win = (DESKWIN *) 0;
	x_type = DESKICON;

	win = w_gfirst();

	while (win)
	{
		dir = win->w_memory;
		for (i = 0; i < win->w_items; i++)
		{
			if (dir[i].d_state & SELECTED)
			{
				x_win = win;
				x_type = WINICON;
				return x_status = TRUE;
			}
		}
		win = w_gnext();
	}

	return x_status = i_next(1, background, &j);
}


/*
 * Extended dir structure search next
 */
/* 306de: 00e3260a */
BOOLEAN x_next(P(const char **)name, P(int16_t *)type)
PP(const char **name;)
PP(int16_t *type;)
{
	register DIR *dir;
	register int16_t i;
	int16_t limit;
	char *str;

	if (x_type == WINICON)
	{
		dir = x_win->w_memory;
		limit = x_win->w_items;

		for (i = x_index; i < limit; i++)
		{
			if (dir[i].d_state & SELECTED)
			{
				str = put_name(x_win, &dir[i].d_name[0]);
				if (dir[i].d_att & FA_DIREC)
				{
					strcat(str, wilds);
					d_dir++;
					*type = FA_DIREC;
				} else
				{
					*type = x_type;
				}
				
				*name = str;
				x_cur = i;
				x_index = i + 1;
				return TRUE;
			}
		}
		return FALSE;
	} else
		return d_sdesk(name, type);
}


/*
 * Object oriented search first
 * Returns icon type, WINICON, DISK, SUBDIR
 * Extended dir search first
 */
/* 306de: 00e326f8 */
BOOLEAN x_first(P(const char **)name, P(int16_t *)type)
PP(const char **name;)
PP(int16_t *type;)
{
	register DESKWIN *win;
	register int16_t i, j;
	DIR *dir;

	d_dir = 0;

	x_type = DESKICON;					/* try desktop first    */
	x_win = NULL;

	if (i_next(1, background, &x_index))
		return x_next(name, type);

	win = w_gfirst();

	while (win)							/* inside a window? */
	{
		dir = win->w_memory;
		j = win->w_items;

		for (i = 0; i < j; i++)
		{
			if (dir[i].d_state & SELECTED)
			{
				x_index = i;
				x_type = WINICON;
				x_win = win;
				return x_next(name, type);
			}
		}

		win = w_gnext();
	}

	return FALSE;
}


/*
 * Find out what the user has clicked on based on the mx and my
 */
/* 306de: 00e327aa */
BOOLEAN i_find(P(int16_t) mx, P(int16_t) my, P(DESKWIN **)winout, P(int16_t *)item, P(int16_t *)type)
PP(register int16_t mx;)
PP(register int16_t my;)
PP(DESKWIN **winout;)
PP(int16_t *item;)
PP(int16_t *type;)
{
	register DESKWIN *win;
	register int16_t which;

	win = w_gfirst();

	while (win)
	{									/* inside a window boundary */
		if (inside(mx, my, &win->w_sizes))
		{
			*winout = win;
			*type = WINICON;
			*item = 0;
			/* inside the work area */
			if (inside(mx, my, &win->w_work))
			{
				if ((which = m_objfind(win->w_obj, mx, my, TRUE)) != -1)
					*item = which;
			}

			return TRUE;
		}

		win = w_gnext();
	}

	/* try desktop      */
	if ((which = m_objfind(background, mx, my, FALSE)) != -1)
	{
		*item = which;
		*type = DESKICON;
		*winout = (DESKWIN *) 0;
		return TRUE;
	}

	return FALSE;
}


/*
 * Search for next selected OBJECT
 */
/* 306de: 00e32878 */
BOOLEAN i_next(P(int16_t) start, P(OBJECT *)obj, P(int16_t *)itemout)
PP(int16_t start;)
PP(register OBJECT *obj;)
PP(int16_t *itemout;)
{
	register int16_t limit, i;

	limit = obj->ob_tail;

	for (i = start; i <= limit; i++)
	{
		if ((!(obj[i].ob_flags & HIDETREE)) && (obj[i].ob_state & SELECTED))
		{
			*itemout = i;
			return TRUE;
		}
	}

	return FALSE;
}


/*
 * Search the selected desktop object
 * Used by x_next only
 */
/* 306de: 00e328ce */
BOOLEAN d_sdesk(P(const char **)name, P(int16_t *)type)
PP(const char **name;)
PP(int16_t *type;)
{
	int16_t temp, i;
	register IDTYPE *itype;

	UNUSED(i);
	while (i_next(x_index, background, &x_index))
	{
		itype = &backid[x_index];
		temp = itype->i_type;

		if (temp == DISK)
		{
			strcpy(path1, wildext);
			path1[0] = itype->i_iblk.ib_char;
			*name = path1;
			*type = temp;
			goto xd_1;
		} else if (itype->i_path)
		{
			*name = itype->i_path;
			*type = temp;

		xd_1:
			x_cur = x_index++;
			return TRUE;
		} else
		{
			x_index++;
		}
	}

	return FALSE;
}
