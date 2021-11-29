/*
 ********************************** monobj.c ***********************************
 *
 * =============================================================================
 * $Author: lozben $	$Date: 91/01/03 15:12:41 $
 * =============================================================================
 *
 * Revision 3.0  91/01/03  15:12:41  lozben
 * New generation VDI
 * 
 * Revision 2.2  89/05/16  12:55:28  lozben
 * Functions that used to initialize FG_BP_[1,2,3,4], now
 * initialize FG_B_PLANES instead. FG_B_PLANES is set to the current
 * color index before a drawing primitive is called.
 * 
 * Revision 2.1  89/02/21  17:23:50  kbad
 * *** TOS 1.4  FINAL RELEASE VERSION ***
 * 
 * Revision 1.7  88/05/05  12:17:01  lozben
 * Put back vq_mouse_status() routine, then commented it out, so that people
 * could see what it used to look like in "C".
 * 
 * Revision 1.6  88/04/28  17:25:59  eisen
 * Removed the initialization in vrq_locator because it seemed to affect
 * compatibility with previous versions.
 * 
 * Revision 1.5  88/04/25  17:18:51  eisen
 * Changed v_locator to call SET_CUR(x, y). SET_CUR sets the GCURX, GCURY and
 * vblank draw packet position to x,y. SET_CUR(x, y) alters system variables
 * atomically.
 * 
 * Revision 1.4  88/04/19  17:19:57  eisen
 * *** empty log message ***
 * 
 * Revision 1.2  88/04/19  12:34:34  lozben
 * vq_mouse_status has been changed to an asembly routine, to allow
 * for atomic access to mouse parameter block.
 * 
 * Revision 1.1  87/11/20  15:16:23  lozben
 * Initial revision
 * 
 *************************************************************************
 */

#include "vdi.h"
#include "fontdef.h"
#include "attrdef.h"
#include "scrndev.h"
#include "lineavar.h"
#include "gsxdef.h"
#include "gsxextrn.h"

/*--------------------------------------------------------------------------*/
/*
 * VDI #15 - vsl_type - Set the line type
 */
/* 306de: 00e081e6 */
/* 104de: 00fcb900 */
VOID vsl_type(NOTHING)
{
	register int16_t li;

	NINTOUT = 1;

	li = LV(INTIN)[0] - 1;
	if ((li >= MX_LN_STYLE) || (li < 0))
		li = 0;

	LV(INTOUT)[0] = (LV(cur_work)->line_index = li) + 1;
}

/*--------------------------------------------------------------------------*/
/* 
 * VDI #16 - vsl_width - Set polyline width
 */
/* 306de: 00e08230 */
/* 104de: 00fcb94a */
VOID vsl_width(NOTHING)
{
	register int16_t w,
	*pts_out;

	/* Limit the requested line width to a reasonable value. */

	w = LV(PTSIN)[0];
	if (w < 1)
		w = 1;
	else if (w > LV(SIZ_TAB)[6])
		w = LV(SIZ_TAB)[6];

	/* Make the line width an odd number (one less, if even). */

	w = ((w - 1) / 2) * 2 + 1;

	/* Set the line width internals and return parameters */

	NPTSOUT = 1;
	pts_out = LV(PTSOUT);
	*pts_out++ = LV(cur_work)->line_width = w;
	*pts_out = 0;
}

/*--------------------------------------------------------------------------*/
/*
 * VDI #108 - vsl_ends - Set polyline end styles
 */
/* 306de: 00e082ec */
/* 104de: 00fcb9aa */
VOID vsl_ends(NOTHING)
{
	register int16_t lb, le;
	register int16_t *pointer;
	register ATTRIBUTE *work_ptr;

	NINTOUT = 2;

	pointer = LV(INTIN);
	lb = *pointer++;
	if (lb < 0 || lb > 2)
		lb = 0;

	le = *pointer;
	if (le < 0 || le > 2)
		le = 0;

	pointer = LV(INTOUT);
	work_ptr = LV(cur_work);
	*pointer++ = work_ptr->line_beg = lb;
	*pointer = work_ptr->line_end = le;
}										/* End "vsl_ends". */

/*--------------------------------------------------------------------------*/
/* 
 * VDI #17 - vsl_color - Set polyline color index
 */
/* 306de: 00e082ec */
/* 104de: 00fcba06 */
VOID vsl_color(NOTHING)
{
	register int16_t lc;

	NINTOUT = 1;
	lc = LV(INTIN)[0];

	if ((lc >= LV(DEV_TAB)[13]) || (lc < 0))
		lc = 1;

	LV(INTOUT)[0] = lc;
	LV(cur_work)->line_color = MAP_COL[lc];
}

/*--------------------------------------------------------------------------*/
/* 
 * VDI #19 - vsm_height - Set polymarker height
 */
/* 306de: 00e0833c */
/* 104de: 00fcba56 */
VOID vsm_height(NOTHING)
{
	register int16_t h, *pts_out;
	register ATTRIBUTE *work_ptr;

	/* Limit the requested marker height to a reasonable value. */

	h = LV(PTSIN)[1];
	if (h < DEF_MKHT)
		h = DEF_MKHT;

	else if (h > MAX_MKHT)
		h = MAX_MKHT;

	/* Set the marker height internals and the return parameters. */

	work_ptr = LV(cur_work);
	work_ptr->mark_height = h;
	h = (h + DEF_MKHT / 2) / DEF_MKHT;
	work_ptr->mark_scale = h;
	NPTSOUT = 1;
	pts_out = LV(PTSOUT);
	*pts_out++ = h * DEF_MKWD;
	*pts_out = h * DEF_MKHT;
	FLIP_Y = 1;
}

/*--------------------------------------------------------------------------*/
/*
 * VDI #18 - vsm_type - Set polymarker type
 */
/* 306de: 00e083c8 */
/* 104de: 00fcbae2 */
VOID vsm_type(NOTHING)
{
	register int16_t i;

	i = LV(INTIN)[0] - 1;
	i = ((i >= MAX_MARK_INDEX) || (i < 0)) ? 2 : i;
	LV(INTOUT)[0] = (LV(cur_work)->mark_index = i) + 1;
	NINTOUT = 1;
}

/*--------------------------------------------------------------------------*/
/*
 * VDI #20 - vsm_color - Set polymarker color index
 */
/* 306de: 00e08418 */
/* 104de: 00fcbb32 */
VOID vsm_color(NOTHING)
{
	register int16_t i;

	i = LV(INTIN)[0];
	i = ((i >= LV(DEV_TAB)[13]) || (i < 0)) ? 1 : i;
	LV(INTOUT)[0] = i;
	LV(cur_work)->mark_color = MAP_COL[i];
	NINTOUT = 1;
}

/*--------------------------------------------------------------------------*/
/*
 * VDI #23 - vsf_interior - Set fill interior style
 */
/* 306de: 00e0846e */
/* 104de: 00fcbb88 */
VOID vsf_interior(NOTHING)
{
	register int16_t fs;

	NINTOUT = 1;
	fs = LV(INTIN)[0];
	if (fs > MX_FIL_STYLE || fs < 0)
		fs = 0;
	LV(INTOUT)[0] = LV(cur_work)->fill_style = fs;
	st_fl_ptr();
}

/*--------------------------------------------------------------------------*/
/* 
 * VDI #24 - vsf_style - Set fill style index
 */
/* 306de: 00e084ba */
/* 104de: 00fcbbd4 */
VOID vsf_style(NOTHING)
{
	register int16_t fi;
	register ATTRIBUTE *work_ptr;

	NINTOUT = 1;
	fi = LV(INTIN)[0];
	work_ptr = LV(cur_work);

	if (work_ptr->fill_style == 2)
	{
		if (fi > MX_FIL_PAT_INDEX || fi < 1)
			fi = 1;
	} else
	{
		if (fi > MX_FIL_HAT_INDEX || fi < 1)
			fi = 1;
	}

	work_ptr->fill_index = (LV(INTOUT)[0] = fi) - 1;

	st_fl_ptr();
}

/*--------------------------------------------------------------------------*/
/*
 * VDI #25 - vsf_color - Set fill color index
 */
/* 306de: 00e08522 */
/* 104de: 00fcbc3c */
VOID vsf_color(NOTHING)
{
	register int16_t fc;

	NINTOUT = 1;
	fc = LV(INTIN)[0];
	if ((fc >= LV(DEV_TAB)[13]) || (fc < 0))
		fc = 1;

	LV(INTOUT)[0] = fc;
	LV(cur_work)->fill_color = MAP_COL[fc];
}

/*--------------------------------------------------------------------------*/
/*
 * VDI #28 - v_locator - Input locator
 */
/* 306de: 00e08572 */
/* 104de: 00fcbc8c */
VOID v_locator(NOTHING)
{
	register int16_t motion, button;
	register int16_t *pointer;
	register int16_t x, y;

	LV(INTIN)[0] = 1;

	/* Set the initial locator position.                 */

	pointer = LV(PTSIN);
	x = *pointer++;
	y = *pointer;
	SET_CUR(x, y);						/* set GCURX, GCURY, & mouse */


	if (LV(loc_mode) == 0)					/* Request mode       */
	{
/*	  GLOC_KEY(); Init locator status. OOPS, Causes incompatibilities */

		LV(HIDE_CNT) = 1;					/* Force cursor visible   */
		DIS_CUR();

		/* Wait for key or button event (bit 0 of GLOC_KEY return)    */

		while (!(GLOC_KEY() & 1))		/* X1 and Y1 get updated  */
			;

		pointer = LV(CONTRL);
		*(pointer + 4) = 1;
		*(pointer + 2) = 1;
		*(LV(INTOUT)) = LV(TERM_CH) & 0x00FF;	/* terminating character  */
		pointer = LV(PTSOUT);
		*pointer++ = LV(X1);				/* final cursor position  */
		*pointer = LV(Y1);

		HIDE_CUR();						/* always hide cursor     */
	}
	else								/* Sample mode        */
	{
		motion = 0;
		button = 0;

		switch (GLOC_KEY())
		{
		case 0:
			break;

		case 1:
			button = 1;
			*(LV(INTOUT)) = LV(TERM_CH) & 0x00FF;
			break;

		case 2:
			motion = 1;
			pointer = LV(PTSOUT);
			*pointer++ = LV(X1);
			*pointer = LV(Y1);
			break;

		case 3:
			motion = 1;
			button = 1;
			*(LV(INTOUT)) = LV(TERM_CH) & 0x00FF;
			pointer = LV(PTSOUT);
			*pointer++ = LV(X1);
			*pointer = LV(Y1);
			break;
		}
		pointer = LV(CONTRL);
		*(pointer + 2) = motion;
		*(pointer + 4) = button;
	}
}

/*--------------------------------------------------------------------------*/
/*
 * VDI #122 - v_show_c - Show Cursor
 */
/* 306de: 00e0868e */
/* 104de: 00fcbda8 */
VOID v_show_c(NOTHING)
{
	/* DIS_CUR will trash all registers but FP and SP */

	if (!LV(INTIN)[0] && LV(HIDE_CNT))
		LV(HIDE_CNT) = 1;					/* reset cursor to on */

	DIS_CUR();
}

/*--------------------------------------------------------------------------*/
/*
 * VDI #123 - v_hide_c - Hide cursor
 */
/* 306de: 00e086b6 */
/* 104de: 00fcbdd0 */
VOID v_hide_c(NOTHING)
{
	HIDE_CUR();
}

/*--------------------------------------------------------------------------*/
/*
 * RETURN MOUSE BUTTON STATUS
 *
 * vq_mouse() - has been changed to an assembly file, to allow for
 *              atomic access to mouse parameter block.
 * vq_mouse() 
 * {
 *    register int16_t *pointer;
 *
 *    LV(INTOUT)[0] = MOUSE_BT;
 *
 *    pointer = LV(CONTRL);
 *    *(pointer+4) = 1;
 *    *(pointer+2) = 1;
 *
 *    pointer = LV(PTSOUT);
 *    *pointer++ = GCURX;
 *    *pointer   = GCURY;
 * }
 */

/*--------------------------------------------------------------------------*/
/* 
 * VDI #29 - v_valuator - Input valuator
 */
/* 306de: 00e086c4 */
/* 104de: 00fcbdde */
VOID v_valuator(NOTHING)
{
}

/*--------------------------------------------------------------------------*/
/*
 * VDI #30 - v_choice - Input choice
 */
/* 306de: 00e086cc */
/* 104de: 00fcbde6 */
VOID v_choice(NOTHING)
{
	int16_t i;

	if (LV(chc_mode) == 0)
	{
		NINTOUT = 1;
		while (GCHC_KEY() != 1)
			;
		LV(INTOUT)[0] = LV(TERM_CH) & 0x00ff;
	} else
	{
		i = GCHC_KEY();
		NINTOUT = i;
		if (i == 1)
			LV(INTOUT)[0] = LV(TERM_CH) & 0x00ff;
		else if (i == 2)
			LV(INTOUT)[1] = LV(TERM_CH) & 0x00ff;
	}
}

/*--------------------------------------------------------------------------*/
/*
 * VDI #31 - v_string - Input string
 */
/* 306de: 00e08756 */
/* 104de: 00fcbe70 */
VOID v_string(NOTHING)
{
	int16_t i;
	int16_t j;
#if TOSVERSION < 0x400
	int unused;
#endif
	int16_t mask;

#if TOSVERSION < 0x400
	UNUSED(unused);
#endif
	mask = 0x00ff;
	j = LV(INTIN)[0];
	if (j < 0)
	{
		j = -j;
		mask = 0xffff;
	}
	if (!LV(str_mode))						/* Request mode */
	{
		LV(TERM_CH) = 0;
		for (i = 0; (i < j) && (LV(TERM_CH) != 0x000d); i++)
		{
			while (GCHR_KEY() == 0)
				;
			LV(INTOUT)[i] = LV(TERM_CH) = LV(TERM_CH) & mask;
		}
		if (LV(TERM_CH) == 0x000d)
			--i;
		NINTOUT = i;
	} else								/* Sample mode */
	{
		i = 0;
		while ((i < j) && (GCHR_KEY() != 0))	/* jde 12-aug-85 */
			LV(INTOUT)[i++] = LV(TERM_CH) & mask;
		NINTOUT = i;
	}
}

/*--------------------------------------------------------------------------*/
/*
 * VDI #128 - vq_key_s - Return Shift, Control, Alt State
 */
/* 306de: 00e08836 */
/* 104de: 00fcbf50 */
VOID vq_key_s(NOTHING)
{
	NINTOUT = 1;
	LV(INTOUT)[0] = GSHIFT_S();
}

/*--------------------------------------------------------------------------*/
/*
 * VDI #32 - vswr_mode - Set writing mode
 */
/* 306de: 00e0885a */
/* 104de: 00fcbf74 */
VOID vswr_mode(NOTHING)
{
	register int16_t wm;

	NINTOUT = 1;
	wm = LV(INTIN)[0] - 1;
	if ((wm > MAX_MODE) | (wm < 0))
		wm = 0;

	LV(INTOUT)[0] = (LV(cur_work)->wrt_mode = wm) + 1;
}

/*--------------------------------------------------------------------------*/
/*
 * VDI #33 - vsin_mode - Set input mode
 */
/* 306de: 00e088b4 */
/* 104de: 00fcbfce */
VOID vsin_mode(NOTHING)
{
	register int16_t i,	*int_in;

	NINTOUT = 1;

	int_in = LV(INTIN);
	LV(INTOUT)[0] = i = *(int_in + 1);
	i--;
	switch (*(int_in))
	{
	case 0:
		break;

	case 1:							/* locator */
		LV(loc_mode) = i;
		break;

	case 2:							/* valuator */
		LV(val_mode) = i;
		break;

	case 3:							/* choice */
		LV(chc_mode) = i;
		break;

	case 4:							/* string */
		LV(str_mode) = i;
		break;
	}
}

/*--------------------------------------------------------------------------*/
/*
 * VDI #115 - vqin_mode - Inquire Input Mode
 */
/* 306de: 00e08920 */
/* 104de: 00fcc03a */
VOID vqin_mode(NOTHING)
{
	register int16_t *int_out;

	NINTOUT = 1;

	int_out = LV(INTOUT);
	switch (LV(INTIN)[0])
	{
	case 0:
		break;

	case 1:							/* locator */
		*int_out = LV(loc_mode);
		break;

	case 2:							/* valuator */
		*int_out = LV(val_mode);
		break;

	case 3:							/* choice */
		*int_out = LV(chc_mode);
		break;

	case 4:							/* string */
		*int_out = LV(str_mode);
		break;
	}
}

/*--------------------------------------------------------------------------*/
/*
 * VDI #104 - vsf_perimeter - Set fill perimeter visibility
 */
/* 306de: 00e08984 */
/* 104de: 00fcc09e */
VOID vsf_perimeter(NOTHING)
{
	register int16_t *int_out;
	register ATTRIBUTE *work_ptr;
#if TOSVERSION < 0x400
	register int unused;
	UNUSED(unused);
#endif

	work_ptr = LV(cur_work);
	int_out = LV(INTOUT);

	if (LV(INTIN)[0] == 0)
	{
		*int_out = 0;
		work_ptr->fill_per = FALSE;
	} else
	{
		*(int_out) = 1;
		work_ptr->fill_per = TRUE;
	}
	NINTOUT = 1;
}

/*--------------------------------------------------------------------------*/
/* 
 * VDI #113 - vsl_udsty - Set user-defined line style pattern
 */
/* 306de: 00e089ca */
/* 104de: 00fcc0e4 */
VOID vsl_udsty(NOTHING)
{
	LV(cur_work)->ud_ls = LV(INTIN)[0];
}

/*--------------------------------------------------------------------------*/
/*
 * VDI #129 - vs_clip - Set Clip Region
 */
/* 306de: 00e089e2 */
/* 104de: 00fcc0fc */
VOID vs_clip(NOTHING)
{
	register int16_t *xy;
#if TOSVERSION < 0x400
	register int unused;
#endif
	register int16_t rtemp;
	register ATTRIBUTE *work_ptr;

#if TOSVERSION < 0x400
	UNUSED(unused);
#endif

	work_ptr = LV(cur_work);
	if ((work_ptr->clip = LV(INTIN)[0]) != 0)
	{
		xy = LV(PTSIN);
		arb_corner(xy, ULLR);

		rtemp = *xy++;
		work_ptr->xmn_clip = (rtemp < 0) ? 0 : rtemp;

		rtemp = *xy++;
		work_ptr->ymn_clip = (rtemp < 0) ? 0 : rtemp;

		rtemp = *xy++;
		work_ptr->xmx_clip = (rtemp > LV(DEV_TAB)[0]) ? LV(DEV_TAB)[0] : rtemp;

		rtemp = *xy;
		work_ptr->ymx_clip = (rtemp > LV(DEV_TAB)[1]) ? LV(DEV_TAB)[1] : rtemp;
	} else
	{
		work_ptr->clip = 0;
		work_ptr->xmn_clip = 0;
		work_ptr->ymn_clip = 0;
		work_ptr->xmx_clip = xres;
		work_ptr->ymx_clip = yres;
	}									/* End else:  clipping turned off. */
}

/*--------------------------------------------------------------------------*/

/* 306de: 00e08a86 */
/* 104de: 00fcc1a0 */
VOID arb_corner(P(int16_t *) corners, P(int16_t) type)
PP(int16_t *corners;)
PP(int16_t type;)
{
	/* Local declarations. */
	register int16_t temp, typ;
	register int16_t *xy1, *xy2;

	/* Fix the x coordinate values, if necessary. */

	xy1 = corners;
	xy2 = corners + 2;
	if (*xy1 > *xy2)
	{
		temp = *xy1;
		*xy1 = *xy2;
		*xy2 = temp;
	}


	/* End if:  "x" values need to be swapped. */
	/* Fix y values based on whether traditional (ll, ur) or raster-op */
	/* (ul, lr) format is desired.                                     */
	xy1++;								/* they now point to corners[1] and corners[3] */
	xy2++;

	typ = type;

	if (((typ == LLUR) && (*xy1 < *xy2)) || ((typ == ULLR) && (*xy1 > *xy2)))
	{
		temp = *xy1;
		*xy1 = *xy2;
		*xy2 = temp;
	}									/* End if:  "y" values need to be swapped. */
}

/*--------------------------------------------------------------------------*/

/*
 * VDI #109 - vro_cpyfm - Copy raster, opaque
 */
/* 306de: 00e08ad2 */
/* 104de: 00fcc1ec */
VOID dro_cpyfm(NOTHING)
{
	arb_corner(LV(PTSIN), ULLR);
	arb_corner((LV(PTSIN) + 4), ULLR);
	LV(COPYTRAN) = 0;
	COPY_RFM();
}

/*--------------------------------------------------------------------------*/

/*
 * VDI #121 - vrt_cpyfm - Copy raster, transparent
 */
/* 306de: 00e08b04 */
/* 104de: 00fcc21e */
VOID drt_cpyfm(NOTHING)
{
	arb_corner(LV(PTSIN), ULLR);
	arb_corner((LV(PTSIN) + 4), ULLR);
	LV(COPYTRAN) = 0xFFFF;
	COPY_RFM();
}

/*--------------------------------------------------------------------------*/

#if VIDEL_SUPPORT
/*
 * VDI #110 - vr_trnfm - Transform form
 */
VOID vr_trnfm(NOTHING)
{
	register FDB *src, *dst;
	register int16_t sFormat, dFormat;
	register FDB **cntrlS, **cntrlD;

	cntrlS = (FDB **) (&LV(CONTRL)[7]);
	cntrlD = (FDB **) (&LV(CONTRL)[9]);

	src = *cntrlS;
	dst = *cntrlD;

	sFormat = src->formatId;
	dFormat = dst->formatId;

	switch (sFormat)
	{
	case DEVICEDEP:
		switch (dFormat)
		{
		case DEVICEDEP:
		case STANDARD:
		default:
			TRAN_FM();
			break;

		case INTERLEAVED:
			break;

		case PIXPACKED:
			break;
		}
		break;

	case STANDARD:
		switch (dFormat)
		{
		case DEVICEDEP:
		case STANDARD:
		default:
			TRAN_FM();
			break;
		}
		break;

	default:
		break;
	}
}
#endif

/*--------------------------------------------------------------------------*/

/*
 * VDI #114 - vr_recfl - Fill rectangle
 */
/* 306de: 00e08b3c */
/* 104de: 00fcc256 */
VOID dr_recfl(NOTHING)
{
	register int16_t *pts_in;
#if !PLANES8
	register int16_t color;
#endif

	/* Perform arbitrary corner fix-ups and invoke the rectangle fill routine */

	arb_corner(LV(PTSIN), ULLR);
#if PLANES8
	LV(FG_B_PLANES) = LV(cur_work)->fill_color;
#else
	color = LV(cur_work)->fill_color;
	LV(FG_BP_1) = color & 0x01;
	LV(FG_BP_2) = color & 0x02;
	LV(FG_BP_3) = color & 0x04;
	LV(FG_BP_4) = color & 0x08;
#endif

	pts_in = LV(PTSIN);
	LV(X1) = *pts_in++;
	LV(Y1) = *pts_in++;
	LV(X2) = *pts_in++;
	LV(Y2) = *pts_in;

	RECTFILL();
}
