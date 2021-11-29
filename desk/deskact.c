/*      DESKACT.C               5/31/89 - 6/19/89       Derek Mui       */
/*      Take out vdi_handle from vdi calls      6/28/89                 */
/*      Fix hd_down, it needs to update menu    7/3/90  D.Mui           */
/*      Modifying hd_down       7/8/90                  D.Mui           */
/*      Fix at hd_down to solve bug when mouse is moving too fast       */
/*                              4/16/91                 D.Mui           */
/*      Fix at file_op to check for destination drive   4/18/91 D.Mui   */
/*      Fix at file_op to do update for all affected windows 4/18/91    */
/*      Change all the iconblk to ciconblk      7/11/92 D.Mui           */

/************************************************************************/
/*      New Desktop for Atari ST/TT Computer                            */
/*      Atari Corp                                                      */
/*      Copyright 1989,1990     All Rights Reserved                     */
/************************************************************************/

#include "desktop.h"

BOOLEAN back_update;						/* update background    */

VOID chk_rect PROTO((DESKWIN *win, GRECT *rect, int16_t id));
VOID frame PROTO((int16_t x1, int16_t y1, int16_t x2, int16_t y2));
int16_t dist PROTO((int16_t x, int16_t y));
VOID desk_desk PROTO((int16_t sitem, int16_t ditem, int16_t mx, int16_t my));
BOOLEAN gh_init PROTO((OBJECT *obj, BOOLEAN disk));
VOID ghost_icon PROTO((int16_t offx, int16_t offy, BOOLEAN disk));
VOID to_desk PROTO((int16_t ditem, const char *tail));
VOID to_win PROTO((int16_t sitem, DESKWIN *swin, int16_t ditem, DESKWIN *dwin));




/*
 * Check what kind of object is executable
 * Return TRUE if it is
 */
/* 306de: 00e26466 */
BOOLEAN ch_obj(P(int16_t) mx, P(int16_t) my, P(DESKWIN **) win, P(int16_t *) item, P(int16_t *) type)
PP(int16_t mx;)
PP(int16_t my;)
PP(DESKWIN **win;)
PP(int16_t *item;)
PP(int16_t *type;)
{
	register int16_t i;
	DIR *dir;
	BOOLEAN install;
	APP *app;
	const char *str;

	if (i_find(mx, my, win, item, type))
	{
		i = *item;
		if (i)							/* if there is object   */
		{
			if (*type == DESKICON)
			{
				return TRUE;
			} else
			{
				dir = get_dir(*win, i);
				if (dir->d_att & FA_DIREC)	/* dir is OK    */
					return TRUE;

				str = put_name(*win, dir->d_name);
				/* check file type  */
			ch_1:

				if (!install)
				{
					switch (app->a_type)	/* executable is OK */
					{
					case TOS:
					case TTP:
					case PRG:
						return TRUE;
					}
				}
			}							/* window object   */
		}
	}
	/* if found something  */
	return FALSE;
}


/*
 * Check for UNDO key
 */
/* 306de: 00e26566 */
BOOLEAN ch_undo(NOTHING)
{
	if (Bconstat(2) && Bconin(2) == 0x00610000L && do1_alert(ABORTCON) == 1)
		return FALSE;

	return TRUE;
}


/*
 * Perform a file operation
 */
/* 306de: 00e265b0 */
VOID file_op(P(const char *) dest, P(int16_t) mode)
PP(const char *dest;)
PP(int16_t mode;)
{
	register OBJECT *obj;
	register BOOLEAN ret;
	int16_t type, item, i;
	int16_t keydown;
	int32_t ndir, nfile, nsize;
	const char *source;
	char buffer[2];
	GRECT pt;
	const char *which;

	/* get the key state */

	graf_mkstate(&item, &item, &item, &keydown);
	f_rename = (keydown & K_ALT) ? TRUE : FALSE;

	if (!x_first(&source, &type))
		return;

	if (mode != OP_DELETE)
	{
		if (!ch_drive(*dest))
			return;
	}

	d_display = TRUE;
	back_update = FALSE;
	buffer[1] = 0;

	obj = get_tree(CPBOX);

#if !BINEXACT
	which = 0; /* quiet compiler */
#endif
	switch (mode)
	{
	case OP_DELETE:
		which = Delstr;
		if (!thedesk->cdele_save)
			d_display = FALSE;
		break;

	case OP_COPY:
		if (!(keydown & K_CTRL))		/* control key down?    */
		{
			which = f_rename ? Crenstr : Cpystr;
			if (!thedesk->ccopy_save)
				d_display = FALSE;
			break;
		}

	case OP_MOVE:
		mode = OP_MOVE;
		which = f_rename ? Mrenstr : Movestr;
		if (!thedesk->ccopy_save && !thedesk->cdele_save)
			d_display = FALSE;
		break;
	}

	build_rect(background, &pt, d_xywh[6], d_xywh[9]);

	if (!dofiles(source, dest, OP_COUNT, &ndir, &nfile, &nsize, type, TRUE))
	{
		return;
	}

	ndir += d_dir;						/* count also the number of dir in window */
	((TEDINFO *) (obj[TITLE].ob_spec))->te_ptext = NO_CONST(which);
	f_str(obj, NUMDIR, ndir);
	f_str(obj, NUMFILE, nfile);
	buffer[0] = *dest;
	fm_draw(CPBOX);						/* draw the box     */

	if (d_display)
		item = form_do(obj, 0) & 0x7FFF;
	else
		item = OKCP;

	d_display = TRUE;

#if !BINEXACT
	ret = FALSE; /* quiet compiler */
#endif
	if (item == OKCP)
	{
		bfill(32, 0, dr);
		x_first(&source, &type);
		ret = dofiles(source, dest, mode, &ndir, &nfile, &nsize, type, TRUE);
	}

	obj[item].ob_state = NORMAL;
	do_finish(CPBOX);

	if (item == OKCP && ret)
	{
		for (i = 0; i < 32; i++)		/* update all the affected window */
		{
			if (dr[i])
			{
				buffer[0] = i + 'A';
				up_allwin(buffer, TRUE);
			}
		}

		if (back_update)				/* clean up the memory  */
		{
			lp_collect();
			if (mode == OP_DELETE)		/* full screen      */
				rc_copy(&thedesk->full, &pt);
		}

		if (x_type == WINICON)			/* update source window */
		{
			i = x_win->w_path[0] - 'A';
			if (!dr[i])					/* if it is not updated yet */
				up_2(x_win);
		}

		do_redraw(0, &pt, 0);
	}
}


/*
 * Build a rectangle that can hold all the selected icons
 */
/* 306de: 00e26984 */
BOOLEAN build_rect(P(OBJECT *) obj, P(GRECT *) rect, P(int16_t) w, P(int16_t) h)
PP(register OBJECT *obj;)
PP(register GRECT *rect;)
PP(int16_t w;)
PP(int16_t h;)
{
	register int16_t i;
	register int16_t minx, miny;
	register int16_t maxx, maxy;
	int16_t found;

	minx = thedesk->full.g_x + thedesk->full.g_w;
	miny = thedesk->full.g_y + thedesk->full.g_h;
	maxx = 0;
	maxy = 0;
	found = FALSE;

	for (i = 1; i <= obj[0].ob_tail; i++)
	{
		if ((obj[i].ob_state & SELECTED) && in_parent(obj, i))
		{
			found = TRUE;

			if (minx > obj[i].ob_x)
				minx = obj[i].ob_x;

			if (miny > obj[i].ob_y)
				miny = obj[i].ob_y;

			if (obj[i].ob_x > maxx)
				maxx = obj[i].ob_x;

			if (obj[i].ob_y > maxy)
				maxy = obj[i].ob_y;
		}
	}

	if (found)
	{
		rect->g_x = minx + obj[0].ob_x;
		rect->g_y = miny + obj[0].ob_y;
		rect->g_w = maxx - minx + w;
		rect->g_h = maxy - miny + h;
	} else
	{
		rect->g_x = 0;
		rect->g_y = 0;
		rect->g_w = 0;
		rect->g_h = 0;
	}

	return found;
}


/*
 * Check whose is inside the rect and select the object
 */
/* 306de: 00e26ab6 */
VOID chk_rect(P(DESKWIN *) win, P(GRECT *) rect, P(int16_t) id)
PP(register DESKWIN *win;)
PP(GRECT *rect;)
PP(int16_t id;)
{
	register OBJECT *obj;
	register int16_t i;
	int unused;
	register int16_t minx, miny, maxx, maxy;
	int16_t orgx, orgy, select;
	GRECT pt;
	int16_t doit;

	UNUSED(unused);
	if (win)
	{
		rc_intersect(&win->w_work, rect);
		doit = TRUE;
	} else
	{
		obj = background;
		doit = FALSE;
	}

	orgx = obj[0].ob_x;
	orgy = obj[0].ob_y;
	select = FALSE;

	minx = orgx + obj[0].ob_width;
	miny = orgy + obj[0].ob_height;
	maxx = 0;
	maxy = 0;

	for (i = 1; i <= obj[0].ob_tail; i++)
	{
		if (obj[i].ob_flags != HIDETREE)
		{
			rc_copy((GRECT *)&obj[i].ob_x, &pt);
			pt.g_x += orgx;
			pt.g_y += orgy;
			if (rc_intersect(rect, &pt))
			{
				if (minx > obj[i].ob_x)
					minx = obj[i].ob_x;

				if (miny > obj[i].ob_y)
					miny = obj[i].ob_y;

				if (obj[i].ob_x > maxx)
					maxx = obj[i].ob_x;

				if (obj[i].ob_y > maxy)
					maxy = obj[i].ob_y;

				obj[i].ob_state = SELECTED;
				select = TRUE;
				if (doit)
					get_dir(win, i)->d_state = SELECTED;
			}
		}
	}

	if (select)
	{
		pt.g_w = maxx - minx + obj[1].ob_width;
		pt.g_h = maxy - miny + obj[1].ob_height;
		pt.g_x = minx + obj[0].ob_x;
		pt.g_y = miny + obj[0].ob_y;
		do_redraw(id, &pt, 0);
	}
}


/*
 * Draw a box
 */
/* 306de: 00e26c7e */
VOID frame(P(int16_t) x1, P(int16_t) y1, P(int16_t) x2, P(int16_t) y2)
PP(int16_t x1;)
PP(int16_t y1;)
PP(int16_t x2;)
PP(int16_t y2;)
{
	int16_t points[10];

	mice_state(M_OFF);
	points[0] = points[6] = points[8] = x1;
	points[1] = points[3] = points[9] = y1;
	points[2] = points[4] = x2;
	points[5] = points[7] = y2;
	gsx_attr(FALSE, MD_XOR, BLACK);
	gsx_xline(5, points);
	mice_state(M_ON);
}


/*
 * Draw a box and wait for button to go up
 */
/* 306de: 00e26cf8 */
VOID r_box(P(int16_t) id, P(DESKWIN *) win)
PP(int16_t id;)
PP(DESKWIN *win;)
{
	register int16_t tmpx, tmpy;
	register int16_t tmpx1, tmpy1;
	int16_t gr_mkmx, gr_mkmy;
	int16_t gr_mkmstate, gr_mkkstate;
	GRECT rect;

	graf_mkstate(&gr_mkmx, &gr_mkmy, &gr_mkmstate, &gr_mkkstate);

	if (!(0x01 & gr_mkmstate))
		return;

	mice_state(POINT_HAND);

	rect.g_x = thedesk->full.g_x;
	rect.g_y = thedesk->full.g_y;
	rect.g_w = thedesk->full.g_x + thedesk->full.g_w; /* BUG: should be -1 for dvs_clip */
	rect.g_h = thedesk->full.g_y + thedesk->full.g_h; /* BUG: should be -1 for dvs_clip */

	dvs_clip(1, &rect.g_x);

	wind_update(TRUE);

#if !BINEXACT
	tmpx = tmpy = tmpx1 = tmpy1 = 0; /* quiet compiler */
#endif
	while (TRUE)
	{
		if (0x0001 & gr_mkmstate)
		{
			tmpy = tmpy1 = gr_mkmy;
			tmpx = tmpx1 = gr_mkmx;
			frame(tmpx, tmpy, tmpx1, tmpy1);

			while (0x01 & gr_mkmstate)
			{
				if ((tmpx1 != gr_mkmx || tmpy1 != gr_mkmy) && (0x0001 & gr_mkmstate))
				{
					frame(tmpx, tmpy, tmpx1, tmpy1);
					frame(tmpx, tmpy, gr_mkmx, gr_mkmy);
					tmpy1 = gr_mkmy;
					tmpx1 = gr_mkmx;
				}

				graf_mkstate(&gr_mkmx, &gr_mkmy, &gr_mkmstate, &gr_mkkstate);
			}

			frame(tmpx, tmpy, tmpx1, tmpy1);
		}
		break;
	}

	rect.g_x = min(tmpx, tmpx1);
	rect.g_y = min(tmpy, tmpy1);

	rect.g_w = dist(tmpx, tmpx1);
	rect.g_h = dist(tmpy, tmpy1);

	if (rect.g_w && rect.g_h)
		chk_rect(win, &rect, id);

	wind_update(FALSE);
	mice_state(ARROW);
	return;
}


/*
 * Return an absolute value
 */
/* 306de: 00e26e90 */
int16_t dist(P(int16_t) x, P(int16_t) y)
PP(int16_t x;)
PP(int16_t y;)
{
	if (x > y)
		return x - y;
	else
		return y - x;
}


/*
 * Move icons from desktop to desktop
 */
/* 306de: 00e2711c */
VOID desk_desk(P(int16_t) sitem, P(int16_t) ditem, P(int16_t) mx, P(int16_t) my)
PP(int16_t sitem;)
PP(int16_t ditem;)
PP(int16_t mx;)
PP(int16_t my;)
{
	register OBJECT *obj;
	char buffer[NAMELEN];
	register char temp1;
	char temp2;
	GRECT rect;
	long unused1;
	int16_t sitems;
	long unused2;
	const char *tail;

	UNUSED(unused1);
	UNUSED(unused2);
	
	obj = background;

	if (!ditem)							/* on the background    */
	{
		if (mx || my)					/* moved        */
		{
			sitems = 1;
			while (i_next(sitems, obj, &sitems))
			{							/* copy x,y,w,h     */
				rect.g_x = obj[0].ob_x + obj[sitems].ob_x;
				rect.g_y = obj[0].ob_y + obj[sitems].ob_y;
				app_mtoi(rect.g_x + mx, rect.g_y + my, &obj[sitems].ob_x, &obj[sitems].ob_y);
				do_redraw(0, &rect, 0);	/* erase old one    */
				do_redraw(0, &thedesk->full, sitems);	/* draw the new one */
				sitems++;
			}
		}
	} else
	{									/* check for floppy disk copy   */
		/* 7/11/92          */
		temp1 = ((CICONBLK *) (obj[sitem].ob_spec))->monoblk.ib_char;
		temp2 = ((CICONBLK *) (obj[ditem].ob_spec))->monoblk.ib_char;

		if (backid[sitem].i_type == DISK && backid[ditem].i_type == DISK)
		{
			if (temp1 == temp2)
			{
				return;
			} else if ((temp1 == 'A' || temp1 == 'B') && (temp2 == 'A' || temp2 == 'B'))
			{
				buffer[0] = temp1;
				fc_start(buffer, CMD_COPY);
				return;
			}
		}

		tail = Nostr;
		
		to_desk(ditem, tail);
	}
}


/*
 * Ghost icon initalization
 */
/* 306de: 00e2731a */
BOOLEAN gh_init(P(OBJECT *)obj, P(BOOLEAN) disk)
PP(register OBJECT *obj;)
PP(BOOLEAN disk;)
{
	register int16_t *ptr1;
	int16_t x, y, i, offx, offy;
	int32_t limit, j;
	int16_t count, lines;
	int16_t *ptr;
	OBJECT *tree;

	if (!(gh_buffer = Malloc(0xFFFFFFFFL)))
		return FALSE;

	gh_buffer = Malloc(gh_buffer);

	j = gh_buffer / 40;					/* 9 vertices x 2 x 2   */
	/* + 1 ascushion    */
	limit = (uint16_t) obj->ob_tail;

	if (limit > j)
		limit = j;

	offx = obj->ob_x;
	offy = obj->ob_y;

	ptr1 = (int16_t *)gh_buffer;
	ptr1++;								/* leave space to save the count    */

	tree = obj++;
	lines = disk ? 9 : 5;

	for (count = 0, j = 0; j < limit; j++, obj++)
	{
		if (obj->ob_state & SELECTED)
		{								/* if inside parent */
			if (in_parent(tree, (int16_t) j + 1))
			{
				ptr = disk ? d_xywh : f_xywh;
				x = obj->ob_x;
				y = obj->ob_y;

				for (i = 0; i < lines; i++)
				{
					*ptr1++ = *ptr++ + x + offx;
					*ptr1++ = *ptr++ + y + offy;
				}

				count++;
			}
		}
	}

	ptr1 = (int16_t *)gh_buffer;
	*ptr1 = count;
	return TRUE;
}


/*
 * Draw icons outline
 */
/* 306de: 00e2747c */
VOID ghost_icon(P(int16_t) offx, P(int16_t) offy, P(BOOLEAN) disk)
PP(register int16_t offx;)
PP(register int16_t offy;)
PP(BOOLEAN disk;)
{
	register int16_t *ptr;
	register int16_t i, j, limit;
	int16_t lines;
	int16_t buffer[4];
	int16_t *start;

	mice_state(M_OFF);

	rc_copy(&thedesk->full, (GRECT *)buffer);				/* set clipping rectangle   */
	buffer[2] = buffer[0] + buffer[2];
	buffer[3] = buffer[1] + buffer[3];
	dvs_clip(1, buffer);

	gsx_attr(FALSE, MD_XOR, BLACK);

	ptr = (int16_t *)gh_buffer;
	limit = *ptr++;

	lines = disk ? 9 : 5;

	for (j = 0; j < limit; j++)
	{
		start = ptr;

		for (i = 0; i < lines; i++)
		{
			*ptr++ += offx;
			*ptr++ += offy;
		}

		gsx_xline(lines, start);
	}

	mice_state(M_ON);
}


/*
 * Handle the holding down button event
 */
/* 306de: 00e27544 */
VOID hd_down(P(int16_t) sitem, P(int16_t) stype, P(DESKWIN *)swin)
PP(register int16_t sitem;)
PP(register int16_t stype;)
PP(register DESKWIN *swin;)
{
	register int16_t pitem, state;
	BOOLEAN itype;
	int16_t w, h, ret;
	BOOLEAN exec;
	int16_t mx, my, kstate, mstate;
	int16_t omx, omy;
	int16_t ditem, dtype;
	int16_t ptype, pid;
	BOOLEAN docopy;
	int16_t cx, cy, offx, offy, o1, o2;
	DESKWIN *dwin;
	DESKWIN *pwin;
	register OBJECT *pobj;
	register OBJECT *sobj;
	GRECT pt;
	GRECT pt2;

	graf_mkstate(&omx, &omy, &mstate, &kstate);

	if (!i_find(omx, omy, &pwin, &ret, &ptype))
		return;
	/* if no button or no object    */
	if (!(mstate & 0x01) || !sitem)
		return;

	itype = TRUE;
	w = d_xywh[6];
	h = d_xywh[9];

	if (stype == DESKICON)				/* source is desktop    */
	{
		sobj = background;
	} else								/* source is window */
	{
		if (thedesk->s_view != S_ICON)
		{
			itype = FALSE;
			w = f_xywh[2];
			h = f_xywh[5];
		}
	}
	/* if no object selected  */
	if (!(sobj[sitem].ob_state & SELECTED))
	{
		while (TRUE)					/* wait until button comes up   */
		{
			graf_mkstate(&omx, &omy, &mstate, &kstate);
			if (!(mstate & 0x01))
				break;
		}
		return;
	}

	if (!gh_init(sobj, itype))
	{
		do1_alert(FCNOMEM);
		return;
	}

	mice_state(FLAT_HAND);

	ghost_icon(0, 0, itype);			/* draw icon            */
	/* draw the biggest rectangle   */
	build_rect(sobj, &pt, w, h);
	rc_copy(&pt, &pt2);

	state = SELECTED;
	i_find(omx, omy, &pwin, &ret, &ptype);
	pitem = ret;
	pid = ptype == DESKICON ? 0 : pwin->w_id;

	ret = FALSE;						/* not into the loop yet    */
	cx = omx;
	cy = omy;

#if !BINEXACT
	docopy = exec = FALSE; /* quiet compiler */
#endif
	do
	{
		graf_mkstate(&mx, &my, &mstate, &kstate);

		if (!(mstate & 0x01))			/* no button down   */
			break;

		if (dist(mx, omx) > 2 || dist(my, omy) > 2)
		{
			o1 = pt.g_x;					/* save the old rectangle x,y   */
			o2 = pt.g_y;

			pt.g_x = o1 + mx - omx;		/* update the new x.y   */
			pt.g_y = o2 + my - omy;

			rc_constrain(&thedesk->full, &pt);	/* check how far it can move    */

			offx = pt.g_x - o1;			/* movement distance    */
			offy = pt.g_y - o2;

			if (offx)					/* movement */
			{
				if (offx < 0)			/* move left    */
				{
					if (cx < mx)
						goto h_3;
				} else					/* move right   */
				{
					if (mx < cx)
					{
					h_3:
						pt.g_x -= offx;
						offx = 0;
					}
				}
			}

			cx += offx;					/* outline box x,y  */

			if (offy)					/* movement */
			{
				if (offy < 0)			/* move left    */
				{
					if (cy < my)
						goto h_4;
				} else					/* move right   */
				{
					if (my < cy)
					{
					h_4:
						pt.g_y -= offy;
						offy = 0;
					}
				}
			}

			cy += offy;

			ghost_icon(0, 0, itype);
			/* Look for object  */
			exec = ch_obj(mx, my, &dwin, &ditem, &dtype);

			ret = TRUE;					/* pass the loop    */

			if (pwin != dwin || pitem != ditem || ptype != dtype)
			{
				if (pitem)				/* restore the previous item    */
				{
					if (pobj[pitem].ob_state != state)
					{
						pobj[pitem].ob_state = state;
						do_redraw(pid, &thedesk->full, pitem);
					}
				}

				if (dtype == DESKICON)
				{
					pid = 0;
					pobj = background;
				} else
				{
					pid = dwin->w_id;
				}

				state = pobj[ditem].ob_state;
				docopy = (state & SELECTED) ? FALSE : TRUE;

				if (ditem && exec)		/* set the new item */
				{
					if (!(pobj[ditem].ob_state & SELECTED))
					{
						pobj[ditem].ob_state |= SELECTED;
						do_redraw(pid, &thedesk->full, ditem);
					}
				}

				pwin = dwin;
				pitem = ditem;
				ptype = dtype;
			}
			
			ghost_icon(offx, offy, itype);	/* draw icon    */
			omx = mx;
			omy = my;
		}
	} while (TRUE);

	ghost_icon(0, 0, itype);			/* erase ghost icon */

	Mfree(gh_buffer);

	mice_state(ARROW);

	if (!ret)
		return;

	if (pitem)							/* restore destination object's state */
	{
		pobj[pitem].ob_state = state;
		do_redraw(pid, &thedesk->full, pitem);
	}

	menu_verify();
	/* fall back on its own icon    */
	if (stype == dtype && sitem == ditem)
	{
		if (dtype == WINICON)
		{
			if (swin == dwin)
				goto h_2;
		} else
			goto h_2;
	}

	if (stype == WINICON)				/* source is window */
	{
		if (dtype == DESKICON)			/* Hit the desktop  */
		{
			if (!ditem || exec)
			{
				/* win_desk(swin, sitem, ditem, pt.g_x - pt2.g_x, pt.g_y - pt2.g_y); */
			}
		} else
		{
			if (!exec)					/* if no executable the assume  */
				ditem = 0;				/* it want to copy      */
			to_win(sitem, swin, ditem, dwin);
		}
	} else								/* source is desktop    */
	{
		if (dtype == DESKICON)			/* hit the desktop  */
		{
			if (!docopy)				/* treat everything as a move function */
				ditem = 0;

			if (!ditem || exec)
				desk_desk(sitem, ditem, pt.g_x - pt2.g_x, pt.g_y - pt2.g_y);
		} else							/* hit the window   */
		{
			if (!exec)
				ditem = 0;
			to_win(sitem, (DESKWIN *) 0, ditem, dwin);
		}
	}

  h_2:
	return;
}


/*
 * Take action when something is dragged to desktop area
 */
/* 306de: 00e27ae2 */
VOID to_desk(P(int16_t) ditem, P(const char *)tail)
PP(int16_t ditem;)
PP(const char *tail;)
{
	char buffer[NAMELEN];
	int16_t ret;
	register IDTYPE *itype;

	UNUSED(ret);
	itype = &backid[ditem];

	switch (itype->i_type)
	{
	case DISK:							/* copy to disk     */
		strcpy(buffer, wildext);
		buffer[0] = itype->i_iblk.ib_char;
		file_op(buffer, OP_COPY);
		break;

	case TRASHCAN:
		/* do_file(DELMENU); */
		break;

	default:
		break;
	}
}


/*
 * Take action when something is dragged to window
 */
/* 306de: 00e27b98 */
VOID to_win(P(int16_t) sitem, P(DESKWIN *)swin, P(int16_t) ditem, P(DESKWIN *)dwin)
PP(int16_t sitem;)
PP(DESKWIN *swin;)
PP(int16_t ditem;)
PP(DESKWIN *dwin;)
{
	register DIR *dir;
	register char *temp;

	temp = path3;
	strcpy(temp, dwin->w_path);

	if (ditem)							/* copy to something    */
	{
		dir = get_dir(dwin, ditem);
		if (dir->d_att & FA_DIREC)		/* win file to folder   */
		{
			cat_path(dir->d_name, temp);
		} else							/* launch application   */
		{
			if (swin)					/* window to window */
			{
				dir = get_dir(swin, sitem);
				strcpy(&temp[1], swin->w_path);
				rep_path(dir->d_name, &temp[1]);
				temp[0] = strlen(&temp[1]);
				open_file(dwin, ditem, temp);
			} else						/* desktop to window    */
			{
				if (ch_tail(backid[sitem].i_path, path2))
					open_file(dwin, ditem, path2);
			}
			return;
		}
	}
	/* copy to the window   */
	rep_path(getall, temp);
	file_op(temp, OP_COPY);
}


/*
 * make a desktop icon
 */
/* 306de: 00e27cda */
int16_t make_icon(P(int16_t) drive, P(int16_t) icon, P(int16_t) type, P(const char *)text)
PP(int16_t drive;)
PP(int16_t icon;)
PP(int16_t type;)
PP(const char *text;)
{
	register int16_t id;
	register IDTYPE *itype;
	OBJECT *obj;

	if ((id = av_icon()) != -1)
	{
		itype = &backid[id];
		obj = background;
		cp_iblk(get_icon(icon), (ICONBLK *) (obj[id].ob_spec));
		/* $00E2D47E */
		itype->i_type = type;
		itype->i_iblk.ib_char = (char) drive;
		itype->i_icon = icon;
		strcpy(((CICONBLK *) (obj[id].ob_spec))->monoblk.ib_ptext, text);
	}

	return id;
}
