*********************************  entry.s  ***********************************
*
* =============================================================================
* $Author: lozben $	$Date: 91/02/14 17:57:44 $
* =============================================================================
*
* Revision 3.3  91/02/14  17:57:44  lozben
* We forgot to reference the local_pb of a linea structure pointer.
*
* Revision 3.2  91/02/13  10:36:41  lozben
* Forgot to include "lineaequ.s".
*
* Revision 3.1  91/02/11  13:25:55  lozben
* Adjusted the code to work with the multiple linea variablestructures.
*
* Revision 3.0  91/01/03  15:07:00  lozben
* New generation VDI
*
* Revision 2.2  90/12/05  13:47:32  lozben
* Changed MAX_VERT from 512 to 1024.
*
* Revision 2.1  89/02/21  17:18:57  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
*
*******************************************************************************

#include "config.h"
#include "vdidefs.h"
#include "lineaequ.inc"


max_vert		equ	MAX_PTSIN		; PTSIN maximum length:	1024 verticies


*******************************************************************************
*
* _GSX_ENTRY
*  This module is the front end of the built-in screen GIOS for the Atari RBP.
*  The application will have arrived at this point via
*
*	...
*
*	move	#115,d0
*	move.l	#PB,d1
*	trap	#2
*
*	...
*
* PB:	.dc.l	contrl
*	.dc.l	intin
*	.dc.l	ptsin
*	.dc.l	intout
*	.dc.l	ptsout
*
*******************************************************************************

/* 306de: 00e078b4 */
/* 206de: 00e068c8 */
/* 104de: 00fcab20 */
/* 106de: 00e0ad4c */
/* 100de: 00fc9d34 */
	xdef	_GSX_ENTRY
_GSX_ENTRY:

	movem.l	d1-d7/a0-a6,-(sp)	; Save the callers registers

	move.l	d1,a0			; a0 -> caller's parameter block
	PIXLA(a2)
	lea	PIXLV(local_pb,a2),a1		; a1 -> local parameter block

*   make a local copy of the pointers in the caller's parameter block

	move.l	0(a0),(a1)+		; contrl
	move.l	4(a0),(a1)+		; intin
	move.l	#ptsin_array,(a1)+		; ptsin (local ptsin array)
	move.l	12(a0),(a1)+		; intout
	move.l	16(a0),(a1)+		; ptsout


*   get number of ptsin entries to copy locally

	movea.l 0(a0),a1
	move.w	2(a1),d0	 ; d0 <- number of verticies from CONTRL[1]
	move.w	d0,-(sp)	 ; save copy since driver may alter original
	beq	no_ptsin	 ; no entries to copy

	asl.w      #1,d0
	cmpi.w	#max_vert*2,d0		 ; is it more than we have room for?
	bls	ptsin_ok	 ; no, transfer this number

	move.w	#max_vert*2,d0		 ; yes, set size to max
	move.w	#max_vert,2(a1)	 ; truncate value in user's CONTRL array


*   make a local copy of the PTSIN array

ptsin_ok:
	subq.w     #1,d0        ; for dbra
	move.l  8(a0),a0        ; users ptsin
	move.l #ptsin_array,a1

ptsin_loop:
	move.w	(a0)+,(a1)+		; move verticies
	dbra	d0,ptsin_loop		; d0 contains count ((# of verts))


no_ptsin:

*   jump to SCREEN, front end of C routines for screen GIOS

	jsr	_SCREEN


*   Restore the vertex count in the callers control array

	PIXLA(a2)
	move.l	PIXLV(CONTRL,a2),a0		; a0 -> CONTRL
	move.w	(sp)+,2(a0)		; restore original array length

	movem.l	(sp)+,d1-d7/a0-a6	; Restore the callers registers
	move.w	_FLIP_Y,d0		; d0 indicates magnitude/coordinate

	rts

	data
	xdef _MAX_VERT
_MAX_VERT:
	dc.w	max_vert
