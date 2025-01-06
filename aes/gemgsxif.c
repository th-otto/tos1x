/*************************************************************************
 *			Revision Control System
 * =======================================================================
 *  $Author: mui $	$Date: 89/04/26 18:23:50 $
 * =======================================================================
 *
 * Revision 2.2  89/04/26  18:23:50  mui
 * TT
 * 
 * Revision 2.1  89/02/22  05:27:16  kbad
 * *** TOS 1.4  FINAL RELEASE VERSION ***
 * 
 * Revision 1.2  88/10/24  10:34:08  mui
 * move gsx_malloc to geminit.c
 * 
 * Revision 1.1  88/06/02  12:34:09  lozben
 * Initial revision
 * 
 *************************************************************************
 *	Translated by J.Eisenstein	1/19/87
 *	Fix	1/21/87			Derek Mui, J.Eisenstein
 *	Fix at gsx_mret	4/28/1988	D.Mui	
 *	Remove gsx_mfset	5/8/91	D.Mui
 *	Add gsx_wsopen for six resolutions 4/25/89	D.Mui
 * 	Assemble with MAS 900801 kbad
 *	Check for sparrow resolution at gsx_wsopen	7/19/92	D.Mui	
 */
/*	GEMGSXIF.C	05/06/84 - 02/17/85	Lee Lorenzen		*/
/*	68k		02/20/85 - 03/25/85	Lowell Webster		*/
/*	Reg Opt		03/09/85		Derek Mui		*/
/*	speed bee	05/14/85		jim eisenstein		*/
/*	Comment something out	07/11/85	Derek Mui		*/
/*	6 resolutions	1/30/86			Derek Mui		*/
/*	At gsx_wsopen, at gsx_malloc					*/
/*	Store mouse addr at gsx_mfset	2/28/86	Derek Mui		*/
/*	New flag to tell if the mouse is really on 3/3/86	D.Mui	*/
/*	Take out save mouse address		1/7/87	Derek Mui	*/

/*
 *	-------------------------------------------------------------
 *	GEM Application Environment Services		  Version 1.1
 *	Serial No.  XXXX-0000-654321		  All Rights Reserved
 *	Copyright (C) 1985			Digital Research Inc.
 *	-------------------------------------------------------------
 */

#include "aes.h"
#include "gemlib.h"
#include "gsxdefs.h"

/*
 *	Calls used in Crystal:
 *
 *	vsf_interior();
 *	vr_recfl();
 *	vst_height(); 
 *	vsl_type();
 *	vsl_udsty();
 *	vsl_width();
 *	v_pline();
 *	vst_clip();
 *	vex_butv();
 *	vex_motv();
 *	vex_curv();
 *	vex_timv();
 *	vr_cpyfm();
 *	v_opnwk();
 *	v_clswk();
 *	vq_extnd();
 *	v_clsvwk( handle )
 *	v_opnvwk( pwork_in, phandle, pwork_out )
 */


VOID gsx_mfree(NOTHING)
{
	dos_free(gl_tmp.fd_addr);
}



VOID gsx_mret(P(VOIDPTR *)pmaddr, P(int32_t *)pmlen)
PP(VOIDPTR *pmaddr;)
PP(int32_t *pmlen;)
{
	*pmaddr = gl_tmp.fd_addr;
	*pmlen = gl_mlen;
}



VOID gsx_ncode(P(int16_t) code, P(int16_t) n, P(int16_t) m)
PP(int16_t code;)
PP(int16_t n;)
PP(int16_t m;)
{
	register int16_t *pctrl;

	pctrl = &contrl[0];

	pctrl[0] = code;
	pctrl[1] = n;
	pctrl[3] = m;
	pctrl[6] = gl_handle;
	gsx2();
}



VOID gsx_1code(P(int16_t) code, P(int16_t) value)
PP(int16_t code;)
PP(int16_t value;)
{
	intin[0] = value;
	gsx_ncode(code, 0, 1);
}


extern VOID far_bchange PROTO((NOTHING));
extern VOID far_mchange PROTO((NOTHING));

VOID gsx_init(NOTHING)
{
	gsx_wsopen();
	gsx_start();
	gsx_setmb(far_bchange, far_mchange, &drwaddr);
	gsx_ncode(MOUSE_ST, 0, 0);
	xrat = ptsout[0];
	yrat = ptsout[1];
}



VOID gsx_graphic(P(BOOLEAN) tographic)
PP(BOOLEAN tographic;)
{
	if (gl_graphic != tographic)
	{
		gl_graphic = tographic;
		if (gl_graphic)
		{
			gsx_escapes(2);
			gsx_setmb(far_bchange, far_mchange, &drwaddr);
		} else
		{
			gsx_escapes(3);
			gsx_resetmb();
		}
	}
}



VOID av_hardcopy(NOTHING)
{
	gsx_escapes(17);
}


VOID gsx_escapes(P(int16_t) esc_code)
PP(int16_t esc_code;)
{
	contrl[5] = esc_code;
	gsx_ncode(GSX_ESCAPE, 0, 0);
}



/*****	 Open physical work station for 6 resolutions	*****/
VOID gsx_wsopen(NOTHING)
{
	register int i;
	
	for (i = 0; i < 10; i++)
		intin[i] = 1;
	intin[10] = 2;
	intin[0] = gl_restype;
	av_opnwk(intin, &gl_handle, &gl_ws);
	if (gl_ws.ws_xres == 320 - 1)
		gl_restype = 2;
	else if (gl_ws.ws_yres == 400 - 1)
		gl_restype = 4;
	else
		gl_restype = 3;
	gl_rschange	= FALSE;
	gl_graphic = TRUE;
}



VOID gsx_wsclose(NOTHING)
{
	gsx_ncode(CLOSE_WORKSTATION, 0, 0);
}



VOID ratinit(NOTHING)
{
	gsx_1code(SHOW_CUR, 0);
	gl_moff = 0;
}


VOID bb_set(P(int16_t) sx, P(int16_t) sy, P(int16_t) sw, P(int16_t) sh, P(int16_t *) pts1, P(int16_t *) pts2, P(FDB *) pfd, P(FDB *) psrc, P(FDB *) pdst)
PP(int16_t sx;)
PP(int16_t sy;)
PP(int16_t sw;)
PP(int16_t sh;)
PP(int16_t *pts1;)
PP(int16_t *pts2;)
PP(FDB *pfd;)
PP(FDB *psrc;)
PP(FDB *pdst;)
{
	int16_t oldsx;

	/* get on word boundary */
	oldsx = sx;
	sx = (sx / 16) * 16;
	sw = (((oldsx - sx) + (sw + 15)) / 16) * 16;

	gl_tmp.fd_stand = TRUE;
	gl_tmp.fd_wdwidth = sw / 16;
	gl_tmp.fd_w = sw;
	gl_tmp.fd_h = sh;

	gsx_moff();
	pts1[0] = sx;
	pts1[1] = sy;
	pts1[2] = sx + sw - 1;
	pts1[3] = sy + sh - 1;
	pts2[0] = 0;
	pts2[1] = 0;
	pts2[2] = sw - 1;
	pts2[3] = sh - 1;

	gsx_fix(pfd, NULL, 0, 0);
	avro_cpyfm(S_ONLY, &ptsin[0], psrc, pdst);
	gsx_mon();
}



VOID bb_save(P(GRECT *) ps)
PP(GRECT *ps;)
{
	bb_set(ps->g_x, ps->g_y, ps->g_w, ps->g_h, &ptsin[0], &ptsin[4], &gl_src, &gl_src, &gl_tmp);
}


VOID bb_restore(P(GRECT *)ps)
PP(GRECT *ps;)
{
	bb_set(ps->g_x, ps->g_y, ps->g_w, ps->g_h, &ptsin[0], &ptsin[4], &gl_dst, &gl_tmp, &gl_dst);
}


extern VOIDPTR old_bcode;
extern VOIDPTR old_mcode;

int16_t gsx_setmb(P(VOIDPTR) boff, P(VOIDPTR) moff, P(VOIDPTR *) pdrwaddr)
PP(VOIDPTR boff;)
PP(VOIDPTR moff;)
PP(VOIDPTR *pdrwaddr;)
{
	i_ptr(boff, 0x0);
	gsx_ncode(BUT_VECX, 0, 0);
	m_lptr2(&old_bcode);

	i_ptr(moff, 0x0);
	gsx_ncode(MOT_VECX, 0, 0);
	m_lptr2(&old_mcode);

/*	i_ptr(justretf, 0x0);	
	gsx_ncode(CUR_VECX, 0, 0);
	m_lptr2( pdrwaddr );		don't intercept draw vector */
}


VOID gsx_resetmb(NOTHING)
{
	i_ptr(old_bcode);
	gsx_ncode(BUT_VECX, 0, 0);

	i_ptr(old_mcode);
	gsx_ncode(MOT_VECX, 0, 0);

/*	i_ptr(drwaddr);	
	gsx_ncode(CUR_VECX, 0, 0);     dont' replace cursor draw vector */
}



int16_t gsx_tick(P(intptr_t) tcode, P(intptr_t *) ptsave)
PP(intptr_t tcode;)
PP(intptr_t *ptsave;)
{
	i_ptr(tcode);
	gsx_ncode(TIM_VECX, 0, 0);
	m_lptr2(ptsave);
	return intout[0];
}


VOID gsx_mfset(P(MFORM *) pmfnew)
PP(MFORM *pmfnew;)
{
	gsx_moff();
	LWCOPY(ad_intin, pmfnew, sizeof(MFORM) / 2);
	gsx_ncode(ST_CUR_FORM, 0, sizeof(MFORM) / 2);
	gsx_mon();
}


VOID gsx_mxmy(P(int16_t *) pmx, P(int16_t *) pmy)
PP(int16_t *pmx;)
PP(int16_t *pmy;)
{
	*pmx = xrat;
	*pmy = yrat;
}



int16_t gsx_button(NOTHING)
{
	return button;
}



VOID ratexit(NOTHING)
{
	gsx_moff();
}


VOID gsx_moff(NOTHING)
{
	if (!gl_moff)
	{
		gsx_ncode(HIDE_CUR, 0, 0);
		gl_mouse = FALSE;
	}

	gl_moff++;
}



VOID gsx_mon(NOTHING)
{
	gl_moff--;
	if (!gl_moff)
	{
		gsx_1code(SHOW_CUR, 1);
		gl_mouse = TRUE;
	}
}


#if 0
/* unused */
int16_t gsx_kstate(NOTHING)
{
	gsx_ncode(KEY_SHST, 0, 0);
	return intout[0];
}
#endif


#if 0
/* unused */
int16_t gsx_char(NOTHING)
{
	register int16_t *pintin;
	register int16_t *pintout;
	pintin = &intin[0];
	pintout = &intout[0];

	pintin[0] = 4;
	pintin[1] = 2;
	gsx_ncode(SET_INPUT_MODE, 0, 2);

	pintin[0] = -1;
	pintin[1] = FALSE;
	gsx_ncode(STRING_INPUT, FALSE, 2);
	if (contrl[4])
		return pintout[0];
	else
		return 0;
}
#endif


int16_t av_opnwk(P(int16_t *) pwork_in, P(int16_t *) phandle, P(int16_t *) pwork_out)
PP(int16_t *pwork_in;)
PP(int16_t *phandle;)
PP(int16_t *pwork_out;)
{
	register int16_t *ptsptr;

	ptsptr = pwork_out + 45;
	i_ptsout(ptsptr);					/* set ptsout to work_out array */
	i_intin(pwork_in);					/* set intin to point to callers data  */
	i_intout(pwork_out);				/* set intout to point to callers data */
	gsx_ncode(OPEN_WORKSTATION, 0, 11);

	*phandle = contrl[6];
	i_intin(intin);
	i_intout(intout);
	i_ptsin(ptsin);
	i_ptsout(ptsout);
}



VOID av_pline(P(int16_t) count, P(int16_t *) pxyarray)
PP(int16_t count;)
PP(int16_t *pxyarray;)
{
	i_ptsin(pxyarray);
	gsx_ncode(POLYLINE, count, 0);
	i_ptsin(ptsin);
}



VOID avst_clip(P(int16_t) clip_flag, P(int16_t) pxyarray)
PP(int16_t clip_flag;)
PP(int16_t pxyarray;)
{
	int16_t tmp, value;

	value = (clip_flag != 0) ? 2 : 0;
	i_ptsin(pxyarray);
	intin[0] = clip_flag;
	gsx_ncode(TEXT_CLIP, value, 1);
	i_ptsin(ptsin);
}



VOID avst_height(P(int16_t) height, P(int16_t *) pchr_width, P(int16_t *) pchr_height, P(int16_t *) pcell_width, P(int16_t *) pcell_height)
PP(int16_t height;)
PP(int16_t *pchr_width;)
PP(int16_t *pchr_height;)
PP(int16_t *pcell_width;)
PP(int16_t *pcell_height;)
{
	register int16_t *ppts;

	ppts = &ptsout[0];

	ptsin[0] = 0;
	ptsin[1] = height;
	gsx_ncode(CHAR_HEIGHT, 1, 0);
	*pchr_width = ppts[0];
	*pchr_height = ppts[1];
	*pcell_width = ppts[2];
	*pcell_height = ppts[3];
}


VOID avr_recfl(P(int16_t *) pxyarray, P(FDB *) pdesMFDB) /* ??? why MFDB ??? */
PP(int16_t *pxyarray;)
PP(FDB *pdesMFDB;)
{
	i_lptr1(pdesMFDB);
	i_ptsin(pxyarray);
	gsx_ncode(FILL_RECTANGLE, 2, 1);
	i_ptsin(ptsin);
}




VOID avro_cpyfm(P(int16_t) wr_mode, P(int16_t *) pxyarray, P(int16_t *) psrcMFDB, P(int16_t *) pdesMFDB)
PP(int16_t wr_mode;)
PP(int16_t *pxyarray;)
PP(int16_t *psrcMFDB;)
PP(int16_t *pdesMFDB;)
{
	intin[0] = wr_mode;
	i_lptr1(psrcMFDB);
	i_ptr2(pdesMFDB);
	i_ptsin(pxyarray);
	gsx_ncode(COPY_RASTER_FORM, 4, 1);
	i_ptsin(ptsin);
}



VOID avrt_cpyfm(P(int16_t) wr_mode, P(int16_t *) pxyarray, P(FDB *) psrcMFDB, P(FDB *) pdesMFDB, P(int16_t) fgcolor, P(int16_t) bgcolor)
PP(int16_t wr_mode;)
PP(int16_t *pxyarray;)
PP(FDB *psrcMFDB;)
PP(FDB *pdesMFDB;)
PP(int16_t fgcolor;)
PP(int16_t bgcolor;)
{
	register int16_t *pintin;

	pintin = &intin[0];

	pintin[0] = wr_mode;
	pintin[1] = fgcolor;
	pintin[2] = bgcolor;
	i_lptr1(psrcMFDB);
	i_ptr2(pdesMFDB);
	i_ptsin(pxyarray);
	gsx_ncode(TRAN_RASTER_FORM, 4, 3);
	i_ptsin(ptsin);
}



VOID avr_trnfm(P(FDB *) psrcMFDB, P(FDB *) pdesMFDB)
PP(FDB *psrcMFDB;)
PP(FDB *pdesMFDB;)
{
	i_lptr1(psrcMFDB);
	i_ptr2(pdesMFDB);
	gsx_ncode(TRANSFORM_FORM, 0, 0);
}



VOID avsl_width(P(int16_t) width)
PP(int16_t width;)
{
	ptsin[0] = width;
	ptsin[1] = 0;
	gsx_ncode(S_LINE_WIDTH, 1, 0);
}
