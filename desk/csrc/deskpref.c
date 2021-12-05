/*      DESKPREF.C              3/17/89 - 6/15/89       Derek Mui       */
/*      Change at set color and pattern 6/29/90         D.Mui           */
/*      Use m_st to determine the resolution    9/19/90 D.Mui           */
/*      Fixed at col_par_pref for window background 7/7/92      D.Mui   */

/************************************************************************/
/*      New Desktop for Atari ST/TT Computer                            */
/*      Atari Corp                                                      */
/*      Copyright 1989,1990     All Rights Reserved                     */
/************************************************************************/

#include "desktop.h"


/*
 * Set preferences dialog
 */
/* 306de: 00e316e8 */
VOID desk_pref(NOTHING)
{
	register OBJECT *obj;
	register int16_t cyes, i, flag;
	int16_t overwrite, font;
	THEDSK *d;
	
	UNUSED(font);
	UNUSED(overwrite);
	
	d = thedesk;
	
	obj = d->rtree[ADSETPREF];
	cyes = thedesk->ddele_save;
	obj[SPCDYES].ob_state = cyes;
	obj[SPCDNO].ob_state = !cyes;

	cyes = thedesk->dwrite_save;
	obj[YWRITE].ob_state = !cyes;
	obj[NWRITE].ob_state = cyes;

	cyes = thedesk->ccopy_save;
	obj[SPCCYES].ob_state = cyes;
	obj[SPCCNO].ob_state = !cyes;

	for (i = SPLOW; i <= SPHIGH; i++)	/* hopefully they are in order  */
		obj[i].ob_state = NORMAL;

	/* set the resolution button */
	for (i = 0, flag = SPLOW; i < 6; i++, flag++)
	{
		if (!restable[i])
			obj[flag].ob_state = DISABLED;
	}

	/* gl_restype is set according to followings:
	                                vdi handle
	1 = LOW RES     320 x 200       0, 2, 5, 7
	2 = MEDIUM RES  640 x 200       3               
	3 = HIGH RES    640 x 400       4
	4 = EXT1        640 x 480       6
	5 = EXT2        1280 x 960      8
	6 = EXT3        320 x 480       9
	
	*/

	switch (gl_restype)
	{
	case 1:
		flag = SPLOW;
		break;

	case 2:
		flag = SPMEDIUM;
		break;

	case 3:
		flag = SPHIGH;
		break;
	}

	obj[flag].ob_state = SELECTED;

	if (fmdodraw(ADSETPREF, 0) == SPOK)
	{
		thedesk->cdele_save = inf_what(obj, SPCDYES, SPCDNO);
		thedesk->ccopy_save = inf_what(obj, SPCCYES, SPCCNO);
		thedesk->write_save = !inf_what(obj, YWRITE, NWRITE);

		flag = inf_gindex(obj, SPLOW, 6) + 1;

		if (app_reschange(flag))
			d_exit = L_CHGRES;
	}
}
