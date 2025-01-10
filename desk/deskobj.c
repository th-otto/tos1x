/*      DESKOBJ.C       06/11/84 - 02/08/85             Lee Lorenzen    */
/*      merge source    5/27/87                         mdf             */

/*
 *       Copyright 1999, Caldera Thin Clients, Inc.                      
 *       This software is licenced under the GNU Public License.         
 *       Please see LICENSE.TXT for further information.                 
 *                                                                       
 *                  Historical Copyright                                 
 *       -------------------------------------------------------------
 *       GEM Desktop                                       Version 2.3
 *       Serial No.  XXXX-0000-654321              All Rights Reserved
 *       Copyright (C) 1985                      Digital Research Inc.
 *       -------------------------------------------------------------
 */

#include "desktop.h"


OBJECT const gl_sampob[2] = {
	{ NIL, NIL, NIL, G_IBOX, NONE, NORMAL, 0, 0, 0, 0, 0 },
	{ NIL, NIL, NIL, G_BOX, NONE, NORMAL, 0x00001100L, 0, 0, 0, 0 }
};


/*
 *	Initialize all objects as children of the 0th root which is
 *	the parent of unused objects.
 * (inlined obj_init)
 */
VOID obj_init(NOTHING)
{
	register THEDSK *d;
	register int i;
	OBJECT *tree;

	d = thedesk;
	tree = d->g_pscreen = d->g_screen;
	for (i = 0; i < NUM_SOBS; i++)
	{
		d->g_screen[i].ob_head = NIL;
		d->g_screen[i].ob_next = NIL;
		d->g_screen[i].ob_tail = NIL;
	}
	movs(sizeof(OBJECT), &gl_sampob[0], &d->g_screen[ROOT]);
	r_set((GRECT *) &d->g_screen[ROOT].ob_x, 0, 0, gl_width, gl_height);
	for (i = 0; i < (NUM_WNODES + NUM_ROBS - 1); i++)
	{
		movs(sizeof(OBJECT), &gl_sampob[1], &d->g_screen[i + DROOT]);
		objc_add(tree, ROOT, i + DROOT);
	}
}


/*
 *	Allocate a window object from the screen tree by looking for 
 *	the child of the parent with no size
 */
/* 104de: 00fd9e58 */
/* 106de: 00e1ace0 */
int16_t obj_walloc(P(int16_t) x, P(int16_t) y, P(int16_t) w, P(int16_t) h)
PP(int16_t x;)
PP(int16_t y;)
PP(int16_t w;)
PP(int16_t h;)
{
	register int ii;
	register THEDSK *d;
	
	d = thedesk;
	for (ii = NUM_ROBS - 1; ii < (NUM_WNODES + NUM_ROBS - 1); ii++)
	{
		if (d->g_screen[ii + 1].ob_width == 0 || d->g_screen[ii + 1].ob_height == 0)
			break;
	}
	if (ii < (NUM_WNODES + NUM_ROBS - 1))
	{
		r_set((GRECT *) &d->g_screen[ii + 1].ob_x, x, y, w, h);
		return ii + 1;
	} else
	{
		return 0;
	}
}


/*
 *	Free a window object by changing its size to zero and
 *	NILing out all its children.
 */
/* 104de: 00fd9eca */
/* 106de: 00e1ad5e */
VOID obj_wfree(P(int16_t) obj, P(int16_t) x, P(int16_t) y, P(int16_t) w, P(int16_t) h)
PP(int16_t obj;)
PP(int16_t x;)
PP(int16_t y;)
PP(int16_t w;)
PP(int16_t h;)
{
	register THEDSK *d;
	register int ii;
	register int16_t nxtob;

	d = thedesk;
	r_set((GRECT *) &d->g_screen[obj].ob_x, x, y, w, h);
	for (ii = d->g_screen[obj].ob_head; ii > obj; ii = nxtob)
	{
		nxtob = d->g_screen[ii].ob_next;
		d->g_screen[ii].ob_next = NIL;
	}
	d->g_screen[obj].ob_head = d->g_screen[obj].ob_tail = NIL;
}


/*
 *	Routine to find and allocate a particular item object.  The
 *	next free object is found by looking for any object that
 *	is available (i.e., a next pointer of NIL).
 */
/* 104de: 00fd9f56 */
/* 106de: 00e1adf6 */
int16_t obj_ialloc(P(int16_t) wparent, P(int16_t) x, P(int16_t) y, P(int16_t) w, P(int16_t) h)
PP(int16_t wparent;)
PP(int16_t x;)
PP(int16_t y;)
PP(int16_t w;)
PP(int16_t h;)
{
	register THEDSK *d;
	register int ii;

	d = thedesk;
	for (ii = NUM_WNODES + NUM_ROBS; ii < NUM_SOBS; ii++)
	{
		if (d->g_screen[ii].ob_next == NIL)
			break;
	}
	if (ii < NUM_SOBS)
	{
		d->g_screen[ii].ob_head = d->g_screen[ii].ob_tail = NIL;
		objc_add(d->g_pscreen, wparent, ii);
		r_set((GRECT *) &d->g_screen[ii].ob_x, x, y, w, h);
		return ii;
	} else
	{
		return 0;
	}
}
