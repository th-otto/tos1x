/*
 **********************************  monout.c  *********************************
 *
 * =============================================================================
 * $Author: lozben $	$Date: 91/01/22 15:58:35 $
 * =============================================================================
 *
 * Revision 3.2  91/01/22  15:58:35  lozben
 * Changed some of the code to work with the latest include files.
 * 
 * Revision 3.1  91/01/14  15:49:11  lozben
 * Made changes so the file can work with the latest gsxextrn.h and
 * the new lineavar.h files.
 * 
 * Revision 3.0  91/01/03  15:12:50  lozben
 * New generation VDI
 * 
 * Revision 2.6  90/05/31  18:23:44  lozben
 * Fixed v_opnvwk(). There used to be a bug while adding a new work station
 * in the middle of the linked list.
 * 
 * Revision 2.5  90/04/03  13:45:09  lozben
 * Added a constant of BLTPRFRM in the inquire call. It used to be hardwired to
 * a 1000.
 * 
 * Revision 2.4  89/08/18  18:33:53  lozben
 * Got rid of all the call to Icos() and Isin() with constant parameters.
 * 
 * Revision 2.3  89/07/28  14:38:25  lozben
 * Changed circ_dda() to deal with modes where each pixel is larger
 * in the x direction than in the y. Also changed do_circ() do draw
 * more rounded wide line edges.
 * 
 * Revision 2.2  89/05/16  12:57:39  lozben
 * Functions that used to initialize FG_BP_[1,2,3,4], now
 * initialize FG_B_PLANES instead. FG_B_PLANES is set to the current
 * color index before a drawing primitive is called.
 * 
 * Revision 2.1  89/02/21  17:24:00  kbad
 * *** TOS 1.4  FINAL RELEASE VERSION ***
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

#define Malloc(size) vtrap1(0x48, (long)(size))
#define Mfree(ptr) vtrap1(0x49, ptr)
#define SPSHIFTMODE	    (* ((int16_t *) 0xff8266L))	/* sparrow shift mode */
#define PIXMASK		    0x200			/* pix control in XGA */

const int16_t *const markhead[] = { m_dot, m_plus, m_star, m_square, m_cross, m_dmnd };

static int16_t code PROTO((int16_t x,int16_t y));
static VOID cir_dda PROTO((NOTHING));
static VOID Calc_pts PROTO((int16_t j));
static VOID wline PROTO((NOTHING));
static VOID clc_arc PROTO((NOTHING));
static VOID clc_nsteps PROTO((NOTHING));
static VOID perp_off PROTO((int16_t *px,int16_t *py));
static VOID quad_xform PROTO((int quad, int x, int y, int16_t *tx, int16_t *ty));
static VOID do_circ PROTO((int16_t cx, int16_t cy));
static VOID s_fa_attr PROTO((NOTHING));
static VOID r_fa_attr PROTO((NOTHING));
static VOID do_arrow PROTO((NOTHING));
static VOID arrow PROTO((int16_t *xy, int16_t inc));



/*
 * VDI #102 - vq_extnd - Extended inquire function
 */
/* 306de: 00e08b94 */
/* 206de: 00e082b2 */
/* 104de: 00fcc50a */
/* 106de: 00e0c736 */
VOID vq_extnd(NOTHING)
{
	register int16_t i;
	register int16_t *dp, *sp;

	dp = LV(CONTRL);
	*(dp + 2) = 6;
	*(dp + 4) = 45;

	FLIP_Y = 1;

	dp = LV(PTSOUT);

	if (LV(INTIN)[0] == 0)
	{
		sp = LV(SIZ_TAB);
		for (i = 0; i < 12; i++)
			*dp++ = *sp++;

		sp = LV(DEV_TAB);
	} else
	{
		*dp++ = LV(XMN_CLIP);				/* PTSOUT[0] */
		*dp++ = LV(YMN_CLIP);				/* PTSOUT[1] */
		*dp++ = LV(XMX_CLIP);				/* PTSOUT[2] */
		*dp++ = LV(YMX_CLIP);				/* PTSOUT[3] */

		for (i = 4; i < 12; i++)
			*dp++ = 0;

		sp = LV(INQ_TAB);
	}

	dp = LV(INTOUT);
	for (i = 0; i < 45; i++)
		*dp++ = *sp++;

	if (LV(INTIN)[0])						/* if extended inquire is requested */
	{
		if (GETBLT() & 1)
			LV(INTOUT)[6] = 5000;			/*     BiT BLiT performance = 5000  */
		else
			LV(INTOUT)[6] = BLTPRFRM;		/*     non BiT BLiT performance     */
	}
}


/*
 * VDI #2 - v_clswk - Close workstation
 */
/* 306de: 00e08c5c */
/* 206de: 00e0837a */
/* 104de: 00fcc5d2 */
/* 106de: 00e0c7fe */
VOID v_clswk(NOTHING)
{
	ATTRIBUTE *next_work;

	if (virt_work.next_work != NULL)
	{									/* Are there VWs to close */
		LV(cur_work) = virt_work.next_work;
		do
		{
			next_work = LV(cur_work)->next_work;
			Mfree(LV(cur_work));
		} while ((LV(cur_work) = next_work));
	}

	DINIT_G();
}


/*
 * VDI #6 - v_pline - Polyline
 */
/* 306de: 00e08ca4 */
/* 206de: 00e083c2 */
/* 104de: 00fcc61a */
VOID v_pline(NOTHING)
{
	register int16_t l;
	register ATTRIBUTE *work_ptr;

	work_ptr = LV(cur_work);
	l = work_ptr->line_index;
	LV(LN_MASK) = (l < 6) ? LINE_STYLE[l] : work_ptr->ud_ls;

	l = work_ptr->line_color;
	LV(FG_BP_1) = l & 0x01;
	LV(FG_BP_2) = l & 0x02;
	LV(FG_BP_3) = l & 0x04;
	LV(FG_BP_4) = l & 0x08;

	if (work_ptr->line_width == 1)
	{
		pline();
		work_ptr = LV(cur_work);
		if ((work_ptr->line_beg | work_ptr->line_end) & ARROWED)
			do_arrow();
	} else
	{
		wline();
	}
}


/*
 * VDI #7 - v_pmarker - Polymarker
 */
/* 306de: 00e08d14 */
/* 206de: 00e0845c */
/* 104de: 00fcc6b4 */
VOID v_pmarker(NOTHING)
{
	int16_t i, j, num_lines, num_vert, x_center, y_center, sav_points[10];
	int16_t sav_index, sav_color, sav_width, sav_beg, sav_end;
	int unused;
	const int16_t *mrk_ptr;
	int16_t *old_ptsin;
	int16_t scale, num_points, *src_ptr;
	register int16_t h, *pts_in;
	register const int16_t *m_ptr;
	register ATTRIBUTE *work_ptr;

	UNUSED(unused);

	/* Save the current polyline attributes which will be used. */

	work_ptr = LV(cur_work);
	sav_index = work_ptr->line_index;
	sav_color = work_ptr->line_color;
	sav_width = work_ptr->line_width;
	sav_beg = work_ptr->line_beg;
	sav_end = work_ptr->line_end;

	/* Set the appropriate polyline attributes. */

	work_ptr->line_index = 0;
	work_ptr->line_color = work_ptr->mark_color;
	work_ptr->line_width = 1;
	work_ptr->line_beg = 0;
	work_ptr->line_end = 0;
	LV(CLIP) = 1;

	scale = work_ptr->mark_scale;

	/* Copy the PTSIN pointer since we will be doing polylines */

	num_vert = NPTSIN;
	src_ptr = old_ptsin = LV(PTSIN);
	LV(PTSIN) = sav_points;

	/* Loop over the number of points. */

	for (i = 0; i < num_vert; i++)
	{
		pts_in = src_ptr;
		x_center = *pts_in++;
		y_center = *pts_in++;
		src_ptr = pts_in;

		/* Get the pointer to the appropriate marker type definition. */
		m_ptr = markhead[LV(cur_work)->mark_index];
		num_lines = *m_ptr++;

		/* Loop over the number of polylines which define the marker. */

		for (j = 0; j < num_lines; j++)
		{

			num_points = NPTSIN = *m_ptr++;	/* How many points?  Get them.  */

			pts_in = sav_points;
			for (h = 0; h < num_points; h++)
			{
				*pts_in++ = x_center + scale * (*m_ptr++);
				*pts_in++ = y_center + scale * (*m_ptr++);
			}

			/* Output the polyline. */

			mrk_ptr = m_ptr;			/* Save for next pass */
			v_pline();
			m_ptr = mrk_ptr;
		}
	}

	/* Restore the PTSIN pointer */

	LV(PTSIN) = old_ptsin;

	/* Restore the current polyline attributes. */

	work_ptr = LV(cur_work);
	work_ptr->line_index = sav_index;
	work_ptr->line_color = sav_color;
	work_ptr->line_width = sav_width;
	work_ptr->line_beg = sav_beg;
	work_ptr->line_end = sav_end;
}


/*
 * VDI #9 - v_fillarea - Filled area
 */
/* 306de: 00e08e5a */
/* 206de: 00e085a2 */
/* 104de: 00fcc7fa */
VOID v_fillarea(NOTHING)
{
	plygn();
}


/*
 * VDI #11 - v_gdp - Graphic drawing primitives
 */
/* 306de: 00e08e66 */
/* 206de: 00e085ae */
/* 104de: 00fcc806 */
VOID v_gdp(NOTHING)
{
	int16_t i, ltmp_end, rtmp_end;
	register int16_t *xy_pointer;
	register ATTRIBUTE *work_ptr;

	i = LV(CONTRL)[5];
	xy_pointer = LV(PTSIN);
	work_ptr = LV(cur_work);

	if (i > 0 && i < 11)
	{
		i--;
		switch (i)
		{
		case 0:						/* GDP BAR - converted to alpha 2 RJG 12-1-84 */
			dr_recfl();
			if (LV(cur_work)->fill_per == TRUE)
			{
				LV(LN_MASK) = 0xffff;

				xy_pointer = LV(PTSIN);
				*(xy_pointer + 5) = *(xy_pointer + 7) = *(xy_pointer + 3);
				*(xy_pointer + 3) = *(xy_pointer + 9) = *(xy_pointer + 1);
				*(xy_pointer + 4) = *(xy_pointer + 2);
				*(xy_pointer + 6) = *(xy_pointer + 8) = *(xy_pointer);

				NPTSIN = 5;

				pline();
			}
			break;

		case 1:						/* GDP ARC */
		case 2:						/* GDP PIE */
			gdp_arc();
			break;

		case 3:						/* GDP CIRCLE */
			LV(xc) = *xy_pointer;
			LV(yc) = *(xy_pointer + 1);
			LV(xrad) = *(xy_pointer + 4);
			LV(yrad) = SMUL_DIV(LV(xrad), xsize, ysize);
			LV(del_ang) = 3600;
			LV(beg_ang) = 0;
			LV(end_ang) = 3600;
			clc_nsteps();
			clc_arc();
			break;

		case 4:						/* GDP ELLIPSE */
			LV(xc) = *xy_pointer;
			LV(yc) = *(xy_pointer + 1);
			LV(xrad) = *(xy_pointer + 2);
			LV(yrad) = *(xy_pointer + 3);
			if (work_ptr->xfm_mode < 2)
				LV(yrad) = yres - LV(yrad);
			LV(del_ang) = 3600;
			LV(beg_ang) = 0;
			LV(end_ang) = 0;
			clc_nsteps();
			clc_arc();
			break;

		case 5:						/* GDP ELLIPTICAL ARC */
		case 6:						/* GDP ELLIPTICAL PIE */
			gdp_ell();
			break;

		case 7:						/* GDP Rounded Box */
			ltmp_end = work_ptr->line_beg;
			work_ptr->line_beg = SQUARED;
			rtmp_end = work_ptr->line_end;
			work_ptr->line_end = SQUARED;
			gdp_rbox();
			work_ptr = LV(cur_work);
			work_ptr->line_beg = ltmp_end;
			work_ptr->line_end = rtmp_end;
			break;

		case 8:						/* GDP Rounded Filled Box */
			gdp_rbox();
			break;

		case 9:						/* GDP Justified Text */
			d_justified();
#ifndef __ALCYON__
			break;
#endif
		}
	}
}


/*
 * VDI #35 - vql_attributes - Inquire Current Polyline Attributes
 */
/* 306de: 00e09016 */
/* 206de: 00e0875e */
/* 104de: 00fcc9b6 */
VOID vql_attributes(NOTHING)
{
	register int16_t *pointer;
	register ATTRIBUTE *work_ptr;

	pointer = LV(INTOUT);
	work_ptr = LV(cur_work);
	*pointer++ = work_ptr->line_index + 1;
	*pointer++ = REV_MAP_COL[work_ptr->line_color];
	*pointer = LV(WRT_MODE) + 1;

	pointer = LV(PTSOUT);
	*pointer++ = work_ptr->line_width;
	*pointer = 0;

	pointer = LV(CONTRL);
	*(pointer + 2) = 1;
	*(pointer + 4) = 3;
}


/*
 * VDI #36 - vqm_attributes - Inquire Current Polymarker Attributes
 */
/* 306de: 00e09072 */
/* 206de: 00e087ba */
/* 104de: 00fcca12 */
VOID vqm_attributes(NOTHING)
{
	register int16_t *pointer;
	register ATTRIBUTE *work_ptr;

	pointer = LV(INTOUT);
	work_ptr = LV(cur_work);
	*pointer++ = work_ptr->mark_index;
	*pointer++ = REV_MAP_COL[work_ptr->mark_color];
	*pointer = LV(WRT_MODE) + 1;

	pointer = LV(PTSOUT);
	*pointer++ = 0;
	*pointer = work_ptr->mark_height;

	pointer = LV(CONTRL);
	*(pointer + 4) = 3;
	*(pointer + 2) = 1;
	FLIP_Y = 1;
}


/*
 * VDI #37 - vqm_attributes - Inquire Current Fill Area Attributes
 */
/* 306de: 00e090d2 */
/* 206de: 00e0881a */
/* 104de: 00fcca72 */
VOID vqf_attributes(NOTHING)
{
	register int16_t *pointer;
	register ATTRIBUTE *work_ptr;

	pointer = LV(INTOUT);
	work_ptr = LV(cur_work);
	*pointer++ = work_ptr->fill_style;
	*pointer++ = REV_MAP_COL[work_ptr->fill_color];
	*pointer++ = work_ptr->fill_index + 1;
	*pointer++ = LV(WRT_MODE) + 1;
	*pointer = work_ptr->fill_per;

	NINTOUT = 5;
}


VOID pline(NOTHING)
{
	int16_t i, *old_pointer;
	register int16_t *pointer;

	LV(LSTLIN) = FALSE;
	old_pointer = LV(PTSIN);
	for (i = (NPTSIN - 1); i > 0; i--)
	{
		if (i == 1)
			LV(LSTLIN) = TRUE;

		pointer = old_pointer;
		LV(X1) = *pointer++;
		LV(Y1) = *pointer++;
		LV(X2) = *pointer;
		LV(Y2) = *(pointer + 1);
		old_pointer = pointer;
		if (LV(CLIP))
		{
			if (clip_line())
				ABLINE();
		} else
		{
			ABLINE();
		}
	}
}


/* 306de: 00e091ae */
/* 206de: 00e088f6 */
/* 104de: 00fccb4e */
BOOLEAN clip_line(NOTHING)
{
	int16_t _deltaX, _deltaY;
	int16_t x1y1_clip_flag, x2y2_clip_flag, line_clip_flag;
	register int16_t *x, *y;

	while ((x1y1_clip_flag = code(LV(X1), LV(Y1))) | (x2y2_clip_flag = code(LV(X2), LV(Y2))))
	{
		if ((x1y1_clip_flag & x2y2_clip_flag))
			return FALSE;

		if (x1y1_clip_flag)
		{
			line_clip_flag = x1y1_clip_flag;
			x = &LV(X1);
			y = &LV(Y1);
		} else
		{
			line_clip_flag = x2y2_clip_flag;
			x = &LV(X2);
			y = &LV(Y2);
		}

		_deltaX = LV(X2) - LV(X1);
		_deltaY = LV(Y2) - LV(Y1);

		if (line_clip_flag & 1)
		{								/* left ? */
			*y = LV(Y1) + SMUL_DIV(_deltaY, (LV(XMN_CLIP) - LV(X1)), _deltaX);
			*x = LV(XMN_CLIP);
		} else if (line_clip_flag & 2)
		{								/* right ? */
			*y = LV(Y1) + SMUL_DIV(_deltaY, (LV(XMX_CLIP) - LV(X1)), _deltaX);
			*x = LV(XMX_CLIP);
		} else if (line_clip_flag & 4)
		{								/* top ? */
			*x = LV(X1) + SMUL_DIV(_deltaX, (LV(YMN_CLIP) - LV(Y1)), _deltaY);
			*y = LV(YMN_CLIP);
		} else if (line_clip_flag & 8)
		{								/* bottom ? */
			*x = LV(X1) + SMUL_DIV(_deltaX, (LV(YMX_CLIP) - LV(Y1)), _deltaY);
			*y = LV(YMX_CLIP);
		}
	}

	return TRUE;						/* segment now cliped  */
}


/* 306de: 00e0932a */
/* 206de: 00e08a72 */
/* 104de: 00fcccca */
static int16_t code(P(int16_t ) x, P(int16_t ) y)
PP(int16_t x;)
PP(int16_t y;)
{
	int16_t clip_flag;

	clip_flag = 0;

	if (x < LV(XMN_CLIP))
		clip_flag = 1;
	else if (x > LV(XMX_CLIP))
		clip_flag = 2;
	if (y < LV(YMN_CLIP))
		clip_flag += 4;
	else if (y > LV(YMX_CLIP))
		clip_flag += 8;

	return clip_flag;
}


/* 306de: 00e09382 */
/* 206de: 00e08aca */
/* 104de: 00fccd22 */
VOID plygn(NOTHING)
{
	register int16_t *pointer, i, k;
	register int unused1;
	int unused2;
	UNUSED(unused1);
	UNUSED(unused2);

	i = LV(cur_work)->fill_color;
	LV(FG_BP_1) = i & 0x01;
	LV(FG_BP_2) = i & 0x02;
	LV(FG_BP_3) = i & 0x04;
	LV(FG_BP_4) = i & 0x08;

	LV(LSTLIN) = FALSE;

	pointer = LV(PTSIN);
	pointer++;

	LV(fill_maxy) = LV(fill_miny) = *pointer++;
	pointer++;

	for (i = (NPTSIN - 1); i > 0; i--)
	{
		k = *pointer++;
		pointer++;
		if (k < LV(fill_miny))
			LV(fill_miny) = k;
		else if (k > LV(fill_maxy))
			LV(fill_maxy) = k;
	}
	if (LV(CLIP))
	{
		if (LV(fill_miny) < LV(YMN_CLIP))
		{
			if (LV(fill_maxy) >= LV(YMN_CLIP))	/* plygon starts before clip */
				LV(fill_miny) = LV(YMN_CLIP) - 1;	/* plygon partial overlap */
			else						/* see fix 1.2 */
				return;					/* plygon entirely before clip */
		}
		if (LV(fill_maxy) > LV(YMX_CLIP))
		{
			if (LV(fill_miny) <= LV(YMX_CLIP))	/* plygon ends after clip */
				LV(fill_maxy) = LV(YMX_CLIP);	/* plygon partial overlap */
			else
				return;					/* plygon entirely after clip */
		}
	}
	k = NPTSIN * 2;
	pointer = LV(PTSIN);
	*(pointer + k) = *pointer;
	*(pointer + k + 1) = *(pointer + 1);
	for (LV(Y1) = LV(fill_maxy); LV(Y1) > LV(fill_miny); LV(Y1)--)
	{
		LV(fil_intersect) = 0;
		CLC_FLIT();
	}
	if (LV(cur_work)->fill_per == TRUE)
	{
		LV(LN_MASK) = 0xffff;
		NPTSIN++;
		pline();
	}
}


/*
 * VDI #11,8 - v_rbox - Rounded rectangle
 * VDI #11,9 - v_rfbox - Filled rounded rectangle
 */
/* 306de: 00e094e2 */
/* 206de: 00e08c52 */
/* 104de: 00fcceaa */
VOID gdp_rbox(NOTHING)
{
	register int16_t i, j;
	int16_t rdeltax, rdeltay;
	register int16_t *pointer;
	register ATTRIBUTE *work_ptr;

#ifndef __ALCYON__
	pointer = LV(PTSIN); /* BUG: not initialized here */
#endif
	arb_corner(pointer, LLUR);

	pointer = LV(PTSIN);
	LV(X1) = *pointer++;
	LV(Y1) = *pointer++;
	LV(X2) = *pointer++;
	LV(Y2) = *pointer;

	rdeltax = (LV(X2) - LV(X1)) / 2;
	rdeltay = (LV(Y1) - LV(Y2)) / 2;

	LV(xrad) = xres >> 6;
	if (LV(xrad) > rdeltax)
		LV(xrad) = rdeltax;

	LV(yrad) = SMUL_DIV(LV(xrad), xsize, ysize);
	if (LV(yrad) > rdeltay)
		LV(yrad) = rdeltay;

	pointer = LV(PTSIN);
	*pointer++ = 0;
	*pointer++ = LV(yrad);

	*pointer++ = SMUL_DIV(Icos(675), LV(xrad), 32767);
	*pointer++ = SMUL_DIV(Isin(675), LV(yrad), 32767);
	*pointer++ = SMUL_DIV(Icos(450), LV(xrad), 32767);
	*pointer++ = SMUL_DIV(Isin(450), LV(yrad), 32767);
	*pointer++ = SMUL_DIV(Icos(225), LV(xrad), 32767);
	*pointer++ = SMUL_DIV(Isin(225), LV(yrad), 32767);

	*pointer++ = LV(xrad);
	*pointer = 0;

	pointer = LV(PTSIN);
	LV(xc) = LV(X2) - LV(xrad);
	LV(yc) = LV(Y1) - LV(yrad);
	j = 10;
	for (i = 9; i >= 0; i--)
	{
		*(pointer + j + 1) = LV(yc) + *(pointer + i--);
		*(pointer + j) = LV(xc) + *(pointer + i);
		j += 2;
	}
	LV(xc) = LV(X1) + LV(xrad);
	j = 20;
	for (i = 0; i < 10; i++)
	{
		*(pointer + j++) = LV(xc) - *(pointer + i++);
		*(pointer + j++) = LV(yc) + *(pointer + i);
	}
	LV(yc) = LV(Y2) + LV(yrad);
	j = 30;
	for (i = 9; i >= 0; i--)
	{
		*(pointer + j + 1) = LV(yc) - *(pointer + i--);
		*(pointer + j) = LV(xc) - *(pointer + i);
		j += 2;
	}
	LV(xc) = LV(X2) - LV(xrad);
	j = 0;
	for (i = 0; i < 10; i++)
	{
		*(pointer + j++) = LV(xc) + *(pointer + i++);
		*(pointer + j++) = LV(yc) - *(pointer + i);
	}
	*(pointer + 40) = *pointer;
	*(pointer + 41) = *(pointer + 1);

	pointer = LV(CONTRL);
	*(pointer + 1) = 21;
	if (*(pointer + 5) == 8)
	{
		work_ptr = LV(cur_work);
		i = work_ptr->line_index;
		LV(LN_MASK) = (i < 6) ? LINE_STYLE[i] : work_ptr->ud_ls;

		i = work_ptr->line_color;
		LV(FG_BP_1) = i & 0x01;
		LV(FG_BP_2) = i & 0x02;
		LV(FG_BP_3) = i & 0x04;
		LV(FG_BP_4) = i & 0x08;

		if (work_ptr->line_width == 1)
		{
			pline();
		} else
		{
			wline();
		}
	} else
	{
		plygn();
	}
}


/*
 * VDI #11,2 - v_arc - Draw a circular arc
 */
/* 306de: 00e09824 */
/* 206de: 00e08ffc */
/* 104de: 00fcd254 */
VOID gdp_arc(NOTHING)
{
	register int16_t *pointer;

	pointer = LV(INTIN);

	LV(beg_ang) = *pointer++;
	LV(end_ang) = *pointer;
	LV(del_ang) = LV(end_ang) - LV(beg_ang);
	if (LV(del_ang) < 0)
		LV(del_ang) += 3600;

	pointer = LV(PTSIN);
	LV(xrad) = *(pointer + 6);
	LV(yrad) = SMUL_DIV(LV(xrad), xsize, ysize);
	clc_nsteps();

#if 0 /* removed 5/1/86 LT */

	LV(n_steps) = SMUL_DIV(LV(del_ang), LV(n_steps), 3600);
	if (LV(n_steps) == 0)
		return;
#endif

	LV(xc) = *pointer++;
	LV(yc) = *pointer;
	clc_arc();
}


static VOID clc_nsteps(NOTHING)
{
	if (LV(xrad) > LV(yrad))
		LV(n_steps) = LV(xrad);
	else
		LV(n_steps) = LV(yrad);
	LV(n_steps) = LV(n_steps) >> 2;
	if (LV(n_steps) < MIN_ARC_CT)
		LV(n_steps) = MIN_ARC_CT;
	else
	{
		if (LV(n_steps) > MAX_ARC_CT)
			LV(n_steps) = MAX_ARC_CT;
	}
}


/*
 * VDI #11,6 - v_ellarc - Elliptical arc
 * VDI #11,7 - v_ellpie - Elliptical pie
 */
/* 306de: 00e0990a */
/* 206de: 00e090e2 */
/* 104de: 00fcd33a */
VOID gdp_ell(NOTHING)
{
	register int16_t *pointer;

	pointer = LV(INTIN);
	LV(beg_ang) = *pointer++;
	LV(end_ang) = *pointer;
	LV(del_ang) = LV(end_ang) - LV(beg_ang);
	if (LV(del_ang) < 0)
		LV(del_ang) += 3600;

	pointer = LV(PTSIN);
	LV(xc) = *pointer++;
	LV(yc) = *pointer++;
	LV(xrad) = *pointer++;
	LV(yrad) = *pointer;
	if (LV(cur_work)->xfm_mode < 2)
		LV(yrad) = yres - LV(yrad);
	clc_nsteps();

#if 0 /*  removed 5/1/86 LT */
	LV(n_steps) = SMUL_DIV(LV(del_ang), LV(n_steps), 3600);
	if (LV(n_steps) == 0)
		return;
#endif

	clc_arc();
}


static VOID clc_arc(NOTHING)
{
	int16_t i, j;
	register int16_t *cntl_ptr, *xy_ptr;

	if (LV(CLIP))
	{
		if (((LV(xc) + LV(xrad)) < LV(XMN_CLIP)) || ((LV(xc) - LV(xrad)) > LV(XMX_CLIP)) ||
			((LV(yc) + LV(yrad)) < LV(YMN_CLIP)) || ((LV(yc) - LV(yrad)) > LV(YMX_CLIP)))
			return;
	}
	LV(start) = LV(angle) = LV(beg_ang);
	i = j = 0;
	Calc_pts(j);
	for (i = 1; i < LV(n_steps); i++)
	{
		j += 2;
		LV(angle) = SMUL_DIV(LV(del_ang), i, LV(n_steps)) + LV(start);
		Calc_pts(j);
	}
	j += 2;
	i = LV(n_steps);
	LV(angle) = LV(end_ang);
	Calc_pts(j);

/*----------------------------------------------------------------------*/
/* If pie wedge, draw to center and then close. If arc or circle, do 	*/
/* nothing because loop should close circle.				*/
/*----------------------------------------------------------------------*/

	cntl_ptr = LV(CONTRL);
	xy_ptr = LV(PTSIN);

	*(cntl_ptr + 1) = LV(n_steps) + 1;		/* since loop in Clc_arc starts at 0 */
	if ((*(cntl_ptr + 5) == 3) || (*(cntl_ptr + 5) == 7))	/* pie wedge */
	{
		LV(n_steps)++;
		j += 2;
		*(xy_ptr + j) = LV(xc);
		*(xy_ptr + j + 1) = LV(yc);
		*(cntl_ptr + 1) = LV(n_steps) + 1;
	}
	if ((*(cntl_ptr + 5) == 2) || (*(cntl_ptr + 5) == 6))	/* open arc */
		v_pline();

	else
		plygn();
}


static VOID Calc_pts(P(int16_t) j)
PP(int16_t j;)
{
	int16_t k;
	register int16_t *pointer;

	pointer = LV(PTSIN);
	k = SMUL_DIV(Icos(LV(angle)), LV(xrad), 32767) + LV(xc);
	*(pointer + j) = k;
	k = LV(yc) - SMUL_DIV(Isin(LV(angle)), LV(yrad), 32767);	/*FOR RASTER CORDS. */
	*(pointer + j + 1) = k;
}


VOID st_fl_ptr(NOTHING)
{
	register int16_t fi, pm;
	register const int16_t *pp;
	register ATTRIBUTE *work_ptr;

	work_ptr = LV(cur_work);
	fi = work_ptr->fill_index;
	pm = 0;
	switch (work_ptr->fill_style)
	{
	case 0:
		pp = HOLLOW;
		break;

	case 1:
		pp = SOLID;
		break;

	case 2:
		if (fi < 8)
		{
			pm = DITHRMSK;
			pp = &DITHER[fi * (pm + 1)];
		} else
		{
			pm = OEMMSKPAT;
			pp = &OEMPAT[(fi - 8) * (pm + 1)];
		}
		break;
	case 3:
		if (fi < 6)
		{
			pm = HAT_0_MSK;
			pp = &HATCH0[fi * (pm + 1)];
		} else
		{
			pm = HAT_1_MSK;
			pp = &HATCH1[(fi - 6) * (pm + 1)];
		}
		break;
	case 4:
		pm = 0x000f;
		pp = &work_ptr->ud_patrn[0];
#ifndef __ALCYON__
		break;
	default:
		/* BUG: illegal values for fill_style set patptr to undefined pointer pp */
		return;
#endif
	}
	work_ptr->patptr = pp;
	work_ptr->patmsk = pm;
}


/* Moved the circle DDA code that was in vsl_width() here. */
static VOID cir_dda(NOTHING)
{
	int unused1;
	int unused2;
	int16_t i, j;
	register int16_t *xptr, *yptr, x, y, d;

	UNUSED(unused1);
	UNUSED(unused2);
	/* Calculate the number of vertical pixels required. */

	d = LV(cur_work)->line_width;
	LV(num_qc_lines) = (d * xsize / ysize) / 2 + 1;

	/* Initialize the circle DDA.  "y" is set to the radius. */
	LV(line_cw) = d;
	y = (d + 1) / 2;
	x = 0;
	d = 3 - 2 * y;

	xptr = &LV(q_circle)[x];
	yptr = &LV(q_circle)[y];

	/* Do an octant, starting at north.  The values for the next octant */
	/* (clockwise) will be filled by transposing x and y.               */

	while (x < y)
	{
		*yptr = x;
		*xptr = y;

		if (d < 0)
			d = d + 4 * x + 6;
		else
		{
			d = d + 4 * (x - y) + 10;
			yptr--;
			y--;
		}
		xptr++;
		x++;
	}

	if (x == y)
		LV(q_circle)[x] = x;

	/* Fake a pixel averaging when converting to non-1:1 aspect ratio. */
	for (x = 0, yptr = LV(q_circle), i = 0; i < LV(num_qc_lines); i++)
	{
		y = (i << 1) + 1;
		y = y * ysize / xsize;
		y = y / 2;

		d = 0;

		xptr = &LV(q_circle)[x];
		for (j = x; j <= y; j++)
			d += *xptr++;

		*yptr++ = d / (y - x + 1);
		x = y + 1;
	}
}


/* 306de: 00e09e1e */
/* 206de: 00e0956c */
/* 104de: 00fcd7c4 */
static VOID wline(NOTHING)
{
	int16_t i, k, box[10];							/* box two high to close polygon */
	int16_t numpts, wx1, wy1, wx2, wy2, vx, vy;
	int unused1;
	int16_t *old_ptsin, *src_ptr;
	register int16_t *pointer, x, y, d, d2;
	register ATTRIBUTE *work_ptr;

	UNUSED(unused1);

	/* Don't attempt wide lining on a degenerate polyline */

	if ((numpts = NPTSIN) < 2)
		return;

	work_ptr = LV(cur_work);
	if (work_ptr->line_width != LV(line_cw))
		cir_dda();

	/* If the ends are arrowed, output them. */

	if ((work_ptr->line_beg | work_ptr->line_end) & ARROWED)
		do_arrow();

	s_fa_attr();

	/* Initialize the starting point for the loop. */

	old_ptsin = pointer = LV(PTSIN);
	wx1 = *pointer++;
	wy1 = *pointer++;
	src_ptr = pointer;

	/* If the end style for the first point is not squared, output a circle. */

	if (LV(s_begsty) != SQUARED)
		do_circ(wx1, wy1);

	/* Loop over the number of points passed in. */

	for (i = 1; i < numpts; i++)
	{
		/* Get the ending point for the line segment and the vector from the */
		/* start to the end of the segment.                                  */

		pointer = src_ptr;
		wx2 = *pointer++;
		wy2 = *pointer++;
		src_ptr = pointer;

		vx = wx2 - wx1;
		vy = wy2 - wy1;

		/* Ignore lines of zero length. */

		if ((vx == 0) && (vy == 0))
			continue;

		/* Calculate offsets to fatten the line.  If the line segment is */
		/* horizontal or vertical, do it the simple way.                 */

		if (vx == 0)
		{
			vx = LV(q_circle)[0];
			vy = 0;
		}
		/* End if:  vertical. */
		else if (vy == 0)
		{
			vx = 0;
			vy = LV(num_qc_lines) - 1;
		}
		/* End else if:  horizontal. */
		else
		{
			/* Find the offsets in x and y for a point perpendicular to the line */
			/* segment at the appropriate distance.                              */

			k = SMUL_DIV(-vy, ysize, xsize);
			vy = SMUL_DIV(vx, xsize, ysize);
			vx = k;
			perp_off(&vx, &vy);
		}

		/* Prepare the control and points parameters for the polygon call. */

		NPTSIN = 4;

		LV(PTSIN) = pointer = box;

		x = wx1;
		y = wy1;
		d = vx;
		d2 = vy;

		*pointer++ = x + d;
		*pointer++ = y + d2;
		*pointer++ = x - d;
		*pointer++ = y - d2;

		x = wx2;
		y = wy2;

		*pointer++ = x - d;
		*pointer++ = y - d2;
		*pointer++ = x + d;
		*pointer = y + d2;

		plygn();

		/* restore the PTSIN pointer */

		LV(PTSIN) = old_ptsin;

		/* If the terminal point of the line segment is an internal joint, */
		/* output a filled circle.                                         */

		if ((i < numpts - 1) || (LV(s_endsty) != SQUARED))
			do_circ(wx2, wy2);

		/* The line segment end point becomes the starting point for the next */
		/* line segment.                                                      */

		wx1 = wx2;
		wy1 = wy2;
	}

	/* Restore the attribute environment. */

	r_fa_attr();
}


/* 306de: 00e0a010 */
/* 206de: 00e09756 */
/* 104de: 00fcd9ae */
static VOID perp_off(P(int16_t *) px, P(int16_t *) py)
PP(int16_t *px;)
PP(int16_t *py;)
{
	register int16_t *vx, *vy, *pcircle, u, v;
	int unused1;
	int16_t x, y, quad, magnitude, min_val, x_val, y_val;

	UNUSED(unused1);
	vx = px;
	vy = py;

	pcircle = LV(q_circle);

	/* Mirror transform the vector so that it is in the first quadrant. */

	if (*vx >= 0)
		quad = (*vy >= 0) ? 1 : 4;
	else
		quad = (*vy >= 0) ? 2 : 3;

	quad_xform(quad, *vx, *vy, &x, &y);

	/* Traverse the circle in a dda-like manner and find the coordinate pair   */
	/* (u, v) such that the magnitude of (u*y - v*x) is minimized.  In case of */
	/* a tie, choose the value which causes (u - v) to be minimized.  If not   */
	/* possible, do something.                                                 */

	min_val = 32767;
	u = *pcircle;
	v = 0;
#ifndef __ALCYON__
	x_val = y_val = 0; /* quiet compiler */
#endif
	for (;;)
	{
		/* Check for new minimum, same minimum, or finished. */
		if (((magnitude = ABS(u * y - v * x)) < min_val) ||
			((magnitude == min_val) && (ABS(x_val - y_val) > ABS(u - v))))
		{
			min_val = magnitude;
			x_val = u;
			y_val = v;
		}
		/* End if:  new minimum. */
		else
			break;

		/* Step to the next pixel. */
		if (v == LV(num_qc_lines) - 1)
		{
			if (u == 1)
				break;
			else
				u--;
		}
		/* End if:  doing top row. */
		else
		{
			if (pcircle[v + 1] >= u - 1)
			{
				v++;
				u = pcircle[v];
			} /* End if:  do next row up. */
			else
			{
				u--;
			}
		}
	}

	/* Transform the solution according to the quadrant. */

	quad_xform(quad, x_val, y_val, vx, vy);
}


/* 306de: 00e0a154 */
/* 206de: 00e09896 */
/* 104de: 00fcdaee */
static VOID quad_xform(P(int) quad, P(int) x, P(int) y, P(int16_t *) tx, P(int16_t *) ty)
PP(int quad;)
PP(int x;)
PP(int y;)
PP(int16_t *tx;)
PP(int16_t *ty;)
{
	switch (quad)
	{
	case 1:
	case 4:
		*tx = x;
		break;

	case 2:
	case 3:
		*tx = -x;
		break;
#if BINEXACT
		asm("ds.b 0"); /* hmpf, optimizer seems to have missed to remove superfluous bra */
#endif
	}

	switch (quad)
	{
	case 1:
	case 2:
		*ty = y;
		break;

	case 3:
	case 4:
		*ty = -y;
		break;
#if (TOSVERSION < 0x106) & BINEXACT & (OS_COUNTRY != CTRY_NL)
		asm("ds.b 0"); /* hmpf, optimizer seems to have missed to remove superfluous bra */
#endif
	}
}


/* 306de: 00e0a1cc */
/* 206de: 00e0990c */
/* 104de: 00fcdb66 */
static VOID do_circ(P(int16_t) cx, P(int16_t) cy)
PP(int16_t cx;)
PP(int16_t cy;)
{
	int16_t k;
	register int16_t *pointer;

	/* Only perform the act if the circle has radius. */

	if (LV(num_qc_lines) > 0)
	{
		/* Do the horizontal line through the center of the circle. */
		pointer = LV(q_circle);
		LV(X1) = cx - *pointer;
		LV(X2) = cx + *pointer;
		LV(Y1) = LV(Y2) = cy;

		if (clip_line())
			ABLINE();
		/* Do the upper and lower semi-circles. */
		for (k = 1; k < LV(num_qc_lines); k++)
		{
			/* Upper semi-circle. */
			pointer = &LV(q_circle)[k];
			LV(X1) = cx - *pointer;
			LV(X2) = cx + *pointer;
			LV(Y1) = LV(Y2) = cy - k;
			if (clip_line())
			{
				ABLINE();
				pointer = &LV(q_circle)[k];
			}

			/* Lower semi-circle. */
			LV(X1) = cx - *pointer;
			LV(X2) = cx + *pointer;
			LV(Y1) = LV(Y2) = cy + k;
			if (clip_line())
				ABLINE();
		}
	}
}


/* 306de: 00e0a2ca */
/* 206de: 00e09a14 */
/* 104de: 00fcdc6e */
static VOID s_fa_attr(NOTHING)
{
	register ATTRIBUTE *work_ptr;

	/* Set up the fill area attribute environment. */

	work_ptr = LV(cur_work);

	LV(LN_MASK) = LINE_STYLE[0];
	LV(s_fil_col) = work_ptr->fill_color;
	work_ptr->fill_color = work_ptr->line_color;
	LV(s_fill_per) = work_ptr->fill_per;
	work_ptr->fill_per = TRUE;
	LV(patptr) = SOLID;
	LV(patmsk) = 0;
	LV(multifill) = 0;						/* jde 25sep85 */
	LV(s_begsty) = work_ptr->line_beg;
	LV(s_endsty) = work_ptr->line_end;
	work_ptr->line_beg = SQUARED;
	work_ptr->line_end = SQUARED;
}


/* 306de: 00e0a336 */
/* 206de: 00e09a80 */
/* 104de: 00fcdcda */
static VOID r_fa_attr(NOTHING)
{
	register ATTRIBUTE *work_ptr;

	/* Restore the fill area attribute environment. */

	work_ptr = LV(cur_work);

	work_ptr->fill_color = LV(s_fil_col);
	work_ptr->fill_per = LV(s_fill_per);
	work_ptr->line_beg = LV(s_begsty);
	work_ptr->line_end = LV(s_endsty);
}


/* 306de: 00e0a36e */
/* 206de: 00e09ab8 */
/* 104de: 00fcdd12 */
static VOID do_arrow(NOTHING)
{
	int16_t x_start, y_start, new_x_start, new_y_start;
	register int16_t *pts_in;

	/* Set up the attribute environment. */

	s_fa_attr();

	/* Function "arrow" will alter the end of the line segment.  Save the */
	/* starting point of the polyline in case two calls to "arrow" are    */
	/* necessary.                                                         */

	pts_in = LV(PTSIN);
	new_x_start = x_start = *pts_in;
	new_y_start = y_start = *(pts_in + 1);

	if (LV(s_begsty) & ARROWED)
	{
		arrow(pts_in, 2);
		pts_in = LV(PTSIN);					/* arrow calls plygn which trashes regs */
		new_x_start = *pts_in;
		new_y_start = *(pts_in + 1);
	}
	/* End if:  beginning point is arrowed. */
	if (LV(s_endsty) & ARROWED)
	{
		*pts_in = x_start;
		*(pts_in + 1) = y_start;
		arrow((pts_in + 2 * NPTSIN - 2), -2);
		pts_in = LV(PTSIN);					/* arrow calls plygn which trashes regs */
		*pts_in = new_x_start;
		*(pts_in + 1) = new_y_start;
	}


	/* End if:  ending point is arrowed. */
	/* Restore the attribute environment. */
	r_fa_attr();
}


/* 306de: 00e0a40a */
/* 206de: 00e09b54 */
/* 104de: 00fcddae */
static VOID arrow(P(int16_t *) xy, P(int16_t) inc)
PP(int16_t *xy;)
PP(int16_t inc;)
{
	int16_t arrow_len, arrow_wid, line_len;
	int16_t *xybeg, sav_contrl, triangle[8];						/* triangle 2 high to close polygon */
	int16_t dx, dy;
	int16_t base_x, base_y, ht_x, ht_y;
	int16_t *old_ptsin;
	register int16_t *ptr1, *ptr2, temp, i;

	/* Set up the arrow-head length and width as a function of line width. */

	temp = LV(cur_work)->line_width;
	arrow_wid = (arrow_len = (temp == 1) ? 8 : 3 * temp - 1) / 2;

	/* Initialize the beginning pointer. */

	xybeg = ptr1 = ptr2 = xy;

	/* Find the first point which is not so close to the end point that it */
	/* will be obscured by the arrowhead.                                  */

	temp = NPTSIN;
#ifndef __ALCYON__
	line_len = 0; /* BUG: used uninitialized below for nptsin < 1 */
	dx = dy = 0;
#endif
	for (i = 1; i < temp; i++)
	{
		/* Find the deltas between the next point and the end point.  Transform */
		/* to a space such that the aspect ratio is uniform and the x axis      */
		/* distance is preserved.                                               */

		ptr1 += inc;
		dx = *ptr2 - *ptr1;
		dy = SMUL_DIV(*(ptr2 + 1) - *(ptr1 + 1), ysize, xsize);

		/* Get the length of the vector connecting the point with the end point. */
		/* If the vector is of sufficient length, the search is over.            */

		if ((line_len = vec_len(ABS(dx), ABS(dy))) >= arrow_len)
			break;
	}

	/* Set xybeg to the point we found */

	xybeg = ptr1;

	/* If the longest vector is insufficiently long, don't draw an arrow. */

	if (line_len < arrow_len)
		return;

	/* Rotate the arrow-head height and base vectors.  Perform calculations */
	/* in 1000x space.                                                      */

	ht_x = SMUL_DIV(arrow_len, SMUL_DIV(dx, 1000, line_len), 1000);
	ht_y = SMUL_DIV(arrow_len, SMUL_DIV(dy, 1000, line_len), 1000);
	base_x = SMUL_DIV(arrow_wid, SMUL_DIV(dy, -1000, line_len), 1000);
	base_y = SMUL_DIV(arrow_wid, SMUL_DIV(dx, 1000, line_len), 1000);

	/* Transform the y offsets back to the correct aspect ratio space. */

	ht_y = SMUL_DIV(ht_y, xsize, ysize);
	base_y = SMUL_DIV(base_y, xsize, ysize);

	/* Save the vertice count */

	ptr1 = LV(CONTRL);
	sav_contrl = ptr1[1];		/* number of vertices */

	/* Build a polygon to send to plygn.  Build into a local array first since */
	/* xy will probably be pointing to the LV(PTSIN) array.                        */

	*(ptr1 + 1) = 3;
	ptr1 = triangle;
	ptr2 = xy;
	*ptr1 = *ptr2 + base_x - ht_x;
	*(ptr1 + 1) = *(ptr2 + 1) + base_y - ht_y;
	*(ptr1 + 2) = *ptr2 - base_x - ht_x;
	*(ptr1 + 3) = *(ptr2 + 1) - base_y - ht_y;
	*(ptr1 + 4) = *ptr2;
	*(ptr1 + 5) = *(ptr2 + 1);

	old_ptsin = LV(PTSIN);
	LV(PTSIN) = ptr1;
	plygn();
	LV(PTSIN) = old_ptsin;

	/* Restore the vertex count. */

	NPTSIN = sav_contrl;

	/* Adjust the end point and all points skipped. */

	ptr1 = xy;
	ptr2 = xybeg;
	*ptr1 -= ht_x;
	*(ptr1 + 1) -= ht_y;

	temp = inc;
	while ((ptr2 -= temp) != ptr1)
	{
		*ptr2 = *ptr1;
		*(ptr2 + 1) = *(ptr1 + 1);
	}
}


/* 306de: 00e0a676 */
/* 206de: 00e09dc0 */
/* 104de: 00fce01a */
/* 106de: 00e0e244 */
VOID init_wk(NOTHING)
{
	register int16_t l;
	register int16_t *pointer, *src_ptr;
	register ATTRIBUTE *work_ptr;

	pointer = LV(INTIN);
	pointer++;
	work_ptr = LV(cur_work);

	l = *pointer++;						/* INTIN[1] */
	work_ptr->line_index = ((l > MX_LN_STYLE) || (l < 0)) ? 0 : l - 1;

	l = *pointer++;						/* INTIN[2] */
	if ((l >= LV(DEV_TAB)[13]) || (l < 0))
		l = 1;
	work_ptr->line_color = MAP_COL[l];

	l = *pointer++ - 1;					/* INTIN[3] */
	work_ptr->mark_index = ((l >= MAX_MARK_INDEX) || (l < 0)) ? 2 : l;

	l = *pointer++;						/* INTIN[4] */
	if ((l >= LV(DEV_TAB)[13]) || (l < 0))
		l = 1;
	work_ptr->mark_color = MAP_COL[l];

	/* You always get the default font */

	pointer++;							/* INTIN[5] */

	l = *pointer++;						/* INTIN[6] */
	if ((l >= LV(DEV_TAB)[13]) || (l < 0))
		l = 1;
	work_ptr->text_color = MAP_COL[l];

	work_ptr->mark_height = DEF_MKHT;
	work_ptr->mark_scale = 1;

	l = *pointer++;						/* INTIN[7] */
	work_ptr->fill_style = ((l > MX_FIL_STYLE) || (l < 0)) ? 0 : l;

	l = *pointer++;						/* INTIN[8] */
	if (work_ptr->fill_style == 2)
		l = ((l > MX_FIL_PAT_INDEX) || (l < 1)) ? 1 : l;
	else
		l = ((l > MX_FIL_HAT_INDEX) || (l < 1)) ? 1 : l;
	work_ptr->fill_index = l;

	l = *pointer++;						/* INTIN[9] */
	if ((l >= LV(DEV_TAB)[13]) || (l < 0))
		l = 1;
	work_ptr->fill_color = MAP_COL[l];

	work_ptr->xfm_mode = *pointer;		/* INTIN[10] */

	st_fl_ptr();						/* set the fill pattern as requested */

	work_ptr->wrt_mode = 0;				/* default is replace mode */
	work_ptr->line_width = DEF_LWID;
	work_ptr->line_beg = 0;				/* default to squared ends */
	work_ptr->line_end = 0;

	work_ptr->fill_per = TRUE;

	work_ptr->xmn_clip = 0;
	work_ptr->ymn_clip = 0;
	work_ptr->xmx_clip = LV(DEV_TAB)[0];
	work_ptr->ymx_clip = LV(DEV_TAB)[1];
	work_ptr->clip = 0;

	work_ptr->cur_font = LV(def_font);

	work_ptr->loaded_fonts = NULL;

	work_ptr->scrpt2 = scrtsiz;
	work_ptr->scrtchp = deftxbu;

	work_ptr->num_fonts = LV(ini_font_count);

	work_ptr->style = 0;				/* reset special effects */
	work_ptr->scaled = FALSE;
	work_ptr->h_align = 0;
	work_ptr->v_align = 0;
	work_ptr->chup = 0;
	work_ptr->pts_mode = FALSE;

	/* move default user defined pattern to RAM */

	src_ptr = ROM_UD_PATRN;
	pointer = &work_ptr->ud_patrn[0];

	for (l = 0; l < 16; l++)
		*pointer++ = *src_ptr++;

	work_ptr->multifill = 0;

	work_ptr->ud_ls = LINE_STYLE[0];

	pointer = LV(CONTRL);
	*(pointer + 2) = 6;
	*(pointer + 4) = 45;

	pointer = LV(INTOUT);
	src_ptr = LV(DEV_TAB);
	for (l = 0; l < 45; l++)
		*pointer++ = *src_ptr++;

	pointer = LV(PTSOUT);
	src_ptr = LV(SIZ_TAB);
	for (l = 0; l < 12; l++)
		*pointer++ = *src_ptr++;

	FLIP_Y = 1;
}


/*
 * VDI #100 - v_opnvwk - Open virtual screen workstation
 */
/* 306de: 00e0a886 */
/* 206de: 00e09fd0 */
/* 104de: 00fce22a */
/* 106de: 00e0e454 */
VOID d_opnvwk(NOTHING)
{
	register int16_t handle;
	register ATTRIBUTE *new_work, *work_ptr;

	/* Allocate the memory for a virtual workstation.  If none available, exit */

	new_work = (ATTRIBUTE *) Malloc(sizeof(ATTRIBUTE));

	if (new_work == NULL)
	{									/* No work available */
		LV(CONTRL)[6] = 0;
		return;
	}

	/* Now find a free handle */

#if TP_28 /* VDIFIX */
	handle = 2;
#else
	handle = 1;
#endif
	work_ptr = &virt_work;

#if TP_28 /* VDIFIX */
	while (work_ptr->next_work != NULL && handle == work_ptr->next_work->handle)
	{
		handle++;
		work_ptr = work_ptr->next_work;
	}

	/* slot found, Insert the workstation here */
	LV(cur_work) = new_work;
	new_work->next_work = work_ptr->next_work;
	work_ptr->next_work = new_work;
#else
	while (handle == work_ptr->handle)
	{
		handle++;
		if (work_ptr->next_work == NULL)
			break;
		work_ptr = work_ptr->next_work;
	}
	if (work_ptr->next_work == NULL)
	{
		LV(cur_work) = work_ptr->next_work = new_work;
		new_work->next_work = NULL;
	} else
	{
		/*
		 * BUG: this will insert the new structure in the wrong
		 * place if there are gaps in the handle numbers.
		 * Fixed by the code for 3.0x above, and the VDIFIX auto folder program.
		 */
		register ATTRIBUTE *tmp;
		
		tmp = work_ptr->next_work;
		LV(cur_work) = work_ptr->next_work = new_work;
		new_work->next_work = tmp;
	}
#endif /* TP_28 */

	new_work->handle = LV(CONTRL)[6] = handle;

	init_wk();
}


/*
 * VDI #101 - v_clsvwk - Close virtual screen workstation
 */
/* 306de: 00e0a900 */
/* 206de: 00e0a062 */
/* 104de: 00fce2bc */
/* 106de: 00e0e4e6 */
VOID d_clsvwk(NOTHING)
{
	register ATTRIBUTE *work_ptr;
	register int16_t handle;

	/* cur_work points to workstation to deallocate, find who points to me */

	handle = LV(cur_work)->handle;

	if (handle == 1)					/* Can't close physical this way */
		return;

	for (work_ptr = &virt_work; handle != work_ptr->next_work->handle; work_ptr = work_ptr->next_work)
		;

	work_ptr->next_work = LV(cur_work)->next_work;
	Mfree(LV(cur_work));
}


/*
 * VDI #112 - vsf_udpat - Set user-defined fill-pattern
 */
/* 306de: 00e0a956 */
/* 206de: 00e0a0b8 */
/* 104de: 00fce312 */
/* 106de: 00e0e53c */
VOID dsf_udpat(NOTHING)
{
	register int16_t *sp, *dp, i, count;
	register ATTRIBUTE *work_ptr;

	work_ptr = LV(cur_work);
	count = NINTIN;

	if (count == 16)
	{
		work_ptr->multifill = 0;		/* Single Plane Pattern */
	} else if (count == (LV(INQ_TAB)[4] * 16))
	{
		work_ptr->multifill = 1;		/* Valid Multi-plane pattern */
	} else
	{
#if BINEXACT
		return 0;
#else
		return;
#endif
	}
	sp = LV(INTIN);
	dp = &work_ptr->ud_patrn[0];
	for (i = 0; i < count; i++)
		*dp++ = *sp++;
}
