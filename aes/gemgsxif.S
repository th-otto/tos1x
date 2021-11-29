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

#define __ASSEMBLER__ 1

#include "config.h"
#include "aesdefs.h"
#include "asmdefs.h"

#if BINEXACT
#  ifdef __GNUC__
#    undef BINEXACT
#    define BINEXACT 0
#  endif
#endif

#define CCODE 0

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


	xdef	_gl_tmp
	comm	_gl_tmp,20
	xdef	old_mcode
	comm 	old_mcode,4
	xdef	old_bcode
	comm	old_bcode,4
	xdef	_gl_moff
	comm	_gl_moff,2
	xdef	_gl_mlen
	comm	_gl_mlen,4
	xdef	_gl_graphic
	comm	_gl_graphic,2
	xdef	_gl_mouse
	comm	_gl_mouse,2

#define iioff pblock+4
#define pioff pblock+8
#define iooff pblock+12
#define pooff pblock+16

GSX_MFS	equ	 0*3
V_OPNWK	equ	 1*3
VST_CLP	equ	 2*3
VST_HGT	equ	 3*3
VR_RECT	equ	 4*3
VRO_CPY	equ	 5*3
VRT_CPY	equ	 6*3
VSL_WID	equ	 7*3


#if 0
	xdef _gsx_malloc
_gsx_malloc:

	clr.l	-(sp)
	clr.l	-(sp)
	pea	_gl_tmp
	jsr	_gsx_fix

	move.l	#$00003400,_gl_mlen
	pea	 $3400
	jsr	_dos_alloc
	move.l	 d0,_gl_tmp

	lea	16(sp),sp		; clean up stack
	rts
#endif



#if CCODE
VOID gsx_mfree(NOTHING)
{
	if (gl_tmp.fd_addr)
		dos_free(gl_tmp.fd_addr);
}
#endif
/* 306de: 00e25064 */
/* 104de: 00fe1afc */
/* 404: 00e33f06 */
	xdef _gsx_mfree
_gsx_mfree:
#if (AESVERSION >= 0x330) | !BINEXACT
	tst.l	_gl_tmp			; Fix 8/3/92
	beq	g1
#endif
	move.l	_gl_tmp,-(sp)		; Fix 1/20/87
	jsr	_dos_free
	addq.l	#4,sp
g1:
	rts



#if CCODE
VOID gsx_mret(VOIDPTR *pmaddr, int32_t *pmlen)
{
	*pmaddr = gl_tmp.fd_addr;
	*pmlen = gl_mlen;
}
#endif
/* 306de: 00e25074 */
/* 104de: 00fe1b08 */
	xdef _gsx_mret
_gsx_mret:

	move.l	4(sp),a0
	move.l	_gl_tmp,(a0)
	move.l  8(sp),a0
	move.l _gl_mlen,(a0)
	rts



#if CCODE
VOID gsx_ncode(WORD code, WORD n, WORD m)
{
	REG WORD *pctrl;

	pctrl = &contrl[0];

	pctrl[0] = code;
	pctrl[1] = n;
	pctrl[3] = m;
	pctrl[6] = gl_handle;
	gsx2();
}
#endif
/* 306de: 00e2508a */
/* 104de: 00fe1b1e */
/* 404: 00e33f34 */
	xdef _gsx_ncode
_gsx_ncode: ds.b 0
#if LINEF_HACK
	xdef _gsx_acode
_gsx_acode: ds.b 0
#endif

	lea	4(sp),a0
	lea	_contrl,a1

	move.l	(a0)+,(a1)+
	addq.l	#2,a1
	move.w	(a0)+,(a1)
	addq.l	#6,a1
	move.w	_gl_handle,(a1)

	jmp	_gsx2



#if CCODE
VOID gsx_1code(WORD code, WORD value)
{
	intin[0] = value;
	gsx_ncode(code, 0, 1);
}
#endif
/* 306de: 00e250a8 */
/* 104de: 00fe1b3c */
	xdef _gsx_1code
_gsx_1code: ds.b 0
#if LINEF_HACK
	xdef _gsx_1acode
_gsx_1acode: ds.b 0
#endif

	move.w  6(sp),_intin

	move.l	#$00000001,-(sp)	; Fix 1/20/87
	move.w	4+4(sp),-(sp)
	bsr	_gsx_ncode

	addq.l	#6,sp
	rts



#if CCODE
VOID gsx_init(NOTHING)
{
	gsx_wsopen();
	gsx_start();
	gsx_setmb(far_bchange, far_mchange, &drwaddr);
	gsx_ncode(MOUSE_ST, 0, 0);
	xrat = ptsout[0];
	yrat = ptsout[1];
}
#endif
/* 306de: 00e250c0 */
/* 104de: 00fe1b54 */
	xdef _gsx_init
_gsx_init:

	bsr	_gsx_wsopen
	jsr	_gsx_start
	bsr	setmb

	moveq.l	#124,d0			; code 124 => vq_mouse
	bsr	vdi_short

	lea	_ptsout,a0
	move.w	(a0)+,_xrat
	move.w  (a0)+,_yrat

	rts




#if CCODE
VOID gsx_graphic(BOOLEAN tographic)
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
#endif
/* 306de: 00e250e4 */
/* 104de: 00fe1b74 */
	xdef _gsx_graphic
_gsx_graphic:

	move.w	4(sp),d0
	lea	_gl_graphic,a1
	cmp.w	(a1),d0
	beq	L8

	move.w	d0,(a1)
	beq	L9

	moveq.l #2,d0
	bsr	escape

setmb:	pea	_drwaddr
	pea	_far_mchange
	pea	_far_bchange
	bsr	_gsx_setmb
	lea	12(sp),sp

L8:	rts


L9:	moveq.l	#3,d0
	bsr	escape
	bra	_gsx_resetmb




#if CCODE
VOID av_hardcopy(NOTHING)
{
	gsx_escapes(17);
}
#endif
/* 306de: 00e2511e */
/* 104de: 00fe1bae */
	xdef _av_hardcopy
_av_hardcopy:
	moveq.l	#17,d0
	bra	escape




#if CCODE
VOID gsx_escapes(WORD esc_code)
{
	contrl[5] = esc_code;
	gsx_ncode(GSX_ESCAPE, 0, 0);
}
#endif
	xdef _gsx_escapes
_gsx_escapes:

	move.w	4(sp),d0

escape:	move.w	d0,_contrl+10
	moveq.l	#5,d0			; code 5 => escape
	bra	vdi_short



*****	 Open physical work station for 6 resolutions	*****
/* 306de: 00e25132 */
/* 104de: 00fe1bc2 */
/* 404: 00e33fdc */
	xdef _gsx_wsopen
_gsx_wsopen:

	lea	_intin,a1
	move.l	a1,a2			; a2 -> intin[0]

	moveq.l	#9,d0

L15:	move.w	#1,(a1)+
	dbra	d0,L15

	move.w	#2,(a1)			; intin[10] <- 2

	lea	restable,a0		; look for the driver handle 
	lea	restype,a1		; load in res table
L209:
	move.w	(a1)+,d0
	tst.w	(a0)+
	cmp.w	_gl_restype,d0
	bne	L209

	move.w	-(a0),(a2)		; intin[0] <- screen handle

	pea	_gl_ws
	pea	_gl_handle
	pea	(a2)
			
/* Check for sparrow machine */
		
#if TOSVERSION >= 0x400
	jsr	_setres			; check mode code
#endif

	bsr	_av_opnwk
	lea	12(sp),sp

	lea	_gl_ws,a1
	lea	_gl_restype,a2

L20:	
	move.w	#5,(a2)		; default to 1280 x 960 
	
	cmp.w	#639,(a1)	; check for x = 640 ?
	bne	L18
	tst.w	(a1)+
	cmp.w	#199,(a1)	; 640 x 200
	bne	L20_1
	move.w	#2,(a2)
	bra	L22
	
L20_1:	cmp.w	#399,(a1)	; 640 x 400
	bne	L20_2
	move.w	#3,(a2)
	bra	L22
	
L20_2:	move.w	#4,(a2)		; 640 x 480
	bra	L22	

L18:	cmp.w	#319,(a1)+	; check for x = 320 ?
	bne	L22	
	cmp.w	#199,(a1)	; check for y = 200 ?
	bne	L18_1
	move.w	#1,(a2)		; Yes		 
	bra	L22

L18_1:	move.w	#6,(a2)		; No it is 320 x 480

L22:	clr.w	_gl_rschange	; gl_rschange  <- FALSE
	move.w	#1,_gl_graphic	; gl_graphic   <- TRUE
	rts



#if CCODE
VOID gsx_wsclose(NOTHING)
{
	gsx_ncode(CLOSE_WORKSTATION, 0, 0);
}
#endif
/* 306de: 00e251d4 */
/* 104de: 00fe1c2a */
	xdef _gsx_wsclose
_gsx_wsclose:

	moveq.l	#2,d0			; code 2 => v_clswk
	bra	vdi_short



#if CCODE
VOID ratinit(NOTHING)
{
	gsx_1code(SHOW_CUR, 0);
	gl_moff = 0;
}
#endif
/* 104de: 00fe1c30 */
	xdef _ratinit
_ratinit:

	clr.w	     -(sp)
	move.w	#122,-(sp)		; show cursor: force show
	bsr	_gsx_1code
	addq.l	#4,sp

	clr.w	_gl_moff
	rts


#if CCODE
VOID bb_set(WORD sx, WORD sy, WORD sw, WORD sh, WORD *pts1, WORD *pts2, FDB *pfd, FDB *psrc, FDB *pdst)
{
	WORD oldsx;

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
#endif
/* 104de: 00fe1c44 */
	xdef _bb_set
_bb_set:

	lea	4(sp),a0		; a0 -> stack resident parameters

	move.w	(a0)+,d0		; d0[15:00] <- sx  (XminSRC)
	move.l	(a0)+,d1		; d1[31:16] <- sy  (YminSRC)
*					; d1[15:00] <- sw  (width)
	move.w	(a0)+,d2		; d2[15:00] <- sh  (height)

	add.w	d0,d1			; d1 <- sx + sw = XmaxSRC + 1
	subq.w	#1,d1			; d1 <- XmaxSRC

	lsr.w	#4,d0			; d0 <- XminSRC/16
	lsr.w	#4,d1			; d1 <- XmaxSRC/16
	sub.w	d0,d1			; d1 <- width-1	(in words)
	addq.w	#1,d1			; d1 <- width   (in words)

	lea	_gl_tmp+10,a1		; a1 -> gl_tmp.fd_stand

	move.w	#1,(a1)			; gl_tmp.fd_stand   <- TRUE
	move.w	d1,-(a1)		; gl_tmp.fd_wdwidth <- width in words
	move.w	d2,-(a1)		; gl_tmp.fd_h       <- height in pixels
	lsl.w	#4,d1
	move.w	d1,-(a1)		; gl_tmp.fd_w       <- width in pixels
	
	move.l	(a0)+,a1		; a1 -> pts1 array
	move.l	(a0)+,a2		; a2 -> pts2 array

	clr.l	(a2)+			; pts2[0] <- XminDST=0
*					; pts2[1] <- YminDST=0
	subq.w	#1,d1			; d1      <- width - 1
	move.w	d1,(a2)+		; pts2[2] <- XmaxDST
	subq.w	#1,d2			; d2      <- height -1
	move.w	d2,(a2)+		; pts2[3] <- YmaxDST

	lsl.w	#4,d0			; d0      <- XminSRC/16 *16
	move.w	d0,(a1)+		; pts1[0] <- XminSRC on word boundry
	add.w	d0,d1			; d1      <- XminSRC + width - 1
	move.l	d1,(a1)+		; pts1[1] <- YminSRC:  d1[31:16]
*					; pts1[2] <- XmaxSRC:  d1[15:00]
	swap	d1			; d1      <- YminSRC
	add.w	d1,d2			; d2      <- YminSRC + height -1
	move.w	d2,(a1)+		; pts1[3] <- YmaxSRC

	clr.l	      -(sp)		; gsx_fix(pfd, 0, 0, 0, 0)
	clr.l	      -(sp)
	move.l	(a0)+,-(sp)		; pfd -> space for MFDB
	jsr	_gsx_fix		; build MFDB

	bsr	_gsx_moff		; hide mouse cursor

	lea	12+28(sp),a0		; a0 -> pdst pointer
	move.l	 (a0),-(sp)		; push *pdst
	move.l	-(a0),-(sp)		; push *psrc
	pea	_ptsin			; push *ptsin
	move.w	#3,-(sp)		; replace mode (S_ONLY)
	bsr	_avro_cpyfm

	lea	26(sp),sp		; clean the stack up from earlier calls

	bra	_gsx_mon		; show mouse cursor (RETURN from there)




#if CCODE
VOID bb_save(GRECT *ps)
{
	bb_set(ps->g_x, ps->g_y, ps->g_w, ps->g_h, &ptsin[0], &ptsin[4], &gl_src, &gl_src, &gl_tmp);
}
#endif
/* 306de: 00e25260 */
/* 104de: 00fe1cb2 */
	xdef _bb_save
_bb_save:

	pea	_gl_tmp
	lea	_gl_src,a1
	pea	 (a1)
	pea	 (a1)
	pea	_ptsin+8
	pea	_ptsin+0

	move.l	4+20(sp),a0		; a0 -> ps.g_w
	move.l	4(a0),-(sp)		; width and height
	move.l	 (a0),-(sp)		; Xmin  and Ymin
	bsr	_bb_set

	lea	28(sp),sp
	rts



/* 306de: 00e25290 */
/* 104de: 00fe1ce2 */
	xdef _bb_restore
_bb_restore:

	lea	_gl_dst,a1
	pea	 (a1)
	pea	_gl_tmp
	pea	 (a1)
	pea	_ptsin+0
	pea	_ptsin+8

	move.l	4+20(sp),a0		; a0 -> ps.g_w
	move.l	4(a0),-(sp)		; ps.g_w and ps.g_h
	move.l	 (a0),-(sp)		; ps.g_x and ps.g_y
	bsr	_bb_set

	lea	28(sp),sp
	rts




#if CCODE
WORD gsx_setmb(UWORD *boff, UWORD *moff, VOIDPTR *pdrwaddr)
{
	i_lptr1(boff, 0x0);
	gsx_ncode(BUT_VECX, 0, 0);
	m_lptr2(&old_bcode);

	i_lptr1(moff, 0x0);
	gsx_ncode(MOT_VECX, 0, 0);
	m_lptr2(&old_mcode);

/*	i_lptr1( justretf, 0x0 );	
	gsx_ncode(CUR_VECX, 0, 0);
	m_lptr2( pdrwaddr );		don't intercept draw vector */
}
#endif
/* 306de: 00e252c0 */
/* 104de: 00fe1d12 */
	xdef _gsx_setmb
_gsx_setmb:

	move.l	4(sp),_contrl+14	; contrl[7-8] <- new button vector
	moveq.l	#125,d0
	bsr	vdi_short
	move.l	_contrl+18,old_bcode

	move.l	8(sp),_contrl+14	; contrl[7-8] <- new motion vector
	moveq.l	#126,d0
	bsr	vdi_short
	move.l	_contrl+18,old_mcode

	rts



#if CCODE
VOID gsx_resetmb(NOTHING)
{
	i_lptr1(old_bcode);
	gsx_ncode(BUT_VECX, 0, 0);

	i_lptr1(old_mcode);
	gsx_ncode(MOT_VECX, 0, 0);

/*	i_lptr1( drwaddr );	
	gsx_ncode(CUR_VECX, 0, 0);     dont' replace cursor draw vector */
}
#endif
/* 104de: 00fe1d44 */
	xdef _gsx_resetmb
_gsx_resetmb:

	move.l	old_bcode,_contrl+14		; reset button vector
	moveq.l	#125,d0
	bsr	vdi_short
	move.l	old_mcode,_contrl+14		; reset motion vector
	moveq.l	#126,d0
	bra	vdi_short



#if CCODE
WORD gsx_tick(intptr_t tcode, intptr_t *ptsave)
{
	i_lptr1(tcode);
	gsx_ncode(TIM_VECX, 0, 0);
	m_lptr2(ptsave);
	return (intout[0]);
}
#endif
/* 306de: 00e25312 */
/* 104de: 00fe1d64 */
	xdef _gsx_tick
_gsx_tick:

	move.l	4(sp),_contrl+14

	moveq.l	#118,d0			; code 118 => vex_timv
	bsr	vdi_short

	move.l	8(sp),a0
	move.l	_contrl+18,(a0)

	move.w	_intout,d0
	rts


#if AESVERSION < 0x200
/* 104de: 00fe1d84 */
	xdef _gsx_mfset
_gsx_mfset:
	bsr.s     ig_moff
	moveq.l   #37-1,d0
	movea.l   4(a7),a0
	movea.l   _ad_intin,a1
gsx_mf1:
	move.w    (a0)+,(a1)+
	dbf       d0,gsx_mf1
	moveq.l   #0,d0
	bsr       vdi_call
	bra       _gsx_mon
#endif


#if CCODE
VOID gsx_mxmy(WORD *pmx, WORD *pmy)
{
	*pmx = xrat;
	*pmy = yrat;
}
#endif
/* 306de: 00e25332 */
/* 104de: 00fe1da0 */
	xdef _gsx_mxmy
_gsx_mxmy: ds.b 0
#if LINEF_HACK
	xdef _gsx_fmxmy
_gsx_fmxmy: ds.b 0
#endif

	lea	4(sp),a0
	move.l	(a0)+,a1
	move.w	_xrat,(a1)
	move.l	(a0)+,a1
	move.w	_yrat,(a1)
	rts



#if CCODE
WORD gsx_button(NOTHING)
{
	return button;
}
#endif
	xdef _gsx_button
_gsx_button:

	move.w	_button,d0
	rts



#if CCODE
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
#endif
/* 306de: 00e25350 */
/* 104de: 00fe1dbe */
	xdef _gsx_moff
	xdef _ratexit
_ratexit:
_gsx_moff:
ig_moff:

	tst.w	_gl_moff
	bne	L35

	moveq.l	#123,d0			; code 123 => v_hide
	bsr	vdi_short

	clr.w	 _gl_mouse

L35:	add.w	#1,_gl_moff
	rts



#if CCODE
VOID gsx_mon(NOTHING)
{
	gl_moff--;
	if (!gl_moff)
	{
		gsx_1code(SHOW_CUR, 1);
		gl_mouse = TRUE;
	}
}
#endif
/* 306de: 00e2536c */
/* 104de: 00fe1dda */
	xdef _gsx_mon
_gsx_mon:

	moveq.l	#1,d0
	sub.w	d0,_gl_moff
	bne	L37

	move.w	  d0,-(sp)
	move.w	#122,-(sp)		; show cursor: don't force it
	bsr	_gsx_1code
	addq.l	#4,sp

	move.w	#1,_gl_mouse

L37:	rts



#if CCODE
/* unused */
WORD gsx_kstate(NOTHING)
{
	gsx_ncode(KEY_SHST, 0, 0);
	return(intout[0]);
}
#endif


#if CCODE
/* unused */
WORD gsx_char(NOTHING)
{
	REG WORD		*pintin;
	REG WORD		*pintout;
	pintin = &intin[0];
	pintout = &intout[0];

	pintin[0] = 4;
	pintin[1] = 2;
	gsx_ncode(SET_INPUT_MODE, 0, 2);

	pintin[0] = -1;
	pintin[1] = FALSE;
	gsx_ncode(STRING_INPUT, FALSE, 2);
	if (contrl[4])
		return(pintout[0]);
	else
		return(0);
}
#endif


#if CCODE
WORD av_opnwk(WORD *pwork_in, WORD *phandle, WORD *pwork_out)
{
	WORD *ptsptr;

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
#endif
/* 306de: 00e2538c */
/* 104de: 00fe1dfa */
/* 404: 00e3423c */
	xdef _av_opnwk
_av_opnwk:

	move.l	4(sp),iioff		; _intin array is pwork_in
	move.l	12(sp),a1		; a1 -> pwork_out
	move.l	a1,iooff		; _intout array is pwork_out
	lea	90(a1),a1		; a1 -> pwork_out+45
	move.l	a1,pooff		; _ptsout array is pwork_out+45

	moveq.l	#V_OPNWK,d0
	bsr	vdi_call

	move.l	8(sp),a1		; a1 -> phandle
	move.w	_contrl+12,(a1)		; phandle <- workstation handle
	
	move.l	#_intin,iioff
	move.l	#_intout,iooff
	move.l	#_ptsout,pooff
	rts



#if CCODE
VOID av_pline(WORD count, WORD *pxyarray)
{
	i_ptsin(pxyarray);
	gsx_ncode(POLYLINE, count, 0);
	i_ptsin(ptsin);
}
#endif
/* 306de: 00e253d8 */
/* 104de: 00fe1e46 */
/* 404: 00e34288 */
	xdef _av_pline
_av_pline:

	lea	4(sp),a0

	clr.w	      -(sp)
	move.w	(a0)+,-(sp)
	move.w	   #6,-(sp)

	bsr	set_pioff
	bra	vdi_cont



#if CCODE
VOID avst_clip(WORD clip_flag, WORD pxyarray)
{
	WORD tmp, value;

	value = (clip_flag != 0) ? 2 : 0;
	i_ptsin(pxyarray);
	intin[0] = clip_flag;
	gsx_ncode(TEXT_CLIP, value, 1);
	i_ptsin(ptsin);
}
#endif
/* 306de: 00e253ec */
/* 104de: 00fe1e5a */
	xdef _avst_clip
_avst_clip:

	lea	4(sp),a0
	move.w	(a0)+,_intin		; intin[0] <- clip flag
	bsr	set_pioff		; redirect ptsin array pointer
	moveq.l	#VST_CLP,d0
	bra	vdi_call



#if CCODE
VOID avst_height(WORD height, WORD *pchr_width, WORD *pchr_height, WORD *pcell_width, WORD *pcell_height)
{
	REG WORD *ppts;

	ppts = &ptsout[0];

	ptsin[0] = 0;
	ptsin[1] = height;
	gsx_ncode(CHAR_HEIGHT, 1, 0);
	*pchr_width = ppts[0];
	*pchr_height = ppts[1];
	*pcell_width = ppts[2];
	*pcell_height = ppts[3];
}
#endif
/* 306de: 00e25400 */
/* 104de: 00fe1e6e */
	xdef _avst_height
_avst_height:

	lea	_ptsin,a1
	clr.w	      (a1)+		; ptsin[0] <- 0
	move.w	4(sp),(a1)+		; ptsin[1] <- height

	moveq.l	#VST_HGT,d0
	bsr	vdi_call

	lea	_ptsout,a0
	lea	6(sp),a1

	move.l	(a1)+,a2		; a2 -> pchar_width
	move.w	(a0)+,(a2)		; pchr_width   <- ptsout[0]
	move.l	(a1)+,a2		; a2 -> pchar_height
	move.w	(a0)+,(a2)		; pchr_height  <- ptsout[1]
	move.l	(a1)+,a2		; a2 -> pcell_width
	move.w	(a0)+,(a2)		; pcell_width  <- ptsout[2]
	move.l	(a1)+,a2		; a2 -> pcell_height
	move.w	(a0)+,(a2)		; pcell_height <- ptsout[3]
	rts



#if CCODE
VOID avr_recfl(WORD *pxyarray, FDB *pdesMFDB) /* ??? why MFDB ??? */
{
	i_ptr(pdesMFDB);
	i_ptsin(pxyarray);
	gsx_ncode(FILL_RECTANGLE, 2, 1);
	i_ptsin(ptsin);
}
#endif
/* 306de: 00e2542e */
/* 104de: 00fe1e9c */
	xdef _avr_recfl
_avr_recfl:

	lea	4(sp),a0
	bsr	set_pioff
	move.l	(a0)+,_contrl+14

	moveq.l	#VR_RECT,d0
	bra	vdi_call




#if CCODE
VOID avro_cpyfm(WORD wr_mode, WORD *pxyarray, WORD *psrcMFDB, WORD *pdesMFDB)
{
	intin[0] = wr_mode;
	i_ptr(psrcMFDB);
	i_ptr2(pdesMFDB);
	i_ptsin(pxyarray);
	gsx_ncode(COPY_RASTER_FORM, 4, 1);
	i_ptsin(ptsin);
}
#endif
/* 306de: 00e2543e */
/* 104de: 00fe1eac */
	xdef _avro_cpyfm
_avro_cpyfm:

	lea	4(sp),a0		; a0 -> parameters on stack
	move.w	(a0)+,_intin		; intin[0] <- writing mode	  4(sp)
	bsr	set_pioff		; initialize ptsin array pointer  6(sp)
	bsr	mfdb_load		; load MFDBs

	moveq.l	#VRO_CPY,d0
	bra	vdi_call




#if CCODE
VOID avrt_cpyfm(WORD wr_mode, WORD *pxyarray, FDB *psrcMFDB, FDB *pdesMFDB, WORD fgcolor, WORD bgcolor)
{
	REG WORD *pintin;

	pintin = &intin[0];

	pintin[0] = wr_mode;
	pintin[1] = fgcolor;
	pintin[2] = bgcolor;
	i_ptr(psrcMFDB);
	i_ptr2(pdesMFDB);
	i_ptsin(pxyarray);
	gsx_ncode(TRAN_RASTER_FORM, 4, 3);
	i_ptsin(ptsin);
}
#endif
/* 306de: 00e25450 */
/* 104de: 00fe1ebe */
	xdef _avrt_cpyfm
_avrt_cpyfm:

	lea	  4(sp),a0		; a0 -> parameters on stack
	lea	 _intin,a2		; a2 -> intin array
	
	move.w	(a0)+,(a2)+		; intin[0] <- writing mode        4(sp)
	bsr	set_pioff		; initialize ptsin pointer	  6(sp)
	bsr	mfdb_load		; load MFDBs
	move.l	(a0)+,(a2)+		; intin[1] <- foreground color	 18(sp)
*					; intin[2] <- background color   20(sp)
	moveq.l	#VRT_CPY,d0
	bra	vdi_call



#if CCODE
VOID avr_trnfm(FDB *psrcMFDB, FDB *pdesMFDB)
{
	i_ptr(psrcMFDB);
	i_ptr2(pdesMFDB);
	gsx_ncode(TRANSFORM_FORM, 0, 0);
}
#endif
/* 306de: 00e25466 */
/* 104de: 00fe1ed4 */
	xdef _avr_trnfm
_avr_trnfm:

	lea	 4(sp),a0		; a0 -> stack parameters
	bsr	mfdb_load

	moveq.l	#110,d0			; code 110 => vr_trn_fm
	bra	vdi_short



#if CCODE
VOID avsl_width(WORD width)
{
	ptsin[0] = width;
	ptsin[1] = 0;
	gsx_ncode(S_LINE_WIDTH, 1, 0);
}
#endif
/* 306de: 00e25470 */
/* 104de: 00fe1ede */
	xdef _avsl_width
_avsl_width:
	lea	_ptsin,a1
	move.w	4(sp),(a1)+		; ptsin[0] <- width
	clr.w	      (a1)		; ptsin[1] <- 0

	moveq.l	#VSL_WID,d0
	bra	vdi_call




* in:
*	a0	pointer to SRC and DST MFDBs

mfdb_load:
	lea	_contrl+14,a1		; a1 -> contrl[7]
	move.l (a0)+,(a1)+		; contrl[7] -> SRC MFDB
	move.l (a0)+,(a1)+		; contrl[8] -> DST MFDB
	rts



* in:
*	a0	pointer to ptsin array
set_pioff:
	move.l	(a0)+,pioff
	rts



* in:
*	d0	vdi op code
/* 404: 00e34344 */
vdi_short:

	clr.l	-(sp)
	bra	vdi_sh


* in:
*	d0	offset into vdi_list
/* 306de: 00e25498 */
/* 104de: 00fe1f06 */
/* 404: 00e34348 */
vdi_call:

	lea	vdi_list(pc,d0.w),a2

	clr.w	d0
	move.b	(a2)+,d0
	move.w	d0,-(sp)
	move.b	(a2)+,d0
	move.w	d0,-(sp)
	move.b	(a2)+,d0
vdi_sh:	move.w	d0,-(sp)

vdi_cont:

#if LINEF_HACK
	jsr	_gsx_acode
#else
	jsr	_gsx_ncode
#endif
	addq.l	#6,sp
	move.l	#_ptsin,pioff		; some routines alter this pointer
	rts				; so we shall always reset it.

#if !BINEXACT
	xdef _set_cache
_set_cache:
	move.l 4(a7),d1
	CACR_D0
	D1_CACR
	rts
#endif


vdi_list:	

	dc.b	037,000,111		; GSX_MFS	vsc_form
	dc.b	011,000,001		; V_OPNWK	v_opnwk
	dc.b	001,002,129		; VST_CLP	vs_clip
	dc.b	000,001,012		; VST_HGT	vst_height
	dc.b	001,002,114		; VR_RECT	vr_recfl
	dc.b	001,004,109		; VRO_CPY	vro_cpyfm
	dc.b	003,004,121		; VRT_CPY	vrt_cpyfm
	dc.b	000,001,016		; VSL_WID	vsl_width


/* driver id to use in v_opnwk() call */
restable:
	dc.w	0
	dc.w	2 /* ST-LOW 320x200x16 */
	dc.w	5 /* ST-LOW 320x200x16 */
	dc.w	7 /* ST-LOW 320x200x16 */
	dc.w	3 /* ST-MED 640x200x4 */
	dc.w	4 /* ST-HIGH 640x400x2 */
	dc.w	6 /* TT-MED 640x480x16 */
	dc.w	8 /* TT-HIGH 1280x960x2 */
	dc.w	9 /* TT-LOW 320x480x256 */
/* internal resolution type; compared against gl_restype */
restype:
	dc.w	0
	dc.w	1 /* ST-LOW 320x200x16 */
	dc.w	1
	dc.w	1
	dc.w	2 /* ST-MED 640x200x4 */
	dc.w	3 /* ST-HIGH 640x400x2 */
	dc.w	4 /* TT-MED 640x480x16 */
	dc.w	5 /* TT-HIGH 1280x960x2 */
	dc.w	6 /* TT-LOW 320x480x256 */
