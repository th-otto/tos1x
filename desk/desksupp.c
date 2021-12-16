/*	DESKSUPP.C	05/04/84 - 06/20/85	Lee Lorenzen		*/
/*	for 3.0 (xm)	3/12/86	 - 01/17/87	MDF			*/
/*	for 3.0			11/13/87		mdf		*/

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


/* 104de: 00fd9fde */
/* 106de: 00e1ae8e */
BOOLEAN pro_chdir(P(int) drv, P(char *) path)
PP(int drv;)
PP(char *path;)
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
		do_wopen(FALSE, wh, curr, d->g_full.g_x, d->g_full.g_y, d->g_full.g_w, d->g_full.g_h);
	}
	return ret;
}


/*
 *	Clear out the selections for this particular window
 */


/* 104de: 00fda13c */
/* 106de: 00e1b02a */
VOID desk_verify PROTO((int16_t wh, int16_t changed));

