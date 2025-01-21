***************************  gsxasm2.s  *********************************
*
* =======================================================================
* $Author: lozben $	$Date: 91/02/15 11:46:42 $
* =======================================================================
*
* Revision 3.3  91/02/15  11:46:42  lozben
* Restored the linea var structure pointer stored in the adr register in
* the trap binding routines. The actual trap clobered the adr reg.
*
* Revision 3.2  91/02/14  18:11:11  lozben
* Forgot to reference some of the variables of the line a var struct ptr.
*
* Revision 3.1  91/01/30  14:44:36  lozben
* Adjusted the code to work the multiple linea variable structures.
*
* Revision 3.0  91/01/03  15:09:59  lozben
* New generation VDI
*
* Revision 2.5  90/06/13  11:35:09  lozben
* Created a trap 14 binding (_trap14() routine).
*
* Revision 2.4  90/02/14  16:21:28  lozben
* Functions which are called by seedfill() don't clobber "C" registers anymore.
*
* Revision 2.3  89/05/16  16:22:16  lozben
* Changed setup for sb_rect(), d1 and d2 registers have been swapped.
*
* Revision 2.2  89/02/27  17:35:13  lozben
* Moved hb_rect() into another file. The idea is to have
* all the hard blit code in independent files.
*
* Revision 2.1  89/02/21  17:22:17  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
*
*************************************************************************


#include "config.h"
#include "vdidefs.h"
#include "lineaequ.inc"
#include "tosvars.inc"


		text

/* 306de: 00e0c0a4 */
/* 206de: 00e0c414 */
/* 104de: 00fd0674 */
/* 106de: 00e10898 */
		xdef	_vtrap1
_vtrap1:	PIXLA(a0)
		move.l	(sp)+,PIXLV(retsav,a0)
		trap	#1
		PIXLA(a0)
		move.l	PIXLV(retsav,a0),-(sp)
		rts


*******************************************************************************
*									      *
*	_TRNSFONT							      *
*									      *
*	This routine converts a font to standard form by byte swapping it     *
*									      *
*	input:	FWIDTH = width of font data in bytes			      *
*		DELY   = number of scan lines in font			      *
*		FBASE  = starting address of the font data	 	      *
*									      *
*	output: nothing is returned					      *
*									      *
*	destroys: d0-d1/a0-a1						      *
*									      *
*******************************************************************************

/* 306de: 00e0c0c4 */
/* 206de: 00e0c424 */
/* 104de: 00fd0684 */
/* 106de: 00e108a8 */
		xdef	_TRNSFONT
_TRNSFONT:
		PIXLA(a1)
		move.w	PIXLV(FWIDTH,a1),d0	; d0 <- Width of a font form
		mulu.w	PIXLV(DELY,a1),d0	; d0 <- length of form (bytes)
		lsr.w	#1,d0		; d0 <- length of form (words)
		subq.w	#1,d0		; d0 <- dbra counter

		move.l	PIXLV(FBASE,a1),a0	; a0 -> font form

swap_loop:	move.w	(a0),d1		; d1 <- font form word
		ror.w	#8,d1		; swap bytes
		move.w	d1,(a0)+	; put it back
		dbra	d0,swap_loop

		rts

*******************************************************************************
*******************************************************************************
**
**	_put_pix:
**
**	This routine plots a pixel for anybody (even BASIC)
**
**	input:	INTIN(0) = pixel value
**		PTSIN(0) = X coordinate
**		PTSIN(1) = Y coordinate
**
**	output: none
**
**	destroys: d0-d3/a0-a2
**
*******************************************************************************
*******************************************************************************
/* 306de: 00e0c0e6 */
/* 206de: 00e0c446 */
/* 104de: 00fd06a6 */
/* 106de: 00e108ca */
		xdef	_put_pix
_put_pix:
		PIXLA(a2)
		movea.l	PIXLV(PTSIN,a2),a0	; a0 -> PTSIN array
		move.w	 (a0),d0	; d0 <- X coordinate
		move.w	2(a0),d1	; d1 <- Y coordinate
		bsr	concat		; get physical offset
		move.l	_v_bas_ad,a1	; a1 -> start of screen
		add.w	d1,a1		; a1 -> 1st word containing pixel

		add.w      d0,d0
		lea.l      ortbl,a0
		move.w     0(a0,d0.w),d0		; d0 <- OR mask  (for setting a bit)
		move.w	d0,d1
		not.w	d1		; d1 <- AND mask (for clearing a bit)

		move.w	PIXLV(v_planes,a2),d2	; d2 <- planes
		subq.w	#1,d2			; d2 <- dbra plane counter
		move.l	PIXLV(INTIN,a2),a0		; a0 -> INTIN array
		move.w	(a0),d3			; d3 <- pixel value

ppx_loop:	ror.w	#1,d3		; rotate pixel bit and put in carry.
		bcc	ppx_clr		; if 0, clear the bit.

ppx_set:	or.w	d0,(a1)+	; if 1, set the bit.
		dbra	d2,ppx_loop
		rts

ppx_clr:	and.w	d1,(a1)+	; clear the bit.
		dbra	d2,ppx_loop
		rts


*******************************************************************************
*******************************************************************************
**
**	_ST_GETPIX:
**
**	This routine gets a pixel for anybody (even BASIC)
**
**	input:		PTSIN[0] = X coordinate
**			PTSIN[1] = Y coordinate
**
**	output:	       d0 = pixel value
**
**	destroys:      d0-d2/a0-a1
**
*******************************************************************************
*******************************************************************************
/* 306de: 00e0c12e */
/* 206de: 00e0c48e */
/* 104de: 00fd06ee */
/* 106de: 00e10912 */
		xdef	_get_pix
_get_pix:
		PIXLA(a1)
		move.l	PIXLV(PTSIN,a1),a0	; a0 -> PTSIN array
		move.w	(a0)+,d0	; d0 <- X coordinate
		move.w	(a0),d1		; d1 <- Y coordinate
		bsr	concat		; get physical offset
		move.l	_v_bas_ad,a0	; a0 -> screen base
		add.w	d1,a0		; a0 -> 1st word of pixel

		add.w      d0,d0
		lea.l      ortbl,a1
		move.w     0(a1,d0.w),d1		; fetch the pixel word mask.

		move.w	PIXLV(v_planes,a1),d2	; d2 <- planes
		move.w	d2,d0
		add.w	d0,d0			; d0 <- off to nxt wrd in plane
		subq.w	#1,d2			; d2 <- dbra plane counter
		add.w	d0,a0			; a0 ->highest order bitplane+2
		moveq.l	#0,d0			; init pixel acc and cy:0
		bra gpxl_in
gpx_loop:
		asl.w      #1,d0	; shift accumulator for next bit_plane.
gpxl_in:
		move.w	-(a0),d3	; d3 <- current plane word
		and.w	d1,d3		; test the current word's bit
		beq	gpxl_bot		; if 0, branch.
		or.w    #1,d0		; if 1, set value accumulator bit.
gpxl_bot:
		dbra	d2,gpx_loop
		rts


*******************************************************************************
*******************************************************************************
**
**	_fill_line
**
**	This routine fills a line for "seedfill" using HABLINE
**
**	input:	36(sp) = X left
**		38(sp) = X right
**		40(sp) = Y
**
**	output: filled line
**
**	destroys: a0-a2
**
*******************************************************************************
*******************************************************************************


		xdef	_fill_line
_fill_line:
		move.l	_v_bas_ad,a5	/* fetch video base address. */
		lea	PIXLV(FG_BP_1,a4),a4	/* point to array of bit_plane values. */
		move.w	PIXLV(v_planes,a4),a3	/* a3 := xinc. (# of planes) */
		move.w	a3,d3
		adda.w	a3,a3		/* word xinc. */
		subq.w	#1,d3		/* d3 := (# of planes) -1. */
		move.w	4(sp),d0	/* fetch xleft. (input to concat) */
		move.w	d0,d4		/* save for later. */

		move.w	8(sp),d1	/* fetch y. (input to concat) */
		move.w	d1,d5		/* save for later. */
		bsr	concat		/* form physical offset. */
		adda.w	d1,a5		/* base + physical offset. */
		move.w	6(sp),d2	/* fetch xright. */
		and.w	PIXLV(patmsk,a4),d5	/* compute pattern index. */
		asl.w	#1,d5		/* word indexing. */
		move.l	PIXLV(patptr,a4),a0	/* ptr to start of pattern. */
		adda.w	d5,a0		/* index into pattern. */
		suba.w	a1,a1		/* default offset = 0. */
		tst.w	PIXLV(multifill,a4)	/* multi-plane fill pattern? */
		beq	xline		/* no, branch. */
		move.w	#32,a1		/* yes, offset = 32. */
*
*	d4 = xleft.			a5 = ptr to destination.
*	d3 = # of bit_planes - 1	a4 = ptr to _FG_BP_1.
*	d2 = xright.
*   a3 = # of bytes between video planes
*	d1 = fill pattern.		a1 = offset to next planes fill pattern
*	d0 = xleft and 0x000F.           a0 = ptr to fill pattern.
*
		bra	xline		/* fill the horizontal line with color. */

*******************************************************************************
*******************************************************************************
**
**      end_pts(int16_t xstart, int16_t ystart, int16_t *lptr, int16_t *rptr)
**
**      This routine finds the endpoints of a horizontaly contiguous
**      section of solid color ( used by the _seed_fill routine )
**
**      input:  4(sp) = X start
**              6(sp) = Y start
**              8(sp) = ptr to endXleft.
**             12(sp) = ptr to endXright
**
**      output:
**
**           endXleft = X of left endpoint of solid color
**          endXright = X of right endpoint of solid color
**                 d0 = success flag
**
**                      0 => no endpoints or X start on edge
**                      1 => endpoints found
**
**      destroys: d0-d2/a0-a2
**
*******************************************************************************
*******************************************************************************

		xdef	_end_pts
_end_pts: ds.b 0
vars set 4
		PIXLA(a6)
		move.w	vars+2(sp),d1		; d1 <- Y coordinate
		cmp.w	PIXLV(YMN_CLIP,a6),d1	; return if above viewport Ymin
		bmi	ep_ret0
		cmp.w	PIXLV(YMX_CLIP,a6),d1
		bgt	ep_ret0			; return if below viewport Ymax

		move.l	_v_bas_ad,a5		; a5 -> start of logical screen
		move.w	PIXLV(v_planes,a6),a3	; d3 <- planes
		move.w	a3,d3
		add.w	a3,a3			; a3 <- off to nxt wrd in plane
		subq.w	#1,d3			; d3 <- dbra plane counter
		move.w	vars+0(sp),d0		; d0 <- X coordinate

		bsr	concat			; d1<-physical off d0<-X mod 16
		add.w	d1,a5			; a5 -> word containing (X,Y)


*	a5 = ptr to word containing low-order pixel bit.
*	a4 = scratch.
*
*	d4 = scratch
*	d3 = planes -1
*	d1 = scratch
*	d0 = X mod 16


		add.w	d0,d0		/* word indexing. */
		lea	ortbl,a4	/* table of pixel masks. */
		move.w	0(a4,d0.w),d0	/* fetch the pixel mask. */

		move.w	d0,a0		; a0 <- copy of pixel mask
		moveq.l	#0,d1		; d1 <- initial pixel accumulator
		move.w	d3,a1		; a1 <- copy of dbra plane counter
		move.l	a5,a2		; a2 -> root word of search span
		add.w	a3,a5		; a5 -> next word in plane


*	a5 = ptr to word containing low-order pixel bit
*	a4 = scratch
*	a3 = Xinc
*	a2 = root word of search
*	a1 = dbra plane counter
*	a0 = original pixel mask
*
*	d7 = X coordinate
*	d6 = X max
*	d5 = scratch
*	d4 = scratch
*	d3 = planes -1
*	d2 = color we are looking for
*	d1 = pixel value accumulator
*	d0 = pixel mask

		bra	pxl_in
*
*  Get color value of requested pixel.
*
px_lp:
		asl.w	#1,d1		/* shift accumulator for next bit_plane. */
pxl_in:
		move.w	-(a5),d4	; d4 <- this plane's word
		and.w	d0,d4		; isolate the bit of interest
		beq	pxl_bot		/* if 0, branch. */
		or.w	#1,d1		/* if 1, set value accumulator bit. */
pxl_bot:
		dbra	d3,px_lp
		move.l	a2,a5		/* restore the pixel word pointer. */
		move.w	a1,d3		; d3 <- dbra plane counter
		move.w  vars+0(a7),d7 ; d7 = x coordinate.
		move.w	PIXLV(XMX_CLIP,a6),d6	; d6 <- X min
		move.l	a5,-(sp)	/* push a5. (this adds 4 to the parameter offsets) */
		move.w	d1,d2		/* this is the color we are searching for */
		bra	rnl1		/* branch around redundant test. */
rnedg_lp:
		cmp.w	d1,d2		/* while (pixel value <> search color) */
		bne	rt_nedge
rnl1:
		cmp.w	d6,d7		/* and (x coord < x resolution). */
		bgt	rt_nedge
		addq.w	#1,d7		/* increment x coord. */
		ror.w	#1,d0		/* "increment" the pixel mask and a5. */
		bcc	rn_gpx		/* if no wrap, branch. */
		adda.w	a3,a5		/* else point to next bit_plane 0. */
rn_gpx:
		movea.l	a5,a2		/* save a5. */
*	Now, search to the right.
		moveq.l	#0,d1		/* clear the pixel value. */
		adda.w	a3,a5		/* point to highest-order bit_plane. (+2) */
		bra	rnpxl_in
rnpx_lp:
		asl.w	#1,d1		/* shift accumulator for next bit_plane. */
rnpxl_in:
		move.w	-(a5),d4	/* fetch a bit. */
		and.w	d0,d4		/* test the bit. */
		beq	rnpxl_bot	/* if 0, branch. */
		or.w	#1,d1		/* if 1, set value accumulator bit. */
rnpxl_bot:
		dbra	d3,rnpx_lp
		move.l	a2,a5		/* restore the pixel word pointer. */
		move.w	a1,d3		/* restore the # of bit_planes - 1. */
		bra	rnedg_lp

rt_nedge:
		move.l	(sp)+,a5		; a5 -> root wrd of search span
		adda.w	a3,a5		/* to use predecrement addressing. */
		subq.w	#1,d7			; d7 <- end Xright
		movea.l	vars+8(sp),a4	/* fetch ptr to endxright. */
		move.w	d7,(a4)			; store end Xright
		move.l	a5,a2		/* save a5. */
		move.w	4(sp),d7	/* fetch x coord again. */
		move.w	PIXLV(XMN_CLIP,a4), d6	/* fetch left side of x viewport */
		move.w	a0,d0		/* restore pixel mask. */

*	Now, search to the left.

*	a5 = ptr to word containing low-order pixel bit
*	a4 = scratch
*	a3 = Xinc
*	a2 = root word of search
*	a1 = dbra plane counter
*	a0 = original pixel mask
*
*	d7 = X coordinate
*	d6 = X min
*	d5 = scratch
*	d4 = scratch
*	d3 = planes -1
*	d2 = color we are looking for
*	d1 = pixel value accumulator
*	d0 = pixel mask

		bra	lnlp1		/* d1 isn't ready yet. */

lnedg_lp:
		cmp.w	d1,d2		/* while (pixel value <> search color) */
		bne	lt_nedge
lnlp1:
		cmp.w	d6, d7		/* and (x coord inside viewport). */
		bmi	lt_nedge
		subq.w	#1,d7		/* decrement x coord. */
		rol.w	#1,d0		/* "decrement" the pixel mask and a5. */
		bcc	ln_gpx		/* if no wrap, branch. */
		suba.w	a3,a5		/* else point to previous bit_plane 0. */
ln_gpx:
		movea.l	a5,a2		/* save a5. */

*	Now, get the next pixel value.

		moveq.l	#0,d1		/* clear the pixel value. */
		bra	lnpxl_in

lnpx_lp:
		asl.w	#1,d1		/* shift accumulator for next bit_plane. */
lnpxl_in:
		move.w	-(a5),d4	/* fetch a bit. */
		and.w	d0,d4		/* test the bit. */
		beq	lnpxl_bot	/* if 0, branch. */
		or.w	#1,d1		/* if 1, set value accumulator bit. */
lnpxl_bot:
		dbra	d3,lnpx_lp
		move.l	a2,a5		/* restore the pixel word pointer. */
		move.w	a1,d3		/* restore the # of bit_planes - 1. */
		bra	lnedg_lp

lt_nedge:
		addq.w	#1,d7		/* backup the x coord by 1. */
		movea.l	8(sp),a4	/* fetch ptr to endxleft. */
		move.w	d7,(a4)		/* output x coord to endxleft. */

		cmp.w	_search_color,d2
		beq	ep_is_search

		move.w	_seed_type, d0	/* return segment not of search color */
		eori.w	#1,d0
		rts

ep_is_search:
		move.w	_seed_type, d0	/* return segment is of search color */
		eori.w	#0,d0		; what the fuck is this ?
		rts


ep_ret0:
		moveq.l	#0,d0		; return(0). (failure)
		rts





*******************************************************************************
*******************************************************************************
**
**	_RECTFILL
**
**	This routine fills a rectangular area of the screen with a
**	pattern.
**
**	input:	X1	  = X upper left corner
**		Y1	  = Y upper left corner
**		X2	  = X lower right corner
**		Y2	  = Y lower right corner
**		CLIP	  = clipping flag (0 => no clipping)
**		XMN_CLIP = X clipping minimum
**		XMX_CLIP = X clipping maximum
**		YMN_CLIP = Y clipping minimum
**		YMX_CLIP = Y clipping maximum
**	    WRT_MODE = writing mode (0-3)
**		V_RECT    = vector to rectangle filler
**
**
**
**	Notes:
**
**	 X1,Y1,X2,Y2 are contiguous words
**	 CLIP,XMN_CLIP,YMN_CLIP,XMX_CLIP,YMX_CLIP are contiguous words
**
*******************************************************************************
*******************************************************************************

rf_out:
	rts

/* 306de: 00e0c28a */
/* 104de: 00fd082e */
/* 100fr: 00fd018c */
		xdef	_RECTFILL
_RECTFILL: ds.b 0
		xdef	M_RECTFILL
M_RECTFILL: ds.b 0
	LA(a2)
		tst.w	_CLIP
		beq	BOX_FILL		/* if no clipping, just do it. */
*
*	clipping.
*
		move.w	_XMN_CLIP,d0
		move.w	_X1,d1
		move.w	_X2,d2
		cmp.w	d0,d1			/* is x1 >= xmn_clip? */
		bge	rf_xmx			/* yes, branch. */
		cmp.w	d0,d2			/* is x2 < xmn_clip */
		blt	rf_out			/* yes, branch. (clipped box is null) */
		move.w	d0,_X1			/* clip x1. */
rf_xmx:
		move.w	_XMX_CLIP,d0
		cmp.w	d0,d2			/* is x2 <= xmx_clip? */
		ble	rf_yclip		/* yes, branch. (x clip is done) */
		cmp.w	d0,d1			/* is x1 > xmx_clip? */
		bgt	rf_out			/* yes, branch. (clipped box is null) */
		move.w	d0,_X2			/* clip x2. */
*
rf_yclip:
		move.w	_YMN_CLIP,d0
		move.w	_Y1,d1
		move.w	_Y2,d2
		cmp.w	d0,d1			/* is y1 >= ymn_clip? */
		bge	rf_ymx			/* yes, branch. */
		cmp.w	d0,d2			/* is y2 < ymn_clip */
		blt	rf_out			/* yes, branch. (clipped box is null) */
		move.w	d0,_Y1			/* clip y1. */
rf_ymx:
		move.w	_YMX_CLIP,d0
		cmp.w	d0,d2			/* is y2 <= ymx_clip? */
		ble	BOX_FILL		/* yes, branch. (y clip is done) */
		cmp.w	d0,d1			/* is y1 > ymx_clip? */
		bgt	rf_out			/* yes, branch. (clipped box is null) */
		move.w	d0,_Y2			/* clip y2. */
*
*	fall through to BOX_FILL.
***********************************************************************
*
*	BOX_FILL:							      
*		This routine fills a rectangular area of the screen with a    
*	pattern using a "bitblt" algorithm similar to "_HABLINE"'s.	      
*		This routine handles all 3 video resolutions.		      
*									      
*		input:  _X1 = x coord of upper left corner.		      
*			_Y1 = y coord of upper left corner.		      
*			_X2 = x coord of lower right corner.		      
*			_Y2 = y coord of lower right corner.		      
*			_WRT_MODE = writing mode.			      
*									      
*		output: none.						      
*									      
*		destroys: everything.					      
*									      
***********************************************************************
parm_size	set	6		/* temporary stack area size */
patindx		set	-2		/* copy of current pattern index */
pat_start	set	-6		/* copy of pattern starting address */

BOX_FILL:
		link    a6,#-6	/* allocate temporary stack area */
		move.l	_v_bas_ad,a5	/* fetch video base address. */
		lea.l   PIXLV(FG_BP_1,a2),a4
		move.w	_v_planes,a3	/* a3 := xinc. (# of planes) */
		move.w	a3,d3
		adda.w	a3,a3		/* word xinc. */
		subq.w	#1,d3		/* d3 := (# of planes) -1. */
		move.w	_X1,d0		/* fetch X1. (input to concat) */
		move.w	d0,d4		/* save for later. */
		move.w	_Y1,d1		/* fetch Y1. (input to concat) */
		move.w	d1,d5		/* save for later. */
		bsr	concat		/* form physical offset. */
		adda.w	d1,a5		/* base + physical offset. */
		move.w	_X2,d2		/* fetch X2. */
		move.w	_Y2,d6		/* fetch Y2. */
		sub.w	d5,d6		/* line loop counter. */
		and.w	_patmsk,d5	/* compute pattern index. */
		move.w	d5,patindx(a6) 	/* save pattern index in low word */
		asl.w	#1,d5		/* word indexing. */
		move.l	_patptr,a0	/* ptr to start of pattern. */
		adda.w  d5,a0
		move.l	a0,pat_start(a6) /* save starting address of pattern */
		lea	lf_tab,a2	/* point to fringe table. */
*
*	d7 = scratch.		a5 = ptr to destination.
*	d6 = line loop counter.	a4 = ptr to _FG_BP_1.
*	d5 = scratch.
*   a3 = # of bytes between video planes.
*
*	d4 = X1.		a2 = ptr to fringe table.
*	d3 = # of bit_planes - 1.
*	d2 = X2.		a0 = ptr to fill pattern.
*	d1 = scratch.
*	d0 = X1 and 0x000F.
*
		asl.w	#1,d0		/* word index for left fringe. */
		move.w	0(a2,d0.w),d0	/* fetch left fringe mask. */
		not.w	d0		/* not left fringe mask. */
		move.w	d2,d7		/* X2. */
		and.w	#0x000F,d7	/* X2 and 0x000F. */
		asl.w	#1,d7		/* word index. */
		move.w	2(a2,d7.w),d7	/* fetch not right fringe mask. */
		moveq.l	#4,d5
		asr.w	d5,d4		/* X1/16. */
		asr.w	d5,d2		/* X2/16. */
		sub.w	d4,d2		/* X2/16 - X1/16. */
		subq.w	#1,d2		/* inner loop count. (-1,0,>0.) */
*
*					/* -1 => X1 and X2 in same word. */
*					/* 0  => 2 words, inner loop = 0. */
*					/* >0 => LM,inner loop,RM. */
*
		bpl	bf_cont		/* >= 0 normal case. */
		addq.w	#1,d2		/* loop count := 0. */
		or	d7,d0		/* combine both masks. */
		moveq	#-1,d7		/* prevent right mask from effecting screen. */
bf_cont:
		move.w	_WRT_MODE,d5	/* decode write mode. */
		asl.w	#2,d5		/* longword indexing. */
		lea	htab,a2		/* point to start of decode table. */
		movea.l	0(a2,d5.w),a2	/* address of HABLINE writing mode fragment. */
		suba.w	a1,a1		/* default offset = 0. */
		tst.w	_multifill	/* multi-plane fill pattern? */
		beq	bf_loop	/* no, branch. */
		move.w	#32,a1		/* yes, offset = 32. */
*
*                                 a6 = copy of ptr to destination.
*	d7 = right mask.	  a5 = ptr to destination.
*	d6 = line loop counter.	  a4 = ptr to _FG_BP_1.
*	d5 = scratch.
*   a3 = # of bytes between video planes.
*
*	d4 = scratch.	  	  a2 = ptr to HABLINE writing mode fragment.
* 	d3 = # of bit_planes - 1. a1 = offset to next bit-plane's fill pattern.
*	d2 = inner loop count.	  a0 = ptr to fill pattern.
*	d1 = scratch.
*	d0 = left mask (or left "and" right masks).
*
*
bf_loop:
		movem.l    a4-a5,-(a7)
		move.w     d3,-(a7)
		jsr	(a2)		/* draw a horizontal line. */

		addq.w	#1,patindx(a6) 	/* increment pattern count. */
		addq.l	#2,pat_start(a6)	/* increment pattern pointer. */
		move.w	patindx(a6),a5	/* get pattern count */
		cmp.w	PIXLV(patmsk,a2),a5	/* pattern count > pattern maximum? */
		ble		bf_pat		/* no, branch. */
		move.l	PIXLV(patptr,a2),pat_start(a6) /* reset the pattern pointer */
		clr.w	patindx(a6)	/* reset the pattern count. */
bf_pat:
		movea.l	pat_start(a6),a0	/* point to the next line of pattern. */
		move.w     (a7)+,d3	/* restore video plane count */
		movem.l    (a7)+,a4-a5
		adda.w     PIXLV(v_lin_wr),a5
		dbra	d6,bf_loop	/* rectangle loop. */
		unlk       a6	/* remove temporary stack variables */
		rts

