/*      DESKBIND.C              6/16/89 - 9/14/89       Derek Mui       */

/************************************************************************/
/*      New Desktop for Atari ST/TT Computer                            */
/*      Atari Corp                                                      */
/*      Copyright 1989,1990     All Rights Reserved                     */
/************************************************************************/


#include "desktop.h"
#include "aesbind.h"




/* 306de: 00e28052 */
VOID wind_new(NOTHING)
{
	wm_new();
	dsptch();
}


/* 306de: 00e28066 */
int16_t fsel_exinput(P(char *)path, P(char *)selec, P(int16_t *)button, P(const char *)label)
PP(char *path;)
PP(char *selec;)
PP(int16_t *button;)
PP(const char *label;)
{
	int16_t ret;

	ret = fs_input(path, selec, button, label);
	dsptch();
	return ret;
}


/* 306de: 00e28098 */
int16_t rsrc_load(P(const char *) name)
PP(const char *name;)
{
	int16_t ret;

	ret = rs_load((intptr_t) pglobal, name);
	dsptch();
	return ret;
}


/*
 * show cursor
 */
/* 306de: 00e280de */
VOID dv_show_c(P(BOOLEAN) reset)
PP(int16_t reset;)
{
	intin[0] = reset;
	gsx_ncode(122, 0, 1);
}


/*
 * hide cursor
 */
/* 306de: 00e28100 */
VOID dv_hide_c(NOTHING)
{
	gsx_ncode(123, 0, 0);
}


/*
 * enter graphic mode
 */
/* 306de: 00e28118 */
VOID dv_exit_cur(NOTHING)
{
	contrl[5] = 2;
	gsx_ncode(5, 0, 0);
}


/*
 * enter alpha mode
 */
/* 306de: 00e28138 */
VOID dv_enter_cur(NOTHING)
{
	contrl[5] = 3;
	gsx_ncode(5, 0, 0);
}


/*
 * clipping function
 */
/* 306de: 00e28158 */
VOID dvs_clip(P(BOOLEAN) clip_flag, P(const int16_t *) pxy)
PP(BOOLEAN clip_flag;)
PP(int16_t *pxy;)
{
	intin[0] = clip_flag;
	ptsin[0] = pxy[0];
	ptsin[1] = pxy[1];
	ptsin[2] = pxy[2];
	ptsin[3] = pxy[3];
	gsx_ncode(129, 2, 1);
}
