****************************  hbmono.s  *********************************
*
* =======================================================================
* $Author: lozben $	$Date: 91/01/03 15:10:56 $
* =======================================================================
*
* Revision 3.0  91/01/03  15:10:56  lozben
* New generation VDI
*
* Revision 2.2  89/02/27  17:45:15  lozben
* *** initial revision ***
*
*************************************************************************

#include "config.h"
#include "vdidefs.h"
#include "lineaequ.inc"
#include "asmdefs.h"
#include "tosvars.inc"

#if BLITTER_SUPPORT /* whole file */


/*
 * in TOS versions before 4.00, the routines below
 * are called with a5 pointing to the font base.
 * In TOS 4.x, they are called with a1 pointing to the
 * linea reference base.
 */

#if TOSVERSION >= 0x400
OF equ 0
#else
OF equ FBASE
#endif

#include "blaster.inc"

	text

*-
*  Mono-spaced text blt; no clipping to worry about
*
*   d0.w =  DESTX
*   d1.w =  DESTY
*   d2.w =  # of characters
*   d3.w =  DELY
*   a1   =  line A variable reference base
*-
/* 206de: 00e0c336 */
/* 104de: 00fd0596 */
	xdef	 hb_mono
hb_mono:
#if TOSVERSION >= 0x400
	move.l	a1,a5		    ;a5 -> line A variable structure
	add.l	#FBASE,a5		;a5 -> FBASE
#endif
	lea	BLASTER+B_OFF,a4    ;12	 a4 -> base of bitblt regs

	move.l	(a5)+,a0	    ;12	 a0 -> source form
	move.w	(a5),B_S_WRAP(a4)   ;16	 load src form width     ( FWIDTH   )
	move.w	-86(a5),d7	    ;12	 d7 <- dst form width	 ( v_lin_wr )
	move.w	d7,B_D_WRAP(a4)	    ;20	 load dst form width
	muls	-90(a5),d1	    ;79> d1 <- offset to dst Ymin( bytes_lin)
	move.l	-80(a5),a2	    ;12	 a2 -> ascii char string ( INTIN    )
	move.w	-52(a5),d4	    ;12	 d4 <- writing mode      ( WRT_MOD  )
	move.w	-88(a5),d5	    ;12	 d5 <- number of planes  ( v_planes )
	subq.w	#1,d5		    ; 4	 d5 <- dbra plane counter

	move.b	shf_tab(pc,d5.w),d7 ;12	 d7 <- horizontal shift factor
	move.w	d0,d6		    ; 4  d6 <- dst X
	and.w	#$FFF0,d0	    ; 8	 d0 <- clip X to word boundry
	asr.w	d7,d0		    ; 8/10/12  d0 <- offset to dst X
	lsr.w	#4,d6		    ;14	 x flag:0  even  x flag:1 odd
	ext.l	d0		    ; 4	 d0 <- longword offset to dst X
	addx.l	d0,d1		    ; 8	 d1 <- X offset + Y offset + x flag
	add.l	_v_bas_ad,d1	    ;22	 d1 -> start of dst

	move.w	18(a5),d6	    ;12	 d6 <- foreground color  ( TEXT_FG  )
	move.w	#1,B_D_SPAN(a4)	    ;16	 span of 1 word
	move.w	#BM_SRC,B_LOGOP(a4) ;16  source and no pattern

	bra	char1st		    ;10	 count 1 character off 1st



*	a0   -> source form base
*	d1   -> screen destination
*
*	a2   -> character string
*	a4   -> BLASTER base address
*
*	d0,d7 temp use
*
*	d2.w = # of characters remaining
*	d3.w = height of character (in rows)
*	d4.w = writing mode
*	d5.w = # of planes -1
*	d6.w = foreground color


*		    planes

shf_tab:   *	1 2   4       8

	dc.b	3,2,0,1,0,0,0,0

* same/different "oddness" skew

skewtab:   *	S,D

	dc.b	0,8

*	writing mode table
*
*	     color bit
mon_mode:  *	0,1

	dc.b	0,3		; replace
	dc.b	4,7		; transparent
	dc.b	6,6		; xor
	dc.b	1,13		; reverse transparent


chr_mask:

	dc.w	$FF00,$00FF,$FF00,$00FF

chr_nxwd:

	dc.w	0,0,-1,0

chr_skew:

	dc.w	BM_GO+BM_HOG+00
	dc.w	BM_GO+BM_HOG+08
	dc.w	BM_GO+BM_HOG+08
	dc.w	BM_GO+BM_HOG+00


mchar_loop:

	move.l	a0,d0		;4  d0 -> start of font
	add.w	(a2)+,d0	;8  d0 -> 1st byte of character form
	move.l	d0,a3		;4  a3 -> source

	and.w	#$0001,d0	;8  d0 <- 0:even src addr    1:odd src addr
	move.w	d1,d7		;4  d7 -> destination
	lsr.w	#1,d7		;8  cy <- 0:even dst addr    1:odd dst addr
	addx.w	d0,d0		;4  d0 <- index into tables
	add.w	d0,d0		;4  d0 <- offset into tables

	move.w	chr_mask(pc,d0.w),B_F1_MSK(a4)	;22
	move.w	chr_nxwd(pc,d0.w),B_S_NXWD(a4)	;22
	move.w	chr_skew(pc,d0.w),a5		;14   a5 <- SKEW word

	move.w	d5,d0		;4     d0 <- dbra plane counter
	move.w	d6,d7		;4     d7 <- foreground color
	move.l	d1,a1		;4     a1 -> destination


mplan_loop:

	move.l	a3,B_S_ADDR(a4)	;16    set source address
	move.l	a1,B_D_ADDR(a4)	;16    set destination address
	move.w	d3,B_HEIGHT(a4)	;12    set height
	lsr.w	#1,d7		;8     cy <- current foreground color bit
	addx.w	d4,d4		;8     pick it up in writing mode

	move.b	mon_mode(pc,d4.w),B_LOGOP+1(a4) ;22

	lsr.w	#1,d4		;8     restore writing mode

*******************************************************************************
	move.w	a5,(a4)		;8     load SKEW & GO
*******************************************************************************

	addq.l	#2,a1		;8     a1 -> next plane

mchar_sync:

	tst.w	(a4)		;8     BLASTER has finished
	bmi	mchar_sync	;8/10  when GO flag is lo


mchar_cont:

	dbra	d0,mplan_loop	;10/14 do next plane


	addq.l	#1,d1		;8     d1 -> next character destination
	btst.l	#0,d1		;10    if next character on odd byte boundry,
	bne	char1st		 /* 8/10  dst address is same as last character's */

	move.l	a1,d1		;4     d1 -> destination just blasted
	subq.l	#1,d1		;8     d1 -> next character destination

char1st:

	dbra	d2,mchar_loop	;10/14 do next character

#if P68030
	D0_CACR			; d0 <- cache control register
	bset.l	#11,d0			; set "Clr DATA Cache" bit
	CACR_D0			; clear the data cache
#endif

	moveq.l	#1,d0		;4	exit blit with success code in d0
#if TOSVERSION < 0x400
	movea.l   (a7)+,a5
#endif
	rts			;16

#endif /* BLITTER_SUPPORT */
