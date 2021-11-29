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
*	Hard Horizontal Line Code
* in:
*	d0	offset between pattern words
*	d1	word containing X1
*	d2	span-1 (words)
*	d3	mod 16 mask
*	d4	left fringe mask
*	d5	Y1
*	d6	right fringe mask
*
*	a0	points to 1st pattern word
*	a4	points to line A variables base address  (v_planes)
*-
		xdef	hb_hline
hb_hline:

	lea	BLASTER+B_OFF,a5	; a5 -> bit blt reference register
	clr.w	B_S_NXWD(a5)		; proceed from left to right

	addq.w	#1,d2			; d2 <- span
	move.w	d2,B_D_SPAN(a5)

	lea	B_F1_MSK(a5),a3
	move.w	 d4,(a3)+		; B_F1_MSK <- left fringe
	move.w	#-1,(a3)+		; B_CT_MSK <- center fringe
	move.w	 d6,(a3)+		; B_F2_MSK <- right fringe

	move.w	(a4),d2			; d2 <- planes		( v_planes   )
	move.w	d2,d7
	subq.w	#1,d7			; d7 <- dbra plane counter

	add.w	d2,d2			; d2 <- offset between words in plane
	move.w	d2,(a3)+		; load B_D_NXWD

	move.l	_v_bas_ad,a1		; a1 -> start of dst form
	muls	LV(bytes_lin,a4),d5	; d5 <- offset to 1st row of dst
	add.l	d5,a1			; a1 -> row containing line

	muls	d2,d1			; d1 <- offset to word containing X1
	add.l	d1,a1			; a1 -> 1st word of line

	lea	B_PATTERN(a5),a2	; a2 -> 1st pattern register
#if PLANES8
        move.l  LV(FG_B_PLANES,a4),d5	; d5 <- color index
#else
	lea     FG_BP_1(a4),a3
#endif

	move.w	LV(WRT_MODE,a4),d2	; d2 <- writing mode (0-3)
	add.w	d2,d2
	add.w	d2,d2			; d2 <- offset to writing mode table
	lea	op_table(pc),a4		; a4 -> 1st logic op table
	add.w	d2,a4			; a4 -> writing mode table

	moveq.l	#2,d3			; d3 <- logic op offset mask
	move.w	#BM_GO,d4		; d4 <- SKEW word
	moveq.l	#1,d6			; d6 <- height


hl_loop:

	move.w	(a0),(a2)		; load the pattern into BLASTER
	add.w	d0,a0			; a0 -> next pattern word

	move.l	a1,B_D_ADDR(a5)		; new dst plane
	move.w	d6,B_HEIGHT(a5)		; height of 1

#if PLANES8
	ror.l	#1,d5			; what color is this plane ?
	scs	d2
#else
	tst.w   (a3)+
	sne     d2
#endif
	and.w	d3,d2			; d2 <- logic op offset: 0=>0  1=>2
	move.w	0(a4,d2.w),B_LOGOP(a5)	; load the logic op

*******************************************************************************
	move.w	d4,(a5)			; start the BLASTER
*******************************************************************************

hl_sync:

	tas	(a5)
	nop
	bmi	hl_sync

hl_cont:

	addq.l	#2,a1			; a1 -> next dst plane
	dbra	d7,hl_loop

#if P68030
	CACR_D7			; d7 <- cache control register
	bset.l	#11,d7			; set "Clr DATA Cache" bit
	D7_CACR			; clear the data cache
#endif
	rts


#if BLITTER_SUPPORT & (TOSVERSION >= 0x300)
		xdef	op_table
op_table:  *	 color=0   color=1

	dc.w	BM_PAT+00,BM_PAT+03	; replace
	dc.w	BM_PAT+04,BM_PAT+07	; transparent
	dc.w	BM_PAT+06,BM_PAT+06	; xor
	dc.w	BM_PAT+01,BM_PAT+13	; reverse transparent
#endif

#endif /* BLITTER_SUPPORT */
