/*************************************************************************
 *			Revision Control System
 * =======================================================================
 *  $Author: kbad $	$Date: 89/07/27 03:18:58 $
 * =======================================================================
 *
 * Revision 2.3  89/07/27  03:18:58  kbad
 * gsx_start: force gl_wbox > gl_wchar+2
 *
 * Revision 2.2  89/04/26  18:06:48  mui
 * aes30
 *
 * Revision 2.1  89/02/22  05:14:52  kbad
 * *** TOS 1.4  FINAL RELEASE VERSION ***
 *
 * Revision 1.1  88/06/02  12:26:09  lozben
 * Initial revision
 */
/*	APGSXIF.C	05/06/84 - 02/04/85	Lee Lorenzen		*/
/*	Reg Opt		03/08/85 - 03/09/85	Derek Mui		*/
/*	Crunching	4/10/86			Derek Mui		*/
/*	Fix at gsx_xbox	6/11/86			Derek Mui		*/

/*
 *	-------------------------------------------------------------
 *	GEM Application Environment Services		  Version 1.0
 *	Serial No.  XXXX-0000-654321		  All Rights Reserved
 *	Copyright (C) 1985			Digital Research Inc.
 *	-------------------------------------------------------------
 */

/*
 *	Crunched 	2/2/87 		JE
 *
 *	Change at gsx_start for new pixel ratio	7/26/89	D.Mui
 * 	Assemble with MAS 900801 kbad
 *	Change at gsx_start to do inquire of number planes 7/7/92	D.Mui
 */

#include "aes.h"
#include "gemlib.h"
#include "gsxdefs.h"



VOID gsx_sclip(P(GRECT *) pt)
PP(GRECT *pt;)
{
	register int16_t *ppts;

	ppts = &ptsin[0];

	r_get(pt, &gl_xclip, &gl_yclip, &gl_wclip, &gl_hclip);

	if (gl_wclip && gl_hclip)
	{
		ppts[0] = gl_xclip;
		ppts[1] = gl_yclip;
		ppts[2] = gl_xclip + gl_wclip - 1;
		ppts[3] = gl_yclip + gl_hclip - 1;
		avst_clip(TRUE, &ppts[0]);
	} else
	{
		avst_clip(FALSE, &ppts[0]);
	}
	return TRUE;
}


VOID gsx_gclip(P(GRECT *) pt)
PP(GRECT *pt;)
{
	r_set(pt, gl_xclip, gl_yclip, gl_wclip, gl_hclip);
}



BOOLEAN gsx_chkclip(P(GRECT *) pt)
PP(register GRECT *pt;)
{
	/* if clipping is on    */
	if (gl_wclip && gl_hclip)
	{
		if ((pt->g_y + pt->g_h) < gl_yclip)
			return FALSE;				/* all above    */
		if ((pt->g_x + pt->g_w) < gl_xclip)
			return FALSE;				/* all left */
		if ((gl_yclip + gl_hclip) <= pt->g_y)
			return FALSE;				/* all below    */
		if ((gl_xclip + gl_wclip) <= pt->g_x)
			return FALSE;				/* all right    */
	}
	return TRUE;
}


VOID gsx_pline(P(int16_t) offx, P(int16_t) offy, P(int16_t) cnt, P(const int16_t *) pts)
PP(int16_t offx;)
PP(int16_t offy;)
PP(register int16_t cnt;)
PP(register const int16_t *pts;)
{
	register int16_t i, j;

	for (i = 0; i < cnt; i++)
	{
		j = i * 2;
		ptsin[j] = offx + pts[j];
		ptsin[j + 1] = offy + pts[j + 1];
	}

	gsx_xline(cnt, &ptsin[0]);
}


VOID gsx_cline(P(uint16_t) x1, P(uint16_t) y1, P(uint16_t) x2, P(uint16_t) y2)
PP(uint16_t x1;)
PP(uint16_t y1;)
PP(uint16_t x2;)
PP(uint16_t y2;)
{
	int16_t x, y, w, h;

	UNUSED(x);
	UNUSED(y);
	UNUSED(w);
	UNUSED(h);
	gsx_moff();
#ifdef __GNUC__
	{
		int16_t pxy[4];
		pxy[0] = x1;
		pxy[1] = y1;
		pxy[2] = x2;
		pxy[3] = y2;
		av_pline(2, pxy);
	}
#else
	/* ugly hack */
	av_pline(2, &x1);
#endif
	gsx_mon();
}


VOID gsx_attr(P(uint16_t) text, P(uint16_t) mode, P(uint16_t) color)
PP(uint16_t text;)
PP(register uint16_t mode;)
PP(register uint16_t color;)
{
	register int16_t tmp;
	register int16_t *pcntr;

	pcntr = &contrl[0];

	tmp = intin[0];
	pcntr[1] = 0;
	pcntr[3] = 1;
	pcntr[6] = gl_handle;
	if (mode != gl_mode)
	{
		pcntr[0] = SET_WRITING_MODE;
		intin[0] = gl_mode = mode;
		gsx2();
	}
	pcntr[0] = FALSE;
	if (text)
	{
		if (color != gl_tcolor)
		{
			pcntr[0] = S_TEXT_COLOR;
			gl_tcolor = color;
		}
	} else
	{
		if (color != gl_lcolor)
		{
			pcntr[0] = S_LINE_COLOR;
			gl_lcolor = color;
		}
	}
	if (pcntr[0])
	{
		intin[0] = color;
		gsx2();
	}
	intin[0] = tmp;
}



VOID gsx_bxpts(P(GRECT *) pt)
PP(register GRECT *pt;)
{
	register int16_t *ppts;

	ppts = &ptsin[0];

	ppts[0] = pt->g_x;
	ppts[1] = pt->g_y;
	ppts[2] = pt->g_x + pt->g_w - 1;
	ppts[3] = pt->g_y;
	ppts[4] = pt->g_x + pt->g_w - 1;
	ppts[5] = pt->g_y + pt->g_h - 1;
	ppts[6] = pt->g_x;
	ppts[7] = pt->g_y + pt->g_h - 1;
	ppts[8] = pt->g_x;
	ppts[9] = pt->g_y;
}


VOID gsx_box(P(GRECT *) pt)
PP(GRECT *pt;)
{
	gsx_bxpts(pt);
	av_pline(5, &ptsin[0]);
}


VOID gsx_xbox(P(GRECT *)pt)
PP(GRECT *pt;)
{
	gsx_bxpts(pt);
#if AESVERSION < 0x140
	gsx_xline(5, &ptsin[0]);
#else
	gsx_xline(4, &ptsin[0]);
	ptsin[2] = ptsin[6];				/* fix the clipping problem of xbox */
	ptsin[3] = ptsin[7] - 1;
	gsx_xline(2, &ptsin[0]);
#endif
}


VOID gsx_xcbox(P(GRECT *)pt)
PP(GRECT *pt;)
{
	register int16_t wa, ha;
	register int16_t *ppts;

	ppts = &ptsin[0];

	wa = 2 * gl_wbox;
	ha = 2 * gl_hbox;
	ppts[0] = pt->g_x;
	ppts[1] = pt->g_y + ha;
	ppts[2] = pt->g_x;
	ppts[3] = pt->g_y;
	ppts[4] = pt->g_x + wa;
	ppts[5] = pt->g_y;
	gsx_xline(3, &ppts[0]);
	ppts[0] = pt->g_x + pt->g_w - wa;
	ppts[1] = pt->g_y;
	ppts[2] = pt->g_x + pt->g_w - 1;
	ppts[3] = pt->g_y;
	ppts[4] = pt->g_x + pt->g_w - 1;
	ppts[5] = pt->g_y + ha;
	gsx_xline(3, &ppts[0]);
	ppts[0] = pt->g_x + pt->g_w - 1;
	ppts[1] = pt->g_y + pt->g_h - ha;
	ppts[2] = pt->g_x + pt->g_w - 1;
	ppts[3] = pt->g_y + pt->g_h - 1;
	ppts[4] = pt->g_x + pt->g_w - wa;
	ppts[5] = pt->g_y + pt->g_h - 1;
	ppts[5] = ppts[3];
	gsx_xline(3, &ppts[0]);
	ppts[0] = pt->g_x + wa;
	ppts[1] = pt->g_y + pt->g_h - 1;
	ppts[2] = pt->g_x;
	ppts[3] = pt->g_y + pt->g_h - 1;
	ppts[4] = pt->g_x;
	ppts[5] = pt->g_y + pt->g_h - ha;
	gsx_xline(3, &ppts[0]);
}



VOID gsx_fix(P(FDB *) pfd, P(int16_t *) theaddr, P(int16_t) wb, P(int16_t) h)
PP(FDB *pfd;)
PP(int16_t *theaddr;)
PP(int16_t wb;)
PP(int16_t h;)
{
	if (theaddr == ORGADDR)
	{
		pfd->fd_w = gl_ws.ws_xres + 1;
		pfd->fd_wdwidth = pfd->fd_w / 16;
		pfd->fd_h = gl_ws.ws_yres + 1;
		pfd->fd_nplanes = gl_nplanes;
	} else
	{
		pfd->fd_wdwidth = wb / 2;
		pfd->fd_w = wb * 8;
		pfd->fd_h = h;
		pfd->fd_nplanes = 1;
	}
	pfd->fd_stand = FALSE;
	pfd->fd_addr = theaddr;
}


VOID gsx_blt(P(int16_t *) saddr, P(uint16_t) sx, P(uint16_t) sy, P(uint16_t) swb, P(int16_t *) daddr, P(uint16_t) dx, P(uint16_t) dy, P(uint16_t) dwb, P(uint16_t) w, P(uint16_t) h, P(uint16_t) rule, P(int16_t) fgcolor, P(int16_t) bgcolor)
PP(int16_t *saddr;)
PP(register uint16_t sx;)
PP(register uint16_t sy;)
PP(register uint16_t swb;)
PP(int16_t *daddr;)
PP(register uint16_t dx;)
PP(register uint16_t dy;)
PP(uint16_t dwb;)
PP(uint16_t w;)
PP(uint16_t h;)
PP(uint16_t rule;)
PP(int16_t fgcolor;)
PP(int16_t bgcolor;)
{
	register int16_t *ppts;

	ppts = &ptsin[0];

	gsx_fix(&gl_src, saddr, swb, h);
	gsx_fix(&gl_dst, daddr, dwb, h);

	gsx_moff();
	ppts[0] = sx;
	ppts[1] = sy;
	ppts[2] = sx + w - 1;
	ppts[3] = sy + h - 1;
	ppts[4] = dx;
	ppts[5] = dy;
	ppts[6] = dx + w - 1;
	ppts[7] = dy + h - 1;
	if (fgcolor == -1)
		avro_cpyfm(rule, &ppts[0], &gl_src, &gl_dst);
	else
		avrt_cpyfm(rule, &ppts[0], &gl_src, &gl_dst, fgcolor, bgcolor);
	gsx_mon();
}


VOID bb_screen(P(int16_t) scrule, P(int16_t) scsx, P(int16_t) scsy, P(int16_t) scdx, P(int16_t) scdy, P(int16_t) scw, P(int16_t) sch)
PP(int16_t scrule;)
PP(int16_t scsx;)
PP(int16_t scsy;)
PP(int16_t scdx;)
PP(int16_t scdy;)
PP(int16_t scw;)
PP(int16_t sch;)
{
	gsx_blt(ORGADDR, scsx, scsy, 0, ORGADDR, scdx, scdy, 0, scw, sch, scrule, -1, -1);
}


VOID gsx_trans(P(int16_t *) saddr, P(uint16_t) swb, P(int16_t *) daddr, P(uint16_t) dwb, P(uint16_t) h, P(int16_t) fg, P(int16_t) bg)
PP(int16_t *saddr;)
PP(uint16_t swb;)
PP(int16_t *daddr;)
PP(uint16_t dwb;)
PP(uint16_t h;)
PP(int16_t fg;)
PP(int16_t bg;)
{
	gsx_fix(&gl_dst, daddr, dwb, h);

	gsx_fix(&gl_src, saddr, swb, h);
	gl_src.fd_stand = TRUE;
	gl_src.fd_nplanes = 1;
	avr_trnfm(&gl_src, &gl_dst);
}


VOID gsx_start(NOTHING)
{
	int16_t dummy;
	register int i;

	/* force update */
	gl_mode = gl_mask = gl_tcolor = gl_lcolor = -1;
	gl_fis = gl_patt = gl_font = -1;
	gl_xclip = 0;
	gl_yclip = 0;
	gl_width = gl_wclip = gl_ws.ws_xres + 1;
	gl_height = gl_hclip = gl_ws.ws_yres + 1;

	i = gl_ws.ws_ncolors;
	gl_nplanes = 0;
	while (i != 1)
	{
		i >>= 1;
		gl_nplanes += 1;
	}
#if 0
	intin[0] = 1;
	gsx_ncode(EXTENDED_INQUIRE, 0, 1); /* vq_extnd(1) */
	gl_nplanes = intout[4];
#endif

	/* The driver may have more than two fonts.  The large font */
	/* to the services is the default font in the driver.  This */
	/* font will give us 80 chars across the screen in all but  */
	/* 320 pels in x, when it will be the 40 column font.       */

	gsx_ncode(VQT_ATTRIBUTES, 0, 0);				/* inquire text attributes vqt_attributes  */
	gl_wptschar = ptsout[0];
	gl_ws.ws_chmaxh = gl_hptschar = ptsout[1];
	gl_wchar = ptsout[2];
	gl_hchar = ptsout[3];

	avst_height(gl_ws.ws_chminh, &gl_wsptschar, &gl_hsptschar, &gl_wschar, &gl_hschar);

	avst_height(gl_ws.ws_chmaxh, &dummy, &dummy, &dummy, &dummy);

	gl_ncols = gl_width / gl_wchar;
	gl_nrows = gl_height / gl_hchar;
	gl_hbox = gl_hchar + 3;
	gl_wbox = (gl_hbox * gl_ws.ws_hpixel) / gl_ws.ws_wpixel;
	/*   7/26/89    */
	if (gl_wbox < (gl_wchar + 2))
		gl_wbox = gl_wchar + 2;
	vsl_type(7);
	avsl_width(1);
	vsl_udsty(0xffff);
	r_set(&gl_rscreen, 0, 0, gl_width, gl_height);
	r_set(&gl_rfull, 0, gl_hbox, gl_width, (gl_height - gl_hbox));
	r_set(&gl_rzero, 0, 0, 0, 0);
	r_set(&gl_rcenter, (gl_width - gl_wbox) / 2, (gl_height - (2 * gl_hbox)) / 2, gl_wbox, gl_hbox);
	r_set(&gl_rmenu, 0, 0, gl_width, gl_hbox);
	ad_intin = ADDR(&intin[0]);
}


VOID bb_fill(P(int16_t) mode, P(int16_t) fis, P(int16_t) patt, P(int16_t) hx, P(int16_t) hy, P(int16_t) hw, P(int16_t) hh)
PP(int16_t mode;)
PP(int16_t fis;)
PP(int16_t patt;)
PP(int16_t hx;)
PP(int16_t hy;)
PP(int16_t hw;)
PP(int16_t hh;)
{
	register int16_t *ppts;

	ppts = &ptsin[0];

	gsx_fix(&gl_dst, 0x0L, 0, 0);
	ppts[0] = hx;
	ppts[1] = hy;
	ppts[2] = hx + hw - 1;
	ppts[3] = hy + hh - 1;

	gsx_attr(TRUE, mode, gl_tcolor);
	if (fis != gl_fis)
	{
		vsf_interior(fis);
		gl_fis = fis;
	}
	if (patt != gl_patt)
	{
		vsf_style(patt);
		gl_patt = patt;
	}
	avr_recfl(&ppts[0], &gl_dst);
}




uint16_t ch_width(P(int16_t) fn)
PP(register int16_t fn;)
{
	if (fn == IBM)
		return gl_wchar;
	if (fn == SMALL)
		return gl_wschar;
	return 0;
}



uint16_t ch_height(P(int16_t) fn)
PP(register int16_t fn;)
{
	if (fn == IBM)
		return gl_hchar;
	if (fn == SMALL)
		return gl_hschar;
	return 0;
}


/*
 *  call:
 *
 *	gsx_tcalc(font, ptext, ptextw, ptexth, pnumchs)
 *
 *   Calculate the minimum bounding rectangle:
 *
 *   ptextw < wc * pnumchs
 *   ptexth < hc
 *
 *	ptextw  =  ptextw			(unchanged)
 *	ptexth  =  ptexth			(unchanged)
 *       pnumchs =  0
 *
 *   ptextw > wc * pnumchs
 *   ptexth < hc
 *
 *	ptextw  =  wc * number of characters
 *	ptexth  =  ptexth			(unchanged)
 *       pnumchs =  0
 *
 *   ptextw < wc * pnumchs
 *   ptexth > hc
 *
 *	ptextw  =  ptextw			(unchanged)
 *	ptexth  =  hc
 *       pnumchs =  ptextw / wc
 *
 *   ptextw > wc * pnumchs
 *   ptexth > hc
 *
 *	ptextw  =  wc * number of characters
 *	ptexth  =  hc
 *       pnumchs =  number of characters
 */
VOID gsx_tcalc(P(int16_t) font, P(const char *) ptext, P(int16_t *) ptextw, P(int16_t *) ptexth, P(int16_t *) pnumchs)
PP(register int16_t font;)
PP(const char *ptext;)
PP(register int16_t *ptextw;)
PP(register int16_t *ptexth;)
PP(register int16_t *pnumchs;)
{
	register int16_t wc;
	register int16_t hc;

	wc = ch_width(font);
	hc = ch_height(font);
	/* figure out the width of the text string in pixels   */

	*pnumchs = LBWMOV(ad_intin, ptext);
	*ptextw = min(*ptextw, *pnumchs * wc);
	/* figure out the height of the text */
	*ptexth = min(*ptexth, hc);
	if (*ptexth / hc)
		*pnumchs = min(*pnumchs, *ptextw / wc);
	else
		*pnumchs = 0;
}


VOID gsx_tblt(P(int16_t) tb_f, P(int16_t) x, P(int16_t) y, P(int16_t) tb_nc)
PP(register int16_t tb_f;)
PP(register int16_t x;)
PP(register int16_t y;)
PP(int16_t tb_nc;)
{
	int16_t i;
	register int16_t pts_height;

	if (tb_f == IBM)
	{
		if (tb_f != gl_font)
		{
			avst_height(gl_ws.ws_chmaxh, &gl_wptschar, &gl_hptschar, &gl_wchar, &gl_hchar);
			gl_font = tb_f;
		}
		y += gl_hptschar;
	}

	if (tb_f == SMALL)
	{
		if (tb_f != gl_font)
		{
			avst_height(gl_ws.ws_chminh, &gl_wsptschar, &gl_hsptschar, &gl_wschar, &gl_hschar);
			gl_font = tb_f;
		}
		y += gl_hsptschar;
	}

	contrl[0] = 8;						/* TEXT */
	contrl[1] = 1;
	contrl[6] = gl_handle;
	ptsin[0] = x;
	ptsin[1] = y;
	contrl[3] = tb_nc;
	gsx2();
}



VOID gsx_xline(P(int16_t) ptscount, P(int16_t *) ppoints)
PP(int16_t ptscount;)
PP(register int16_t *ppoints;)
{
	static int16_t const hztltbl[2] = { 0x5555, 0xaaaa };
	static int16_t const verttbl[4] = { 0x5555, 0xaaaa, 0xaaaa, 0x5555 };
	register int16_t *linexy;
	register int16_t st, i;

	for (i = 1; i < ptscount; i++)
	{
		if (*ppoints == *(ppoints + 2))
		{
			st = verttbl[(((*ppoints) & 1) | ((*(ppoints + 1) & 1) << 1))];
		} else
		{
			linexy = (*ppoints < *(ppoints + 2)) ? ppoints : ppoints + 2;
			st = hztltbl[(*(linexy + 1) & 1)];
		}
		vsl_udsty(st);
		av_pline(2, ppoints);
		ppoints += 2;
	}
	vsl_udsty(0xffff);
}
