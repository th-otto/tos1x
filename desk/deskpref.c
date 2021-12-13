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
#include "taddr.h"

#undef Dfree
#define Dfree(a,b)      trap(0x36,a,b)


/*
 *	Set preferences dialog.
 */
/* 306de: 00e316e8 */
/* 104de: 00fd8622 */
/* 106de: 00e19162 */
BOOLEAN desk_pref(NOTHING)
{
	register THEDSK *d;
	register LPTREE tree;
	register int16_t cyes;
	register int i;
	register short flag;
	short dummy;

	d = thedesk;
	tree = d->g_atree[ADSETPREF];
	
	cyes = d->g_cdelepref;
	LWSET(OB_STATE(SPCDYES), cyes);
	LWSET(OB_STATE(SPCDNO), !cyes);

	cyes = d->g_covwrpref;
	LWSET(OB_STATE(YWRITE), !cyes);
	LWSET(OB_STATE(NWRITE), cyes);

	cyes = d->g_ccopypref;
	LWSET(OB_STATE(SPCCYES), cyes);
	LWSET(OB_STATE(SPCCNO), !cyes);
	
	for (i = 0; i < 3; i++)	/* hopefully they are in order  */
		LWSET(OB_STATE(i + SPLOW), NORMAL);
	flag = Getrez();
	if (flag != 2)
	{
		LWSET(OB_STATE(SPHIGH), DISABLED);
	} else
	{
		LWSET(OB_STATE(SPLOW), DISABLED);
		LWSET(OB_STATE(SPMEDIUM), DISABLED);
	}

	flag = gl_restype - 2;
	LWSET(OB_STATE(flag + SPLOW), SELECTED);

	if (xform_do(tree, ROOT) == SPOK)
	{
		d->g_cdelepref = inf_what(tree, SPCDYES, SPCDNO);
		d->g_ccopypref = inf_what(tree, SPCCYES, SPCCNO);
		d->g_covwrpref = !inf_what(tree, YWRITE, NWRITE);

		flag = inf_gindex(tree, SPLOW, 3) + 2;

		if (app_reschange(flag))
			return TRUE;
	}
	return FALSE;
}


/* 104de: 00fd8780 */
/* 106de: 00e192e2 */
int dos_space(P(int) drive, P(int32_t *) total, P(int32_t *) avail)
PP(int drive;)
PP(int32_t *total;)
PP(int32_t *avail;)
{
	int32_t lbuf[4];
	int32_t clsize;

	Dfree(lbuf, drive);
	clsize = lbuf[3] * lbuf[2];
	*total = clsize * lbuf[1];
	*avail = clsize * lbuf[0];
	return TRUE;
}
