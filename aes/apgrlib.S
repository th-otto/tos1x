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

#define __ASSEMBLER__ 1

#include "config.h"
#include "aesdefs.h"
#include "asmdefs.h"

#define CCODE 0

/*
 *
 *		Apgrlib.s
 *
 *	Original		- Derek Mui
 *	Optimized in assembly	- CS	1-29-87
 *
 *
 * assemble with MAS 900801 kbad
 */

FIS_PATTERN	equ	2
FIS_HOLLOW	equ	0
FIS_SOLID	equ	1
IP_HOLLOW	equ	0
IP_SOLID	equ	7
S_FILL_COLOR	equ	25
MD_REPLACE	equ	1
MD_TRANS	equ	2
TE_CNTR		equ	2
TE_RIGHT	equ	1
SELECTED	equ	1
SMALL		equ	5


	text

/*************************************************************************
 *
 *		gr_inside(pt,th)
 *
 *************************************************************************/
#if CCODE
VOID gr_inside(GRECT *pt, WORD th)
{
	pt->g_x += th;
	pt->g_y += th;
	pt->g_w -= (2 * th);
	pt->g_h -= (2 * th);
}
#endif
/* 306de: 00e2414c */
/* 104de: 00fd4388 */
/* 106de: 00e1471e */
	xdef	_gr_inside
_gr_inside:
	move.l	4(sp),a0		; a0 contains grect pointer
	move.w	8(sp),d1		; d1 contains "th"
	add	d1,(a0)+		; pt->g_x += th
	add	d1,(a0)+		; pt->g_y += th
	asl	#1,d1			; th * 2
	sub	d1,(a0)+		; pt->g_w -= (2*th)
	sub	d1,(a0)+		; pt->g_h -= (2*th)
	rts

/***************************************************************************
 *
 *	gr_rect(icolor,ipattern,pt)
 *
 **************************************************************************/

#if CCODE
VOID gr_rect(UWORD icolor, UWORD ipattern, GRECT *pt)
{
	REG WORD fis;

	fis = FIS_PATTERN;
	if (ipattern == IP_HOLLOW)
		fis = FIS_HOLLOW;
	else if (ipattern == IP_SOLID)
		fis = FIS_SOLID;

	vsf_color(icolor);
	bb_fill(MD_REPLACE, fis, ipattern, pt->g_x, pt->g_y, pt->g_w, pt->g_h);
}
#endif
/* 306de: 00e24160 */
/* 104de: 00fd439c */
	xdef	_gr_rect
_gr_rect:
gr_rect:
	movem.l	d3-d5/a3-a3,-(sp)
	movem.w	16+4(sp),d3-d4		; d3 = icolor,d4 = pattern
	move.l	16+8(sp),a3		; a3 = pt
	moveq	#FIS_PATTERN,d5		; d5 = fis
	tst.w	d4			; if (ipattern == IP_HOLLOW
	bne	L21
	clr.w	d5			; then fis = FIS_HOLLOW
L21:	cmp.w	#IP_SOLID,d4		; else if (ipattern == IP_SOLID
	bne 	L22
	moveq	#FIS_SOLID,d5
L22:	move.w	d3,-(sp)
	move.w	#S_FILL_COLOR,-(sp)
	jsr	_gsx_1code		; vsf_color(icolor)
	move.l	4(a3),-(sp)		; push pt->w and pt->ht
	move.l	(a3),-(sp)		; push pt->x and pt->y
	move.w	d4,-(sp)		; push ipattern
	move.w	d5,-(sp)		; push fis
	move.w	#MD_REPLACE,-(sp)
	jsr	_bb_fill
	lea	18(sp),sp		; restore the stack
	movem.l	(sp)+,d3-d5/a3-a3
	rts

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
#if CCODE
WORD gr_just(WORD just, WORD font, const char *ptext, WORD w, WORD h, GRECT *pt)
{
	WORD numchs;

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
			break;
		}								/* switch */
	}

	return (numchs);
}
#endif
/* 306de: 00e241a8 */
/* 104de: 00fd43dc */
	xdef	_gr_just
_gr_just:
	movem.l	d0-d7/a3-a3,-(sp)
	move.w	36+4(sp),d3		; pop off "just" into d3
	movem.w	36+12(sp),d6-d7		; "width into d6,height into d7
	move.l	36+16(sp),a3		; "pt" into a3
	lea	2(sp),a1		; local var "numchs" in d0's spot
*					; on the stack
	move.l	a1,-(sp)		; and push it onto the stack
	lea	6(a3),a1		; push &pt->g_h
	move.l	a1,-(sp)
	lea	4(a3),a1		; push &pt->g_w
	move.l	a1,-(sp)
	move.l	48+8(sp),-(sp)		; push ptext
	move.w	52+6(sp),-(sp)		; push font
	jsr	_gsx_tcalc
	lea	18(sp),sp
	sub	6(a3),d7		; h -= pt->g_h
	ble	L31
	move	d7,d5			; d5 = temp height
	addq	#1,d5			
	ext.l	d5
	asr	#1,d5
	add	d5,2(a3)		; pt->g_y += (h + 1)/2
L31:
	sub	4(a3),d6		; w -= pt->g_w;
	ble	L32
	cmp.w	#TE_CNTR,d3		; case TE_CNTR
	bne	L33
	move	d6,d5
	addq	#1,d5
	ext.l	d5
	asr	#1,d5
	add	d5,(a3)			; pt->g_x += (w+1)/2
	bra	L32
L33:	cmp.w	#TE_RIGHT,d3
	bne	L32
	add	d6,(a3)			; pt->g_x += w
L32:
	movem.l	(sp)+,d0-d7/a3-a3	; restore stack and return 
	rts				; numchs into d0

/************************************************************************
 *
 *	gr_gtext
 *
 ************************************************************************/
/*
 *	Routine to draw a string of graphic text.
 */
#if CCODE
VOID gr_gtext(WORD just, WORD font, const char *ptext, GRECT *pt)
{
	WORD numchs;

	GRECT t;

	/* figure out where &   */
	/*   how to put out */
	/*   the text       */
	rc_copy(pt, &t);
	numchs = gr_just(just, font, ptext, t.g_w, t.g_h, &t);
	if (numchs > 0)
		gsx_tblt(font, t.g_x, t.g_y, numchs);
}
#endif
/* 306de: 00e24216 */
/* 104de: 00fd4446 */
	xdef	_gr_gtext
_gr_gtext:
gr_gtext:
	movem.l	d0-d1/a3,-(sp)		; save a3 and make room for
*					; a grect
	move.l	sp,a3			; which is pointed to by a3
	move.l	12+12(sp),a0
	move.l	(a0)+,(a3)		; copy grect into our local one
	move.l	(a0)+,4(a3)
	move.l	a3,-(sp)		; push grect "t"  onto stack
	move.l	4(a3),-(sp)		; push t.g_w and t.g_h onto stack
	move.l	20+8(sp),-(sp)		; push ptext
	move.w	24+6(sp),-(sp)		; push font
	move.w	26+4(sp),-(sp)		; push just
	jsr	_gr_just
	lea	16(sp),sp		; Restore stack
	tst.w	d0
	ble	L41
	move.w	d0,-(sp)
	move.l	(a3),-(sp)		; push t.g_x and t.g_y
	move.w	18+6(sp),-(sp)		; push	font
	jsr	_gsx_tblt
	addq.l	#8,sp
L41:	movem.l	(sp)+,d0-d1/a3		; restore a3
	rts

/**************************************************************************
 *
 *		gr_crack(color,pbc,ptc,pip,pic,pmd)
 *
 **************************************************************************/
/*
 *	Routine to crack out the border color, text color, inside pattern,
 *	and inside color from a single color information word.
 */
#if CCODE
VOID gr_crack(UWORD color, WORD *pbc, WORD *ptc, WORD *pip, WORD *pic, WORD *pmd)
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
#endif
/* 306de: 00e2425a */
/* 104de: 00fd4484 */
	xdef	_gr_crack
_gr_crack:
	move.w	4(sp),d0		; d0 contains color
	move.l	6(sp),a0		; a0 <- pbc
	move.w	d0,d1
	lsr	#8,d1			; LHIBT(color) gets hi byte of word
	move.w	d1,d2			; save for later use
	asr	#4,d1			; LHIBT(color) >> 4
	and	#$0F,d1			; LHIBT(color) >> 4) & 0x0f
	move	d1,(a0)			; put value into pbc
	and	#$0F,d2			; LHIBT(color) & 0x0f
	move.l	10(sp),a0		; get ptc from stack
	move	d2,(a0)			; put value into ptc
	move	d0,d1			; get color again
	and	#$ff,d1
	move	d1,d2			; save for later
	asr	#4,d1
	and	#$0f,d1
	move.l	14(sp),a0		; get pip off the stack
	move	d1,(a0)			; *pip = (LLOBT(color)>>4)&0x0f
	move.l	22(sp),a1		; get pmd off the stack
	btst	#3,1(a0)		; if(*pip & 0x08)
	beq	L51
	and	#7,(a0)			; *pip &= 0x07
	move.w	#MD_REPLACE,(a1)	; *pmd = MD_REPLACE
	bra	L52
L51:	move.w	#MD_TRANS,(a1)		; *pmd = MD_TRANS
L52:	and	#$0f,d2		
	move.l	18(sp),a1
	move.w	d2,(a1)			; *pic = LLOBT(color) & 0x0f
	rts

/************************************************************************
 *
 *	gr_icon(state,pmask,pdata,ptext,ch,chx,chy,pi,pt)
 *
 ************************************************************************/
/*
 *	Routine to draw an icon, which is a graphic image with a text
 *	string underneath it.
 */
#if CCODE
VOID gr_gicon(WORD state, int16_t *pmask, int16_t *pdata, const char *ptext, WORD ch, WORD chx, WORD chy, GRECT *pi, GRECT *pt)
{
	REG WORD fgcol, bgcol, tmp;

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
#endif
/* 306de: 00e242b4 */
/* 104de: 00fd44de */
	xdef	_gr_gicon
_gr_gicon:
	movem.l	d3-d7/a3-a4,-(sp)	; 28 bytes 
	movem.w	28+18(sp),d5-d7		; d5 <- ch,d6-chx,d7-chy
	move.w	d5,d4
	move.w	#12,d0
	asr	d0,d4
	and	#15,d4			; d4 = fg
	move.w	d5,d3			; temp 
	asr	#8,d3
	and	#15,d3			; d3 = bg
	and	#$FF,d5			; and ch with 0xff
	btst	#0,28+5(sp)		; check bit in "state" + byte offset
	beq	L61
	exg	d3,d4			; exchange fg/bg
L61:	movem.l	28+24(sp),a3-a4		; pi off stackinto a3, pt into a4
	btst	#6,28+5(sp)		; check state (+ byte offset)
	beq	L62
	tst.w	d3			; bg == WHITE?
	beq	L63
L62:	move.l	28+6(sp),d0		; get pmask
	move.w	d4,d1			; fg - set up for stack prep
	move.w	d3,d2			; bg 
	bsr	make_call		; make call to gsx_blt
	move.l	a4,-(sp)
	move.w	#IP_SOLID,-(sp)
	move.w	d3,-(sp)
	bsr	gr_rect
	addq.l	#8,sp
L63:
	move.l	28+10(sp),d0		; pdata
	move.w	d3,d1			; bg
	move.w	d4,d2			; fg
	bsr	make_call
	move.w	d4,-(sp)		; fg
	move.l	#$00010002,-(sp)        ; push #MD_TRANS then #1
	jsr	_gsx_attr
	addq.l	#6,sp
	tst.w	d5			; if(ch)
	beq	L64
	move.w	d5,_intin		; intin[0] = ch
	move.w	#1,-(sp)
	move.w	2(a3),-(sp)		; push pi->g_y
	add	d7,(sp)			; add chy
	move.w	(a3),-(sp)		; push pi
	add	d6,(sp)			; add chx
	move.w	#SMALL,-(sp)
	jsr	_gsx_tblt
	addq.l	#8,sp
L64:	move.w	#MD_TRANS,-(sp)
	move.l	a4,-(sp)
	move.l	34+14(sp),-(sp)		; push ptext
	move.l	#$00020005,-(sp)	; push SMALL then TE_CNTR
	bsr	gr_gtext
	lea	14(sp),sp
	movem.l	(sp)+,d3-d7/a3-a4
	rts

*************************************************************
*	Utility for gr_gicon:
*		EXPECTS:   data pointer in d0
*			   bg/fg in d1 and d2
*************************************************************
			
make_call:
	move.w	d1,-(sp)		; fg/bg
	move.w	d2,-(sp)		; fg/bg
	move.w	#MD_TRANS,-(sp)	
	move.l	4(a3),-(sp)		; pi->g_w and pi->g_h
	move.w	_gl_width,d1
	ext.l	d1
	divs	#8,d1
	move	d1,-(sp)		; push gl_width/8
	move.l	(a3),-(sp)		; pi->g_x and pi->g_y
	clr.l	-(sp)
	move.w	4(a3),d1
	ext.l	d1
	divs	#8,d1
	move.w	d1,-(sp)		; push pi->g_w/8
	clr.l	-(sp)
	move.l	d0,-(sp)		; pmask/pdata
	jsr	_gsx_blt
	lea	30(sp),sp		; clean up
	rts

	

/**************************************************************************
 *
 *	gr_box(x,y,w,h,th)
 *
 **************************************************************************/
/*
 *	Routine to draw a box of a certain thickness using the current
 *	attribute settings
 */
#if CCODE
VOID gr_box(WORD x, WORD y, WORD w, WORD h, WORD th)
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
#endif

/* 104de: 00fd45be */
	xdef	_gr_box
_gr_box:
	movem.l	d3/a3-a4,-(sp)		; save some needed registers
#if (AESVERSION >= 0x200) | !BINEXACT
	suba.w	#16,sp			; need 8 bytes for local grects
#else
	suba.l	#16,sp			; need 8 bytes for local grects
#endif
	move.l	sp,a3			; a3 <- t grect
	lea	8(sp),a4		; a4 <- n grect
	move.w	28+12(sp),d3		; th
	move.l	28+4(sp),(a3)		; set local grect with x,y,w,h
	move.l	28+8(sp),4(a3)
	tst.w	d3
	beq	L71			; if(th != 0)
	bge	L72			; if(th < 0)
	subq.w	#1,d3			;    then th--
L72:	jsr	_gsx_moff
L73:	tst.w	d3			; th += (th>0)?-1:1
	ble	L74
	subq	#1,d3
	bra	L75
L74:	addq	#1,d3
L75:	move.l	(a3),(a4)		; copy grect t to grect n
	move.l	4(a3),4(a4)
	move.w	d3,-(sp)		; push th
	move.l	a4,-(sp)		; push &n
	jsr	_gr_inside
	jsr	_gsx_box		; gsx_box(&n) n's already on stack
	addq.l	#6,sp
	tst.w	d3
	bne	L73
	jsr	_gsx_mon
L71:
	lea	16(sp),sp		; don't need local grects anymore
	movem.l	(sp)+,d3/a3-a4
	rts
