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

#define V_FUNC(func,la,r) \
	move.l	PIXLV((LA_ROUTINES)+func,la),r

#define V_CALL(func,la,r) \
		V_FUNC(func,la,r) \
		jsr (r)
#define V_JUMP(func,la,r) \
		V_FUNC(func,la,r) \
		jmp (r)


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
		add.l	d1,a1		; a1 -> 1st word containing pixel

		eor.w	#$000F,d0	; d0 <- bit number corresponding to X
		clr.w	d1
		bset.l	d0,d1		; d1 <- OR mask
		move.w	d1,d0		; d0 <- OR mask  (for setting a bit)
		not.w	d0		; d0 <- AND mask (for clearing a bit)

		move.w	PIXLV(v_planes,a2),d2	; d2 <- planes
		subq.w	#1,d2			; d2 <- dbra plane counter
		move.l	PIXLV(INTIN,a2),a0		; a0 -> INTIN array
		move.w	(a0),d3			; d3 <- pixel value

ppx_loop:	ror.w	#1,d3		; rotate pixel bit and put in carry.
		bcc	ppx_clr		; if 0, clear the bit.

ppx_set:	or.w	d1,(a1)+	; if 1, set the bit.
		dbra	d2,ppx_loop
		rts

ppx_clr:	and.w	d0,(a1)+	; clear the bit.
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
		add.l	d1,a0		; a0 -> 1st word of pixel

		eor.w	#$000F,d0	; d0 <- bit number corresponding to X
		clr.w	d1
		bset.l	d0,d1		; d1 <- pixel mask corresponding to X

		move.w	PIXLV(v_planes,a1),d2	; d2 <- planes
		move.w	d2,d0
		add.w	d0,d0			; d0 <- off to nxt wrd in plane
		subq.w	#1,d2			; d2 <- dbra plane counter
		add.w	d0,a0			; a0 ->highest order bitplane+2
		moveq.l	#0,d0			; init pixel acc and cy:0

gpx_loop:	move.w	-(a0),d3	; d3 <- current plane word
		and.w	d1,d3		; test the current word's bit
		sne	d3		; bit=0 cy:0       bit=1 cy:1
		add.b	d3,d3		; set carry flag to bit value
		addx.w	d0,d0		; shift in latest bit
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
	movem.w	4(sp),d4-d6		; d4 <- X1  d5 <- X2  d6 <- Y1
	exg	d5,d6			; d4 <- X1  d5 <- Y1  d6 <- X2

	LA(a4)
    bra fline

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
		move.w	PIXLV(v_planes,a6),d3	; d3 <- planes
		move.w	d3,a3
		add.w	a3,a3			; a3 <- off to nxt wrd in plane
		subq.w	#1,d3			; d3 <- dbra plane counter
		move.w	vars+0(sp),d0		; d0 <- X coordinate

		bsr	concat			; d1<-physical off d0<-X mod 16
		add.l	d1,a5			; a5 -> word containing (X,Y)


*	a5 = ptr to word containing low-order pixel bit.
*	a4 = scratch.
*
*	d4 = scratch
*	d3 = planes -1
*	d1 = scratch
*	d0 = X mod 16


		eor.w	#$000F,d0	; d0 <- bit number corresponding to X
		clr.w	d1
		bset.l	d0,d1		; d1 <- OR mask
		move.w	d1,d0		; d0 <- pixel mask corresponding to X

		move.w	d1,a0		; a0 <- copy of pixel mask
		move.w	d3,a1		; a1 <- copy of dbra plane counter
		move.l	a5,a2		; a2 -> root word of search span
		add.w	a3,a5		; a5 -> next word in plane
		moveq.l	#0,d1		; d1 <- initial pixel accumulator

px_loop:	move.w	-(a5),d4	; d4 <- this plane's word
		and.w	d0,d4		; isolate the bit of interest
		sne	d4		; copy the bit to all bits
		add.b	d4,d4		; move the bit into the carry flag
		addx.w	d1,d1		; shift the new bit into the LSB of d1
		dbra	d3,px_loop	; do the next plane

		move.w	a1,d3			; d3 <- dbra plane counter
		move.w	vars+0(sp),d7		; d7 <- X coordinate
		move.w	PIXLV(XMX_CLIP,a6),d6	; d6 <- X max
		move.w	d1,d2			; d2 <- target color of search



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


rnedg_loop:	cmp.w	d1,d2		; Search to the right while the
		bne	rt_nedge	; current pixel is the target
		cmp.w	d6,d7		; color and X is not greater
		bgt	rt_nedge	; than Xmax


*	    Search to the right

		moveq.l	#0,d1		; d1 <- initial pixel accumulator
		addq.w	#1,d7		; d7 <- pixel to the right of X
		ror.w	#1,d0		; d0 <- corresponding pixel mask
		bcc	rn_gpx		; check for word fault

		add.w	a3,a5		; a5 -> next word to right

rn_gpx:		add.w	a3,a5		; a5 -> hi-order word +2

rnpx_loop:	move.w	-(a5),d4	; d4 <- this plane's word
		and.w	d0,d4		; isolate the bit of interest
		sne	d4		; bit=0 d4:00   bit=1 d4:FF
		add.b	d4,d4		; put the bit into the carry flag
		addx.w	d1,d1		; d1 <- new bit in LSB
		dbra	d3,rnpx_loop	; do the next plane

		move.w	a1,d3		; d3 <- dbra plane counter
		bra	rnedg_loop


rt_nedge:	move.l	a2,a5			; a5 -> root wrd of search span
		move.l	vars+8(sp),a4		; a4 -> end Xright
		subq.w	#1,d7			; d7 <- end Xright
		move.w	d7,(a4)			; store end Xright
		move.w	vars+0(sp),d7		; d7 <- initial X
		move.w	PIXLV(XMN_CLIP,a6),d6	; d6 <- X min
		move.w	a0,d0			; d0 <- initial pixel mask



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

		move.w	d2,d1		; d1 <- is the target color

lnedg_loop:	cmp.w	d1,d2		; Search to the left while the
		bne	lt_nedge	; current pixel is the target
		cmp.w	d6,d7		; color and X is not less
		blt	lt_nedge	; than Xmin

*	    Search to the left

		moveq.l	#0,d1		; d1 <- initial pixel accumulator
		subq.w	#1,d7		; d7 <- next pixel to the left
		rol.w	#1,d0		; d0 <- corresponding pixel mask
		bcs	lnpx_loop	; skip if word fault

		add.w	a3,a5		; a5 -> word after hi-order bit plane

lnpx_loop:	move.w	-(a5),d4	; d4 <- this plane's word
		and.w	d0,d4		; isolate the bit of interest
		sne	d4		; bit=0 d4:00   bit=1 d4:FF
		add.b	d4,d4		; put the bit into the carry flag
		addx.w	d1,d1		; d1 <- new bit in LSB
		dbra	d3,lnpx_loop	; do the next plane

		move.w	a1,d3		; d3 <- dbra plane counter
		bra	lnedg_loop


lt_nedge:
		addq.w	#1,d7		; d7 <- minimum X of span
		move.l	vars+4(sp),a4	; a4 -> end Xleft
		move.w	d7,(a4)		; store end Xleft

		move.w	_seed_type,d0
		cmp.w	_search_color,d2
		beq	ep_is_search	; return segment is of search color

		eor.w	#1,d0		; return segment not of search color

ep_is_search:
		eor.w	#0,d0		; what the fuck is this ?
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

rf_null:
	movem.w	d4-d7,(a0)		; the old routine saved clipped values
	rts


/* 306de: 00e0c28a */
		xdef	_RECTFILL
_RECTFILL: ds.b 0
/* 104de: 00fd082e */
		xdef	M_RECTFILL
M_RECTFILL: ds.b 0
	LA(a2)
	lea	LV(X1,a2),a0		; a0 -> rectangle endpoints array
	movem.w	(a0),d4-d7		; d4<-X1   d5<-Y1   d6<-X2   d7<-Y2

	lea	LV(CLIP,a2),a1		; a1 -> clipping flag
	tst.w	(a1)+			; a1 -> 1st entry in clipping array
	beq	rf_noclip		; if no clipping, don't dawdle here.


*   Clipping is in effect

	movem.w	(a1),d0-d3		; d0<-Xmin d1<-Ymin d2<-Xmax d3<-Ymax

	cmp.w	d0,d4			; X1 < clipping Xmin ?
	bge	rf_xmax			; no  => X1 is in bounds
	cmp.w	d0,d6			; X2 < clipping Xmin ?
	blt	rf_null			; yes => null rectangle

	move.w	d0,d4			; d4 <- clipped X1

rf_xmax:

	cmp.w	d2,d6			; X2 > clipping Xmax ?
	ble	rf_yclip		; no  => X2 is in bounds
	cmp.w	d2,d4			; X1 > clipping Xmax ?
	bgt	rf_null			; yes => null rectangle

	move.w	d2,d6			; d6 <- clipped X2

rf_yclip:

	cmp.w	d1,d5			; Y1 < clipping Ymin ?
	bge	rf_ymax			; no  => Y1 is in bounds
	cmp.w	d1,d7			; Y2 < clipping Ymin ?
	blt	rf_null			; yes => null rectangle

	move.w	d1,d5			; d5 <- clipped Y1

rf_ymax:

	cmp.w	d3,d7			; Y2 > clipping Ymax ?
	ble	rf_rsave		; no  => Y2 is in bounds
	cmp.w	d3,d5			; Y1 > clipping Ymax ?
	bgt	rf_null			; yes => null rectangle

	move.w	d3,d7			; d7 <- clipped Y2


*   To maintain compatibility with previous versions of this routine,
*   the clipped values must be saved to their original memory locations.

rf_rsave:

	movem.w	d4-d7,(a0)		; save clipped values: X1 Y1 X2 Y2

rf_noclip:

	move.w	d4,d0			; d0 <- X1
	asr.w	#4,d0			; d0 <- word containing X1

	move.w	d6,d1			; d2 <- X2
	asr.w	#4,d1			; d2 <- word containing X2

	lea	lf_tab,a1		; a1 -> left fringe mask table
	moveq.l	#$0F,d2			; d1 <- mod 16 mask

	and.w	d2,d4			; d4 <- X1 mod 16
	add.w	d4,d4			; d4 <- offset into fringe table
	move.w	0(a1,d4.w),d4		; d4 <- left fringe mask  (0:Dst 1:Src)

	and.w	d2,d6			; d6 <- X2 mod 16
	add.w	d6,d6			; d6 <- offset into right fringe table
	move.w	2(a1,d6.w),d6		; d6 <- inverted right fringe mask
	not.w	d6			; d6 <- right fringe mask (0:Dst 1:Src)

	sub.w	d0,d1			; d2 <- span -1 of rectangle in words

	bne	select_version		; 1 word span =>  merge lf & rt masks

	and.w	d6,d4			; d4 <- single fringe mask

select_version:

	V_JUMP(V_RECT,a2,a5)		; vec to rectangle filler

