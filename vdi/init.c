/*
 ********************************  init.c  *************************************
 *
 * =============================================================================
 * $Author: lozben $	$Date: 91/07/30 15:52:15 $
 * =============================================================================
 *
 *******************************************************************************
 */
#include "vdi.h"
#include "fontdef.h"
#include "attrdef.h"
#include "scrndev.h"
#include "lineavar.h"
#include "gsxdef.h"
#include "gsxextrn.h"

#define	P_COOKIE    *(int32_t **) 0x5a0
#define _VDO	    0x5f56444fL /* '_VDO' */

#define STCOOKIE    0L
#define STECOOKIE   1L
#define TTCOOKIE    2L
#define SPCOOKIE    3L
#define SPSHIFTMODE	    (* ((int16_t *) 0xff8266))	/* sparrow shift mode */
#define PIXMASK		    0x200			/* pix control in XGA */
#define	SSHIFT		    * ((char *) 0x44cL)

#define GetRez()	vtrap14(4)
#define	EsetBank(a)	vtrap14(82, a)
#define	EsetGray(a)	vtrap14(86, a)
#define	SETRGB(a, b, c)	vtrap14(93, a, b, c)

/*----------------------------------------------------------------------------*/

#if TOSVERSION >= 0x400 /* whole file */

VOID init_st_tt_sp(NOTHING)
{
	register int32_t *cookiePtr, cookieVal;
#if VIDEL_SUPPORT
	register int32_t *palMapPtr, i;

	palMapPtr = LV(pal_map);
	for (i = 0; i < 256; i++)
		*palMapPtr++ = i;				/* mapping is one to one for pens */
#endif

	cookiePtr = P_COOKIE;

	if (cookiePtr == NULL)				/* no cookie jar (i.e> it's an ST */
	{
		InitST();
	} else
	{
		for (; *cookiePtr != 0L; cookiePtr += 2)
			if (*cookiePtr == _VDO)
				break;

		if (*cookiePtr == _VDO)
		{
			/*
			 * store in the lower wrd the val
			 */
			cookieVal = cookiePtr[1] >> 16;

			if (cookieVal == TTCOOKIE)
			{
				LV(LA_ROUTINES)[V_VQCOLOR] = tt_vq_color;
				LV(LA_ROUTINES)[V_VSCOLOR] = tt_vs_color;
				InitTT();
			} else if (cookieVal > TTCOOKIE && LV(LA_CURDEV)->palSize != 2)
			{
				LV(LA_ROUTINES)[V_VQCOLOR] = sp_vq_color;
				LV(LA_ROUTINES)[V_VSCOLOR] = sp_vs_color;
				InitSTSpLut();
				InitColReqArray();
			} else
			{
				InitST();
			}
		} else
		{
			InitST();
		}
	}
}

/*----------------------------------------------------------------------------*/

VOID InitST(NOTHING)
{
	register int16_t *sp, *dp, i;
	int16_t *old_intin, *old_intout, *old_contrl;
	int16_t new_contrl[7], new_intin[2], new_intout[4];

	InitSTSpLut();						/* initialize color lut       */

	if (GetRez() == _640x400)
	{
		LV(DEV_TAB)[35] = 0;				/* color capability           */
		LV(DEV_TAB)[39] = 2;				/* palette size               */
		LV(INQ_TAB)[1] = 1;					/* number of background clrs  */
		LV(INQ_TAB)[5] = 0;					/* video lookup table         */
	}

	/* set up the REQ_COL array */
	old_intin = LV(INTIN);
	old_intout = LV(INTOUT);
	old_contrl = LV(CONTRL);

	LV(CONTRL) = new_contrl;
	LV(INTIN) = new_intin;
	LV(INTOUT) = new_intout;

	new_intin[1] = 1;
	dp = &LV(REQ_COL)[0][0];
	sp = new_intout + 1;

	for (i = 0; i < LV(DEV_TAB)[13]; i++)
	{
		new_intin[0] = i;
		vq_color();
		*dp++ = *sp;
		*dp++ = *(sp + 1);
		*dp++ = *(sp + 2);
	}

	LV(CONTRL) = old_contrl;
	LV(INTIN) = old_intin;
	LV(INTOUT) = old_intout;
}

/*----------------------------------------------------------------------------*/

VOID InitTT(NOTHING)
{
	register int16_t *sp, *dp, i;
	register int j;
	register int temp;
	int16_t *old_intin, *old_intout, *old_contrl;
	int16_t new_contrl[7], new_intin[2], new_intout[4];

	EsetGray(0);						/* init to color mode         */
	EsetBank(0);						/* init to bank zero          */
	InitTTLut();						/* initialize color lut       */

	old_intin = LV(INTIN);
	old_intout = LV(INTOUT);
	old_contrl = LV(CONTRL);

	LV(CONTRL) = new_contrl;
	LV(INTIN) = new_intin;
	LV(INTOUT) = new_intout;
	temp = LV(DEV_TAB)[13];					/* temp <- #  pens available  */

	new_intin[1] = 1;
	dp = &LV(REQ_COL)[0][0];
	sp = new_intout + 1;

	/*
	 * Initialize the request color array, and the request extended
	 * color array. Do it for all banks if there are banks in the
	 * current video mode.
	 */
	switch ((int)GetRez())
	{
	case _320x200:						/* initialize the 2 color arrays to the */
	case _640x200:						/* values which are stored in the color */
	case _640x480:						/* lookup table for all 16 banks        */
		for (i = 0; i < 16; i++)
		{
			new_intin[0] = i;
			vq_color();
			*dp++ = sp[0];
			*dp++ = sp[1];
			*dp++ = sp[2];
		}

		dp = &LV(REQ_X_COL)[0][0];
		for (i = 1; i < 16; i++)
		{
			EsetBank(i);
			for (j = 0; j < 16; j++)
			{
				new_intin[0] = j;
				vq_color();
				*dp++ = sp[0];
				*dp++ = sp[1];
				*dp++ = sp[2];
			}
		}
		EsetBank(0);					/* restore to bank 0        */
		break;

	case _640x400:
	case _1280x960:
		for (i = 0; i < temp; i++)
		{
			new_intin[0] = i;
			vq_color();
			*dp++ = sp[0];
			*dp++ = sp[1];
			*dp++ = sp[2];
		}
		break;

	case _320x480:
		for (i = 0; i < 16; i++)
		{
			new_intin[0] = i;
			vq_color();
			*dp++ = sp[0];
			*dp++ = sp[1];
			*dp++ = sp[2];
		}

		/*
		 * we have > 16 cols so fill the extended color array
		 */
		dp = &LV(REQ_X_COL)[0][0];
		for (; i < temp; i++)
		{
			new_intin[0] = i;
			vq_color();
			*dp++ = sp[0];
			*dp++ = sp[1];
			*dp++ = sp[2];
		}
		break;
	}

	LV(CONTRL) = old_contrl;
	LV(INTIN) = old_intin;
	LV(INTOUT) = old_intout;
}

/*----------------------------------------------------------------------------*/

VOID InitSTSpLut(NOTHING)
{
	register int16_t count;

	count = (LV(LA_CURDEV)->maxPen > 16) ? 256 : 16;
	SETRGB(0, count, colors);

	if (LV(LA_CURDEV)->planes == 1)
		SETRGB(1, 1, colors + 15);
	else if (LV(LA_CURDEV)->planes == 2)
		SETRGB(3, 1, colors + 15);
}

/*----------------------------------------------------------------------------*/

#if VIDEL_SUPPORT
/*
 * Initialize the virtual pen values for the gsx mode.
 */
VOID Init16Pal(NOTHING)
{
	register int32_t R, G, B;
	register int16_t i, temp, *palMapPtr;
	register volatile int16_t *lutPtr;

	/*
	 * BUG: thats nonsense; pal_map has 32-bit entries
	 */
	palMapPtr = (int16_t *)LV(pal_map);
	for (i = 0; i < 256; i++)
	{
		R = G = B = colors[i];

		/*
		 * calculate the red component
		 */
		temp = R >> 16;
		R = (temp * 31) / 255;
		R <<= 11;

		/*
		 * calculate the green component
		 */
		temp = (G >> 8) & 0xff;

		if (SPSHIFTMODE & PIXMASK)
		{
			G = (temp * 63) / 255;		/* green gun has 6 bits   */
			G <<= 5;
		} else
		{
			G = (temp * 31) / 255;		/* green gun has 5 bits   */
			G <<= 6;
		}

		/*
		 * calculate the blue component
		 */
		temp = B & 0xff;
		B = (temp * 31) / 255;

		*palMapPtr++ = (int16_t) (R | G | B);
		*palMapPtr++ = (int16_t) (R | G | B);
	}
	InitColReqArray();
	lutPtr = (volatile int16_t *) 0xff9800;			/* point to color LUT     */

	/*
	 * make border white
	 */
	*lutPtr++ = 0xffff;
	*lutPtr = 0xffff;
}
#endif

/*----------------------------------------------------------------------------*/

#if VIDEL_SUPPORT
VOID Init32Pal(NOTHING)
{
	register int32_t R, G, B, *palMapPtr;
	register int16_t i, temp;
	
	/* BUG: R, G, B, temp were used uninitialized */
	R = G = B = temp = 0;
	palMapPtr = LV(pal_map);
	for (i = 0; i < 256; i++)
		*palMapPtr++ = R | G | B;

	InitColReqArray();
}
#endif

/*----------------------------------------------------------------------------*/

VOID InitColReqArray(NOTHING)
{
	register int16_t *sp, *dp, i;
#if VIDEL_SUPPORT
	register int16_t temp;
#endif
	int16_t *old_intin, *old_intout, *old_contrl;
	int16_t new_contrl[7], new_intin[2], new_intout[4];

	/* set up the REQ_COL array */
	old_intin = LV(INTIN);
	old_intout = LV(INTOUT);
	old_contrl = LV(CONTRL);

	LV(CONTRL) = new_contrl;
	LV(INTIN) = new_intin;
	LV(INTOUT) = new_intout;

	new_intin[1] = 1;
	dp = &LV(REQ_COL)[0][0];
	sp = new_intout + 1;

	for (i = 0; i < 16; i++)
	{
		new_intin[0] = i;
		vq_color();
		*dp++ = sp[0];
		*dp++ = sp[1];
		*dp++ = sp[2];
	}

#if VIDEL_SUPPORT
	dp = &LV(REQ_X_COL)[0][0];
	temp = LV(DEV_TAB)[13];					/* temp <- #  pens available  */
	for (; i < temp; i++)
	{
		new_intin[0] = i;
		vq_color();
		*dp++ = sp[0];
		*dp++ = sp[1];
		*dp++ = sp[2];
	}
#endif

	LV(CONTRL) = old_contrl;
	LV(INTIN) = old_intin;
	LV(INTOUT) = old_intout;
}

/*----------------------------------------------------------------------------*/

VOID InitTTLut(NOTHING)
{
	register int16_t i;
	register volatile int16_t *lutPtr;

	lutPtr = (volatile int16_t *) 0xff8400;			/* point to ste col lut     */

	for (i = 0; i < 256; i++)
		*lutPtr++ = colors[i];

	if (_640x200 == GetRez())
	{
		lutPtr = (volatile int16_t *) 0xff8400;		/* point to ste col lut     */
		lutPtr[3] = colors[15];			/* set foreground color     */
	}
}

#endif /* TOSVERSION >= 0x400 */
