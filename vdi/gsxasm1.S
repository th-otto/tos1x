********************************  gsxasm1.s  **********************************
*
* =============================================================================
* $Author: lozben $	$Date: 91/02/13 11:37:39 $
* =============================================================================
*
* Revision 3.2  91/02/13  11:37:39  lozben
* Adjusted the code to work with the multiple linea variable structures..
*
* Revision 3.1  91/02/07  18:35:38  lozben
* Adjusted the code to work with the multiple linea variable structures.
*
* Revision 3.0  91/01/03  15:09:28  lozben
* New generation VDI
*
* Revision 2.5  90/05/03  16:36:03  lozben
* Added conditional code in pixfrag() to clear the instruction cache
* if one is available. We do this because we compile code on the stack.
*
* Revision 2.4  90/02/16  12:22:34  lozben
* Fixed some of the code so that it can be assembled with mas.
*
* Revision 2.3  89/05/16  13:01:52  lozben
* Changed pix_frag() to deal with a color index (FG_B_PLANES) instead
* of dealing with back plane flags (FG_BP_[1,2,3,4]).
*
* Revision 2.2  89/04/13  20:14:48  lozben
* Moved hb_vline(), hb_hline() into another file. The idea
* is to have all the hard blit code in independent files.
*
* Revision 2.1  89/02/21  17:21:12  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
*
*******************************************************************************

#include "config.h"
#include "vdidefs.h"
#include "lineaequ.inc"
#include "asmdefs.h"
#include "tosvars.inc"

MAX_PLANES	equ	 4		; maximum planes for pixel fragment
FRAG_LEN	equ  MAX_PLANES*4+4 ; space for fragment of 16 planes


/* v_planes == 0; stupid as68 does not optimize it */
#define V_PLANES v_planes

	text

*******************************************************************************
*******************************************************************************
**
**	_vec_len
**
**		This routine computes the length of a vector using the
**		formula: SQRT( dX**2 + dY**2 )
**
**		input:	4(sp) = dX
**			6(sp) = dY
**
**		output: d0 = SQRT( dX**2 + dY**2 )
**
**		destroys: d0-d4
**
*******************************************************************************
*******************************************************************************

/* 306de: 00e07a38 */
/* 104de: 00fcac28 */
/* 106de: 00e0ae54 */
		xdef	_vec_len
_vec_len:
		move.w	4(sp),d0	; d0 <- dX
		muls	d0,d0		; d0 <- dX**2
		move.w	6(sp),d1	; d1 <- dY
		muls	d1,d1		; d1 <- dY**2
		add.l	d0,d1		; d1 <- dX**2 + dY**2
		beq	vl_out		; quit on null length

*   Compute an initial upper and lower bound on the square root. The lower
*   bound is the largest number that is no more than half the length of
*   The square; the upper bound is twice the lower bound.

		move.l	d1,d0		; d0 <- dX**2 + dY**2
		moveq.l	#00,d2		; d2 <- initial exponent: 2**00
		cmp.l	#$10000,d1	; significant digits in high word?
		bcs	bds_lp		; if so, concentrate on high word.

		swap	d1		; d1 <- high word of square
		move.w	#16,d2		; d2 <- initial exponent: 2**16

bds_lp:		cmp.w	#1,d1		; any significant digits left ?
		beq	bds_end		; no => time to calculate bounds

		addq.w	#1,d2		; d2 <- exponent +1
		lsr.w	#1,d1		; d1 <- square/2
		bra	bds_lp

bds_end:	asr.w	#1,d2		; d2 <- exponent/2  (square root)
		moveq.l	#1,d3
		asl.w	d2,d3		; d3 <- initial lower bound
		move.w	d3,d2
		asl.w	#1,d2		; d2 <- initial upper bound
		bne	srch_lp		; check for overflow

		subq.w	#1,d2		; d2 <- maximum value: FFFF


*   Now, perform a binary search for the square root.

srch_lp:	move.w	d2,d1		; d1 <- upper bound
		sub.w	d3,d1		; d1 <- upper bound - lower bound
		cmp.w	#1,d1		;
		beq	srch_end	; quit when the delta is 1

		asr.w	#1,d1		; d1 <- half the difference
		add.w	d3,d1		; d1 <- midway 'tween the boundries
		move.w	d1,d4		; d4 <- copy of candidate
		mulu	d1,d1		; d1 <- candidate**2
		cmp.l	d0,d1		; compare with target
		bhi	hi_adjust	; if candidate too large, branch.
		bcs	lo_adjust	; if candidate too small, branch.

		move.w	d4,d0		; d0 <- exactly the square root
		rts


hi_adjust:	move.w	d4,d2		; d2 <- new upper bound
		bra	srch_lp

lo_adjust:	move.w	d4,d3		; d3 <- new lower bound
		bra	srch_lp

srch_end:	move.w	d3,d0		; no match: use the lower bound

vl_out:		rts



*******************************************************************************
*******************************************************************************
**
**	_CLC_FLIT
**
**		This routine calculates the fill intersections for a list of
**	vectors.  The x-intersection of each vector with the scan-line of
**	interest is calculated and inserted into a buffer which is then
**	sorted in ascending order.  The resulting array of x-values are then
**	pulled out pair-wise and used as inputs to "_HABLINE".
**
**		input:	CONTRL[1] = number of vectors.
**			PTSIN[]   = array of vertices.
**			Y1        = scan-line to calculate intersections for
**
**		output: fil_int  = number of intersections.
**			fill_buf  = array of x-values.
**
**		destroys: everything.
**
*******************************************************************************
*******************************************************************************

#define _fill_buffer _dskbuf

/* stupid as68 does not optimize it away */
#define x1  0
y1		equ	2
x2		equ	4
y2		equ	6


		xdef	M_CLC_FLIT
M_CLC_FLIT: ds.b 0

/* 306de: 00e07a9a */
/* 104de: 00fcac8a */
		xdef	_CLC_FLIT
_CLC_FLIT:
		PIXLA(a2)
		move.l	PIXLV(CONTRL,a2),a0
		move.w	2(a0),d0	; d0 <- number of vectors
		subq.w	#1,d0		; d0 <- dbra counter

		move.l	PIXLV(PTSIN,a2),a0		; a0 -> array of vertices
		lea	_fill_buffer,a1		; a1 -> array of X coordinates
		move.w	#0,PIXLV(fil_intersect,a2)	; init cnt of fill intrsctions

flit_lp:	move.w	y2(a0),d1	; d1 <- Y coordinate of 2nd endpoint
		move.w	y1(a0),d2	; d2 <- Y coordinate of 1st endpoint
		sub.w	d2,d1		; d1 <- dY
		beq	no_fill_int	; Ignore Horizantal Vectors

		move.w	PIXLV(Y1,a2),d3	; d3 <- scanline Y
		move.w	d3,d4
		sub.w	d2,d4		; d4 <- dY1
		sub.w	y2(a0),d3	; d3 <- dY2
		move.w	d4,d2
		eor.w	d3,d2		; are the signs equal?
		bpl	no_fill_int	; yes, ignore this vector.


*    This test also handles the case when dY1 = 0 or dY2 = 0.  Thus, the
*    singularity case discussed in Newman & Sproull is properly handled.

		move.w	x2(a0),d2	; d2 <-   X2
		sub.w	x1(a0),d2	; d2 <-   dX	   (really dX-1)
		asl.w	#1,d2		; d2 <-  2dX       (greater precision)
		muls	d2,d4		; d4 <- 2(dX * dY1)
		divs	d1,d4		; d4 <- 2(dX * dY1) /dY
		bmi	int_neg


int_pos:	addq.w	#1,d4		; compensate for round off error
		asr.w	#1,d4		; d4 <-  (dX * dY1) /dY

ld_fill_int:	add.w	x1(a0),d4		; d4 <- ((dX * dY1) /dY) + X1
		move.w	d4,(a1)+		; put intrsctn X into fill buf
		addq.w	#1,PIXLV(fil_intersect,a2)	; increment intersection count

no_fill_int:	lea	4(a0),a0		; a0 -> next pair of endpoints
		dbra	d0,flit_lp


*   Now that all the intersections have been found, sort them.

sort_fill_int:	move.w	PIXLV(fil_intersect,a2),d0	; d0 <- intersections
		bne	sfi_cont
		rts				; quit if nothing to sort

sfi_cont:	lea	_fill_buffer,a0		; a0 -> list of intersections
		bsr	bub_sort		; bubble-sort it


*   Now, do the necessary work to fill between the intersections.

		move.w	PIXLV(fil_intersect,a2),d0
		asr.w	#1,d0			; d0 <- number of x-pairs.
		subq.w	#1,d0			; d0 <- dbra counter
		tst.w	PIXLV(CLIP,a2)		; is clipping on?
		bne	dr_clip			; yes, branch.

draw_lp:	move.w	(a1)+,PIXLV(X1,a2)	; grab a pair of X intersections.
		move.w	(a1)+,PIXLV(X2,a2)
		move.w	d0,-(sp)	; save the count
		move.l	a1,-(sp)	; save the pointer
		bsr	_HABLINE	; fill between X's.
		PIXLA(a2)
		move.l	(sp)+,a1	; a1 -> next pair of points
		move.w	(sp)+,d0	; d0 <- dbra pair counter
		dbra	d0,draw_lp
		rts


dr_clip:	move.w	(a1)+,PIXLV(X1,a2)		; grab a pair of X intrsections
		move.w	(a1)+,PIXLV(X2,a2)
		move.w	PIXLV(XMN_CLIP,a2),d1	; clip X pair to minimum
		move.w	PIXLV(X1,a2),d2
		move.w	PIXLV(X2,a2),d3
		cmp.w	d1,d2		; is X1 < MINIMUM X ?
		bge	drc_1		; if so, check for a total eclipse

		cmp.w	d1,d3		; is X2 < minimum X ?
		blt	drc_end		; if so, segment is totally obscured

		move.w	d1,PIXLV(X1,a2)		; clip X1 to minimum

drc_1:		move.w	PIXLV(XMX_CLIP,a2),d1	; clip X pair to maximum
		cmp.w	d1,d3			; is X2 > maximum X ?
		ble	drc_2			; no => draw segment

		cmp.w	d1,d2		; is X1 > maximum X ?
		bgt	drc_end		; if so, segment is totally obscured

		move.w	d1,PIXLV(X2,a2)	; clip X2 to maximum

drc_2:		move.w	d0,-(sp)	; save the dbra count
		move.l	a1,-(sp)	; save the pointer to the point list
		bsr	_HABLINE	; fill between the X1 and X2
		PIXLA(a2)
		move.l	(sp)+,a1	; a1 -> next point pair
		move.w	(sp)+,d0	; d0 <- dbra count
drc_end:	dbra	d0,dr_clip
		rts
int_neg:	neg.w	d4		; Matt did it this way and it works
		addq.w	#1,d4
		asr.w	#1,d4
		neg.w	d4
		bra	ld_fill_int



*******************************************************************************
*******************************************************************************
**
**	bub_sort
**
**		This routine bubble-sorts an array of words into ascending
**		order.
**
**		input:	a0 = ptr to start of array.
**			d0 = number of words in array.	(unsigned word)
**
**		output: a1 = ptr to start of sorted array.
**
**		destroys: d0-d2/a0-a1
**
*******************************************************************************
*******************************************************************************


bub_sort:	tst.w	d0		; d0 <- number of compares -1
		beq	bs_out		; there must be more than one point
		subq.w     #1,d0
		beq	bs_out
		subq.w     #1,d0

		move.w	d0,d1		; d1 <- copy of swap count
		move.l	a0,a1		; a1 -> start of point list

bsl0_init:	move.w	d1,d0		; d0 <- initial dbra count
		move.l	a1,a0		; a1 -> start of list
bs_lp0:		move.w	(a0)+,d2	; d2 <- X1
		cmp.w	(a0),d2		; compare with X2
		ble	bs_noswap	; if in ascending order, skip exchange

		move.w	(a0),-2(a0)	; X1' <- X2
		move.w	d2,(a0)		; X2' <- X1
bs_noswap:	dbra	d0,bs_lp0	; completes 1 pass of the sort.
*					; the largest word has been bubbled
*					; down to the end of the array.
bsl1_end:	dbra	d1,bsl0_init	; shorten the count for the next pass.

bs_out:		rts


*******************************************************************************
*******************************************************************************
**
**  smul_div (m1,m2,d1)
**
**	( ( M1 * M2 ) / D1 ) + 1
**	M1 = signed 16 bit integer
**	M2 = unsigned 15 bit integer
**	D1 = signed 16 bit integer
**
*******************************************************************************
*******************************************************************************

/* 306de: 00e07bbe */
		xdef	_SMUL_DIV
_SMUL_DIV:	moveq.l	#1,d1		; d1 <- positive increment
		move.w	6(sp),d0
		muls	4(sp),d0	; d0 <- M2 * M1
		bpl	smd_1

		neg.w	d1		; d1 <- negative increment

smd_1:		move.w	8(sp),d2	; d2 <- divisor  (D1)
		divs	d2,d0		; d0 <- M2 * M1 / D1
		and.w	d2,d2		; was divisor negative ?
		bpl	smd_2

		neg.w	d1		; negate increment
		neg.w	d2		; d2 <- positive divisor

smd_2:		move.l	d3,-(sp)
		move.l	d0,d3
		swap	d3		; d3[15:00] <- remainder
		and.w d3,d3
		bpl	smd_3		; the remainder must be positive

		neg.w	d3		; d3[31:16] <- positive remainder

smd_3:		
		asl.w	#1,d3
		cmp.w	d2,d3
		blt	smd_4		; if remainder*2 > divisor,

		add.w	d1,d0		; round up

smd_4:		move.l	(sp)+,d3
		rts


*******************************************************************************
*******************************************************************************
**
**	comments:
**
**	  Two bugs have been found and fixed in this 68000 implementation
**	  of these VDI line-drawing routines.  Both bugs were due to
**	  entering "HABLINE" from "ABLINE" on horizontal lines.
**
**	    1) the XOR mode patch was not applied.
**	    2) LN_MASK was not rotated to align with X2 on exit.
**
*******************************************************************************
*******************************************************************************


*******************************************************************************
*******************************************************************************
**
**	concat
**
**	  This routine converts (by "concatenating") Y and X coordinates
**	  into the physical address and bit index into that word
**
**	  input:	d0.w = signed X coordinate.
**			d1.w = signed Y coordinate.
**
**	  output:	d0.w = bit index into word    (X mod 16)
**			d1.l = address offset
**			       (Y * bytes_per_line) + (X & Xmask) >> Xshift
**
**	  destroys: 	nothing.
**
*******************************************************************************
*******************************************************************************

/* 306de: 00e07bf0 */
/* 102de: 00fca212 */
/* 104de: 00fcade4 */
		xdef	 concat
concat:
	move.w	d2,-(a7)
	move.w	d3,-(a7)

	PIXLA(a0)
	mulu	PIXLV(bytes_lin,a0),d1	; d1 <- offset to (0,Y)

	move.w	PIXLV(v_planes,a0),d3
	move.b	shf_tab-1(pc,d3.w),d3	; d3 <- shift factor for plane adjust

	move.w	d0,d2			; d2[15:00] <- signed X
	and.w	#$000F,d0		; d0 <- X mod 16
	and.w	#$FFF0,d2		; clamp to word boundry
	lsr.w	d3,d2			; d2 <- X displacement (in bytes)
	add.w	d2,d1			; d1 <- offset into screen


	move.w	(a7)+,d3
	move.w	(a7)+,d2
	rts

shf_tab:   *    1 2   4       8		; number of planes

	dc.b	3,2,0,1		; right shift factor


*******************************************************************************
*******************************************************************************
**
**	ABLINE
**
**	  This routine draws a line between (X1,Y1) and (X2,Y2) using
**	  Bresenham's algorithm. The line is modified by the LN_MASK and
**	  WRT_MODE variables. This routine handles all 3 video resolutions
**
**	Note:
**
**	  For line-drawing in VDI, the background color is fixed as 0
**	  (i.e., there is no user-settable background color). This fact
**	  allows coding short-cuts in the implementation of "replace" and
**	  "not" modes, resulting in faster execution of their inner loops.
**
**	input:
**
**	   X1,Y1,X2,Y2 = coordinates.
**	         v_planes = number of video planes. (resolution)
**	          LN_MASK = line mask. (for dashed/dotted lines)
**	         WRT_MODE = writing mode.
**
**			     0 => replace mode.
**			     1 => or mode.
**			     2 => xor mode.
**			     3 => not or mode.
**
**	output:
**
**	  LN_MASK rotated to proper alignment with ( X2,Y2 ).
**
**
**	destroys:
**
**	    everything.
**
**	FEATURES:
**
**	 o In the horizontal case, the pattern is not alligned prior to
**	   the line being drawn, hence the pattern isn't in phase with
**	   the pattern in the succeeding line. In any case, the entire
**	   method for aligning horizontal patterns is incorrect.
**
**	 o The pattern is always implemented starting at the minimum vertex
**	   regardless of the intended direction of line segment. hence,
**	   patterns in consecutive segments are likely not to dovetail or
**	   to have a reversed pattern.
**
**	 o The procedure for preventing the endpoints in consecutive
**	   segments that are XORed to the destination from cancelling
**	   is incorrectly implemented. The current method eliminates the
**	   last point at the maximum vertex regardless of the order of
**	   the entered verticies (or direction of the preceeding segment).
**
**
*******************************************************************************
*******************************************************************************


/* 306de: 00e07c22 */
/* 104de: 00fcae16 */
/* 106de: 00e0b042 */
		xdef	_ABLINE
_ABLINE: ds.b 0
		xdef	M_ABLINE
M_ABLINE: ds.b 0
        move.l _v_bas_ad,a5	; a5 -> start of destination form
		lea	LV(FG_BP_1,a4),a4		; get address of bit plane mask table
		move.w	LV(v_planes,a4),d6	; get number of planes - 1
		move.w  d6,d3
		asl.w   #1,d6
		subq.w  #1,d3
		move.w  LV(v_lin_wr,a4),d7 ; get offset to next scan in plane
		move.w	LV(X2,a4),d5		; compute delta x
		sub.w	LV(X1,a4),d5
	    bmi	swap		; if delta x < 0 then draw from point 2 to 1

*
*	The point at x1,y1 is to the left of the point at x2,y2 so we will
*	draw the line using x1,y1 as the starting point.  Compute the address
*	of the word in the plane that contains the first point in the line.
*
	move.w	LV(X1,a4),d0		; delta x is positive - start from x1,y1
	move.w	LV(Y1,a4),d1
	bsr	concat		; compute offset of x1,y1 into plane
	adda.w	d1,a5		; get address of word containing first point

*
*	Compute the delta y of the line.  If the line is horizontal then
*	draw the line using the routine HABLINE because we can draw the
*	line much faster that way.
*
	move.w	LV(Y2,a4),d4		; compute delta y
	sub.w	LV(Y1,a4),d4
	bne	nothor		; branch if the line is not horizontal

*
*	We need to draw a horizontal line.  If we are in the exclusive or
*	writing mode and this is not the last line in a polyline then
*	decrement the x-coordinate of the ending point in order to prevent
*	polylines from xor'ing themselves at the intersection points.
*
	cmpi.w	#2,LV(WRT_MODE,a4)	; in xor mode?
	bne	xln_ok		; nope - don't adjust the line
	tst.w	LV(LSTLIN,a4)		; last line in a polyline?
	bne	xln_ok		; nope - don't adjust the line
	tst.w	d5		; are the start and end points the same?
	beq	xln_ok		; yes - don't adjust the line
	subq.w	#1,LV(X2,a4)		; decrement the ending x-coordinate
xln_ok:
	bsr	xl_noswap	; call habline to draw the line fast
	move.w	LV(X2,a4),d0		; recompute delta x
	sub.w	LV(X1,a4),d0
	bra	xl_out


*
*	The point at x1,y1 was to the right of the point at x2,y2 resulting
*	in a negative delta x.  Since we only draw from left to right, use
*	x2,y2 as the starting point for the line.  Compute the address of
*	the word in the plane that contains the first point of the line.
*
swap:
	move.w	LV(X2,a4),d0		; delta x is negative - start from x2,y2
	move.w	LV(Y2,a4),d1
	bsr	concat		; compute offset of x2,y2 into plane
	adda.w	d1,a5		; get address of word containing first point
	neg.w	d5		; get absolute value of delta x
	move.w	LV(Y1,a4),d4		; compute delta y
	sub.w	LV(Y2,a4),d4
	bne	nothor		; branch if the line is not horizontal

*
*	We need to draw a horizontal line.  If we are in the exclusive or
*	writing mode and this is not the last line in a polyline then
*	decrement the x-coordinate of the ending point in order to prevent
*	polylines from xor'ing themselves at the intersection points.
*
	cmpi.w	#2,LV(WRT_MODE,a4)	; in xor mode?
	bne	xls_ok		; nope - don't adjust the line
	tst.w	LV(LSTLIN,a4)		; last line in a polyline?
	bne	xls_ok		; nope - don't adjust the line
	tst.w	d5		; are the start and end points the same?
	beq	xls_ok		; yes - don't adjust the line
	addq.w	#1,LV(X2,a4)		; shorten the line from the starting end
	addq.w	#1,d0		; increment the index into the word
	and.w	#15,d0		; overflow into the next word?
	bne	xls_ok		; nope
	adda.w	d6,a5		; yes - increment pointer to next word
xls_ok:
	bsr	xl_swap		; call habline to draw the line fast
	move.w	LV(X1,a4),d0		; recompute delta x
	sub.w	LV(X2,a4),d0
xl_out:
	addq.w	#1,d0		; adjust for true length of the line segment
	and.w	#15,d0		; get length mod 16
	move.w	LV(LN_MASK,a4),d1	; get the line style
	rol.w	d0,d1		; rotate it to align the next line segment
	move.w	d1,LV(LN_MASK,a4)	; save it for the next time through
	rts


*
*	We want to draw a line that is not horizontal.  Test delta y to
*	determine if the slope of the line is positive or negative.  If it
*	is negative then make delta y positive and the offset to the next
*	scan line negative.
nothor:
	bpl	abnorm		; branch if delta y is positive
	neg.w	d4		; it's negative - get its absolute value
	neg.w	d7		; negate the offset to the next scan line

*
*	The register usages at this point are as follows.
*
*	d7 = yinc.		a5 = ptr to 1st word of line.
*	d6 = xinc.		a1 = offset to next plane (vme/10 only)
*	d5 = dx.
*	d4 = dy.
*	d3 = (# of planes) - 1.
*

*
*	Get the or mask for the current index into the word and compare
*	delta x with delta y to determine which is greater.
*
abnorm:
	asl.w	#1,d0		; convert the word index to a table index
	move.w	ortbl(pc,d0.w),d0	; get the or mask
	cmp.w	d4,d5		; which delta is larger?
	bmi	dygtdx		; delta y - branch to separate code

*
*	We want to draw a line where delta x is greater than delta y so we
*	will use the x-axis as the frame of reference.  Initialize the loop
*	counter for plotting individual pixels, calculate the decision
*	variables for Bresenham's Algorithm, and jump to the appropriate
*	line drawing routine for the current writing mode.
*
dxgedy:
	move.w	d5,d2		; loop count = # of pixels - 1
	asl.w	#1,d4		; e1 = 2dy
	move.w	d4,a3		; save e1
	sub.w	d5,d4		; epsilon = 2dy - dx
	move.w	d4,a2		; e2 = 2dy - 2dx
	suba.w	d5,a2
	move.w	LV(LN_MASK,a4),d1	; get the line mask
	move.w	LV(WRT_MODE,a4),d5	; get the writing mode
	asl.w	#2,d5		; convert it to a word offset
	move.l	dxge(pc,d5.w),a1	; get address of mode service routine
	move.w	d0,d5		; get the or table mask
	not.w	d5		; complement it
	jmp	(a1)		; go draw the line

*
*	The register usages at this point are as follows.
*
*	d7 = yinc.		a5 = ptr to destination.
*	d6 = xinc.		a4 = ptr to _FG_BP_1.
*	d5 = not or table mask.	a3 = e1.
*	d4 = epsilon.		a2 = e2.
*	d3 = # of bit_planes - 1.
*	d2 = line loop counter - 1.
*	d1 = line mask.		a1 = offset to next plane (vme/10 only)
*	d0 = or table mask.
*

********************************************************************
*
*	OR Mask Table
*
********************************************************************

	xdef ortbl
ortbl:
		dc.w	$8000
		dc.w	$4000
		dc.w	$2000
		dc.w	$1000
		dc.w	$0800
		dc.w	$0400
		dc.w	$0200
		dc.w	$0100
		dc.w	$0080
		dc.w	$0040
		dc.w	$0020
		dc.w	$0010
		dc.w	$0008
		dc.w	$0004
		dc.w	$0002
		dc.w	$0001

********************************************************************
*
*	Write Mode Address Table
*
********************************************************************

dxge:
	dc.l	rep_dxge
	dc.l	or_dxge
	dc.l	xor_dxge
	dc.l	nor_dxge

********************************************************************
*
*	Line Drawing Routine for the Replace Mode When Delta X is
*	Greater than Delta Y
*
********************************************************************

*
*	Save the registers that get clobbered and test whether the current
*	plane should be written with the line style or 0's for the current
*	drawing color.
*
rep_dxge:
	movem.w d0-d2/d4/d5,-(sp)	; save the registers that get clobbered
	move.l	a5,-(sp)
	tst.w	(a4)+		; write this plane with pattern or 0's
	bne	r_dx_rev	; use inverted pattern
	clr.w	d1		; use 0's
*
*	If the current bit in the pattern is 0 then clear the current bit
*	in the plane.  If it is 1 then set the bit in the plane.
*
r_dx_rev:
r_dx_ltop:
	rol.w	#1,d1		; put current bit of pattern in carry
	bcc	r_dx_clr	; branch if bit is zero
r_dx_set:
	or.w	d0,(a5)		; bit in pattern is 1 - set bit in plane
	bra	r_dx_xinc
r_dx_clr:
	and.w	d5,(a5)		; bit in pattern is 0 - clear bit in plane

*
*	Update the masks for clearing and setting bits.  If we have overflowed
*	the current word then update the pointer to the next word in the plane.
*
r_dx_xinc:
	ror.w	#1,d5		; rotate mask for clearing bits
	ror.w	#1,d0		; rotate mask for setting bits
	bcc	r_dx_yinc	; branch if no overflow to next word
	adda.w	d6,a5		; overflowed word - bump pointer to next word

*
*	If the current value of epsilon is positive then add e2 to epsilon
*	and increment y (by adding the offset to the next scan in the plane).
*	Loop until all the bits in the line segment have been drawn.
*
r_dx_yinc:
	tst.w	d4		; epsilon < 0?
	bmi	r_dx_same1	; yes - don't increment y
	add.w	a2,d4		; nope - epsilon = epsilon + e2
	adda.w	d7,a5		; increment y
	dbra	d2,r_dx_ltop	; loop until done with line segment

*
*	We are now done drawing the line in the current plane.  Restore the
*	registers that were clobbered, update the pointer to the next plane,
*	and test if any additional planes remain to be drawn.
*
r_dx_bp:
	move.l	(sp)+,a5	; restore the clobbered registers
	movem.w	(sp)+,d0-d2/d4/d5
	addq.w	#2,a5		; update pointer to next plane
	dbra	d3,rep_dxge	; loop until all planes are drawn
	bra	abl_out		; take common exit

*
*	The current value of epsilon is negative so add e1 to epsilon.
*	Loop until all the bits in the line segment have been drawn.
*
r_dx_same1:
	add.w	a3,d4		; epsilon = epsilon + e1
	dbra	d2,r_dx_ltop	; loop until done with line segment
	bra	r_dx_bp		; done - check for more planes to draw

********************************************************************
*
*	Line Drawing Routine for the Transparent Mode When Delta X
*	Is Greater than Delta Y
*
********************************************************************

*
*	Save the registers that get clobbered and test whether the current
*	plane should be set or cleared for the current foreground color.
*
or_dxge:
	movem.w d0-d2/d4/d5,-(sp)	; save the registers that get clobbered
	move.l	a5,-(sp)
	tst.w	(a4)+		; set bits in this plane for the fgnd color?
	beq	o_dx_0ltop	; nope - clear bits where mask = fgnd color
*
*	If the current bit in the mask is set then set the current bit in the
*	line segment to acheive the desired foreground color.  Otherwise, do
*	nothing.
*
o_dx_1ltop:
	rol.w	#1,d1		; get next bit from mask (line style)
	bcc	o_dx_1xinc	; it is 0 - do nothing
	or.w	d0,(a5)		; it is 1 - set the current bit in the line

*
*	Update the mask for setting bits.  If we have overflowed the current
*	word then update the pointer to the next word in the plane.
*
o_dx_1xinc:
	ror.w	#1,d0		; rotate mask for setting bits
	bcc	o_dx_1yinc	; branch if no overflow to next word
	adda.w	d6,a5		; overflowed word - bump pointer to next word

*
*	If the current value of epsilon is positive then add e2 to epsilon
*	and increment y (by adding the offset to the next scan in the plane).
*	Loop until all the bits in the line segment have been drawn.
*
o_dx_1yinc:
	tst.w	d4		; epsilon < 0?
	bmi	o_dx_1same1	; yes - don't increment y
	add.w	a2,d4		; nope - epsilon = epsilon +e2
	adda.w	d7,a5		; increment y
	dbra	d2,o_dx_1ltop	; loop until done with line segment

*
*	We are now done drawing the line in the current plane.  Restore the
*	registers that were clobbered, update the pointer to the next plane,
*	and test if any additional planes remain to be drawn.
*
o_dx_bp:
	move.l	(sp)+,a5	; restore the clobbered registers
	movem.w	(sp)+,d0-d2/d4/d5
	addq.w	#2,a5		; update pointer to next plane
	dbra	d3,or_dxge	; loop until all planes are drawn
	bra	abl_out		; take common exit

*
*	The current value of epsilon is negative so add e1 to epsilon.
*	Loop until all the bits in the line segment have been drawn.
*
o_dx_1same1:
	add.w	a3,d4		; epsilon = epsilon + e1
	dbra	d2,o_dx_1ltop	; loop until done with line segment
	bra	o_dx_bp		; done - check for more planes to draw

*
*	If the current bit in the mask is set then clear the current bit in the
*	line segment to acheive the desired foreground color.  Otherwise, do
*	nothing.
*
o_dx_0ltop:
	rol.w	#1,d1		; get next bit from mask (line style)
	bcc	o_dx_0xinc	; it is 0 - do nothing
	and.w	d5,(a5)		; it is 1 - clear the current bit in the line

*
*	Update the mask for clearing bits.  If we have overflowed the current
*	word then update the pointer to the next word in the plane.
*
o_dx_0xinc:
	ror.w	#1,d5		; rotate mask for clearing bits
	bcs	o_dx_0yinc	; branch if no overflow to next word
	adda.w	d6,a5		; overflowed word - bump pointer to next word

*
*	If the current value of epsilon is positive then add e2 to epsilon
*	and increment y (by adding the offset to the next scan in the plane).
*	Loop until all the bits in the line segment have been drawn.
*
o_dx_0yinc:
	tst.w	d4		; epsilon < 0?
	bmi	o_dx_0same1	; yes - don't increment y
	add.w	a2,d4		; nope - epsilon = epsilon + e2
	adda.w	d7,a5		; increment y
	dbra	d2,o_dx_0ltop	; loop until done with line segment
	bra	o_dx_bp		; done - check for more planes to draw

*
*	The current value of epsilon is negative so add e1 to epsilon.
*	Loop until all the bits in the line segment have been drawn.
*
o_dx_0same1:
	add.w	a3,d4		; epsilon = epsilon + e1
	dbra	d2,o_dx_0ltop	; loop until done with line segment
	bra	o_dx_bp		; done - check for more planes to draw

********************************************************************
*
*	Line Drawing Routine for the Exclusive Or Mode When Delta
*	X Is Greater than Delta Y
*
********************************************************************

xor_dxge:
*
*	If the endpoint at x2,y2 should be drawn then don't adjust the line.
*	If the line is a singularity (point) then do nothing.  If we are
*	drawing from x1,y1 then decrement the number of times to go through
*	the pixel drawing loop. If we are drawing from x2,y2 then update
*	epsilon and decrement the loop count without actually drawing the
*	first time through the loop.
*
	tst.w	LV(LSTLIN,a4)		; should the final endpoint be omitted?
	bne	x_dx_lt1	; nope - don't adjust that endpoint
	subq.w     #1,d2
	bne	x_dx_lt1
	addq.w     #1,d2
x_dx_lt1:
	movem.w d0-d2/d4,-(sp)	; save the registers that get clobbered
	move.l	a5,-(sp)
*
*	If the current bit in the mask is set then exclusive or it with the
*	current bit in the line segment.  Otherwise, do nothing.
*
x_dx_ltop:
	rol.w	#1,d1		; get next bit from mask (line style)
	bcc	x_dx_xinc	; it is 0 - do nothing
	eor.w	d0,(a5)		; it is 1 - xor it with bit in line

*
*	Update the mask for exclusive or'ing bits.  If we have overflowed
*	the current word then update the pointer to the next word in the plane.
*
x_dx_xinc:
	ror.w	#1,d0		; rotate mask for xor'ing bits
	bcc	x_dx_yinc	; branch if no overflow to next word
	adda.w	d6,a5		; overflow occurred - bump pointer to next word

*
*	If the current value of epsilon is positive then add e2 to epsilon
*	and increment y (by adding the offset to the next scan in the plane).
*	Loop until all the bits in the line segment have been drawn.
*
x_dx_yinc:
	tst.w	d4		; epsilon < 0?
	bmi	x_dx_same1	; yes - don't increment y
	add.w	a2,d4		; nope - epsilon = epsilon + e2
	adda.w	d7,a5		; increment y
	dbra	d2,x_dx_ltop	; loop until done with line segment

*
*	We are now done drawing the line in the current plane.  Restore the
*	registers that were clobbered, update the pointer to the next plane,
*	and test if any additional planes remain to be drawn.
*
x_dx_bp:
	move.l	(sp)+,a5	; restore the clobbered registers
	movem.w	(sp)+,d0-d2/d4
	addq.w	#2,a5 		; update pointer to next plane
	dbra	d3,x_dx_lt1	; loop until all planes are drawn

*
*	General Purpose Exit For ABLINE -- Take the actual number of pixels
*	in the line segment (less 1 if in the xor mode and we are not drawing
*	the last segment in a polyline) modulo 16 and rotate left the line
*	style by that amount.  Save the new line style for next time through.
*
abl_out:
	addq.w	#1,d2		; get number of pixels in the line
	and.w	#15,d2		; get it mod 16
	rol.w	d2,d1		; rotate left the line style that many bits
	move.w	d1,LV(LN_MASK,a4)	; save the result for next time
	rts

*
*	The current value of epsilon is negative so add e1 to epsilon.
*	Loop until all the bits in the line segment have been drawn.
*
x_dx_same1:
	add.w	a3,d4		; epsilon = epsilon + e1
	dbra	d2,x_dx_ltop	; loop until done with line segment
	bra	x_dx_bp		; done - check for more planes to draw

********************************************************************
*
*	Line Drawing Routine for the Reverse Transparent Mode When
*	Delta X is Greater than Delta Y
*
********************************************************************

*
*	Draw a line in the reverse transparent mode by complementing the
*	line style and calling the code for drawing a line in the transparent
*	mode.
*
nor_dxge:
	not.w	d1		; complement the line style
	bsr	or_dxge		; call the transparent mode code to draw line
	not.w	LV(LN_MASK,a4)	; restore the proper states of the style bits
	rts

*
*	We want to draw a line where delta y is greater than delta x so we
*	will use the y-axis as the frame of reference.  Initialize the loop
*	counter for plotting individual pixels, calculate the decision
*	variables for Bresenham's Algorithm, and jump to the appropriate
*	line drawing routine for the current writing mode.
*
dygtdx:
	exg	d4,d5		; swap delta x and delta y
	move.w	d5,d2		; loop count = # of pixels - 1
	asl.w	#1,d4		; e1 = 2dx
	move.w	d4,a3		; save e1
	sub.w	d5,d4		; epsilon = 2dx - dy
	move.w	d4,a2		; e2 = 2dx - 2dy
	suba.w	d5,a2
	move.w	LV(LN_MASK,a4),d1	; get the line mask
	move.w	LV(WRT_MODE,a4),d5	; get the writing mode
	asl.w	#2,d5		; convert it to a word offset
	move.l	dygt(pc,d5.w),a1	; get address of mode service routine
	move.w	d0,d5		; get the or table mask
	not.w	d5		; complement it
	jmp	(a1)		; go draw the line

*
*	The register usages at this point are as follows.
*
*	d7 = yinc.		a5 = ptr to destination.
*	d6 = xinc.		a4 = ptr to _FG_BP_1.
*	d5 = not or table mask.	a3 = e1.
*	d4 = epsilon.		a2 = e2.
*	d3 = # of bit_planes - 1.
*	d2 = line loop counter - 1.
*	d1 = line mask.		a1 = offset to next plane (vme/10 only)
*	d0 = or table mask.
*

********************************************************************
*
*	Write Mode Address Table
*
********************************************************************
dygt:
	dc.l	rep_dygt
	dc.l	or_dygt
	dc.l	xor_dygt
	dc.l	nor_dygt

********************************************************************
*
*	Line Drawing Routine for the Replace Mode When Delta Y is
*	Greater than Delta X
*
********************************************************************

*
*	Save the registers that get clobbered and text whether the current
*	plane should be written with the line style or 0's for the current
*	drawing color.
*
rep_dygt:
	movem.w d0-d2/d4/d5,-(sp)	; save the registers that get clobbered
	move.l	a5,-(sp)
	tst.w	(a4)+		; write this plane with pattern or 0's?
	bne	r_dy_rev	; use inverted pattern
	clr.w	d1		; use 0's
*
*	If the current bit in the pattern is 0 then clear the current bit
*	in the plane.  If it is 1 then set the bit in the plane.
*
r_dy_rev:
r_dy_ltop:
	rol.w	#1,d1		; put current bit of pattern in carry
	bcc	r_dy_clr	; branch if bit is 0
r_dy_set:
	or.w	d0,(a5)		; bit in pattern is 1 - set bit in plane
	bra	r_dy_yinc
r_dy_clr:
	and.w	d5,(a5)		; bit in pattern is 0 - clear bit in plane

*
*	Increment y (by adding the offset to the next scan in the plane).
*	If the current value of epsilon is positive then add e2 to epsilon.
*
r_dy_yinc:
	adda.w	d7,a5		; increment y
	tst.w	d4		; epsilon < 0?
	bmi	r_dy_same1	; yes - don't increment x
	add.w	a2,d4		; nope - epsilon = epsilon + e2

*
*	We have a step in x.  Update the masks for clearing and setting bits.
*	If we have overflowed the current word then update the pointer to the
*	next word in the plane.  Loop until all the bits in the line segment
*	have been drawn.
*
	ror.w	#1,d5		; rotate mask for clearing bits
	ror.w	#1,d0		; rotate mask for setting bits
	bcc	r_dy_llp_end	; branch if no overflow to next word
	adda.w	d6,a5		; overflowed word - bump pointer to next word
r_dy_llp_end:
	dbra	d2,r_dy_ltop	; loop until done with line segment

*
*	We are now done drawing the line in the current plane.  Restore the
*	registers that were clobbered, update the pointer to the next plane,
*	and test if any additional planes remain to be drawn.
*
r_dy_bp:
	move.l	(sp)+,a5	; restore the clobbered registers
	movem.w	(sp)+,d0-d2/d4/d5
	addq.w	#2,a5		; update pointer to next plane
	dbra	d3,rep_dygt	; loop until all planes are drawn
	bra	abl_out		; take common exit

*
*	The current value of epsilon is negative so add e1 to epsilon.
*	Loop until all the bits in the line segment have been drawn.
*
r_dy_same1:
	add.w	a3,d4		; epsilon = epsilon + e1
	dbra	d2,r_dy_ltop	; loop until done with line segment
	bra	r_dy_bp		; done - check for more planes to draw


********************************************************************
*
*	Line Drawing Routine for the Replace Mode When Delta X is
*	Greater than Delta Y
*
********************************************************************

*
*	Save the registers that get clobbered and text whether the current
*	plane should be set or cleared for the current foreground color.
*
or_dygt:
	movem.w d0-d2/d4/d5,-(sp)	; save the registers that get clobbered
	move.l	a5,-(sp)
	tst.w	(a4)+		; set bits in this plane for the fgnd color?
	beq	o_dy_0ltop	; nope - clear bits where mask = fgnd color
*
*	If the current bit in the mask is set then set the current bit in the
*	line segment to acheive the desired foreground color.  Otherwise, do
*	nothing.
*
o_dy_1ltop:
	rol.w	#1,d1		; get next bit from mask (line style)
	bcc	o_dy_1yinc	; it is 0 - do nothing
	or.w	d0,(a5)		; it is 1 - set the current bit in the line

*
*	Increment y (by adding the offset to the next scan in the plane).
*	If the current value of epsilon is positive then add e2 to epsilon.
*
o_dy_1yinc:
	adda.w	d7,a5		; increment y
	tst.w	d4		; epsilon < 0?
	bmi	o_dy_1same1	; yes - don't increment x
	add.w	a2,d4		; nope - epsilon = epsilon + e2

*
*	We have a step in x.  Update the mask for setting bits.  If we have
*	overflowed the current word then update the pointer to the next word
*	in the plane.  Loop until all bits in the line segment have been drawn.
*
	ror.w	#1,d0		; rotate mask for setting bits
	bcc	o_dy_1llp_end	; branch if no overflow to next word
	adda.w	d6,a5		; overflowed word - bump pointer to next word
o_dy_1llp_end:
	dbra	d2,o_dy_1ltop	; loop until done with line segment

*
*	We are now done drawing the line in the current plane.  Restore the
*	registers that were clobbered, update the pointer to the next plane,
*	and test if any additional planes remain to be drawn.
*
o_dy_bp:
	move.l	(sp)+,a5	; restore the clobbered registers
	movem.w	(sp)+,d0-d2/d4/d5
	addq.w     #2,a5		; update pointer to next plane
	dbra	d3,or_dygt	; loop until all planes are drawn
	bra	abl_out		; take common exit

*
*	The current value of epsilon is negative so add e1 to epsilon.
*	Loop until all the bits in the line segment have been drawn.
*
o_dy_1same1:
	add.w	a3,d4		; epsilon = epsilon + e1
	dbra	d2,o_dy_1ltop	; loop until done with line segment
	bra	o_dy_bp		; done - check for more planes to draw

*
*	If the current bit in the mask is set then clear the current bit in the
*	line segment to acheive the desired foreground color.  Otherwise, do
*	nothing.
*
o_dy_0ltop:
	rol.w	#1,d1		; get next bit from mask (line style)
	bcc	o_dy_0yinc	; it is 0 - do nothing
	and.w	d5,(a5)		; it is 1 - clear the current bit in the line

*
*	Increment y (by adding the offset to the next scan in the plane).
*	If the current value of epsilon is positive then add e2 to epsilon.
*
o_dy_0yinc:
	adda.w	d7,a5		; increment y
	tst.w	d4		; epsilon < 0?
	bmi	o_dy_0same1	; yes - don't increment x
	add.w	a2,d4		; nope - epsilon = epsilon + e2

*
*	We have a step in x.  Update the mask for clearing bits.  If we have
*	overflowed the current word then update the pointer to the next word
*	in the plane.  Loop until all bits in the line segment have been drawn.
*
	ror.w	#1,d5		; rotate mask for clearing bits
	bcs	o_dy_0llp_end	; branch if no overflow to next word
	adda.w	d6,a5		; overflowed word - bump pointer to next word
o_dy_0llp_end:
	dbra	d2,o_dy_0ltop	; loop until done with line segment
	bra	o_dy_bp		; done - check for more planes to draw

*
*	The current value of epsilon is negative so add e1 to epsilon.
*	Loop until all the bits in the line segment have been drawn.
*
o_dy_0same1:
	add.w	a3,d4		; epsilon = epsilon + e1
	dbra	d2,o_dy_0ltop	; loop until done with line segment
	bra	o_dy_bp


********************************************************************
*
*	Line Drawing Routine for the Exclusive Or Mode When Delta
*	Y Is Greater than Delta X
*
********************************************************************

*
*	Save the registers that get clobbered.
*
xor_dygt:

*
*	If the endpoint at x2,y2 should be drawn then don't adjust the line.
*	If the line is a singularity (point) then do nothing.  If we are
*	drawing from x1,y1 then decrement the number of times to go through
*	the pixel drawing loop. If we are drawing from x2,y2 then update
*	epsilon and decrement the loop count without actually drawing the
*	first time through the loop.
*
	tst.w	LV(LSTLIN,a4)		; should the final endpoint be omitted?
	bne	x_dy_lt1	; nope - don't adjust that endpoint
	subq.w     #1,d2		; is line a single point?
	bne	x_dy_lt1		; yes - don't even bother to draw it
	addq.w     #1,d2

x_dy_lt1:
	movem.w d0-d2/d4,-(sp)	; save the registers that get clobbered
	move.l	a5,-(sp)
*
*	If the current bit in the mask is set then exclusive or it with the
*	current bit in the line segment.  Otherwise, do nothing.
*
x_dy_ltop:
	rol.w	#1,d1		; get next bit from mask (line style)
	bcc	x_dy_yinc	; it is 0 - do nothing
	eor.w	d0,(a5)		; it is 1 - xor it with bit in line

*
*	Increment y (by adding the offset to the next scan in the plane).
*	If the current value of epsilon is positive then add e2 to epsilon.
*
x_dy_yinc:
	adda.w	d7,a5		; increment y
	tst.w	d4		; epsilon < 0?
	bmi	x_dy_same1	; yes - don't increment x
	add.w	a2,d4		; nope - epsilon = epsilon + e2

*
*	Update the mask for exclusive or'ing bits.  If we have overflowed
*	the current word then update the pointer to the next word in the plane.
*
	ror.w	#1,d0		; rotate mask for xor'ing bits
	bcc	x_dy_llp_end	; branch if no overflow to next word
	adda.w	d6,a5		; overflow occurred - bump pointer to next word
x_dy_llp_end:
	dbra	d2,x_dy_ltop	; loop until done with line segment

*
*	We are now done drawing the line in the current plane.  Restore the
*	registers that were clobbered, update the pointer to the next plane,
*	and test if any additional planes remain to be drawn.
*
x_dy_bp:
	move.l	(sp)+,a5	; restore the clobbered registers
	movem.w	(sp)+,d0-d2/d4
	addq.w     #2,a5		; update pointer to next plane
	dbra	d3,x_dy_lt1	; loop until all planes are drawn
	bra	abl_out		; take common exit

*
*	The current value of epsilon is negative so add e1 to epsilon.
*	Loop until all the bits in the line segment have been drawn.
*
x_dy_same1:
	add.w	a3,d4		; epsilon = epsilon + e1
	dbra	d2,x_dy_ltop	; loop until done with line segment
	bra	x_dy_bp		; done - check for more planes to draw


********************************************************************
*
*	Line Drawing Routine for the Reverse Transparent Mode When
*	Delta Y Is Greater than Delta X
*
********************************************************************

*
*	Draw a line in the reverse transparent mode by complementing the
*	line style and calling the code for drawing a line in the transparent
*	mode.
*
nor_dygt:
	not.w	d1		; complement the line style
	bsr	or_dygt		; call the transparent mode code to draw line
	not.w	LV(LN_MASK,a4)	; restore the proper states of the style bits
	rts


********************************************************************
*
*	HABLINE
*
*	This routine draws a line between (_X1,_Y1) and (_X2,_Y1)
*	using a left fringe, inner loop, right fringe bitblt algor-
*	ithm.  The line is modified by the pattern and _WRT_MODE
*	variables.  This routine handles all 3 video resolutions.
*	Note that 2 entry points are provided for ABLINE.
*
*	input:
*	   _X1,_Y1,_X2	= coordinates.
*	   _v_planes	= number of video planes. (resolution)
*	   _patmsk	= index into pattern.
*	   _patptr	= ptr to pattern.
*	   _WRT_MODE	= writing mode.
*				0 => replace mode.
*				1 => or mode.
*				2 => xor mode.
*				3 => not mode.
*
*	output:		nothing.
*
*	destroys:	everything.
*
********************************************************************

*
*	This is the entry point used by ABLINE when a horizontal line is
*	to be drawn using the current line style.
*
xl_noswap:
	lea	LV(LN_MASK,a4),a0	; get the current line style
	suba.w     a1,a1	; line style is monoplaned - no offset
	move.w  d6,a3		; get # of bytes between graphic planes
	move.w	LV(X1,a4),d4		; get starting x-coordinate
	move.w	LV(X2,a4),d2		; get ending x-coordinate
	bra	xline

*
*	This is the entry point used by ABLINE when a horizontal line is
*	to be drawn using the current line style but when the two endpoints
*	need to be swapped.
*
xl_swap:
	lea	LV(LN_MASK,a4),a0	; get the current line style
	suba.w     a1,a1	; line style is monoplaned - no offset
	move.w  d6,a3		; get # of bytes between graphic planes
	move.w	LV(X2,a4),d4		; get starting x-coordinate
	move.w	LV(X1,a4),d2		; get ending x-coordinate
	bra	xline

*
*	Main entry point to _HABLINE
*
*	Compute the address of the word containing the starting point of
*	the line to be drawn and the offset of the starting bit within the
*	word.
*
	xdef _HABLINE
_HABLINE: ds.b 0
	xdef M_HABLINE
M_HABLINE: ds.b 0
	xdef fline
fline: ds.b 0
	movea.l	_v_bas_ad,a5	; get base address of first video plane
	lea	LV(FG_BP_1,a4),a4	; get address of bit plane mask table
	movea.w	LV(v_planes,a4),a3	; get number of planes
	move.w	a3,d3		; get number of planes - 1
	adda.w	a3,a3		; get offset to next word in same plane
	subq.w	#1,d3
	move.w	LV(X1,a4),d0		; get starting x-coordinate (input to concat)
	move.w	d0,d4		; save it for later use
	move.w	LV(Y1,a4),d1		; get y-coordinate (input to concat)
	move.w	d1,d5		; save it for later use
	bsr	concat		; compute word offset and bit offset
	adda.w	d1,a5		; compute actual address of starting word
	move.w	LV(X2,a4),d2		; get ending x-coordinate

*
*	Get the pattern with which the line is to be drawn.
*
	and.w	LV(patmsk,a4),d5	; get index into pattern
	asl.w	#1,d5		; convert to offset into pattern def table
	move.l	LV(patptr,a4),a0	; get pointer to start of pattern definition
	adda.w	d5,a0		; get pointer to desired word of pattern def
	suba.w	a1,a1		; init offset to next plane of pattern to 0
	tst.w	LV(multifill,a4)	; using multi-planed patterns?
	beq	xline		; nope
	move.w	#32,a1		; yes - offset = length of 1 plane of pat def

*
*	At this point the register usages are as follows:
*
*	d7 = scratch.		a5 = ptr to destination.
*	d6 = scratch.		a4 = ptr to _FG_BP_1.
*	d5 = scratch.		a3 = offset to next plane
*	d4 = _X1.		a2 = scratch
*	d3 = # of bit_planes - 1.
*	d2 = _X2.		a1 = offset to next plane of fill pattern
*	d1 = scratch		a0 = ptr to fill pattern
*	d0 = _X1 and 0x000F.
*

*
*	Compute the left and right fringe masks for the line.
*
	xdef xline
xline:
	asl.w	#1,d0		; convert bit offset of 1st bit to word index
	move.w	lf_tab(pc,d0.w),d0	; get not of left fringe mask
	not.w	d0		; invert bits of mask to proper value
	move.w	d2,d7		; get ending x-coordinate
	and.w	#15,d7		; get bit offset into its word
	asl.w	#1,d7		; convert bit offset of last bit to word index
	move.w	rf_tab(pc,d7.w),d7	; get right fringe mask

*
*	Compute the number of entire words to be written with the line.
*
	move.w  #4,d5
	asr.w	d5,d4		; compute # of words preceeding starting point
	asr.w	d5,d2		; compute # of words preceeding ending point
	sub.w	d4,d2		; compute word offset between the endpoints
	subq.w	#1,d2		; compute # of full words in line

*
*	If the number of full words in the line segment is negative then the
*	two endpoints lie in the same word.  Combine the two fringe masks,
*	set the inner loop count to 0, and modify the right fringe mask so
*	that it will have no effect.
*
	bpl	hab_decode	; count >= 0 so this is a normal case
	addq.w  #1,d2		; set inner loop count to 0
	or.w	d7,d0		; combine fringe masks
	moveq	#-1,d7		; prevent right mask from affecting screen
*
*	Jump to the appropriate handling routine for the current write mode
*	for both the general and special cases.
*
hab_decode:
	move.w	LV(WRT_MODE,a4),d5	; write mode used to select HABLINE entry
	asl.w	#2,d5		; convert to longword index
	move.l	htab(pc,d5.w),a2	; get address of handling routine
	jmp	(a2)		; jump to it

*
*	At this point the register usages are as follows:
*
*	d7 = right mask.	a5 = ptr to destination.
*	d6 = scratch.		a4 = ptr to _FG_BP_1.
*	d5 = scratch.		a3 = offset to next plane or next word in plane
*	d4 = scratch.		a1 = offset to next bitplane's fill pattern
*	d3 = # of bit_planes - 1.
*	d2 = inner loop count.	a0 = ptr to fill pattern
*	d1 = scratch
*	d0 = left mask (or left "and" right masks).
*


********************************************************************
*
*	Word Mask Table
*
*	The table has been compacted by taking the one's complement
*	of the left fringe table and combining it with the right
*	fringe table.
*
********************************************************************

	xdef lf_tab
lf_tab:
		dc.w	$FFFF		; origin for not left fringe lookup.
	xdef rf_tab
rf_tab:
		dc.w	$7FFF		; origin for right fringe lookup.
		dc.w	$3FFF
		dc.w	$1FFF
		dc.w	$0FFF
		dc.w	$07FF
		dc.w	$03FF
		dc.w	$01FF
        dc.w    $00FF
        dc.w    $007F
        dc.w    $003F
        dc.w    $001F
        dc.w    $000F
        dc.w    $0007
        dc.w    $0003
        dc.w    $0001
        dc.w    $0000

********************************************************************
*
*	HABLINE Mode Address Table
*
*	This table contains the jump addresses for the line drawing
*	routines for the four writing modes.
*
********************************************************************

	xdef htab
htab:
	dc.l	rep_x
	dc.l	or_x
	dc.l	xor_x
	dc.l	nor_x

********************************************************************
*
*	Line Drawing Routine for Replace Mode
*
********************************************************************

*
*	Save the registers that are clobbered and test whether the current
*	plane should be written with the line style or 0's.
*
rep_x:
	movem.l    d2/a5,-(a7)	; save registers that get clobbered
	move.w	(a0),d1		; get line style or fill pattern

	adda.w	a1,a0		; update line style/fill pattern pointer
	tst.w	(a4)+		; write this plane with pattern or 0's?
	bne	r_x_lf		; use pattern
	clr.w	d1		; use 0's

*
*	Draw the left fringe.
*
r_x_lf:
	move.w	(a5),d5		; get source data
	eor.w	d1,d5		; xor the pattern with the source
	and.w	d0,d5		; isolate the bits outside the fringe
	eor.w	d1,d5		; restore the bits outside the fringe
	move.w	d5,(a5)		; write the fringe
	adda.w	a3,a5		; update pointer to next word in plane

*
*	Inner Loop -- Draw the full words contained in the line.
*
	bra	rx_lend		; test if any entire words are to be drawn
rx_ltop:
	move.w	d1,(a5)		; write the fringe
	adda.w	a3,a5		; update pointer to next word in plane
rx_lend:
	dbra	d2,rx_ltop	; loop until done

*
*	Draw the right fringe.
*
	move.w	(a5),d5		; get source data
	eor.w	d1,d5		; xor the pattern with the source
	and.w	d7,d5		; isolate the bits outside the fringe
	eor.w	d1,d5		; restore the bits outside the fringe
	move.w	d5,(a5)		; write the fringe and advance to next word

*
*	We are now done drawing the line in the current plane.  Restore the
*	registers that were clobbered, update the pointer to the next plane,
*	and test whether any additional planes need to be drawn.
*
	movem.l (a7)+,d2/a5	; restore the clobbered registers
	addq.w	#2,a5		; update pointer to next plane
	dbra	d3,rep_x	; loop until all planes are drawn
	rts


********************************************************************
*
*	Line Drawing Routine for Transparent Mode
*
*	This mode is not to be confused with a true 'or' mode.
*
********************************************************************

*
*	If the foreground color requires that bits in the current plane
*	be set then 'or' the mask with the source.  Otherwise, the fore-
*	ground color requires that bits in the current plane be cleared
*	so 'and' the complement of the mask with the source.  Bits that
*	would be drawn with the background color (black) are left unchanged.
*

*
*	Call a subroutine common to the transparent and reverse transparent
*	modes to draw the line segment.
*
or_x:
	move.w	(a0),d1		; get current scan of pattern
	bsr	or_nor		; draw the line segment
	dbra	d3,or_x		; loop until all planes drawn
	rts

********************************************************************
*
*	Line Drawing Routine for Reverse Transparent Mode
*
********************************************************************

*
*	Get the one's complement of the pattern and call a subroutine
*	common to the transparent and reverse transparent modes to draw
*	the line segment.
*
nor_x:
	move.w	(a0),d1		; get current scan of pattern
	not.w	d1		; get one's complement of the pattern
	bsr	or_nor		; draw the line segment
	dbra	d3,nor_x	; loop until all planes drawn
	rts

********************************************************************
*
*	General Purpose Line Drawing Routine for Both Transparent
*	and Reverse Transparent Writing Modes
*
********************************************************************

*
*	Save the registers that get clobbered and test whether the current
*	plane should be set or cleared for the current foreground color.
*
or_nor:
	movem.l	d2/a5,-(sp)	; save registers that get clobbered
	adda.w	a1,a0		; update pointer to next plane's pattern
	tst.w	(a4)+		; set bits in this plane for the fgnd color?
	bne	o_x_lf1		; yes - or mask with source
	not.w	d1		; nope - and complement of mask with source
*
*	Draw the left fringe by clearing bits in this plane.
*
o_x_lf0:
	move.w	(a5),d5		; get source data
	move.w	d5,d4		; save it
	and.w	d1,d5		; and complement of mask with source
	eor.w	d5,d4		; isolate changed bits
	and.w	d0,d4		; isolate changed bits outside of fringe
	eor.w	d4,d5		; restore them to original states
	move.w	d5,(a5)		; write left fringe
	adda.w	a3,a5		; update pointer to next word in plane

*
*	Inner Loop -- Draw the full words contained in the line.
*
	bra	oxc_lend	; first test for any full words to be drawn
oxc_ltop:
	and.w	d1,(a5)		; clear all bits to contain foreground color
	adda.w	a3,a5		; update pointer to next word in plane
oxc_lend:
	dbra	d2,oxc_ltop	; loop until done

*
*	Draw the right fringe.
*
	move.w	(a5),d5		; get source data
	move.w	d5,d4		; save it
	and.w	d1,d5		; nope - and complement of mask with source
ox_merge:
	eor.w	d5,d4		; isolate changed bits
	and.w	d7,d4		; isolate changed bits outside of pattern
	eor.w	d4,d5		; restore them to original states
	move.w	d5,(a5)		; write out right fringe

*
*	We are now done drawing the line in the current plane.  Restore the
*	registers that were clobbered, update the pointer to the next plane,
*	and test whether any additional planes need to be drawn.
*
	movem.l	(sp)+,d2/a5	; restore the clobbered registers
	addq.w	#2,a5		; update pointer to next plane
	rts

*
*	Draw the left fringe by setting bits in this plane.
*
o_x_lf1:
	move.w	(a5),d5		; get source data
	move.w	d5,d4		; save it
	or.w	d1,d5		; or mask with source
	eor.w	d5,d4		; isolate changed bits
	and.w	d0,d4		; isolate changed bits outside of fringe
	eor.w	d4,d5		; restore them to original states
	move.w	d5,(a5)		; write left fringe
	adda.w	a3,a5		; update pointer to next word in plane

*
*	Inner Loop -- Draw the full words contained in the line.
*
	bra	oxs_lend	; first test for any full words to be drawn
oxs_ltop:
	or.w	d1,(a5)		; set all bits to contain forground color
	adda.w	a3,a5		; update pointer to next word in plane
oxs_lend:
	dbra	d2,oxs_ltop	; loop until done

*
*	Draw the right fringe by setting bits in this plane.
*
	move.w	(a5),d5		; get source data
	move.w	d5,d4		; save it
	or.w	d1,d5		; or mask with source
	bra	ox_merge	; jump to common code for setting and clearing

********************************************************************
*
*	Line Drawing Routine for Exclusive Or Mode
*
********************************************************************

*
*	Save the registers that get clobbered.
*
xor_x:
	movem.l	d2/a5,-(sp)	; save registers that get clobbered
	move.w	(a0),d1		; get line style or fill pattern
	adda.w	a1,a0		; update line style/fill pattern pointer

*
*	Draw the left fringe.
*
x_x_lf:
	move.w	(a5),d5		; get the source
	move.w	d5,d4		; save it
	eor.w	d1,d5		; xor the pattern with the source
	eor.w	d5,d4		; xor result with source - now have pattern
	and.w	d0,d4		; isolate changed bits outside of fringe
	eor.w	d4,d5		; restore states of bits outside of fringe
	move.w	d5,(a5)		; write left fringe
	adda.w	a3,a5		; update pointer to next word in plane

*
*	Inner Loop -- Draw the full words contained in the line.
*
	bra	xx_lend			; test if any entire words are to be drawn
xx_ltop:
	eor.w	d1,(a5)		; draw current word
	adda.w	a3,a5		; update pointer to next word in plane
xx_lend:
	dbra	d2,xx_ltop	; loop until done

*
*	Draw the right fringe.
*
	move.w	(a5),d5		; get the source
	move.w	d5,d4		; save it
	eor.w	d1,d5		; xor the pattern with the source
	eor.w	d5,d4		; xor result with source - now have pattern
	and.w	d7,d4		; isolate changed bits outside of fringe
	eor.w	d4,d5		; restore states of bits outside of fringe
	move.w	d5,(a5)		; write out right fringe

*
*	We are now done drawing the line in the current plane.  Restore the
*	registers that were clobbered, update the pointer to the next plane,
*	and test whether any additional planes need to be drawn.
*
	movem.l (sp)+,d2/a5     ; restore the clobbered registers
	addq.w	#2,a5		; update pointer to next plane
	dbra    d3,xor_x        ; loop until all bit planes are drawn
	rts
