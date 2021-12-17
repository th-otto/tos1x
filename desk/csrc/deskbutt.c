/*      DESKBUTT.C              3/16/89 - 3/22/89       Derek Mui       */
/*      Foption( win )          9/14/89                 D.Mui           */

/************************************************************************/
/*      New Desktop for Atari ST/TT Computer                            */
/*      Atari Corp                                                      */
/*      Copyright 1989,1990     All Rights Reserved                     */
/************************************************************************/

#include "desktop.h"


/*
 * Find an empty icon
 */
/* 306de: 00e281aa */
int16_t av_icon(NOTHING)
{
	register int16_t i, k;
	register OBJECT *obj;
	int16_t x, y, col, row;
	int16_t xcol, xrow, found;

	obj = background;

	for (i = 1; i <= maxicon; i++)
	{
		if (obj[i].ob_flags & HIDETREE)
		{
			k = i;
			col = thedesk->full.g_w / thedesk->g_icw;
			row = thedesk->full.g_h / thedesk->g_icwh;

			for (xrow = 0; xrow < row; xrow++)
			{
				for (xcol = 0; xcol < col; xcol++)
				{
					found = FALSE;
					app_posicon(xcol, xrow, &x, &y);

					for (i = 1; i <= maxicon; i++)
					{
						if (!(obj[i].ob_flags & HIDETREE))
						{
							if (obj[i].ob_x == x && obj[i].ob_y == y)
							{
								found = TRUE;
								break;
							}
						}
					}

					if (!found)
						goto av_1;
				}
			}
		av_1:
			backid[k].i_path = NULL;
			obj[k].ob_flags = NONE;
			obj[k].ob_state = NORMAL;
			obj[k].ob_x = x;
			obj[k].ob_y = y;
			return k;
		}
	}

	return -1;
}


/*
 * Deselect all the disk and trash icons
 */
/* 306de: 00e282fc */
VOID clr_dicons(NOTHING)
{
	GRECT pt;
	register OBJECT *obj;
	int16_t i;

	obj = background;

	if (build_rect(obj, &pt, d_xywh[6], d_xywh[9]))
	{
		for (i = 1; i <= obj[0].ob_tail; i++)
			obj[i].ob_state = NORMAL;

		do_redraw(0, &pt, 0);
	}

}


/*
 * Handle the click event
 */
/* 306de: 00e2836c */
VOID hd_button(P(int16_t) clicks, P(int16_t) kstate, P(int16_t) mx, P(int16_t) my)
PP(int16_t clicks;)
PP(int16_t kstate;)
PP(int16_t mx;)
PP(int16_t my;)
{
	register int16_t item;
	int16_t xitem, type, keypress, state;
	register OBJECT *obj;
	register DESKWIN *win;
	DESKWIN *win1;

	/* click on any objects */

	if (kstate != K_RSHIFT && kstate != K_LSHIFT)
		keypress = FALSE;
	else
		keypress = TRUE;

	if (i_find(mx, my, &win1, &xitem, &type))
	{
		item = xitem;
		win = win1;

		if (type == WINICON)			/* window objects   */
		{
			clr_dicons();				/* clean up desktop icons */

			if (x_win && x_win != win)
				clr_xwin(x_win, TRUE);

			if (!item)					/* hit nothing      */
			{
				if (!keypress)			/* shift key down?  */
					clr_xwin(win, FALSE);

				r_box(win->w_id, win);
				winfo(win);
				return;
			} else						/* hit something    */
			{
				state = obj[item].ob_state;

				if ((state & SELECTED) && !keypress)
					goto a_1;

				if (!keypress)
				{
					clr_xwin(win, FALSE);
					state = SELECTED;
				} else
				{
					state ^= SELECTED;
				}
				
				obj[item].ob_state = state;
				get_dir(win, item)->d_state = state;
				do_redraw(win->w_id, &thedesk->full, item);
				winfo(win);
			}
		} else							/* desktop icon selected    */
		{
			clr_allwin();

			if (!item)					/* hit background       */
			{
				if (!keypress)			/* clean up all the disk icons  */
					clr_dicons();

				r_box(0, (DESKWIN *) 0);
				return;
			} else
			{
				obj = background;
				state = obj[item].ob_state;

				if ((state & SELECTED) && !keypress)
					goto a_1;

				if (!keypress)
				{
					state = SELECTED;
					clr_dicons();
				} else
				{
					state ^= SELECTED;
				}
				
				obj[item].ob_state = state;
				do_redraw(0, &thedesk->full, item);
			}
		}
	a_1:
		o_select();						/* update the search routine    */
		x_select();

		if (clicks == 2)				/* double clicks    */
			open_item(item, type, win);
		else							/* button still down    */
			hd_down(item, type, win);

	}									/* nothing is found    */
}
