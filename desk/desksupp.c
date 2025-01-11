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
	register THEDSK *d;
	
	d = thedesk;
	/* change to directory that application is in */
	if (drv)
	{
		dos_sdrv(drv - 'A');
		d->g_srcpth[0] = drv;
		d->g_srcpth[1] = ':';
		d->g_srcpth[2] = '\\';
		strcpy(d->g_srcpth + 3, path);
		dos_chdir(ADDR(&d->g_srcpth[0]));
	}
	return TRUE;
}


BOOLEAN pro_cmd(P(char *) psubcmd, P(char *) psubtail, P(BOOLEAN) exitflag, P(int16_t) taillen)
PP(char *psubcmd;)
PP(char *psubtail;)
PP(BOOLEAN exitflag;)
PP(int16_t taillen;)
{
	register THEDSK *d;
	
	UNUSED(exitflag);
	d = thedesk;
	strcpy(d->g_cmd, psubcmd);
	strcpy(&d->g_tail[1], psubtail);
	d->g_tail[0] = taillen;
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
	ret = pro_exec(isgraf, iscr, d->g_pcmd, d->g_ptail);
	d->g_tail[0] = '\0';
	if (wh != -1)
	{
		do_wopen(FALSE, wh, curr, d->g_desk.g_x, d->g_desk.g_y, d->g_desk.g_w, d->g_desk.g_h);
	}
	return ret;
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


#if TOSVERSION < 0x106
#include "desksup3.c"
#endif
