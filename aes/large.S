/*************************************************************************
 *                       Revision Control System
 * =======================================================================
 *  $Author: mui $       $Date: 89/04/26 18:28:54 $
 * =======================================================================
 *
 * Revision 2.2  89/04/26  18:28:54  mui
 * TT
 * 
 * Revision 2.1  89/02/22  05:30:57  kbad
 * *** TOS 1.4  FINAL RELEASE VERSION ***
 * 
 * Revision 1.1  88/06/02  12:35:49  lozben
 *
 * Initial revision
 * 
 ***************************************************************************
 ***                                                                     ***
 ***                                                                     ***
 ***                             LARGE.S                                 ***
 ***                                                                     ***
 ***                                                                     ***
 ***************************************************************************
 *
 *       10/26/84        Dan Oliver
 *       1/31/85 - 03/21/85      Lowell Webster
 *       05/10/85                Jim Eisenstein
 *       Take out LBFILL, LWFILL, LBDSKIP         03/09/1988     D.Mui           
 *       Subroutines used by CRYSTAL.
 *       Take out LSTRLEN        3/15/88         D.Mui
 *       Use MAC to assemble     6/28/90         D.Mui
 * assemble with MAS 900801 kbad
 */

#define __ASSEMBLER__ 1

#include "config.h"
#include "aesdefs.h"
#include "asmdefs.h"

	text


/*
 *	copy from src to dest until and including a null in the
 *	source string, return the length not including the null.
 *	len = LSTCPY(src,dst)
 *		BYTE	*src,dst;
 */
	xdef	_LSTCPY
_LSTCPY:
	move.l	8(a7),a0	; source
	move.l	4(a7),a1	; destination
	clr.l	d0
lst1:
	addq.b	#1,d0
	move.b	(a0)+,(a1)+	; get and store a byte
	bne	lst1		; test for 0
	subq	#1,d0
	rts

/*
 *	expand from bytes to words until a null, return
 *	number of bytes moved (don't transfer null)
 *
 *	len = LBWMOV(dst,src)
 *		BYTE	*dst,src;
 */
	xdef	_LBWMOV
_LBWMOV:
	move.l	8(a7),a0	; source
	move.l	4(a7),a1	; destination
	clr.l	d0
	clr.l	d1
lbw1:
	move.b	(a0)+,d1	; get a byte
	beq	lbw2		; quit if null       **jde*10-may-85
	move.w	d1,(a1)+	; store a word
	addq.b	#1,d0		; count a character
	bra	lbw1		; test for 0
lbw2:
	rts
	


/*
 * ================================================
 * ==		Copy block of words		==
 *
 * IN:	Address of destination block.
 *	Address of source block.
 *	Number of words to copy.
 *
 *OUT:	Source block duplicated at Destination.
 *
 * ==						==
 * ================================================
 */
	xdef  _LWCOPY
_LWCOPY:

	move.l	4(a7),a0		; Get address of destination.
	move.l	8(a7),a1		; Get address of source.
	move.w	12(a7),d0		; Get number of words to copy.
	beq	lwend			; get out if none

lop105:
	move.w	(a1)+,(a0)+		; Copy word.
	subq	#1,d0
	bne	lop105

lwend:
	rts


/*
 * ================================================
 * ==						==
 * ==		Move block of memory		==
 * ==						==
 *	Moves one block of memory to a new location.  Used mainly to move
 *	a square of screen data to a new position on the screen.  Considers
 *	if the new block overlaps the old.
 *
 * IN:	Destination address		LONG.
 *	Source address			LONG.
 *	Number of bytes to move		WORD.
 *
 *OUT:	No value returned.
 *
 *	Screen will show duplication of selected area in new choosen location.
 */
	xdef	_LBCOPY
_LBCOPY:

	movem.l	4(a7),a0-a1	; A0 = Destination   A1 = Source.
	clr.l	d0
	move.w	12(a7),d0	; D0 = Number of bytes to moves.
	beq	lbcend		; get out if 0
/*
 * Move from source starting at top or bottom?
 */
	cmp.l	a0,a1		; If A1 < A0 then start from bottom of source
	blt	backward	; and go backward.
/*
 * Start at beginning of source and move to end of source.
 */
lop101:
	move.b	(a1)+,(a0)+
	subq.w	#1,d0
	bne	lop101
	rts
/*
 * Start at end of source and move backward to begnning of source.
 */
backward:

	add.l	d0,a1
	add.l	d0,a0
	subq.w	#1,d0

lop102:
	move.b	-(a1),-(a0)
ent100:	subq.w	#1,d0
	bpl	lop102
lbcend:
	rts

