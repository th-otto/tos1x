*********************************  xfrmform.s  ********************************
*
* =============================================================================
* $Author: lozben $	$Date: 91/01/28 18:07:18 $
* =============================================================================
*
* Revision 3.1  91/01/28  18:07:18  lozben
* Adjusted the code to work with the multiple linea variable structures.
*
* Revision 3.0  91/01/03  15:23:38  lozben
* New generation VDI
*
* Revision 2.3  90/07/17  15:07:10  lozben
* in_place() now skips the one plane mode.
*
* Revision 2.2  90/07/13  15:36:26  lozben
* Fixed in_place() and out_of_place() to handle higher rezes.
*
* Revision 2.1  89/02/21  17:29:35  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
*
*******************************************************************************

#include "config.h"
#include "vdidefs.h"
#include "lineaequ.inc"


/*******************************************************************************
 *
 * VDI #110 - vr_trnfm - Transform form
 *
 * name:	_r_trnfm
 *
 * purpose:
 *
 *	transform a device independent memory form into a device dependent form
 *	or vice versa. device independent forms are composed of planes of
 *	contiguous memory while device dependent forms are constructed from
 *	shuffled planes where corresponding words from sequential planes are
 *	contiguous.
 *
 *
 *		device independent		 device dependent
 *
 *		P0W0 P0W1 ... P0Wn		P0W0 P1W0 ... PmW0
 *		P1W0 P1W1 ... P1Wn		P0W1 P1W1 ... PmW1
 *		      .				      .
 *		      .		      <---->	      .
 *		      .				      .
 *		PmW0 PmW1 ... PmWn		P0Wn P1Wn ... PmWn
 *
 *
 *	transformation can be performed in place or the transformation may
 *	be created at another location. note that inplace transformations
 *	take considerably longer to perform.
 *
 *	source and destination MEMORY FORM DEFINITION BLOCKS are input.
 *	the format of the destination is opposite that of the provided source.
 *
 *	it is assumed that the destination form is large enough to receive
 *	the transformed source.
 *
 *
 * author:	jim eisenstein
 *
 * parameters
 *
 *  in:
 *
 *	CONTRL		address of control array (word wide)
 *
 *	control(07-08)	address of source MFDB
 *	control(09-10)	address of destination MFDB
 */


/* memory form base address (0: physical device) */
#define MF_BAS_AD 0
MF_WD_PIX	equ	4	; form width in pixels ( form width in words /16)
MF_HT_PIX	equ	6	; form height in pixels
MF_WD_WRD	equ	8	; form width in words
MF_FORMAT	equ	10	; form format flag (0:device specific 1:standard)
MF_PLANES	equ	12	; number of memory planes

*	CONTRL ARRAY OFFSETS

C_MFDB_S	equ	14	; pointer to source MFDB
C_MFDB_D	equ	18	; pointer to destination MFDB

	page


/* 306de: 00e0d25a */
/* 206de: 00e0da2e */
/* 104de: 00fd1c8e */
/* 106de: 00e11eb2 */
	xdef _vr_trnfm
_vr_trnfm:

	movem.l	d0-d4/a0-a2,-(sp)

	PIXLA(a0)
	move.l	PIXLV(CONTRL,a0),a2		; a2 -> control array
	move.l	C_MFDB_S(a2),a0		; a0 -> source MFDB
	move.l	C_MFDB_D(a2),a1		; a1 -> destination MFDB

	move.w	MF_PLANES(a0),d0	; d0 <- # planes
	move.w	MF_HT_PIX(a0),d1	; d1 <- # lines
	move.w	MF_WD_WRD(a0),d2	; d2 <- planar word wrap

	tst.w	MF_FORMAT(a0)
	bne	di_2_dd


*  convert from device dependent to device independent

dd_2_di:

	move.w	#1,MF_FORMAT(a1)	; device independent format flag (dest)

	mulu	d2,d1			; d1 <- length of DI plane (in words)

*					; d0 <- members per group (# of planes)
	bra	do_it			; d1 <- number of groups  (length of plane)



*  convert from device independent to device dependent

di_2_dd:

	clr.w	MF_FORMAT(a1)		; device dependent format flag (dest)

	mulu	d2,d1			; d1 <- length of DI plane

*					; d0 <- members per group (length of DI plane)
	exg	d0,d1			; d1 <- number of groups  (# of planes)


do_it:

	move.l	MF_BAS_AD(a0),a0	; a0 -> start of source
	move.l	MF_BAS_AD(a1),a1	; a1 -> start of destination

	cmp.l	a0,a1
	beq	xfrm_in_place

	bsr	out_of_place
	bra	quit


xfrm_in_place:

	bsr	in_place

quit:	movem.l	(sp)+,d0-d4/a0-a2
	rts


*  do that crazy in-place shuffle
*
*  in:
*	a0.l	points to start of form
*
*	d0.w	number of members in group
*	d1.w	number of groups
*
*
*			DD -> DI		       DI -> DD
*
*	members:  length of plane in words	     # of planes
*	groups:	       # of planes 	        length of plane in words


in_place:

	dbra	d1,entry02		; iteration count <- number of units - 1; BUG FOR >= 3.00: only decrements word
	rts				; if number was 0, return now

loop02:
	clr.w	d2			; initialize count accumulator
	move	d1,d4			; initialize iteration counter
	bra	entry01

loop01:
	add.w	d0,a0			; a0 <- a1 + (2*d0) + 2
	lea	2(a0,d0.w),a0		; a0 -> element to be repositioned
	move.w	(a0),d7			; save element in d7

	move.l	a0,a1			; a1 -> source in transfer
	move.l	a0,a2			; a2 -> destination in transfer
	add.w	d0,d2			; d2 <- length of transfer
	move.w	d2,d3			; d3 <- loop counter
	bra	entry00

loop00:
	move.l	a1,a2
	move.w	-(a1),(a2)		; move word to the right

entry00:
	dbf	d3,loop00
	move.w	d7,(a1)			; store target element to new home

entry01:
	dbra	d4,loop01
	move.l	a2,a0			; a0 -> start of next cycle

entry02:
	dbra	d0,loop02		; decrease the width by 1. quit on no width
	rts



*  make that boring out-of-place rearrangement
*
*
*  in:
*
*	a0.l	start of source block
*	a1.l	start of destination block
*
*	d0.w	number of members in group  (destination)
*	d1.w	number of groups	    (destination)




out_of_place:
	move.w	d1,d4			; d4 <- pass counter
	add.w	d1,d1			; d0 <- offset to next member word (in bytes)
	bra	entry11

loop11:
	move.l	a1,a2			; a2 <- working destination pointer
	move.w	d0,d3			; d3 <- repeat counter
	bra	entry10

loop10:
	move.w	(a0)+,(a2)		; destination <- source. advance source ptr
	add.w	d1,a2			; advance destination ptr

entry10:
	dbf	d3,loop10
	lea	2(a1),a1		; start another pass

entry11:
	dbf	d4,loop11
	rts
