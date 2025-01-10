/*      DESKPREF.C              3/17/89 - 6/15/89       Derek Mui       */
/*      Change at set color and pattern 6/29/90         D.Mui           */
/*      Use m_st to determine the resolution    9/19/90 D.Mui           */
/*      Fixed at col_par_pref for window background 7/7/92      D.Mui   */

/************************************************************************/
/*      New Desktop for Atari ST/TT Computer                            */
/*      Atari Corp                                                      */
/*      Copyright 1989,1990     All Rights Reserved                     */
/************************************************************************/


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

	UNUSED(dummy);
	d = thedesk;
	tree = (LPTREE)d->g_atree[ADSETPREF];
	
	cyes = d->g_cdelepref;
	LWSET(OB_STATE(SPCDYES), cyes);
	LWSET(OB_STATE(SPCDNO), !cyes);

#if TOSVERSION >= 0x104
	cyes = d->g_covwrpref;
	LWSET(OB_STATE(YWRITE), !cyes);
	LWSET(OB_STATE(NWRITE), cyes);
#endif

	cyes = d->g_ccopypref;
	LWSET(OB_STATE(SPCCYES), cyes);
	LWSET(OB_STATE(SPCCNO), !cyes);
	
#if (TOSVERSION >= 0x162)
	for (i = SPLOW; i <= SPHIGH; i++)	/* hopefully they are in order  */
		LWSET(OB_STATE(i), NORMAL);
	switch (gl_restype)
	{
	case 1:
		flag = SPLOW;
		goto disable_high;
	case 2:
		flag = SPMEDIUM;
	disable_high:
		LWSET(OB_STATE(SPHIGH), DISABLED);
		break;
	case 3:
		flag = SPHIGH;
		LWSET(OB_STATE(SPLOW), DISABLED);
		LWSET(OB_STATE(SPMEDIUM), DISABLED);
		break;
#ifdef __GNUC__
	default:
		__builtin_unreachable();
		break;
#endif
	}
	LWSET(OB_STATE(flag), SELECTED);
#else
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
#endif

	if (xform_do((OBJECT *)tree, ROOT) == SPOK)
	{
		d->g_cdelepref = inf_what((OBJECT *)tree, SPCDYES, SPCDNO);
		d->g_ccopypref = inf_what((OBJECT *)tree, SPCCYES, SPCCNO);
#if TOSVERSION >= 0x104
		d->g_covwrpref = !inf_what((OBJECT *)tree, YWRITE, NWRITE);
#endif

#if (TOSVERSION >= 0x162)
		flag = inf_gindex(tree, SPLOW, 3) + 1;
#else
		flag = inf_gindex(tree, SPLOW, 3) + 2;
#endif
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
