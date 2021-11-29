****************************  hbline.s  ********************************
*
* =======================================================================
* $Author: lozben $	$Date: 91/02/13 18:34:26 $
* =======================================================================
*
* Revision 3.2  91/02/13  18:34:26  lozben
* Adjusted the spelling of some of the linea equates to correspond
* to the ones in the lineaequ.s file.
* 
* Revision 3.1  91/01/31  16:20:29  lozben
* Adjusted the code to work with the multiple linea variable structures.
* 
* Revision 3.0  91/01/03  15:10:50  lozben
* New generation VDI
* 
* Revision 2.3  90/02/23  18:22:21  lozben
* We now use FG_B_PLANES as our color index instead of _FG_BP_{0-7}.
* 
* Revision 2.2  89/02/27  17:45:13  lozben
* *** initial revision ***
* 
*************************************************************************


#if BLITTER_SUPPORT /* whole file */

#include "blaster.inc"

	text

*+
*	Hard Vertical Line Code
*
*  in:
*	d4	X
*	d5	Y1
*	d6	X
*	d7	Y2
*
*	a4	pointer to LineA variable base
*-
		xdef	hb_vline
hb_vline:

	lea	BLASTER+B_OFF,a5	; a5 -> BLASTER reference register

	not.w	d4
	and.w	#$000F,d4		; d4 <- bit number within word
	clr.w	d0
	bset.l	d4,d0			; d0 <- pixel mask   0:DST 1:LINE
	move.w	d0,B_F1_MSK(a5)		; load the fringe mask

	move.w	LV(v_planes,a4),d0	; d0 <- planes
	move.w	d0,d1
	add.w	d1,d1			; d1 <- offset between words
	subq.w	#1,d0			; d0 <- dbra plane counter

	move.l	_v_bas_ad,a1		; a1 -> start of destination form
	asr.w	#4,d6			; d6 <- X/16
	muls	d6,d1			; d1 <- byte offset to X
	add.l	d1,a1			; a1 -> dst (X,0)

	move.w	LV(bytes_lin,a4),d2		; d2 <- screen width
	muls	d5,d2			; d2 <- offset to (0,Y1)
	add.l	d2,a1			; a1 -> (X,Y1)

	moveq.l	#7,d2			; d2 <- dbra loop counter

	move.w	LV(v_lin_wr,a4),d1	; d1 <- offset between lines

	lea	LV(LN_MASK,a4),a3		; a3 -> line style mask
	move.w	(a3),d3			; d3 <- line style mask

	sub.w	d5,d7			; d7 <- dY
	bge	vl_top


vl_bot:	neg.w	d7			; d7 <- absolute value of dY
	neg.w	d1			; d1 <- offset to next line up
	lea	B_PATTERN+32(a5),a0	; a0 -> last pattern register

vl_b2t:	add.w	d3,d3			; cy <- next style bit
	subx.w	d4,d4			; cy:0 => d0<-0000  cy:1 => d0<-FFFF
	move.w	d4,-(a0)		; load register
	add.w	d3,d3
	subx.w	d4,d4
	move.w	d4,-(a0)
	dbra	d2,vl_b2t

	move.w	#BM_GO+$0F00,d2		; d2 <- SKEW word (start on last line)
	bra	vl_wrap



vl_top:	lea	B_PATTERN(a5),a0	; a0 -> 1st pattern register

vl_t2b:	add.w	d3,d3			; cy <- next style bit
	subx.w	d4,d4			; cy:0 => d0<-0000  cy:1 => d0<-FFFF
	move.w	d4,(a0)+		; load pattern register
	add.w	d3,d3
	subx.w	d4,d4
	move.w	d4,(a0)+
	dbra	d2,vl_t2b		; next 2 registers

	move.w	#BM_GO+$0000,d2		; d2 <- initial pattern index


vl_wrap:

	move.w	d1,B_D_WRAP(a5)		; store destination wrap
	addq.w	#1,d7			; d7  <- dY+1: height

	lea	op_table,a2
	move.w	LV(WRT_MODE,a4),d1	; d1 <- writing mode
	lsl.w	#2,d1			; d1 <- offset into main table
	add.w	d1,a2			; a2 -> op code table for this mode

	subq.w	#8,d1			/* if it's XOR mode ... */
	bne	vl_newmask		
	tst.w	LV(LSTLIN,a4)		/* and it's not the last line ... */
	bne	vl_newmask

	subq.w	#1,d7			/* don't plot last pixel */

vl_newmask:

	move.w	d7,d1			; d1 <- line length
	move.w	(a3),d3			; d3 <- pattern for this line
	and.w	#$000F,d1		; d1 <- realignment factor
	rol.w	d1,d3			; d3 <- pattern aligned for next line
	move.w	d3,(a3)			; save it back to LN_MASK

#if PLANES8
        move.l  LV(FG_B_PLANES,a4),d5	; d5 <- color index
#else
	lea     FG_BP_1(a4),a3
#endif
	moveq.l	#2,d4			; d4 <- mask for op_table offset
	move.w	#1,B_D_SPAN(a5)		; one word span

vl_loop:

	move.l	a1,B_D_ADDR(a5)		; next plane
	move.w	d7,B_HEIGHT(a5)		; line height

#if PLANES8
	ror.l	#1,d5			; what color is this plane ?
	scs	d3
#else
	tst.w   (a3)+
	sne     d3
#endif
	and.w	d4,d3
	move.w	0(a2,d3.w),B_LOGOP(a5)


*******************************************************************************
	move.w	d2,(a5)			; load the SKEW register and fly
*******************************************************************************

vl_sync:

	tas	(a5)
	nop
	bmi	vl_sync

vl_cont:

	addq.w	#2,a1			; a1 -> start of next plane
	dbra	d0,vl_loop		; do the next plane

#if P68030
	CACR_D0			; d0 <- cache control register
	bset.l	#11,d0			; set "Clr DATA Cache" bit
	D0_CACR			; clear the data cache
#endif
	rts


#endif /* BLITTER_SUPPORT */
