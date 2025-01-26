/*   DESKAPP.C  06/11/84 - 07/11/85     Lee Lorenzen    */
/*  for 3.0     3/6/86   - 5/6/86       MDF     */
/*  for 2.3     9/25/87             mdf     */

/*
 *       Copyright 1999, Caldera Thin Clients, Inc.                      
 *       This software is licenced under the GNU Public License.         
 *       Please see LICENSE.TXT for further information.                 
 *                                                                       
 *                  Historical Copyright                                 
 *   -------------------------------------------------------------
 *   GEM Desktop                   Version 2.3
 *   Serial No.  XXXX-0000-654321          All Rights Reserved
 *   Copyright (C) 1987          Digital Research Inc.
 *   -------------------------------------------------------------
 */

#include "desktop.h"


/*
 *	Build the desktop list of objects based on this current 
 *	application list.
 */
/* 104de: 00fd59a0 */
/* 106de: 00e15f0c */
VOID app_blddesk(NOTHING)
{
	register int16_t obid;
	uint16_t bvdisk;
	uint16_t bvhard;
	int16_t bvect;
	register APP *pa;
	register THEDSK *d;
#if TOSVERSION >= 0x104
	int rez;
	int unused;

	UNUSED(unused);
#endif
	
	d = thedesk;
	/* kids and set size */
	obj_wfree(DROOT, 0, 0, gl_width, gl_height);

	/* see also sh_main in AES */
#if TOSVERSION >= 0x104
	rez = Getrez();
	d->g_screen[DROOT].ob_spec = rez == 2 || rez == 4 ? 0x00001143L : 0x00001173L;
#else
	d->g_screen[DROOT].ob_spec = Getrez() != 2 ? 0x00001173L : 0x00001143L;
#endif

	bvdisk = bvhard = 0;

	for (pa = d->applist; pa; pa = pa->a_next)
	{
		if (pa->a_apptype & AF_ISDESK)
		{
			obid = obj_ialloc(DROOT, pa->a_x, pa->a_y, d->g_wicon, d->g_hicon);
			if (!obid)
				/* error case, no more obs */
				/* break */
				;
			/* set up disk vector   */
			if (pa->a_type == AT_ISDISK)
			{
				bvect = (uint16_t)0x8000 >> (pa->a_char - 'A');
				bvdisk |= bvect;
			}
			/* remember it */
			pa->a_obid = obid;
			/* build object */
			d->g_screen[obid].ob_state = NORMAL;
			d->g_screen[obid].ob_flags = NONE;
			d->g_screen[obid].ob_type = G_ICON;
			d->g_index[obid] = pa->a_aicon;
			d->g_screen[obid].ob_spec = (intptr_t)&d->gl_icons[obid];
			movs(sizeof(ICONBLK), &d->g_iblist[pa->a_aicon], &d->gl_icons[obid]);
			d->gl_icons[obid].ib_xicon = ((d->g_wicon - d->gl_icons[obid].ib_wicon) / 2);
			d->gl_icons[obid].ib_ptext = pa->a_pappl;
			d->gl_icons[obid].ib_char |= (0x00ff & pa->a_char);
		}
	}

	ap_bvset(bvdisk, bvhard);
}


/*
 *	Find the ANODE that is appropriate for this object.
 */
/* 104de: 00fd5b36 */
/* 106de: 00e160be */
APP *app_afind(P(BOOLEAN) isdesk, P(int16_t) atype, P(int16_t) obid, P(char *)pname, P(BOOLEAN *)pisapp)
PP(register BOOLEAN isdesk;)
PP(register int16_t atype;)
PP(register int16_t obid;)
PP(register char *pname;)
PP(register BOOLEAN *pisapp;)
{
	register APP *pa;
	for (pa = thedesk->applist; pa; pa = pa->a_next)
	{
		if (isdesk)
		{
			if (pa->a_obid == obid)
				return pa;
		} else
		{
			if (pa->a_type == atype && !(pa->a_apptype & AF_ISDESK))
			{
				if (wildcmp(pa->a_pdata, pname))
				{
					*pisapp = FALSE;
					return pa;
				}
				if (wildcmp(pa->a_pappl, pname))
				{
					*pisapp = TRUE;
					return pa;
				}
			}
		}
	}
	return NULL;
}
