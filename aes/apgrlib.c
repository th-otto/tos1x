/*************************************************************************
 *			Revision Control System
 * =======================================================================
 *  $Author: mui $	$Date: 89/04/26 18:06:25 $
 * =======================================================================
 *
 * Revision 2.2  89/04/26  18:06:25  mui
 * *** empty log message ***
 *
 * Revision 2.1  89/02/22  05:14:33  kbad
 * *** TOS 1.4  FINAL RELEASE VERSION ***
 *
 * Revision 1.1  88/06/02  12:26:00  lozben
 * Initial revision
 *
 *************************************************************************/

/*	APGRLIB.C	4/11/84 - 02/03/85	Gregg Morris		*/
/*	for 68k		03/06/85 - 03/09/85	Lowell Webster		*/
/*	Reg Opt		03/09/85		Derek Mui		*/

/*
 *	-------------------------------------------------------------
 *	GEM Application Environment Services		  Version 1.0
 *	Serial No.  XXXX-0000-654321		  All Rights Reserved
 *	Copyright (C) 1985			Digital Research Inc.
 *	-------------------------------------------------------------
 */

#include "aes.h"
#include "gemlib.h"
#include "gsxdefs.h"


/*************************************************************************
 *
 *		gr_inside(pt,th)
 *
 *************************************************************************/
 /* 100de: 00fd952a */
VOID gr_inside(P(GRECT *) pt, P(int16_t) th)
PP(register GRECT *pt;)
PP(register int16_t th;)
{
	pt->g_x += th;
	pt->g_y += th;
	pt->g_w -= (2 * th);
	pt->g_h -= (2 * th);
}

/***************************************************************************
 *
 *	gr_rect(icolor,ipattern,pt)
 *
 **************************************************************************/

/* 100de: 00fd9552 */
VOID gr_rect(P(uint16_t) icolor, P(uint16_t) ipattern, P(GRECT *) pt)
PP(uint16_t icolor;)
PP(register uint16_t ipattern;)
PP(register GRECT *pt;)
{
	register int16_t fis;

	fis = FIS_PATTERN;
	if (ipattern == IP_HOLLOW)
		fis = FIS_HOLLOW;
	else if (ipattern == IP_SOLID)
		fis = FIS_SOLID;

	vsf_color(icolor);
	bb_fill(MD_REPLACE, fis, ipattern, pt->g_x, pt->g_y, pt->g_w, pt->g_h);
}

/*************************************************************************
 *
 *		gr_just
 *
 *************************************************************************/
/*
 *	Routine to adjust the x,y starting point of a text string
 *	to account for its justification.  The number of characters
 *	in the string is also returned.
 */
/* 100de: 00fd95a0 */
int16_t gr_just(P(int16_t) just, P(int16_t) font, P(const char *) ptext, P(int16_t) w, P(int16_t) h, P(GRECT *) pt)
PP(int16_t just;)
PP(int16_t font;)
PP(const char *ptext;)
PP(register int16_t w;)
PP(register int16_t h;)
PP(register GRECT *pt;)
{
	int16_t numchs;

	/* figure out the width of the text string in pixels   */
	gsx_tcalc(font, ptext, &pt->g_w, &pt->g_h, &numchs);

	h -= pt->g_h;
	if (h > 0)							/* check height     */
		pt->g_y += (h + 1) / 2;

	w -= pt->g_w;
	if (w > 0)
	{
		switch (just)
		{
		case TE_CNTR:					/* center text in   */
			/*   rectangle      */
			pt->g_x += (w + 1) / 2;
			break;
		case TE_RIGHT:					/* right justify    */
			pt->g_x += w;
			/* break; */
		}
	}

	return numchs;
}

/************************************************************************
 *
 *	gr_gtext
 *
 ************************************************************************/
/*
 *	Routine to draw a string of graphic text.
 */
/* 100de: 00fd9618 */
VOID gr_gtext(P(int16_t) just, P(int16_t) font, P(const char *) ptext, P(GRECT *) pt, P(int16_t) mode)
PP(int16_t just;)
PP(int16_t font;)
PP(const char *ptext;)
PP(GRECT *pt;)
PP(int16_t mode;)
{
	int16_t numchs;
	GRECT t;

	/* figure out where &   */
	/*   how to put out */
	/*   the text       */
	rc_copy(pt, &t);
	numchs = gr_just(just, font, ptext, t.g_w, t.g_h, &t);
	if (numchs > 0)
		gsx_tblt(font, t.g_x, t.g_y, numchs);
}

/**************************************************************************
 *
 *		gr_crack(color,pbc,ptc,pip,pic,pmd)
 *
 **************************************************************************/
/*
 *	Routine to crack out the border color, text color, inside pattern,
 *	and inside color from a single color information word.
 */
/* 100de: 00fd9670 */
VOID gr_crack(P(uint16_t) color, P(int16_t *) pbc, P(int16_t *) ptc, P(int16_t *) pip, P(int16_t *) pic, P(int16_t *) pmd)
PP(register uint16_t color;)
PP(int16_t *pbc;)
PP(int16_t *ptc;)
PP(register int16_t *pip;)
PP(int16_t *pic;)
PP(register int16_t *pmd;)
{
	/* 4 bit encoded border color      */
	*pbc = (LHIBT(color) >> 4) & 0x0f;
	/* 4 bit encoded text color      */
	*ptc = LHIBT(color) & 0x0f;
	/* 3 bit encoded pattern */
	*pip = (LLOBT(color) >> 4) & 0x0f;
	/* 4th bit used to set text writing mode  */
	if (*pip & 0x08)
	{
		*pip &= 0x07;
		*pmd = MD_REPLACE;
	} else
	{
		*pmd = MD_TRANS;
	}
	/* 4 bit encoded inside color      */
	*pic = LLOBT(color) & 0x0f;
}

/************************************************************************
 *
 *	gr_icon(state,pmask,pdata,ptext,ch,chx,chy,pi,pt)
 *
 ************************************************************************/
/*
 *	Routine to draw an icon, which is a graphic image with a text
 *	string underneath it.
 */
/* 100de: 00fd96e0 */
VOID gr_gicon(P(int16_t) state, P(int16_t *) pmask, P(int16_t *) pdata, P(const char *) ptext, P(int16_t) ch, P(int16_t) chx, P(int16_t) chy, P(GRECT *) pi, P(GRECT *) pt)
PP(register int16_t state;)
PP(int16_t *pmask;)
PP(int16_t *pdata;)
PP(const char *ptext;)
PP(register int16_t ch;)
PP(int16_t chx;)
PP(int16_t chy;)
PP(register GRECT *pi;)
PP(register GRECT *pt;)
{
	register int16_t fgcol, bgcol, tmp;

	/* crack the color/chardefinition word    */
	fgcol = (ch >> 12) & 0x000f;
	bgcol = (ch >> 8) & 0x000f;
	ch &= 0x0ff;
	/* invert if selected   */
	if (state & SELECTED)
	{
		tmp = fgcol;
		fgcol = bgcol;
		bgcol = tmp;
	}
	/* do mask unless its on a white background   */
	if (!((state & WHITEBAK) && (bgcol == WHITE)))
	{
		gsx_blt(pmask, 0, 0, pi->g_w / 8, 0x0L, pi->g_x, pi->g_y,
				gl_width / 8, pi->g_w, pi->g_h, MD_TRANS, bgcol, fgcol);
		gr_rect(bgcol, IP_SOLID, pt);
	}
	/* draw the data    */
	gsx_blt(pdata, 0, 0, pi->g_w / 8, 0x0L, pi->g_x, pi->g_y, gl_width / 8, pi->g_w, pi->g_h, MD_TRANS, fgcol, bgcol);
	/* draw the character   */
	gsx_attr(TRUE, MD_TRANS, fgcol);
	if (ch)
	{
		intin[0] = ch;
		gsx_tblt(SMALL, pi->g_x + chx, pi->g_y + chy, 1);
	}
	/* draw the label   */
	gr_gtext(TE_CNTR, SMALL, ptext, pt, MD_TRANS);
}



/**************************************************************************
 *
 *	gr_box(x,y,w,h,th)
 *
 **************************************************************************/
/*
 *	Routine to draw a box of a certain thickness using the current
 *	attribute settings
 */
/* 100de: 00fd9806 */
VOID gr_box(P(int16_t) x, P(int16_t) y, P(int16_t) w, P(int16_t) h, P(int16_t) th)
PP(int16_t x;)
PP(int16_t y;)
PP(int16_t w;)
PP(int16_t h;)
PP(register int16_t th;)
{
	GRECT t, n;

	r_set(&t, x, y, w, h);
	if (th != 0)
	{
		if (th < 0)
			th--;
		gsx_moff();
		do
		{
			th += (th > 0) ? -1 : 1;
			rc_copy(&t, &n);
			gr_inside(&n, th);
			gsx_box(&n);
		} while (th != 0);
		gsx_mon();
	}
}
