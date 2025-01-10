/*      DESKSUPP.C      05/04/84 - 06/20/85     Lee Lorenzen            */
/*      for 3.0 (xm)    3/12/86  - 01/17/87     MDF                     */
/*      for 3.0                 11/13/87                mdf             */

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
#include "gsxdefs.h"
#include "toserrno.h"

/* 104de: 00fd9fde */
/* 106de: 00e1ae8e */
BOOLEAN pro_chdir(P(int) drv, P(const char *) path)
PP(int drv;)
PP(const char *path;)
{
	register char *ptr;
	register int i;

	ptr = g_buffer;
	if (drv == CHAR_FOR_CARTRIDGE)
	{
		DOS_ERR = 0;
		return TRUE;
	}
	/* change to directory that application is in */
	if (drv != 0)
	{
		ptr[256] = '\\';
		strcpy(ptr + 257, path);
		for (i = 1; ptr[i + 256] != '\0'; )
		{
			if (ptr[i + 256] == ' ' || ptr[i + 256] == '*')
			{
				ptr[i + 256] = '\0';
				break;
			} else
			{
				i++;
			}
		}
		do_cdir(drv - 'A', ptr + 256);
	}
	return TRUE;
	
}


int16_t pro_exec(P(int16_t) isgraf, P(int16_t) isover, P(char *) pcmd, P(char *) ptail)
PP(int16_t isgraf;)
PP(int16_t isover;)
PP(char *pcmd;)
PP(char *ptail;)
{
	int16_t ret;

	graf_mouse(HOURGLASS, NULL);

	ret = shel_write(TRUE, isgraf, isover, pcmd, ptail);
	return ret;
}


/* 104de: 00fda066 */
/* 106de: 00e1af28 */
int pro_run(P(int16_t) isgraf, P(int16_t) iscr, P(int16_t) wh, P(int16_t) curr)
PP(int16_t isgraf;)
PP(int16_t iscr;)
PP(int16_t wh;)
PP(int16_t curr;)
{
	register THEDSK *d;
	int ret;
	int len;

	d = thedesk;
	if (d->g_tail[0] == 0)
	{
		d->g_tail[0] = len = (int)strlen(d->g_tail + 1);
		d->g_tail[len + 1] = '\r';
	}
	desk_wait(TRUE);
	ret = shel_write(TRUE, isgraf, iscr, d->g_pcmd, d->g_ptail);
	d->g_tail[0] = '\0';
	if (wh != -1)
	{
		do_wopen(FALSE, wh, curr, d->g_desk.g_x, d->g_desk.g_y, d->g_desk.g_w, d->g_desk.g_h);
	}
	return ret;
}


/*
 *	Clear out the selections for this particular window
 */
/* 104de: 00fda0e0 */
/* 106de: 00e1afba */
VOID desk_clear(P(int16_t) wh)
PP(register int16_t wh;)
{
	register DESKWIN *pw;
	GRECT c;
	register int16_t root;

	/* get current size */
	wind_get(wh, WF_WORKXYWH, &c.g_x, &c.g_y, &c.g_w, &c.g_h);
	/* find its tree of items */
	if (wh != 0)
	{
		pw = win_find(wh);
		root = pw->w_root;
	} else
	{
		root = DROOT;
	}
	/* clear all selections */
	act_allchg(wh, thedesk->g_pscreen, root, 0, &gl_rfull, &c, SELECTED, FALSE, TRUE, TRUE);
}


#if TOSVERSION < 0x106
#include "desksup3.c"
#endif
