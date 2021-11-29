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

#if TOSVERSION >= 0x400
#define V_FUNC(func,la,r) \
	move.l	PIXLV(LA_ROUTINES,la),r \
	move.l	func(r),r
#else
#define V_FUNC(func,la,r) \
	move.l	PIXLV((USERDEVINIT)+func,la),r
#endif

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
		xdef	_vtrap1
_vtrap1:	PIXLA(a0)
		move.l	(sp)+,PIXLV(retsav,a0)
		trap	#1
		PIXLA(a0)
		move.l	PIXLV(retsav,a0),-(sp)
		rts


#if (TOSVERSION >= 0x300)
#if !PLANES8
#define trap14sav q_circle
#endif
/* 306de: 00e0c0b4 */
		xdef	_vtrap14			; xbios trap
_vtrap14:	PIXLA(a0)
		move.l	(sp)+,PIXLV(trap14sav,a0)
		trap	#14
		PIXLA(a0)
		move.l	PIXLV(trap14sav,a0),-(sp)
		rts
#endif

#if TOSVERSION >= 0x400
/*
 * Same as above except we use this for SetScreen, and SetMode calls.
 * The reason you ask? Those call cause XBIOS calls (i.e. one level of
 * reentency).
 */
		xdef	_vtrap14b		; xbios trap
_vtrap14b:	PIXLA(a0)
		move.l	(sp)+,PIXLV(trapb14sav,a0)
		trap	#14
		PIXLA(a0)
		move.l	PIXLV(trapb14sav,a0),-(sp)
		rts
#endif

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

#if TOSVERSION >= 0x400
		xdef	_put_pix
_put_pix:
		PIXLA(a1)
		V_JUMP(V_PUTPIX,a1,a1)		; vec to put pix routine
#endif

#if VIDEL_SUPPORT
PX_PUTPIX:
		PIXLA(a1)
		move.l	PIXLV(PTSIN,a1),a0		; a0 -> PTSIN array
		move.w	(a0)+,d0		; d0 <- X coordinate
		move.w	(a0),d1			; d1 <- Y coordinate
#if BINEXACT
		mulu	PIXLV(v_lin_wr,a4),d1	; d1 <- y portion of offset ??? why (a4)?
		dc.w $c0f0,$01a0,$0b06     ; mulu	PIXLV(byt_per_pix,d0),d0	; d0 <- x portion of offset ??? why (d0)? it is assembled as 68030 instr
#else
		mulu	PIXLV(v_lin_wr,a1),d1	; d1 <- y portion of offset
		mulu	PIXLV(byt_per_pix,a1),d0	; d0 <- x portion of offset
#endif
		add.l	d0,d1			; d1 <- byte offs into mem frm
		move.l	_v_bas_ad,a0		; a0 -> base of screen
		add.l	d1,a0			; a0 -> (x,y)
		moveq.l	#0,d0			; d0 to be used as ret val
		move.l	PIXLV(INTIN,a1),a2		; a0 -> INTIN array
#if BINEXACT
		cmp.w	#16,PIXLV(v_planes,a4)	; see how many bits per pixel ??? why (a4)?
#else
		cmp.w	#16,PIXLV(v_planes,a1)	; see how many bits per pixel
#endif
		beq	PXPTP16			; do 16 bit case
		blt	PXPTP8			; do 8 bit case
		move.l	(a2),(a0)		; splat pixel
		rts

PXPTP16:	move.w	(a2),(a0)		; splat pixel
		rts

PXPTP8:		move.b	2(a2),(a0)		; splat pixel
		rts
#endif


#if TOSVERSION >= 0x400
		xdef ST_PUTPIX
ST_PUTPIX:
#else
/* 306de: 00e0c0e6 */
/* 206de: 00e0c446 */
/* 104de: 00fd06a6 */
		xdef	_put_pix
_put_pix:
#endif
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

#if TOSVERSION >= 0x400
		xdef	_get_pix
_get_pix:
		PIXLA(a1)
		V_JUMP(V_GETPIX,a1,a1)		; vec to get pix routine
#endif

#if VIDEL_SUPPORT
PX_GETPIX:
		PIXLA(a1)
		move.l	PIXLV(PTSIN,a1),a0		; a0 -> PTSIN array
		move.w	(a0)+,d0		; d0 <- X coordinate
		move.w	(a0),d1			; d1 <- Y coordinate
		mulu	PIXLV(v_lin_wr,a1),d1	; d1 <- y portion of offset
		mulu	PIXLV(byt_per_pix,a1),d0	; d0 <- x portion of offset
		add.l	d0,d1			; d1 <- byte offs into mem frm
		move.l	_v_bas_ad,a0		; a0 -> base of screen
		add.l	d1,a0			; a0 -> (x,y)
		moveq.l	#0,d0			; d0 to be used as ret val
		cmp.w	#16,PIXLV(v_planes,a1)	; see how many bits per pixel
		beq	PXGTP16			; do 16 bit case
		blt	PXGTP8			; do 8 bit case
		move.l	(a0),d0			; d0 <- pixel value
		rts

PXGTP16:	move.w	(a0),d0			; d0 <- pixel value
		rts

PXGTP8:		move.b	(a0),d0
		rts
#endif

#if TOSVERSION >= 0x400
		xdef ST_GETPIX
ST_GETPIX:
#else
/* 306de: 00e0c12e */
/* 206de: 00e0c48e */
/* 104de: 00fd06ee */
		xdef	_get_pix
_get_pix:
#endif
		PIXLA(a1)
#if (TOSVERSION >= 0x300) | !BINEXACT
		move.l	d3,-(sp)	; save register for "c"
#endif
		move.l	PIXLV(PTSIN,a1),a0	; a0 -> PTSIN array
#if VIDEL_SUPPORT
		moveq.l	#0,d0		; return value is a long so clear upper
#endif
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
#if (TOSVERSION >= 0x300) | !BINEXACT
		move.l	(sp)+,d3	; restore register for "c"
#endif
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
#if (TOSVERSION >= 0x300) | !BINEXACT
	movem.l d3-d7/a3-a5,-(sp)       ; save registers for "C"
	movem.w	36(sp),d4-d6		; d4 <- X1  d5 <- X2  d6 <- Y1
#else
	movem.w	4(sp),d4-d6		; d4 <- X1  d5 <- X2  d6 <- Y1
#endif
	exg	d5,d6			; d4 <- X1  d5 <- Y1  d6 <- X2

	LA(a4)
#if VIDEL_SUPPORT
	cmp.w	#PIXPACKED,LV(form_id,a4)	; see if we are in pix packed mode
	bne	fillLine0		; if not do interleaved mode
	jsr	px_fline		; HABLINE entry point for fill_line
	movem.l (sp)+,d3-d7/a3-a5       ; restore registers for "C"
	rts

fillLine0:
#endif
#if (TOSVERSION >= 0x300) | !BINEXACT
	jsr	fline			; HABLINE entry point for fill_line
	movem.l (sp)+,d3-d7/a3-a5       ; restore registers for "C"
	rts
#else
    bra fline
#endif

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
#if MULTI_LINEA
		movem.l d3-d7/a3-a6,-(sp) 	; save registers for "C"
vars set 40
		PIXLA(a6)
#else
#if (TOSVERSION >= 0x300) | !BINEXACT
		movem.l d3-d7/a3-a5,-(sp) 	; save registers for "C"
vars set 36
#else
vars set 4
#endif
		PIXLA(a6)
#endif
#if VIDEL_SUPPORT
		cmp.w	#PIXPACKED,form_id(a6)	; see if we are pix packe mode
		bne	end_intrlv_pts

*+
* Pixel packed case
*-
end_pix_pts:
		move.l	vars+4(sp),a0		; a0 -> Xleft
		move.l	vars+8(sp),a1		; a1 -> Xright
		moveq.l	#0,d0			; initialize return value

		move.w	vars+0(sp),d4		; d4 <- X coordinate
		cmp.w	PIXLV(XMN_CLIP,a6),d4	; ret if left of viewport Xmin
		bmi	epp_ret0
		cmp.w	PIXLV(XMX_CLIP,a6),d4
		bgt	epp_ret0		; ret if right of viewport Xmax

        move.w	vars+2(sp),d1		; d1 <- Y coordinate
		cmp.w	PIXLV(YMN_CLIP,a6),d1	; return if above viewport Ymin
		bmi	epp_ret0
		cmp.w	PIXLV(YMX_CLIP,a6),d1
		bgt	epp_ret0		; return if below viewport Ymax

		move.w	PIXLV(XMN_CLIP,a6),(a0)	; init end X left
		move.w	PIXLV(XMX_CLIP,a6),(a1)	; init end X right

		mulu	PIXLV(v_lin_wr,a6),d1	; d1 <- y portion of offset
		move.w	d4,d2			; d2 <- X coordinate
		mulu	PIXLV(byt_per_pix,a6),d2	; d2 <- x portion of offset
		add.l	d2,d1			; d1 <- byte offs into mem frm
		move.l	_v_bas_ad,a2		; a2 -> base of screen
		add.l	d1,a2			; a2 -> (x,y)


		cmp.w	#16,PIXLV(v_planes,a6)	; see how many bits per pixel
		beq	check16Left		; do 16 bits per pixel case
		blt	check8Left		; do 8 bits per pixel case

*+
*	a0	points to Xleft
*	a1	points to Xright
*	a2	points to the pixel in question
*
*	d4.w	X coordinate
*-

*+
* 32 bit case
*-
check32Left:	move.l	(a2),d1			; d1 <- value of current pix
		move.w	d4,d2			; d2 <- x position
		move.w	PIXLV(XMN_CLIP,a6),d3	; d3 <- x minimum position
		move.l	a2,a3			; a3 -> current X position
		addq.l	#4,a3			; adjust for predecrement

left32Loop:	cmp.l	-(a3),d1		; see if color matches
		beq	l32lSkip		; if so then skip
		addq.w	#1,d2			; d2 <- end X left
		move.w	d2,(a0)			; store end Xleft
		bra	check32Right		; go right no
l32lSkip:	subq.w	#1,d2			; move one pixel left
		cmp.w	d2,d3			; see if we reached endpoint
		ble	left32Loop		; if not the loop back

check32Right:	move.w	d4,d2			; d2 <- x position
		move.w	PIXLV(XMX_CLIP,a6),d3	; d3 <- x maximum position
		move.l	a2,a3			; a3 -> current X position

right32Loop:	cmp.l	(a3)+,d1		; see if color matches
		beq	r32lSkip		; if so then skip
		subq.w	#1,d2			; d2 <- end X right
		move.w	d2,(a1)			; store end Xright
		bra	epp_ret1		; found end point and skip
r32lSkip:	addq.w	#1,d2			; advance x position
		cmp.w	d2,d3			; see if we reached end point
		bge	right32Loop		; if so then leave
		bra	epp_ret1		; done with search now leave

*+
* 16 bit case
*-
check16Left:
		move.w	(a2),d1			; d1 <- value of current pix
		swap	d1			; search_color is a long (upper
		move.w	(a2),d1			; and lower words are equal)
		move.w	d4,d2			; d2 <- x position
		move.w	PIXLV(XMN_CLIP,a6),d3	; d3 <- x minimum position
		move.l	a2,a3			; a3 -> current X position
		addq.l	#2,a3			; adjust for predecrement

left16Loop:	cmp.w	-(a3),d1		; see if color matches
		beq	l16lSkip		; if so then skip
		addq.w	#1,d2			; d2 <- end X left
		move.w	d2,(a0)			; store end Xleft
		bra	check16Right		; go right no
l16lSkip:	subq.w	#1,d2			; move one pixel left
		cmp.w	d2,d3			; see if we reached endpoint
		ble	left16Loop		; if not the loop back

check16Right:	move.w	d4,d2			; d2 <- x position
		move.w	PIXLV(XMX_CLIP,a6),d3	; d3 <- x maximum position
		move.l	a2,a3			; a3 -> current X position

right16Loop:	cmp.w	(a3)+,d1		; see if color matches
		beq	r16lSkip		; if so then skip
		subq.w	#1,d2			; d2 <- end X right
		move.w	d2,(a1)			; store end Xright
		bra	epp_ret1		; found end point and skip
r16lSkip:	addq.w	#1,d2			; advance x position
		cmp.w	d2,d3			; see if we reached end point
		bge	right16Loop		; if so then leave
		bra	epp_ret1		; done with search now leave

*+
* 8 bit case
*-
check8Left:	moveq.l	#0,d1			; clear upper bits of long var
		move.b	(a2),d1			; d1 <- value of current pix
		move.w	d4,d2			; d2 <- x position
		move.w	PIXLV(XMN_CLIP,a6),d3	; d3 <- x minimum position
		move.l	a2,a3			; a3 -> current X position
		addq.l	#4,a3			; adjust for predecrement

left8Loop:	cmp.b	-(a3),d1		; see if color matches
		beq	l8lSkip			; if so then skip
		addq.w	#1,d2			; d2 <- end X left
		move.w	d2,(a0)			; store end Xleft
		bra	check8Right		; go right no
l8lSkip:	subq.w	#1,d2			; move one pixel left
		cmp.w	d2,d3			; see if we reached endpoint
		ble	left8Loop		; if not the loop back

check8Right:	move.w	d4,d2			; d2 <- x position
		move.w	PIXLV(XMX_CLIP,a6),d3	; d3 <- x maximum position
		move.l	a2,a3			; a3 -> current X position

right8Loop:	cmp.b	(a3)+,d1		; see if color matches
		beq	r8lSkip			; if so then skip
		subq.w	#1,d2			; d2 <- end X right
		move.w	d2,(a1)			; store end Xright
		bra	epp_ret1		; found end point and skip
r8lSkip:	addq.w	#1,d2			; advance x position
		cmp.w	d2,d3			; see if we reached end point
		bge	right8Loop		; if so then leave
		and.l	#$FF,d1			; clear unused bits

epp_ret1:	move.w	_seed_type,d0
		cmp.l	_search_color,d1
		beq	epp_ret0		; ret seg is of search color

		eor.w	#1,d0			; ret seg not of search color

epp_ret0:
#if MULTI_LINEA
		movem.l (sp)+,d3-d7/a3-a6	; restore registers for "C"
#else
#if (TOSVERSION >= 0x300) | !BINEXACT
		movem.l (sp)+,d3-d7/a3-a5	; restore registers for "C"
#endif
#endif
		rts

*+
* Interleave case
*-
#endif
end_intrlv_pts:
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
#if VIDEL_SUPPORT
		and.l	#$FFFF,d2	; clear upper word of long variable
		cmp.l	_search_color,d2
#else
		cmp.w	_search_color,d2
#endif
		beq	ep_is_search	; return segment is of search color

		eor.w	#1,d0		; return segment not of search color

ep_is_search:
		eor.w	#0,d0		; what the fuck is this ?
#if MULTI_LINEA
		movem.l (sp)+,d3-d7/a3-a6 ; restore registers for "C"
#else
#if (TOSVERSION >= 0x300) | !BINEXACT
		movem.l (sp)+,d3-d7/a3-a5 ; restore registers for "C"
#endif
#endif
		rts


ep_ret0:
		moveq.l	#0,d0		; return(0). (failure)
#if MULTI_LINEA
		movem.l (sp)+,d3-d7/a3-a6 ; restore registers for "C"
#else
#if (TOSVERSION >= 0x300) | !BINEXACT
		movem.l (sp)+,d3-d7/a3-a5 ; restore registers for "C"
#endif
#endif
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

#if TOSVERSION >= 0x400
		xdef	_RECTFILL
_RECTFILL:
	PIXLA(a2)
	V_JUMP(V_RECTFILL,a2,a5)	; vec to rectangle filler
#endif



rf_null:

	movem.w	d4-d7,(a0)		; the old routine saved clipped values
	rts


#if TOSVERSION >= 0x400
		xdef	ST_RECTFILL
ST_RECTFILL:
#else
/* 306de: 00e0c28a */
		xdef	_RECTFILL
_RECTFILL: ds.b 0
#if !PLANES8
/* 104de: 00fd082e */
		xdef	M_RECTFILL
M_RECTFILL: ds.b 0
#endif
#endif
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

#if TOSVERSION >= 0x300  /* d1/d2 swapped in older versions */
	move.w	d6,d2			; d2 <- X2
	asr.w	#4,d2			; d2 <- word containing X2

	lea	lf_tab,a1		; a1 -> left fringe mask table
	moveq.l	#$0F,d1			; d1 <- mod 16 mask

	and.w	d1,d4			; d4 <- X1 mod 16
	add.w	d4,d4			; d4 <- offset into fringe table
	move.w	0(a1,d4.w),d4		; d4 <- left fringe mask  (0:Dst 1:Src)

	and.w	d1,d6			; d6 <- X2 mod 16
	add.w	d6,d6			; d6 <- offset into right fringe table
	move.w	2(a1,d6.w),d6		; d6 <- inverted right fringe mask
	not.w	d6			; d6 <- right fringe mask (0:Dst 1:Src)

	sub.w	d0,d2			; d2 <- span -1 of rectangle in words
#else
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
#endif
	bne	select_version		; 1 word span =>  merge lf & rt masks

	and.w	d6,d4			; d4 <- single fringe mask

select_version:

	V_JUMP(V_RECT,a2,a5)		; vec to rectangle filler


******************************************************************************
*									     *
* _SetOverlay(x1, y1, x2, y2, flag)					     *
*									     *
* Set or clear the overlay plane on a sparrow. x1,y1 is the upper left	     *
* corner, x2,y2 is the lower right corner. When flag = 0 we clear the	     *
* overlay plane when flag = 1 we set the overlay plane.			     *
*									     *
* registers cloberred d0-d2/a0-a2					     *
*									     *
******************************************************************************

#if VIDEL_SUPPORT
		xdef	_SetOverlay
_SetOverlay:

	PIXLA(a0)
	movem.w	d3-d4,-(sp)		; save registers
	move.w	8(sp),d0		; d0 <- X1
	move.w	10(sp),d1		; d1 <- Y1
	move.w	12(sp),d2		; d2 <- X2
	move.w	14(sp),d3		; d3 <- Y2

	sub.w	d0,d2			; d2 <- width of area
	sub.w	d1,d3			; d3 <- height of area

	move.l	_v_bas_ad,a1		; a1 -> strt of dst form (0,0)

	mulu	#2,d0			; d0 <- x portion of offset
	mulu	PIXLV(v_lin_wr,a0),d1	; d1 <- y portion of offset
	add.l	d0,d1			; d1 <- byte offs into mem frm
	add.l	d1,a1			; a1 -> (x,y)

	move.w	d2,d0			; d0 <- width of area in pixels
	subq.w	#1,d0			; d0 <- delta X - 1
	move.w	d3,d1			; d1 <- Y1
	subq.w	#1,d1			; d1 <- delta Y - 1
	move.w	PIXLV(v_lin_wr,a0),d2	; d2 <- screen line wrap in bytes

	tst.w	12(sp)			; see if set flag is on
	bne	ClearFlag		; if not then clear
	move.w	SetMask(pc),d4		; d4 <- set mask
	bra	SetLine			; set the overlay bit

ClearFlag:
	move.w	ClearMask(pc),d4	; d4 <- clear mask
	bra	ClearLine		; clear the overlay bit

*+
*	wipe out or set a region with a mask
*
*	in	d0.w		delta X - 1
*		d1.w		delta Y - 1
*		d2.w		screen line wrap in bytes
*		d4.w		mask
*
*		a1.l		point to the X,Y position
*-
ClearLine:
	move.l	a1,a2			; a2 -> current line
	move.w	d0,d3			; d3 <- delta X - 1

ClearLoop:
	and.w	d4,(a2)+		; splat text background
	dbra	d3,ClearLoop		; do next pixel
	add.w	d2,a1			; a1 -> to next line
	dbra	d1,ClearLine		; do next line
	movem.w	(sp)+,d3-d4		; restore registers
	rts

SetLine:
	move.l	a1,a2			; a2 -> current line
	move.w	d0,d3			; d3 <- delta X - 1

SetLoop:
	or.w	d4,(a2)+		; splat text background
	dbra	d3,SetLoop		; do next pixel
	add.w	d2,a1			; a1 -> to next line
	dbra	d1,SetLine		; do next line
	movem.w	(sp)+,d3-d4		; restore registers
	rts

ClearMask:	dc.w	$ffdf
SetMask:	dc.w	$0020

******************************************************************************
*									     *
* _SetMasks(orMask, andMask, overlay)					     *
*									     *
* During the the vdi set color call a pen value gets calculated. Before it   *
* is assigned it first gets ored with "orMask" then it is anded with	     *
* "andMask" the final value becomes the value of the pen. This function	     *
* applies only in true color mode (16, 32 bits per pixel. Initially the      *
* "orMask" is initialized to 0L and the "andMask" is initialized to -1L      *
*									     *
* registers cloberred a0					             *
*									     *
******************************************************************************


		xdef	_SetMasks
_SetMasks:
	PIXLA(a0)
	move.l	4(sp),PIXLV(col_or_mask,a0)	; set the or mask for vs_color
	move.l	8(sp),PIXLV(col_and_mask,a0)	; set the and mask for vs_color
* Sparrow only stuff follows
* 920910 towns changed to or.w from move.w to preserve rest of shift
*              register
	move.w	12(sp),d0
	beq	clr_olay		; clear the overlay
	or.w	#$0200,$FFFF8266	; Set the overlay bit
	bra	setm_exit
clr_olay:
	and.w	#$fdff,$FFFF8266	; clear bit

* Sparrow only stuff earlier
setm_exit:
	rts

#endif /* VIDEL_SUPPORT */
